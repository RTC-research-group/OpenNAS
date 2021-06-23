//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
//Date        : Wed Jun 23 10:11:51 2021
//Host        : arios-xps running 64-bit Ubuntu 18.04.5 LTS
//Command     : generate_target nas_system_wrapper.bd
//Design      : nas_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module nas_system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    aer_ack,
    aer_data_out,
    aer_req,
    i2s_bclk,
    i2s_d_in,
    i2s_lr,
    pdm_clk_left,
    pdm_clk_right,
    pdm_dat_left,
    pdm_dat_right,
    rst_ext_n,
    source_sel);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input aer_ack;
  output [15:0]aer_data_out;
  output aer_req;
  input i2s_bclk;
  input i2s_d_in;
  input i2s_lr;
  output pdm_clk_left;
  output pdm_clk_right;
  input pdm_dat_left;
  input pdm_dat_right;
  input rst_ext_n;
  input source_sel;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire aer_ack;
  wire [15:0]aer_data_out;
  wire aer_req;
  wire i2s_bclk;
  wire i2s_d_in;
  wire i2s_lr;
  wire pdm_clk_left;
  wire pdm_clk_right;
  wire pdm_dat_left;
  wire pdm_dat_right;
  wire rst_ext_n;
  wire source_sel;

  nas_system nas_system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .aer_ack(aer_ack),
        .aer_data_out(aer_data_out),
        .aer_req(aer_req),
        .i2s_bclk(i2s_bclk),
        .i2s_d_in(i2s_d_in),
        .i2s_lr(i2s_lr),
        .pdm_clk_left(pdm_clk_left),
        .pdm_clk_right(pdm_clk_right),
        .pdm_dat_left(pdm_dat_left),
        .pdm_dat_right(pdm_dat_right),
        .rst_ext_n(rst_ext_n),
        .source_sel(source_sel));
endmodule
