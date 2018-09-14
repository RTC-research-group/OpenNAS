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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AER_HOLDER_AND_FIRE is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SET : in  STD_LOGIC;
           HOLD_TIME : in  STD_LOGIC_VECTOR (15 downto 0);
           HOLD_PULSE : out  STD_LOGIC;
			  FIRE_PULSE : out  STD_LOGIC);
end AER_HOLDER_AND_FIRE;

architecture Behavioral of AER_HOLDER_AND_FIRE is
--type STATE_TYPE is (IDLE,HOLD,RE_HOLD,FIRE);
type STATE_TYPE is (IDLE,HOLD);
	signal CS: STATE_TYPE:=IDLE;
	signal NS: STATE_TYPE;
--	signal count: STD_LOGIC_VECTOR (15 downto 0):=(others=>'0');
begin

--Ahora ya no dispara
FIRE_PULSE<='0';

process(rst,set,cs,ns)--,count,hold_time)
begin
	case CS is
		when IDLE=>
			HOLD_PULSE<='0';
--			FIRE_PULSE<='0';
			if(SET='1') then
				NS<=HOLD;
			else
				NS<=IDLE;
			end if;
		when HOLD=>
			HOLD_PULSE<='1';
--			FIRE_PULSE<='0';
--			if(SET='1') then
--				NS<=RE_HOLD;
--			elsif(count=HOLD_TIME) then
--				NS<=FIRE;
--			else
				NS<=HOLD;
--			end if;
--		when RE_HOLD=>
--			HOLD_PULSE<='1';
--			FIRE_PULSE<='0';
--			NS<=HOLD;
--		when FIRE=>
--			HOLD_PULSE<='0';
--			FIRE_PULSE<='1';
--			NS<=IDLE;
		when others=>
			HOLD_PULSE<='0';
--			FIRE_PULSE<='0';		
			NS<=IDLE;
	end case;

end process;

process(clk,rst,cs,ns)
begin

	if(clk='1' and clk'event) then
		if(RST='1') then
--			count<=(others=>'0');
			CS<=IDLE;
		else
			CS<=NS;
--			case CS is
--				when IDLE=>
--					count<=(others=>'0');
--				when HOLD=>
--					count<=count+1;
--				when RE_HOLD=>
--					count<=(others=>'0');
--				when others=>
--					count<=(others=>'0');
--			end case;
			
		end if;
	end if;

end process;
end Behavioral;

