`timescale 1ns / 1ps

module DDS_tl(  //CLK in
                input clk,
                input rst,
                //Codec wires
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
                //Volume
                input             bt3,
                input             sw0,
                output            vol_clk,
                output            vol_ud
    );
    
    assign vol_clk = bt3;
    assign vol_ud  = sw0;
        
    wire clk_pll_out;
    wire reset_internal;
    wire pll_lock;
    //CLK generation
    clk_wiz_0 clock_pll(.clk_in1(clk),
                        .reset(rst),
                        .locked(pll_lock),
                        .clk_out1(clk_pll_out)
                        );    
    //RESET
    assign reset_internal = ~pll_lock | rst;
    //VIO
    wire [23:0] cntrl_word;
    wire [1:0] signal_sel;
    wire [14:0] gain_set;
    vio_DDS vio(.clk(clk_pll_out),
                .probe_out0(cntrl_word),
                .probe_out1(signal_sel),
                .probe_out2(gain_set));
    //DDS
    wire [23:0] wave_out;
    DDS dds_int(.clk(clk_pll_out),
                .rst(reset_internal),
                .cntrl_word(cntrl_word),
                .wave_sel(signal_sel),
                .attenn(gain_set),
                .wave_out(wave_out),
                .nco_out(),
                .sin_out(),
                .tri_out(),
                .sqr_out(),
                .nco_dith(),
                .rnd());
    //AUDIO CODEC
    codec_if codec( .clk(clk_pll_out),
                    .rst(reset_internal),
                    //IO connections
                    .codec_m0      (codec_m0),
                    .codec_m1      (codec_m1),
                    .codec_i2s     (codec_i2s),
                    .codec_mdiv1   (codec_mdiv1),
                    .codec_mdiv2   (codec_mdiv2),
                    .codec_rstn    (codec_rstn),
                    .codec_mclk    (codec_mclk),
                    .codec_lrclk   (codec_lrclk),
                    .codec_sclk    (codec_sclk),
                    .codec_sdin    (codec_sdin),
                    .codec_sdout   (codec_sdout),
                    //We don't care about outputs
                    .aud_dout_vld  (),
                    .aud_dout      (),
                    //Inputs, same on both channel
                    .aud_din_vld   (2'b11),
                    .aud_din_ack   (),
                    .aud_din0      (wave_out),
                    .aud_din1      (wave_out)
                    );
    
endmodule
