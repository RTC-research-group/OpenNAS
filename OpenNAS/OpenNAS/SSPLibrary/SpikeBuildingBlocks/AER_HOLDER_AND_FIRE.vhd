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
		CLK        : in  STD_LOGIC;
		RST        : in  STD_LOGIC;
		SET        : in  STD_LOGIC;
		HOLD_PULSE : out  STD_LOGIC
	);
end AER_HOLDER_AND_FIRE;

architecture Behavioral of AER_HOLDER_AND_FIRE is

	type STATE_TYPE is (IDLE,HOLD);
	signal CS : STATE_TYPE := IDLE;
	signal NS : STATE_TYPE;
	
	begin

		process(RST, SET, CS, NS)
		begin
			case CS is
				when IDLE =>
					HOLD_PULSE <= '0';
					if(SET = '1') then
						NS <= HOLD;
					else
						NS <= IDLE;
					end if;
				when HOLD =>
					HOLD_PULSE <= '1';
					NS         <= HOLD;
				when others =>
					HOLD_PULSE <= '0';		
					NS         <= IDLE;
			end case;
		end process;

		process(CLK, RST, CS, NS)
		begin

			if(CLK = '1' and CLK'event) then
				if(RST = '1') then
					CS <= IDLE;
				else
					CS <= NS;
				end if;
			else
			
			end if;
		end process;
		
end Behavioral;

