--------------------------------------------------------------------------
-- okTriggerOut.vhd
--
-- This entity simulates the "Trigger Out" endpoint.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.parameters.all;
use work.mappings.all;

entity okTriggerOut is
	port (
		okHE           : in   std_logic_vector(112 downto 0);
		okEH           : out  std_logic_vector(64 downto 0);
		ep_addr        : in   std_logic_vector(7 downto 0);
		ep_clk         : in   std_logic;
		ep_trigger     : in   std_logic_vector(31 downto 0)
	);
end okTriggerOut;

architecture arch of okTriggerOut is
	signal ti_clk          : std_logic;
	signal ti_reset        : std_logic;
	signal ti_read         : std_logic;
	signal ti_trigupdate   : std_logic;
	signal ti_addr         : std_logic_vector(7 downto 0);

	signal eptrig         : std_logic_vector(31 downto 0) := x"00000000";
	signal ep_trigger_p1  : std_logic_vector(31 downto 0) := x"00000000";
	signal trighold       : std_logic_vector(31 downto 0) := x"00000000";
	signal captrig        : std_logic := '0';
	signal captrig_p1     : std_logic := '0';
	signal captrig_p2     : std_logic := '0';

begin
	ti_clk           <= okHE(okHE_CLK);
	ti_reset         <= okHE(okHE_RESET);
	ti_read          <= okHE(okHE_READ);
	ti_addr          <= okHE(okHE_ADDRH downto okHE_ADDRL);
	ti_trigupdate    <= okHE(okHE_TRIGUPDATE);
	
	okEH(okEH_DATAH downto okEH_DATAL) <= trighold when (ti_addr = ep_addr) else (others => '0');
	okEH(okEH_READY) <= '0';
	okEH(okEH_REGREADDATAH downto okEH_REGREADDATAL) <= x"0000_0000";
	
	process is
	begin
		wait until (rising_edge(ti_clk));
		if (ti_reset = '1') then
			captrig <= '0';
			wait for 0 ns;
		elsif (ti_trigupdate = '1') then
			captrig <= not(captrig);
			wait for 0 ns;
		end if;
		
	end process;
	
	process is
	begin
		wait until (rising_edge(ti_reset) or rising_edge(ep_clk));
		if (ti_reset = '1') then
			wait for 0 ns;
			trighold <= x"0000_0000";
			wait for 0 ns;
			eptrig <= x"0000_0000";
			wait for 0 ns;
			ep_trigger_p1 <= x"0000_0000";
			wait for 0 ns;
			captrig_p1 <= '0';
			wait for 0 ns;
			captrig_p2 <= '0';
			wait for 0 ns;
		elsif (ep_clk = '1') then
			captrig_p1 <= captrig;
			captrig_p2 <= captrig_p1;
			ep_trigger_p1 <= ep_trigger;
			if ((captrig_p1 xor captrig_p2) = '1') then
				trighold <= eptrig;
				wait for 0 ns;
				eptrig <= ep_trigger;
				wait for 0 ns;
			else
				eptrig <= (eptrig or (ep_trigger and not ep_trigger_p1));
				wait for 0 ns;
			end if;
		end if;
		
	end process;

	process is
	begin
		wait for 1ns;
		if ((ep_addr < x"60") or (ep_addr > x"7F")) then
			report "okTriggerOut endpoint address outside valid range, must be between 0x60 and 0x7F" severity FAILURE;
			std.env.finish;
		end if;
	end process;
end arch;

