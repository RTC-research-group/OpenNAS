--------------------------------------------------------------------------
-- okTriggerIn.vhd
--
-- This entity simulates the "Trigger In" endpoint.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.parameters.all;
use work.mappings.all;

entity okTriggerIn is
	port (
		okHE           : in   std_logic_vector(112 downto 0);
		ep_addr        : in   std_logic_vector(7 downto 0);
		ep_clk         : in   std_logic;
		ep_trigger     : out  std_logic_vector(31 downto 0):= x"0000_0000"
	);
end okTriggerIn;

architecture arch of okTriggerIn is
	signal ti_clk     : std_logic;
	signal ti_reset   : std_logic;
	signal ti_write   : std_logic;
	signal ti_addr    : std_logic_vector(7 downto 0);
	signal ti_datain  : std_logic_vector(31 downto 0);

	signal eptrig     : std_logic_vector(31 downto 0) := x"0000_0000";
	signal eptrig_p1  : std_logic_vector(31 downto 0) := x"0000_0000";
	signal eptrig_p2  : std_logic_vector(31 downto 0) := x"0000_0000";

begin
	ti_clk           <= okHE(okHE_CLK);
	ti_reset         <= okHE(okHE_RESET);
	ti_write         <= okHE(okHE_WRITE);
	ti_addr          <= okHE(okHE_ADDRH downto okHE_ADDRL);
	ti_datain        <= okHE(okHE_DATAH downto okHE_DATAL);

	process is
	begin
		wait until (rising_edge(ti_reset) or rising_edge(ep_clk));
		if (ti_reset = '1' ) then
			wait for TTRIG_DELAY;
			ep_trigger <= x"0000_0000";
			eptrig_p1 <= x"0000_0000";
			eptrig_p2 <= x"0000_0000";
			wait for 0 ns;
		elsif (ep_clk = '1') then
		  eptrig_p1 <= eptrig;
		  eptrig_p2 <= eptrig_p1;
			wait for TTRIG_DELAY;
			ep_trigger <= eptrig_p1 xor eptrig_p2;
			wait for 0 ns;
		end if;
	end process;

	process is
	begin
		wait until (rising_edge(ti_clk));
		if (ti_reset = '1') then
			eptrig <= x"0000_0000";
			wait for 0 ns;
		elsif ( (ti_write = '1') and (ti_addr = ep_addr) ) then
			eptrig <= (eptrig xor ti_datain);
			wait for 0 ns;
		end if;
	
	end process;

--	process is
--	begin
--		wait for 1ns;
--		if ((ep_addr < x"40") or (ep_addr > x"5F")) then
--			report "okTriggerIn endpoint address outside valid range, must be between 0x40 and 0x5F" severity FAILURE;
--			std.env.finish;
--		end if;
--	end process;

end arch;

