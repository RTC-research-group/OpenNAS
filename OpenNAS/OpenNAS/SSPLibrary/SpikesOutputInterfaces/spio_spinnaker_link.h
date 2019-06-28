// -------------------------------------------------------------------------
// $Id: spiNNlink_definitions.v 2515 2013-08-19 07:50:12Z plana $
//  spiNNlink global constants and parameters
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//
// -------------------------------------------------------------------------
// Taken from:
// https://solem.cs.man.ac.uk/svn/spiNNlink/testing/src/spiNNlink_definitions.v
// Revision 2515 (Last-modified date: Date: 2013-08-19 08:50:12 +0100)
//
// -------------------------------------------------------------------------
// COPYRIGHT
//  Copyright (c) The University of Manchester, 2012-2016.
//  SpiNNaker Project
//  Advanced Processor Technologies Group
//  School of Computer Science
// -------------------------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`ifndef SCD_DEF
`define SCD_DEF
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


// ----------------------------------------------------------------
// ---------------------- bit sizes and ranges --------------------
// ----------------------------------------------------------------
`define PKT_BITS         72
`define PKT_HDR_RNG       0 +: 8
`define PKT_KEY_RNG       8 +: 32
`define PKT_PLD_RNG      40 +: 32


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`endif
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

