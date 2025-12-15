//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
//Date        : Wed Sep 24 12:59:49 2025
//Host        : us running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1
   (i2s_bclk,
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
    source_sel,
    pdm_clk_left,
    pdm_clk_right,
    pdm_dat_left,
    pdm_dat_right);
  
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
  input source_sel;
  output pdm_clk_left;
  output pdm_clk_right;
  input pdm_dat_left;
  input pdm_dat_right;

  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]OpenNas_Cascade_STER_0_aer_data_out;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Cascade_STER_0_aer_req;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Cascade_STER_0_pdm_clk_left;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Cascade_STER_0_pdm_clk_right;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]OpenNas_Parallel_STE_0_aer_data_out;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Parallel_STE_0_aer_req;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire clk_wiz_0_clk_out1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [0:0]config_0_Dout;
//   wire [0:0]config_1_Dout;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire i2s_bclk_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire i2s_d_in_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire i2s_lr_0_1;
  wire [4:0]okUH_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]okt_sno_top_2_AER_DATA_OUT;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_sno_top_2_AER_REQ;
  wire okt_top_0_clock;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [15:0]okt_top_0_config_addr;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [15:0]okt_top_0_config_data;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [2:0]okt_top_0_config_en;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]okt_top_0_leds;
  wire [2:0]okt_top_0_okHU;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [15:0]okt_top_0_out_data;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_out_req_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_port_a_ack_n;
//  wire okt_top_0_port_b_ack_n;
 (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_port_c_ack_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_rst_sw_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire out_ack_n_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire pdm_dat_left_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire pdm_dat_right_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire source_sel_0_1;

  assign source_sel_0_1 = ~source_sel;
  assign i2s_bclk_0_1 = i2s_bclk;
  assign i2s_d_in_0_1 = i2s_d_in;
  assign i2s_lr_0_1 = i2s_lr;
  assign leds[7:0] = okt_top_0_leds;
  assign okHU[2:0] = okt_top_0_okHU;
  assign okUH_0_1 = okUH[4:0];
  assign out_ack_n_0_1 = out_ack_n;
  assign out_data[15:0] = okt_top_0_out_data;
  assign out_req_n = okt_top_0_out_req_n;
  assign pdm_clk_left = OpenNas_Cascade_STER_0_pdm_clk_left;
  assign pdm_clk_right = OpenNas_Cascade_STER_0_pdm_clk_right;
  assign pdm_dat_left_0_1 = pdm_dat_left;
  assign pdm_dat_right_0_1 = pdm_dat_right;
  assign config_0_Dout = okt_top_0_config_en[0];
//   assign config_1_Dout = okt_top_0_config_en[1];
  assign okt_sno_top_2_AER_REQ = 1'b1;
  assign okt_sno_top_2_AER_DATA_OUT = 8'b0;
  assign OpenNas_Parallel_STE_0_aer_data_out = 8'b0;
  assign OpenNas_Parallel_STE_0_aer_req = 1'b1;

  OpenNas_Cascade_STEREO_64ch OpenNas_Cascade_STEREO_64ch_0
       (.aer_ack(okt_top_0_port_a_ack_n),//okt_top_0_port_a_ack_n
        .aer_data_out(OpenNas_Cascade_STER_0_aer_data_out),//OpenNas_Cascade_STER_0_aer_data_out
        .aer_req(OpenNas_Cascade_STER_0_aer_req),//OpenNas_Cascade_STER_0_aer_req
        .clock(clk_wiz_0_clk_out1),
//        .config_addr(okt_top_0_config_addr),
//        .config_data(okt_top_0_config_data),
//        .config_wren(config_0_Dout),
        .i2s_bclk(i2s_bclk_0_1),
        .i2s_d_in(i2s_d_in_0_1),
        .i2s_lr(i2s_lr_0_1),
        .pdm_clk_left(OpenNas_Cascade_STER_0_pdm_clk_left),
        .pdm_clk_right(OpenNas_Cascade_STER_0_pdm_clk_right),
        .pdm_dat_left(pdm_dat_left_0_1),
        .pdm_dat_right(pdm_dat_right_0_1),
        .rst_ext(okt_top_0_rst_sw_n),
        .source_sel(source_sel_0_1));

//  OpenNas_Parallel_STEREO_64ch OpenNas_Parallel_STE_0
//       (.aer_ack(okt_top_0_port_b_ack_n),
//        .aer_data_out(OpenNas_Parallel_STE_0_aer_data_out),
//        .aer_req(OpenNas_Parallel_STE_0_aer_req),
//        .clock(clk_wiz_0_clk_out1),
//        .config_addr(okt_top_0_config_addr),
//        .config_data(okt_top_0_config_data),
//        .config_wren(config_1_Dout),
//        .i2s_bclk(i2s_bclk_0_1),
//        .i2s_d_in(i2s_d_in_0_1),
//        .i2s_lr(i2s_lr_0_1),
//        .pdm_dat_left(pdm_dat_left_0_1),
//        .pdm_dat_right(pdm_dat_right_0_1),
//        .rst_n(okt_top_0_rst_sw_n),
//        .source_sel(source_sel_0_1));

  Reloj clk_wiz_0
       (.clk_in1(okt_top_0_clock),
        .clk_out1(clk_wiz_0_clk_out1));
  
// okt_sno_top okt_sno_top_0
//      (.AER_ACK(okt_top_0_port_c_ack_n),
//       .AER_DATA_OUT(okt_sno_top_2_AER_DATA_OUT),
//       .AER_REQ(okt_sno_top_2_AER_REQ),
//       .clock(clk_wiz_0_clk_out1),
//       .rst_n(okt_top_0_rst_sw_n));

  okt_top okt_top_0
       (.clock(okt_top_0_clock),
        .config_addr(okt_top_0_config_addr),
        .config_data(okt_top_0_config_data),
        .config_en(okt_top_0_config_en),
        .leds(okt_top_0_leds),
        .okAA(okAA),
        .okHU(okt_top_0_okHU),
        .okUH(okUH_0_1),
        .okUHU(okUHU[31:0]),
        .out_ack_n(out_ack_n_0_1),//out_ack_n_0_1
        .out_data(okt_top_0_out_data),//okt_top_0_out_data
        .out_req_n(okt_top_0_out_req_n),//okt_top_0_out_req_n
        .port_a_ack_n(okt_top_0_port_a_ack_n),
        .port_a_data(OpenNas_Cascade_STER_0_aer_data_out),
        .port_a_req_n(OpenNas_Cascade_STER_0_aer_req),
        .port_b_ack_n(),
        .port_b_data(OpenNas_Parallel_STE_0_aer_data_out),
        .port_b_req_n(OpenNas_Parallel_STE_0_aer_req),
        .port_c_ack_n(),
        .port_c_data(okt_sno_top_2_AER_DATA_OUT),
        .port_c_req_n(okt_sno_top_2_AER_REQ),
        .rst_ext_n(okt_top_0_rst_sw_n),
        .rst_sw_n(okt_top_0_rst_sw_n));

endmodule
