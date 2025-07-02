// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Tue May  6 12:56:32 2025
// Host        : us running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_OpenNas_Parallel_STE_0_0_stub.v
// Design      : design_1_OpenNas_Parallel_STE_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "OpenNas_Parallel_STEREO_64ch,Vivado 2022.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clock, rst_n, pdm_clk_left, pdm_dat_left, 
  pdm_clk_right, pdm_dat_right, i2s_bclk, i2s_d_in, i2s_lr, source_sel, config_data, config_addr, 
  config_wren, aer_data_out, aer_req, aer_ack)
/* synthesis syn_black_box black_box_pad_pin="clock,rst_n,pdm_clk_left,pdm_dat_left,pdm_clk_right,pdm_dat_right,i2s_bclk,i2s_d_in,i2s_lr,source_sel,config_data[15:0],config_addr[15:0],config_wren,aer_data_out[7:0],aer_req,aer_ack" */;
  input clock;
  input rst_n;
  output pdm_clk_left;
  input pdm_dat_left;
  output pdm_clk_right;
  input pdm_dat_right;
  input i2s_bclk;
  input i2s_d_in;
  input i2s_lr;
  input source_sel;
  input [15:0]config_data;
  input [15:0]config_addr;
  input config_wren;
  output [7:0]aer_data_out;
  output aer_req;
  input aer_ack;
endmodule
