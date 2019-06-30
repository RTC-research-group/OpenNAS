// -------------------------------------------------------------------------
//  SpiNNaker packet to AER event mapper
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Taken from:
// https://solem.cs.man.ac.uk/svn/spinn_aer2_if/out_mapper.v
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

`include "spio_spinnaker_link.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module spio_spinn2aer_mapper
(
  input wire                    rst,
  input wire                    clk,

  // SpiNNaker packet interface
  input  wire [`PKT_BITS - 1:0] opkt_data,
  input  wire                   opkt_vld,
  output reg                    opkt_rdy,

  // output AER device interface
  output reg             [15:0] oaer_data,
  output reg                    oaer_req,
  input  wire                   oaer_ack
);

  //---------------------------------------------------------------
  // constants
  //---------------------------------------------------------------
  localparam OSTATE_BITS = 2;
  localparam IDLE_OST    = 0;
  localparam HS11_OST    = IDLE_OST + 1;
  localparam HS10_OST    = HS11_OST + 1;


  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  reg [OSTATE_BITS - 1:0] ostate;


  //---------------------------------------------------------------
  // generate opkt_rdy signal
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      opkt_rdy <= 1'b1;
    else
      case (ostate)
        IDLE_OST:
          if (opkt_vld)
            opkt_rdy <= 1'b0;
          else
            opkt_rdy <= 1'b1;      // no change!
	
        HS10_OST:
          if (oaer_ack)            // oaer_ack is active LOW!
            opkt_rdy <= 1'b1;
          else
            opkt_rdy <= 1'b0;      // no change!
	
	default:  
            opkt_rdy <= opkt_rdy;  // no change!
      endcase
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // extract event data from packet and send out
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      oaer_data <= 16'd0;  // not really necessary!
    else
      case (ostate)
        IDLE_OST:
          if (opkt_vld)
            oaer_data <= opkt_data[23:8];
          else
            oaer_data <= oaer_data;      // no change!
	
	default:  
            oaer_data <= oaer_data;      // no change!
      endcase


  always @(posedge clk or posedge rst)
    if (rst)
      oaer_req <= 1'b1;            // oaer_req is active LOW!
    else
      case (ostate)
        IDLE_OST:
          if (opkt_vld)
            oaer_req <= 1'b0;
          else
            oaer_req <= 1'b1;      // no change!
	
        HS11_OST:
          if (!oaer_ack)           // oaer_ack is active LOW!
            oaer_req <= 1'b1;
          else
            oaer_req <= 1'b0;      // no change!
	
	default:  
            oaer_req <= oaer_req;  // no change!
      endcase
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // out_mapper state machine
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      ostate <= IDLE_OST;
    else
      case (ostate)
        IDLE_OST:
          if (opkt_vld)
            ostate <= HS11_OST;
          else
            ostate <= IDLE_OST;  // no change!

	HS11_OST:
          if (!oaer_ack)  // oaer_ack is active LOW!
            ostate <= HS10_OST;
	  else
            ostate <= HS11_OST;  // no change!

	HS10_OST:
          if (oaer_ack)
            ostate <= IDLE_OST;
	  else
            ostate <= HS10_OST;  // no change!

	default:  
            ostate <= ostate;    // no change!
      endcase
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
