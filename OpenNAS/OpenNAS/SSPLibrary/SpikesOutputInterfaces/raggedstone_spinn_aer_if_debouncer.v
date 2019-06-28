// -------------------------------------------------------------------------
//  Button debouncer
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Adapted from:
// https://solem.cs.man.ac.uk/svn/spinn_aer2_if/user_int.v
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


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module raggedstone_spinn_aer_if_debouncer
#(
  // debouncer constant (can be adjusted for simulation!)
  parameter DBNCER_CONST = 20'hfffff,
  parameter RESET_VALUE  = 1'b1
)
(
  input  wire                   rst,
  input  wire                   clk,

  // button signals
  input  wire                   pb_input,
  output reg                    pb_debounced
);
  // ---------------------------------------------------------
  // internal signals
  // ---------------------------------------------------------
  reg [19:0] pb_debounce_cnt;
  reg  [2:0] pb_bounce;
  reg        pb_sel_debounced;

  // ---------------------------------------------------------
  // generate stable output signal after suitable delay
  // ---------------------------------------------------------
  // for simulation purposes only!
  initial
    begin
      pb_debounced = RESET_VALUE;
      pb_debounce_cnt = DBNCER_CONST;
    end

  always @(posedge clk or posedge rst)
    if (rst)
      pb_debounced <= RESET_VALUE;
    else
      if ((pb_bounce[2] == pb_bounce[1]) && (pb_debounce_cnt == 0))
        pb_debounced <= pb_bounce[2];

  always @(posedge clk)
    begin
      pb_bounce[0] <= pb_input;  
      pb_bounce[1] <= pb_bounce[0];
      pb_bounce[2] <= pb_bounce[1];
    end

  always @(posedge clk)
    if (pb_bounce[2] != pb_bounce[1]) 
      pb_debounce_cnt <= DBNCER_CONST;
    else
      if (pb_debounce_cnt != 0)
        pb_debounce_cnt <= pb_debounce_cnt - 1;
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
