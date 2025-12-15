--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                      //
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
		CLK        : in std_logic;		
		RST        : in std_logic;
		CLOCK_DIV  : in std_logic_vector(7 downto 0);
		PDM_CLK	   : out std_logic;
		PDM_DAT    : in std_logic;
		SPIKES_OUT : out std_logic_vector(1 downto 0)
	);
end PDM_Interface;

architecture PDM_Interface_arq of PDM_Interface is

	signal clock_counter : std_logic_vector (7 downto 0);
	signal int_counter   : std_logic_vector (7 downto 0);
	signal PDM_CLK_INT   : std_logic;
	signal PDM_INT       : std_logic;

	begin

		PDM_CLK <= PDM_CLK_INT;

		process (CLK, RST, PDM_INT, PDM_DAT, clock_counter)
		begin
			if(RST = '0') then
				clock_counter <= (others=>'0');
				int_counter   <= (others=>'0');
				PDM_CLK_INT	  <= '0';
				PDM_INT	      <= '0';
				SPIKES_OUT    <= (others=>'0');

			elsif (rising_edge(CLK)) then
				clock_counter <= clock_counter + 1;

				if(clock_counter = CLOCK_DIV) then
					PDM_CLK_INT   <= not PDM_CLK_INT;
					clock_counter <= (others=>'0');
					
					if(PDM_CLK_INT = '1') then
						PDM_INT     <= PDM_DAT;
						int_counter	<= (others=>'0');
					end if;
				end if;

				if(int_counter < x"01") then -- la condición sería equivalente a (int_counter = "00")
					int_counter <= int_counter + 1;

					if(PDM_INT = '1') then
						SPIKES_OUT(1) <='1';
						SPIKES_OUT(0) <='0';
					else
						SPIKES_OUT(1) <='0';
						SPIKES_OUT(0) <='1';
					end if;
				else
					SPIKES_OUT(1) <= '0';
					SPIKES_OUT(0) <= '0';
				end if;
			end if;
		end process;

end PDM_Interface_arq;

