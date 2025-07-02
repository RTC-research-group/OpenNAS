//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
//Date        : Tue Jul  1 10:29:57 2025
//Host        : us running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (adc_clk,
    i2s_bclk,
    i2s_d_in,
    i2s_lr,
    leds,
    okAA,
    okHU,
    okUH,
    okUHU,
    out_ack_n,
    out_data,
    out_req_n,
    pdm_clk_left,
    pdm_clk_right,
    pdm_dat_left,
    pdm_dat_right,
    source_sel);
  output adc_clk;
  input i2s_bclk;
  input i2s_d_in;
  input i2s_lr;
  output [7:0]leds;
  inout okAA;
  output [2:0]okHU;
  input [4:0]okUH;
  inout [31:0]okUHU;
  input out_ack_n;
  output [15:0]out_data;
  output out_req_n;
  output pdm_clk_left;
  output pdm_clk_right;
  input pdm_dat_left;
  input pdm_dat_right;
  input source_sel;

  wire adc_clk;
  wire i2s_bclk;
  wire i2s_d_in;
  wire i2s_lr;
  wire [7:0]leds;
  wire okAA;
  wire [2:0]okHU;
  wire [4:0]okUH;
  wire [31:0]okUHU;
  wire out_ack_n;
  wire [15:0]out_data;
  wire out_req_n;
  wire pdm_clk_left;
  wire pdm_clk_right;
  wire pdm_dat_left;
  wire pdm_dat_right;
  wire source_sel;

  design_1 design_1_i
       (.adc_clk(adc_clk),
        .i2s_bclk(i2s_bclk),
        .i2s_d_in(i2s_d_in),
        .i2s_lr(i2s_lr),
        .leds(leds),
        .okAA(okAA),
        .okHU(okHU),
        .okUH(okUH),
        .okUHU(okUHU),
        .out_ack_n(out_ack_n),
        .out_data(out_data),
        .out_req_n(out_req_n),
        .pdm_clk_left(pdm_clk_left),
        .pdm_clk_right(pdm_clk_right),
        .pdm_dat_left(pdm_dat_left),
        .pdm_dat_right(pdm_dat_right),
        .source_sel(source_sel));
endmodule
