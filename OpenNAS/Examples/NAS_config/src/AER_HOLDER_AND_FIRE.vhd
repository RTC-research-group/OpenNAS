--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright � 2016  �ngel Francisco Jim�nez-Fern�ndez                      //
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
-- Create Date:    12:35:08 09/06/2007 
-- Design Name: 
-- Module Name:    AER_HOLDER_AND_FIRE - Behavioral 
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
 
entity AER_HOLDER_AND_FIRE is
    Port ( 
		clk        : in  STD_LOGIC;
		rst        : in  STD_LOGIC;		-- Debe ser activo en alto porque este reset es provocado por un spike
		set        : in  STD_LOGIC;
		hold_pulse : out  STD_LOGIC
	);
end AER_HOLDER_AND_FIRE;

architecture Behavioral of AER_HOLDER_AND_FIRE is

	type STATE_TYPE is (IDLE,HOLD);
	signal CS : STATE_TYPE := IDLE;
	signal NS : STATE_TYPE;
	
	begin

		process(rst, set, CS, NS)
		begin
			case CS is
				when IDLE =>
					hold_pulse <= '0';
					if(set = '1') then
						NS <= HOLD;
					else
						NS <= IDLE;
					end if;
				when HOLD =>
					hold_pulse <= '1';
					NS         <= HOLD;
				when others =>
					hold_pulse <= '0';		
					NS         <= IDLE;
			end case;
		end process;

		process(clk, rst, CS, NS)
		begin

			if(clk = '1' and clk'event) then
				if(rst = '1') then
					CS <= IDLE;
				else
					CS <= NS;
				end if;
			else
			
			end if;
		end process;
		
end Behavioral;

