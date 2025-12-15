--------------------------------------------------------------------------
-- okPipeIn.vhd
--
-- This entity simulates the "Input Pipe" endpoint.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.parameters.all;
use work.mappings.all;

entity okPipeIn is
	port (
		okHE           : in   std_logic_vector(112 downto 0);
		okEH           : out  std_logic_vector(64 downto 0);
		ep_addr        : in   std_logic_vector(7 downto 0);
		ep_write       : out  std_logic;
		ep_dataout     : out  std_logic_vector(31 downto 0)
	);
end okPipeIn;

architecture arch of okPipeIn is
	signal ti_clk     : std_logic;
	signal ti_reset   : std_logic;
	signal ti_write   : std_logic;
	signal ti_addr    : std_logic_vector(7 downto 0);
	signal ti_datain  : std_logic_vector(31 downto 0);

begin
	ti_clk           <= okHE(okHE_CLK);
	ti_reset         <= okHE(okHE_RESET);
	ti_write         <= okHE(okHE_WRITE);
	ti_addr          <= okHE(okHE_ADDRH downto okHE_ADDRL);
	ti_datain        <= okHE(okHE_DATAH downto okHE_DATAL);
	
	okEH(okEH_DATAH downto okEH_DATAL) <= (others => '0');
	okEH(okEH_READY) <= '1' when (ti_addr = ep_addr) else '0';
	okEH(okEH_REGREADDATAH downto okEH_REGREADDATAL) <= (others => '0');

	process is
	begin
	 wait until rising_edge(ti_clk);
		wait for TDOUT_DELAY;
		ep_write <= '0';
		if (ti_reset = '1') then
			ep_dataout <= x"0000_0000";
		elsif ((ti_write = '1') and (ti_addr = ep_addr)) then
			ep_dataout <= ti_datain;
			ep_write <= '1';
		end if;
	end process;

--	process is
--	begin
--		wait for 1ns;
--		if ((ep_addr < x"80") or (ep_addr > x"9F")) then
--			report "okPipeIn endpoint address outside valid range, must be between 0x80 and 0x9F" severity FAILURE;
--			std.env.finish;
--		end if;
--	end process;
end arch;

