library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.okt_imu_pkg.all;
use work.okt_global_pkg.all;


entity okt_imu is                       -- Input Merger Unit
	Port(
		clk            : in  std_logic;
		rst_n          : in  std_logic;
		
		in0_data       : in  std_logic_vector(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0);
		in0_req_n      : in  std_logic;
		in0_ack_n      : out std_logic;
		
		in1_data       : in  std_logic_vector(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0);
		in1_req_n      : in  std_logic;
		in1_ack_n      : out std_logic;
		
		in2_data       : in  std_logic_vector(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0);
		in2_req_n      : in  std_logic;
		in2_ack_n      : out std_logic;
		
		input_select   : in  std_logic_vector(NUM_INPUTS - 1 downto 0);
		out_data       : out std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		out_req_n      : out std_logic;
		ecu_node_in_ack_n : in  std_logic
);
end okt_imu;

architecture Behavioral of okt_imu is

	signal n_out_req_n, n_out_ack_n : std_logic;
	signal n_out_data               : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	
--	signal CAVIAR_ack, CAVIAR_req : std_logic;
--	signal CAVIAR_data : std_logic_vector(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0);

	type state is (idle, in0, in1, in2);
	signal r_okt_control_state, n_okt_control_state : state;

	-- DEBUG
	attribute MARK_DEBUG : string; 
	attribute MARK_DEBUG of rst_n, in0_data, in0_req_n, in0_ack_n, in1_data, in1_req_n, in1_ack_n, 
												in2_data, in2_req_n, in2_ack_n, input_select, out_data, out_req_n, ecu_node_in_ack_n, 
												n_out_req_n, n_out_ack_n, n_out_data, r_okt_control_state, n_okt_control_state : signal is "TRUE";

begin

--    ws2c: entity work.okt_wsaer2caviar
--    port map(
--        WSAER_data  => in2_data(9 downto 0),
--        WSAER_req  => in2_req_n,
--        WSAER_ack => in2_ack_n,
--        CLK  => clk,
--        RST => not rst_n,             
--        row_delay  => "00111",
--        CAVIAR_ack  => CAVIAR_ack,
--        CAVIAR_req  => CAVIAR_req,
--        CAVIAR_data  => CAVIAR_data(16 downto 0)
--    );

	process(clk, rst_n)
	begin
		if rst_n = '0' then
			r_okt_control_state <= idle;

		elsif rising_edge(clk) then
			r_okt_control_state <= n_okt_control_state;

		end if;
	end process;

--	process(r_okt_control_state, input_select, in0_req_n, in1_req_n, CAVIAR_req, in0_data, in1_data, CAVIAR_data, n_out_ack_n)
	process(r_okt_control_state, input_select, in0_req_n, in1_req_n, in2_req_n, in0_data, in1_data, in2_data, n_out_ack_n)
	begin
		n_okt_control_state <= r_okt_control_state;
		in0_ack_n           <= '1';
		in1_ack_n           <= '1';
		in2_ack_n           <= '1';
		n_out_data          <= (others => '0');
		n_out_req_n         <= '1';

		case r_okt_control_state is
			when idle =>
				if input_select(0) = '1' and in0_req_n = '0' then
					n_okt_control_state <= in0;

				elsif input_select(1) = '1' and in1_req_n = '0' then
					n_okt_control_state <= in1;

				elsif input_select(2) = '1' and in2_req_n = '0' then
					n_okt_control_state <= in2;

				end if;

			when in0 =>
				n_out_data(BUFFER_BITS_WIDTH - 1 downto BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH) <= std_logic_vector(to_unsigned(0, INPUT_BITS_WIDTH));
				n_out_data(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0)                 <= in0_data;
				n_out_req_n                                                                   <= in0_req_n;
				in0_ack_n                                                                   <= n_out_ack_n;

				if input_select = std_logic_vector(to_unsigned(0, input_select'length)) then
					n_okt_control_state <= idle;

				elsif in0_req_n = '1' and n_out_ack_n = '1' then
					if input_select(1) = '1' and in1_req_n = '0' then
						n_okt_control_state <= in1;

					elsif input_select(2) = '1' and in2_req_n = '0' then
						n_okt_control_state <= in2;
						
					elsif unsigned(input_select) = 0 then
						n_okt_control_state <= idle;
						
					end if;
				end if;

			when in1 =>
				n_out_data(BUFFER_BITS_WIDTH - 1 downto BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH) <= std_logic_vector(to_unsigned(1, INPUT_BITS_WIDTH));
				n_out_data(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0)                 <= in1_data;
				n_out_req_n                                                                   <= in1_req_n;
				in1_ack_n                                                                   <= n_out_ack_n;

				if input_select = std_logic_vector(to_unsigned(0, input_select'length)) then
					n_okt_control_state <= idle;

				elsif in1_req_n = '1' and n_out_ack_n = '1' then
					if input_select(2) = '1' and in2_req_n = '0' then
						n_okt_control_state <= in2;

					elsif input_select(0) = '1' and in0_req_n = '0' then
						n_okt_control_state <= in0;

					elsif unsigned(input_select) = 0 then
						n_okt_control_state <= idle;
						
					end if;
				end if;

			when in2 =>
				n_out_data(BUFFER_BITS_WIDTH - 1 downto BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH) <= std_logic_vector(to_unsigned(2, INPUT_BITS_WIDTH));
				n_out_data(BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto 0)                 <= in2_data;
				n_out_req_n                                                                   <= in2_req_n;
				in2_ack_n                                                                    <= n_out_ack_n;

				if input_select = std_logic_vector(to_unsigned(0, input_select'length)) then
					n_okt_control_state <= idle;

				elsif in2_req_n = '1' and n_out_ack_n = '1' then
					if input_select(0) = '1' and in0_req_n = '0' then
						n_okt_control_state <= in0;

					elsif input_select(1) = '1' and in1_req_n = '0' then
						n_okt_control_state <= in1;

					elsif unsigned(input_select) = 0 then
						n_okt_control_state <= idle;
						
					end if;
				end if;

		end case;
	end process;

	process(n_out_data, n_out_req_n, ecu_node_in_ack_n)
	begin
		out_data    <= n_out_data;
		out_req_n   <= n_out_req_n;
		n_out_ack_n <= ecu_node_in_ack_n;
	end process;

end Behavioral;

