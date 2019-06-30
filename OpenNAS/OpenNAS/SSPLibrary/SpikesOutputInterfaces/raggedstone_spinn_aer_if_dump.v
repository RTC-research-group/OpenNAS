// -------------------------------------------------------------------------
//  SpiNNaker <-> AER interface controller
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Adapted from:
// https://solem.cs.man.ac.uk/svn/spinn_aer2_if/in_mapper.v
// Revision 2615 (Last-modified date: 2013-10-02 11:39:58 +0100)
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

`include "spio_spinnaker_link.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module raggedstone_spinn_aer_if_dump
#(
  // dump incoming events if SpiNNaker is busy
  // for DUMP_CNT consecutive clock cycles
  //parameter DUMP_CNT = 128
  parameter DUMP_CNT = 31
)
(
  input  wire                   rst,
  input  wire                   clk,

  // control and status interface
  input  wire                   go,
  output wire                   dump_mode,

  // AER bus interface
  input  wire [`PKT_BITS - 1:0] mpkt_data,
  input  wire                   mpkt_vld,
  output wire                   mpkt_rdy,

  // SpiNNaker packet interface
  output wire [`PKT_BITS - 1:0] ipkt_data,
  output wire                   ipkt_vld,
  input  wire                   ipkt_rdy
);

  //---------------------------------------------------------------
  // constants
  //---------------------------------------------------------------
  localparam STATE_BITS = 1;
  localparam IDLE_ST    = 0;
  localparam DUMP_ST    = IDLE_ST + 1;


  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  reg [STATE_BITS - 1:0] state;

  wire                   busy;  // output not ready for next packet
  reg             [15:0] busy_ctr;


  //---------------------------------------------------------------
  // use switch to drop event packets
  //---------------------------------------------------------------
  spio_switch
  #(
    .PKT_BITS(`PKT_BITS),
    .NUM_PORTS(1)
  ) sw
  (
    .RESET_IN             (rst),
    .CLK_IN               (clk),
    .IN_DATA_IN           (mpkt_data),
    .IN_VLD_IN            (mpkt_vld),
    .IN_RDY_OUT           (mpkt_rdy),
    .IN_OUTPUT_SELECT_IN  (go),
    .OUT_DATA_OUT         (ipkt_data),
    .OUT_VLD_OUT          (ipkt_vld),
    .OUT_RDY_IN           (ipkt_rdy),
    .BLOCKED_OUTPUTS_OUT  (),
    .SELECTED_OUTPUTS_OUT (),
    .DROP_IN              (dump_mode),
    .DROPPED_DATA_OUT     (),
    .DROPPED_OUTPUTS_OUT  (),
    .DROPPED_VLD_OUT      ()
  );
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // dump packets if SpiNNaker busy for DUMP_CNT consecutive cycles
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      busy_ctr <= DUMP_CNT;
    else
      if (!busy)
        busy_ctr <= DUMP_CNT;  // SpiNNaker not busy resets counter
      else if (busy_ctr != 0)
        busy_ctr <= busy_ctr - 1;
  //---------------------------------------------------------------
 

  //---------------------------------------------------------------
  // report when dumping packets
  //---------------------------------------------------------------
  assign dump_mode = (state == DUMP_ST);
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // check if SpiNNaker is responding
  //---------------------------------------------------------------
  assign busy = ipkt_vld && !ipkt_rdy;
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // dump state machine
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      state <= IDLE_ST;
    else
      case (state)
        IDLE_ST:
          if (busy_ctr == 0)
            state <= DUMP_ST;

	DUMP_ST:
          if (!busy)
	    state <= IDLE_ST;
      endcase
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
