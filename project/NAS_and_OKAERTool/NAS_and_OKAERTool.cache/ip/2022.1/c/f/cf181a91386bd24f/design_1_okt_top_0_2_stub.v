// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Tue May 20 12:07:56 2025
// Host        : us running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_okt_top_0_2_stub.v
// Design      : design_1_okt_top_0_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "okt_top,Vivado 2022.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(rst_ext_n, clock, rst_sw_n, okUH, okHU, okUHU, okAA, 
  port_a_data, port_a_req_n, port_a_ack_n, port_b_data, port_b_req_n, port_b_ack_n, 
  port_c_data, port_c_req_n, port_c_ack_n, out_data, out_req_n, out_ack_n, config_data, 
  config_addr, config_en, leds)
/* synthesis syn_black_box black_box_pad_pin="rst_ext_n,clock,rst_sw_n,okUH[4:0],okHU[2:0],okUHU[31:0],okAA,port_a_data[7:0],port_a_req_n,port_a_ack_n,port_b_data[7:0],port_b_req_n,port_b_ack_n,port_c_data[7:0],port_c_req_n,port_c_ack_n,out_data[15:0],out_req_n,out_ack_n,config_data[15:0],config_addr[15:0],config_en[2:0],leds[7:0]" */;
  input rst_ext_n;
  output clock;
  output rst_sw_n;
  input [4:0]okUH;
  output [2:0]okHU;
  inout [31:0]okUHU;
  inout okAA;
  input [7:0]port_a_data;
  input port_a_req_n;
  output port_a_ack_n;
  input [7:0]port_b_data;
  input port_b_req_n;
  output port_b_ack_n;
  input [7:0]port_c_data;
  input port_c_req_n;
  output port_c_ack_n;
  output [15:0]out_data;
  output out_req_n;
  input out_ack_n;
  output [15:0]config_data;
  output [15:0]config_addr;
  output [2:0]config_en;
  output [7:0]leds;
endmodule
