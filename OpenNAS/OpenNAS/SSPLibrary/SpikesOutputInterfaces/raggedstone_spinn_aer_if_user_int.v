// -------------------------------------------------------------------------
//  Raggedstone board user interface module
//
// -------------------------------------------------------------------------
// AUTHOR
//  lap - luis.plana@manchester.ac.uk
//  Based on work by J Pepper (Date 08/08/2012)
//
// -------------------------------------------------------------------------
// Taken from:
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

`include "raggedstone_spinn_aer_if_top.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
`timescale 1ns / 1ps
module raggedstone_spinn_aer_if_user_int
(
  input  wire                    rst,
  input  wire                    clk,

  // control and status interface
  input  wire                    mode_sel,
  input  wire                    dump_mode,
  input  wire                    error,
  output reg  [`MODE_BITS - 1:0] msel,
  output reg   [`VKS_BITS - 1:0] vksel,

  // display interface (7-segment and leds)
  output reg               [7:0] o_7seg,
  output reg               [3:0] o_strobe,
  output wire                    o_led_act,
  output wire                    o_led_dmp,
  output reg                     o_led_err
);
  //---------------------------------------------------------------
  // constants
  //---------------------------------------------------------------
  localparam PRESCALE_BITS = 14;


  //---------------------------------------------------------------
  // internal signals
  //---------------------------------------------------------------
  // signals for 7-segment display driver
  // ---------------------------------------------------------
  reg              [3:0] digit [0:3];
  reg              [3:0] point;
  reg              [1:0] curr_digit;

  reg                    display_clk;
  reg                    prescale_out;
  reg  [PRESCALE_BITS:0] prescale_cnt;


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //----------------------------- tasks ---------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //---------------------------------------------------------------
  // BCD to 7-segment converter
  // seven segment encoding:
  // bcd2sevenSeg[6:0] = abcdefg
  //---------------------------------------------------------------
  function [6:0] bcd2sevenSeg;
    input [3:0] bcd;
    case (bcd)
            0: bcd2sevenSeg = 7'b000_0001;  // 0
            1: bcd2sevenSeg = 7'b100_1111;  // 1
            2: bcd2sevenSeg = 7'b001_0010;  // 2
            3: bcd2sevenSeg = 7'b000_0110;  // 3
            4: bcd2sevenSeg = 7'b100_1100;  // 4
            5: bcd2sevenSeg = 7'b010_0100;  // 5
            6: bcd2sevenSeg = 7'b110_0000;  // 6
            7: bcd2sevenSeg = 7'b000_1111;  // 7
            8: bcd2sevenSeg = 7'b000_0000;  // 8
            9: bcd2sevenSeg = 7'b000_1100;  // 9
           10: bcd2sevenSeg = 7'b111_1111;  // space
           11: bcd2sevenSeg = 7'b111_0010;  // c
           12: bcd2sevenSeg = 7'b110_0010;  // o
           13: bcd2sevenSeg = 7'b110_1000;  // h
      default: bcd2sevenSeg = 7'b111_1111;  // all segments off
    endcase
  endfunction
  //---------------------------------------------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------ mode selection -----------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ---------------------------------------------------------
  // NOTE: only one mode change per button pressing
  // ---------------------------------------------------------
  reg sel_state;

  always @(posedge clk or posedge rst)
    if (rst)
      sel_state <= 0;
    else
      if (mode_sel == 1'b0)
        sel_state <= 1;
      else
        sel_state <= 0;
  // ---------------------------------------------------------

  // ---------------------------------------------------------
  // sequence through modes and virtual keys
  // ---------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      msel <= 0;
    else
      if ((sel_state == 0) && (mode_sel == 1'b0))
      begin
        if (msel == `LAST_MODE)
          msel <= 0;
        else
          msel <= msel + 1;
      end

  always @(posedge clk or posedge rst)
    if (rst)
      vksel <= 0;
    else
      if ((sel_state == 0) && (mode_sel == 1'b0) && (msel == `LAST_MODE))
      begin
        if (vksel == `LAST_VKS)
	  vksel <= 0;
        else
	  vksel <= vksel + 1;
      end
  // ---------------------------------------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //----------------------------- leds ----------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //---------------------------------------------------------------
  // indicate activity by flashing "activity led"
  //---------------------------------------------------------------
  reg [23:0] lstate;

  assign o_led_act = lstate[23];

  always @(posedge clk or posedge rst)
    if (rst)
      lstate <= 0;
    else
      if (lstate == 24'hffffff)
        lstate <= 0;
      else
        lstate <= lstate + 1;
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // report dump mode using "dump led"
  //---------------------------------------------------------------
  assign o_led_dmp = dump_mode;
  //---------------------------------------------------------------

  //---------------------------------------------------------------
  // report errors using "error led" (sticky)
  //---------------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      o_led_err <= 1'b0;
    else
      if (error)
        o_led_err <= 1'b1;
  //---------------------------------------------------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //------------------------ display driver -----------------------
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //---------------------------------------------------------------
  // use decimal point to show virtual key selection
  //---------------------------------------------------------------
  always @(posedge clk)
    case (vksel)
      `VKS_ALT: point <= 4'b1110;

      // no decimal point is the default
      default: point <= 4'b1111;
    endcase
  //---------------------------------------------------------------

  // ---------------------------------------------------------
  // display current mode in 7-segment displays
  // ---------------------------------------------------------
  always @(posedge clk)
    case (msel)
      `RET_128:
        begin
          digit[0] <= 4'd10;
          digit[1] <= 4'd1;
          digit[2] <= 4'd2;
          digit[3] <= 4'd8;
        end

      `RET_64:
        begin
          digit[0] <= 4'd10;
          digit[1] <= 4'd10;
          digit[2] <= 4'd6;
          digit[3] <= 4'd4;
        end

      `RET_32:
        begin
          digit[0] <= 4'd10;
          digit[1] <= 4'd10;
          digit[2] <= 4'd3;
          digit[3] <= 4'd2;
        end

      `RET_16:
        begin
          digit[0] <= 4'd10;
          digit[1] <= 4'd10;
          digit[2] <= 4'd1;
          digit[3] <= 4'd6;
        end

      `COCHLEA:
        begin
          digit[0] <= 4'd11;
          digit[1] <= 4'd12;
          digit[2] <= 4'd11;
          digit[3] <= 4'd13;
        end

      `DIRECT:
        begin
          digit[0] <= 4'd0;
          digit[1] <= 4'd0;
          digit[2] <= 4'd0;
          digit[3] <= 4'd0;
        end
    endcase
  // ---------------------------------------------------------

  // ---------------------------------------------------------
  // 7-segment display driver
  // ---------------------------------------------------------
  //---------------------------------------------------------------
  // current digit selection
  //---------------------------------------------------------------
  always @(posedge display_clk or posedge rst)
    if (rst)
      curr_digit <= 0;
    else
      curr_digit <= curr_digit + 1;

  always @(posedge display_clk or posedge rst)
    if (rst)
      o_strobe <= 4'b0000;
    else
      case (curr_digit)
        0: o_strobe <= 4'b0001;
        1: o_strobe <= 4'b0010;
        2: o_strobe <= 4'b0100;
        3: o_strobe <= 4'b1000;
      endcase

  always @(posedge display_clk or posedge rst)
    if (rst)
      o_7seg <= 8'b1111_1111;
    else
      o_7seg <= {point[curr_digit], bcd2sevenSeg(digit[curr_digit])};
  // ---------------------------------------------------------

  // ---------------------------------------------------------
  // display clock generator (scaled-down external clock)
  // ---------------------------------------------------------
  always @(posedge clk or posedge rst)
    if (rst)
      prescale_cnt <= 0;
    else
      prescale_cnt <= prescale_cnt + 1;

  always @(posedge clk or posedge rst)
    if (rst)
      prescale_out <= 0;
    else
      prescale_out <= (prescale_cnt == 0);

  always @(posedge prescale_out)
    display_clk <= ~display_clk;
  // ---------------------------------------------------------
endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
