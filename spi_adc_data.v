module spi_adc_data (
	//system
	input sys_clk,
	input rst_n,
	//SPI
	input I_spi_mosi,
	input I_spi_sck,
	input I_spi_cs,
	output O_spi_miso,
	//ADC
	input [12:0] ADC_IO,
	output reg trigger_flag,
	//DAC
	output [13:0] da_data,
	output da_clk,
	output clk_drive,
	output GND1,
	output GND2,
	//spi2
	input spi_mosi,
	input spi_sck,
	input spi_cs,
	output spi_miso
	);
wire clk_100m;
assign GND1 = 1'b0;
assign GND2 = 1'b0;
assign clk_drive = sys_clk;
//ADC@50Mhz
reg [15:0] ADC_data_reg;
wire [15:0] ADC_data;
reg [15:0] dummy_data;
assign ADC_data = {4'b0000,ADC_IO[11:0]};
/*always @ (posedge sys_clk or negedge rst_n) begin
	if (!rst_n)
		dummy_data <= 16'd0;
	else if (dummy_data <= 2333)
		dummy_data <= dummy_data + 16'd1;
	else
		dummy_data <= 16'd0;
end*/
always @ (posedge sys_clk or negedge rst_n) begin 
	if (!rst_n)
		ADC_data_reg <= 16'd0;
	else
		ADC_data_reg <= ADC_data;
end

reg [9:0] wr_addr; //spi发送缓存写地址
reg [9:0] rd_addr; //spi发送缓存读地址

reg [1:0] cs_sync;
//reg [12:0] rd_cnt;
wire cs_nedge;
always @(posedge sys_clk or negedge rst_n)begin
   if(!rst_n)
      cs_sync <= 2'b11;
   else
      cs_sync <= {cs_sync[0],I_spi_cs};
end
assign cs_nedge = cs_sync[1:0] == 2'b10;
reg wr_en_flag;
reg rd_en_flag;
wire tx_done;
reg tx_done_reg;
//reg rx_done_reg;
always @(posedge clk_200m or negedge rst_n)begin
	if (!rst_n) 
		tx_done_reg <= 1'b0;
		//rx_done_reg <= 1'b0;
	else
		tx_done_reg <= tx_done;
		//rx_done_reg <= rx_done;

end

always @(posedge sys_clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_en_flag <= 1'b0;
		rd_en_flag <= 1'b0;
	end
	else if (cs_nedge) begin
		wr_en_flag <= 1'b1;
		rd_en_flag <= 1'b0;
	end
	else if (wr_addr == 10'd1023) begin
		wr_en_flag <= 1'b0;
		rd_en_flag <= 1'b1;
	end
	else if (rd_addr == 10'd1023) begin
		wr_en_flag <= wr_en_flag;
		rd_en_flag <= 1'b0;
	end
	else begin
		wr_en_flag <= wr_en_flag;
		rd_en_flag <= rd_en_flag;
	end
end

always @(posedge sys_clk or negedge rst_n) begin
	if (!rst_n)
		wr_addr <= 10'd0;
	else if (wr_en_flag)
		wr_addr <= wr_addr + 10'd1;
	else if (wr_addr == 10'd1023)
		wr_addr <= 10'd0;
	else
		wr_addr <= wr_addr;
end

always @ (posedge clk_200m or negedge rst_n) begin
	if (!rst_n)
		rd_addr <= 10'd0;
	else if (tx_done_reg)
		rd_addr <= rd_addr + 1;
	else if (rd_addr == 12'd1023)
		rd_addr <= 10'd0;
	else
		rd_addr <= rd_addr;
end
//reg trigger_flag;
always @ (posedge sys_clk or negedge rst_n) begin
	if (!rst_n)
		trigger_flag <= 1'b0;
	else if (rd_addr >= 12'd1020)
		trigger_flag <= 1'b1;
	else
		trigger_flag <= 1'b0;
end
wire [9:0] ram_addr;
wire [15:0] spi_data;
assign ram_addr = wr_en_flag ? wr_addr : rd_addr;
wire clk_200m;
//wire [13:0] da_data;
wire [13:0] rd_data_rom1;
wire [13:0] rd_data_rom2;
wire [6:0] rd_addr_rom;

wire [3:0] address_reg;
wire [7:0] data_reg;
reg recv_done_reg;
always @(posedge clk_200m or negedge rst_n) begin
	if (!rst_n) 
		recv_done_reg <= 1'b0;
	else
		recv_done_reg <= recv_done;
end


//wave_form == 72--三角波
//wave_form == 82--正弦波
reg [7:0] wave_form;
reg [7:0] freq;
reg [7:0] default_reg;
always @(posedge clk_200m or negedge rst_n) begin
	//根据address选择寄存器存入数据
	if (!rst_n) begin
		wave_form <= 8'd0;
		freq <= 8'd0;
		default_reg <= 8'd0;
	end
	else if (recv_done_reg) begin
		case (address_reg)
			4'b0010: wave_form <= data_reg;
			4'b0110: freq <= data_reg;
			default: default_reg <= data_reg;
		endcase
	end
end
reg [6:0] wave_sel_addr1;
reg [6:0] wave_sel_addr2;
reg [13:0] wave_sel_data;
always @(posedge clk_200m or negedge rst_n) begin
	if (!rst_n) begin
		wave_sel_addr1 <= 10'd0;
		wave_sel_data <= 10'd0;
		wave_sel_addr2 <= 10'd0;
	end
	else
		case(wave_form)
			8'd82: begin
				wave_sel_addr1 <= rd_addr_rom;
				wave_sel_addr2 <= 10'd0;
				wave_sel_data <= rd_data_rom1;
			end
			8'd104: begin
				wave_sel_addr2 <= rd_addr_rom;
				wave_sel_addr1 <= 10'd0;
				wave_sel_data <= rd_data_rom2;
			end
			default: begin
				wave_sel_addr1 <= rd_addr_rom;
				wave_sel_addr2 <= 10'd0;
				wave_sel_data <= rd_data_rom1;
			end
		endcase
end
wire [15:0] rx_data;
rom_1024_10b u_rom_1024_10b (
	.address (wave_sel_addr1),
	.clock (clk_200m),
	.q (rd_data_rom1)
);
rom_1024_10b_tri u_rom_1024_10b_tri (
	.address (wave_sel_addr2),
	.clock (clk_200m),
	.q (rd_data_rom2)
);

dac_top u_dac_top(
	.clk (clk_100m),
	.rst_n (rst_n),
	.rd_data (wave_sel_data),
	.rd_addr (rd_addr_rom),
	.da_clk (da_clk),
	.da_data (da_data)
);
	
ram_1port u_ram_1port (
	.address (ram_addr),
	.clock (sys_clk),
	.data (ADC_data_reg),
	.rden (rd_en_flag),
	.wren (wr_en_flag),
	.q (spi_data)
);

spi_slave u_spi_slave (
	.clk (clk_200m),
	.rst_n (rst_n),
	.data_in (spi_data),
	.spi_sck (I_spi_sck),
	.spi_mosi (I_spi_mosi),
	.spi_cs (I_spi_cs),
	.tx_en (1'b1),
	.spi_miso (O_spi_miso),
	.tx_done (tx_done),
	//.data_out (rx_data)
	//.tx_en(rd_en_flag)
);
spi_slave2 u_spi_slave2 (
	.clk (clk_200m),
	.rst_n (rst_n),
	.data_in (16'd0),
	.spi_sck (spi_sck),
	.spi_mosi (spi_mosi),
	.spi_cs (spi_cs),
	.tx_en (1'b1),
	.spi_miso (spi_miso),
	//.tx_done (tx_done),
	.data_out (rx_data),
	.rx_done (rx_done)
	//.tx_en(rd_en_flag)
);

pll u_pll (
	.inclk0 (sys_clk),
	.c0 (clk_200m),
	.c1(clk_100m)
);
spi_register (
	.rx_done (rx_done),
	.recv_data (rx_data),
	.clk (clk_200m),
	.rst_n (rst_n),
	.address_reg (address_reg),
	.data_reg (data_reg),
	.recv_done (recv_done)
);
endmodule