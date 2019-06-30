// -------------------------------------------------------------------------
//  SpiNNaker <-> AER interface control module
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
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
module raggedstone_spinn_aer_if_control
(
  input  wire                   rst,
  input  wire                   clk,

  // packet interface
  input  wire [`PKT_BITS - 1:0] cpkt_data,
  input  wire                   cpkt_vld,
  output reg                    cpkt_rdy,

  // control interface
  input  wire [`MODE_BITS - 1:0] msel,
  input  wire  [`VKS_BITS - 1:0] vksel,
  output reg  [`MODE_BITS - 1:0] vmode,
  output reg  [`VKEY_BITS - 1:0] vkey,
  output reg                    go
);
  //---------------------------------------------------------------
  // packet interface 
  // generate cpkt_rdy signal
  //---------------------------------------------------------------
  always @(*)
    cpkt_rdy <= 1'b1;
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // mode selection
  //---------------------------------------------------------------
  always @(*)
    vmode = `COCHLEA;
    //vmode = msel;
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // virtual key selection
  //---------------------------------------------------------------
  always @(*)
    vkey = `VIRTUAL_KEY_DEF;
    /*case (vksel)
      `VKS_ALT: vkey = `VIRTUAL_KEY_ALT;
      default:  vkey = `VIRTUAL_KEY_DEF;
    endcase*/
  //---------------------------------------------------------------


  //---------------------------------------------------------------
  // generate go signal (initial value configurable)
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      go <= `INIT_GO;
    else
      if (cpkt_vld)
        go <= cpkt_data[8];
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
