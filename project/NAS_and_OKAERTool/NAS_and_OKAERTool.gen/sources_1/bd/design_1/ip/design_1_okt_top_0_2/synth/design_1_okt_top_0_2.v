// (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:okt_top:1.0
// IP Revision: 1

(* X_CORE_INFO = "okt_top,Vivado 2022.1" *)
(* CHECK_LICENSE_TYPE = "design_1_okt_top_0_2,okt_top,{}" *)
(* CORE_GENERATION_INFO = "design_1_okt_top_0_2,okt_top,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=okt_top,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_okt_top_0_2 (
  rst_ext_n,
  clock,
  rst_sw_n,
  okUH,
  okHU,
  okUHU,
  okAA,
  port_a_data,
  port_a_req_n,
  port_a_ack_n,
  port_b_data,
  port_b_req_n,
  port_b_ack_n,
  port_c_data,
  port_c_req_n,
  port_c_ack_n,
  out_data,
  out_req_n,
  out_ack_n,
  config_data,
  config_addr,
  config_en,
  leds
);

input wire rst_ext_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clock, FREQ_HZ 100800000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_okt_top_0_2_clock, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
output wire clock;
output wire rst_sw_n;
input wire [4 : 0] okUH;
output wire [2 : 0] okHU;
inout wire [31 : 0] okUHU;
inout wire okAA;
input wire [7 : 0] port_a_data;
input wire port_a_req_n;
output wire port_a_ack_n;
input wire [7 : 0] port_b_data;
input wire port_b_req_n;
output wire port_b_ack_n;
input wire [7 : 0] port_c_data;
input wire port_c_req_n;
output wire port_c_ack_n;
output wire [15 : 0] out_data;
output wire out_req_n;
input wire out_ack_n;
output wire [15 : 0] config_data;
output wire [15 : 0] config_addr;
output wire [2 : 0] config_en;
output wire [7 : 0] leds;

  okt_top inst (
    .rst_ext_n(rst_ext_n),
    .clock(clock),
    .rst_sw_n(rst_sw_n),
    .okUH(okUH),
    .okHU(okHU),
    .okUHU(okUHU),
    .okAA(okAA),
    .port_a_data(port_a_data),
    .port_a_req_n(port_a_req_n),
    .port_a_ack_n(port_a_ack_n),
    .port_b_data(port_b_data),
    .port_b_req_n(port_b_req_n),
    .port_b_ack_n(port_b_ack_n),
    .port_c_data(port_c_data),
    .port_c_req_n(port_c_req_n),
    .port_c_ack_n(port_c_ack_n),
    .out_data(out_data),
    .out_req_n(out_req_n),
    .out_ack_n(out_ack_n),
    .config_data(config_data),
    .config_addr(config_addr),
    .config_en(config_en),
    .leds(leds)
  );
endmodule
