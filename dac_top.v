module dac_top(
	input clk,
	input rst_n,
	input [13:0] rd_data,
	output reg [6:0] rd_addr, //1024地址线
	output [13:0] da_data,
	output da_clk
	);
	
parameter FREQ_ADJ = 10'd0;
reg [9:0] freq_cnt;

assign da_clk = clk;
assign da_data = 14'h3FFF - rd_data;
//频率调节计数器
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0)
		freq_cnt <= 10'd0;
	else if(freq_cnt == FREQ_ADJ)
		freq_cnt <= 10'd0;
	else
		freq_cnt <= freq_cnt + 10'd1;
end

//读ROM地址
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0)
		rd_addr <= 10'd0;
	else if (rd_addr < 10'd97)begin
		if(freq_cnt == FREQ_ADJ) begin
			rd_addr <= rd_addr + 10'd1;
		end
	end
	else if (rd_addr == 10'd97)
		rd_addr <= 10'd0;
end

endmodule

