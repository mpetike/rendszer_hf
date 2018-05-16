// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
// Date        : Wed May 16 18:47:51 2018
// Host        : Peti-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Peti/Documents/VIK_MSc/rendszer/rendszer_hf/logterv/DDS/DDS.srcs/sources_1/ip/vio_DDS/vio_DDS_stub.v
// Design      : vio_DDS
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k70tfbg676-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2017.2" *)
module vio_DDS(clk, probe_out0, probe_out1, probe_out2)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_out0[23:0],probe_out1[1:0],probe_out2[14:0]" */;
  input clk;
  output [23:0]probe_out0;
  output [1:0]probe_out1;
  output [14:0]probe_out2;
endmodule
