// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed May 14 10:31:02 2025
// Host        : us running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_okt_sno_top_0_0_stub.v
// Design      : design_1_okt_sno_top_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "okt_sno_top,Vivado 2022.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clock, rst_n, AER_DATA_OUT, AER_REQ, AER_ACK)
/* synthesis syn_black_box black_box_pad_pin="clock,rst_n,AER_DATA_OUT[7:0],AER_REQ,AER_ACK" */;
  input clock;
  input rst_n;
  output [7:0]AER_DATA_OUT;
  output AER_REQ;
  input AER_ACK;
endmodule
