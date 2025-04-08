//----------------------------------------------------------------
// name     		: crc16_r
// engineer 		: wtf
// date     		: 2025.4.5
// version  		: v1.0 base
// description : 
//----------------------------------------------------------------
module crc16_r(
//sys signal
input  wire             i_crc16_r_clk           ,
input  wire             i_crc16_r_rst_n         ,
input  wire             i_crc16_r_rx_sop        ,
input  wire             i_crc16_r_rx_eop        ,
input  wire             i_crc16_r_rx_valid      ,
input  wire   [7:0]     i_crc16_r_rx_data       ,
input  wire             i_crc16_r_rx_data_on    ,
input  wire             i_crc16_r_rx_lt_ready   ,
output wire             o_crc16_r_rx_ready      ,
output wire             o_crc16_r_rx_lt_sop     ,
output wire             o_crc16_r_rx_lt_eop     ,
output wire             o_crc16_r_rx_lt_valid   ,
output wire   [7:0]     o_crc16_r_rx_lt_data    ,
output wire             o_crc16_r_rx_sop_en     ,
output wire             o_crc16_r_rx_lt_eop_en  ,
output wire             o_crc16_r_crc16_error
);
//----------------------------------------------------------------
// parameter
//----------------------------------------------------------------

//----------------------------------------------------------------
// reg & wire
//----------------------------------------------------------------
wire                    packet_is_data      ;
wire                    tran_buf            ;
reg     [7:0]           data_reg            ;
reg                     sop_reg             ;
reg                     eop_reg             ;
reg                     tran_en             ;
reg                     valid_reg           ;
//----------------------------------------------------------------
// logic
//----------------------------------------------------------------
assign packet_is_data = ((data_reg == 8'b1100_0011) && (i_crc16_r_rx_data_on == 1'b1) )? 1'b1 : 1'b0;
assign tran_buf       = i_crc16_r_rx_data_on      ? i_crc16_r_rx_valid : 1'b0;


always @(posedge i_crc16_r_clk or negedge i_crc16_r_rst_n) begin
    if(!i_crc16_r_rst_n)
        sop_reg <= 1'b0;
    else    if(i_crc16_r_rx_data_on)
        sop_reg <= i_crc16_r_rx_sop;
    else
        sop_reg <= 1'b0;
end

always @(posedge i_crc16_r_clk or negedge i_crc16_r_rst_n) begin
    if(!i_crc16_r_rst_n)
        valid_reg <= 1'b0;
    else    if(i_crc16_r_rx_data_on)
        valid_reg <= i_crc16_r_rx_valid;
    else
        valid_reg <= 1'b0;
end

always @(posedge i_crc16_r_clk or negedge i_crc16_r_rst_n) begin
    if(!i_crc16_r_rst_n)
        eop_reg <= 1'b0;
    else    if(i_crc16_r_rx_data_on && i_crc16_r_rx_eop)
        eop_reg <= 1'b1;
    else    if(i_crc16_r_rx_sop)
        eop_reg <= 1'b0;
    else
        eop_reg <= eop_reg;
end

always @(posedge i_crc16_r_clk or negedge i_crc16_r_rst_n) begin
    if(!i_crc16_r_rst_n)
        data_reg <= 'd0;
    else    if(i_crc16_r_rx_data_on && i_crc16_r_rx_valid)
        data_reg <= i_crc16_r_rx_data;
    else
        data_reg <= data_reg;
end

always @(posedge i_crc16_r_clk or negedge i_crc16_r_rst_n) begin
    if(!i_crc16_r_rst_n)
        tran_en <= 'd0;
    else    if(i_crc16_r_rx_data_on && (i_crc16_r_rx_eop == 1'b0) && i_crc16_r_rx_valid)
        tran_en <= 1'b1;
    else    if(i_crc16_r_rx_eop)
        tran_en <= 1'b0;  
    else
        tran_en <= tran_en;
end







assign o_crc16_r_rx_sop_en      = (packet_is_data && tran_buf)  ?             1'b1 : 1'b0   ;
assign o_crc16_r_rx_lt_eop_en   = (eop_reg && valid_reg)        ?             1'b1 : 1'b0   ;
assign o_crc16_r_rx_lt_sop      = i_crc16_r_rx_data_on          ? sop_reg          : 1'b0   ;
assign o_crc16_r_rx_lt_valid    = i_crc16_r_rx_valid            ? valid_reg        : 1'b0   ;
assign o_crc16_r_rx_lt_data     = data_reg                                                  ;
assign o_crc16_r_rx_lt_eop      = eop_reg                                                   ;
assign o_crc16_r_crc16_error    = 1'b0;//case先赋0
assign o_crc16_r_rx_ready       = 1'bz;
//----------------------------------------------------------------
// module
//----------------------------------------------------------------

//----------------------------------------------------------------
endmodule
//----------------------------------------------------------------
