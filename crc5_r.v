//--------------------------------------------------
// name         : crc5_r                                  
// engineer     : Yy
// date         : 2025.4.3
// version      : v0
//description   : 验证令牌包
//--------------------------------------------------
module crc5_r
( 
input wire       i_crc5_r_clk              ,
input wire       i_crc5_r_rst_n            ,
input wire [7:0] i_crc5_r_rx_lp_data       ,
input wire       i_crc5_r_rx_lp_sop        ,
input wire       i_crc5_r_rx_lp_valid      ,
input wire       i_crc5_r_rx_lp_eop        ,
input wire       i_crc5_r_rx_ready         ,
input wire [6:0] i_crc5_r_self_addr        ,
input wire       i_crc5_r_rx_handshake_on  ,

output wire       o_crc5_r_crc5_error      ,
output wire       o_crc5_r_rx_eop          ,
output wire       o_crc5_r_rx_sop          ,
output wire       o_crc5_r_rx_valid        ,
output wire [7:0] o_crc5_r_rx_data         ,
output wire [3:0] o_crc5_r_rx_endp         ,
output wire [3:0] o_crc5_r_rx_pid          ,
output wire       o_crc5_r_rx_pid_en       ,
output wire       o_crc5_r_rx_lp_ready
);
//--------------------------------------------------
// reg & wire
//--------------------------------------------------

reg        pid_ok            ;
reg        pid_is_not_data   ;
wire [4:0] crc_reg           ;
reg        crc5_r_crc5_error ;
reg [3:0]  crc5_r_rx_endp    ; 
reg [3:0]  crc5_r_rx_pid     ;   
reg [3:0]  crc5_r_rx_pid_en  ;
//--------------------------------------------------
// logic
//--------------------------------------------------

  assign crc_reg[0] = i_crc5_r_rx_lp_data[2] ^ i_crc5_r_rx_lp_data[3] ^ i_crc5_r_rx_lp_data[5] ^ 1 ^ 0;
  assign crc_reg[1] = i_crc5_r_rx_lp_data[0] ^ i_crc5_r_rx_lp_data[3] ^ i_crc5_r_rx_lp_data[4] ^ i_crc5_r_rx_lp_data[6] ^ 1 ^ 0 ^ 0;
  assign crc_reg[2] = i_crc5_r_rx_lp_data[0] ^ i_crc5_r_rx_lp_data[1] ^ i_crc5_r_rx_lp_data[4] ^ i_crc5_r_rx_lp_data[5] ^ i_crc5_r_rx_lp_data[7] ^ 1 ^ 0 ^ 0;
  assign crc_reg[3] = i_crc5_r_rx_lp_data[0] ^ i_crc5_r_rx_lp_data[1] ^ i_crc5_r_rx_lp_data[3] ^ i_crc5_r_rx_lp_data[6] ^ 1 ^ 0 ^ 0;
  assign crc_reg[4] = i_crc5_r_rx_lp_data[1] ^ i_crc5_r_rx_lp_data[2] ^ i_crc5_r_rx_lp_data[4] ^ i_crc5_r_rx_lp_data[7] ^ 0 ^ 1 ^ 0;

always@(posedge i_crc5_r_clk or negedge i_crc5_r_rst_n)
begin
  if(!i_crc5_r_rst_n)
    crc5_r_crc5_error <= 1'b0;
  else if (i_crc5_r_rx_lp_eop && i_crc5_r_rx_lp_valid)
    if (crc_reg != 5'b01000)
      crc5_r_crc5_error <= 1'b1;
    else
      crc5_r_crc5_error <= 1'b0;
  else
      crc5_r_crc5_error <= 1'b0;
end

always@(posedge i_crc5_r_clk or negedge i_crc5_r_rst_n)
begin
  if (!i_crc5_r_rst_n)
    pid_ok <= 1'b0;
  else if (i_crc5_r_rx_lp_sop || ~i_crc5_r_rx_lp_eop)
    begin
      if(~i_crc5_r_rx_lp_data[7:4] == i_crc5_r_rx_lp_data[3:0])//正确的pid应该高低相反
        pid_ok <= 1'b1;
    end
  else
    pid_ok <= 1'b0;
end

always@(*)
begin
  if (pid_ok)//数据包起始阶段
    begin
      case (i_crc5_r_rx_lp_data)
        8'b11100001 : crc5_r_rx_pid = 4'b0001 ;
        8'b01101001 : crc5_r_rx_pid = 4'b1001 ;
        8'b10100101 : crc5_r_rx_pid = 4'b0101 ;
        8'b00101101 : crc5_r_rx_pid = 4'b1101 ;
        8'b01001011 : crc5_r_rx_pid = 4'b1011 ;
        8'b11100111 : crc5_r_rx_pid = 4'b0111 ;
        8'b00001111 : crc5_r_rx_pid = 4'b1111 ;
        8'b10100101 : crc5_r_rx_pid = 4'b0101 ;
        8'b01011010 : crc5_r_rx_pid = 4'b1010 ;
        8'b00011110 : crc5_r_rx_pid = 4'b1110 ;
        8'b10010110 : crc5_r_rx_pid = 4'b0110 ;
        default     : crc5_r_rx_pid = 4'b0000 ;
      endcase
    end
  else
    crc5_r_rx_pid = 4'b0;
end

always@(*)
begin
  if (pid_ok)//数据包起始阶段
    begin
      case (i_crc5_r_rx_lp_data)
        8'b11100001 : pid_is_not_data = 1'b1 ;
        8'b01101001 : pid_is_not_data = 1'b1 ;
        8'b10100101 : pid_is_not_data = 1'b1 ;
        8'b00101101 : pid_is_not_data = 1'b1 ;
        8'b01001011 : pid_is_not_data = 1'b0 ;
        8'b11100111 : pid_is_not_data = 1'b0 ;
        8'b00001111 : pid_is_not_data = 1'b0 ;
        8'b10100101 : pid_is_not_data = 1'b0 ;
        8'b01011010 : pid_is_not_data = 1'b0 ;
        8'b00011110 : pid_is_not_data = 1'b0 ;
        8'b10010110 : pid_is_not_data = 1'b0 ;
        default     : pid_is_not_data = 1'b0 ;
      endcase
    end
  else
    crc5_r_rx_pid = 4'b0;
end
always@(posedge i_crc5_r_clk or negedge i_crc5_r_rst_n)//用时序逻辑让en信号在下一个周期再变
begin
  if(!i_crc5_r_rst_n)
    crc5_r_rx_pid_en <= 1'b0;
  else if (i_crc5_r_rx_lp_sop && i_crc5_r_rx_lp_valid)//数据有效部位
    crc5_r_rx_pid_en <= 1'b1;
  else
    crc5_r_rx_pid_en <= 1'b0;
end

always@(posedge i_crc5_r_clk or negedge i_crc5_r_rst_n)
begin
  if(!i_crc5_r_rst_n)
    crc5_r_rx_endp <= 4'b0;
  else if (!i_crc5_r_rx_lp_sop && i_crc5_r_rx_lp_valid)
    crc5_r_rx_endp[0] <= i_crc5_r_rx_lp_data[7];//由于lsb在左，所以这一帧的最高位时ENDP的Msb
  else if (i_crc5_r_rx_lp_valid && i_crc5_r_rx_lp_eop)
    crc5_r_rx_endp[3:1] <= i_crc5_r_rx_lp_data[2:0];//下一帧的低三位是ENDP的高三位，最终也就是【ENDP0,ENDP1,ENDP2,ENDP3】
  else
    crc5_r_rx_endp <= 4'b0;
end

assign o_crc5_r_rx_lp_ready = 1'b1                  ;
assign o_crc5_r_rx_sop      = i_crc5_r_rx_lp_sop    ;
assign o_crc5_r_rx_eop      = i_crc5_r_rx_lp_eop    ;
assign o_crc5_r_rx_valid    = i_crc5_r_rx_lp_valid  ;
assign o_crc5_r_rx_data     = i_crc5_r_rx_lp_data   ;

assign o_crc5_r_crc5_error = crc5_r_crc5_error      ;
assign o_crc5_r_rx_endp    = crc5_r_rx_endp         ;
assign o_crc5_r_rx_pid     = crc5_r_rx_pid          ;
assign o_crc5_r_rx_pid_en  = crc5_r_rx_pid_en       ;
endmodule