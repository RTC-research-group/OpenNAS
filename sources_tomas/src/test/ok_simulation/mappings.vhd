 --------------------------------------------------------------------------
-- mappings.vhd
--
-- Description:
--  This file contains ok1 mappings for simulation.
--
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package mappings is

	--Endpoint input harness
	constant okHE_DATAL         : integer := 47;
	constant okHE_DATAH         : integer := 78;
	constant okHE_ADDRL         : integer := 36;
	constant okHE_ADDRH         : integer := 43;

	constant okHE_CLK           : integer := 3;
	constant okHE_RESET         : integer := 0;
	constant okHE_READ          : integer := 46;
	constant okHE_WRITE         : integer := 1;
	constant okHE_WIREUPDATE    : integer := 45;
	constant okHE_TRIGUPDATE    : integer := 2;
	constant okHE_BLOCKSTROBE   : integer := 44;
	constant okHE_REGADDRL      : integer := 81;
	constant okHE_REGADDRH      : integer := 112;
	constant okHE_REGWRITE      : integer := 80;
	constant okHE_REGWRITEDATAL : integer := 4;
	constant okHE_REGWRITEDATAH : integer := 35;
	constant okHE_REGREAD       : integer := 79;

	--Endpoint output harness
	constant okEH_DATAL         : integer := 32;
	constant okEH_DATAH         : integer := 63;
	constant okEH_READY         : integer := 64;
	constant okEH_REGREADDATAL  : integer := 0;
	constant okEH_REGREADDATAH  : integer := 31;

end mappings;


package body mappings is


end mappings;