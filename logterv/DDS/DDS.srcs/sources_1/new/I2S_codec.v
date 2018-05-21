`timescale 1ns / 1ps

module codec_if
(
   input             clk,
   input             rst,
   
   output            codec_m0,
   output            codec_m1,
   output            codec_i2s,
   output            codec_mdiv1,
   output            codec_mdiv2,
   
   output            codec_rstn,
   output            codec_mclk,
   output            codec_lrclk,
   output            codec_sclk,
   output            codec_sdin,
   input             codec_sdout,
   
   output reg [ 1:0] aud_dout_vld,
   output     [23:0] aud_dout,
   
   input      [ 1:0] aud_din_vld,
   output reg [ 1:0] aud_din_ack,
   input      [23:0] aud_din0,
   input      [23:0] aud_din1
);


reg [19:0] div_cntr;
// LRCK: clk/512
// startup wait: 2048

reg rst_ff;
reg init_done_ff;

wire lrclk_fall;
wire lrclk_rise;
wire sclk_fall;
wire sclk_rise;

wire [ 4:0] bit_cntr;

reg  [23:0] shr_rx;
reg  [23:0] shr_tx;

begin

//Config : single-speed MCLK/SCLK 256
assign codec_m0      = 1'b0;
assign codec_m1      = 1'b0;
assign codec_i2s     = 1'b0;
assign codec_mdiv1   = 1'b0;
assign codec_mdiv2   = 1'b0;

always @ (posedge clk)
if (rst==1)
  div_cntr <= 0;
else
  div_cntr <= div_cntr + 1;

assign codec_lrclk  = div_cntr[8];
assign codec_sclk   = div_cntr[2];
assign codec_mclk   = div_cntr[0];

assign sclk_fall    = (div_cntr[2:0]==3'b111);
assign sclk_rise    = (div_cntr[2:0]==3'b011);

assign bit_cntr     = div_cntr[7:3];

always @ (posedge clk)
if (rst==1)
   rst_ff <= 1'b0;
else if (div_cntr[19:9]==7)
   rst_ff <= 1'b1;
      
assign codec_rstn = rst_ff;

always @ (posedge clk)
if (rst==1)
   init_done_ff <= 1'b0;
else if (div_cntr[19:9]==1200)
   init_done_ff <= 1'b1;


always @ (posedge clk)
if (sclk_rise==1)
   shr_rx <= {shr_rx[22:0], codec_sdout};

always @ (posedge clk)
if (div_cntr[8]==0 & bit_cntr==23 & sclk_rise==1 & init_done_ff==1)
   aud_dout_vld[0] <= 1'b1;
else
   aud_dout_vld[0] <= 1'b0;


always @ (posedge clk)
   if (div_cntr[8]==1 & bit_cntr==23 & sclk_rise==1 & init_done_ff==1)
      aud_dout_vld[1] <= 1'b1;
   else
      aud_dout_vld[1] <= 1'b0;

end

assign aud_dout = shr_rx;


always @ (posedge clk)
if (init_done_ff==0)
   shr_tx <= 0;
else if (div_cntr[8]==0 & bit_cntr==31 & sclk_fall==1)
   shr_tx <= aud_din0;
else if (div_cntr[8]==1 & bit_cntr==31 & sclk_fall==1)
   shr_tx <= aud_din1;
else if (sclk_fall==1)
   shr_tx <= {shr_tx[22:0], 1'b0};

assign codec_sdin = shr_tx[23];

always @ (posedge clk)
if (div_cntr[8]==0 & bit_cntr==31 & sclk_fall==1)
   aud_din_ack[0] <= 1'b1;
else
   aud_din_ack[0] <= 1'b0;
   
always @ (posedge clk)
if (div_cntr[8]==1 & bit_cntr==31 & sclk_fall==1)
   aud_din_ack[1] <= 1'b1;
else
   aud_din_ack[1] <= 1'b0;
 

endmodule
