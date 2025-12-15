
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.okt_global_pkg.all;
use work.okt_cu_pkg.all;
use work.okt_imu_pkg.all;
use work.okt_top_pkg.all;
use work.FRONTPANEL.all;

entity okt_cu is                        -- Control Unit
	Port(
		clk         : out   std_logic;  -- 100.8 MHz
		rst_n       : in    std_logic;
		rst_sw_int  : out   std_logic;  -- sw rst to internal modules
		rst_sw_ext  : out   std_logic;  -- sw rst to external modules
		-- USB 3.0 interface
		okUH        : in    std_logic_vector(OK_UH_WIDTH_BUS - 1 downto 0);
		okHU        : out   std_logic_vector(OK_HU_WIDTH_BUS - 1 downto 0);
		okUHU       : inout std_logic_vector(OK_UHU_WIDTH_BUS - 1 downto 0);
		okAA        : inout std_logic;
		-- ECU interface
		ecu_data    : in    std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		ecu_rd      : out   std_logic;
		ecu_ready   : in    std_logic;
		--OSU interface
		osu_data    : out   std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
		osu_wr      : out   std_logic;
		osu_ready   : in    std_logic;
		-- Input selection
		input_sel   : out   std_logic_vector(NUM_INPUTS - 1 downto 0);
		-- Leds
		status      : out   std_logic_vector(LEDS_BITS_WIDTH - 1 downto 0);
		-- ECU and OSU interface
		cmd         : out   std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);
		-- Configuration
		config_data : out   std_logic_vector(CONFIG_BITS_WIDTH - 1 downto 0);
		config_addr : out   std_logic_vector(CONFIG_BITS_WIDTH - 1 downto 0);
		config_en   : out   std_logic_vector(CONFIG_NUN_DEVICES - 1 downto 0)
	);
end okt_cu;

architecture Behavioral of okt_cu is
	-- CU Signals
	signal n_command   	: std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);
	signal n_input_sel 	: std_logic_vector(NUM_INPUTS - 1 downto 0);
	signal n_rst_sw_int : std_logic;
	signal n_rst_sw_ext : std_logic;

	-- ECU Signals
	-- signal n_ecu_data  : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	-- signal n_ecu_rd    : std_logic;
	-- signal n_ecu_ready : std_logic;

	-- OSU Signals
	-- signal n_osu_data  : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	-- signal n_osu_wr    : std_logic;
	-- signal n_osu_ready : std_logic;

	-- USB signals
	signal okClk : std_logic;
	signal okHE  : std_logic_vector(OK_HE_WIDTH_BUS - 1 downto 0);
	signal okEH  : std_logic_vector(OK_EH_WIDTH_BUS - 1 downto 0);
	signal okEHx : std_logic_vector(OK_EH_WIDTH_BUS * OK_NUM_okEHx_END_POINTS - 1 downto 0);

	-- OK Endpoints
	signal ep00wire : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal ep01wire : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal ep02wire : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal ep03wire : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);

	signal epA0_datain      : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal epA0_read        : std_logic;
	signal epA0_blockstrobe : std_logic; -- @suppress "Signal epA0_blockstrobe is never read"
	signal epA0_ready       : std_logic;

	signal ep80_dataout     : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
	signal ep80_write       : std_logic;
	signal ep80_blockstrobe : std_logic; -- @suppress "Signal ep80_blockstrobe is never read"
	signal ep80_ready       : std_logic;

	-- DEBUG
	attribute MARK_DEBUG : string; 
	attribute MARK_DEBUG of rst_n, rst_sw_int, ecu_data, ecu_rd, ecu_ready, osu_data, 
							osu_wr, osu_ready, input_sel, status, cmd, config_data, config_addr, config_en, 
							n_command, n_input_sel, n_rst_sw_int, okClk, okHE, okEH, okEHx, ep00wire, ep01wire, n_rst_sw_ext,
							ep02wire, ep03wire, epA0_datain, epA0_read, epA0_blockstrobe, epA0_ready, ep80_dataout, 
							ep80_write, ep80_blockstrobe, ep80_ready : signal is "TRUE";

begin
	-- Connect the signals to the top level
	ecu_rd      <= epA0_read;
	epA0_datain <= ecu_data;
	epA0_ready  <= ecu_ready;

	osu_wr     <= ep80_write;
	osu_data   <= ep80_dataout;
	ep80_ready <= osu_ready;

	-- n_ecu_data  <= ecu_data;
	-- ecu_rd      <= n_ecu_rd;
	-- n_ecu_ready <= ecu_ready;

	-- osu_data    <= n_osu_data;
	-- osu_wr      <= n_osu_wr;
	-- n_osu_ready <= osu_ready;

	input_sel 	<= n_input_sel;
	cmd       	<= n_command;
	rst_sw_int  <= n_rst_sw_int;
	rst_sw_ext 	<= n_rst_sw_ext;

	--okHI : work.FRONTPANEL.okHost
	okHI : okHost
		port map(
			okUH  => okUH,
			okHU  => okHU,
			okUHU => okUHU,
			okAA  => okAA,
			okClk => okClk,             -- 100.8 MHz
			okHE  => okHE,
			okEH  => okEH
		);
	clk <= okClk;

	okOR : okWireOR
		generic map(
			N => OK_NUM_okEHx_END_POINTS
		)
		port map(
			okEH  => okEH,
			okEHx => okEHx
		);

	-- WireIn to receive command from USB
	cmd_EP : okWireIn
		port map(
			okHE       => okHE,
			ep_addr    => x"00",
			ep_dataout => ep00wire
		);

	-- WireIn to receive IMU input_sel from USB
	selInput_EP : okWireIn
		port map(
			okHE       => okHE,
			ep_addr    => x"01",
			ep_dataout => ep01wire
		);

	-- WireIn to receive sw rst from USB
	rst_EP : okWireIn
		port map(
			okHE       => okHE,
			ep_addr    => x"02",
			ep_dataout => ep02wire
		);
	n_rst_sw_int <= ep02wire(0);
	n_rst_sw_ext <= ep02wire(1);

	-- WireIn to receive configuration data from USB
	config_EP : okWireIn
		port map(
			okHE       => okHE,
			ep_addr    => x"03",
			ep_dataout => ep03wire
		);
	-- config_en(0) <= '1' when ((n_command and Mask_CONF_1) = Mask_CONF_1) else '0';
	-- config_en(1) <= '1' when ((n_command and Mask_CONF_2) = Mask_CONF_2) else '0';
	-- config_en(2) <= '1' when ((n_command and Mask_CONF_3) = Mask_CONF_3) else '0';
	-- config_data  <= ep03wire(CONFIG_BITS_WIDTH - 1 downto 0);
	-- config_addr  <= ep03wire(2 * CONFIG_BITS_WIDTH - 1 downto CONFIG_BITS_WIDTH);

	--PipeOut to send data out using the USB
	data_out_EP : okBTPipeOut
		port map(
			okHE           => okHE,
			okEH           => okEHx(1 * OK_EH_WIDTH_BUS - 1 downto 0 * OK_EH_WIDTH_BUS),
			ep_addr        => x"A0",
			ep_read        => epA0_read,
			ep_blockstrobe => epA0_blockstrobe,
			ep_datain      => epA0_datain,
			ep_ready       => epA0_ready
		);

	--PipeIn to receive data using the USB
	data_In_EP : okBTPipeIn
		port map(
			okHE           => okHE,
			okEH           => okEHx(2 * OK_EH_WIDTH_BUS - 1 downto 1 * OK_EH_WIDTH_BUS),
			ep_addr        => x"80",
			ep_write       => ep80_write,
			ep_blockstrobe => ep80_blockstrobe,
			ep_dataout     => ep80_dataout,
			ep_ready       => ep80_ready
		);

	-- -- Reset command and input_sel signals
	-- process(rst_n, ep00wire, ep01wire)
	-- begin
	-- 	if (rst_n = '0') then
	-- 		n_command   <= (others => '0');
	-- 		n_input_sel <= (others => '0');
	-- 	else
	-- 		n_command   <= ep00wire(COMMAND_BIT_WIDTH - 1 downto 0);
	-- 		n_input_sel <= ep01wire(NUM_INPUTS - 1 downto 0);
	-- 	end if;
	-- end process;
	-- Reset command and input_sel signals
	signal_update : process(okClk, rst_n)
	begin
		if (rst_n = '0') then
			n_command   <= (others => '0');
			n_input_sel <= (others => '0');
			config_en   <= (others => '0');
			config_data  <= (others => '0');
			config_addr  <= (others => '0');
			
		elsif rising_edge(okClk) then
			n_command   <= ep00wire(COMMAND_BIT_WIDTH - 1 downto 0);
			n_input_sel <= ep01wire(NUM_INPUTS - 1 downto 0);
			if(((n_command and Mask_CONF_1) = Mask_CONF_1)) then
				config_en(0) <= '1';
			else
				config_en(0) <= '0';
			end if;
			if(((n_command and Mask_CONF_2) = Mask_CONF_2)) then
				config_en(1) <= '1';
			else
				config_en(1) <= '0';
			end if;
			if(((n_command and Mask_CONF_3) = Mask_CONF_3)) then
				config_en(2) <= '1';
			else
				config_en(2) <= '0';
			end if;
			config_data  <= ep03wire(CONFIG_BITS_WIDTH - 1 downto 0);
			config_addr  <= ep03wire(2 * CONFIG_BITS_WIDTH - 1 downto CONFIG_BITS_WIDTH);
		end if;
	end process;

	-- Multiplexer that select the data path depending of the command
	leds_status : process(epA0_read, ep80_write,  rst_n)
	begin
		if (rst_n = '0') then
			status <= (others => '0');  -- Set all status led off
		else
			-- Default assignment
        	status <= (others => '0');  -- Set all LEDs off by default
			
			-- status(NUM_INPUTS - 1 downto 0) <= not n_input_sel; -- Set input selection led

			-- if ((n_command and Mask_MON) = Mask_MON) then -- MON command. Send out captured event to USB
			-- 	status(NUM_INPUTS) <= '1'; -- Set MON led
			-- end if;

			-- if ((n_command and Mask_PASS) = Mask_PASS) then -- PASS command. Send out inputs events through NODE_IN output
			-- 	status(NUM_INPUTS + 1) <= '1'; -- Set PASS led
			-- end if;

			-- if ((n_command and Mask_SEQ) = Mask_SEQ) then -- SEQ command. Send out inputs events through NODE_IN output
			-- 	status(NUM_INPUTS + 2) <= '1'; -- Set SEQ led
			-- end if;

			-- if (((n_command and Mask_CONF_1) = Mask_CONF_1) 
			-- 	or ((n_command and Mask_CONF_2) = Mask_CONF_2)
			-- 	or ((n_command and Mask_CONF_3) = Mask_CONF_3)) then -- CONF command. Send out configuration data through NODE_IN output
			-- 	status(NUM_INPUTS + 3) <= '0'; -- Set CONF led
			-- end if;

			-- if (n_rst_sw = '1') then    -- Software reset. Set all led on
			-- 	status <= (others => '0');
			-- end if;

			if (epA0_read = '1' or ep80_write = '1') then -- ECU or OSU read/write. Set MSB led on
				status(LEDS_BITS_WIDTH - 1) <= '0'; -- Set MSB led
			end if;
		end if;

	end process;

	-- -- Multiplexer that select the data path depending of the command
	-- command_multiplexer : process(n_command, epA0_read, n_ecu_data, n_ecu_ready, --ECU signals
	-- 	ep80_write, ep80_dataout, n_osu_ready --OSU signals
	-- 	)
	-- begin
	-- 	n_ecu_rd    <= epA0_read;
	-- 	epA0_datain <= n_ecu_data;
	-- 	epA0_ready  <= n_ecu_ready;

	-- 	n_osu_wr   <= ep80_write;
	-- 	n_osu_data <= ep80_dataout;
	-- 	ep80_ready <= n_osu_ready;

	-- 	status(LEDS_BITS_WIDTH - 1 downto 5) <= (others => '1'); -- Set all status led off

	-- 	if ((n_command and Mask_MON) = Mask_MON) then -- MON command. Send out captured event to USB
	-- 		status(1) <= '1';         -- Set MON led
	-- 	end if;

	-- 	if ((n_command and Mask_PASS) = Mask_PASS) then -- PASS command. Send out inputs events through NODE_IN output
	-- 		status(2) <= '1';         -- Set PASS led
	-- 	end if;

	-- 	if ((n_command and Mask_SEQ) = Mask_SEQ) then -- SEQ command. Send out inputs events through NODE_IN output 
	-- 		status(3) <= '1';         -- Set SEQ led
	-- 	end if;

	-- 	if ((n_command and Mask_CONF_1) = Mask_CONF_1) then -- CONF command. Send out configuration data through NODE_IN output
	-- 		status(4) <= '1';         -- Set CONF led
	-- 	end if;

	-- 	if ((n_command and Mask_CONF_2) = Mask_CONF_2) then -- CONF command. Send out configuration data through NODE_IN output
	-- 		status(4) <= '1';         -- Set CONF led
	-- 	end if;

	-- end process;

end Behavioral;

