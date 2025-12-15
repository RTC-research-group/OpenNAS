------------------------------------------------------------------------
-- okRegisterBridge
--
-- This module simulates the "Register Bridge" endpoint.
--
------------------------------------------------------------------------
-- Copyright (c) 2004-2011 Opal Kelly Incorporated
-- $Id$
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.parameters.all;
use work.mappings.all;

entity okRegisterBridge is
	port (
		okHE           : in   std_logic_vector(112 downto 0);
		okEH           : out  std_logic_vector(64 downto 0);
		ep_address     : out  std_logic_vector(31 downto 0);
		ep_write       : out  std_logic;
		ep_dataout     : out  std_logic_vector(31 downto 0);
		ep_read        : out  std_logic;
		ep_datain      : in   std_logic_vector(31 downto 0)
	);
end okRegisterBridge;

architecture arch of okRegisterBridge is
	signal ti_reg_addr        : std_logic_vector(31 downto 0);
	signal ti_reg_write       : std_logic;
	signal ti_reg_write_data  : std_logic_vector(31 downto 0);
	signal ti_reg_read        : std_logic;
	
begin
	ti_reg_addr        <= okHE(okHE_REGADDRH downto okHE_REGADDRL);
	ti_reg_write       <= okHE(okHE_REGWRITE);
	ti_reg_write_data  <= okHE(okHE_REGWRITEDATAH downto okHE_REGWRITEDATAL);
	ti_reg_read        <= okHE(okHE_REGREAD);
	
	ep_address <= ti_reg_addr;
	ep_write   <= ti_reg_write;
	ep_dataout <= ti_reg_write_data;
	ep_read    <= ti_reg_read;
	
	okEH(okEH_REGREADDATAH downto okEH_REGREADDATAL) <= ep_datain;
	okEH(okEH_READY) <= '0';
	okEH(okEH_DATAH downto okEH_DATAL) <= (others => '0');
	
end arch;