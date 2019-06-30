// -------------------------------------------------------------------------
//  AER event to SpiNNaker packet mapper
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Taken from:
// https://solem.cs.man.ac.uk/svn/spinn_aer2_if/in_mapper.v
// Revision 2615 (Last-modified date: 2013-10-02 11:39:58 +0100)
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
module spio_aer2spinn_mapper
(
  input  wire                    rst,
  input  wire                    clk,

  // control interface
  input  wire [`MODE_BITS - 1:0] vmode,
  input  wire [`VKEY_BITS - 1:0] vkey,

  // input AER device interface
  input  wire             [15:0] iaer_data,
  input  wire                    iaer_req,
  output reg                     iaer_ack,

  // SpiNNaker packet interface
  output reg   [`PKT_BITS - 1:0] ipkt_data,
  output reg                     ipkt_vld,
  input  wire                    ipkt_rdy
);

  //---------------------------------------------------------------
  // constants
  //---------------------------------------------------------------
  localparam STATE_BITS = 1;
  localparam IDLE_ST    = 0;
  localparam WTRQ_ST    = IDLE_ST + 1;


  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  reg [STATE_BITS - 1:0] state;

  reg             [15:0] aer_coords;
  wire             [6:0] retina_x, retina_y;
  wire                   plrty_bit;

  reg                    busy;  // output not ready for next packet


  //---------------------------------------------------------------
  // generate aer ack signal
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      iaer_ack <= 1'b1;  // active LOW!
    else
      case (state)
        IDLE_ST:
          if (!iaer_req && !busy)
            iaer_ack <= 1'b0;

	WTRQ_ST:
          if (iaer_req)
            iaer_ack <= 1'b1;
      endcase
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // mode selection 
  //---------------------------------------------------------------
  always @(*)
    case (vmode)
      // retina 64x64 mode
      `RET_64:  aer_coords = {iaer_data[15], plrty_bit, 2'b00,
                               retina_y[6:1], retina_x[6:1]
                             };

      // retina 32x32 mode
      `RET_32:  aer_coords = {iaer_data[15], plrty_bit, 4'b0000,
                               retina_y[6:2], retina_x[6:2]
                             };

      // retina 16x16 mode
      `RET_16:  aer_coords = {iaer_data[15], plrty_bit, 6'b000000,
                               retina_y[6:3], retina_x[6:3]
                             };

      // cochlea mode
      /*`COCHLEA: aer_coords = {iaer_data[15], 3'b000, iaer_data[1], 3'b000,
                               iaer_data[7:2],iaer_data[9:8]
                             };*/
      `COCHLEA: aer_coords = iaer_data[15:0];

      // straight-through mode
      `DIRECT:  aer_coords = iaer_data[15:0];

      // make the retina 128x128 mode the default
      default:  aer_coords = {iaer_data[15], plrty_bit, retina_y, retina_x};
    endcase
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // retina mapper
  //---------------------------------------------------------------
  assign retina_x  = iaer_data[14:8];
  assign retina_y  = iaer_data[7:1];
  assign plrty_bit = iaer_data[0];  // polarity
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // packet interface
  //---------------------------------------------------------------
  wire [38:0]  pkt_bits;
  wire         parity;
   
  assign pkt_bits = {vkey, aer_coords, 7'd0};
  assign parity   = ~(^pkt_bits);

  always @(posedge clk)
    case (state)
      IDLE_ST:
        if (!iaer_req && !busy)
          ipkt_data <= {32'd0, pkt_bits, parity};  // no payload!
    endcase

  always @(posedge clk or posedge rst)
    if (rst)
      ipkt_vld <= 1'b0;
    else
      case (state)
    	IDLE_ST:
          if (!iaer_req || busy)
            ipkt_vld <= 1'b1;
          else
            ipkt_vld <= 1'b0;

    	WTRQ_ST:
          if (busy)
            ipkt_vld <= 1'b1;
          else
            ipkt_vld <= 1'b0;
      endcase 
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // busy (output packet interface not ready to accept new one)
  //---------------------------------------------------------------
  always @(*)
    busy = ipkt_vld && !ipkt_rdy;
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // in_mapper state machine
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      state <= IDLE_ST;
    else
      case (state)
        IDLE_ST:
          if (!iaer_req && !busy)
            state <= WTRQ_ST;

	WTRQ_ST:
          if (iaer_req)
            state <= IDLE_ST;
      endcase
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
