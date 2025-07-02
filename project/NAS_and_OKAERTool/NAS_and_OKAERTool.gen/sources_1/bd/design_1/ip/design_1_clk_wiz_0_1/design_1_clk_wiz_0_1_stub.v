// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Tue Jul  1 10:30:21 2025
// Host        : us running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/arios/Projects/OpenNAS/created_projects/project/NAS_and_OKAERTool/NAS_and_OKAERTool.gen/sources_1/bd/design_1/ip/design_1_clk_wiz_0_1/design_1_clk_wiz_0_1_stub.v
// Design      : design_1_clk_wiz_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module design_1_clk_wiz_0_1(clk_out1, clk_out2, resetn, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_out2,resetn,locked,clk_in1" */;
  output clk_out1;
  output clk_out2;
  input resetn;
  output locked;
  input clk_in1;
endmodule
