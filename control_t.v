//----------------------------------------------------------------
// name     		: control_t
// engineer 		: wtf
// date     		: 2025.3.29
// version  		: v1.0 base
// description : 
//----------------------------------------------------------------
module control_t(
//sys signal
input  wire             i_control_t_clk             ,
input  wire             i_control_t_rst_n           ,
input  wire             i_control_t_tx_to_sop       ,
input  wire             i_control_t_tx_to_eop       ,
input  wire             i_control_t_tx_to_valid     ,
input  wire  [7:0]      i_control_t_tx_to_data      ,
input  wire             i_control_t_tx_lt_sop       ,
input  wire             i_control_t_tx_lt_eop       ,
input  wire             i_control_t_tx_lt_valid     ,
input  wire  [7:0]      i_control_t_tx_lt_data      ,
input  wire             i_control_t_tx_lt_cancle    ,
input  wire             i_control_t_tx_lp_ready     ,
input  wire             i_control_t_tx_data_on      ,
output wire             o_control_t_tx_to_ready     ,
output wire             o_control_t_tx_lt_ready     ,
output wire             o_control_t_tx_lp_sop       ,
output wire             o_control_t_tx_lp_eop       ,
output wire             o_control_t_tx_lp_valid     ,
output wire  [7:0]      o_control_t_tx_lp_data      ,
output wire             o_control_t_tx_lp_cancle    ,
output wire             o_control_t_tx_lp_eop_en
);
//----------------------------------------------------------------
// parameter
//----------------------------------------------------------------

//----------------------------------------------------------------
// reg & wire
//----------------------------------------------------------------
wire  [7:0] data_buf        ;//lt_data to lp_data buffer
wire        sop_buf         ;
wire        eop_buf         ;
wire        valid_buf       ;
wire        ready_buf       ;
wire        lp_valid_buf    ;
wire        lp_eop_en_buf   ;
wire        cancle_buf      ;
wire        lp_eop_buf      ;

reg   [7:0] lp_data_buf     ;
reg         lp_sop_buf      ;


//----------------------------------------------------------------
// logic
//----------------------------------------------------------------
assign data_buf      = i_control_t_rst_n ? (i_control_t_tx_data_on ? i_control_t_tx_lt_data  : i_control_t_tx_to_data      ) : i_control_t_tx_to_data             ;
assign sop_buf       = i_control_t_rst_n ? (i_control_t_tx_data_on ? i_control_t_tx_lt_sop   : i_control_t_tx_to_sop       ) : 'd1                                ;
assign eop_buf       = i_control_t_rst_n ? (i_control_t_tx_data_on ? i_control_t_tx_lt_eop   : i_control_t_tx_to_eop       ) : 'd0                                ;
assign valid_buf     = i_control_t_rst_n ? (i_control_t_tx_data_on ? i_control_t_tx_lt_valid : 1'b0                        ) : 'd0                                ;             
assign ready_buf     = i_control_t_rst_n ? (i_control_t_tx_data_on ? i_control_t_tx_lp_ready : 1'b1                        ) : 'd1                                ;
assign cancle_buf    = i_control_t_rst_n ? (i_control_t_tx_lt_cancle                                                       ) : 'd0                                ;                           
assign lp_valid_buf  = i_control_t_rst_n ? ((lp_valid_buf ^ lp_sop_buf  && i_control_t_tx_data_on)? 1'b1:((i_control_t_tx_data_on)? lp_valid_buf: 'd0)) : 'd0     ;
assign lp_eop_en_buf = i_control_t_rst_n ? (lp_eop_buf ? eop_buf && ready_buf : 'd0                                        ) : 'd0                                ;
assign lp_eop_buf    = i_control_t_rst_n ? ((i_control_t_tx_lt_eop && i_control_t_tx_lt_data == lp_data_buf) ? 1'b1 : 1'b0 ) : 'd0                                ;

always @(posedge i_control_t_clk or negedge i_control_t_rst_n) begin
    if(!i_control_t_rst_n)
        lp_data_buf <= 'd0;
    else if(ready_buf && i_control_t_tx_data_on)
        lp_data_buf <= data_buf;
    else
        lp_data_buf <= lp_data_buf;
end

always @(posedge i_control_t_clk or negedge i_control_t_rst_n) begin
    if(!i_control_t_rst_n)
        lp_sop_buf <= 1'b0;
    else if((lp_sop_buf ^ i_control_t_tx_lt_sop) && i_control_t_tx_data_on && i_control_t_tx_lp_ready)
        lp_sop_buf <= 1'b1;
    else
        lp_sop_buf <= 1'b0;
end 

assign o_control_t_tx_lp_sop    = lp_sop_buf                                    ; 
assign o_control_t_tx_lp_valid  = lp_valid_buf                                  ; 
assign o_control_t_tx_lp_data   = lp_data_buf                                   ;
assign o_control_t_tx_lp_cancle = cancle_buf                                    ;
assign o_control_t_tx_to_ready  = ~i_control_t_tx_data_on                       ;
assign o_control_t_tx_lt_ready  = i_control_t_tx_data_on? ready_buf : 1'b0      ;
assign o_control_t_tx_lp_eop    = lp_eop_buf                                    ;
assign o_control_t_tx_lp_eop_en = lp_eop_en_buf                                 ;
//----------------------------------------------------------------
// module
//----------------------------------------------------------------

//----------------------------------------------------------------
endmodule
//----------------------------------------------------------------
