//----------------------------------------------------------------
// name     		: link_ctrl
// engineer 		: wtf
// date     		: 2025.3.21
// version  		: v1.0 base
// description : 
//----------------------------------------------------------------
module link_ctrl(
//sys signal
input  wire             i_link_ctrl_clk             ,
input  wire             i_link_ctrl_rst_n           ,
input  wire             i_link_ctrl_ms              ,
input  wire    [5:0]    i_link_ctrl_delay_shreshole ,
input  wire    [15:0]   i_link_ctrl_time_threshold  ,
input  wire    [3:0]    i_link_ctrl_rx_pid          ,
input  wire             i_link_ctrl_rx_pid_en       ,
input  wire             i_link_ctrl_rx_sop_en       ,
input  wire             i_link_ctrl_rx_lt_eop_en    ,
input  wire    [3:0]    i_link_ctrl_tx_con_pid      ,
input  wire             i_link_ctrl_tx_con_pid_en   ,
input  wire             i_link_ctrl_tx_lp_eop_en    ,
output wire             o_link_ctrl_time_out        ,
output wire             o_link_ctrl_rx_data_on      ,
output wire             o_link_ctrl_rx_handshake_on ,
output wire             o_link_ctrl_tx_data_on      ,
output wire             o_link_ctrl_d_oe            //1:phy数据接收完成，trans向phy发送数据；0：接收phy数据，phy向trans发送数据

);
//----------------------------------------------------------------
// parameter
//----------------------------------------------------------------

//----------------------------------------------------------------
// reg & wire
//----------------------------------------------------------------
reg [15:0]  timer                       ;//最大为time_threshold
reg [5:0]   delay_cnt                   ;//延迟计数器，最大为delay_shreshole
reg [1:0]   master_finish_sending_wr    ;
reg         master_finish_sending_rt    ;
reg         delay_on                    ;//延迟开始计数
reg         master_d_oe                 ;//delay结束到下一个包进来之前？
reg         rx_sop_en_regd              ;
reg         slave_d_oe                  ;//d_oe
reg         slave_has_received_rt       ;//tx_data_on
reg         rx_handshake_on             ;
reg         rx_sop_en_signal_r          ;//下降沿reg
reg         tx_lp_eop_signal_r          ;//下降沿reg

wire        delay_done                  ;//delay_cnt计数满，拉低d_oe和master_d_oe
wire        slave_receive_rt            ;//d_oe=1,crc5_r_rx_pid使能
wire        slave_receive_wt            ;
wire        master_send_rt              ;
wire        master_send_wt              ;
wire        ms_receive_hs               ;//d_oe=0,crc5_r_rx_pid使能

//----------------------------------------------------------------
// logic
//----------------------------------------------------------------
always @(*) begin//暂时没用到的信号赋初值
     if(!i_link_ctrl_rst_n)
     master_finish_sending_rt = 'd0;
     master_finish_sending_wr = 'd0;
     rx_sop_en_regd           = 'd0;
 end
 assign o_link_ctrl_rx_data_on      = 'd0;
 assign o_link_ctrl_time_out        = 'd0;
 assign master_send_rt              = 'd0;
 assign master_send_wt              = 'd0;
 assign slave_receive_wt            = 'd0;

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin//lp_eop下降沿reg
     if(!i_link_ctrl_rst_n)
         tx_lp_eop_signal_r <= 1'b0;
     else
         tx_lp_eop_signal_r <= i_link_ctrl_tx_lp_eop_en;
 end

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin//lp_eop下降沿reg
     if(!i_link_ctrl_rst_n)
         rx_sop_en_signal_r <= 1'b0;
     else
         rx_sop_en_signal_r <= i_link_ctrl_rx_pid_en;
 end

assign slave_receive_rt = master_d_oe  ? rx_sop_en_signal_r : 1'b0;
assign ms_receive_hs    = (master_d_oe == 1'b0) ? rx_sop_en_signal_r : 1'b0;

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        slave_has_received_rt <= 1'b0;
    else if((slave_has_received_rt ^ slave_receive_rt) && !tx_lp_eop_signal_r )
        slave_has_received_rt <= 1'b1;
    else
        slave_has_received_rt <= 1'b0;
end

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        slave_d_oe <= 1'b0;
    else if((slave_d_oe ^ slave_receive_rt) && !delay_done )
        slave_d_oe <= 1'b1;
    else
        slave_d_oe <= 1'b0;
end

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        delay_on <= 1'b0;
    else if((tx_lp_eop_signal_r ^ delay_on) && !delay_done)
        delay_on <= 1'b1;
    else
        delay_on <= 1'b0;
end

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        timer <= 'd0;
    else if(rx_handshake_on && !ms_receive_hs && timer <= 200)
        timer <= timer + 1;
    else
        timer <= 'd0;
end

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        rx_handshake_on = 1'b0;
    else if((tx_lp_eop_signal_r ^ rx_handshake_on ) && !ms_receive_hs)
        rx_handshake_on = 1'b1;
    else
        rx_handshake_on = 1'b0;
end

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        delay_cnt <= 'd0;
    else if(delay_on)
        delay_cnt <= delay_cnt + 1;
    else
        delay_cnt <= 'd0;
end

assign delay_done = (delay_cnt == 'h3f) ? 1'b1 : 1'b0;

always @(posedge i_link_ctrl_clk or negedge i_link_ctrl_rst_n) begin
    if(!i_link_ctrl_rst_n)
        master_d_oe <= 1'b1;
    else if((delay_done == master_d_oe) && !ms_receive_hs)
        master_d_oe <= 1'b0;
    else 
        master_d_oe <= 1'b1;
end


assign o_link_ctrl_rx_handshake_on  = rx_handshake_on       ;
assign o_link_ctrl_tx_data_on       = slave_has_received_rt ;
assign o_link_ctrl_d_oe             = slave_d_oe            ;

//----------------------------------------------------------------
// module
//----------------------------------------------------------------
/*crc5_r crc5_r_u0(
.o_crc5_r_rx_pid           (i_link_ctrl_rx_pid         )   ,
.o_crc5_r_rx_pid_en        (i_link_ctrl_rx_pid_en      )   ,
.i_crc5_r_rx_handshake_on  (o_link_ctrl_rx_handshake_on)         
);

crc16_r crc16_r_u0(
.i_crc16_r_rx_data_on    (o_link_ctrl_rx_data_on    ),
.o_crc16_r_rx_sop_en     (i_link_ctrl_rx_sop_en     ),
.o_crc16_r_rx_lt_eop_en  (i_link_ctrl_rx_lt_eop_en  )    
);

control_t control_t_u0(
.i_control_t_tx_data_on   (o_link_ctrl_tx_data_on   ),
.o_control_t_tx_lp_eop_en (i_link_ctrl_tx_lp_eop_en )
);

crc5_t crc5_t_u0(
.o_crc5_t_tx_con_pid_en (i_link_ctrl_tx_con_pid_en  ),
.o_crc5_t_tx_con_pid    (i_link_ctrl_tx_con_pid     )
);*/
//----------------------------------------------------------------
endmodule
//----------------------------------------------------------------
