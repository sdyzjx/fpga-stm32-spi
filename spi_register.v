module spi_register (
	input rx_done,
	input [15:0] recv_data,
	input clk, //200m
	input rst_n,
	output reg [3:0] address_reg,
	output reg [7:0] data_reg,
	output reg recv_done
);
//signiture:0110
reg rx_done_reg;
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		rx_done_reg <= 1'b0;
	else
		rx_done_reg <= rx_done;
end
reg [15:0] recv_data_reg;
//reg process_flag;
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		recv_data_reg <= 16'd0;
		//process_flag = 1'b0;
	end
	else if (rx_done_reg)
		recv_data_reg <= recv_data;
	else
		recv_data_reg <= recv_data_reg;
end
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		address_reg <= 8'd0;
		data_reg <= 8'd0;
		recv_done <= 1'b0;
	end
	else if (rx_done_reg) begin
		if (recv_data_reg[15:12] == 4'b0110) begin
			address_reg <= recv_data_reg[11:8];
			data_reg <= recv_data_reg[7:0];
			recv_done <= 1'b1;
		end
	end
	else begin
		address_reg <= address_reg;
		data_reg <= data_reg;
		recv_done <= 1'b0;
	end
end

endmodule