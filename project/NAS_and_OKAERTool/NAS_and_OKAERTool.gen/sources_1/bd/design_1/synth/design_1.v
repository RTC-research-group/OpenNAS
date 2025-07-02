//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
//Date        : Tue Jul  1 10:29:57 2025
//Host        : us running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=7,numReposBlks=7,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=4,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ADC_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ADC_CLK, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 49200000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output adc_clk;
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

  (* DEBUG = "true" *) (* MARK_DEBUG *) wire Net;
  wire [31:0]Net1;
  wire Net2;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]OpenNas_Cascade_STER_0_aer_data_out;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Cascade_STER_0_aer_req;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Cascade_STER_0_pdm_clk_left;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Cascade_STER_0_pdm_clk_right;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]OpenNas_Parallel_STE_0_aer_data_out;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire OpenNas_Parallel_STE_0_aer_req;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_clk_out2;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [0:0]config_1_Dout;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire i2s_bclk_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire i2s_d_in_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire i2s_lr_0_1;
  wire [4:0]okUH_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]okt_sno_top_0_AER_DATA_OUT;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_sno_top_0_AER_REQ;
  wire okt_top_0_clock;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [15:0]okt_top_0_config_addr;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [15:0]okt_top_0_config_data;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [2:0]okt_top_0_config_en;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [7:0]okt_top_0_leds;
  wire [2:0]okt_top_0_okHU;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [15:0]okt_top_0_out_data;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_out_req_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_port_c_ack_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_rome_a_ack_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire okt_top_0_rome_b_ack_n;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire out_ack_n_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire pdm_dat_left_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire pdm_dat_right_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire source_sel_0_1;
  (* DEBUG = "true" *) (* MARK_DEBUG *) wire [0:0]xlslice_0_Dout;

  assign adc_clk = clk_wiz_0_clk_out2;
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
  assign source_sel_0_1 = source_sel;
  design_1_OpenNas_Cascade_STER_0_2 OpenNas_Cascade_STER_0
       (.aer_ack(okt_top_0_rome_a_ack_n),
        .aer_data_out(OpenNas_Cascade_STER_0_aer_data_out),
        .aer_req(OpenNas_Cascade_STER_0_aer_req),
        .clock(clk_wiz_0_clk_out1),
        .config_addr(okt_top_0_config_addr),
        .config_data(okt_top_0_config_data),
        .config_wren(xlslice_0_Dout),
        .i2s_bclk(i2s_bclk_0_1),
        .i2s_d_in(i2s_d_in_0_1),
        .i2s_lr(i2s_lr_0_1),
        .pdm_clk_left(OpenNas_Cascade_STER_0_pdm_clk_left),
        .pdm_clk_right(OpenNas_Cascade_STER_0_pdm_clk_right),
        .pdm_dat_left(pdm_dat_left_0_1),
        .pdm_dat_right(pdm_dat_right_0_1),
        .rst_n(Net),
        .source_sel(source_sel_0_1));
  design_1_OpenNas_Parallel_STE_0_0 OpenNas_Parallel_STE_0
       (.aer_ack(okt_top_0_rome_b_ack_n),
        .aer_data_out(OpenNas_Parallel_STE_0_aer_data_out),
        .aer_req(OpenNas_Parallel_STE_0_aer_req),
        .clock(clk_wiz_0_clk_out1),
        .config_addr(okt_top_0_config_addr),
        .config_data(okt_top_0_config_data),
        .config_wren(config_1_Dout),
        .i2s_bclk(i2s_bclk_0_1),
        .i2s_d_in(i2s_d_in_0_1),
        .i2s_lr(i2s_lr_0_1),
        .pdm_dat_left(pdm_dat_left_0_1),
        .pdm_dat_right(pdm_dat_right_0_1),
        .rst_n(Net),
        .source_sel(source_sel_0_1));
  design_1_clk_wiz_0_1 clk_wiz_0
       (.clk_in1(okt_top_0_clock),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_0_clk_out2),
        .resetn(Net));
  design_1_xlslice_0_0 config_0
       (.Din(okt_top_0_config_en),
        .Dout(xlslice_0_Dout));
  design_1_xlslice_0_1 config_1
       (.Din(okt_top_0_config_en),
        .Dout(config_1_Dout));
  design_1_okt_sno_top_0_0 okt_sno_top_0
       (.AER_ACK(okt_top_0_port_c_ack_n),
        .AER_DATA_OUT(okt_sno_top_0_AER_DATA_OUT),
        .AER_REQ(okt_sno_top_0_AER_REQ),
        .clock(clk_wiz_0_clk_out1),
        .rst_n(Net));
  design_1_okt_top_0_2 okt_top_0
       (.clock(okt_top_0_clock),
        .config_addr(okt_top_0_config_addr),
        .config_data(okt_top_0_config_data),
        .config_en(okt_top_0_config_en),
        .leds(okt_top_0_leds),
        .okAA(okAA),
        .okHU(okt_top_0_okHU),
        .okUH(okUH_0_1),
        .okUHU(okUHU[31:0]),
        .out_ack_n(out_ack_n_0_1),
        .out_data(okt_top_0_out_data),
        .out_req_n(okt_top_0_out_req_n),
        .port_a_ack_n(okt_top_0_rome_a_ack_n),
        .port_a_data(OpenNas_Cascade_STER_0_aer_data_out),
        .port_a_req_n(OpenNas_Cascade_STER_0_aer_req),
        .port_b_ack_n(okt_top_0_rome_b_ack_n),
        .port_b_data(OpenNas_Parallel_STE_0_aer_data_out),
        .port_b_req_n(OpenNas_Parallel_STE_0_aer_req),
        .port_c_ack_n(okt_top_0_port_c_ack_n),
        .port_c_data(okt_sno_top_0_AER_DATA_OUT),
        .port_c_req_n(okt_sno_top_0_AER_REQ),
        .rst_ext_n(Net),
        .rst_sw_n(Net));
endmodule
