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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all; -- @suppress "Deprecated package"

entity Handshake_Out is
	Port (
		rst     : in std_logic;
		clk     : in std_logic;
		ack     : in std_logic;
		dataIn  : in std_logic_vector (15 downto 0);
		load    : in std_logic;
		req     : out std_logic;
		dataOut : out std_logic_vector (15 downto 0);
		busy    : out std_logic
	);
end Handshake_Out;

architecture handout of Handshake_Out is
	
	signal estado   : integer range 0 to 5;
	signal sestado  : integer range 0 to 5;

	begin

		process(load, ack, estado)
		begin
			case estado is
				when 0 =>
					req  <= '1';
					busy <= '0';
					if(load = '1') then
						sestado <= 3;
					else
						sestado <= 0;
					end if;
				when 3 =>	--Estado de setup
					busy    <= '1';
					req     <= '1';
					sestado <= 1;
--				when 4 =>	--Estado de setup
--		
--					busy<='1';
--					req <= '1';
--					sestado <= 1;
				when 1 =>
					busy <= '1';
					req  <= '0';
					if(ack = '0') then
						sestado <= 2;
					else
						sestado <= 1;
					end if;
				when 2 =>
					busy <= '1';
					req  <= '1';
					if(ack = '1') then
						sestado <= 5;
					else
						sestado <= 2;
					end if;
				when 5 =>	--estado de hold
					busy    <= '1';
					req     <= '1';
					sestado <= 0;
				when others=>
					busy    <= '1';
					req     <= '1';
					sestado <= 0;
			end case;
		end process;
 
		process(clk, rst)
		begin
			if (rst = '0') then
				estado  <= 0;
				dataOut <= (others => '0');
			else
				if(clk = '1' and clk'event) then
					estado <= sestado;
					
					if(load = '1' and estado = 0 ) then
						dataOut <= dataIn;
					else
						
					end if;
				else

				end if;
			end if;
		end process;

end handout;

