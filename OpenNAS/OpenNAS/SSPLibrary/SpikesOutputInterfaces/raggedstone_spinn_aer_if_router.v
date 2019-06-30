// -------------------------------------------------------------------------
//  SpiNNaker <-> AER interface SpiNNaker packet router module
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
module raggedstone_spinn_aer_if_router
(
  input  wire                   rst,
  input  wire                   clk,

  // SpiNNaker packet interface
  input  wire [`PKT_BITS - 1:0] spkt_data,
  input  wire                   spkt_vld,
  output wire                   spkt_rdy,

  // out_mapper packet interface
  output wire [`PKT_BITS - 1:0] opkt_data,
  output wire                   opkt_vld,
  input  wire                   opkt_rdy,

  // control packet interface
  output wire [`PKT_BITS - 1:0] cpkt_data,
  output wire                   cpkt_vld,
  input  wire                   cpkt_rdy
);
  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  wire [1:0] sw_sel;
  wire       mc_pkt;  // incoming packet is multicast
  wire       ct_pkt;  // incoming packet is control


  //---------------------------------------------------------------
  // switch packets
  //---------------------------------------------------------------
  spio_switch
  #(
    .PKT_BITS(`PKT_BITS),
    .NUM_PORTS(2)
  ) sw
  (
    .RESET_IN             (rst),
    .CLK_IN               (clk),
    .IN_DATA_IN           (spkt_data),
    .IN_VLD_IN            (spkt_vld),
    .IN_RDY_OUT           (spkt_rdy),
    .IN_OUTPUT_SELECT_IN  (sw_sel),
    .OUT_DATA_OUT         ({cpkt_data, opkt_data}),
    .OUT_VLD_OUT          ({cpkt_vld,  opkt_vld}),
    .OUT_RDY_IN           ({cpkt_rdy,  opkt_rdy}),
    .BLOCKED_OUTPUTS_OUT  (),
    .SELECTED_OUTPUTS_OUT (),
    .DROP_IN              (1'b0),
    .DROPPED_DATA_OUT     (),
    .DROPPED_OUTPUTS_OUT  (),
    .DROPPED_VLD_OUT      ()
  );

  // route selection (drop non-multicast packets)
  assign sw_sel[0] = spkt_vld & mc_pkt & ~ct_pkt;
  assign sw_sel[1] = spkt_vld & mc_pkt &  ct_pkt;

  // detect packet types
  assign mc_pkt = (spkt_data[7:6] == 2'b00);
  assign ct_pkt = ((spkt_data[`PKT_KEY_RNG] & `CTRL_MSK) == `CTRL_KEY);
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
