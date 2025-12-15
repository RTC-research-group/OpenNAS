--------------------------------------------------------------------------------
-- sim_tf.vhd
--
-- Version: USB3
-- Language: VHDL
--
-- A test fixture example that illustrates how to simulate FrontPanel
-- designs.
--
--------------------------------------------------------------------------------
-- Copyright (c) 2005-2014 Opal Kelly Incorporated
-- $Rev: 0 $ $Date: 2014-12-4 16:07:50 -0700 (Thur, 4 Dec 2014) $
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;           -- @suppress "Deprecated package"
use IEEE.std_logic_unsigned.all;        -- @suppress "Deprecated package"
use IEEE.std_logic_textio.all;
USE ieee.numeric_std.ALL;
use work.FRONTPANEL.all;
use work.okt_top_pkg.all;
use work.okt_global_pkg.all;
use work.okt_imu_pkg.all;

use std.textio.all;

use work.mappings.all;
use work.parameters.all;

entity okt_top_tb is
end okt_top_tb;

architecture simulate of okt_top_tb is

	signal leds : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0); -- @suppress "signal leds is never read"

	-- FrontPanel Host --------------------------------------------------------------------------

	signal okUH  : std_logic_vector(4 downto 0) := b"00000";
	signal okHU  : std_logic_vector(2 downto 0);
	signal okUHU : std_logic_vector(31 downto 0);
	signal okAA  : std_logic;

	---------------------------------------------------------------------------------------------

	-- okHostCalls Simulation Parameters & Signals ----------------------------------------------
	constant tCK      : time := 5 ns;   --Half of the hi_clk frequency @ 1ns timing = 100MHz
	constant Tsys_clk : time := 5 ns;   --Half of the hi_clk frequency @ 1ns timing = 100MHz

	signal hi_clk     : std_logic;
	signal hi_drive   : std_logic                     := '0';
	signal hi_cmd     : std_logic_vector(2 downto 0)  := "000";
	signal hi_busy    : std_logic;
	signal hi_datain  : std_logic_vector(31 downto 0) := x"00000000";
	signal hi_dataout : std_logic_vector(31 downto 0) := x"00000000";

	signal sys_clkp : std_logic;        -- @suppress "signal sys_clkp is never read"
	signal sys_clkn : std_logic;        -- @suppress "signal sys_clkn is never read"

	-- Clocks
	signal sys_clk : std_logic := '0';  -- @suppress "signal sys_clk is never read"

	-- Reset
	signal rst, rst_n : std_logic;

	-- Input signals
	signal rome_a_data  : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal rome_a_req_n : std_logic;
	signal rome_a_ack_n : std_logic;
	signal rome_b_data  : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal rome_b_req_n : std_logic;
	signal rome_b_ack_n : std_logic;
	signal node_data    : std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
	signal node_req_n   : std_logic;
	signal node_ack_n   : std_logic;

	-- Output signals
	signal out_data  : std_logic_vector(OUT_DATA_BITS_WIDTH - 1 downto 0); -- @suppress "signal out_data is never read"
	signal out_req_n : std_logic;
	signal out_ack_n : std_logic;

	signal cuenta : std_logic_vector(7 downto 0);

	type state is (idle, req_fall, req_rise);
	signal current_state_rome_a, next_state_rome_a : state;
	signal current_state_rome_b, next_state_rome_b : state;
	signal current_state_node, next_state_node     : state;

	type state_handshake is (idle, req_fall, delay1, delay2);
	signal current_state_out, next_state_out : state_handshake;

	---------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------
	-- Begin functional body
	--------------------------------------------------------------------------
begin

	rst_n <= not rst;
	okt_u : entity work.okt_top
		port map(
			rst_ext_n    => rst,
			okUH         => okUH,
			okHU         => okHU,
			okUHU        => okUHU,
			okAA         => okAA,
			port_a_data  => rome_a_data,
			port_a_req_n => rome_a_req_n,
			port_a_ack_n => rome_a_ack_n,
			port_b_data  => rome_b_data,
			port_b_req_n => rome_b_req_n,
			port_b_ack_n => rome_b_ack_n,
			port_c_data  => node_data,
			port_c_req_n => node_req_n,
			port_c_ack_n => node_ack_n,
			out_data     => out_data,
			out_req_n    => out_req_n,
			out_ack_n    => out_ack_n,
			leds         => leds
		);

	-- okHostCalls Simulation okHostCall<->okHost Mapping  --------------------------------------
	okUH(0)          <= hi_clk;
	okUH(1)          <= hi_drive;
	okUH(4 downto 2) <= hi_cmd;
	hi_datain        <= okUHU;
	hi_busy          <= okHU(0);
	okUHU            <= hi_dataout when (hi_drive = '1') else (others => 'Z');

	--	rome_a_data <= out_data(ROME_DATA_BITS_WIDTH -1 downto 0);
	--	rome_a_req_n <= out_req_n;
	--	out_ack_n <= rome_a_ack_n;
	---------------------------------------------------------------------------------------------

	-- Clock Generation
	hi_clk_gen : process is
	begin
		hi_clk <= '0';
		wait for tCK;
		hi_clk <= '1';
		wait for tCK;
	end process hi_clk_gen;

	sys_clk_gen : process is
	begin
		sys_clk  <= '0';
		sys_clkp <= '0';
		sys_clkn <= '1';
		wait for Tsys_clk;
		sys_clk  <= '1';
		sys_clkp <= '1';
		sys_clkn <= '0';
		wait for Tsys_clk;
	end process sys_clk_gen;

	-- Simulation Process
	sim_process : process is
		--<<<<<<<<<<<<<<<<<<< OKHOSTCALLS START PASTE HERE >>>>>>>>>>>>>>>>>>>>-- 

		-----------------------------------------------------------------------
		-- User defined data for pipe and register procedures
		-----------------------------------------------------------------------
		variable BlockDelayStates : integer := 5; -- REQUIRED: # of clocks between blocks of pipe data
		variable ReadyCheckDelay  : integer := 5; -- REQUIRED: # of clocks before block transfer before
		                                          --    host interface checks for ready (0-255)
		variable PostReadyDelay   : integer := 5; -- REQUIRED: # of clocks after ready is asserted and
		                                          --    check that the block transfer begins (0-255)
		variable pipeInSize       : integer := 4 * 1024; -- REQUIRED: byte (must be even) length of default
		--    PipeIn; Integer 0-2^32
		variable pipeOutSize      : integer := 4 * 1024; -- REQUIRED: byte (must be even) length of default
		--    PipeOut; Integer 0-2^32
		variable registerSetSize  : integer := 32; -- Size of array for register set commands.

		-----------------------------------------------------------------------
		-- Required data for procedures and functions
		-----------------------------------------------------------------------
		-- If you require multiple pipe arrays, you may create more arrays here
		-- duplicate the desired pipe procedures as required, change the names
		-- of the duplicated procedure to a unique identifiers, and alter the
		-- pipe array in that procedure to your newly generated arrays here.
		type PIPEIN_ARRAY is array (0 to pipeInSize - 1) of std_logic_vector(7 downto 0);
		variable pipeIn : PIPEIN_ARRAY;

		type PIPEOUT_ARRAY is array (0 to pipeOutSize - 1) of std_logic_vector(7 downto 0);
		variable pipeOut : PIPEOUT_ARRAY;

		type STD_ARRAY is array (0 to 31) of std_logic_vector(31 downto 0);
		variable WireIns   : STD_ARRAY; -- 32x32 array storing WireIn values
		variable WireOuts  : STD_ARRAY; -- 32x32 array storing WireOut values 
		variable Triggered : STD_ARRAY; -- 32x32 array storing IsTriggered values

		type REGISTER_ARRAY is array (0 to registerSetSize - 1) of std_logic_vector(31 downto 0);
		variable u32Address       : REGISTER_ARRAY;
		variable u32Data          : REGISTER_ARRAY;
		variable u32Count         : std_logic_vector(31 downto 0);
		variable ReadRegisterData : std_logic_vector(31 downto 0);

		constant DNOP                  : std_logic_vector(2 downto 0) := "000";
		constant DReset                : std_logic_vector(2 downto 0) := "001";
		constant DWires                : std_logic_vector(2 downto 0) := "010";
		constant DUpdateWireIns        : std_logic_vector(2 downto 0) := "001";
		constant DUpdateWireOuts       : std_logic_vector(2 downto 0) := "010";
		constant DTriggers             : std_logic_vector(2 downto 0) := "011";
		constant DActivateTriggerIn    : std_logic_vector(2 downto 0) := "001";
		constant DUpdateTriggerOuts    : std_logic_vector(2 downto 0) := "010";
		constant DPipes                : std_logic_vector(2 downto 0) := "100";
		constant DWriteToPipeIn        : std_logic_vector(2 downto 0) := "001";
		constant DReadFromPipeOut      : std_logic_vector(2 downto 0) := "010";
		constant DWriteToBlockPipeIn   : std_logic_vector(2 downto 0) := "011";
		constant DReadFromBlockPipeOut : std_logic_vector(2 downto 0) := "100";
		constant DRegisters            : std_logic_vector(2 downto 0) := "101";
		constant DWriteRegister        : std_logic_vector(2 downto 0) := "001";
		constant DReadRegister         : std_logic_vector(2 downto 0) := "010";
		constant DWriteRegisterSet     : std_logic_vector(2 downto 0) := "011";
		constant DReadRegisterSet      : std_logic_vector(2 downto 0) := "100";

		-----------------------------------------------------------------------
		-- FrontPanelReset
		-----------------------------------------------------------------------
		procedure FrontPanelReset is
			variable i        : integer := 0;
			variable msg_line : line;
		begin
			for i in 31 downto 0 loop
				WireIns(i)   := (others => '0');
				WireOuts(i)  := (others => '0');
				Triggered(i) := (others => '0');
			end loop;
			wait until (rising_edge(hi_clk));
			hi_cmd <= DReset;
			rst    <= '1';
			wait until (rising_edge(hi_clk));
			hi_cmd <= DNOP;
			rst    <= '0';
			wait until (hi_busy = '0');
		end procedure FrontPanelReset;

		-----------------------------------------------------------------------
		-- SetWireInValue
		-----------------------------------------------------------------------
		procedure SetWireInValue(
			ep   : in std_logic_vector(7 downto 0);
			val  : in std_logic_vector(31 downto 0);
			mask : in std_logic_vector(31 downto 0)) is

			variable tmp_slv32 : std_logic_vector(31 downto 0);
			variable tmpI      : integer;
		begin
			tmpI          := CONV_INTEGER(ep);
			tmp_slv32     := WireIns(tmpI) and (not mask);
			WireIns(tmpI) := (tmp_slv32 or (val and mask));
		end procedure SetWireInValue;

		-----------------------------------------------------------------------
		-- GetWireOutValue
		-----------------------------------------------------------------------
		impure function GetWireOutValue(
			ep : std_logic_vector) return std_logic_vector is

			variable tmp_slv32 : std_logic_vector(31 downto 0);
			variable tmpI      : integer;
		begin
			tmpI      := CONV_INTEGER(ep);
			tmp_slv32 := WireOuts(tmpI - 16#20#);
			return (tmp_slv32);
		end GetWireOutValue;

		-----------------------------------------------------------------------
		-- IsTriggered
		-----------------------------------------------------------------------
		impure function IsTriggered(
			ep   : std_logic_vector;
			mask : std_logic_vector(31 downto 0)) return BOOLEAN is

			variable tmp_slv32 : std_logic_vector(31 downto 0);
			variable tmpI      : integer;
			variable msg_line  : line;
		begin
			tmpI      := CONV_INTEGER(ep);
			tmp_slv32 := (Triggered(tmpI - 16#60#) and mask);

			if (tmp_slv32 >= 0) then
				if (tmp_slv32 = 0) then
					return FALSE;
				else
					return TRUE;
				end if;
			else
				write(msg_line, STRING'("***FRONTPANEL ERROR: IsTriggered mask 0x"));
				hwrite(msg_line, mask);
				write(msg_line, STRING'(" covers unused Triggers"));
				writeline(output, msg_line);
				return FALSE;
			end if;
		end IsTriggered;

		-----------------------------------------------------------------------
		-- UpdateWireIns
		-----------------------------------------------------------------------
		procedure UpdateWireIns is
			variable i : integer := 0;
		begin
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DWires;
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DUpdateWireIns;
			wait until (rising_edge(hi_clk));
			hi_drive <= '1';
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DNOP;
			for i in 0 to 31 loop
				hi_dataout <= WireIns(i);
				wait until (rising_edge(hi_clk));
			end loop;
			wait until (hi_busy = '0');
		end procedure UpdateWireIns;

		-----------------------------------------------------------------------
		-- UpdateWireOuts
		-----------------------------------------------------------------------
		procedure UpdateWireOuts is
			variable i : integer := 0;
		begin
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DWires;
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DUpdateWireOuts;
			wait until (rising_edge(hi_clk));
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_drive <= '0';
			wait until (rising_edge(hi_clk));
			wait until (rising_edge(hi_clk));
			for i in 0 to 31 loop
				wait until (rising_edge(hi_clk));
				WireOuts(i) := hi_datain;
			end loop;
			wait until (hi_busy = '0');
		end procedure UpdateWireOuts;

		-----------------------------------------------------------------------
		-- ActivateTriggerIn
		-----------------------------------------------------------------------
		procedure ActivateTriggerIn(
			ep  : in std_logic_vector(7 downto 0);
			bit : in integer) is

			variable tmp_slv5 : std_logic_vector(4 downto 0);
		begin
			tmp_slv5   := CONV_std_logic_vector(bit, 5);
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DTriggers;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DActivateTriggerIn;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_dataout <= (x"000000" & ep);
			wait until (rising_edge(hi_clk));
			hi_dataout <= SHL(x"00000001", tmp_slv5);
			hi_cmd     <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_dataout <= x"00000000";
			wait until (hi_busy = '0');
		end procedure ActivateTriggerIn;

		-----------------------------------------------------------------------
		-- UpdateTriggerOuts
		-----------------------------------------------------------------------
		procedure UpdateTriggerOuts is
		begin
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DTriggers;
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DUpdateTriggerOuts;
			wait until (rising_edge(hi_clk));
			wait until (rising_edge(hi_clk));
			hi_cmd   <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_drive <= '0';
			wait until (rising_edge(hi_clk));
			wait until (rising_edge(hi_clk));
			wait until (rising_edge(hi_clk));

			for i in 0 to (UPDATE_TO_READOUT_CLOCKS - 1) loop
				wait until (rising_edge(hi_clk));
			end loop;

			for i in 0 to 31 loop
				wait until (rising_edge(hi_clk));
				Triggered(i) := hi_datain;
			end loop;
			wait until (hi_busy = '0');
		end procedure UpdateTriggerOuts;

		-----------------------------------------------------------------------
		-- WriteToPipeIn
		-----------------------------------------------------------------------
		procedure WriteToPipeIn(
			ep     : in std_logic_vector(7 downto 0);
			length : in integer) is

			variable len, i, j, k, blockSize : integer;
			variable tmp_slv8                : std_logic_vector(7 downto 0);
			variable tmp_slv32               : std_logic_vector(31 downto 0);
		begin
			len       := (length / 4);
			j         := 0;
			k         := 0;
			blockSize := 1024;
			tmp_slv8  := CONV_std_logic_vector(BlockDelayStates, 8);
			tmp_slv32 := CONV_std_logic_vector(len, 32);

			wait until (rising_edge(hi_clk));
			hi_cmd     <= DPipes;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DWriteToPipeIn;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_dataout <= (x"0000" & tmp_slv8 & ep);
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DNOP;
			hi_dataout <= tmp_slv32;
			for i in 0 to len - 1 loop
				wait until (rising_edge(hi_clk));
				hi_dataout(7 downto 0)   <= pipeIn(i * 4);
				hi_dataout(15 downto 8)  <= pipeIn((i * 4) + 1);
				hi_dataout(23 downto 16) <= pipeIn((i * 4) + 2);
				hi_dataout(31 downto 24) <= pipeIn((i * 4) + 3);
				j                        := j + 4;
				if (j = blockSize) then
					for k in 0 to BlockDelayStates - 1 loop
						wait until (rising_edge(hi_clk));
					end loop;
					j := 0;
				end if;
			end loop;
			wait until (hi_busy = '0');
		end procedure WriteToPipeIn;

		-----------------------------------------------------------------------
		-- ReadFromPipeOut
		-----------------------------------------------------------------------
		procedure ReadFromPipeOut(
			ep     : in std_logic_vector(7 downto 0);
			length : in integer) is

			variable len, i, j, k, blockSize : integer;
			variable tmp_slv8                : std_logic_vector(7 downto 0);
			variable tmp_slv32               : std_logic_vector(31 downto 0);
		begin
			len       := (length / 4);
			j         := 0;
			blockSize := 1024;
			tmp_slv8  := CONV_std_logic_vector(BlockDelayStates, 8);
			tmp_slv32 := CONV_std_logic_vector(len, 32);

			wait until (rising_edge(hi_clk));
			hi_cmd     <= DPipes;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DReadFromPipeOut;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_dataout <= (x"0000" & tmp_slv8 & ep);
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DNOP;
			hi_dataout <= tmp_slv32;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '0';
			for i in 0 to len - 1 loop
				wait until (rising_edge(hi_clk));
				pipeOut(i * 4)       := hi_datain(7 downto 0);
				pipeOut((i * 4) + 1) := hi_datain(15 downto 8);
				pipeOut((i * 4) + 2) := hi_datain(23 downto 16);
				pipeOut((i * 4) + 3) := hi_datain(31 downto 24);
				j                    := j + 4;
				if (j = blockSize) then
					for k in 0 to BlockDelayStates - 1 loop
						wait until (rising_edge(hi_clk));
					end loop;
					j := 0;
				end if;
			end loop;
			wait until (hi_busy = '0');
		end procedure ReadFromPipeOut;

		-----------------------------------------------------------------------
		-- WriteToBlockPipeIn
		-----------------------------------------------------------------------
		procedure WriteToBlockPipeIn(
			ep          : in std_logic_vector(7 downto 0);
			blockLength : in integer;
			length      : in integer) is

			variable len, i, j, k, blockSize, blockNum : integer;
			variable tmp_slv8                          : std_logic_vector(7 downto 0);
			variable tmp_slv16                         : std_logic_vector(15 downto 0);
			variable tmp_slv32                         : std_logic_vector(31 downto 0);
		begin
			len       := (length / 4);
			blockSize := (blockLength / 4);
			j         := 0;
			k         := 0;
			blockNum  := (len / blockSize);
			tmp_slv8  := CONV_std_logic_vector(BlockDelayStates, 8);
			tmp_slv16 := CONV_std_logic_vector(blockSize, 16);
			tmp_slv32 := CONV_std_logic_vector(len, 32);

			wait until (rising_edge(hi_clk));
			hi_cmd     <= DPipes;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DWriteToBlockPipeIn;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_dataout <= (x"0000" & tmp_slv8 & ep);
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DNOP;
			hi_dataout <= tmp_slv32;
			wait until (rising_edge(hi_clk));
			hi_dataout <= x"0000" & tmp_slv16;
			wait until (rising_edge(hi_clk));
			tmp_slv16  := (CONV_std_logic_vector(PostReadyDelay, 8) & CONV_std_logic_vector(ReadyCheckDelay, 8));
			hi_dataout <= x"0000" & tmp_slv16;
			for i in 1 to blockNum loop
				while (hi_busy = '1') loop
					wait until (rising_edge(hi_clk));
				end loop;
				while (hi_busy = '0') loop
					wait until (rising_edge(hi_clk));
				end loop;
				wait until (rising_edge(hi_clk));
				wait until (rising_edge(hi_clk));
				for j in 1 to blockSize loop
					hi_dataout(7 downto 0)   <= pipeIn(k);
					hi_dataout(15 downto 8)  <= pipeIn(k + 1);
					hi_dataout(23 downto 16) <= pipeIn(k + 2);
					hi_dataout(31 downto 24) <= pipeIn(k + 3);
					wait until (rising_edge(hi_clk));
					k                        := k + 4;
				end loop;
				for j in 1 to BlockDelayStates loop
					wait until (rising_edge(hi_clk));
				end loop;
			end loop;
			wait until (hi_busy = '0');
		end procedure WriteToBlockPipeIn;

		-----------------------------------------------------------------------
		-- ReadFromBlockPipeOut
		-----------------------------------------------------------------------
		procedure ReadFromBlockPipeOut(
			ep          : in std_logic_vector(7 downto 0);
			blockLength : in integer;
			length      : in integer) is

			variable len, i, j, k, blockSize, blockNum : integer;
			variable tmp_slv8                          : std_logic_vector(7 downto 0);
			variable tmp_slv16                         : std_logic_vector(15 downto 0);
			variable tmp_slv32                         : std_logic_vector(31 downto 0);
		begin
			len       := (length / 4);
			blockSize := (blockLength / 4);
			j         := 0;
			k         := 0;
			blockNum  := (len / blockSize);
			tmp_slv8  := CONV_std_logic_vector(BlockDelayStates, 8);
			tmp_slv16 := CONV_std_logic_vector(blockSize, 16);
			tmp_slv32 := CONV_std_logic_vector(len, 32);

			wait until (rising_edge(hi_clk));
			hi_cmd     <= DPipes;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DReadFromBlockPipeOut;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_dataout <= (x"0000" & tmp_slv8 & ep);
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DNOP;
			hi_dataout <= tmp_slv32;
			wait until (rising_edge(hi_clk));
			hi_dataout <= x"0000" & tmp_slv16;
			wait until (rising_edge(hi_clk));
			tmp_slv16  := (CONV_std_logic_vector(PostReadyDelay, 8) & CONV_std_logic_vector(ReadyCheckDelay, 8));
			hi_dataout <= x"0000" & tmp_slv16;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '0';
			for i in 1 to blockNum loop
				while (hi_busy = '1') loop
					wait until (rising_edge(hi_clk));
				end loop;
				while (hi_busy = '0') loop
					wait until (rising_edge(hi_clk));
				end loop;
				wait until (rising_edge(hi_clk));
				wait until (rising_edge(hi_clk));
				for j in 1 to blockSize loop
					pipeOut(k)     := hi_datain(7 downto 0);
					pipeOut(k + 1) := hi_datain(15 downto 8);
					pipeOut(k + 2) := hi_datain(23 downto 16);
					pipeOut(k + 3) := hi_datain(31 downto 24);
					wait until (rising_edge(hi_clk));
					k              := k + 4;
				end loop;
				for j in 1 to BlockDelayStates loop
					wait until (rising_edge(hi_clk));
				end loop;
			end loop;
			wait until (hi_busy = '0');
		end procedure ReadFromBlockPipeOut;

		-----------------------------------------------------------------------
		-- WriteRegister
		-----------------------------------------------------------------------
		procedure WriteRegister(
			address : in std_logic_vector(31 downto 0);
			data    : in std_logic_vector(31 downto 0)) is
		begin
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DRegisters;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DWriteRegister;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_cmd     <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_dataout <= address;
			wait until (rising_edge(hi_clk));
			hi_dataout <= data;
			wait until (hi_busy = '0');
			hi_drive   <= '0';
		end procedure WriteRegister;

		-----------------------------------------------------------------------
		-- ReadRegister
		-----------------------------------------------------------------------
		procedure ReadRegister(
			address : in std_logic_vector(31 downto 0);
			data    : out std_logic_vector(31 downto 0)) is
		begin
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DRegisters;
			wait until (rising_edge(hi_clk));
			hi_cmd     <= DReadRegister;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '1';
			hi_cmd     <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_dataout <= address;
			wait until (rising_edge(hi_clk));
			hi_drive   <= '0';
			wait until (rising_edge(hi_clk));
			wait until (rising_edge(hi_clk));
			data       := hi_datain;
			wait until (hi_busy = '0');
		end procedure ReadRegister;

		-----------------------------------------------------------------------
		-- WriteRegisterSet
		-----------------------------------------------------------------------
		procedure WriteRegisterSet is
			variable i            : integer;
			variable u32Count_int : integer;
		begin
			u32Count_int := CONV_INTEGER(u32Count);
			wait until (rising_edge(hi_clk));
			hi_cmd       <= DRegisters;
			wait until (rising_edge(hi_clk));
			hi_cmd       <= DWriteRegisterSet;
			wait until (rising_edge(hi_clk));
			hi_drive     <= '1';
			hi_cmd       <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_dataout   <= u32Count;
			for i in 1 to u32Count_int loop
				wait until (rising_edge(hi_clk));
				hi_dataout <= u32Address(i - 1);
				wait until (rising_edge(hi_clk));
				hi_dataout <= u32Data(i - 1);
				wait until (rising_edge(hi_clk));
				wait until (rising_edge(hi_clk));
			end loop;
			wait until (hi_busy = '0');
			hi_drive     <= '0';
		end procedure WriteRegisterSet;

		-----------------------------------------------------------------------
		-- ReadRegisterSet
		-----------------------------------------------------------------------
		procedure ReadRegisterSet is
			variable i            : integer;
			variable u32Count_int : integer;
		begin
			u32Count_int := CONV_INTEGER(u32Count);
			wait until (rising_edge(hi_clk));
			hi_cmd       <= DRegisters;
			wait until (rising_edge(hi_clk));
			hi_cmd       <= DReadRegisterSet;
			wait until (rising_edge(hi_clk));
			hi_drive     <= '1';
			hi_cmd       <= DNOP;
			wait until (rising_edge(hi_clk));
			hi_dataout   <= u32Count;
			for i in 1 to u32Count_int loop
				wait until (rising_edge(hi_clk));
				hi_dataout     <= u32Address(i - 1);
				wait until (rising_edge(hi_clk));
				hi_drive       <= '0';
				wait until (rising_edge(hi_clk));
				wait until (rising_edge(hi_clk));
				u32Data(i - 1) := hi_datain;
				hi_drive       <= '1';
			end loop;
			wait until (hi_busy = '0');
		end procedure ReadRegisterSet;

		-----------------------------------------------------------------------
		-- Available User Task and Function Calls:
		--    FrontPanelReset;              -- Always start routine with FrontPanelReset;
		--    SetWireInValue(ep, val, mask);
		--    UpdateWireIns;
		--    UpdateWireOuts;
		--    GetWireOutValue(ep);          -- returns a 16 bit SLV
		--    ActivateTriggerIn(ep, bit);   -- bit is an integer 0-15
		--    UpdateTriggerOuts;
		--    IsTriggered(ep, mask);        -- returns a BOOLEAN
		--    WriteToPipeIn(ep, length);    -- pass pipeIn array data; length is integer
		--    ReadFromPipeOut(ep, length);  -- pass data to pipeOut array; length is integer
		--    WriteToBlockPipeIn(ep, blockSize, length);   -- pass pipeIn array data; blockSize and length are integers
		--    ReadFromBlockPipeOut(ep, blockSize, length); -- pass data to pipeOut array; blockSize and length are integers
		--    WriteRegister(addr, data);  
		--    ReadRegister(addr, data);
		--    WriteRegisterSet();  
		--    ReadRegisterSet();
		--
		-- *  Pipes operate by passing arrays of data back and forth to the user's
		--    design.  If you need multiple arrays, you can create a new procedure
		--    above and connect it to a differnet array.  More information is
		--    available in Opal Kelly documentation and online support tutorial.
		-----------------------------------------------------------------------

		--<<<<<<<<<<<<<<<<<<< OKHOSTCALLS END PASTE HERE >>>>>>>>>>>>>>>>>>>>>>--

		variable NO_MASK : std_logic_vector(31 downto 0) := x"ffff_ffff";

		variable msg_line       : line; -- type defined in textio.vhd
		variable i              : integer;
		variable j              : natural;
		variable ReadPipe       : PIPEOUT_ARRAY;
		variable WritePipe      : PIPEIN_ARRAY;
		variable num_write_line : integer := 0;

		---------------------------------------------------------------------------------
		-- Select okaertool input
		-- Set the WireIn 0x01 value. To enable each input set the corresponding WireIn bit
		-- Example:
		-- Enable Input0 --> WireIn value = x"0000_0001" (Value expressed in hex)
		-- Enable Input1 --> WireIn value = x"0000_0002"
		-- Enable Input 0 and Input1 --> WireIn value = x"0000_0003"
		-- Disable ALL inputs --> WireIn value = x"0000_0000"
		---------------------------------------------------------------------------------
		procedure select_input(inputs : std_logic_vector(31 downto 0)) is
		begin
			SetWireInValue(x"01", inputs, NO_MASK);
			UpdateWireIns;
		end procedure select_input;

		--------------------------------------------------------------------------------------
		-- Select okaertool command
		-- Set the WireIn 0x00 value. To enable each command set the corresponding WireIn bit
		-- Example:
		-- Enable ECU --> WireIn value = x"0000_0001" (Value in hex)
		-- Disable ALL commands --> WireIn value = x"0000_0000"
		--------------------------------------------------------------------------------------
		procedure select_command(commands : std_logic_vector(31 downto 0)) is
		begin
			SetWireInValue(x"00", commands, NO_MASK);
			UpdateWireIns;
		end procedure select_command;

		--------------------------------------------------------------------------------------
		-- Check data read from the USB (PipeOut)
		-- The read data will be printed out to check if the content is right
		--------------------------------------------------------------------------------------
		procedure read_USB_data(num_USB_transfers : integer) is
		begin
			write(msg_line, STRING'("Reading values from USB pipe A0: "));
			writeline(output, msg_line);
			i := 0;
			while i < num_USB_transfers loop
				-- Read values
				ReadFromBlockPipeOut(x"a0", 1024, pipeOutSize);

				j := 0;
				while j < pipeOutSize loop
					-- Timestamp
					ReadPipe(j)     := pipeOut(j);
					ReadPipe(j + 1) := pipeOut(j + 1);
					ReadPipe(j + 2) := pipeOut(j + 2);
					ReadPipe(j + 3) := pipeOut(j + 3);
					write(msg_line, INTEGER'(num_write_line));
					write(msg_line, STRING'(" Ts: 0x"));
					hwrite(msg_line, STD_LOGIC_VECTOR'(ReadPipe(j + 3)) & STD_LOGIC_VECTOR'(ReadPipe(j + 2)));
					hwrite(msg_line, STD_LOGIC_VECTOR'(ReadPipe(j + 1)) & STD_LOGIC_VECTOR'(ReadPipe(j)));
					-- Event data
					ReadPipe(j + 4) := pipeOut(j + 4);
					ReadPipe(j + 5) := pipeOut(j + 5);
					ReadPipe(j + 6) := pipeOut(j + 6);
					ReadPipe(j + 7) := pipeOut(j + 7);
					write(msg_line, STRING'(" - Addr 0x"));
					hwrite(msg_line, STD_LOGIC_VECTOR'(ReadPipe(j + 7)) & STD_LOGIC_VECTOR'(ReadPipe(j + 6)));
					hwrite(msg_line, STD_LOGIC_VECTOR'(ReadPipe(j + 5)) & STD_LOGIC_VECTOR'(ReadPipe(j + 4)));

					writeline(output, msg_line);
					num_write_line := num_write_line + 1;
					j              := j + 8;
				end loop;
				i := i + 1;
			end loop;
		end procedure read_USB_data;

		--
		procedure write_USB_data(num_USB_transfers : integer) is
		begin
			write(msg_line, STRING'("Writing values into USB pipe 93: "));
			writeline(output, msg_line);
			i := 0;

			while i < num_USB_transfers loop
				--WriteToBlockPipeIn(x"93", 1024, pipeInSize);
				j := 0;
				while j < pipeInSize loop

					pipeIn(j + 0) := x"05";
					pipeIn(j + 1) := x"00";
					pipeIn(j + 2) := x"00";
					pipeIn(j + 3) := x"00";
					pipeIn(j + 4) := x"2F";
					pipeIn(j + 5) := x"2F";
					pipeIn(j + 6) := x"00";
					pipeIn(j + 7) := x"00";

					write(msg_line, INTEGER'(num_write_line));
					write(msg_line, STRING'(" Ts: 0x"));
					hwrite(msg_line, STD_LOGIC_VECTOR'(pipeIn(j + 3)) & STD_LOGIC_VECTOR'(pipeIn(j + 2)));
					hwrite(msg_line, STD_LOGIC_VECTOR'(pipeIn(j + 1)) & STD_LOGIC_VECTOR'(pipeIn(j)));
					write(msg_line, STRING'(" - Addr 0x"));
					hwrite(msg_line, STD_LOGIC_VECTOR'(pipeIn(j + 7)) & STD_LOGIC_VECTOR'(pipeIn(j + 6)));
					hwrite(msg_line, STD_LOGIC_VECTOR'(pipeIn(j + 5)) & STD_LOGIC_VECTOR'(pipeIn(j + 4)));
					writeline(output, msg_line);
					num_write_line := num_write_line + 1;
					j              := j + 8;
				end loop;
				WriteToBlockPipeIn(x"80", 1024, pipeInSize);
				i := i + 1;
			end loop;
		end procedure write_USB_data;

		--

		procedure send_sw_rst(rst_command : std_logic_vector(31 downto 0)) is
		begin
			SetWireInValue(x"02", rst_command, NO_MASK);
			UpdateWireIns;
		end procedure;

	begin
		FrontPanelReset;
		wait for 10 ns;
		select_command(x"0000_0000");
		select_input(x"0000_0000");
		wait for 10 ns;
		--select_input(x"0000_0001");
		--write_USB_data(1);
		--select_command(x"0000_0004"); 
		--write_USB_data(65);
		--read_USB_data(1024*8);
		--wait for 100 ns;
		--read_USB_data(1);
		--select_command(x"0000_0005"); 
		--wait for 100 ns;

		-- Select input 1 and 2

		--select_input(x"0000_0002");
		--wait for 10 ns;
		-- Check data
		--read_USB_data(10);
		--wait for 100 ns;

		-- Select input 3
		select_input(x"0000_0007");
		select_command(x"0000_0001");
		wait for 10 ns;
		-- Check data
		read_USB_data(16);

		wait;
	end process sim_process;

	signals_update : process(hi_clk, rst_n)
	begin
		if rst_n = '0' then
			current_state_rome_a <= idle;
			current_state_rome_b <= idle;
			current_state_node   <= idle;
			current_state_out    <= idle;

		elsif rising_edge(hi_clk) then
			current_state_rome_a <= next_state_rome_a;
			current_state_rome_b <= next_state_rome_b;
			current_state_node   <= next_state_node;
			current_state_out    <= next_state_out;

		end if;
	end process;

	FSM_transition : process(current_state_rome_a, rome_a_ack_n, current_state_rome_b, rome_b_ack_n, current_state_node, node_ack_n)
	begin
		next_state_rome_a <= current_state_rome_a;
		next_state_rome_b <= current_state_rome_b;
		next_state_node   <= current_state_node;

		rome_a_req_n <= '1';
		rome_b_req_n <= '1';
		node_req_n   <= '1';

		rome_a_data <= (others => '0');
		rome_b_data <= (others => '0');
		node_data   <= (others => '0');

		case current_state_rome_a is
			when idle =>
				if rome_a_ack_n = '1' then
					next_state_rome_a <= req_fall;
				end if;

			when req_fall =>
				rome_a_req_n <= '0';
				rome_a_data  <= std_logic_vector(to_unsigned(1, rome_a_data'length));
				if rome_a_ack_n = '0' then
					next_state_rome_a <= req_rise;
				end if;

			when req_rise =>
				rome_a_req_n      <= '1';
				next_state_rome_a <= idle;

		end case;

		case current_state_rome_b is
			when idle =>
				if rome_b_ack_n = '1' then
					next_state_rome_b <= req_fall;
				end if;

			when req_fall =>
				rome_b_req_n <= '0';
				rome_b_data  <= std_logic_vector(to_unsigned(2, rome_b_data'length));
				if rome_b_ack_n = '0' then
					next_state_rome_b <= req_rise;
				end if;

			when req_rise =>
				rome_b_req_n      <= '1';
				next_state_rome_b <= idle;

		end case;

		case current_state_node is
			when idle =>
				if node_ack_n = '1' then
					next_state_node <= req_fall;
				end if;

			when req_fall =>
				node_req_n <= '0';
				node_data  <= std_logic_vector(to_unsigned(3, node_data'length));
				if node_ack_n = '0' then
					next_state_node <= req_rise;
				end if;

			when req_rise =>
				node_req_n      <= '1';
				next_state_node <= idle;

		end case;
	end process;

	--	OUT_FSM_transitions : process(current_state_out, out_req_n)
	--	begin
	--		next_state_out <= current_state_out;
	--		out_ack_n      <= '1';
	--
	--		case current_state_out is
	--			when idle =>
	--				if (out_req_n = '0') then
	--					next_state_out <= req_fall;
	--				end if;
	--				
	--			when delay1 =>
	--				next_state_out <= delay2;
	--			
	--
	--			when req_fall =>
	--				out_ack_n <= '0';
	--				next_state_out <= delay2;
	--
	--			
	--			when delay2 =>
	--			out_ack_n <= '0';
	--			if (out_req_n = '1') then
	--				next_state_out <= idle;
	--				end if;
	--
	--		end case;
	--	end process;

end simulate;
