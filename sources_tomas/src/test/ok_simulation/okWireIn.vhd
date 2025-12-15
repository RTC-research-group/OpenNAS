--------------------------------------------------------------------------
-- okWireIn.vhd
--
-- This entity simulates the "Wire In" endpoint.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.parameters.all;
use work.mappings.all;

entity okWireIn is
	port (
		okHE           : in   std_logic_vector(112 downto 0);
		ep_addr        : in   std_logic_vector(7 downto 0);
		ep_dataout     : out  std_logic_vector(31 downto 0)
	);
end okWireIn;

architecture arch of okWireIn is
	signal ti_clk         : std_logic;
	signal ti_reset       : std_logic;
	signal ti_write       : std_logic;
	signal ti_wireupdate  : std_logic;
	signal ti_addr        : std_logic_vector(7 downto 0);
	signal ti_datain      : std_logic_vector(31 downto 0);
	signal ep_datahold    : std_logic_vector(31 downto 0) := x"0000_0000";

begin
	ti_clk           <= okHE(okHE_CLK);
	ti_reset         <= okHE(okHE_RESET);
	ti_write         <= okHE(okHE_WRITE);
	ti_addr          <= okHE(okHE_ADDRH downto okHE_ADDRL);
	ti_datain        <= okHE(okHE_DATAH downto okHE_DATAL);
	ti_wireupdate    <= okHE(okHE_WIREUPDATE);

	process is
	begin
		wait until rising_edge(ti_clk);
		if ((ti_write = '1') and (ti_addr = ep_addr)) then
			ep_datahold <= ti_datain;
			wait for 0 ns;
		end if;
		if (ti_wireupdate = '1') then
			wait for TDOUT_DELAY;
			ep_dataout <= ep_datahold;
			wait for 0 ns;
		end if;
		if (ti_reset = '1') then
			wait for TDOUT_DELAY;
			ep_datahold <= x"0000_0000";
			wait for 0 ns;
			ep_dataout <= x"0000_0000";
			wait for 0 ns;
		end if;
		
	end process;

--	process is
--	begin
--		wait for 1ns;
--		if ((ep_addr < x"00") or (ep_addr > x"1F")) then
--			report "okWireIn endpoint address outside valid range, must be between 0x00 and 0x1F" severity FAILURE;
--			std.env.finish;
--		end if;
--	end process;
end arch;

