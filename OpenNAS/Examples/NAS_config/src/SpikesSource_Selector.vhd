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
-- Create Date: 22.03.2017 16:12:19
-- Design Name: 
-- Module Name: SpikesSource_Selector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use ieee.numeric_std.all;


entity SpikesSource_Selector is
    Port ( 
		source_sel  : in  std_logic;
		i2s_data    : in  std_logic_vector(1 downto 0);
		pdm_data    : in  std_logic_vector(1 downto 0);
		spikes_data : out std_logic_vector(1 downto 0)
	);
end SpikesSource_Selector;

architecture Behavioral of SpikesSource_Selector is

	begin
		process (source_sel, i2s_data, pdm_data)
		begin
			case source_sel is
				when '0'    => spikes_data <= i2s_data;
				when '1'    => spikes_data <= pdm_data;
				when others => spikes_data <= (others => '0');
			end case;
		end process;

end Behavioral;
