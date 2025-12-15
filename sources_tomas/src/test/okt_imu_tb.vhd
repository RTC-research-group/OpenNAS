-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.okt_imu_pkg.ALL;
use work.okt_global_pkg.ALL;
use work.okt_top_pkg.all;

ENTITY okt_imu_tb IS
END okt_imu_tb;

ARCHITECTURE behavior OF okt_imu_tb IS

	signal clk : std_logic;
	signal rst : std_logic;

	signal rome_a_data : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal rome_a_req  : std_logic;
	signal rome_a_ack  : std_logic;

	signal rome_b_data : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal rome_b_req  : std_logic;
	signal rome_b_ack  : std_logic;

	signal node_data : std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
	signal node_req  : std_logic;
	signal node_ack  : std_logic;

	signal in0_data, in1_data, in2_data: std_logic_vector(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0);

	signal input_select : std_logic_vector(NUM_INPUTS - 1 downto 0);

	signal out_data : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);  -- @suppress "Signal out_data is never read"
	signal out_req  : std_logic;
	signal out_ack  : std_logic;

	-- Clock period definitions
	constant CLK_period : time := 20 ns;

	type state is (idle, req_fall, req_rise);
	signal current_state_rome_a, next_state_rome_a       : state;
	signal current_state_rome_b, next_state_rome_b       : state;
	signal current_state_node, next_state_node           : state;

	type state_handshake is (idle, req_fall);
	signal current_state_out, next_state_out : state_handshake;

BEGIN
	
	in0_data <= std_logic_vector(to_unsigned(0, BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - ROME_DATA_BITS_WIDTH)) & rome_a_data;
	in1_data <= std_logic_vector(to_unsigned(0, BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - ROME_DATA_BITS_WIDTH)) & rome_b_data;
	in2_data <= std_logic_vector(to_unsigned(0, BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - NODE_DATA_BITS_WIDTH)) & node_data;
	
	-- Component Instantiation
	okt_imu : entity work.okt_imu
		PORT MAP(
			clk          => clk,
			rst_n        => rst,
			in0_data     => in0_data,
			in0_req_n    => rome_a_req,
			in0_ack_n    => rome_a_ack,
			in1_data     => in1_data,
			in1_req_n    => rome_b_req,
			in1_ack_n    => rome_b_ack,
			in2_data     => in2_data,
			in2_req_n    => node_req,
			in2_ack_n    => node_ack,
			input_select => input_select,
			out_data     => out_data,
			out_req_n    => out_req,
			ecu_node_in_ack_n      => out_ack
		);

	-- Clock process definitions
	CLK_process : process
	begin
		clk <= '0';
		wait for CLK_period / 2;
		clk <= '1';
		wait for CLK_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		rst          <= '0';
		input_select <= b"000";
		wait for CLK_period * 5;
		rst          <= '1';

		-- insert stimulus here
		wait for CLK_period;
		report "in_0 is enabled";
		input_select <= b"001";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "in_1 is enabled";
		input_select <= b"010";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "in_2 is enabled";
		input_select <= b"100";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "All inputs are enabled";
		input_select <= b"111";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "Enable in_0 and in_2";
		input_select <= b"101";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "Enable in_1 and in_2";
		input_select <= b"110";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "Enable in_0 and in_1";
		input_select <= b"011";
		wait for CLK_period * 20;
		report "All inputs are disabled";
		input_select <= b"000";
		wait for CLK_period * 20;
		report "End of simulation";
		wait;
	end process;

	signals_update : process(clk, rst)
	begin
		if rst = '0' then
			current_state_rome_a    <= idle;
			current_state_rome_b    <= idle;
			current_state_node      <= idle;
			current_state_out       <= idle;

		elsif rising_edge(clk) then
			current_state_rome_a    <= next_state_rome_a;
			current_state_rome_b    <= next_state_rome_b;
			current_state_node      <= next_state_node;
			current_state_out       <= next_state_out;

		end if;
	end process;

	FSM_transition : process(current_state_rome_a, rome_a_ack, current_state_rome_b, rome_b_ack, current_state_node, node_ack)
	begin
		next_state_rome_a    <= current_state_rome_a;
		next_state_rome_b    <= current_state_rome_b;
		next_state_node      <= current_state_node;

		rome_a_req    <= '1';
		rome_b_req    <= '1';
		node_req      <= '1';

		rome_a_data    <= (others => '0');
		rome_b_data    <= (others => '0');
		node_data      <= (others => '0');

		case current_state_rome_a is
			when idle =>
				if rome_a_ack = '1' then
					next_state_rome_a <= req_fall;
				end if;

			when req_fall =>
				rome_a_req  <= '0';
				rome_a_data <= std_logic_vector(to_unsigned(1, rome_a_data'length));
				if rome_a_ack = '0' then
					next_state_rome_a <= req_rise;
				end if;

			when req_rise =>
				rome_a_req        <= '1';
				next_state_rome_a <= idle;

		end case;

		case current_state_rome_b is
			when idle =>
				if rome_b_ack = '1' then
					next_state_rome_b <= req_fall;
				end if;

			when req_fall =>
				rome_b_req  <= '0';
				rome_b_data <= std_logic_vector(to_unsigned(2, rome_b_data'length));
				if rome_b_ack = '0' then
					next_state_rome_b <= req_rise;
				end if;

			when req_rise =>
				rome_b_req        <= '1';
				next_state_rome_b <= idle;

		end case;

		case current_state_node is
			when idle =>
				if node_ack = '1' then
					next_state_node <= req_fall;
				end if;

			when req_fall =>
				node_req  <= '0';
				node_data <= std_logic_vector(to_unsigned(3, node_data'length));
				if node_ack = '0' then
					next_state_node <= req_rise;
				end if;

			when req_rise =>
				node_req        <= '1';
				next_state_node <= idle;

		end case;
	end process;

	OUT_FSM_transitions : process(current_state_out, out_req)
	begin
		next_state_out <= current_state_out;
		out_ack        <= '1';

		case current_state_out is
			when idle =>
				if out_req = '0' then
					next_state_out <= req_fall;
				end if;

			when req_fall =>
				out_ack <= '0';
				if out_req = '1' then
					next_state_out <= idle;
				end if;

		end case;
	end process;

END;
