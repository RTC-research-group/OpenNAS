--------------------------------------------------------------------------
-- okWireOR.vhd
--
-- This module implements the okWireOR for simulation usage.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity okWireOR is
	generic (
		N     : integer := 1
	);
	port (
		okEH   : out std_logic_vector(64 downto 0);
		okEHx  : in  std_logic_vector(N*65-1 downto 0)
	);
end okWireOR;
architecture archWireOR of okWireOR is
begin
	process (okEHx)
		variable okEH_int : STD_LOGIC_VECTOR(64 downto 0);
	begin
		okEH_int:= '0' & x"0000_0000_0000_0000";
		for i in N-1 downto 0 loop
			okEH_int := okEH_int or okEHx( (i*65+64) downto (i*65) );
		end loop;
		okEH <= okEH_int;
	end process;
end archWireOR;
