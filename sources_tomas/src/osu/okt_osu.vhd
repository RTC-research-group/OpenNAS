----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:02:24 03/20/2023 
-- Design Name: 
-- Module Name:    okt_osu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"
use ieee.numeric_std.all;
use work.okt_global_pkg.all;
use work.okt_fifo_pkg.all;
use work.okt_top_pkg.all;
use work.okt_cu_pkg.all;

entity okt_osu is                       -- Output Sequencer Unit
	Port(
		--System ports
		clk                : in  std_logic;
		rst_n              : in  std_logic;
		--MONITOR / PASS DATA IN
		aer_in_data        : in  std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		req_in_data_n      : in  std_logic;
		ecu_in_ack_n       : in  std_logic;
		--Command
		-- status             : out std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
		cmd                : in  std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);
		-- CU interface - SEQUENCER DATA IN (USB)
		in_data            : in  std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		in_wr              : in  std_logic;
		in_ready           : out std_logic;
		-- AER DATA OUT
		node_in_data       : out std_logic_vector(OUT_DATA_BITS_WIDTH - 1 downto 0);
		node_req_n         : out std_logic;
		node_in_osu_ack_n  : in  std_logic;
		--MULTIPLEXED ACK
		ecu_node_out_ack_n : out std_logic
	);
end okt_osu;

architecture Behavioral of okt_osu is

	-- FIFO signals
	signal fifo_w_data       : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal fifo_w_en         : std_logic;
	signal fifo_r_data       : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal fifo_r_en         : std_logic;
	signal fifo_empty        : std_logic;
	-- signal fifo_full         : std_logic;
	-- signal fifo_almost_full  : std_logic; 
	-- signal fifo_almost_empty : std_logic;
	signal fifo_fill_count   : integer range FIFO_DEPTH - 1 downto 0;
	--signal usb_burst : integer;

	signal usb_ready         : std_logic;
	signal fifo_w_en_end     : std_logic;
	signal fifo_w_en_latched : std_logic;

	--Sys signals
	signal n_command      : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);
--	signal ecu_node_ack_n : std_logic := '1'; --Latched signal
	signal ecu_node_ack_n : std_logic; --Latched signal

	signal out_req            : std_logic := '1'; --output request
	signal out_ack            : std_logic := '1'; --output ack
	signal aer_data, limit_ts : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);

	signal rise_timestamp, next_timestamp                   : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	
	-- Pipelined timestamp comparison signals (Stage 1: registered data from FIFO)
	signal limit_ts_reg       : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	signal limit_ts_is_ovf    : std_logic; -- Pre-calculated: limit_ts == 0xFFFFFFFF
	signal limit_ts_is_zero   : std_logic; -- Pre-calculated: limit_ts == 0
	
	-- Pipelined timestamp comparison signals (Stage 2: registered comparisons)
	signal limit_ts_minus_2   : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	signal timestamp_plus_2   : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	signal comp_ts_gt_limit   : std_logic;
	signal comp_ts_near_limit : std_logic;
	signal ovf_limit_minus_2  : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	signal comp_ts_gt_ovf     : std_logic;
	type state is (idle, timestamp_check, wait_ack_rise, data_trigger_0, data_trigger_1, data_trigger_2, wait_ovf);
	signal r_okt_osu_control_state, n_okt_osu_control_state : state;

	-- attribute enum_encoding : string;
	-- attribute enum_encoding of state : type is "IDLE 000, timestamp_check 001, wait_ack_rise 010, data_trigger_0 011, data_trigger_1 100, data_trigger_2 101, wait_ovf 110";

begin

	n_command <= cmd;
	-- status    <= "00000" & usb_ready & fifo_empty & fifo_full;

	--		sequencer_fifo : entity work.okt_fifo
	--		generic map(
	--			DEPTH => OSU_FIFO_DEPTH
	--		)
	--		port map(
	--			clk    => clk,
	--			rst_n  => rst_n,
	--			w_data => fifo_w_data,
	--			w_en   => fifo_w_en,
	--			r_data => fifo_r_data,
	--			r_en   => fifo_r_en,
	--			empty  => fifo_empty,
	--			full   => fifo_full,
	--			almost_full => fifo_almost_full,
	--			almost_empty => fifo_almost_empty
	--		);

	ring_buffer : entity work.ring_buffer
		generic map(
			RAM_DEPTH => FIFO_DEPTH,
			RAM_WIDTH => 32
		)
		port map(
			clk        => clk,
			rst        => rst_n,
			wr_data    => fifo_w_data,
			wr_en      => fifo_w_en,
			rd_data    => fifo_r_data,
			rd_en      => fifo_r_en,
			empty      => fifo_empty,
			-- full       => fifo_full,
			-- full_next  => fifo_almost_full,
			fill_count => fifo_fill_count
			-- empty_next => fifo_almost_empty
		);

	fifo_w_data <= in_data;
	fifo_w_en   <= in_wr;
	in_ready    <= usb_ready;

	--------------------------------------------------------------------------------------------------------------------
	--Output Multiplexer
	--------------------------------------------------------------------------------------------------------------------
	Output_MUX : process(rst_n, n_command, ecu_in_ack_n, node_in_osu_ack_n, aer_data, out_req, ecu_node_ack_n, aer_in_data, req_in_data_n)
	begin
		if rst_n = '0' then             --Reset all values to inactive when RST is active (low)
			node_req_n         <= '1';
			ecu_node_out_ack_n <= '1';
			node_in_data       <= (others => '0');
			out_ack            <= '1';
		else
			node_req_n         <= '1';
			ecu_node_out_ack_n <= '1';
			node_in_data       <= (others => '0');
			out_ack            <= '1';

			case n_command(2 downto 0) is

				when Mask_MON(2 downto 0) =>         --MONITOR: Deactivates output and has IMU_ack connected to ECU_ack
					ecu_node_out_ack_n <= ecu_in_ack_n;

				when Mask_PASS(2 downto 0) =>         --PASS: bypasses output and connects IMU_ack to OUT_ack
					ecu_node_out_ack_n <= node_in_osu_ack_n;
					node_in_data       <= aer_in_data(OUT_DATA_BITS_WIDTH - 1 downto 0);
					node_req_n         <= req_in_data_n;

				when (Mask_MON(2 downto 0) or Mask_PASS(2 downto 0)) =>         --MERGER: bypasses output and connects OUT_ACK and ECU_ACK to IMU_ACK via latch
					ecu_node_out_ack_n <= ecu_node_ack_n;
					node_in_data       <= aer_in_data(OUT_DATA_BITS_WIDTH - 1 downto 0);
					node_req_n         <= req_in_data_n;

				when Mask_SEQ(2 downto 0) =>         --SEQUENCER: Activates output and cuts connections to internal ack signals
					node_in_data <= aer_data(OUT_DATA_BITS_WIDTH - 1 downto 0);
					node_req_n   <= out_req;
					out_ack      <= node_in_osu_ack_n;

				when (Mask_MON(2 downto 0) or Mask_SEQ(2 downto 0)) =>         --DEBUG: TODO
					node_in_data       <= aer_data(OUT_DATA_BITS_WIDTH - 1 downto 0);
					node_req_n         <= out_req;
					out_ack            <= node_in_osu_ack_n;
					ecu_node_out_ack_n <= ecu_in_ack_n;

				when others =>          --TODO

			end case;
		end if;
	end process;

	--------------------------------------------------------------------------------------------------------------------
	--ACK Latch for bypass and monitor commands
	--------------------------------------------------------------------------------------------------------------------
	-- ACK_Latch: Latches ACK signals so that a new message is sent only after having received both acks. No timeout for the moment.
--	ACK_latch : process(ecu_in_ack_n, node_in_osu_ack_n)
--	begin
--		if ecu_in_ack_n = '0' and node_in_osu_ack_n = '0' then
--			ecu_node_ack_n <= '0';
--		elsif ecu_in_ack_n = '1' and node_in_osu_ack_n = '1' then
--			ecu_node_ack_n <= '1';
--		end if;
--	end process;
	ACK_latch : process(clk, rst_n)
	begin
		 if rst_n = '0' then
			  ecu_node_ack_n <= '1';
		 elsif rising_edge(clk) then
			  if ecu_in_ack_n = '0' and node_in_osu_ack_n = '0' then
					ecu_node_ack_n <= '0';
			  elsif ecu_in_ack_n = '1' and node_in_osu_ack_n = '1' then
					ecu_node_ack_n <= '1';
			  end if;
		 end if;
	end process;

	--------------------------------------------------------------------------------------------------------------------
	--FSM synchronous signals
	--------------------------------------------------------------------------------------------------------------------
	-- signals_update: This process will update the control_state and timestamp signals
	signals_update : process(clk, rst_n)
	begin
		if rst_n = '0' then
			r_okt_osu_control_state <= idle;
			rise_timestamp          <= (others => '0');

		elsif rising_edge(clk) then
			r_okt_osu_control_state <= n_okt_osu_control_state;
			rise_timestamp          <= next_timestamp;
		end if;
	end process signals_update;

	--------------------------------------------------------------------------------------------------------------------
	-- Pipelined timestamp comparison (2-stage pipeline para romper camino crítico)
	--------------------------------------------------------------------------------------------------------------------
	timestamp_pipeline : process(clk, rst_n)
	begin
		if rst_n = '0' then
			-- Stage 1: FIFO data registration
			limit_ts_reg       <= (others => '0');
			limit_ts_is_ovf    <= '0';
			limit_ts_is_zero   <= '1';
			-- Stage 2: Arithmetic and comparisons
			limit_ts_minus_2   <= (others => '0');
			timestamp_plus_2   <= (others => '0');
			comp_ts_gt_limit   <= '0';
			comp_ts_near_limit <= '0';
			ovf_limit_minus_2  <= (others => '0');
			comp_ts_gt_ovf     <= '0';
		elsif rising_edge(clk) then
			-- === PIPELINE STAGE 1: Register FIFO data ONLY (no comparisons) ===
			-- Break the critical path from BRAM by only registering the data
			limit_ts_reg <= fifo_r_data(TIMESTAMP_BITS_WIDTH - 1 downto 0);
			
			-- === PIPELINE STAGE 2: Pre-decode special values on REGISTERED data ===
			-- Now the comparisons operate on limit_ts_reg instead of fifo_r_data
			if limit_ts_reg = x"FFFFFFFF" then
				limit_ts_is_ovf <= '1';
			else
				limit_ts_is_ovf <= '0';
			end if;
			
			if limit_ts_reg = x"00000000" then
				limit_ts_is_zero <= '1';
			else
				limit_ts_is_zero <= '0';
			end if;
			
			-- === PIPELINE STAGE 2: Arithmetic operations on registered data ===
			limit_ts_minus_2   <= limit_ts_reg - 2;
			timestamp_plus_2   <= rise_timestamp + 2;
			ovf_limit_minus_2  <= TIMESTAMP_OVF - 2;
			
			-- Registered comparisons for timestamp_check state
			if rise_timestamp > limit_ts_minus_2 then
				comp_ts_gt_limit <= '1';
			else
				comp_ts_gt_limit <= '0';
			end if;
			
			if timestamp_plus_2 > limit_ts_reg then
				comp_ts_near_limit <= '1';
			else
				comp_ts_near_limit <= '0';
			end if;
			
			-- Registered comparison for wait_ovf state
			if rise_timestamp > ovf_limit_minus_2 then
				comp_ts_gt_ovf <= '1';
			else
				comp_ts_gt_ovf <= '0';
			end if;
		end if;
	end process timestamp_pipeline;

	--------------------------------------------------------------------------------------------------------------------
	--FSM sequencer code. Beta VER.
	--------------------------------------------------------------------------------------------------------------------
	-- Take data from FIFO - REVISAR
	-- NOTA: Usa SOLO señales registradas (limit_ts_is_ovf, limit_ts_is_zero, comp_*) para eliminar caminos combinacionales
	output_sequencer : process(r_okt_osu_control_state, out_ack, n_command, fifo_empty, rise_timestamp, fifo_r_data, limit_ts_is_ovf, limit_ts_is_zero, comp_ts_gt_limit, comp_ts_near_limit, comp_ts_gt_ovf)
	begin
		n_okt_osu_control_state <= r_okt_osu_control_state;
		next_timestamp          <= rise_timestamp + 1;

		fifo_r_en <= '0';
		aer_data  <= (others => '0');
		limit_ts  <= (others => '0');
		out_req   <= '1';

		case r_okt_osu_control_state is

			when idle =>
				if (out_ack = '1' and n_command(2) = '1' and fifo_empty = '0') then
					n_okt_osu_control_state <= timestamp_check;
				end if;

			when timestamp_check =>
				-- Pass through for data_trigger states (needed for aer_data assignment)
				limit_ts <= fifo_r_data(BUFFER_BITS_WIDTH - 1 downto 0);
				
				-- Use pre-calculated registered flags (NO combinational logic on limit_ts)
				if (limit_ts_is_ovf = '1') then
					fifo_r_en               <= '1';
					n_okt_osu_control_state <= wait_ovf;
				-- Use registered comparisons (limit_ts_is_zero is inverse of "limit_ts > 0")
				elsif (limit_ts_is_zero = '0' and (comp_ts_gt_limit = '1' or comp_ts_near_limit = '1')) then
					fifo_r_en               <= '1';
					n_okt_osu_control_state <= data_trigger_0;
					next_timestamp          <= (others => '0');
				end if;

			when data_trigger_0 =>
				n_okt_osu_control_state <= data_trigger_1;

			when data_trigger_1 =>
				aer_data <= fifo_r_data(BUFFER_BITS_WIDTH - 1 downto 0);
				out_req  <= '0';
				if (out_ack = '0') then
					n_okt_osu_control_state <= data_trigger_2;
				end if;

			when data_trigger_2 =>
				aer_data                <= fifo_r_data(BUFFER_BITS_WIDTH - 1 downto 0);
				n_okt_osu_control_state <= wait_ack_rise;
				fifo_r_en               <= '1';

			when wait_ack_rise =>
				if (out_ack = '1') then
					aer_data                <= (others => '0');
					n_okt_osu_control_state <= idle;
				end if;

			when wait_ovf =>
				-- Pass through TIMESTAMP_OVF for external visibility (not used in logic)
				limit_ts(TIMESTAMP_BITS_WIDTH - 1 downto 0) <= TIMESTAMP_OVF;
				
				-- Use ONLY registered comparison signal (NO combinational "limit_ts > 0")
				if (comp_ts_gt_ovf = '1') then
					aer_data                <= (others => '0');
					fifo_r_en               <= '1';
					n_okt_osu_control_state <= idle;
				end if;
		end case;
	end process output_sequencer;

	----------------------------------------------------------------------------------------------------------------------
	----Control USB.
	----------------------------------------------------------------------------------------------------------------------
	--	--Control USB: TODO: que no se bloquee al intentar llenarse de datos
	--	control_usb_ready : process(clk, rst_n) is
	--		variable usb_burst : integer;
	--	begin
	--		if rst_n = '0' then --RESET
	--			usb_ready <= '0';
	--			usb_burst := 0;
	--			fifo_w_en_end <= '0';
	--			fifo_w_en_latched <= '0';
	--			
	--		elsif rising_edge(clk) then --NORMAL
	--			 fifo_w_en_latched <= fifo_w_en;									-- latched = enable	
	--			if fifo_w_en_latched = '1' and fifo_w_en = '0' then		-- if latched = 1 and enable = 0
	--				  fifo_w_en_end <= '1';											-- end = 1
	--			else																		-- else
	--				  fifo_w_en_end <= '0';											-- end = 0
	--			end if;		
	--			if fifo_almost_empty = '1' or fifo_empty = '1' then 		-- if fifo is getting empty
	--				usb_ready <= '1';													-- ready = 1
	--				usb_burst := USB_BURST_WORDS;									-- burst = 4096
	--			elsif usb_ready = '1' then											-- else if ready = 1
	--				 usb_burst := usb_burst - 1;									-- burst - 1
	--				 if usb_burst = 0 or fifo_w_en_end = '1' then			-- if burst = 0 or end = 1
	--					  usb_ready <= '0';											-- ready = 0
	--				 end if;
	--			end if;
	--		end if;
	--	end process control_usb_ready;

	--------------------------------------------------------------------------------------------------------------------
	--Control USB. version 2
	--------------------------------------------------------------------------------------------------------------------
	--Control USB: TODO: que no se bloquee al intentar llenarse de datos
	control_usb_ready : process(clk, rst_n) is
		variable usb_burst : integer range 0 to FIFO_DEPTH - 1;
	begin
		if rst_n = '0' then             --RESET
			usb_ready         <= '0';
			usb_burst         := 0;
			fifo_w_en_end     <= '0';
			fifo_w_en_latched <= '0';

		elsif rising_edge(clk) then     --NORMAL
			fifo_w_en_latched <= fifo_w_en;

			if fifo_w_en_latched = '1' and fifo_w_en = '0' then
				fifo_w_en_end <= '1';
			else
				fifo_w_en_end <= '0';
			end if;

			if fifo_fill_count < FIFO_DEPTH - FIFO_ALM_FULL_OFFSET then
				usb_ready <= '1';
				usb_burst := USB_BURST_WORDS;
			elsif usb_ready = '1' then
				usb_burst := usb_burst - 1;
				if usb_burst = 0 or fifo_w_en_end = '1' then
					usb_ready <= '0';
				end if;
			end if;

		end if;
	end process control_usb_ready;

end Behavioral;
