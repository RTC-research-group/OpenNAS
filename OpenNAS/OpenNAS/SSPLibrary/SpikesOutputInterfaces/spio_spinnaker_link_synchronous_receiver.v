// -------------------------------------------------------------------------
//  spiNNaker link fully-synchronous receiver module
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Taken from:
// https://solem.cs.man.ac.uk/svn/spiNNlink/testing/src/packet_receiver.v
// Revision 2517 (Last-modified date: Date: 2013-08-19 10:33:30 +0100)
//
// -------------------------------------------------------------------------
// COPYRIGHT
//  Copyright (c) The University of Manchester, 2012-2016.
//  SpiNNaker Project
//  Advanced Processor Technologies Group
//  School of Computer Science
// -------------------------------------------------------------------------
// TODO
// -------------------------------------------------------------------------


// ----------------------------------------------------------------
// include spiNNlink global constants and parameters
//
`include "spio_spinnaker_link.h"
// ----------------------------------------------------------------


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module spio_spinnaker_link_synchronous_receiver
(
  input                         CLK_IN,
  input                         RESET_IN,

  // link error reporting
  output wire                   FLT_ERR_OUT,
  output wire                   FRM_ERR_OUT,
  output wire                   GCH_ERR_OUT,

  // SpiNNaker link interface
  input                   [6:0] SL_DATA_2OF7_IN,
  output wire                   SL_ACK_OUT,

  // spiNNlink interface
  output wire [`PKT_BITS - 1:0] PKT_DATA_OUT,
  output wire                   PKT_VLD_OUT,
  input                         PKT_RDY_IN
);

  //-------------------------------------------------------------
  // internal signals
  //-------------------------------------------------------------
  wire [6:0] synced_sl_data_2of7;  // synchronized 2of7-encoded data input

  // these signals do not use rdy/vld handshake!
  // cts must be 1 before starting to send flits
  // dat/bad/eop are a 1-hot indication of a new flit
  wire [6:0] flt_data_bad;  // bad data flit
  wire [3:0] flt_data_bin;  // binary data
  wire       flt_dat;       // flit is correct data
  wire       flt_bad;       // flit contains incorrect data
  wire       flt_eop;       // flit contains and end-of-packet
  wire       flt_cts;       // flit interface is clear-to-send


  spio_spinnaker_link_sync #(.SIZE(7)) sync
  ( .CLK_IN (CLK_IN),
    .IN     (SL_DATA_2OF7_IN),
    .OUT    (synced_sl_data_2of7)
  );
		
  flit_input_if fi
  (
    .CLK_IN          (CLK_IN),
    .RESET_IN        (RESET_IN),
    .GCH_ERR_OUT     (GCH_ERR_OUT),
    .SL_DATA_2OF7_IN (synced_sl_data_2of7),
    .SL_ACK_OUT      (SL_ACK_OUT),
    .flt_data_bad    (flt_data_bad),
    .flt_data_bin    (flt_data_bin),
    .flt_dat         (flt_dat),
    .flt_bad         (flt_bad),
    .flt_eop         (flt_eop),
    .flt_cts         (flt_cts)
  );

  pkt_deserializer pd
  (
    .CLK_IN          (CLK_IN),
    .RESET_IN        (RESET_IN),
    .FLT_ERR_OUT     (FLT_ERR_OUT),
    .FRM_ERR_OUT     (FRM_ERR_OUT),
    .flt_data_bad    (flt_data_bad),
    .flt_data_bin    (flt_data_bin),
    .flt_dat         (flt_dat),
    .flt_bad         (flt_bad),
    .flt_eop         (flt_eop),
    .flt_cts         (flt_cts),
    .PKT_DATA_OUT    (PKT_DATA_OUT),
    .PKT_VLD_OUT     (PKT_VLD_OUT),
    .PKT_RDY_IN      (PKT_RDY_IN)
  );
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module flit_input_if
(
  input                         CLK_IN,
  input                         RESET_IN,

  // link error reporting
  output reg                    GCH_ERR_OUT,

  // SpiNNaker link interface
  input                   [6:0] SL_DATA_2OF7_IN,
  output reg                    SL_ACK_OUT,

  // packet deserializer interface
  output reg              [6:0] flt_data_bad,
  output reg              [3:0] flt_data_bin,
  output reg                    flt_dat,
  output reg                    flt_bad,
  output reg                    flt_eop,
  input                         flt_cts
);

  //-------------------------------------------------------------
  // constants
  //-------------------------------------------------------------
  localparam STATE_BITS = 2;
  localparam STRT_ST    = 0;   // need to send an ack on reset exit!
  localparam IDLE_ST    = STRT_ST + 1;
  localparam RECV_ST    = IDLE_ST + 1;
  localparam EOPW_ST    = RECV_ST + 1;


  //-------------------------------------------------------------
  // internal signals
  //-------------------------------------------------------------
  reg send_ack;  // send ack to SpiNNaker (toggle SL_ACK_OUT)

  reg dat_flit;  // correct data flit arrived
  reg err_flit;  // incorrect data flit arrived (could be a glitch)
  reg eop_flit;  // end-of-packet flit arrived

  reg new_flit;  // new flit arrived
  reg bad_flit;  // incorrect data flit (not a glitch)
  reg err_seen;  // incorrect data also in last clock cycle

  reg [3:0] new_data;  // decoded received data
 
  reg [6:0] old_data_2of7;  // remember previous nrz 2of7 data

  reg [6:0] rtz_data;  // data translated from nrz to rtz

  reg [STATE_BITS - 1:0] state;  // current state


  //-------------------------------------------------------------
  // 2-of-7 data detector
  //-------------------------------------------------------------
  function data_2of7 ;
    input [6:0] data;

    case (data)
      7'b0010001: data_2of7 = 1;  // 0
      7'b0010010: data_2of7 = 1;  // 1
      7'b0010100: data_2of7 = 1;  // 2
      7'b0011000: data_2of7 = 1;  // 3
      7'b0100001: data_2of7 = 1;  // 4
      7'b0100010: data_2of7 = 1;  // 5
      7'b0100100: data_2of7 = 1;  // 6
      7'b0101000: data_2of7 = 1;  // 7
      7'b1000001: data_2of7 = 1;  // 8
      7'b1000010: data_2of7 = 1;  // 9
      7'b1000100: data_2of7 = 1;  // 10
      7'b1001000: data_2of7 = 1;  // 11
      7'b0000011: data_2of7 = 1;  // 12
      7'b0000110: data_2of7 = 1;  // 13
      7'b0001100: data_2of7 = 1;  // 14
      7'b0001001: data_2of7 = 1;  // 15
      default:    data_2of7 = 0;  // anything else is not correct data
    endcase
  endfunction


  //-------------------------------------------------------------
  // 2-of-7 end-of-packet detector
  //-------------------------------------------------------------
  function eop_2of7 ;
    input [6:0] data;

    case (data)
      7'b1100000: eop_2of7 = 1;
      default:    eop_2of7 = 0;  // anything else is not an end-of-packet
    endcase
  endfunction


  //-------------------------------------------------------------
  // 2-of-7 error detector
  //-------------------------------------------------------------
  function error_2of7 ;
    input [6:0] data;

    case (data)
      7'b0010001: error_2of7 = 0;  // 0
      7'b0010010: error_2of7 = 0;  // 1
      7'b0010100: error_2of7 = 0;  // 2
      7'b0011000: error_2of7 = 0;  // 3
      7'b0100001: error_2of7 = 0;  // 4
      7'b0100010: error_2of7 = 0;  // 5
      7'b0100100: error_2of7 = 0;  // 6
      7'b0101000: error_2of7 = 0;  // 7
      7'b1000001: error_2of7 = 0;  // 8
      7'b1000010: error_2of7 = 0;  // 9
      7'b1000100: error_2of7 = 0;  // 10
      7'b1001000: error_2of7 = 0;  // 11
      7'b0000011: error_2of7 = 0;  // 12
      7'b0000110: error_2of7 = 0;  // 13
      7'b0001100: error_2of7 = 0;  // 14
      7'b0001001: error_2of7 = 0;  // 15
      7'b1100000: error_2of7 = 0;  // eop
      0, 1, 2, 4,
      8, 16, 32,
      64:         error_2of7 = 0;  // incomplete (single-bit change)
      default:    error_2of7 = 1;  // anything else is an error
    endcase
  endfunction


  //-------------------------------------------------------------
  // 2-of-7 decoder
  //-------------------------------------------------------------
  function [3:0] decode_2of7 ;
    input [6:0] data;

    case (data)
      7'b0010001: decode_2of7 = 0;    // 0
      7'b0010010: decode_2of7 = 1;    // 1
      7'b0010100: decode_2of7 = 2;    // 2
      7'b0011000: decode_2of7 = 3;    // 3
      7'b0100001: decode_2of7 = 4;    // 4
      7'b0100010: decode_2of7 = 5;    // 5
      7'b0100100: decode_2of7 = 6;    // 6
      7'b0101000: decode_2of7 = 7;    // 7
      7'b1000001: decode_2of7 = 8;    // 8
      7'b1000010: decode_2of7 = 9;    // 9
      7'b1000100: decode_2of7 = 10;   // 10
      7'b1001000: decode_2of7 = 11;   // 11
      7'b0000011: decode_2of7 = 12;   // 12
      7'b0000110: decode_2of7 = 13;   // 13
      7'b0001100: decode_2of7 = 14;   // 14
      7'b0001001: decode_2of7 = 15;   // 15
      default:    decode_2of7 = 4'hx; // eop, incomplete, bad
    endcase
  endfunction


  //---------------------------------------------------------------
  // translate data from nrz to rtz
  //---------------------------------------------------------------
  always @(*)
    rtz_data = SL_DATA_2OF7_IN ^ old_data_2of7;


  //---------------------------------------------------------------
  // is the new nrz flit correct data?
  //---------------------------------------------------------------
  always @(*)
    dat_flit = data_2of7 (rtz_data);


  //-------------------------------------------------------------
  // is the new nrz flit an end-of-packet?
  //-------------------------------------------------------------
  always @(*)
    eop_flit = eop_2of7 (rtz_data);


  //---------------------------------------------------------------
  // is the new nrz flit an error? (could be a glitch)
  //---------------------------------------------------------------
  always @(*)
    err_flit = error_2of7 (rtz_data);


  //---------------------------------------------------------------
  // // incorrect data flit (not a glitch)
  //---------------------------------------------------------------
  always @(*)
    bad_flit = err_flit && err_seen;


  //-------------------------------------------------------------
  // detect the arrival of a new nrz flit
  //-------------------------------------------------------------
  always @(*)
    new_flit = dat_flit || eop_flit || bad_flit;


  //---------------------------------------------------------------
  // decode new data flit
  //---------------------------------------------------------------
  always @(*)
    new_data = decode_2of7 (rtz_data);


  //-------------------------------------------------------------
  // SpiNNaker link interface: generate SL_ACK_OUT
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      SL_ACK_OUT <= 1'b0;
    else
      if (send_ack)
        SL_ACK_OUT <= ~SL_ACK_OUT;


  //-------------------------------------------------------------
  // send next value of SL_ACK_OUT (toggle SL_ACK_OUT)
  //-------------------------------------------------------------
  always @(*)
    case (state)
      STRT_ST:   send_ack = 1'b1;  // mimic SpiNNaker: ack on reset exit

      IDLE_ST,
      RECV_ST: if (new_flit && flt_cts)
                 send_ack = 1'b1;  //  ack new flit when ready
               else
                 send_ack = 1'b0;  //  no ack!

      EOPW_ST:   send_ack = 1'b0;  //  no ack!
    endcase 


  //-------------------------------------------------------------
  // remember nrz 2of7 data to generate next rtz value
  //-------------------------------------------------------------
  always @(posedge CLK_IN)
    case (state)
      STRT_ST:
          old_data_2of7 <= SL_DATA_2OF7_IN;  // remember initial data

      IDLE_ST,
      RECV_ST:
        if (new_flit && flt_cts)
          old_data_2of7 <= SL_DATA_2OF7_IN;  // remember incoming data
    endcase 


  //-------------------------------------------------------------
  // packet deserializer interface: generate flt_data_bad
  //-------------------------------------------------------------
  always @(posedge CLK_IN)
    flt_data_bad <= rtz_data;  // send rtz incoming data


  //-------------------------------------------------------------
  // packet deserializer interface: generate flt_data_bin
  //-------------------------------------------------------------
  always @(posedge CLK_IN)
    case (state)
      IDLE_ST,
      RECV_ST:  if (dat_flit && flt_cts)
                  flt_data_bin <= new_data;  // send decoded incoming data
    endcase 


  //-------------------------------------------------------------
  // packet deserializer interface: generate flt_dat
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      flt_dat <= 1'b0;  // no flits during reset
    else
      case (state)
        IDLE_ST,
        RECV_ST:  if (dat_flit && flt_cts)
                    flt_dat <= 1'b1;
                  else
                    flt_dat <= 1'b0;

        default:    flt_dat <= 1'b0;
      endcase 


  //-------------------------------------------------------------
  // packet deserializer interface: generate flt_bad
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      flt_bad <= 1'b0;  // no flits during reset
    else
      case (state)
        IDLE_ST,
        RECV_ST:  if (bad_flit && flt_cts)
                    flt_bad <= 1'b1;
                  else
                    flt_bad <= 1'b0;

        default:    flt_bad <= 1'b0;
      endcase 


  //-------------------------------------------------------------
  // packet deserializer interface: generate flt_eop
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      flt_eop <= 1'b0;  // no flits during reset
    else
      case (state)
        IDLE_ST,
        RECV_ST:  if (eop_flit && flt_cts)
                    flt_eop <= 1'b1;
                  else
                    flt_eop <= 1'b0;

        default:    flt_eop <= 1'b0;
      endcase 


  //-------------------------------------------------------------
  // deal with short (1 clock cycle) glitches
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      err_seen <= 1'b0;  // ignore glitches during reset
    else
      if (err_flit && !err_seen)
        err_seen <= 1'b1;
      else
        err_seen <= 1'b0;


  //---------------------------------------------------------------
  // error reporting (2 clock cycles -- counter runs on slower clock)
  //---------------------------------------------------------------
  reg gch_err_ext;  // extend error indication by 1 clock cycle
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      gch_err_ext <= 1'b0;
    else
      gch_err_ext <= GCH_ERR_OUT;

  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      GCH_ERR_OUT <= 1'b0;
    else
      if (err_seen)
        GCH_ERR_OUT <= 1'b1;
      else if (gch_err_ext)
        GCH_ERR_OUT <= 1'b0;
  //---------------------------------------------------------------


  //-------------------------------------------------------------
  // state machine
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      state <= STRT_ST;  // need to send an ack on reset exit!
    else
      case (state)
        IDLE_ST:
          casex ({flt_cts, dat_flit, eop_flit, bad_flit})
            4'b11xx,
            4'b1xx1: state <= RECV_ST;

            4'b1x1x: state <= EOPW_ST;
          endcase

        RECV_ST: if (eop_flit)
                   state <= EOPW_ST;

        default:   state <= IDLE_ST;
      endcase 
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module pkt_deserializer
(
  input                         CLK_IN,
  input                         RESET_IN,

  // link error reporting
  output reg                    FLT_ERR_OUT,
  output reg                    FRM_ERR_OUT,

  // flit interface
  input                   [6:0] flt_data_bad,
  input                   [3:0] flt_data_bin,
  input                         flt_dat,
  input                         flt_bad,
  input                         flt_eop,
  output reg                    flt_cts,

  // spiNNlink interface
  output reg  [`PKT_BITS - 1:0] PKT_DATA_OUT,
  output reg                    PKT_VLD_OUT,
  input                         PKT_RDY_IN
);

  //---------------------------------------------------------------
  // constants
  //---------------------------------------------------------------
  //# Xilinx recommends one-hot state encoding
  localparam STATE_BITS = 2;
  localparam IDLE_ST    = 0;
  localparam TRAN_ST    = IDLE_ST + 1;
  localparam WAIT_ST    = TRAN_ST + 1;

  localparam SPKT_FLTS = 10;
  localparam LPKT_FLTS = 18;


  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  reg       exp_eop;   // is the new flit expected to be an eop?

  reg [5:0] flit_cnt;  // keep track of number of received flits

  reg       long_pkt;  // remember length of packet

  reg                     send_bad_pkt;  // send bad pkt out
  reg   [`PKT_BITS - 1:0] bad_pkt;       // bad pkt
  reg                     bad_pkt_pty;   // bad pkt parity
  reg               [6:0] bad_flt_dat;   // bad flit data
  reg               [5:0] bad_flt_cnt;   // bad flit count
  reg               [7:0] bad_flt_cyc;   // bad flit cycle

  reg               [6:0] dbg_flt_dat;   // pre flit data
  reg               [5:0] dbg_flt_cnt;   // pre flit count
  reg               [7:0] dbg_flt_cyc;   // pre flit cycle

  reg               [7:0] cycle_cnt;     // packet cycle count

  reg   [`PKT_BITS - 1:0] pkt_buf;   // buffer used to assemble pkt

  reg                     pkt_busy;  // pkt interface busy

  reg                     send_pkt;  // try to send pkt

  reg                     pkt_out;   // pkt is going out this cycle

  reg  [STATE_BITS - 1:0] state;     // current state


  //-------------------------------------------------------------
  // flit interface: generate flt_cts
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      flt_cts <= 1'b0;
    else
      case (state)
        IDLE_ST,
	TRAN_ST: if (flt_eop && pkt_busy)
                   flt_cts <= 1'b0;  // wait for pkt interface
                 else
                   flt_cts <= 1'b1;

	WAIT_ST: if (!pkt_busy)
                   flt_cts <= 1'b1;  // pkt interface ready again

        default:   flt_cts <= 1'b1;
      endcase 


  //-------------------------------------------------------------
  // remember length of packet
  //-------------------------------------------------------------
  always @(posedge CLK_IN)
    if ((state == IDLE_ST) && flt_dat)
      long_pkt <= flt_data_bin[1];


  //---------------------------------------------------------------
  // is the new data expected to be an eop?
  //---------------------------------------------------------------
  always @ (*)
    exp_eop = (!long_pkt && (flit_cnt == SPKT_FLTS))
                || (flit_cnt == LPKT_FLTS);


  //-------------------------------------------------------------
  // keep track of how many flits have been received
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      flit_cnt <= 0;  // prepare for first packet
    else
      if (flt_dat || flt_bad)
        flit_cnt <= flit_cnt + 1;  // count new flit
      else if (pkt_out)
        flit_cnt <= 0;             // prepare for next packet


  //-------------------------------------------------------------
  // packet interface: generate PKT_DATA_OUT
  //-------------------------------------------------------------
  always @(posedge CLK_IN)
    if (pkt_out)
      if (!exp_eop  || send_bad_pkt)
        PKT_DATA_OUT <= bad_pkt;
      else if (long_pkt)
        PKT_DATA_OUT <= pkt_buf;
      else
        PKT_DATA_OUT <= pkt_buf >> 32;  // no payload: complete buffer shift!


  //-------------------------------------------------------------
  // packet interface: generate PKT_VLD_OUT
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      PKT_VLD_OUT <= 1'b0;
    else
      if (!pkt_busy)
        if (send_pkt)
          PKT_VLD_OUT <= 1'b1;
        else
          PKT_VLD_OUT <= 1'b0;


  //-------------------------------------------------------------
  // packet interface busy
  //-------------------------------------------------------------
  always @(*)
    pkt_busy = PKT_VLD_OUT && !PKT_RDY_IN;


  //-------------------------------------------------------------
  // shift in new data to assemble packet
  //-------------------------------------------------------------
  always @(posedge CLK_IN)
    if (flt_dat && flt_cts)
      pkt_buf <= {flt_data_bin, pkt_buf[`PKT_BITS - 1:4]};


  //-------------------------------------------------------------
  // time to send packet
  //-------------------------------------------------------------
  always @(*)
    case (state)
      IDLE_ST,
      TRAN_ST: if (flt_eop)
                 send_pkt = 1;  // try to send newly assembled pkt
               else
                 send_pkt = 0;  // no pkt ready to send

      WAIT_ST:   send_pkt = 1;  // waiting and trying to send pkt

      default:   send_pkt = 0;  // no pkt ready to send
    endcase 


  //---------------------------------------------------------------
  // a new packet is sent out in this cycle
  //---------------------------------------------------------------
  always @(*)
    pkt_out = send_pkt && !pkt_busy;


  //---------------------------------------------------------------
  // keep track of the number of clock cycles for this packet
  //---------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      cycle_cnt <= 0;
    else
      if (pkt_out)
        cycle_cnt <= 0;                // restart cycle count for next packet
      else                             // don't count idle or wait cycles!
        if (state == IDLE_ST)
          cycle_cnt <= 1;              // 1st cycle in outgoing packet
        else if (state != WAIT_ST)
          cycle_cnt <= cycle_cnt + 1;  // count cycle in outgoing packet


  //-------------------------------------------------------------
  // send debug packet with bad parity if an error occured
  //-------------------------------------------------------------
  wire pre_cycle = (!send_bad_pkt && (flt_dat || flt_eop));
  wire pos_cycle = (send_bad_pkt && (cycle_cnt == (bad_flt_cyc + 1)));
//!  wire dbg_cycle = pre_cycle;
  wire dbg_cycle = pos_cycle;
   

  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      send_bad_pkt <= 1'b0;
    else
      if (flt_bad)
        send_bad_pkt <= 1'b1;
      else if (pkt_out)
        send_bad_pkt <= 1'b0;  // clear state for new packet
        
  always @(posedge CLK_IN)
    if (flt_bad && !send_bad_pkt)
      bad_flt_dat <= flt_data_bad;
    else if (pkt_out)
      bad_flt_dat <= 0;  // clear state for new packet
        
  always @(posedge CLK_IN)
    if (flt_bad && !send_bad_pkt)
      bad_flt_cnt <= flit_cnt;
    else if (pkt_out)
      bad_flt_cnt <= 0;  // clear state for new packet
        
  always @(posedge CLK_IN)
    if (flt_bad && !send_bad_pkt)
      bad_flt_cyc <= cycle_cnt;
    else if (pkt_out)
      bad_flt_cyc <= 8'hcc;  // clear state for new packet
        
  always @(posedge CLK_IN)
    if (dbg_cycle)
      dbg_flt_dat <= flt_data_bad;
    else if (pkt_out)
      dbg_flt_dat <= 0;  // clear state for new packet
        
  always @(posedge CLK_IN)
    if (dbg_cycle)
      dbg_flt_cnt <= flit_cnt;
    else if (pkt_out)
      dbg_flt_cnt <= 0;  // clear state for new packet
        
  always @(posedge CLK_IN)
    if (dbg_cycle)
      dbg_flt_cyc <= cycle_cnt;
    else if (pkt_out)
      dbg_flt_cyc <= 8'hcc;  // clear state for new packet
        
  always @(*)
    bad_pkt_pty = ^(dbg_flt_cyc ^ dbg_flt_dat ^ dbg_flt_cnt
                     ^ bad_flt_cyc ^ exp_eop ^ send_bad_pkt
                     ^ flit_cnt ^ bad_flt_dat ^ bad_flt_cnt
                   );

  always @(*)
    bad_pkt = {bad_flt_cyc, dbg_flt_cyc,
                1'b0, dbg_flt_dat, 2'b00, dbg_flt_cnt,
                4'hb, 2'b00, exp_eop, send_bad_pkt,
                2'b00, flit_cnt,
                1'b0, bad_flt_dat,
                2'b00, bad_flt_cnt,
	        7'b0000001, bad_pkt_pty
              };  // packet with wrong parity!


  //---------------------------------------------------------------
  // error reporting
  //---------------------------------------------------------------
  reg flt_err_ext;
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      flt_err_ext <= 1'b0;
    else
      flt_err_ext <= FLT_ERR_OUT;

  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      FLT_ERR_OUT <= 1'b0;
    else
      if (flt_bad && !send_bad_pkt)
        FLT_ERR_OUT <= 1'b1;
      else if (flt_err_ext)
        FLT_ERR_OUT <= 1'b0;

  reg frm_err_ext;
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      frm_err_ext <= 1'b0;
    else
      frm_err_ext <= FRM_ERR_OUT;

  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      FRM_ERR_OUT <= 1'b0;
    else
      if (flt_eop && !exp_eop)
        FRM_ERR_OUT <= 1'b1;
      else if (frm_err_ext)
        FRM_ERR_OUT <= 1'b0;
  //---------------------------------------------------------------


  //-------------------------------------------------------------
  // state machine
  //-------------------------------------------------------------
  always @(posedge CLK_IN or posedge RESET_IN)
    if (RESET_IN)
      state <= IDLE_ST;
    else
      case (state)
        IDLE_ST: casex ({flt_dat, flt_bad, flt_eop, pkt_busy})
                   4'b1xxx,                    // first flit in new packet
                   4'bx1xx: state <= TRAN_ST;  // first flit in new packet
                   4'bxx11: state <= WAIT_ST;  // wait for pkt if to be free
                   default: state <= IDLE_ST;  // stay idle
                 endcase

        TRAN_ST: casex ({flt_eop, pkt_busy})
	           2'b10:  // eop flit and not busy: send and go idle 
                     state <= IDLE_ST;

		   2'b11:  // eop flit but busy: wait
                     state <= WAIT_ST;

                   default:   // data, bad or no flit: stay in transfer state
                     state <= TRAN_ST;
                 endcase

        WAIT_ST: if (!pkt_busy)
                   state <= IDLE_ST;  // wait for pkt interface free
      endcase
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
