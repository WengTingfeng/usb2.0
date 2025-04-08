//--------------------------------------------------
// name         :                                   
// engineer     : Yy
// date         : 2025.4.8
// version      : v0
//description   :
//--------------------------------------------------
`timescale 1ps/1ps
`include "./top.v"
module top_tb;
// sys 
 reg           i_top_clk             ;
 reg           i_top_rst_n           ;
 reg   [6:0]   i_top_self_addr       ;
 reg           i_top_ms              ;
 reg   [15:0]  i_top_time_threshold  ;
 reg   [5:0]   i_top_delay_threshole ;
 reg           i_top_rx_lp_sop       ;
 reg           i_top_rx_lp_eop       ;
 reg           i_top_rx_lp_valid     ;
 reg   [7:0]   i_top_rx_lp_data      ;
 reg           i_top_tx_lp_ready     ;
 reg           i_top_rx_lt_ready     ;
 reg   [3:0]   i_top_tx_pid          ;
 reg   [6:0]   i_top_tx_addr         ;
 reg   [3:0]   i_top_tx_endp         ;
 reg           i_top_tx_valid        ;
 reg           i_top_tx_lt_sop       ;
 reg           i_top_tx_lt_eop       ;
 reg           i_top_tx_lt_valid     ;
 reg   [7:0]   i_top_tx_lt_data      ;
 reg           i_top_tx_lt_cancle    ;
 wire         o_top_crc5_err        ;
 wire         o_top_time_out        ;
 wire         o_top_d_oe            ;
 wire         o_top_rx_lp_ready     ;
 wire         o_top_tx_lp_sop       ;
 wire         o_top_tx_lp_eop       ;
 wire         o_top_tx_lp_valid     ;
 wire   [7:0] o_top_tx_lp_data      ;
 wire         o_top_tx_lp_cancle    ;
 wire         o_top_rx_pid_en       ; 
 wire   [3:0] o_top_rx_pid          ;
 wire   [3:0] o_top_rx_endp         ;
 wire         o_top_rx_lt_sop       ;
 wire         o_top_rx_lt_eop       ;
 wire         o_top_rx_lt_valid     ;
 wire   [7:0] o_top_rx_lt_data      ;
 wire         o_top_tx_ready        ;
 wire         o_top_tx_lt_ready     ;

top top_tb(
.i_top_clk             (i_top_clk             ),
.i_top_rst_n           (i_top_rst_n           ),
.i_top_self_addr       (i_top_self_addr       ),
.i_top_ms              (i_top_ms              ),
.i_top_time_threshold  (i_top_time_threshold  ),
.i_top_delay_threshole (i_top_delay_threshole ),
.i_top_rx_lp_sop       (i_top_rx_lp_sop       ),
.i_top_rx_lp_eop       (i_top_rx_lp_eop       ),
.i_top_rx_lp_valid     (i_top_rx_lp_valid     ),
.i_top_rx_lp_data      (i_top_rx_lp_data      ),
.i_top_tx_lp_ready     (i_top_tx_lp_ready     ),
.i_top_rx_lt_ready     (i_top_rx_lt_ready     ),
.i_top_tx_pid          (i_top_tx_pid          ),
.i_top_tx_addr         (i_top_tx_addr         ),
.i_top_tx_endp         (i_top_tx_endp         ),
.i_top_tx_valid        (i_top_tx_valid        ),
.i_top_tx_lt_sop       (i_top_tx_lt_sop       ),
.i_top_tx_lt_eop       (i_top_tx_lt_eop       ),
.i_top_tx_lt_valid     (i_top_tx_lt_valid     ),
.i_top_tx_lt_data      (i_top_tx_lt_data      ),
.i_top_tx_lt_cancle    (i_top_tx_lt_cancle    ),
.o_top_crc5_err        (o_top_crc5_err        ),
.o_top_time_out        (o_top_time_out        ),
.o_top_d_oe            (o_top_d_oe            ),
.o_top_rx_lp_ready     (o_top_rx_lp_ready     ),
.o_top_tx_lp_sop       (o_top_tx_lp_sop       ),
.o_top_tx_lp_eop       (o_top_tx_lp_eop       ),
.o_top_tx_lp_valid     (o_top_tx_lp_valid     ),
.o_top_tx_lp_data      (o_top_tx_lp_data      ),
.o_top_tx_lp_cancle    (o_top_tx_lp_cancle    ),
.o_top_rx_pid_en       (o_top_rx_pid_en       ),
.o_top_rx_pid          (o_top_rx_pid          ),
.o_top_rx_endp         (o_top_rx_endp         ),
.o_top_rx_lt_sop       (o_top_rx_lt_sop       ),
.o_top_rx_lt_eop       (o_top_rx_lt_eop       ),
.o_top_rx_lt_valid     (o_top_rx_lt_valid     ),
.o_top_rx_lt_data      (o_top_rx_lt_data      ),
.o_top_tx_ready        (o_top_tx_ready        ),
.o_top_tx_lt_ready     (o_top_tx_lt_ready     )
);

initial begin
  i_top_clk             = 1'b0;
  i_top_rst_n           = 1'b0;
  i_top_self_addr       = 7'b0001000;
  i_top_ms              = 1'b0;
  i_top_time_threshold  = 16'b11001000;
  i_top_delay_threshole = 6'b111111;
  i_top_rx_lp_sop       = 1'b0;
  i_top_rx_lp_eop       = 1'b0;
  i_top_rx_lp_valid     = 1'b0;
  i_top_rx_lp_data      = 8'b0;
  i_top_tx_lp_ready     = 1'b1;
  i_top_rx_lt_ready     = 1'b1;         
  i_top_tx_pid          = 4'b0;
  i_top_tx_addr         = 7'b0;
  i_top_tx_endp         = 4'b0;
  i_top_tx_valid        = 1'b0;
  i_top_tx_lt_sop       = 1'b0;
  i_top_tx_lt_eop       = 1'b0;
  i_top_tx_lt_valid     = 1'b0;
  i_top_tx_lt_data      = 8'b0;
  i_top_tx_lt_cancle    = 1'b0;
  forever #5 i_top_clk = ~i_top_clk;
end

initial begin
case0();
$finish;
end



task case0 ;
  begin
  repeat(10)@(posedge i_top_clk);
    #1;
    i_top_rst_n = 1'b1;
  repeat(1)@(posedge i_top_clk);
    #1;
    i_top_rx_lp_data = 8'b01101001;
    i_top_rx_lp_sop = 1'b1;
    i_top_rx_lp_valid = 1'b1;
  repeat(1)@(posedge i_top_clk);
    #1;
    i_top_rx_lp_valid = 1'b0;
  repeat(20)@(posedge i_top_clk);
    #1;
    i_top_rx_lp_data = 8'b00001000;
    i_top_rx_lp_sop = 1'b0;
    i_top_rx_lp_valid = 1'b1;
  repeat(1)@(posedge i_top_clk);
    #1;
    i_top_rx_lp_valid = 1'b0;
  repeat(20)@(posedge i_top_clk);
  #1;
    i_top_rx_lp_data = 8'b01011000;
    i_top_rx_lp_eop = 1'b1;
    i_top_rx_lp_valid = 1'b1;
  repeat(1)@(posedge i_top_clk);
  #1;
    i_top_rx_lp_valid = 1'b0;
  repeat(1)@(posedge i_top_clk);
  #1;
    i_top_tx_lt_data = 8'b1100_0011;
    i_top_tx_lt_sop   = 1'b1;
    i_top_tx_lt_valid = 1'b1;
  repeat(1)@(posedge i_top_clk);
  #1;
    i_top_tx_lt_data = 8'b00000001;
    i_top_tx_lt_sop  = 1'b0;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00000010;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00000011;
  repeat(20)@(posedge i_top_clk);
  i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00000100;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00000101;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00000110;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00000111;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00001000;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_data = 8'b00001001;
    i_top_tx_lt_eop = 1'b1;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;
  #1;
    i_top_tx_lt_valid = 1'b0;
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(1)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b0;  
  repeat(20)@(posedge i_top_clk);
    i_top_tx_lp_ready  = 1'b1;
  repeat(30)@(posedge i_top_clk);
    i_top_rx_lp_data = 8'b00000000;
    i_top_rx_lp_eop = 1'b0;
  repeat(1)@(posedge i_top_clk);
    #1;
    i_top_rx_lp_data = 8'b11010010;
    i_top_rx_lp_eop = 1'b1;
    i_top_rx_lp_sop = 1'b1;
    i_top_rx_lp_valid = 1'b1;
  repeat(1)@(posedge i_top_clk);
    #1;
    i_top_rx_lp_valid =1'b0;
  repeat(300)@(posedge i_top_clk);
  end
endtask
  
endmodule