module spi_slave(
	clk      ,  
   rst_n    ,  //复位
   data_in  ,  //要发送的数据
   data_out ,  //接收到的数据
   spi_sck  ,  //主机时钟
   spi_miso ,  //主收从发（从机）
   spi_mosi ,  //主发从收（从机）
   spi_cs   ,  //主机片选，低有效（从机）
   tx_en    ,  //发送使能
   tx_done  ,  //发送完成标志位
   rx_done     //接收完成标志位
);
parameter DATA_W  =  16;

parameter SYNC_W  =  2;

//计数器参数
parameter CNT_W   =  4;
parameter CNT_N   =  DATA_W;

input                   clk;
input                   rst_n;
input    [DATA_W-1:0]   data_in;
input                   spi_sck;
input                   spi_mosi;
input                   spi_cs;
input                   tx_en;

output   [DATA_W-1:0]   data_out;
output                  spi_miso;
output                  tx_done;
output                  rx_done;

reg      [DATA_W-1:0]   data_out;
reg                     spi_miso;
reg                     tx_done;
reg                     rx_done;

//中间变量
reg      [SYNC_W-1:0]   sck_sync;
wire                    sck_nedge;
wire                    sck_pedge;
reg                     spi_mosi_reg;

reg      [SYNC_W-1:0]   cs_sync;
// wire                    cs_nedge;
// wire                    cs_pedge;

//计数器变量
reg      [CNT_W-1:0]    cnt_rxbit;
wire                    add_cnt_rxbit;
wire                    end_cnt_rxbit;

reg      [CNT_W-1:0]    cnt_txbit;
wire                    add_cnt_txbit;
wire                    end_cnt_txbit;
reg                     tx_flag;

//CS异步信号同步化
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cs_sync <= 2'b11;
   else
      cs_sync <= {cs_sync[0],spi_cs};
end
assign cs_nedge = cs_sync[1:0] == 2'b10;
// assign cs_pedge = cs_sync[1:0] == 2'b01;

//SCK边沿检测
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      //SCK时钟空闲状态位高电平，工作模式3
      sck_sync <= 2'b11;
   else
      sck_sync <= {sck_sync[0],spi_sck};
end
assign sck_nedge = sck_sync[1:0] == 2'b10;
assign sck_pedge = sck_sync[1:0] == 2'b01;

//上升沿接收，工作模式三
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt_rxbit <= 0;
   else if(add_cnt_rxbit)begin
      if(end_cnt_rxbit)
         cnt_rxbit <= 0;
      else
         cnt_rxbit <= cnt_rxbit + 1'b1;
    end
	else if (cs_nedge)
		cnt_rxbit <= 0;
	else if (cs_sync[1] == 1)
		cnt_rxbit <= 0;
		

end
assign add_cnt_rxbit = sck_pedge && cs_sync[1] == 0;
assign end_cnt_rxbit = add_cnt_rxbit && cnt_rxbit == CNT_N - 1;

//下降沿发送，工作模式三
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt_txbit <= 0;
	else if (cs_nedge)
		cnt_txbit <= 0;
	else if (add_cnt_txbit) begin
      if(cnt_txbit == CNT_N - 1)
         cnt_txbit <= 0;
		else
         cnt_txbit <= cnt_txbit + 1'b1;
	end
	else if (cs_sync[1] == 1)
		cnt_txbit <= 0;

end

assign add_cnt_txbit = sck_nedge && tx_flag && cs_sync[1] == 0;
assign end_cnt_txbit = add_cnt_txbit && cnt_txbit == CNT_N - 1;

//因为异步信号同步化的原因，为了与延后的下降沿对齐,多打一拍
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      spi_mosi_reg <= 0;
   else
      spi_mosi_reg <= spi_mosi;
end

//下降沿接收数据
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)  
      data_out <= 0;
   else if(cs_sync[1] == 0)
      data_out[CNT_N - 1 - cnt_rxbit ] <= spi_mosi_reg;
end

//上升沿发送数据
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      spi_miso <= 0;
   else if(cs_sync[1] == 0 && tx_flag)
      spi_miso <= data_in[CNT_N - 1 - cnt_txbit];
   else
      spi_miso <= 0;
end

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      rx_done <= 0;
   else if(end_cnt_rxbit)
      rx_done <= 1;
   else
      rx_done <= 0;
end

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      tx_done <= 0;
   else if(end_cnt_txbit)
      tx_done <= 1;
   else
      tx_done <= 0;
end


always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      tx_flag <= 0;
   else if(tx_en)
      tx_flag <= 1;
   else if(end_cnt_txbit)
      tx_flag <= 0;
end

endmodule
