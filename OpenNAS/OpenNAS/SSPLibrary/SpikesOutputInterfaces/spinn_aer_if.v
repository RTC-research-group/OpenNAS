// -------------------------------------------------------------------------
// $Id$
// -------------------------------------------------------------------------
// COPYRIGHT
// Copyright (c) The University of Manchester, 2012. All rights reserved.
// SpiNNaker Project
// Advanced Processor Technologies Group
// School of Computer Science
// -------------------------------------------------------------------------
// Project            : SpiNNaker link to AER sensor interface
// Module             : top-level module
// Author             : Simon Davidson/Jeff Pepper
// Status             : Review pending
// $HeadURL$
// Last modified on   : $Date$
// Last modified by   : $Author$
// Version            : $Revision$
// -------------------------------------------------------------------------

`timescale 1ns / 1ps

 module spinn_aer_if 
(
    clk,
    data_2of7_to_spinnaker,
    ack_from_spinnaker,
    aer_req,
    aer_data,
    aer_ack,
    reset
);

input        clk;
input        reset;
output [6:0] data_2of7_to_spinnaker;
input        ack_from_spinnaker;

input        aer_req;
input [15:0] aer_data;
output       aer_ack;




//---------------------------------------------------------------
// constants
//---------------------------------------------------------------
// mode and resolution values
localparam RESOL_BITS  = 4;
localparam RET_128_DEF = 0;
localparam RET_64_DEF  = RET_128_DEF + 1;
localparam RET_32_DEF  = RET_64_DEF  + 1;
localparam RET_16_DEF  = RET_32_DEF  + 1;
localparam COCHLEA_DEF = RET_16_DEF  + 1;
localparam DIRECT_DEF  = COCHLEA_DEF + 1;
localparam RET_128_ALT = DIRECT_DEF  + 1;
localparam RET_64_ALT  = RET_128_ALT + 1;
localparam RET_32_ALT  = RET_64_ALT  + 1;
localparam RET_16_ALT  = RET_32_ALT  + 1;
localparam COCHLEA_ALT = RET_16_ALT  + 1;
localparam DIRECT_ALT  = COCHLEA_ALT + 1;
localparam LAST_VALUE  = DIRECT_ALT;

// alternative chip coordinates
localparam CHIP_ADDR_DEF = 16'h0200;
localparam CHIP_ADDR_ALT = 16'hfefe;


//---------------------------------------------------------------
// internal signals
//---------------------------------------------------------------
// Signals for 'event dump mode'
reg       dump_mode_r;
reg [4:0] wait_counter_r;

wire [15:0]  i_aer_data;
reg          i_aer_ack;
//---------------------------------------------------------------


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//----------------------------- tasks ---------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//---------------------------------------------------------------

//---------------------------------------------------------------
// 2-of-7 NRZ data encoder (SpiNNaker interface)
//---------------------------------------------------------------
 function [6:0] code_2of7_lut ;
  input   [4:0] din;
  input   [6:0] code_2of7;

	casez(din)
		5'b00000 : code_2of7_lut = code_2of7 ^ 7'b0010001; // 0
		5'b00001 : code_2of7_lut = code_2of7 ^ 7'b0010010; // 1
		5'b00010 : code_2of7_lut = code_2of7 ^ 7'b0010100; // 2
		5'b00011 : code_2of7_lut = code_2of7 ^ 7'b0011000; // 3
		5'b00100 : code_2of7_lut = code_2of7 ^ 7'b0100001; // 4
		5'b00101 : code_2of7_lut = code_2of7 ^ 7'b0100010; // 5
		5'b00110 : code_2of7_lut = code_2of7 ^ 7'b0100100; // 6
		5'b00111 : code_2of7_lut = code_2of7 ^ 7'b0101000; // 7
		5'b01000 : code_2of7_lut = code_2of7 ^ 7'b1000001; // 8
		5'b01001 : code_2of7_lut = code_2of7 ^ 7'b1000010; // 9
		5'b01010 : code_2of7_lut = code_2of7 ^ 7'b1000100; // 10
		5'b01011 : code_2of7_lut = code_2of7 ^ 7'b1001000; // 11
		5'b01100 : code_2of7_lut = code_2of7 ^ 7'b0000011; // 12
		5'b01101 : code_2of7_lut = code_2of7 ^ 7'b0000110; // 13
		5'b01110 : code_2of7_lut = code_2of7 ^ 7'b0001100; // 14
		5'b01111 : code_2of7_lut = code_2of7 ^ 7'b0001001; // 15
		5'b1???? : code_2of7_lut = code_2of7 ^ 7'b1100000; // EOP
		default  : code_2of7_lut = 7'bxxxxxxx;
	endcase;
 endfunction
//---------------------------------------------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//--------------------------- dump mode -------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
initial wait_counter_r = 5'b000000;
always @(posedge clk)
 begin
   if (i2_spinnaker_ack != old_spinnaker_ack)
	  wait_counter_r <= 5'b000000; // Ack from spinnaker resets counter
	else
	  wait_counter_r <= wait_counter_r + 1;
	end
 

always @(posedge clk)
 begin
   if (i2_spinnaker_ack != old_spinnaker_ack)
	  dump_mode_r <= 1'b0; // Leave dump mode once Spinnaker responds
   else if ((wait_counter_r == 5'b11111)&&(if_state != 0))
	  dump_mode_r <= 1'b1; // Enter dump mode once 31 cycles of no response have passed
 end
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//------------------------- synchronisers -----------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---------------------------------------------------------------
// AER sensor request line synchroniser //
//---------------------------------------------------------------
reg     i1_aer_req;
reg     i2_aer_req;
initial i1_aer_req  = 1;
initial i2_aer_req  = 1;

always @(posedge clk)
 begin
  i1_aer_req  <= aer_req;
  i2_aer_req  <= i1_aer_req;
 end
//---------------------------------------------------------------

//---------------------------------------------------------------
// Synchronise the acknowledge coming from the SpiNNaker async i/f
//---------------------------------------------------------------
reg i1_spinnaker_ack;
reg i2_spinnaker_ack;
initial i1_spinnaker_ack  = 1'b0;
initial i2_spinnaker_ack  = 1'b0;

always@(posedge clk)
	begin
	 i1_spinnaker_ack <= ack_from_spinnaker;
	 i2_spinnaker_ack <= i1_spinnaker_ack;
	end
//---------------------------------------------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---------------------------- mapper ---------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg [RESOL_BITS - 1:0] resolution;
reg             [15:0] chip_addr;


reg   [8:0] if_state;
reg         ack_bit_r;
reg   [6:0] i_spinnaker_data;
reg   [4:0] nibble_and_a_bit;
reg  [39:0] packet;
reg         old_spinnaker_ack;
reg  [14:0] coords;
wire  [6:0] new_x, new_y;
wire        sign_bit;
initial     if_state = 0;
initial     i_spinnaker_data = 0;
initial     i_aer_ack = 1;

initial begin
	//chip_addr = CHIP_ADDR_ALT;
	chip_addr = CHIP_ADDR_DEF;
end

assign i_aer_req = aer_req;
assign i_aer_data = aer_data;
assign aer_ack = ack_bit_r;
assign data_2of7_to_spinnaker =i_spinnaker_data;
assign i_spinnaker_ack = ack_from_spinnaker;


//---------------------------------------------------------------
// New on 04/05/2012. Rotate image by 90 degrees clockwise:
//---------------------------------------------------------------
assign new_x = 7'b1111111 - i_aer_data[14:8]; // new_X = 127 - old_Y
assign new_y = 7'b1111111 - i_aer_data[7:1];  // new_Y = 127 - old_X
assign sign_bit = i_aer_data[0];
//---------------------------------------------------------------

//---------------------------------------------------------------
// device and resolution selection 
//---------------------------------------------------------------
always @(*)

 //coords = {3'b000, i_aer_data[1], 3'b000, i_aer_data[7:2],i_aer_data[9:8]};
 
 //coords = {5'b00000, i_aer_data[6:0],3'b000};
 coords = i_aer_data[14:0];
 

//
//---------------------------------------------------------------

//---------------------------------------------------------------
// virtual chip address selection
//---------------------------------------------------------------
//always @(*)begin
// chip_addr = CHIP_ADDR_ALT;
//chip_addr = CHIP_ADDR_DEF;
//end
//---------------------------------------------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//------------------------- spiNN driver ------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
always @(posedge clk)
 begin
 if(reset == 1)
  begin
   if_state <= 0;
	i_spinnaker_data <= 0;
	i_aer_ack <= 1;
  end
 else
  case(if_state)
   0 :  if(i2_aer_req == 0)
	      begin
			 packet <= {chip_addr, i_aer_data[15], coords, 4'h0, 4'h0}; //create spinnaker packet
			 if_state <= if_state + 1;
			end
	1 :   begin
	       // parity bit is ~(^packet[39:1])
          nibble_and_a_bit <= {1'b0, packet[3:1], ~(^packet[39:1])};         			 
			 if_state <= if_state + 1;
			end
  	2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22
     :   begin
			 i_spinnaker_data <= code_2of7_lut(nibble_and_a_bit, i_spinnaker_data); //transmit 2of7 code to spinnaker
		    packet <= packet >> 4;                                                 //shift the next packet nibble down	 
			 old_spinnaker_ack <= i2_spinnaker_ack;
			 if_state <= if_state + 1;
			end
   3, 5, 7, 9, 11, 13, 15, 17, 19 // set the nibble 
     :   begin
	       nibble_and_a_bit[3:0] <= packet[3:0];
	       if(i2_spinnaker_ack != old_spinnaker_ack) if_state <= if_state +1; //wait for ack from spinnaker
			end
	21 :  begin // set eop
          nibble_and_a_bit[4] <= 1;
	       if(i2_spinnaker_ack != old_spinnaker_ack) if_state <= if_state +1;
	      end
	23 :  if(i2_spinnaker_ack != old_spinnaker_ack) // wait for ack from spinnaker then send ack back to AER sensor
          begin
			  i_aer_ack <= 0;
			  if_state <= if_state +1;
			 end
	24 :  if(i2_aer_req == 1) // wait for AER sensor to "see" the ack then take the ack away
			   begin
				 i_aer_ack <= 1;
 			    if_state <= 0;
	         end
	default: ;
  endcase; 
 end

//---------------------------------------------------------------
// Generate ack bit to AER sensor
//---------------------------------------------------------------
initial dump_mode_r = 1'b0;
initial ack_bit_r = 1'b1;
always@(posedge clk)
 begin
   if (dump_mode_r) // Ack all requests
	  begin
	    if (!i2_aer_req)
		   ack_bit_r <= 1'b0; // Ack this request
		 else
		   ack_bit_r <= 1'b1; // Stop acknowledging - the request has gone away
	  end
   else
	  begin
	  // When not in dump mode, ack when state machine says, but only if req
	  // is still present (req may have been acked previously by dump_mode state machine,
	  // so don't confuse things by acking again):
	  ack_bit_r <= i_aer_ack | i2_aer_req;
	  end
 end
//---------------------------------------------------------------
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
  


// ---------------------------------------------------------
// sequence through resolutions
// ---------------------------------------------------------
initial resolution = COCHLEA_DEF;



endmodule
