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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"

entity AER_Holder_And_Fire is
	Port(
		clk        : in  std_logic;
		rst        : in  std_logic;     -- Debe ser activo en alto porque este reset es provocado por un spike
		set        : in  std_logic;
		hold_pulse : out std_logic
	);
end AER_Holder_And_Fire;

architecture Behavioral of AER_Holder_And_Fire is

	type state_type is (IDLE, HOLD);
	signal CS : state_type := IDLE;
	signal NS : state_type;

begin

	process(set, CS)
	begin
		case CS is
			when IDLE =>
				hold_pulse <= '0';
				if (set = '1') then
					NS <= HOLD;
				else
					NS <= IDLE;
				end if;
			when HOLD =>                -- @suppress "Dead state 'HOLD': state does not have outgoing transitions"
				hold_pulse <= '1';
				NS         <= HOLD;
			when others =>              -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
				hold_pulse <= '0';
				NS         <= IDLE;
		end case;
	end process;

	process(clk)
	begin
		if (clk = '1' and clk'event) then
			if (rst = '1') then
				CS <= IDLE;
			else
				CS <= NS;
			end if;
		else
			
			end if;
	end process;

end Behavioral;

