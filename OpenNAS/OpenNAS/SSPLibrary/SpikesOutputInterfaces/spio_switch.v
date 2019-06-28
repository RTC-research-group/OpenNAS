/**
 * A 1-to-N switch capable of multicast and packet dropping.
 */


module spio_switch#( // The size of individual packets.
                     parameter PKT_BITS = 72
                     // The number of output ports
                   , parameter NUM_PORTS = 2
                   )
                   ( input wire CLK_IN
                   , input wire RESET_IN
                     // Input port
                       // Standard rdy/vld signals
                   ,   input  wire [PKT_BITS-1:0]  IN_DATA_IN
                   ,   input  wire                 IN_VLD_IN
                   ,   output wire                 IN_RDY_OUT
                       // Output selection bits, one bit per output with bit 0
                       // selecting output 0 and so on. If all bits are zero,
                       // the packet is dropped. Sampled on a positive clock
                       // edge when IN_VLD_IN and IN_RDY_OUT are high.
                   ,   input  wire [NUM_PORTS-1:0] IN_OUTPUT_SELECT_IN
                     // Output ports (concatenated into large buses due to
                     // Verilog's inability to support array inputs.
                   , output reg  [(PKT_BITS*NUM_PORTS)-1:0] OUT_DATA_OUT
                   , output reg  [NUM_PORTS-1:0]            OUT_VLD_OUT
                   , input  wire [NUM_PORTS-1:0]            OUT_RDY_IN
                     // Output blocking status signals
                       // A field of bits indicating which output ports are
                       // currently blocking a packet from being sent. Bit 0
                       // corresponds to output 0 being blocked, etc. If all
                       // zero, no outputs are blocked.
                   ,   output wire [NUM_PORTS-1:0] BLOCKED_OUTPUTS_OUT
                       // When BLOCKED_OUTPUTS_OUT is not all zeros, this signal
                       // indicates what outputs the current value is being sent
                       // to, i.e. the XOR of BLOCKED_OUTPUTS_OUT and
                       // SELECTED_OUTPUTS_OUT indicates the outputs where the
                       // packet has been successfully sent.
                   ,   output wire [NUM_PORTS-1:0] SELECTED_OUTPUTS_OUT
                     // A one-clock pulse on this input will cause any packet
                     // waiting an output port to be dropped. Note that the
                     // packet will still be sent if the output port is
                     // unblocked.
                   , input wire DROP_IN
                     // If a packet is dropped, either by the DROP_IN signal or
                     // an all-zero IN_OUTPUT_SELECT_IN, it will be output here for a
                     // single clock cycle (along with a vld signal).
                       // The contents of the packet dropped
                   ,   output reg [PKT_BITS-1:0] DROPPED_DATA_OUT
                       // The set of outputs which were due to send this packet
                       // but didn't because it was dropped. This will
                       // correspond to the blocked ports if DROP_IN caused the
                       // packet to be dropped or will be all zeros if
                       // IN_OUTPUT_SELECT_IN was all zeros.
                   ,   output reg [NUM_PORTS-1:0] DROPPED_OUTPUTS_OUT
                       // When high, the above signals contain a packet which
                       // was dropped for a single cycle (i.e. no rdy signal!)
                   ,   output reg DROPPED_VLD_OUT
                   );

genvar i;


// Since the ready signal on the input necessarily lags one cycle behind the
// output readiness signals, the below data path is used to 'park' incoming
// values when a desired output is blocked.
//
//                         park_i             parked_i
//                            |                  |
//                            | ,---,            |
//                            +-|En |        ,---+
//                         ,--(-|D Q|----,  |\   |
//                         |  | |>  |    '--|1|  |
//                         |  | '---'       | |--)--- data_i
//           IN_DATA_IN  --+--(-------------|0|  |
//                            |             |/   |
//                            | ,---,            |
//                            '-|En |        ,---+
//                         ,----|D Q|----,  |\   |
//                         |    |>  |    '--|1|  |
//                         |    '---'       | |--)--- output_select_i
//  IN_OUTPUT_SELECT_IN  --+----------------|0|  |
//                                          |/   |
//                               -+-         ,---'
//                                |         |\
//                                '---------|1|
//                                          | |------ vld_i
//            IN_VLD_IN  -------------------|0|
//                                          |/
//
//           IN_RDY_OUT  -------------- (inputstate_i == RUN)
//
// The output ports and packet dropping port but not sketched here since they
// are straight forward.


////////////////////////////////////////////////////////////////////////////////
// Control
////////////////////////////////////////////////////////////////////////////////

// Input parking FSM states and state register
localparam RUN    = 1'b0;
localparam PARKED = 1'b1;
reg inputstate_i;

// Parked input registers
reg [PKT_BITS-1:0]  parked_data_i;
reg [NUM_PORTS-1:0] parked_output_select_i;

// The current input value to be dealt with (either parked or coming in this
// cycle)
wire [PKT_BITS-1:0]  data_i          = (inputstate_i == PARKED) ? parked_data_i          : IN_DATA_IN;
wire [NUM_PORTS-1:0] output_select_i = (inputstate_i == PARKED) ? parked_output_select_i : IN_OUTPUT_SELECT_IN;
wire                 vld_i           = (inputstate_i == PARKED) ? 1'b1                   : IN_VLD_IN;

// One signal per output, indicates if the output is NOT able to transmit a new
// value next cycle, i.e. the value must wait.
wire [NUM_PORTS-1:0] wait_i = OUT_VLD_OUT & ~OUT_RDY_IN;

// One signal per output, indicates that a value being transferred this cycle.
wire [NUM_PORTS-1:0] transfer_i = OUT_VLD_OUT & OUT_RDY_IN;

// Accumulate the set of output ports which have already latched the current
// packet.
reg [NUM_PORTS-1:0] accepted_outputs_i;

// Signal asserted whenever the current packet has been transmitted to all
// destinations (or dropped).
wire sent_i = ( !(|( (wait_i & ~accepted_outputs_i) // No blocked & unsent outputs...
                   & output_select_i))              // ...for this packet...
              | DROP_IN)                            // ...or we are dropping...
            & vld_i;                                // ...if there is a packet.

// Signal which is high whenever the current value being received must be parked
// due to a required output being blocked.
wire park_i = IN_RDY_OUT && IN_VLD_IN && |(wait_i & output_select_i);

// Ready to accept a new value whenever we're not parked.
assign IN_RDY_OUT = inputstate_i == RUN;

// Signal for each output which indicates if the current input value should be
// forwarded to this output this cycle.
wire [NUM_PORTS-1:0] send_now_i = {NUM_PORTS{vld_i}}   // There is a packet to send...
                                & ~accepted_outputs_i  // ...and not already sent.
                                & output_select_i      // ...to this output...
                                & ~wait_i              // ...which is not blocked...
                                ;

// Blocked ports are just those the current output is waiting for (or all zeros
// when no packet is being sent).
assign BLOCKED_OUTPUTS_OUT = vld_i ? (output_select_i & wait_i & ~accepted_outputs_i)
                                   : {NUM_PORTS{1'b0}};

// Just the current packet's selected outputs
assign SELECTED_OUTPUTS_OUT = output_select_i;


////////////////////////////////////////////////////////////////////////////////
// Input parking state-machine
////////////////////////////////////////////////////////////////////////////////

//              park_i
//             ,-------,
//             |       V
//        ,-----,     ,--------,
//   ---> | RUN |     | PARKED |
//        '-----'     '--------'
//              ^      |
//              '------'
//               sent_i

always @ (posedge CLK_IN, posedge RESET_IN)
	if (RESET_IN)
		inputstate_i <= RUN;
	else
		case (inputstate_i)
			RUN:    if (park_i) inputstate_i <= PARKED;
			PARKED: if (sent_i) inputstate_i <= RUN;
		endcase


always @ (posedge CLK_IN, posedge RESET_IN)
	if (RESET_IN)
		begin
			parked_data_i          <= {PKT_BITS{1'bX}};
			parked_output_select_i <= {NUM_PORTS{1'bX}};
		end
	else if (park_i)
		begin
			parked_data_i          <= IN_DATA_IN;
			parked_output_select_i <= IN_OUTPUT_SELECT_IN;
		end


////////////////////////////////////////////////////////////////////////////////
// Accumulate output ports which have accepted the current packet.
////////////////////////////////////////////////////////////////////////////////

always @ (posedge CLK_IN, posedge RESET_IN)
	if (RESET_IN)
		accepted_outputs_i <= {NUM_PORTS{1'b0}};
	else
		// Reset whenever a packet has been completely sent
		if (sent_i)
			accepted_outputs_i <= {NUM_PORTS{1'b0}};
		// Otherwise, accumulate whichever outputs aren't blocked while we have a
		// valid packet to sent
		else if (vld_i)
			accepted_outputs_i <= accepted_outputs_i | ~wait_i;


////////////////////////////////////////////////////////////////////////////////
// Forward input to outputs as soon as possible.
////////////////////////////////////////////////////////////////////////////////

generate for (i = 0; i < NUM_PORTS; i = i + 1)
	begin : output_registers
		
		always @ (posedge CLK_IN, posedge RESET_IN)
			if (RESET_IN)
				begin
					OUT_DATA_OUT[PKT_BITS*i+:PKT_BITS] <= {PKT_BITS{1'bX}};
					OUT_VLD_OUT[i] <= 1'b0;
				end
			else
				// Become valid when new data is due to be sent to this output,
				// otherwise become invalid once the transfer occurs.
				if (send_now_i[i])
					begin
						OUT_DATA_OUT[PKT_BITS*i+:PKT_BITS] <= data_i;
						OUT_VLD_OUT[i] <= 1'b1;
					end
				else if (transfer_i[i])
					begin
						OUT_DATA_OUT[PKT_BITS*i+:PKT_BITS] <= {PKT_BITS{1'bX}};
						OUT_VLD_OUT[i] <= 1'b0;
					end
	
	end
endgenerate


////////////////////////////////////////////////////////////////////////////////
// Packet dropping port
////////////////////////////////////////////////////////////////////////////////

always @ (posedge CLK_IN, posedge RESET_IN)
	if (RESET_IN)
		begin
			DROPPED_DATA_OUT    <= {PKT_BITS{1'bX}};
			DROPPED_OUTPUTS_OUT <= {NUM_PORTS{1'bX}};
			DROPPED_VLD_OUT     <= 1'b0;
		end
	else
		if (DROP_IN || (output_select_i == {NUM_PORTS{1'b0}} && vld_i))
			begin
				DROPPED_DATA_OUT    <= data_i;
				DROPPED_OUTPUTS_OUT <= wait_i & ~accepted_outputs_i & output_select_i;
				DROPPED_VLD_OUT     <= 1'b1;
			end
		else
			begin
				DROPPED_DATA_OUT    <= {PKT_BITS{1'bX}};
				DROPPED_OUTPUTS_OUT <= {NUM_PORTS{1'bX}};
				DROPPED_VLD_OUT     <= 1'b0;
			end


endmodule
