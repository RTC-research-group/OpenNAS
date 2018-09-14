--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                     //
--//                                                                             //
--//    This file is part of OpenNAS.                                            //
--//                                                                             //
--//    OpenNAS is free software: you can redistribute it and/or modify          //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    OpenNAS is distributed in the hope that it will be useful,               //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:38:39 02/24/2016 
-- Design Name: 
-- Module Name:    PDM_Interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PDM_Interface is
port (
	clk				: in std_logic;		
	rst				: in std_logic;
	clock_div : in std_logic_vector(7 downto 0);
	PDM_CLK		: out std_logic;
	PDM_DAT		: in std_logic;
	SPIKES_OUT			: out std_logic_vector(1 downto 0)
	);
end PDM_Interface;

architecture PDM_Interface_arq of PDM_Interface is

signal clock_counter: std_logic_vector (7 downto 0):=(others=>'0');
signal int_counter: std_logic_vector (7 downto 0):=(others=>'0');
signal PDM_CLK_INT: std_logic :='0';
signal PDM_INT: std_logic:='0';
begin


PDM_CLK <= PDM_CLK_INT;


process (clk, rst, PDM_INT ,PDM_DAT,clock_counter)
begin

	if(rst = '0') then
		clock_counter <=(others=>'0');
		PDM_CLK_INT<='0';
	elsif (clk='1' and clk'event) then
		clock_counter<=clock_counter+1;
		if(clock_counter = clock_div) then
			PDM_CLK_INT<= not PDM_CLK_INT;
			clock_counter<=(others=>'0');
			
			if(PDM_CLK_INT='1') then
				PDM_INT<=PDM_DAT;
				int_counter<=(others=>'0');
			end if;
		end if;
			if(int_counter<x"01") then
				int_counter<=int_counter+1;
				if(PDM_INT='1') then
					SPIKES_OUT(1)<='1';
					SPIKES_OUT(0)<='0';
				else
					SPIKES_OUT(1)<='0';
					SPIKES_OUT(0)<='1';
				end if;
			else
				SPIKES_OUT(1)<='0';
				SPIKES_OUT(0)<='0';
			end if;

	end if;


end process;


end PDM_Interface_arq;

