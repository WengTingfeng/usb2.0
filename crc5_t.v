//----------------------------------------------------------------
// name     		: crc5_t
// engineer 		: wtf
// date     		: 2025.3.29
// version  		: v1.0 base
// description : 
//----------------------------------------------------------------
module crc5_t(
//sys signal
input  wire             i_crc5_t_clk              ,
input  wire             i_crc5_t_rst_n            ,
input  wire             i_crc5_t_tx_valid         ,
input  wire  [6:0]      i_crc5_t_tx_addr          ,
input  wire  [3:0]      i_crc5_t_tx_endp          ,
input  wire  [3:0]      i_crc5_t_tx_pid           ,
input  wire             i_crc5_t_tx_to_ready      ,
output wire             o_crc5_t_tx_con_pid_en    ,
output wire  [3:0]      o_crc5_t_tx_con_pid       ,
output wire             o_crc5_t_tx_ready         ,
output wire             o_crc5_t_tx_to_sop        ,
output wire             o_crc5_t_tx_to_eop        ,
output wire             o_crc5_t_tx_to_valid      ,
output wire  [7:0]      o_crc5_t_tx_to_data  
);
//----------------------------------------------------------------
// parameter
//----------------------------------------------------------------

//----------------------------------------------------------------
// reg & wire
//----------------------------------------------------------------
wire  [4:0]     c             ;
wire  [4:0]     crc_out       ;
wire  [10:0]    d             ;

reg   [7:0]     tx_to_data_reg    ;
reg   [6:0]     addr_reg      ;//valid拉高，打一拍
reg   [3:0]     endp_reg      ;//valid拉高，打一拍
reg   [3:0]     pid_reg       ;//valid拉高，打一拍
reg             eop_reg       ;//valid拉高，打一拍
reg             valid_reg     ;//打一拍
reg             con_pid_en_reg;//晚一拍valid拉高
reg   [1:0]     send_cnt      ;

//----------------------------------------------------------------
// logic
//----------------------------------------------------------------
assign c = 5'h1f;
assign d = {addr_reg[0],addr_reg[1] ,addr_reg[2] ,addr_reg[3] ,addr_reg[4] ,addr_reg[5] ,addr_reg[6] , endp_reg[0], endp_reg[1],endp_reg[2],endp_reg[3]};
assign crc_out[0] = d[0] ^ d[1] ^ d[2] ^ d[5] ^ d[6] ^ d[8] ^ c[0] ^ c[1] ^ c[2];
assign crc_out[1] = d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[6] ^ d[7] ^ d[9] ^ c[0] ^ c[1] ^ c[2] ^ c[3];
assign crc_out[2] = d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[4] ^ d[7] ^ d[8] ^ d[10] ^ c[0] ^ c[1] ^ c[2] ^ c[3] ^ c[4];
assign crc_out[3] = d[0] ^ d[3] ^ d[4] ^ d[6] ^ d[9] ^ c[0] ^ c[3] ^ c[4];
assign crc_out[4] = d[0] ^ d[1] ^ d[4] ^ d[5] ^ d[7] ^ d[10] ^ c[0] ^ c[1] ^ c[4];

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          send_cnt <= 'd0;
     else if((pid_reg != 'd0) && (addr_reg != 'd0) && (eop_reg != 1'b1) && (valid_reg == 1'b1))
          send_cnt <= send_cnt + 1'b1;
     else 
          send_cnt <= 'd0;
end 

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          tx_to_data_reg <= 8'b1111_0000;
     else if(valid_reg && send_cnt == 2'b00)
          tx_to_data_reg <= {!pid_reg[3],!pid_reg[2],!pid_reg[1],!pid_reg[0],pid_reg[3],pid_reg[2],pid_reg[1],pid_reg[0]};//pid第一拍输出
     else if(valid_reg && send_cnt == 2'b01)
          tx_to_data_reg <= {endp_reg[3:0],addr_reg[3:0]};
     else if(valid_reg && send_cnt == 2'b10)
          tx_to_data_reg <= {crc_out[4],crc_out[3],crc_out[2],crc_out[1],crc_out[0],addr_reg[6],addr_reg[5],addr_reg[4]};
     else
          tx_to_data_reg <= tx_to_data_reg;
end 


always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          addr_reg <= 'd0;
     else if(i_crc5_t_tx_valid)
          addr_reg <= i_crc5_t_tx_addr;
     else
          addr_reg <= addr_reg;
end 

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          endp_reg <= 'd0;
     else if(i_crc5_t_tx_valid)
          endp_reg <= i_crc5_t_tx_endp;
     else
          endp_reg <= endp_reg;
end 

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          pid_reg <= 'd0;
     else if(i_crc5_t_tx_valid)
          pid_reg <= i_crc5_t_tx_pid;
     else
          pid_reg <= pid_reg;
end 

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          valid_reg <= 'd0;
     else if(send_cnt == 'd0)
          valid_reg <= i_crc5_t_tx_valid;
     else if(i_crc5_t_tx_to_ready == 1'b0)
          valid_reg <= valid_reg;
     else
          valid_reg <= 1'b0;
end 

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          eop_reg <= 'd0;
     else   if(send_cnt == 2'b10 || ( i_crc5_t_tx_valid == 1'b1 && send_cnt == 'd0))
          eop_reg <= 1'b1;
     else   /*if(valid_reg == 1'b1 && i_crc5_t_tx_to_ready == 1'b1)
          eop_reg <= 1'b0;
     else*/
          eop_reg <= eop_reg;
end 

always @(posedge i_crc5_t_clk or negedge i_crc5_t_rst_n) begin
     if(!i_crc5_t_rst_n) 
          con_pid_en_reg <= 'd0;
     else
          con_pid_en_reg <= i_crc5_t_tx_valid;         
end



assign o_crc5_t_tx_con_pid_en  = con_pid_en_reg                  ;
assign o_crc5_t_tx_con_pid     = pid_reg                         ;
assign o_crc5_t_tx_to_sop      = (send_cnt == 'd0)? 1'b1:1'b0    ;
assign o_crc5_t_tx_to_eop      = eop_reg                         ;
assign o_crc5_t_tx_to_valid    = valid_reg                       ;
assign o_crc5_t_tx_to_data     = tx_to_data_reg                  ;
assign o_crc5_t_tx_ready       = !valid_reg                      ;


//----------------------------------------------------------------
// module
//----------------------------------------------------------------

//----------------------------------------------------------------
endmodule
//----------------------------------------------------------------
