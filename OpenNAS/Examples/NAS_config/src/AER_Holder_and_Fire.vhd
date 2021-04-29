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

entity AER_Holder_and_Fire is
	Port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		set        : in  std_logic;
		hold_pulse : out std_logic
	);
end AER_Holder_and_Fire;

architecture Behavioral of AER_Holder_and_Fire is

	type state_type is (IDLE, HOLD);
	signal cs : state_type := IDLE;
	signal ns : state_type;

begin

	process(clk)
	begin
		if (clk = '1' and clk'event) then
			if (rst = '1') then
				cs <= IDLE;
			else
				cs <= ns;
			end if;
		else
		
		end if;
	end process;

	process(set, cs)
	begin
		case cs is
			when IDLE =>
				hold_pulse <= '0';
				if (set = '1') then
					ns <= HOLD;
				else
					ns <= IDLE;
				end if;
			when HOLD => -- TODO este estado nunca sale de aquí a no ser que haya un reset
				hold_pulse <= '1';
				ns         <= HOLD;
			when others =>
				hold_pulse <= '0';
				ns         <= IDLE;
		end case;
	end process;

end Behavioral;

