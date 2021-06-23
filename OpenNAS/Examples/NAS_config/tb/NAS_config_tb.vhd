--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2016  Angel Francisco Jimenez-Fernandez                    //
--//                                                                             //
--//    This file is part of OpenNAS.                                            //
--//                                                                             //
--//    NSSOC is free software: you can redistribute it and/or modify            //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    NSSOC is distributed in the hope that it will be useful,                 //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

-------------------------------------------------------------------------------
-- Title      : Testbench for OpenNas_Cascade_STEREO_64ch with configuration feature
-- Project    : OpenNAS
-------------------------------------------------------------------------------
-- File       : NAS_config_Tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2021-06-03
-- Last update: 2021-06-03
-- Platform   : any
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-20  1.0      dgutierrez	Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
use WORK.OpenNas_top_pkg.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY NAS_SOC_top_tb IS

END NAS_SOC_top_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF NAS_SOC_top_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
	COMPONENT OpenNas_Cascade_STEREO_64ch IS
		PORT (
			-- Clock and reset
			clock         : IN  STD_LOGIC;
			rst_ext_n       : IN  STD_LOGIC;
			-- Input interface: PDM
			pdm_clk_left  : OUT STD_LOGIC;
			pdm_dat_left  : IN  STD_LOGIC;
			pdm_clk_right : OUT STD_LOGIC;
			pdm_dat_right : IN  STD_LOGIC;
			-- Input interface: I2S
			i2s_bclk      : IN  STD_LOGIC;
			i2s_d_in      : IN  STD_LOGIC;
			i2s_lr        : IN  STD_LOGIC;
			--Config Bus
			config_data   : IN  STD_LOGIC_VECTOR(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
			config_addr   : IN  STD_LOGIC_VECTOR(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
			config_wren   : IN  STD_LOGIC;
			--Spikes Source Selector
			source_sel    : IN  STD_LOGIC;
			-- Output interface
			aer_data_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			aer_req       : OUT STD_LOGIC;
			aer_ack       : IN  STD_LOGIC
		);
	END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
	---------------------------------------------------------------------------
	
	-- Component generics

	-- Component input ports
	SIGNAL clock         : STD_LOGIC := '0';
	SIGNAL rst_ext       : STD_LOGIC := '0';
	SIGNAL pdm_dat_left  : STD_LOGIC := '0';
	SIGNAL pdm_dat_right : STD_LOGIC := '0';
	SIGNAL i2s_d_in      : STD_LOGIC := '0';
	SIGNAL i2s_bclk      : STD_LOGIC := '0';
	SIGNAL i2s_lr        : STD_LOGIC := '0';
	SIGNAL config_data   : STD_LOGIC_VECTOR(CONFIG_BUS_BIT_WIDTH - 1 downto 0) := (OTHERS => '0');
	SIGNAL config_addr   : STD_LOGIC_VECTOR(CONFIG_BUS_BIT_WIDTH - 1 downto 0) := (OTHERS => '0');
	SIGNAL config_wren   : STD_LOGIC := '0';
	SIGNAL source_sel    : STD_LOGIC := '0';
	SIGNAL AER_ACK       : STD_LOGIC := '1';

	-- Component output ports
	SIGNAL pdm_clk_left  : STD_LOGIC;
	SIGNAL pdm_clk_right : STD_LOGIC;
	SIGNAL aer_req       : STD_LOGIC;
	SIGNAL aer_data_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);

	---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

	-- Clock
	CONSTANT c_sys_clock_period : TIME := 20 ns;

	-- Constants
	CONSTANT c_I2S_sck_num_sys_clock_cycles : INTEGER := 8;

	-- Testbench signals
	SIGNAL tb_start_stimuli : STD_LOGIC := '0';
	SIGNAL tb_end_stimuli   : STD_LOGIC := '0';

	-- Testbench files
	TYPE t_integer_file IS FILE OF INTEGER;

	CONSTANT c_tb_absolute_path         : STRING := "/home/arios/Projects/OpenNAS/OpenNAS/Examples/NAS_config/tb/"; -- Absolute path to the testbench files

	FILE tb_input_left_samples_file  : t_integer_file OPEN read_mode IS c_tb_absolute_path & "stimuli/sin_96e3fs_0_5d_1000a_700Hz_left.bin";
	FILE tb_input_right_samples_file : t_integer_file OPEN read_mode IS c_tb_absolute_path & "stimuli/sin_96e3fs_0_5d_1000a_700Hz_right.bin";

	FILE tb_output_NAS_SOC_aer_events_file : TEXT OPEN write_mode IS c_tb_absolute_path & "results/nas_config_out_events_test.txt";

BEGIN  -- architecture Behavioral

	---------------------------------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
	---------------------------------------------------------------------------
	uut : OpenNas_Cascade_STEREO_64ch
		PORT MAP (
			--// Clock and reset
			clock => clock,
			rst_ext_n => rst_ext,
			--// Input PDM interface
			pdm_clk_left => pdm_clk_left,
			pdm_dat_left => pdm_dat_left,
			pdm_clk_right => pdm_clk_right,
			pdm_dat_right => pdm_dat_right,
			--// Input I2S interface
			i2s_bclk    => i2s_bclk,
			i2s_d_in   => i2s_d_in,
			i2s_lr    => i2s_lr,
			--// Config bus
			config_data => config_data,
			config_addr => config_addr,
			config_wren => config_wren,
			--// Spikes source selector
			source_sel => source_sel,
			--// Output AER interface
			aer_data_out  => aer_data_out,
			aer_req   => aer_req,
			aer_ack   => AER_ACK
		);

    ---------------------------------------------------------------------------
    -- Clocks generation
	---------------------------------------------------------------------------
	
	--
	-- Main clock
	--
	clock <= NOT clock AFTER c_sys_clock_period/2;

    --
    -- I2S sck generation
    --
	p_I2S_sck_generation_process : PROCESS (clock, rst_ext)
		VARIABLE v_internal_counter : INTEGER := 0;
	BEGIN
		IF (rst_ext = '0') THEN
			v_internal_counter := 0;
			i2s_bclk          <= '0';
		ELSE
			IF (clock'EVENT AND clock = '1') THEN
				IF (v_internal_counter = c_I2S_sck_num_sys_clock_cycles) THEN
					v_internal_counter := 0;
					i2s_bclk          <= NOT i2s_bclk;
				ELSE
					v_internal_counter := v_internal_counter + 1;
					i2s_bclk          <= i2s_bclk;
				END IF;
			ELSE

			END IF;
		END IF;
	END PROCESS p_I2S_sck_generation_process;

	--
	-- I2S ws generation
	--
	p_I2S_ws_generation_process : PROCESS (i2s_bclk, rst_ext)
		VARIABLE v_internal_counter : INTEGER := 0;
	BEGIN
		IF (rst_ext = '0') THEN
			v_internal_counter := 0;
			i2s_lr           <= '0';
		ELSE
			IF (i2s_bclk'event AND i2s_bclk = '0') THEN
				IF (v_internal_counter = 31) THEN
					v_internal_counter := 0;
					i2s_lr           <= NOT i2s_lr;
				ELSE
					v_internal_counter := v_internal_counter + 1;
					i2s_lr           <= i2s_lr;
				END IF;
			ELSE

			END IF;
		END IF;
	END PROCESS p_I2S_ws_generation_process;

	-----------------------------------------------------------------------------
    -- Processes
	-----------------------------------------------------------------------------


	-- purpose: Initial reset process
    -- type   :
    -- inputs : 
    -- outputs: 
    p_initial_reset : PROCESS
    BEGIN
        --
        -- First reset
        --

        -- Report the module is under reset
        REPORT "Initial reset..." SEVERITY NOTE;

        -- Start reset
        rst_ext <= '0';
        -- Hold it for 1 us
        WAIT FOR 1 us;

        -- Clear reset
        rst_ext <= '1';

        -- Report the reset has been clear
        REPORT "Reset cleared!" SEVERITY NOTE;

        -- Wait for a few clock cycles
		wait for c_sys_clock_period*10;
		
		-- Synchronize with the I2S ws signal
		WAIT UNTIL i2s_lr'event AND i2s_lr = '0';
        WAIT UNTIL i2s_lr'event AND i2s_lr = '1';
        WAIT UNTIL i2s_lr'event AND i2s_lr = '0';

        -- Set the begining of the testbench flag to 1
        tb_start_stimuli <= '1';
        REPORT "Starting the testbench..." SEVERITY NOTE;

        -- Wait forever
        WAIT;
	END PROCESS p_initial_reset;
	
	-- purpose: Simulate the AER interface from the receiver
    -- type   : combinational
    -- inputs : o_out_aer_req
    -- outputs: i_out_aer_ack
    AER_ACK <= aer_req AFTER (c_sys_clock_period * 2);



    -- purpose: Set the signals to generate the stimuli
    -- type   : combinational
    -- inputs : 
    -- outputs: 
	p_stimuli : PROCESS
		-- Variable for storing the readed audio sample
		VARIABLE v_audio_sample : INTEGER := 0;
		-- Variable for storing the readed audio sample in a binary vector
		VARIABLE v_i2s_audio_sample : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	BEGIN

		-- Wait until the start stimuli flag is enabled
		WAIT UNTIL tb_start_stimuli = '1';

		-- Wait until ws clock is 0 for starting with a left sample
		WAIT UNTIL i2s_lr = '0';

		-- Wait until falling edge of sck clock to start sending bits
		WAIT UNTIL i2s_bclk'event AND i2s_bclk = '0';
		
		-- While there are data in either left or right sample files
		WHILE (NOT endfile(tb_input_left_samples_file)) OR (NOT endfile(tb_input_right_samples_file)) LOOP
			-- Check if it is left or right sample
			IF (i2s_lr = '0') THEN
				-- Read value from left sample file
				read(tb_input_left_samples_file, v_audio_sample);
			ELSE
				-- Read value from right sample file
				read(tb_input_right_samples_file, v_audio_sample);
			END IF;

			-- Convert the integer value to std logic vector (32 bits)
			v_i2s_audio_sample(31 DOWNTO 0) := conv_std_logic_vector(v_audio_sample, 32);

			-- For each falling edge of I2S sck clock, transmit a bit
			FOR j IN 31 DOWNTO 0 LOOP
				i2s_d_in <= v_i2s_audio_sample(j);
				WAIT UNTIL i2s_bclk'event AND i2s_bclk = '0';
			END LOOP;

		END LOOP;

		-- When there is no more data in one of those files, the testbench has finished
		tb_end_stimuli <= '1';

		-- Report the end of the simulation
		REPORT "End of the simulation!" SEVERITY NOTE;

		-- Close the sample files
		file_close(tb_input_left_samples_file);
		file_close(tb_input_right_samples_file);

		WAIT;

	END PROCESS p_stimuli;

    -- purpose: Save out the testbench results into a file
    -- type   : combinational
    -- inputs : 
    -- outputs: 
	p_save_results : PROCESS
		-- Line variable for writing out into the textfile
		VARIABLE v_OLINE_AER                 : LINE;
		-- String variable for getting the timestamp
		VARIABLE v_sim_time_str              : STRING(1 TO 20); -- 20 chars should be enough
		VARIABLE v_sim_time_len              : NATURAL;
		-- Events counter
		VARIABLE v_out_events_counter_NAS    : INTEGER := 0;

	BEGIN
		
		-- Loop while the simulation doesn't finish
		WHILE tb_end_stimuli = '0' LOOP
			-- Wait until there is a new AER data
			WAIT UNTIL AER_ACK = '0';

			-- Take the current simulation time
			v_sim_time_len := TIME'image(now)'length;
			v_sim_time_str := (OTHERS => ' ');
			v_sim_time_str(1 TO v_sim_time_len) := TIME'image(now);
			REPORT "Sim time string.......:'" & v_sim_time_str & "'";

			-- Increase the event counter
			v_out_events_counter_NAS := v_out_events_counter_NAS + 1;
			
			-- Print output events counter
			REPORT "Output event counter NAS: " & INTEGER'image(v_out_events_counter_NAS);

			-- Writing the event address ( lr + freq_channel + polarity)
			write(v_OLINE_AER, conv_integer(unsigned(aer_data_out(15 DOWNTO 0))), right, 1);
			write(v_OLINE_AER, ',', right, 1);

			-- Writing the timestamp
			write(v_OLINE_AER, v_sim_time_str, right, 1);

			-- Writing the line into the output text file
			writeline(tb_output_NAS_SOC_aer_events_file, v_OLINE_AER);

		END LOOP;

		-- Close NAS SOC RESULTS file
		file_close(tb_output_NAS_SOC_aer_events_file);

		WAIT;

	END PROCESS p_save_results;

END Behavioral;