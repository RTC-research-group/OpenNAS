--------------------------------------------------------------------------
-- okWireOut.vhd
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

entity okWireOut is
	port (
		okHE           : in   std_logic_vector(112 downto 0);
		okEH           : out  std_logic_vector(64 downto 0);
		ep_addr        : in   std_logic_vector(7 downto 0);
		ep_datain      : in   std_logic_vector(31 downto 0)
	);
end okWireOut;

architecture arch of okWireOut is
	signal ti_clk          : std_logic;
	signal ti_reset        : std_logic;
	signal ti_read         : std_logic;
	signal ti_wireupdate   : std_logic;
	signal ti_addr         : std_logic_vector(7 downto 0);
	signal wirehold        : std_logic_vector(31 downto 0);

begin
	ti_clk           <= okHE(okHE_CLK);
	ti_reset         <= okHE(okHE_RESET);
	ti_read          <= okHE(okHE_READ);
	ti_addr          <= okHE(okHE_ADDRH downto okHE_ADDRL);
	ti_wireupdate    <= okHE(okHE_WIREUPDATE);

	okEH(okEH_DATAH downto okEH_DATAL) <= wirehold when (ti_addr = ep_addr) else (others => '0');
	okEH(okEH_READY) <= '0';
	okEH(okEH_REGREADDATAH downto okEH_REGREADDATAL) <= (others => '0');
	
	process is
	begin
		wait until rising_edge(ti_clk);
		
		if (ti_wireupdate = '1') then
				wirehold <= ep_datain;
				wait for 0 ns;
		end if;

		if (ti_reset = '1') then
			wirehold <= x"0000_0000";
			wait for 0 ns;
		end if;
		
	end process;

--	process is
--	begin
--		wait for 1ns;
--		if ((ep_addr < x"20") or (ep_addr > x"3F")) then
--			report "okWireOut endpoint address outside valid range, must be between 0x20 and 0x3F" severity FAILURE;
--			std.env.finish;
--		end if;
--	end process;
end arch;

