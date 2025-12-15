--------------------------------------------------------------------------
-- Sim.vhd
--
-- A simple example for getting started with FrontPanel simulation.
-- This sample illustrates the use of the FrontPanel simulation files
--   and calls to the simulated FrontPanel Host Interface.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2015 Opal Kelly Incorporated
-- $Rev: 80 $ $Date: 2015-01-06 11:26:37 -0800 (Tue, 06 Jan 2015) $
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use work.FRONTPANEL.all;

entity sim is
	port(
		okUH  : in    STD_LOGIC_VECTOR (4  downto 0);
		okHU  : out   STD_LOGIC_VECTOR (2  downto 0);
		okUHU : inout STD_LOGIC_VECTOR (31 downto 0);
		led   : out   STD_LOGIC_vector (7  downto 0)
	);
end sim;

architecture arch of sim is
	signal okClk  : std_logic;
	signal okHE   : std_logic_vector(112 downto 0);
	signal okEH   : std_logic_vector(64  downto 0);
	signal okEHx  : std_logic_vector(65*4-1 downto 0);

	signal ep00wire : std_logic_vector(31 downto 0);
	signal ep01wire : std_logic_vector(31 downto 0);
	signal ep20wire : std_logic_vector(31 downto 0);

	signal epModeTrig  : std_logic_vector(31 downto 0);

	signal epPipeIn    : std_logic_vector(31 downto 0);
	signal epPipeWrite : std_logic;

	signal epPipeOut   : std_logic_vector(31 downto 0);
	signal epPipeRead  : std_logic;

	signal regWrite     : std_logic;
	signal regRead      : std_logic;
	signal regAddress   : std_logic_vector(31 downto 0);
	signal regWriteData : std_logic_vector(31 downto 0);
	signal regReadData  : std_logic_vector(31 downto 0);
	type   RAM_ARRAY is array(1023 downto 0) of std_logic_vector(31 downto 0);
	signal block_ram    : RAM_ARRAY;

	constant MODE_LFSR       : std_logic_vector (1 downto 0) := b"01";
	constant MODE_COUNTER    : std_logic_vector (1 downto 0) := b"10";
	constant MODE_OFF        : std_logic_vector (1 downto 0) := b"00";
	constant MODE_CONTINUOUS : std_logic_vector (1 downto 0) := b"01";
	constant MODE_PIPED      : std_logic_vector (1 downto 0) := b"10";

	signal lfsr         : std_logic_vector(31 downto 0);
	signal reset        : std_logic;
	signal ep01_ref     : std_logic_vector(31 downto 0);
	signal LFSR_MODE    : std_logic_vector(1 downto 0) := MODE_OFF;
	signal REFRESH_MODE : std_logic_vector(1 downto 0) := MODE_OFF;
	signal led_data     : bit_vector(1023 downto 0) := (others => '0');
	signal led_store    : std_logic_vector(15 downto 0) := x"0000";
	signal led_temp     : bit_vector(31 downto 0);
	signal clk_en       : std_logic;
	signal clock_count  : std_logic_vector(31 downto 0) := x"0000_0000";

begin
	
	-- Wires update on okClk
	-- Keep the design synchronous by deriving reset
	--    directly from okWireIn endpoint
	reset <= ep00wire(0);

	-- Select mode
	process(okClk)
	begin
		if rising_edge(okClk) then
			case epModeTrig(4 downto 0) is
				when b"00001" => LFSR_MODE <= MODE_LFSR;
				when b"00010" => LFSR_MODE <= MODE_COUNTER;
				when b"00100" => REFRESH_MODE <= MODE_OFF;
				when b"01000" => REFRESH_MODE <= MODE_CONTINUOUS;
				when b"10000" => REFRESH_MODE <= MODE_PIPED;
				when others   => LFSR_MODE <= LFSR_MODE;
				                 REFRESH_MODE <= REFRESH_MODE;
			end case;
		end if;
	end process;

	-- LFSR/Counter
	process(okClk)
	begin
		if rising_edge(okClk) then
			if reset = '1' then
				lfsr <= x"0000_0000";
				ep01_ref <= x"0000_0000";
				epPipeOut <= x"0000_0000";
			end if;

			ep20wire <= lfsr;

			case REFRESH_MODE is
				when MODE_OFF =>
					lfsr <= lfsr;
				when MODE_CONTINUOUS =>
					case LFSR_MODE is
						when MODE_LFSR =>
								if ep01wire /= ep01_ref then
									lfsr <= ep01wire;
									ep01_ref <= ep01wire;
								else
									lfsr <= lfsr(30 downto 0) & (lfsr(31) xor lfsr(21) xor lfsr(1));
								end if;
						when MODE_COUNTER =>
								lfsr <= lfsr + b"1";
						when others => lfsr <= lfsr;
					end case;
				when MODE_PIPED =>
					-- When prompted, PipeOut the current lfsr value
					if epPipeRead = '1' then
						case LFSR_MODE is
							when MODE_LFSR =>
								epPipeOut <= lfsr;
								lfsr <= lfsr(30 downto 0) & (lfsr(31) xor lfsr(21) xor lfsr(1));
							when MODE_COUNTER =>
								epPipeOut <= lfsr;
								lfsr <= lfsr + b"1";
							when others => lfsr <= lfsr;
						end case;
					end if;
				when others => lfsr <= lfsr;
			end case;
		end if;
	end process;

	-- When prompted, update the values used by the LEDs
	process(okClk)
	begin
		if rising_edge(okClk) then
			if reset = '1' then
				led_temp <= x"0000_0000";
				led_data <= (others => '0');
				led_store <= x"0000";
				led <= not x"00";
			end if;

			led_temp <= led_data(1023 downto 992);
			led_data <= led_data sll 32;
			led_data (31 downto 0) <= led_temp;

			if epPipeWrite = '1' then
				led_data(31 downto 0) <= to_bitvector(epPipeIn);
			end if;

			-- LEDs get lower bytes of PipeIn XOR'd with upper bytes
			if clk_en = '1' then
				led_store <= to_stdlogicvector(led_data(15 downto 0));
				led <= not (led_store(15 downto 8) xor led_store(7 downto 0));
			end if;
		end if;
	end process;

	-- Slows the rate at which LEDs update so the changing values are visible
	process(okClk)
	begin
		if rising_edge(okClk) then
			clock_count <= clock_count + b"1";

			if (clock_count and x"0000_00f1") > x"0000_0000" then
				clk_en <= '0';
			else 
				clk_en <= '1';
			end if;
		end if;
	end process;

	-- Implied block of RAM for use with the okRegisterBridge
	process(okClk)
		variable intAddress : integer;
	begin
		if rising_edge(okClk) then
			if reset= '1' then
				regReadData <= x"0000_0000";
				block_ram <= (others=> x"0000_0000");
			end if;

			-- Std_logic_vector to integer conversion from IEEE.std_logic_unsigned
			intAddress := conv_integer(regAddress(9 downto 0));

			if regWrite = '1' then
				block_ram(intAddress) <= regWriteData;
			elsif regRead = '1' then
				regReadData <= block_ram(intAddress);
			end if;
		end if;
	end process;

	okHI : okHost port map(okUH=>okUH, okHU=>okHU, okUHU=>okUHU, okClk=>okClk, okHE=>okHE, okEH=>okEH);

	okWO : okWireOr generic map (N=>4) port map (okEH=>okEH, okEHx=>okEHx);

	ep00 : okWireIn  port map (okHE=>okHE,                                    ep_addr=>x"00", ep_dataout=>ep00wire);
	ep01 : okWireIn  port map (okHE=>okHE,                                    ep_addr=>x"01", ep_dataout=>ep01wire);
	ep20 : okWireOut port map (okHE=>okHE, okEH=>okEHx( 1*65-1 downto 0*65 ), ep_addr=>x"20", ep_datain =>ep20wire);

	epMode : okTriggerIn port map (okHE=>okHE, ep_addr=>x"40", ep_clk=>okClk, ep_trigger=>epModeTrig);

	epPipe80 : okPipeIn  port map (okHE=>okHE, okEH=>okEHx( 2*65-1 downto 1*65 ), ep_addr=>x"80", ep_dataout=>epPipeIn,  ep_write=>epPipeWrite);
	epPipea0 : okPipeOut port map (okHE=>okHE, okEH=>okEHx( 3*65-1 downto 2*65 ), ep_addr=>x"a0", ep_datain =>epPipeOut, ep_read=>epPipeRead);

	regBridge : okRegisterBridge port map (okHE=>okHE, okEH=>okEHx( 4*65-1 downto 3*65 ), ep_write=>regWrite, ep_read=>regRead,
		ep_address=>regAddress, ep_dataout=>regWriteData, ep_datain=>regReadData);

end arch;