
-- library IEEE;
-- use IEEE.std_logic_1164.ALL;
-- use work.okt_global_pkg.all;
-- use work.okt_top_pkg.all;
-- use work.okt_imu_pkg.all;

-- entity okt_top is
-- 	port(
-- 		--        sys_clkp     : in    std_logic; -- The clock is generated in CU module
-- 		--        sys_clkn     : in    std_logic;
-- 		rst_ext_n      : in    std_logic;
-- 		clock          : out   std_logic; -- 100.8 MHz
-- 		rst_sw_n	 : out    std_logic;
-- 		-- USB 3.0 interface
-- 		okUH           : in    std_logic_vector(OK_UH_WIDTH_BUS - 1 downto 0);
-- 		okHU           : out   std_logic_vector(OK_HU_WIDTH_BUS - 1 downto 0);
-- 		okUHU          : inout std_logic_vector(OK_UHU_WIDTH_BUS - 1 downto 0);
-- 		okAA           : inout std_logic;
-- 		-- AER INPUT interfaces
-- 		port_a_data    : in    std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
-- 		port_a_req_n   : in    std_logic;
-- 		port_a_ack_n   : out   std_logic;
-- 		port_b_data    : in    std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
-- 		port_b_req_n   : in    std_logic;
-- 		port_b_ack_n   : out   std_logic;
-- 		port_c_data      : in    std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
-- 		port_c_req_n     : in    std_logic;
-- 		port_c_ack_n : out   std_logic;
-- 		-- AER OUTPUT interface
-- 		out_data       : out   std_logic_vector(OUT_DATA_BITS_WIDTH - 1 downto 0);
-- 		out_req_n      : out   std_logic;
-- 		out_ack_n      : in    std_logic;
-- 		-- Configuration interface
-- 		config_data    : out   std_logic_vector(CONFIG_BITS_WIDTH - 1 downto 0);
-- 		config_addr    : out   std_logic_vector(CONFIG_BITS_WIDTH - 1 downto 0);
-- 		config_en      : out   std_logic_vector(CONFIG_NUN_DEVICES - 1 downto 0);
-- 		-- Status leds
-- 		leds           : out   std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0)
-- 	);
-- end okt_top;

-- architecture Behavioral of okt_top is
-- 	--sys signals
-- 	signal okClk  : std_logic;
-- 	signal rst_n  : std_logic;
-- 	signal rst_sw : std_logic;

-- 	--latch signals
-- 	signal port_a_req_latch_0 : std_logic;
-- 	signal port_a_req_latch_1 : std_logic;
-- 	signal port_a_data_latch_0 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
-- 	signal port_a_data_latch_1 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
-- 	signal port_b_req_latch_0 : std_logic;
-- 	signal port_b_req_latch_1 : std_logic;
-- 	signal port_b_data_latch_0 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
-- 	signal port_b_data_latch_1 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
-- 	signal port_c_req_latch_0   : std_logic;
-- 	signal port_c_req_latch_1   : std_logic;
-- 	signal port_c_data_latch_0 : std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
-- 	signal port_c_data_latch_1 : std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
-- 	signal out_ack_n_latch_0 : std_logic;
-- 	signal out_ack_n_latch_1 : std_logic;
-- 	signal rst_ext_n_latch_0 : std_logic;
-- 	signal rst_ext_n_latch_1 : std_logic;

-- 	signal port_a_ack_n_signal : std_logic;
-- 	signal port_b_ack_n_signal : std_logic;
-- 	signal port_c_ack_n_signal : std_logic;	

-- 	--cu signals
-- 	signal in_ecu_data   : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
-- 	signal in_ecu_rd     : std_logic;
-- 	signal in_ecu_ready  : std_logic;
-- 	signal out_osu_data  : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
-- 	signal out_osu_wr    : std_logic;
-- 	signal out_osu_ready : std_logic;
-- 	signal input_sel     : std_logic_vector(NUM_INPUTS - 1 downto 0);

-- 	--imu signals
-- 	signal imu_req_n    : std_logic;
-- 	signal imu_aer_data : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
-- 	-- signal imu_ack_n    : std_logic;

-- 	--status signals
-- 	signal status_cu  : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
-- 	signal status_ecu : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
-- 	-- signal status_osu : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);

-- 	signal cmd : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);

-- 	--osu signals
-- 	-- signal osu_ack       : std_logic;
-- 	signal osu_imu_ack_n : std_logic;
-- 	signal ecu_osu_ack_n : std_logic;

-- 	-- DEBUG
-- 	attribute MARK_DEBUG : string;
-- 	attribute MARK_DEBUG of status_cu : signal is "TRUE";

-- begin

-- 	-- 0 = led on; 1 = led off 
-- 	-- leds  <= not (status_ecu(2 downto 0) & "000" & status_cu(1 downto 0));
-- 	leds  <= not (status_cu(LEDS_BITS_WIDTH - 1 ) & "0000" & status_ecu(2 downto 0));
-- 	-- leds <= not status_cu;
-- 	rst_n <= rst_ext_n_latch_1 and (not rst_sw);
-- 	clock <= okClk;
-- 	rst_sw_n <= not rst_sw;

-- 	-- Syncronizer with bypass implemented when monitor is inactive
-- 	syncronizer : process(okClk, rst_n)
-- 	begin
-- 		if (rst_n = '0') then
-- 			--ROME A
-- 			port_a_req_latch_0 <= '1';
-- 			port_a_req_latch_1 <= '1';
-- 			port_a_data_latch_0 <= (others => '0');
-- 			port_a_data_latch_1 <= (others => '0');
-- 			--ROME B
-- 			port_b_req_latch_0 <= '1';
-- 			port_b_req_latch_1 <= '1';
-- 			port_b_data_latch_0 <= (others => '0');
-- 			port_b_data_latch_1 <= (others => '0');
-- 			--NODE IN
-- 			port_c_req_latch_0   <= '1';
-- 			port_c_req_latch_1   <= '1';
-- 			port_c_data_latch_0 <= (others => '0');
-- 			port_c_data_latch_1 <= (others => '0');
-- 			--NODE OUT
-- 			out_ack_n_latch_0 <= '1';
-- 			out_ack_n_latch_1 <= '1';
-- 			rst_ext_n_latch_0 <= '1';
-- 			rst_ext_n_latch_1 <= '1';

-- 		elsif rising_edge(okClk) then
-- 			--TODO: Implement OSU command latch
-- 			out_ack_n_latch_0 <= out_ack_n;
-- 			out_ack_n_latch_1 <= out_ack_n_latch_0;

-- 			rst_ext_n_latch_0 <= rst_ext_n;
-- 			rst_ext_n_latch_1 <= rst_ext_n_latch_0;

-- 			if cmd(0) = '1' then
-- 				--ROME A
-- 				port_a_req_latch_0 <= port_a_req_n;
-- 				port_a_req_latch_1 <= port_a_req_latch_0;
-- 				port_a_data_latch_0 <= port_a_data;
-- 				port_a_data_latch_1 <= port_a_data_latch_0;
-- 				--ROME B
-- 				port_b_req_latch_0 <= port_b_req_n;
-- 				port_b_req_latch_1 <= port_b_req_latch_0;
-- 				port_b_data_latch_0 <= port_b_data;
-- 				port_b_data_latch_1 <= port_b_data_latch_0;
-- 				--NODE IN
-- 				port_c_req_latch_0   <= port_c_req_n;
-- 				port_c_req_latch_1   <= port_c_req_latch_0;
-- 				port_c_data_latch_0 <= port_c_data;
-- 				port_c_data_latch_1 <= port_c_data_latch_0;
-- 				--ACK MUX to IMU
-- 				port_a_ack_n <= port_a_ack_n_signal;
-- 				port_b_ack_n <= port_b_ack_n_signal;
-- 				port_c_ack_n <= port_c_ack_n_signal;

-- 			else
-- 				--ACK MUX to REQ
-- 				port_a_ack_n <= port_a_req_n;
-- 				port_b_ack_n <= port_b_req_n;
-- 				port_c_ack_n <= port_c_req_n;
-- 			end if;

-- 		end if;
-- 	end process;

-- 	cu_inst : entity work.okt_cu
-- 		port map(
-- 			--SYS
-- 			clk         => okClk,
-- 			rst_n       => rst_n,
-- 			rst_sw      => rst_sw,
-- 			--USB
-- 			okUH        => okUH,
-- 			okHU        => okHU,
-- 			okUHU       => okUHU,
-- 			okAA        => okAA,
-- 			--ECU
-- 			ecu_data    => in_ecu_data,
-- 			ecu_rd      => in_ecu_rd,
-- 			ecu_ready   => in_ecu_ready,
-- 			--OSU
-- 			osu_data    => out_osu_data,
-- 			osu_wr      => out_osu_wr,
-- 			osu_ready   => out_osu_ready,
-- 			--INTERFACE
-- 			input_sel   => input_sel,
-- 			status      => status_cu,
-- 			cmd         => cmd,
-- 			-- CONFIG
-- 			config_data => config_data,
-- 			config_addr => config_addr,
-- 			config_en   => config_en
-- 		);

-- 	imu_inst : entity work.okt_imu
-- 		port map(
-- 			clk               => okClk,
-- 			rst_n             => rst_n,
-- 			in0_data          => (BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto port_a_data_latch_1'length => '0') & port_a_data_latch_1,
-- 			in0_req_n         => port_a_req_latch_1,
-- 			-- in0_req_n         => port_a_req_n,
-- 			in0_ack_n         => port_a_ack_n_signal,
-- 			in1_data          => (BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto port_b_data_latch_1'length => '0') & port_b_data_latch_1,
-- 			in1_req_n         => port_b_req_latch_1,
-- 			-- in1_req_n         => port_b_req_n,
-- 			in1_ack_n         => port_b_ack_n_signal,
-- 			in2_data          => (BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto port_c_data_latch_1'length => '0') & port_c_data_latch_1,
-- 			in2_req_n         => port_c_req_latch_1,
-- 			-- in2_req_n         => port_c_req_n,
-- 			in2_ack_n         => port_c_ack_n_signal,
-- 			input_select      => input_sel,
-- 			out_data          => imu_aer_data,
-- 			out_req_n         => imu_req_n,
-- 			ecu_node_in_ack_n => osu_imu_ack_n
-- 		);

-- 	ecu_inst : entity work.okt_ecu
-- 		port map(
-- 			clk           => okClk,
-- 			rst_n         => rst_n,
-- 			ecu_req_n     => imu_req_n,
-- 			aer_data      => imu_aer_data,
-- 			ecu_out_ack_n => ecu_osu_ack_n,
-- 			out_data      => in_ecu_data,
-- 			out_rd        => in_ecu_rd,
-- 			out_ready     => in_ecu_ready,
-- 			status        => status_ecu,
-- 			cmd           => cmd        --Add process depending on cmd PASS or MON
-- 		);

-- 	osu_inst : entity work.okt_osu
-- 		port map(
-- 			clk                => okClk,
-- 			rst_n              => rst_n,
-- 			aer_in_data        => imu_aer_data,
-- 			req_in_data_n      => imu_req_n,
-- 			ecu_in_ack_n       => ecu_osu_ack_n,
-- 			cmd                => cmd,
-- 			in_data            => out_osu_data,
-- 			in_wr              => out_osu_wr,
-- 			in_ready           => out_osu_ready,
-- 			node_in_data       => out_data,
-- 			node_req_n         => out_req_n,
-- 			-- node_in_osu_ack_n  => out_ack_n,
-- 			node_in_osu_ack_n  => out_ack_n_latch_1,
-- 			ecu_node_out_ack_n => osu_imu_ack_n
-- 		);

-- end Behavioral;

library IEEE;
use IEEE.std_logic_1164.ALL;
use work.okt_global_pkg.all;
use work.okt_top_pkg.all;
use work.okt_imu_pkg.all;

entity okt_top is
	port(
		--        sys_clkp     : in    std_logic; -- The clock is generated in CU module
		--        sys_clkn     : in    std_logic;
		rst_ext_n    : in    std_logic;
		clock        : out   std_logic; -- 100.8 MHz
		rst_sw_n     : out   std_logic;
		-- USB 3.0 interface
		okUH         : in    std_logic_vector(OK_UH_WIDTH_BUS - 1 downto 0);
		okHU         : out   std_logic_vector(OK_HU_WIDTH_BUS - 1 downto 0);
		okUHU        : inout std_logic_vector(OK_UHU_WIDTH_BUS - 1 downto 0);
		okAA         : inout std_logic;
		-- AER INPUT interfaces
		port_a_data  : in    std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
		port_a_req_n : in    std_logic;
		port_a_ack_n : out   std_logic;
		port_b_data  : in    std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
		port_b_req_n : in    std_logic;
		port_b_ack_n : out   std_logic;
		port_c_data  : in    std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
		port_c_req_n : in    std_logic;
		port_c_ack_n : out   std_logic;
		-- AER OUTPUT interface
		out_data     : out   std_logic_vector(OUT_DATA_BITS_WIDTH - 1 downto 0);
		out_req_n    : out   std_logic;
		out_ack_n    : in    std_logic;
		-- Configuration interface
		config_data  : out   std_logic_vector(CONFIG_BITS_WIDTH - 1 downto 0);
		config_addr  : out   std_logic_vector(CONFIG_BITS_WIDTH - 1 downto 0);
		config_en    : out   std_logic_vector(CONFIG_NUN_DEVICES - 1 downto 0);
		-- Status leds
		leds         : out   std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0)
	);
end okt_top;

architecture Behavioral of okt_top is
	--sys signals
	signal okClk      : std_logic;
	signal rst_n      : std_logic;
	signal rst_sw     : std_logic;
	signal rst_sw_int : std_logic;

	--latch signals
	signal port_a_req_latch_0  : std_logic;
	signal port_a_req_latch_1  : std_logic;
	signal port_a_data_latch_0 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal port_a_data_latch_1 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal port_b_req_latch_0  : std_logic;
	signal port_b_req_latch_1  : std_logic;
	signal port_b_data_latch_0 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal port_b_data_latch_1 : std_logic_vector(ROME_DATA_BITS_WIDTH - 1 downto 0);
	signal port_c_req_latch_0  : std_logic;
	signal port_c_req_latch_1  : std_logic;
	signal port_c_data_latch_0 : std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
	signal port_c_data_latch_1 : std_logic_vector(NODE_DATA_BITS_WIDTH - 1 downto 0);
	signal out_ack_n_latch_0   : std_logic;
	signal out_ack_n_latch_1   : std_logic;
	signal rst_ext_n_latch_0   : std_logic;
	signal rst_ext_n_latch_1   : std_logic;

	--cu signals
	signal in_ecu_data   : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal in_ecu_rd     : std_logic;
	signal in_ecu_ready  : std_logic;
	signal out_osu_data  : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal out_osu_wr    : std_logic;
	signal out_osu_ready : std_logic := '0'; -- TODO: remove initialization
	signal input_sel     : std_logic_vector(NUM_INPUTS - 1 downto 0);

	--imu signals
	signal imu_req_n    : std_logic;
	signal imu_aer_data : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	-- signal imu_ack_n    : std_logic;

	--status signals
	signal status_cu  : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
	signal status_ecu : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
	-- signal status_osu : std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);

	signal cmd : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);

	--osu signals
	-- signal osu_ack       : std_logic;
	signal osu_imu_ack_n : std_logic := '1'; -- TODO: remove initialization
	signal ecu_osu_ack_n : std_logic;

	-- DEBUG
	attribute MARK_DEBUG              : string;
	attribute MARK_DEBUG of status_cu : signal is "TRUE";

begin

	-- 0 = led on; 1 = led off 
	-- XEM6310 LEDS on when 0, LEDS off when 1
	leds     <= not (status_cu(LEDS_BITS_WIDTH - 1) & "0000" & status_ecu(2 downto 0));
	-- XEM7310 LEDS on when 0, LEDS off when 'Z'
	-- TODO: Adjust for XEM7310
	-- leds <= status_cu;
	rst_n    <= rst_ext_n_latch_1 and (not rst_sw_int);
	clock    <= okClk;
	rst_sw_n <= not rst_sw;

	-- Sync input signals
	syncronizer : process(okClk, rst_n)
	begin
		if (rst_n = '0') then
			port_a_req_latch_0  <= '1';
			port_a_req_latch_1  <= '1';
			port_a_data_latch_0 <= (others => '0');
			port_a_data_latch_1 <= (others => '0');
			port_b_req_latch_0  <= '1';
			port_b_req_latch_1  <= '1';
			port_b_data_latch_0 <= (others => '0');
			port_b_data_latch_1 <= (others => '0');
			port_c_req_latch_0  <= '1';
			port_c_req_latch_1  <= '1';
			port_c_data_latch_0 <= (others => '0');
			port_c_data_latch_1 <= (others => '0');
			out_ack_n_latch_0   <= '1';
			out_ack_n_latch_1   <= '1';
			rst_ext_n_latch_0   <= '1';
			rst_ext_n_latch_1   <= '1';

		elsif rising_edge(okClk) then
			port_a_req_latch_0  <= port_a_req_n;
			port_a_req_latch_1  <= port_a_req_latch_0;
			port_a_data_latch_0 <= port_a_data;
			port_a_data_latch_1 <= port_a_data_latch_0;
			port_b_req_latch_0  <= port_b_req_n;
			port_b_req_latch_1  <= port_b_req_latch_0;
			port_b_data_latch_0 <= port_b_data;
			port_b_data_latch_1 <= port_b_data_latch_0;
			port_c_req_latch_0  <= port_c_req_n;
			port_c_req_latch_1  <= port_c_req_latch_0;
			port_c_data_latch_0 <= port_c_data;
			port_c_data_latch_1 <= port_c_data_latch_0;
			out_ack_n_latch_0   <= out_ack_n;
			out_ack_n_latch_1   <= out_ack_n_latch_0;
			rst_ext_n_latch_0   <= rst_ext_n;
			rst_ext_n_latch_1   <= rst_ext_n_latch_0;

		end if;
	end process;

	cu_inst : entity work.okt_cu
		port map(
			--SYS
			clk         => okClk,
			rst_n       => rst_n,
			rst_sw_int  => rst_sw_int,
			rst_sw_ext  => rst_sw,
			--USB
			okUH        => okUH,
			okHU        => okHU,
			okUHU       => okUHU,
			okAA        => okAA,
			--ECU
			ecu_data    => in_ecu_data,
			ecu_rd      => in_ecu_rd,
			ecu_ready   => in_ecu_ready,
			--OSU
			osu_data    => out_osu_data,
			osu_wr      => out_osu_wr,
			osu_ready   => out_osu_ready,
			--INTERFACE
			input_sel   => input_sel,
			status      => status_cu,
			cmd         => cmd,
			-- CONFIG
			config_data => config_data,
			config_addr => config_addr,
			config_en   => config_en
		);

	imu_inst : entity work.okt_imu
		port map(
			clk               => okClk,
			rst_n             => rst_n,
			in0_data          => (BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto port_a_data_latch_1'length => '0') & port_a_data_latch_1,
			in0_req_n         => port_a_req_latch_1,
			-- in0_req_n         => port_a_req_n,
			in0_ack_n         => port_a_ack_n,
			in1_data          => (BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto port_b_data_latch_1'length => '0') & port_b_data_latch_1,
			in1_req_n         => port_b_req_latch_1,
			-- in1_req_n         => port_b_req_n,
			in1_ack_n         => port_b_ack_n,
			in2_data          => (BUFFER_BITS_WIDTH - INPUT_BITS_WIDTH - 1 downto port_c_data_latch_1'length => '0') & port_c_data_latch_1,
			in2_req_n         => port_c_req_latch_1,
			-- in2_req_n         => port_c_req_n,
			in2_ack_n         => port_c_ack_n,
			input_select      => input_sel,
			out_data          => imu_aer_data,
			out_req_n         => imu_req_n,
			ecu_node_in_ack_n => osu_imu_ack_n
		);

	ecu_inst : entity work.okt_ecu
		port map(
			clk           => okClk,
			rst_n         => rst_n,
			ecu_req_n     => imu_req_n,
			aer_data      => imu_aer_data,
			ecu_out_ack_n => ecu_osu_ack_n,
			out_data      => in_ecu_data,
			out_rd        => in_ecu_rd,
			out_ready     => in_ecu_ready,
			status        => status_ecu,
			cmd           => cmd        --Add process depending on cmd PASS or MON
		);

	osu_inst : entity work.okt_osu
		port map(
			clk                => okClk,
			rst_n              => rst_n,
			aer_in_data        => imu_aer_data,
			req_in_data_n      => imu_req_n,
			ecu_in_ack_n       => ecu_osu_ack_n,
			cmd                => cmd,
			in_data            => out_osu_data,
			in_wr              => out_osu_wr,
			in_ready           => out_osu_ready,
			node_in_data       => out_data,
			node_req_n         => out_req_n,
			-- node_in_osu_ack_n  => out_ack_n,
			node_in_osu_ack_n  => out_ack_n_latch_1,
			ecu_node_out_ack_n => osu_imu_ack_n
		);

end Behavioral;

