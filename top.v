//----------------------------------------------------------------
// name     		: top
// engineer 		: wtf
// date     		: 2025.4.7
// version  		: v1.0 base
// description : 
//----------------------------------------------------------------
`include "./control_t.v"
`include "./crc5_r.v"
`include "./crc5_t.v"
`include "./crc16_r.v"
`include "./link_ctrl.v"
module top(
//sys signal
input  wire                 i_top_clk               ,
input  wire                 i_top_rst_n             ,
input  wire     [6:0]       i_top_self_addr         ,
input  wire                 i_top_ms                ,
input  wire     [15:0]      i_top_time_threshold    ,
input  wire     [5:0]       i_top_delay_threshole   ,
input  wire                 i_top_rx_lp_sop         ,
input  wire                 i_top_rx_lp_eop         ,
input  wire                 i_top_rx_lp_valid       ,
input  wire    [7:0]        i_top_rx_lp_data        ,
input  wire                 i_top_rx_lt_ready       ,
input  wire                 i_top_tx_lp_ready       ,
input  wire    [3:0]        i_top_tx_pid            ,
input  wire    [6:0]        i_top_tx_addr           ,
input  wire    [3:0]        i_top_tx_endp           ,
input  wire                 i_top_tx_valid          ,
input  wire                 i_top_tx_lt_sop         ,
input  wire                 i_top_tx_lt_eop         ,
input  wire                 i_top_tx_lt_valid       ,
input  wire    [7:0]        i_top_tx_lt_data        ,
input  wire                 i_top_tx_lt_cancle      ,

output wire                 o_top_crc5_err          ,
output wire                 o_top_time_out          ,
output wire                 o_top_d_oe              ,
output wire                 o_top_rx_lp_ready       ,
output wire                 o_top_tx_lp_sop         ,
output wire                 o_top_tx_lp_eop         ,
output wire                 o_top_tx_lp_valid       ,
output wire    [7:0]        o_top_tx_lp_data        ,
output wire                 o_top_tx_lp_cancle      ,
output wire                 o_top_rx_pid_en         ,
output wire    [3:0]        o_top_rx_pid            ,
output wire    [3:0]        o_top_rx_endp           ,
output wire                 o_top_rx_lt_sop         ,
output wire                 o_top_rx_lt_eop         ,
output wire                 o_top_rx_lt_valid       ,
output wire    [7:0]        o_top_rx_lt_data        ,
output wire                 o_top_tx_ready          ,
output wire                 o_top_tx_lt_ready       ,
output wire                 o_top_crc16_r_error     
);
//----------------------------------------------------------------
// parameter
//----------------------------------------------------------------

//----------------------------------------------------------------
// reg & wire
//----------------------------------------------------------------
wire            rx_sop         ;
wire            rx_eop         ;
wire            rx_valid       ;
wire [7:0]      rx_data        ;
wire            rx_ready       ;
wire            rx_lt_eop_en   ;
wire            rx_sop_en      ;
wire            rx_handshake_on;
wire            rx_data_on     ;
wire            tx_data_on     ;
wire            tx_lp_eop_en   ;
wire            tx_to_sop      ;
wire            tx_to_eop      ;
wire            tx_to_valid    ;
wire [7:0]      tx_to_data     ;
wire            tx_to_ready    ;
wire            tx_con_pid_en  ;
wire [3:0]      tx_con_pid     ;
                
//----------------------------------------------------------------
// logic
//----------------------------------------------------------------

//----------------------------------------------------------------
// module
//----------------------------------------------------------------
crc5_r crc5_r_u1(
.i_crc5_r_clk             (i_top_clk        ),
.i_crc5_r_rst_n           (i_top_rst_n      ),
.i_crc5_r_self_addr       (i_top_self_addr  ),
.i_crc5_r_rx_lp_data      (i_top_rx_lp_data ),
.i_crc5_r_rx_lp_sop       (i_top_rx_lp_sop  ),
.i_crc5_r_rx_lp_valid     (i_top_rx_lp_valid),
.i_crc5_r_rx_lp_eop       (i_top_rx_lp_eop  ),
.i_crc5_r_rx_ready        (rx_ready         ),
.i_crc5_r_rx_handshake_on (rx_handshake_on  ),
.o_crc5_r_rx_sop          (rx_sop           ),
.o_crc5_r_rx_eop          (rx_eop           ),
.o_crc5_r_rx_valid        (rx_valid         ),
.o_crc5_r_rx_data         (rx_data          ),
.o_crc5_r_rx_pid          (o_top_rx_pid     ),
.o_crc5_r_rx_pid_en       (o_top_rx_pid_en  ),
.o_crc5_r_rx_lp_ready     (o_top_rx_lp_ready),
.o_crc5_r_crc5_error      (o_top_crc5_err   ),
.o_crc5_r_rx_endp         (o_top_rx_endp    )      
);

crc16_r crc16_r_u1(
.i_crc16_r_clk         (i_top_clk            ),
.i_crc16_r_rst_n       (i_top_rst_n          ),
.i_crc16_r_rx_sop      (rx_sop               ),
.i_crc16_r_rx_eop      (rx_eop               ),
.i_crc16_r_rx_valid    (rx_valid             ),
.i_crc16_r_rx_data     (rx_data              ),
.i_crc16_r_rx_data_on  (rx_data_on           ),
.i_crc16_r_rx_lt_ready (i_top_rx_lt_ready    ),
.o_crc16_r_rx_lt_sop   (o_top_rx_lt_sop      ),
.o_crc16_r_rx_lt_eop   (o_top_rx_lt_eop      ),
.o_crc16_r_rx_lt_data  (o_top_rx_lt_data     ),
.o_crc16_r_rx_lt_valid (o_top_rx_lt_valid    ),
.o_crc16_r_rx_ready    (rx_ready             ),
.o_crc16_r_rx_lt_eop_en(rx_lt_eop_en         ),
.o_crc16_r_rx_sop_en   (rx_sop_en            ),
.o_crc16_r_crc16_error (o_top_crc16_r_error  ) 
);

link_ctrl link_ctrl_u1(
.i_link_ctrl_clk            (i_top_clk              ),
.i_link_ctrl_rst_n          (i_top_rst_n            ),
.i_link_ctrl_ms             (i_top_ms               ),
.i_link_ctrl_delay_shreshole(i_top_delay_threshole  ), 
.i_link_ctrl_time_threshold (i_top_time_threshold   ), 
.i_link_ctrl_rx_sop_en      (rx_sop_en              ),
.i_link_ctrl_rx_lt_eop_en   (rx_lt_eop_en           ),
.i_link_ctrl_tx_con_pid_en  (tx_con_pid_en          ),
.i_link_ctrl_tx_con_pid     (tx_con_pid             ),
.i_link_ctrl_rx_pid         (o_top_rx_pid           ),
.i_link_ctrl_tx_lp_eop_en   (tx_lp_eop_en           ),
.i_link_ctrl_rx_pid_en      (o_top_rx_pid_en        ),
.o_link_ctrl_rx_handshake_on(rx_handshake_on        ),
.o_link_ctrl_rx_data_on     (rx_data_on             ),
.o_link_ctrl_tx_data_on     (tx_data_on             ),
.o_link_ctrl_d_oe           (o_top_d_oe             ), 
.o_link_ctrl_time_out       (o_top_time_out         ) 
);

control_t control_t_u1(
.i_control_t_clk          (i_top_clk          ),       
.i_control_t_rst_n        (i_top_rst_n        ),  
.i_control_t_tx_lt_sop    (i_top_tx_lt_sop    ),  
.i_control_t_tx_lt_eop    (i_top_tx_lt_eop    ),
.i_control_t_tx_lt_valid  (i_top_tx_lt_valid  ),  
.i_control_t_tx_lt_data   (i_top_tx_lt_data   ),   
.i_control_t_tx_lt_cancle (i_top_tx_lt_cancle ),   
.i_control_t_tx_lp_ready  (i_top_tx_lp_ready  ),  
.i_control_t_tx_data_on   (tx_data_on         ),
.i_control_t_tx_to_sop    (tx_to_sop          ),
.i_control_t_tx_to_eop    (tx_to_eop          ),
.i_control_t_tx_to_valid  (tx_to_valid        ),
.i_control_t_tx_to_data   (tx_to_data         ),
.o_control_t_tx_to_ready  (tx_to_ready        ),
.o_control_t_tx_lp_eop_en (tx_lp_eop_en       ),
.o_control_t_tx_lt_ready  (o_top_tx_lt_ready  ),   
.o_control_t_tx_lp_sop    (o_top_tx_lp_sop    ),   
.o_control_t_tx_lp_eop    (o_top_tx_lp_eop    ),   
.o_control_t_tx_lp_valid  (o_top_tx_lp_valid  ),   
.o_control_t_tx_lp_data   (o_top_tx_lp_data   ),   
.o_control_t_tx_lp_cancle (o_top_tx_lp_cancle )              
);

crc5_t crc5_t_u1(
.i_crc5_t_clk          (i_top_clk          ),
.i_crc5_t_rst_n        (i_top_rst_n        ),
.i_crc5_t_tx_valid     (i_top_tx_valid     ),
.i_crc5_t_tx_addr      (i_top_tx_addr      ),
.i_crc5_t_tx_endp      (i_top_tx_endp      ),
.i_crc5_t_tx_pid       (i_top_tx_pid       ), 
.i_crc5_t_tx_to_ready  (tx_to_ready        ),
.o_crc5_t_tx_to_sop    (tx_to_sop          ),
.o_crc5_t_tx_to_eop    (tx_to_eop          ),
.o_crc5_t_tx_to_valid  (tx_to_valid        ),
.o_crc5_t_tx_to_data   (tx_to_data         ),
.o_crc5_t_tx_con_pid_en(tx_con_pid_en      ),
.o_crc5_t_tx_con_pid   (tx_con_pid         ),
.o_crc5_t_tx_ready     (o_top_tx_ready     ) 
);

//----------------------------------------------------------------
endmodule
//----------------------------------------------------------------
