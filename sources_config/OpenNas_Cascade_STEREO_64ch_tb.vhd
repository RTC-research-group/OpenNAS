--///////////////////////////////////////////////////////////////////////////////
--//                                                                           //
--//    Testbench for OpenNas_Cascade_STEREO_64ch                              //
--//                                                                           //
--///////////////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"
use ieee.math_real.all;
use work.OpenNas_top_pkg.all;

entity OpenNas_Cascade_STEREO_64ch_tb is
end OpenNas_Cascade_STEREO_64ch_tb;

architecture testbench of OpenNas_Cascade_STEREO_64ch_tb is

	-- Clock period definitions
	constant CLOCK_PERIOD : time := 20.833 ns;  -- 48 MHz
	constant PDM_FREQ     : real := 3125000.0;  -- 3.125 MHz PDM clock
	constant I2S_BCLK_FREQ: real := 3072000.0;  -- 3.072 MHz I2S bit clock (64*fs for 48kHz)
	
	-- Test tone frequency parameters
	constant TEST_FREQ_I2S : real := 20.0;  -- Test tone frequency for I2S (Hz) - CONFIGURABLE
	constant TEST_FREQ_PDM : real := 20.0;  -- Test tone frequency for PDM (Hz) - CONFIGURABLE
	constant I2S_SAMPLE_RATE : real := 48000.0;  -- I2S sample rate (Hz)
	
	-- DUT signals
	signal clock         : std_logic := '0';
	signal rst_n         : std_logic := '0';
	signal pdm_clk_left  : std_logic;
	signal pdm_dat_left  : std_logic := '0';
	signal pdm_clk_right : std_logic;
	signal pdm_dat_right : std_logic := '0';
	signal i2s_bclk      : std_logic := '0';
	signal i2s_d_in      : std_logic := '0';
	signal i2s_lr        : std_logic := '0';
	signal source_sel    : std_logic := '0';
	signal config_data   : std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0) := (others => '0');
	signal config_addr   : std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0) := (others => '0');
	signal config_wren   : std_logic := '0';
	signal aer_data_out  : std_logic_vector(AER_DATA_BUS_BIT_WIDTH - 1 downto 0);
	signal aer_req       : std_logic;
	signal aer_ack       : std_logic := '0';
	
	-- Test control signals
	signal test_running  : boolean := true;
	signal i2s_enable    : boolean := false;
	signal pdm_enable    : boolean := false;
	
	-- I2S generation signals
	signal i2s_sample_counter : integer := 0;
	signal i2s_bit_counter    : integer := 0;
	signal i2s_current_sample : std_logic_vector(23 downto 0) := (others => '0');
	
	-- PDM generation signals
	signal pdm_sample_counter : integer := 0;
	signal pdm_sigma_delta    : integer := 0;

begin

	-- Instantiate the Unit Under Test (UUT)
	UUT: entity work.OpenNas_Cascade_STEREO_64ch
		Port map (
			clock         => clock,
			rst_n         => rst_n,
			pdm_clk_left  => pdm_clk_left,
			pdm_dat_left  => pdm_dat_left,
			pdm_clk_right => pdm_clk_right,
			pdm_dat_right => pdm_dat_right,
			i2s_bclk      => i2s_bclk,
			i2s_d_in      => i2s_d_in,
			i2s_lr        => i2s_lr,
			source_sel    => source_sel,
			config_data   => config_data,
			config_addr   => config_addr,
			config_wren   => config_wren,
			aer_data_out  => aer_data_out,
			aer_req       => aer_req,
			aer_ack       => aer_ack
		);

	-- Clock generation process (48 MHz)
	clock_process: process
	begin
		while test_running loop
			clock <= '0';
			wait for CLOCK_PERIOD / 2;
			clock <= '1';
			wait for CLOCK_PERIOD / 2;
		end loop;
		wait;
	end process;

	-- I2S bit clock generation (3.072 MHz)
	i2s_bclk_process: process
	begin
		while test_running loop
			i2s_bclk <= '0';
			wait for 162.76 ns;  -- ~3.072 MHz
			i2s_bclk <= '1';
			wait for 162.76 ns;
		end loop;
		wait;
	end process;

	-- I2S data generation process
	i2s_data_gen_process: process(i2s_bclk)
		variable sample_phase : real := 0.0;
		variable sample_value : real;
		variable sample_int   : integer;
	begin
		if rising_edge(i2s_bclk) and i2s_enable then
			-- I2S frame: 32 bits left + 32 bits right = 64 bits total
			if i2s_bit_counter = 0 then
				-- Generate new sample at the start of left channel
				sample_phase := (real(i2s_sample_counter) / I2S_SAMPLE_RATE) * TEST_FREQ_I2S * 2.0 * MATH_PI;
				sample_value := sin(sample_phase);
				sample_int := integer(sample_value * 8388607.0);  -- 24-bit signed max
				
				if sample_int > 8388607 then
					sample_int := 8388607;
				elsif sample_int < -8388608 then
					sample_int := -8388608;
				end if;
				
				i2s_current_sample <= conv_std_logic_vector(sample_int, 24);
				i2s_sample_counter <= i2s_sample_counter + 1;
			end if;
			
			-- LR signal: 0 = left channel, 1 = right channel
			if i2s_bit_counter < 32 then
				i2s_lr <= '0';  -- Left channel
				if i2s_bit_counter < 24 then
					i2s_d_in <= i2s_current_sample(23 - i2s_bit_counter);
				else
					i2s_d_in <= '0';  -- Padding
				end if;
			else
				i2s_lr <= '1';  -- Right channel
				if i2s_bit_counter < 56 then
					i2s_d_in <= i2s_current_sample(55 - i2s_bit_counter);
				else
					i2s_d_in <= '0';  -- Padding
				end if;
			end if;
			
			i2s_bit_counter <= i2s_bit_counter + 1;
			if i2s_bit_counter >= 63 then
				i2s_bit_counter <= 0;
			end if;
		end if;
	end process;

	-- PDM data generation process for left channel
	pdm_left_gen_process: process(pdm_clk_left)
		variable sample_phase : real := 0.0;
		variable sample_value : real;
		variable sample_int   : integer;
		variable error        : integer := 0;
	begin
		if rising_edge(pdm_clk_left) and pdm_enable then
			-- Generate sine wave sample
			sample_phase := (real(pdm_sample_counter) * PDM_FREQ / 1000000.0) * TEST_FREQ_PDM * 2.0 * MATH_PI;
			sample_value := sin(sample_phase);
			sample_int := integer(sample_value * 32767.0);  -- 16-bit signed
			
			-- Simple sigma-delta modulation
			error := sample_int - pdm_sigma_delta;
			
			if error >= 0 then
				pdm_dat_left <= '1';
				pdm_sigma_delta <= pdm_sigma_delta + 32767;
			else
				pdm_dat_left <= '0';
				pdm_sigma_delta <= pdm_sigma_delta - 32767;
			end if;
			
			-- Apply feedback
			pdm_sigma_delta <= pdm_sigma_delta + (error / 16);
			
			pdm_sample_counter <= pdm_sample_counter + 1;
		end if;
	end process;

	-- PDM data generation process for right channel (same as left for simplicity)
	pdm_right_gen_process: process(pdm_clk_right)
		variable sample_phase : real := 0.0;
		variable sample_value : real;
		variable sample_int   : integer;
		variable error        : integer := 0;
		variable sigma_delta  : integer := 0;
		variable sample_cnt   : integer := 0;
	begin
		if rising_edge(pdm_clk_right) and pdm_enable then
			-- Generate sine wave sample
			sample_phase := (real(sample_cnt) * PDM_FREQ / 1000000.0) * TEST_FREQ_PDM * 2.0 * MATH_PI;
			sample_value := sin(sample_phase);
			sample_int := integer(sample_value * 32767.0);
			
			-- Simple sigma-delta modulation
			error := sample_int - sigma_delta;
			
			if error >= 0 then
				pdm_dat_right <= '1';
				sigma_delta := sigma_delta + 32767;
			else
				pdm_dat_right <= '0';
				sigma_delta := sigma_delta - 32767;
			end if;
			
			-- Apply feedback
			sigma_delta := sigma_delta + (error / 16);
			
			sample_cnt := sample_cnt + 1;
		end if;
	end process;

	-- AER acknowledge generator (simple handshake)
	aer_ack_process: process(clock)
		variable ack_delay : integer := 0;
	begin
		if rising_edge(clock) then
			if aer_req = '1' and aer_ack = '0' then
				if ack_delay < 3 then
					ack_delay := ack_delay + 1;
				else
					aer_ack <= '1';
					ack_delay := 0;
				end if;
			else
				aer_ack <= '0';
			end if;
		end if;
	end process;

	-- Main test stimulus process
	stimulus_process: process
		-- Procedure to write configuration
		procedure write_config(addr: integer; data: integer) is
		begin
			wait until rising_edge(clock);
			config_addr <= conv_std_logic_vector(addr, CONFIG_BUS_BIT_WIDTH);
			config_data <= conv_std_logic_vector(data, CONFIG_BUS_BIT_WIDTH);
			config_wren <= '1';
			wait until rising_edge(clock);
			config_wren <= '0';
			wait until rising_edge(clock);
		end procedure;
		
		variable addr_offset : integer;
	begin
		-- Initial reset
		report "Starting testbench..." severity note;
		rst_n <= '0';
		source_sel <= '0';
		wait for 200 ns;
		rst_n <= '1';
		wait for 100 ns;
		
		-- ========================================================================
		-- PART 1: Configuration of all configurable modules
		-- ========================================================================
		report "PART 1: Configuring modules..." severity note;
		
		-- Configure PDM2Spikes Left (base address 0x0000, 4 parameters)
		report "  Configuring PDM2Spikes Left..." severity note;
		for i in 0 to 3 loop
			write_config(16#0000# + i, PDM2Spikes_DEFAULT_parameter(i));
		end loop;
		
		-- Configure PDM2Spikes Right (base address 0x0004, 4 parameters)
		report "  Configuring PDM2Spikes Right..." severity note;
		for i in 0 to 3 loop
			write_config(16#0004# + i, PDM2Spikes_DEFAULT_parameter(i));
		end loop;
		
		-- Configure I2S2Spikes (base address 0x0008, 1 parameter)
		report "  Configuring I2S2Spikes..." severity note;
		write_config(16#0008#, conv_integer(unsigned(I2S2Spikes_DEFAULT_parameter)));
		
		-- Configure Cascade Filter Bank Left (base address 0x0009, 260 parameters = 65 channels * 4)
		report "  Configuring Cascade Filter Bank Left..." severity note;
		addr_offset := 16#0009#;
		for ch in 0 to NUM_CHANNELS loop
			for param in 0 to 3 loop
				write_config(addr_offset, CASCADE_FILTER_DEFAULT_parameter(ch * 4 + param));
				addr_offset := addr_offset + 1;
			end loop;
		end loop;
		
		-- Configure Cascade Filter Bank Right (base address 0x010D, 260 parameters = 65 channels * 4)
		report "  Configuring Cascade Filter Bank Right..." severity note;
		addr_offset := 16#010D#;
		for ch in 0 to NUM_CHANNELS loop
			for param in 0 to 3 loop
				write_config(addr_offset, CASCADE_FILTER_DEFAULT_parameter(ch * 4 + param));
				addr_offset := addr_offset + 1;
			end loop;
		end loop;
		
		report "Configuration completed!" severity note;
		wait for 1 us;
		
		-- ========================================================================
		-- PART 2: I2S Input Test
		-- ========================================================================
		report "PART 2: Testing I2S input with " & real'image(TEST_FREQ_I2S) & " Hz tone..." severity note;
		source_sel <= '0';  -- Select I2S
		wait for 100 ns;
		i2s_enable <= true;
		
		-- Run I2S test for several milliseconds
		wait for 50 ms;
		
		i2s_enable <= false;
		report "I2S test completed!" severity note;
		wait for 1 us;
		
		-- ========================================================================
		-- PART 3: PDM Input Test
		-- ========================================================================
		report "PART 3: Testing PDM input with " & real'image(TEST_FREQ_PDM) & " Hz tone..." severity note;
		source_sel <= '1';  -- Select PDM
		wait for 100 ns;
		pdm_enable <= true;
		
		-- Run PDM test for several milliseconds
		wait for 50 ms;
		
		pdm_enable <= false;
		report "PDM test completed!" severity note;
		wait for 1 us;
		
		-- ========================================================================
		-- End of simulation
		-- ========================================================================
		report "Testbench completed successfully!" severity note;
		test_running <= false;
		wait;
	end process;

end testbench;
