// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed May 14 10:31:02 2025
// Host        : us running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_okt_sno_top_0_0_sim_netlist.v
// Design      : design_1_okt_sno_top_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_okt_sno_top_0_0,okt_sno_top,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "okt_sno_top,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clock,
    rst_n,
    AER_DATA_OUT,
    AER_REQ,
    AER_ACK);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clock, FREQ_HZ 48000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *) input clock;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst_n;
  output [7:0]AER_DATA_OUT;
  output AER_REQ;
  input AER_ACK;

  wire AER_ACK;
  wire [7:0]AER_DATA_OUT;
  wire AER_REQ;
  wire clock;
  wire rst_n;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno_top inst
       (.AER_ACK(AER_ACK),
        .AER_DATA_OUT(AER_DATA_OUT),
        .AER_REQ(AER_REQ),
        .clock(clock),
        .rst_n(rst_n));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno
   (AER_REQ,
    rst_n_0,
    AER_DATA_OUT,
    clock,
    rst_n,
    node_ack_n_latch_1);
  output AER_REQ;
  output rst_n_0;
  output [7:0]AER_DATA_OUT;
  input clock;
  input rst_n;
  input node_ack_n_latch_1;

  wire [7:0]AER_DATA_OUT;
  wire AER_REQ;
  wire \AER_generator.counter[7]_i_3_n_0 ;
  wire [7:0]\AER_generator.counter_reg ;
  wire \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0 ;
  wire \FSM_onehot_r_okt_sno_control_state_reg_n_0_[0] ;
  wire \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ;
  wire \FSM_onehot_r_okt_sno_control_state_reg_n_0_[2] ;
  wire \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ;
  wire clock;
  wire counter;
  wire node_ack_n_latch_1;
  wire [7:0]node_data;
  wire \node_data[7]_i_1_n_0 ;
  wire [7:0]p_0_in;
  wire rst_n;
  wire rst_n_0;

  LUT1 #(
    .INIT(2'h1)) 
    \AER_generator.counter[0]_i_1 
       (.I0(\AER_generator.counter_reg [0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \AER_generator.counter[1]_i_1 
       (.I0(\AER_generator.counter_reg [0]),
        .I1(\AER_generator.counter_reg [1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \AER_generator.counter[2]_i_1 
       (.I0(\AER_generator.counter_reg [0]),
        .I1(\AER_generator.counter_reg [1]),
        .I2(\AER_generator.counter_reg [2]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \AER_generator.counter[3]_i_1 
       (.I0(\AER_generator.counter_reg [1]),
        .I1(\AER_generator.counter_reg [0]),
        .I2(\AER_generator.counter_reg [2]),
        .I3(\AER_generator.counter_reg [3]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \AER_generator.counter[4]_i_1 
       (.I0(\AER_generator.counter_reg [2]),
        .I1(\AER_generator.counter_reg [0]),
        .I2(\AER_generator.counter_reg [1]),
        .I3(\AER_generator.counter_reg [3]),
        .I4(\AER_generator.counter_reg [4]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \AER_generator.counter[5]_i_1 
       (.I0(\AER_generator.counter_reg [3]),
        .I1(\AER_generator.counter_reg [1]),
        .I2(\AER_generator.counter_reg [0]),
        .I3(\AER_generator.counter_reg [2]),
        .I4(\AER_generator.counter_reg [4]),
        .I5(\AER_generator.counter_reg [5]),
        .O(p_0_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \AER_generator.counter[6]_i_1 
       (.I0(\AER_generator.counter[7]_i_3_n_0 ),
        .I1(\AER_generator.counter_reg [6]),
        .O(p_0_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    \AER_generator.counter[7]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ),
        .I1(node_ack_n_latch_1),
        .O(counter));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \AER_generator.counter[7]_i_2 
       (.I0(\AER_generator.counter[7]_i_3_n_0 ),
        .I1(\AER_generator.counter_reg [6]),
        .I2(\AER_generator.counter_reg [7]),
        .O(p_0_in[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \AER_generator.counter[7]_i_3 
       (.I0(\AER_generator.counter_reg [5]),
        .I1(\AER_generator.counter_reg [3]),
        .I2(\AER_generator.counter_reg [1]),
        .I3(\AER_generator.counter_reg [0]),
        .I4(\AER_generator.counter_reg [2]),
        .I5(\AER_generator.counter_reg [4]),
        .O(\AER_generator.counter[7]_i_3_n_0 ));
  FDCE \AER_generator.counter_reg[0] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[0]),
        .Q(\AER_generator.counter_reg [0]));
  FDCE \AER_generator.counter_reg[1] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[1]),
        .Q(\AER_generator.counter_reg [1]));
  FDCE \AER_generator.counter_reg[2] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[2]),
        .Q(\AER_generator.counter_reg [2]));
  FDCE \AER_generator.counter_reg[3] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[3]),
        .Q(\AER_generator.counter_reg [3]));
  FDCE \AER_generator.counter_reg[4] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[4]),
        .Q(\AER_generator.counter_reg [4]));
  FDCE \AER_generator.counter_reg[5] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[5]),
        .Q(\AER_generator.counter_reg [5]));
  FDCE \AER_generator.counter_reg[6] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[6]),
        .Q(\AER_generator.counter_reg [6]));
  FDCE \AER_generator.counter_reg[7] 
       (.C(clock),
        .CE(counter),
        .CLR(rst_n_0),
        .D(p_0_in[7]),
        .Q(\AER_generator.counter_reg [7]));
  LUT5 #(
    .INIT(32'hFEFEFEBA)) 
    \FSM_onehot_r_okt_sno_control_state[3]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(node_ack_n_latch_1),
        .I2(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[2] ),
        .I3(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[0] ),
        .I4(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ),
        .O(\FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "idle:0001,req:0010,wait_ack:0100,ack:1000" *) 
  FDPE #(
    .INIT(1'b1)) 
    \FSM_onehot_r_okt_sno_control_state_reg[0] 
       (.C(clock),
        .CE(\FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0 ),
        .D(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ),
        .PRE(rst_n_0),
        .Q(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[0] ));
  (* FSM_ENCODED_STATES = "idle:0001,req:0010,wait_ack:0100,ack:1000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_r_okt_sno_control_state_reg[1] 
       (.C(clock),
        .CE(\FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[0] ),
        .Q(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ));
  (* FSM_ENCODED_STATES = "idle:0001,req:0010,wait_ack:0100,ack:1000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_r_okt_sno_control_state_reg[2] 
       (.C(clock),
        .CE(\FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .Q(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[2] ));
  (* FSM_ENCODED_STATES = "idle:0001,req:0010,wait_ack:0100,ack:1000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_r_okt_sno_control_state_reg[3] 
       (.C(clock),
        .CE(\FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[2] ),
        .Q(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[0]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [0]),
        .O(node_data[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[1]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [1]),
        .O(node_data[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[2]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [2]),
        .O(node_data[2]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[3]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [3]),
        .O(node_data[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[4]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [4]),
        .O(node_data[4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[5]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [5]),
        .O(node_data[5]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[6]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [6]),
        .O(node_data[6]));
  LUT2 #(
    .INIT(4'hE)) 
    \node_data[7]_i_1 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ),
        .O(\node_data[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \node_data[7]_i_2 
       (.I0(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[1] ),
        .I1(\AER_generator.counter_reg [7]),
        .O(node_data[7]));
  LUT1 #(
    .INIT(2'h1)) 
    \node_data[7]_i_3 
       (.I0(rst_n),
        .O(rst_n_0));
  FDCE \node_data_reg[0] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[0]),
        .Q(AER_DATA_OUT[0]));
  FDCE \node_data_reg[1] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[1]),
        .Q(AER_DATA_OUT[1]));
  FDCE \node_data_reg[2] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[2]),
        .Q(AER_DATA_OUT[2]));
  FDCE \node_data_reg[3] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[3]),
        .Q(AER_DATA_OUT[3]));
  FDCE \node_data_reg[4] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[4]),
        .Q(AER_DATA_OUT[4]));
  FDCE \node_data_reg[5] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[5]),
        .Q(AER_DATA_OUT[5]));
  FDCE \node_data_reg[6] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[6]),
        .Q(AER_DATA_OUT[6]));
  FDCE \node_data_reg[7] 
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .CLR(rst_n_0),
        .D(node_data[7]),
        .Q(AER_DATA_OUT[7]));
  FDPE node_req_n_reg
       (.C(clock),
        .CE(\node_data[7]_i_1_n_0 ),
        .D(\FSM_onehot_r_okt_sno_control_state_reg_n_0_[3] ),
        .PRE(rst_n_0),
        .Q(AER_REQ));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno_top
   (AER_DATA_OUT,
    AER_REQ,
    clock,
    AER_ACK,
    rst_n);
  output [7:0]AER_DATA_OUT;
  output AER_REQ;
  input clock;
  input AER_ACK;
  input rst_n;

  wire AER_ACK;
  wire [7:0]AER_DATA_OUT;
  wire AER_REQ;
  wire clock;
  wire node_ack_n_latch_0;
  wire node_ack_n_latch_1;
  wire okt_sno_inst_n_1;
  wire rst_n;

  FDPE node_ack_n_latch_0_reg
       (.C(clock),
        .CE(1'b1),
        .D(AER_ACK),
        .PRE(okt_sno_inst_n_1),
        .Q(node_ack_n_latch_0));
  FDPE node_ack_n_latch_1_reg
       (.C(clock),
        .CE(1'b1),
        .D(node_ack_n_latch_0),
        .PRE(okt_sno_inst_n_1),
        .Q(node_ack_n_latch_1));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno okt_sno_inst
       (.AER_DATA_OUT(AER_DATA_OUT),
        .AER_REQ(AER_REQ),
        .clock(clock),
        .node_ack_n_latch_1(node_ack_n_latch_1),
        .rst_n(rst_n),
        .rst_n_0(okt_sno_inst_n_1));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
