// -------------------------------------------------------------------------
//  bidirectional SpiNNaker link to AER device interface
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Taken from:
// https://solem.cs.man.ac.uk/svn/spinn_aer2_if/spinn_aer2_if.v
// Revision 2644 (Last-modified date: 2013-10-24 16:18:41 +0100)
//
// -------------------------------------------------------------------------
// COPYRIGHT
//  Copyright (c) The University of Manchester, 2012-2017.
//  SpiNNaker Project
//  Advanced Processor Technologies Group
//  School of Computer Science
// -------------------------------------------------------------------------
// TODO
// -------------------------------------------------------------------------

`include "raggedstone_spinn_aer_if_top.h"
`include "spio_spinnaker_link.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module raggedstone_spinn_aer_if_top
#(
  // debouncer constant (can be adjusted for simulation!)
  parameter DBNCER_CONST = 20'hfffff
)
(
  input wire         ext_nreset,
  input wire         ext_clk,

  // display interface (7-segment and leds)
  input  wire        ext_mode_sel,
  output wire  [7:0] ext_7seg,
  output wire  [3:0] ext_strobe,
  output wire        ext_led2,
  output wire        ext_led3,
  output wire        ext_led4,
  output wire        ext_led5,

  // input SpiNNaker link interface
  input  wire  [6:0] data_2of7_from_spinnaker,
  output wire        ack_to_spinnaker,

  // output SpiNNaker link interface
  output wire  [6:0] data_2of7_to_spinnaker,
  input  wire        ack_from_spinnaker,

  // input AER device interface
  input  wire [15:0] iaer_data,
  input  wire        iaer_req,
  output wire        iaer_ack,

  // output AER device interface
  output wire [15:0] oaer_data,
  output wire        oaer_req,
  input  wire        oaer_ack
);
  //---------------------------------------------------------------
  // reset and clock signals
  // ---------------------------------------------------------
  wire        i_nreset;
  wire        rst_unlocked;
  wire        rst;
  wire        cg_locked;

  wire        clk;
  wire        clk_32;
  wire        clk_64;
  wire        clk_96;

  wire        clk_sync;
  wire        clk_mod;
  wire        clk_deb;

  // internal SpiNNaker interface signals
  // ---------------------------------------------------------
  wire  [6:0] i_ispinn_data;
  wire        i_ispinn_ack;

  wire  [6:0] i_ospinn_data;
  wire        i_ospinn_ack;

  // internal AER interface signals
  // ---------------------------------------------------------
  wire [15:0] i_iaer_data;
  wire        i_iaer_req;
  wire        s_iaer_req;  // synchronized signal 
  wire        i_iaer_ack;

  wire [15:0] i_oaer_data;
  wire        i_oaer_req;
  wire        i_oaer_ack;
  wire        s_oaer_ack;  // synchronized signal 

  // internal packet data and hadshake signals
  // ---------------------------------------------------------
  wire [`PKT_BITS - 1:0] spkt_data;
  wire                   spkt_vld;
  wire                   spkt_rdy;

  wire [`PKT_BITS - 1:0] opkt_data;
  wire                   opkt_vld;
  wire                   opkt_rdy;

  wire [`PKT_BITS - 1:0] cpkt_data;
  wire                   cpkt_vld;
  wire                   cpkt_rdy;

  wire [`PKT_BITS - 1:0] mpkt_data;
  wire                   mpkt_vld;
  wire                   mpkt_rdy;

  wire [`PKT_BITS - 1:0] ipkt_data;
  wire                   ipkt_vld;
  wire                   ipkt_rdy;

  // control signals
  // ---------------------------------------------------------
  wire                    ct_event_go;
  wire [`MODE_BITS - 1:0] vmode;
  wire [`VKEY_BITS - 1:0] vkey;

  // signals for user interface
  // ---------------------------------------------------------
  wire  [`VKS_BITS - 1:0] vksel;
  wire [`MODE_BITS - 1:0] msel;
  wire                    dump_mode;

  wire                    mode_sel;
  wire                    mode_sel_debounced;
  wire              [7:0] o_7seg;
  wire              [3:0] o_strobe;
  wire                    led2;
  wire                    led4;
  wire                    led5;

  wire                    err_flt;
  wire                    err_frm;
  wire                    err_gch;
  //---------------------------------------------------------------




  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------- synchronisers -----------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //---------------------------------------------------------------
  // synchronize the AER_IN asynchronous request line
  // NOTE: AER request is active LOW -- initialize to HIGH
  //---------------------------------------------------------------
  spio_spinnaker_link_sync
  #(
    .SIZE  (1)
  ) sreq
  (
    .CLK_IN (clk_sync),
    .IN     (i_iaer_req),
    .OUT    (s_iaer_req)
   );
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // synchronize the AER_OUT asynchronous ack line
  // NOTE: AER ack is active LOW -- initialize to HIGH
  //---------------------------------------------------------------
  spio_spinnaker_link_sync
  #(
    .SIZE  (1)
  ) sack
  (
    .CLK_IN (clk_sync),
    .IN     (i_oaer_ack),
    .OUT    (s_oaer_ack)
   );
  //---------------------------------------------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------ spinn_receiver -----------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  spio_spinnaker_link_synchronous_receiver sr
  (
    .RESET_IN        (rst),
    .CLK_IN          (clk_mod),
    .FLT_ERR_OUT     (err_flt),
    .FRM_ERR_OUT     (err_frm),
    .GCH_ERR_OUT     (err_gch),
    .SL_DATA_2OF7_IN (i_ispinn_data),
    .SL_ACK_OUT      (i_ispinn_ack),
    .PKT_DATA_OUT    (spkt_data),
    .PKT_VLD_OUT     (spkt_vld),
    .PKT_RDY_IN      (spkt_rdy)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------ packet router ------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  raggedstone_spinn_aer_if_router pr
  (
    .rst       (rst),
    .clk       (clk_mod),
    .spkt_data (spkt_data),
    .spkt_vld  (spkt_vld),
    .spkt_rdy  (spkt_rdy),
    .opkt_data (opkt_data),
    .opkt_vld  (opkt_vld),
    .opkt_rdy  (opkt_rdy),
    .cpkt_data (cpkt_data),
    .cpkt_vld  (cpkt_vld),
    .cpkt_rdy  (cpkt_rdy)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------- out_mapper --------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  spio_spinn2aer_mapper om
  (
    .rst       (rst),
    .clk       (clk_mod),
    .opkt_data (opkt_data),
    .opkt_vld  (opkt_vld),
    .opkt_rdy  (opkt_rdy),
    .oaer_data (i_oaer_data),
    .oaer_req  (i_oaer_req),
    .oaer_ack  (s_oaer_ack)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //-------------------------- controller -------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  raggedstone_spinn_aer_if_control ct
  (
    .rst       (rst),
    .clk       (clk_mod),
    .cpkt_data (cpkt_data),
    .cpkt_vld  (cpkt_vld),
    .cpkt_rdy  (cpkt_rdy),
    .msel      (msel),
    .vksel     (vksel),
    .vmode     (vmode),
    .vkey      (vkey),
    .go        (ct_event_go)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //-------------------------- in_mapper --------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  spio_aer2spinn_mapper im
  (
    .rst       (rst),
    .clk       (clk_mod),
    .vmode     (vmode),
    .vkey      (vkey),
    .iaer_data (i_iaer_data),
    .iaer_req  (s_iaer_req),
    .iaer_ack  (i_iaer_ack),
    .ipkt_data (mpkt_data),
    .ipkt_vld  (mpkt_vld),
    .ipkt_rdy  (mpkt_rdy)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------ AER2SpiNNaker packet dump ------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  raggedstone_spinn_aer_if_dump
  #(
    .DUMP_CNT  (`DUMP_CNT)
  ) pd
  (
    .rst       (rst),
    .clk       (clk_mod),
    .go        (ct_event_go),
    .dump_mode (dump_mode),
    .mpkt_data (mpkt_data),
    .mpkt_vld  (mpkt_vld),
    .mpkt_rdy  (mpkt_rdy),
    .ipkt_data (ipkt_data),
    .ipkt_vld  (ipkt_vld),
    .ipkt_rdy  (ipkt_rdy)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------- spinn_driver ------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  spio_spinnaker_link_synchronous_sender sd
  (
    .RESET_IN         (rst),
    .CLK_IN           (clk_mod),
    .ACK_ERR_OUT      (),
    .TMO_ERR_OUT      (),
    .PKT_DATA_IN      (ipkt_data),
    .PKT_VLD_IN       (ipkt_vld),
    .PKT_RDY_OUT      (ipkt_rdy),
    .SL_DATA_2OF7_OUT (i_ospinn_data),
    .SL_ACK_IN        (i_ospinn_ack)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
  
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------ user_interface -----------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ---------------------------------------------------------
  // debounce mode select pushbutton
  // ---------------------------------------------------------
  raggedstone_spinn_aer_if_debouncer
  #(
    .DBNCER_CONST (DBNCER_CONST),
    .RESET_VALUE  (1'b1)
  ) md
  (
    .rst          (rst),
    .clk          (clk_deb),
    .pb_input     (mode_sel),
    .pb_debounced (mode_sel_debounced)
  );

  raggedstone_spinn_aer_if_user_int ui
  (
    .rst       (rst),
    .clk       (clk_mod),
    .mode_sel  (mode_sel_debounced),
    .dump_mode (dump_mode),
    .error     (err_flt | err_frm | err_gch),
    .msel      (msel),
    .vksel     (vksel),
    .o_7seg    (o_7seg),
    .o_strobe  (o_strobe),
    .o_led_act (led2),
    .o_led_dmp (led4),
    .o_led_err (led5)
  );
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------ clock and reset ----------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //---------------------------------------------------------------
  // debounce reset pushbutton
  //---------------------------------------------------------------
  raggedstone_spinn_aer_if_debouncer
  #(
    .DBNCER_CONST (DBNCER_CONST)
  ) rd
  (
    .rst          (1'b0),  // no reset for the reset signal!
    .clk          (clk_deb),
    .pb_input     (~i_nreset),
    .pb_debounced (rst_unlocked)
  );
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // generate reset signal -- keep it active until clkgen locked!
  //---------------------------------------------------------------
  assign rst = rst_unlocked; /*| !cg_locked;*/
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // clock generation module
  //---------------------------------------------------------------
  /*assign clk_sync = clk_96;
  assign clk_mod  = clk_96;
  assign clk_deb  = clk_32;*/
  
  assign clk_sync = clk;
  assign clk_mod  = clk;
  assign clk_deb  = clk;
/*
  clkgen cg 
  (
    .CLK_OUT1 (clk_32),
    .CLK_OUT2 (clk_96),
    .CLK_OUT3 (clk_64),
    .CLK_IN1  (clk),
    .LOCKED   (cg_locked),
    .RESET    (~i_nreset)
  );*/
  //---------------------------------------------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //-------------------------- I/O buffers ------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //---------------------------------------------------------------
  // control and status signals
  //---------------------------------------------------------------
  //IBUFG ext_clk_buf   (.I (ext_clk),      .O (clk));
  assign clk = ext_clk;
  //IBUF  nreset_buf    (.I (ext_nreset),   .O (i_nreset));
  assign i_nreset = ext_nreset;
  //OBUF  act_led_buf   (.I (led2),         .O (ext_led2));
  assign ext_led2 = led2;
  //OBUF  reset_led_buf (.I (rst),          .O (ext_led3));
  assign ext_led3 = rst;
  //OBUF  dump_mode_buf (.I (led4),         .O (ext_led4));
  assign ext_led4 = led4;
  //OBUF  debug_buf     (.I (led5),         .O (ext_led5));
  assign ext_led5 = led5;
  //IBUF  mode_sel_buf  (.I (ext_mode_sel), .O (mode_sel));
  assign mode_sel = ext_mode_sel;
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // Asynchronous 2-of-7 interface between FPGA and Spinnaker chip
  //---------------------------------------------------------------
  //OBUF dataOutToCore[6:0]  (.I (i_ospinn_data),
    //                        .O (data_2of7_to_spinnaker)
      //                     );
  assign data_2of7_to_spinnaker = i_ospinn_data;
  
  //IBUF ackInFromCore       (.I (ack_from_spinnaker),
    //                        .O (i_ospinn_ack)
      //                     );
  assign i_ospinn_ack = ack_from_spinnaker;

  //IBUF dataInFromCore[6:0] (.I (data_2of7_from_spinnaker),
    //                        .O (i_ispinn_data)
      //                     );
  assign i_ispinn_data = data_2of7_from_spinnaker;
  
  //OBUF ackOutToCore        (.I (i_ispinn_ack),
    //                        .O (ack_to_spinnaker)
      //                     );
  assign ack_to_spinnaker = i_ispinn_ack;
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // Asynchronous interface between AER interfaces and FPGA
  //---------------------------------------------------------------
  //IBUF iaer_req_buf        (.I (iaer_req),    .O (i_iaer_req));
  assign i_iaer_req = iaer_req;
  
  //IBUF iaer_data_buf[15:0] (.I (iaer_data),   .O (i_iaer_data));
  assign i_iaer_data = iaer_data;
  
  //OBUF iaer_ack_buf        (.I (i_iaer_ack),  .O (iaer_ack));
  assign iaer_ack = i_iaer_ack;

  //OBUF oaer_req_buf        (.I (i_oaer_req),  .O (oaer_req));
  assign oaer_req = i_oaer_req;
  
  //OBUF oaer_data_buf[15:0] (.I (i_oaer_data), .O (oaer_data));
  assign oaer_data = i_oaer_data;
  
  //IBUF oaer_ack_buf        (.I (oaer_ack),    .O (i_oaer_ack));
  assign i_oaer_ack = oaer_ack;
  //---------------------------------------------------------------

  // ---------------------------------------------------------
  // Instantiate I/O buffers for 7-segment display
  // ---------------------------------------------------------
  /*OBUF  sevenSeg_buf0 (.I (o_7seg[0]),   .O (ext_7seg[0]));
  OBUF  sevenSeg_buf1 (.I (o_7seg[1]),   .O (ext_7seg[1]));
  OBUF  sevenSeg_buf2 (.I (o_7seg[2]),   .O (ext_7seg[2]));
  OBUF  sevenSeg_buf3 (.I (o_7seg[3]),   .O (ext_7seg[3]));
  OBUF  sevenSeg_buf4 (.I (o_7seg[4]),   .O (ext_7seg[4]));
  OBUF  sevenSeg_buf5 (.I (o_7seg[5]),   .O (ext_7seg[5]));
  OBUF  sevenSeg_buf6 (.I (o_7seg[6]),   .O (ext_7seg[6]));
  OBUF  sevenSeg_buf7 (.I (o_7seg[7]),   .O (ext_7seg[7]));

  OBUF  strobe_buf0   (.I (o_strobe[0]), .O (ext_strobe[0]));
  OBUF  strobe_buf1   (.I (o_strobe[1]), .O (ext_strobe[1]));
  OBUF  strobe_buf2   (.I (o_strobe[2]), .O (ext_strobe[2]));
  OBUF  strobe_buf3   (.I (o_strobe[3]), .O (ext_strobe[3]));*/
  // ---------------------------------------------------------
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
