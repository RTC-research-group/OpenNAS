library ieee;
use ieee.std_logic_1164.all;
use work.axis2nas_pkg.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.std_logic_arith.all;           -- @suppress "Deprecated package"
use IEEE.std_logic_unsigned.all;        -- @suppress "Deprecated package"

entity axi2nas_tb is
end entity axi2nas_tb;

architecture rtl of axi2nas_tb is
	---------------------------------------------------------------------------
	-- UUT signals declaration
	---------------------------------------------------------------------------

	-- Component generics

	-- Component input ports
	signal clock         : std_logic := '0';
	signal rst_ext_n     : std_logic := '0';
	signal pdm_dat_left  : std_logic := '0';
	signal pdm_dat_right : std_logic := '0';
	signal i2s_d_in      : std_logic := '0';
	signal i2s_bclk      : std_logic := '0';
	signal i2s_lr        : std_logic := '0';
	signal source_sel    : std_logic := '0';
	signal aer_ack       : std_logic := '1';
	signal s_axi_tvalid  : std_logic := '0';
	signal s_axi_tlast   : std_logic := '0';
	signal s_axi_tdata   : std_logic_vector(AXI_BUS_BIT_WIDTH - 1 downto 0);

	-- Component output ports
	signal pdm_clk_left  : std_logic;
	signal pdm_clk_right : std_logic;
	signal aer_req       : std_logic;
	signal s_axi_tready  : std_logic;
	signal aer_data_out  : std_logic_vector(15 downto 0);

	-- Connection signals
	signal config_data : std_logic_vector(NAS_CONFIG_BUS_BIT_WIDTH - 1 downto 0);
	signal config_addr : std_logic_vector(NAS_CONFIG_BUS_BIT_WIDTH - 1 downto 0);
	signal config_wren : std_logic := '0';

	---------------------------------------------------------------------------
	-- Testbench signals declaration
	---------------------------------------------------------------------------

	-- Clock
	constant c_sys_clock_period : time := 20 ns;

	-- Constants
	constant c_I2S_sck_num_sys_clock_cycles : integer := 8;

	-- Testbench signals
	signal tb_start_stimuli  : std_logic := '0';
	signal tb_end_stimuli    : std_logic := '0';
	signal tb_config_stimuli : std_logic := '0';

	-- Testbench files
	type t_integer_file is file of integer;

	constant c_tb_absolute_path : string := "/home/arios/Projects/OpenNAS/OpenNAS/Examples/NAS_config/tb/"; -- Absolute path to the testbench files

	file tb_input_left_samples_file  : t_integer_file open read_mode is c_tb_absolute_path & "stimuli/sin_96e3fs_0_5d_1000a_700Hz_left.bin";
	file tb_input_right_samples_file : t_integer_file open read_mode is c_tb_absolute_path & "stimuli/sin_96e3fs_0_5d_1000a_700Hz_right.bin";

	file tb_output_NAS_SOC_aer_events_file : text open write_mode is c_tb_absolute_path & "results/nas_config_out_events_test.txt";

	file config_params_file : text open read_mode is c_tb_absolute_path & "../vivado/ip_repo/AXIS2NAS/tb/nas_config_params.ncfg";
begin

	---------------------------------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
	---------------------------------------------------------------------------
	uut_0 : entity work.OpenNas_Cascade_STEREO_64ch
		port map(
			clock         => clock,
			rst_ext_n     => rst_ext_n,
			pdm_clk_left  => pdm_clk_left,
			pdm_dat_left  => pdm_dat_left,
			pdm_clk_right => pdm_clk_right,
			pdm_dat_right => pdm_dat_right,
			i2s_bclk      => i2s_bclk,
			i2s_d_in      => i2s_d_in,
			i2s_lr        => i2s_lr,
			config_data   => config_data,
			config_addr   => config_addr,
			config_wren   => config_wren,
			source_sel    => source_sel,
			aer_data_out  => aer_data_out,
			aer_req       => aer_req,
			aer_ack       => aer_ack
		);

	uut_1 : entity work.axis2nas
		port map(
			s_axi_tready    => s_axi_tready,
			s_axi_tvalid    => s_axi_tvalid,
			s_axi_tlast     => s_axi_tlast,
			s_axi_tdata     => s_axi_tdata,
			nas_addr_config => config_addr,
			nas_data_config => config_data,
			nas_wren_config => config_wren
		);

	---------------------------------------------------------------------------
	-- Clocks generation
	---------------------------------------------------------------------------

	--
	-- Main clock
	--
	clock <= not clock after c_sys_clock_period / 2;

	--
	-- I2S sck generation
	--
	p_I2S_sck_generation_process : process(clock, rst_ext_n)
		variable v_internal_counter : integer := 0;
	begin
		if (rst_ext_n = '0') then
			v_internal_counter := 0;
			i2s_bclk           <= '0';
		else
			if (clock'EVENT and clock = '1') then
				if (v_internal_counter = c_I2S_sck_num_sys_clock_cycles) then
					v_internal_counter := 0;
					i2s_bclk           <= not i2s_bclk;
				else
					v_internal_counter := v_internal_counter + 1;
					i2s_bclk           <= i2s_bclk;
				end if;
			else

			end if;
		end if;
	end process p_I2S_sck_generation_process;

	--
	-- I2S ws generation
	--
	p_I2S_ws_generation_process : process(i2s_bclk, rst_ext_n)
		variable v_internal_counter : integer := 0;
	begin
		if (rst_ext_n = '0') then
			v_internal_counter := 0;
			i2s_lr             <= '0';
		else
			if (i2s_bclk'event and i2s_bclk = '0') then
				if (v_internal_counter = 31) then
					v_internal_counter := 0;
					i2s_lr             <= not i2s_lr;
				else
					v_internal_counter := v_internal_counter + 1;
					i2s_lr             <= i2s_lr;
				end if;
			else

			end if;
		end if;
	end process p_I2S_ws_generation_process;

	-----------------------------------------------------------------------------
	-- Processes
	-----------------------------------------------------------------------------
	-- purpose: Initial reset process
	-- type   :
	-- inputs : 
	-- outputs: 
	p_initial_reset : process
	begin
		--
		-- First reset
		--

		-- Report the module is under reset
		report "Initial reset..." severity note;

		-- Start reset
		rst_ext_n <= '0';
		-- Hold it for 1 us
		wait FOR 1 us;

		-- Clear reset
		rst_ext_n <= '1';

		-- Report the reset has been clear
		report "Reset cleared!" severity note;

		-- Wait for a few clock cycles
		wait for c_sys_clock_period * 10;

		-- Synchronize with the I2S ws signal
		wait until i2s_lr'event and i2s_lr = '0';
		wait until i2s_lr'event and i2s_lr = '1';
		wait until i2s_lr'event and i2s_lr = '0';

		-- Set the begining of the testbench flag to 1
		tb_start_stimuli <= '1';
		report "Starting the testbench..." severity note;
		
		-- Wait for a few clock cycles to start the configuration
		wait for c_sys_clock_period * 1000;
		tb_config_stimuli <= '1';
		-- Wait until the configuration is done
		wait until rising_edge(s_axi_tlast);
		tb_config_stimuli <= '0';

		-- Wait forever
		wait;
	end process p_initial_reset;

	-- purpose: Simulate the AER interface from the receiver
	-- type   : combinational
	-- inputs : o_out_aer_req
	-- outputs: i_out_aer_ack
	aer_ack <= aer_req after (c_sys_clock_period * 2);

	-- purpose: Set the signals to generate the stimuli
	-- type   : combinational
	-- inputs : 
	-- outputs: 
	p_stimuli : process
		-- Variable for storing the readed audio sample
		variable v_audio_sample     : integer                       := 0;
		-- Variable for storing the readed audio sample in a binary vector
		variable v_i2s_audio_sample : std_logic_vector(31 downto 0) := (others => '0');
	begin
		-- Wait until the start stimuli flag is enabled
		wait until tb_start_stimuli = '1';

		-- Wait until ws clock is 0 for starting with a left sample
		wait until i2s_lr = '0';

		-- Wait until falling edge of sck clock to start sending bits
		wait until i2s_bclk'event and i2s_bclk = '0';

		-- While there are data in either left or right sample files
		while (not endfile(tb_input_left_samples_file)) or (not endfile(tb_input_right_samples_file)) loop
			-- Check if it is left or right sample
			if (i2s_lr = '0') then
				-- Read value from left sample file
				read(tb_input_left_samples_file, v_audio_sample);
			else
				-- Read value from right sample file
				read(tb_input_right_samples_file, v_audio_sample);
			end if;

			-- Convert the integer value to std logic vector (32 bits)
			v_i2s_audio_sample(31 downto 0) := conv_std_logic_vector(v_audio_sample, 32);

			-- For each falling edge of I2S sck clock, transmit a bit
			for j in 31 downto 0 loop
				i2s_d_in <= v_i2s_audio_sample(j);
				wait until i2s_bclk'event and i2s_bclk = '0';
			end loop;

		end loop;

		-- When there is no more data in one of those files, the testbench has finished
		tb_end_stimuli <= '1';

		-- Report the end of the simulation
		report "End of the simulation!" severity note;

		-- Close the sample files
		file_close(tb_input_left_samples_file);
		file_close(tb_input_right_samples_file);

		wait;

	end process p_stimuli;

	-- purpose: Save out the testbench results into a file
	-- type   : combinational
	-- inputs : 
	-- outputs: 
	p_save_results : process
		-- Line variable for writing out into the textfile
		variable v_OLINE_AER              : line;
		-- String variable for getting the timestamp
		variable v_sim_time_str           : string(1 to 20); -- 20 chars should be enough
		variable v_sim_time_len           : natural;
		-- Events counter
		variable v_out_events_counter_NAS : integer := 0;

	begin
		-- Loop while the simulation doesn't finish
		while tb_end_stimuli = '0' loop
			-- Wait until there is a new AER data
			wait until aer_ack = '0';

			-- Take the current simulation time
			v_sim_time_len                      := TIME'image(now)'length;
			v_sim_time_str                      := (others => ' ');
			v_sim_time_str(1 to v_sim_time_len) := time'image(now);
			report "Sim time string.......:'" & v_sim_time_str & "'";

			-- Increase the event counter
			v_out_events_counter_NAS := v_out_events_counter_NAS + 1;

			-- Print output events counter
			report "Output event counter NAS: " & integer'image(v_out_events_counter_NAS);

			-- Writing the event address ( lr + freq_channel + polarity)
			write(v_OLINE_AER, conv_integer(unsigned(aer_data_out(15 downto 0))), right, 1);
			write(v_OLINE_AER, ',', right, 1);

			-- Writing the timestamp
			write(v_OLINE_AER, v_sim_time_str, right, 1);

			-- Writing the line into the output text file
			writeline(tb_output_NAS_SOC_aer_events_file, v_OLINE_AER);

		end loop;

		-- Close NAS SOC RESULTS file
		file_close(tb_output_NAS_SOC_aer_events_file);

		wait;

	end process p_save_results;

	-- purpose: Configure the NAS using the values store in the yaml file
	-- type   : Sequential
	-- inputs : 
	-- outputs: 
	p_axi_config : process(clock, rst_ext_n)
		variable line_v : line;
		variable data   : integer;
	begin
		if (rst_ext_n = '0') then
			s_axi_tvalid <= '0';
			s_axi_tlast  <= '0';
			s_axi_tdata  <= (others => '0');

		elsif (rising_edge(clock)) then
			if (tb_config_stimuli = '1' and not endfile(config_params_file) and s_axi_tready = '1') then
				s_axi_tvalid                                                       <= '1';
				readline(config_params_file, line_v);
				read(line_v, data);
				s_axi_tdata(AXI_BUS_BIT_WIDTH - 1 downto NAS_CONFIG_BUS_BIT_WIDTH) <= conv_std_logic_vector(data, 16);
				if (data = 527) then
					s_axi_tlast <= '1';
				end if;
				readline(config_params_file, line_v);
				read(line_v, data);
				s_axi_tdata(NAS_CONFIG_BUS_BIT_WIDTH - 1 downto 0)                 <= conv_std_logic_vector(data, 16);

			else
				s_axi_tdata  <= (others => '0');
				s_axi_tlast  <= '0';
				s_axi_tvalid <= '0';
			end if;
		end if;
	end process p_axi_config;

end architecture rtl;
