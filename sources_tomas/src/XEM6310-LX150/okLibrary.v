//------------------------------------------------------------------------
// okLibrary.v
//
// FrontPanel Library Module Declarations (Verilog)
// XEM6310
//
// Copyright (c) 2004-2011 Opal Kelly Incorporated
// $Rev$ $Date$
//------------------------------------------------------------------------
module okHost
	(
	input  wire [4:0]   okUH,
	output wire [2:0]   okHU,
	inout  wire [31:0]  okUHU,
	inout  wire         okAA,
	output wire         okClk,
	output wire [112:0] okHE,
  input  wire [64:0]  okEH
	);
	
	wire [38:0] okHC;
	wire [37:0] okCH;

	wire        okUH0_ibufg;
	wire        dcm0_clk0;
	wire        dcm0_locked;
	
	wire [31:0] iobf0_o;
	wire [31:0] regout0_q;
	wire [31:0] regvalid_q;
	
	wire [3:0]  okUHx;
	
	assign okClk    =  okHC[0];
	assign okHC[38] = ~dcm0_locked;

	IBUFG  hi_clk_bufg  (.I(okUH[0]), .O(okUH0_ibufg));

	DCM_SP #(
		.CLKIN_PERIOD(9.92),                  // Input clock period specified in nS
		.CLKOUT_PHASE_SHIFT("FIXED"),         // Output phase shift (NONE, FIXED, VARIABLE)
		.PHASE_SHIFT("-32"),                  // Fixed negative phase shift centers clock in "ctrl_in" data valid window.~1ns (-255 to 255)
		.CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
		.DESKEW_ADJUST("SOURCE_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
		.STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
	) dcm0 (
		.CLK0(dcm0_clk0),                     // Negative phase shifted to clock in CTRL
		.LOCKED(dcm0_locked),                 // 1-bit output: DCM_SP Lock Output
		.CLKFB(okHC[0]),                      // 1-bit input: Clock feedback input
		.CLKIN(okUH0_ibufg),                  // 1-bit input: Clock input
		.RST(1'b0),                           // 1-bit input: Active high reset input
		.PSEN(1'b0)
	);

	BUFG  dcm0_bufg  (.I(dcm0_clk0), .O(okHC[0]));

	
	//------------------------------------------------------------------------
	// Bidirectional IOB registers
	//------------------------------------------------------------------------
	
	genvar i;
	generate
		for (i=0; i<32; i=i+1) begin : iob_regs
			IOBUF iobf0 (.IO(okUHU[i]), .I(regout0_q[i]), .O(iobf0_o[i]), .T(regvalid_q[i]));
	
			//Input Registering
			(* IOB = "true" *)
			FDRE regin0 (.D(iobf0_o[i]), .Q(okHC[i+5]), .C(okHC[0]), .CE(1'b1), .R(1'b0));
	
			// Output Registering
			(* IOB = "true" *)
			FDRE regout0 (.D(okCH[i+3]), .Q(regout0_q[i]), .C(okHC[0]), .CE(1'b1), .R(1'b0));
			
			// Tristate Drive
			(* IOB = "true" *)
			FDRE regvalid (.D(~okCH[36]), .Q(regvalid_q[i]), .C(okHC[0]), .CE(1'b1), .R(1'b0));
		end
	endgenerate
	
	IOBUF tbuf(.I(okCH[35]), .O(okHC[37]), .T(okCH[37]), .IO(okAA));

	//------------------------------------------------------------------------
	// Output IOB registers
	//------------------------------------------------------------------------
	(* IOB = "true" *)
	FDRE regctrlout0 (.D(okCH[2]), .C(okHC[0]), .CE(1'b1), .R(1'b0), .Q(okHU[2]));
	(* IOB = "true" *)
	FDRE regctrlout1 (.D(okCH[0]), .C(okHC[0]), .CE(1'b1), .R(1'b0), .Q(okHU[0]));
	(* IOB = "true" *)
	FDRE regctrlout2 (.D(okCH[1]), .C(okHC[0]), .CE(1'b1), .R(1'b0), .Q(okHU[1]));

	//------------------------------------------------------------------------
	// Input IOB registers
	//  - First registered on DCM0 (positive edge)
	//  - Then registered on DCM0 (negative edge)
	//------------------------------------------------------------------------
	(* IOB = "true" *)
	FDRE regctrlin0a (.C(okHC[0]),  .D(okUH[1]),  .Q(okHC[1]), .CE(1'b1), .R(1'b0));
	(* IOB = "true" *)
	FDRE regctrlin1a (.C(okHC[0]),  .D(okUH[2]),  .Q(okHC[2]), .CE(1'b1), .R(1'b0));
	(* IOB = "true" *)
	FDRE regctrlin2a (.C(okHC[0]),  .D(okUH[3]),  .Q(okHC[3]), .CE(1'b1), .R(1'b0));
	(* IOB = "true" *)
	FDRE regctrlin3a (.C(okHC[0]),  .D(okUH[4]),  .Q(okHC[4]), .CE(1'b1), .R(1'b0));


	okCoreHarness core0(.okHC(okHC), .okCH(okCH), .okHE(okHE), .okEH(okEH));
endmodule

module okCoreHarness(okHC, okCH, okHE, okEH);
	input  [38:0]  okHC;
	output [37:0]  okCH;
	output [112:0] okHE;
	input  [64:0]  okEH;
// synthesis attribute box_type okCoreHarness "black_box"
endmodule


module okWireIn(okHE, ep_addr, ep_dataout);
	input  [112:0] okHE;
	input  [7:0]   ep_addr;
	output [31:0]  ep_dataout;
// synthesis attribute box_type okWireIn "black_box"
endmodule


module okWireOut(okHE, okEH, ep_addr, ep_datain);
	input  [112:0] okHE;
	output [64:0]  okEH;
	input  [7:0]   ep_addr;
	input  [31:0]  ep_datain;
// synthesis attribute box_type okWireOut "black_box"
endmodule


module okTriggerIn(okHE, ep_addr, ep_clk, ep_trigger);
	input  [112:0] okHE;
	input  [7:0]   ep_addr;
	input          ep_clk;
	output [31:0]  ep_trigger;
// synthesis attribute box_type okTriggerIn "black_box"
endmodule


module okTriggerOut(okHE, okEH, ep_addr, ep_clk, ep_trigger);
	input  [112:0] okHE;
	output [64:0]  okEH;
	input  [7:0]   ep_addr;
	input          ep_clk;
	input  [31:0]  ep_trigger;
// synthesis attribute box_type okTriggerOut "black_box"
endmodule


module okPipeIn(okHE, okEH, ep_addr, ep_write, ep_dataout);
	input  [112:0] okHE;
	output [64:0]  okEH;
	input  [7:0]   ep_addr;
	output         ep_write;
	output [31:0]  ep_dataout;
// synthesis attribute box_type okPipeIn "black_box"
endmodule


module okPipeOut(okHE, okEH, ep_addr, ep_read, ep_datain);
	input  [112:0] okHE;
	output [64:0]  okEH;
	input  [7:0]   ep_addr;
	output         ep_read;
	input  [31:0]  ep_datain;
// synthesis attribute box_type okPipeOut "black_box"
endmodule

module okBTPipeIn(okHE, okEH, ep_addr, ep_write, ep_blockstrobe, ep_dataout, ep_ready);
	input  [112:0] okHE;
	output [64:0]  okEH;
	input  [7:0]   ep_addr;
	output         ep_write;
	output         ep_blockstrobe;
	output [31:0]  ep_dataout;
	input          ep_ready;
// synthesis attribute box_type okBTPipeIn "black_box"
endmodule


module okBTPipeOut(okHE, okEH, ep_addr, ep_read, ep_blockstrobe, ep_datain, ep_ready);
	input  [112:0] okHE;
	output [64:0]  okEH;
	input  [7:0]   ep_addr;
	output         ep_read;
	output         ep_blockstrobe;
	input  [31:0]  ep_datain;
	input          ep_ready;
// synthesis attribute box_type okBTPipeOut "black_box"
endmodule

module okRegisterBridge(okHE, okEH, ep_address, ep_write, ep_dataout, ep_read, ep_datain);
	input  wire [112:0] okHE;
	output wire [64:0]  okEH;
	output wire [31:0]  ep_address;
	output wire         ep_write;
	output wire [31:0]  ep_dataout;
	output wire         ep_read;
	input  wire [31:0]  ep_datain;
// synthesis attribute box_type okRegisterBridge "black_box"	
endmodule

module okWireOR # (parameter N = 1)	(
	output reg  [64:0]     okEH,
	input  wire [N*65-1:0] okEHx
	);

	integer i;
	always @(okEHx)
	begin
		okEH = 0;
		for (i=0; i<N; i=i+1) begin: wireOR
			okEH = okEH | okEHx[ i*65 +: 65 ];
		end
	end
endmodule
