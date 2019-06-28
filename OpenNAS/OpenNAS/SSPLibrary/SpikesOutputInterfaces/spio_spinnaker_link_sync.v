// -------------------------------------------------------------------------
//  $Id: synchronizer.v 2517 2013-08-19 09:33:30Z plana $
// spiNNlink 2-flop synchronizer
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//
// -------------------------------------------------------------------------
// DETAILS
//  Created on       : 29 Nov 2012
//  Version          : $Revision: 2517 $
//  Last modified on : $Date: 2013-08-19 10:33:30 +0100 (Mon, 19 Aug 2013) $
//  Last modified by : $Author: plana $
//  $HeadURL: https://solem.cs.man.ac.uk/svn/spiNNlink/testing/src/synchronizer.v $
//
// -------------------------------------------------------------------------
// COPYRIGHT
//  Copyright (c) The University of Manchester, 2012-2016.
//  SpiNNaker Project
//  Advanced Processor Technologies Group
//  School of Computer Science
// -------------------------------------------------------------------------
//
// TODO
// -------------------------------------------------------------------------


`timescale 1ns / 1ps
module spio_spinnaker_link_sync #
(
  parameter SIZE = 1
)
(
  input                   CLK_IN,
  input      [SIZE - 1:0] IN,
  output reg [SIZE - 1:0] OUT
);

  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  (* IOB = "TRUE" *)
  reg  [SIZE - 1:0] sync;

   
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //--------------------------- datapath --------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // flops
  always @ (posedge CLK_IN)
    begin
       sync <= IN;
       OUT  <= sync;
    end
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

endmodule
