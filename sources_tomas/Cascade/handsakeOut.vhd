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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity handshakeOut is
	Port (
		rst     : in STD_LOGIC;
		clk     : in STD_LOGIC;
		ack     : in STD_LOGIC;
		dataIn  : in STD_LOGIC_VECTOR (15 downto 0);
		load    : in STD_LOGIC;
		req     : out STD_LOGIC;
		dataOut : out STD_LOGIC_VECTOR (15 downto 0);
		busy    : out STD_LOGIC
	);
end handshakeOut;

architecture handout of handshakeOut is
	
	signal estado   : INTEGER range 0 to 5;
	signal sestado  : INTEGER range 0 to 5;

	begin

		process(load, ack, estado, datain, estado)
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

