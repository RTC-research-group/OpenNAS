
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"
use ieee.numeric_std.all;
use work.okt_fifo_pkg.all;
use work.okt_global_pkg.all;
use work.okt_top_pkg.all;

entity okt_ecu is                       -- Event Capture Unit
	Port(
		clk           : in  std_logic;
		rst_n         : in  std_logic;
		ecu_req_n     : in  std_logic;
		aer_data      : in  std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		ecu_out_ack_n : out std_logic;
		-- CU interface
		out_data      : out std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		out_rd        : in  std_logic;
		out_ready     : out std_logic;
		status    : out std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
		cmd           : in  std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0)
	);
end okt_ecu;

architecture Behavioral of okt_ecu is

	type state is (idle, req_fall_0, req_fall_1, wait_req_rise, timestamp_overflow_0, timestamp_overflow_1);
	signal r_okt_ecu_control_state, n_okt_ecu_control_state : state;

	signal r_timestamp, n_timestamp : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	--signal ecu_req_n                : std_logic;
	signal n_ack_n                  : std_logic;
	
	-- Pipelined timestamp signals (2-stage pipeline to break critical path)
	-- Stage 1: Registered timestamp and pre-decoded flags
	signal r_timestamp_reg     : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);
	signal r_timestamp_is_ovf  : std_logic; -- Pre-calculated: r_timestamp = TIMESTAMP_OVF
	
	-- Stage 2: Registered arithmetic operations
	signal r_timestamp_plus_1  : std_logic_vector(TIMESTAMP_BITS_WIDTH - 1 downto 0);

	signal ECU_fifo_w_data     : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal ECU_fifo_w_en       : std_logic;
	signal ECU_fifo_r_data     : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal ECU_fifo_r_en       : std_logic;
	signal ECU_fifo_empty  		  : std_logic;
	signal ECU_fifo_full       : std_logic;
	-- signal ECU_fifo_almost_full   : std_logic;
	-- signal ECU_fifo_almost_empty   : std_logic;
	signal ECU_fifo_fill_count : integer range FIFO_DEPTH - 1 downto 0;
	--signal usb_burst : integer;

	signal ECU_usb_ready         : std_logic;
	signal ECU_fifo_r_en_end     : std_logic;
	signal ECU_fifo_r_en_latched : std_logic;

	signal n_command : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);

	-- DEBUG
	attribute MARK_DEBUG : string; 
	attribute MARK_DEBUG of rst_n, ecu_req_n, aer_data, ecu_out_ack_n, out_data, out_rd, out_ready, cmd, 
							r_okt_ecu_control_state, n_okt_ecu_control_state, r_timestamp, n_timestamp, 
							n_ack_n, ECU_fifo_w_data, ECU_fifo_w_en, ECU_fifo_r_data, ECU_fifo_r_en, 
							ECU_fifo_full, ECU_fifo_fill_count, ECU_usb_ready, ECU_fifo_r_en_end, 
							ECU_fifo_r_en_latched, n_command : signal is "TRUE";

begin

	--ecu_req_n <= req_n;
	ecu_out_ack_n <= n_ack_n;
	status <= "00000" & ECU_usb_ready & ECU_fifo_empty & ECU_fifo_full;
	n_command     <= cmd;

	--	caputre_fifo : entity work.okt_fifo
	--		generic map(
	--			DEPTH => FIFO_DEPTH
	--		)
	--		port map(
	--			clk    => clk,
	--			rst_n  => rst_n,
	--			w_data => ECU_fifo_w_data,
	--			w_en   => ECU_fifo_w_en,
	--			r_data => ECU_fifo_r_data,
	--			r_en   => ECU_fifo_r_en,
	--			empty  => ECU_fifo_empty,
	--			full   => ECU_fifo_full,
	--			almost_full => ECU_fifo_almost_full,
	--			almost_empty => ECU_fifo_almost_empty
	--		);

	ring_buffer : entity work.ring_buffer
		generic map(
			RAM_DEPTH => FIFO_DEPTH,
			RAM_WIDTH => BUFFER_BITS_WIDTH
		)
		port map(
			clk        => clk,
			rst        => rst_n,
			wr_data    => ECU_fifo_w_data,
			wr_en      => ECU_fifo_w_en,
			rd_data    => ECU_fifo_r_data,
			rd_en      => ECU_fifo_r_en,
			empty  => ECU_fifo_empty,
			full       => ECU_fifo_full,
			-- full_next => ECU_fifo_almost_full,
			fill_count => ECU_fifo_fill_count
			-- empty_next => ECU_fifo_almost_empty
		);

	out_data      <= ECU_fifo_r_data;
	ECU_fifo_r_en <= out_rd;
	out_ready     <= ECU_usb_ready;

	signals_update : process(clk, rst_n)
	begin
		if rst_n = '0' then
			r_okt_ecu_control_state <= idle;
			r_timestamp             <= (others => '0');

		elsif rising_edge(clk) then
			r_okt_ecu_control_state <= n_okt_ecu_control_state;
			r_timestamp             <= n_timestamp;
		end if;

	end process signals_update;
	
	--------------------------------------------------------------------------------------------------------------------
	-- Pipelined timestamp operations (2-stage pipeline to break critical path)
	--------------------------------------------------------------------------------------------------------------------
	timestamp_pipeline : process(clk, rst_n)
	begin
		if rst_n = '0' then
			-- Stage 1: Timestamp registration
			r_timestamp_reg    <= (others => '0');
			r_timestamp_is_ovf <= '0';
			-- Stage 2: Arithmetic operations
			r_timestamp_plus_1 <= (others => '0');
		elsif rising_edge(clk) then
			-- === PIPELINE STAGE 1: Register timestamp and pre-decode overflow flag ===
			r_timestamp_reg <= r_timestamp;
			
			-- Pre-calculate overflow check (combinational → register)
			if r_timestamp = TIMESTAMP_OVF then
				r_timestamp_is_ovf <= '1';
			else
				r_timestamp_is_ovf <= '0';
			end if;
			
			-- === PIPELINE STAGE 2: Arithmetic operation on registered data ===
			r_timestamp_plus_1 <= r_timestamp_reg + 1;
		end if;
	end process timestamp_pipeline;

	-- input monitor: Stores data in fifo
	-- MODIFIED: Using pipelined signals to eliminate critical path
	input_monitor : process(r_okt_ecu_control_state, ecu_req_n, r_timestamp, aer_data, ECU_fifo_full, n_command, r_timestamp_is_ovf, r_timestamp_plus_1)
	begin
		n_okt_ecu_control_state <= r_okt_ecu_control_state;
		-- ORIGINAL (combinational path): n_timestamp <= r_timestamp + 1;
		-- NEW (registered arithmetic): Use pre-calculated r_timestamp_plus_1
		n_timestamp             <= r_timestamp_plus_1;
		n_ack_n                 <= '1';
		ECU_fifo_w_data         <= (others => '0');
		ECU_fifo_w_en           <= '0';

		case r_okt_ecu_control_state is
			when idle =>
				if (n_command(0) = '0') then
					n_timestamp <= (others => '0');
					n_okt_ecu_control_state <= idle;

				elsif (ecu_req_n = '0' and n_command(0) = '1') then
					n_okt_ecu_control_state <= req_fall_0;

				-- ORIGINAL (combinational comparison): elsif (r_timestamp = TIMESTAMP_OVF and n_command(0) = '1') then
				-- NEW (registered flag): Use pre-calculated r_timestamp_is_ovf
				elsif (r_timestamp_is_ovf = '1' and n_command(0) = '1') then
					n_okt_ecu_control_state <= timestamp_overflow_0;
				end if;

			when req_fall_0 =>
				-- ORIGINAL (combinational comparison): if (r_timestamp = TIMESTAMP_OVF) then
				-- NEW (registered flag): Use pre-calculated r_timestamp_is_ovf
				if (r_timestamp_is_ovf = '1') then
					n_okt_ecu_control_state <= timestamp_overflow_0;

				elsif (ECU_fifo_full = '0') then
					ECU_fifo_w_data(TIMESTAMP_BITS_WIDTH - 1 downto 0) <= r_timestamp;
					ECU_fifo_w_en                                      <= '1';
					n_timestamp                                        <= (others => '0');
					n_okt_ecu_control_state                            <= req_fall_1;
				end if;

			when req_fall_1 =>
				if (ECU_fifo_full = '0') then
					ECU_fifo_w_data(BUFFER_BITS_WIDTH - 1 downto 0) <= aer_data;
					ECU_fifo_w_en                                   <= '1';
					--n_timestamp                                 <= (others => '0');
					--n_ack_n                                     <= '0';
					n_okt_ecu_control_state                         <= wait_req_rise;
				end if;

			when wait_req_rise =>
				n_ack_n <= '0';
				if (ecu_req_n = '1') then
					n_okt_ecu_control_state <= idle;
				end if;

			when timestamp_overflow_0 =>
				if (ECU_fifo_full = '0') then
					ECU_fifo_w_data         <= (others => '1');
					ECU_fifo_w_en           <= '1';
					n_timestamp             <= (others => '0');
					n_okt_ecu_control_state <= timestamp_overflow_1;
				end if;

			when timestamp_overflow_1 =>
				if (ECU_fifo_full = '0') then
					ECU_fifo_w_data         <= (others => '0');
					ECU_fifo_w_en           <= '1';
					n_timestamp             <= (others => '0');
					n_okt_ecu_control_state <= idle;
				end if;
		end case;
	end process;

	control_ECU_usb_ready : process(clk, rst_n) is
		-- variable usb_burst : integer range 0 to USB_BURST_WORDS;
	begin
		if rst_n = '0' then
			ECU_usb_ready         <= '0';
			-- usb_burst             := 0;
			ECU_fifo_r_en_end     <= '0';
			ECU_fifo_r_en_latched <= '0';

		elsif rising_edge(clk) then
			ECU_fifo_r_en_latched <= ECU_fifo_r_en;

			if ECU_fifo_r_en_latched = '1' and ECU_fifo_r_en = '0' then
				ECU_fifo_r_en_end <= '1';
			else
				ECU_fifo_r_en_end <= '0';
			end if;

			-- if ECU_fifo_fill_count > FIFO_ALM_EMPTY_OFFSET then
			-- 	ECU_usb_ready <= '1';
			-- 	usb_burst     := USB_BURST_WORDS;
			-- elsif ECU_usb_ready = '1' then
			-- 	usb_burst := usb_burst - 1;
			-- 	if usb_burst = 0 or ECU_fifo_r_en_end = '1' then
			-- 		ECU_usb_ready <= '0';
			-- 	end if;
			-- end if;
			if ECU_fifo_fill_count > FIFO_ALM_EMPTY_OFFSET then
				ECU_usb_ready <= '1';
			else
				ECU_usb_ready <= '0';
			end if;
		end if;
	end process;

end Behavioral;

