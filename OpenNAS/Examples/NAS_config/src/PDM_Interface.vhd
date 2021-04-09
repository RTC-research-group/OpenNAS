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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all; -- @suppress "Deprecated package"

entity PDM_Interface is
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		clock_div  : in  std_logic_vector(7 downto 0);
		pdm_clk    : out std_logic;
		pdm_dat    : in  std_logic;
		spikes_out : out std_logic_vector(1 downto 0)
	);
end PDM_Interface;

architecture PDM_Interface_arq of PDM_Interface is

	signal clock_counter : std_logic_vector(7 downto 0);
	signal int_counter   : std_logic_vector(7 downto 0);
	signal pdm_clk_int   : std_logic;
	signal pdm_int       : std_logic;

begin

	pdm_clk <= pdm_clk_int;

	process(clk, rst)
	begin
		if (rst = '0') then
			clock_counter <= (others => '0');
			int_counter   <= (others => '0');
			pdm_clk_int   <= '0';
			pdm_int       <= '0';
			spikes_out    <= (others => '0');

		elsif (rising_edge(clk)) then
			clock_counter <= clock_counter + 1;

			if (clock_counter = clock_div) then
				pdm_clk_int   <= not pdm_clk_int;
				clock_counter <= (others => '0');

				if (pdm_clk_int = '1') then
					pdm_int     <= pdm_dat;
					int_counter <= (others => '0');
				end if;
			end if;

			if (int_counter < x"01") then -- la condici�n ser�a equivalente a (int_counter = "00")
				int_counter <= int_counter + 1;

				if (pdm_int = '1') then
					spikes_out(1) <= '1';
					spikes_out(0) <= '0';
				else
					spikes_out(1) <= '0';
					spikes_out(0) <= '1';
				end if;
			else
				spikes_out(1) <= '0';
				spikes_out(0) <= '0';
			end if;
		end if;
	end process;

end PDM_Interface_arq;

