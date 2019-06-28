/**
 * global constants
 */

`ifndef RAGGEDSTONE_SPINN_AER_IF_TOP_H
`define RAGGEDSTONE_SPINN_AER_IF_TOP_H

// ---------------------
// virtual keys
// ---------------------
`define VKS_BITS    1

// virtual key selection
`define VKS_DEF     0
`define VKS_ALT     (`VKS_DEF + 1)
`define LAST_VKS    `VKS_ALT

`define VKEY_BITS 16

// virtual keys choices
`define VIRTUAL_KEY_DEF  16'h0200
`define VIRTUAL_KEY_ALT  16'hfefe
// ---------------------

// ---------------------
// mode
// ---------------------
`define MODE_BITS  3

// mode options
`define RET_128    0
`define RET_64     (`RET_128 + 1)
`define RET_32     (`RET_64  + 1)
`define RET_16     (`RET_32  + 1)
`define COCHLEA    (`RET_16  + 1)
`define DIRECT     (`COCHLEA + 1)
`define LAST_MODE  `DIRECT

// ---------------------
// dump mode
// ---------------------
`define DUMP_CNT   256  // adjust depending on clock speed

// ---------------------
// control and routing
// ---------------------
`define INIT_GO    1'b0

`define CTRL_KEY   32'h0000fffe
`define CTRL_MSK   32'h0000fffe

`endif
