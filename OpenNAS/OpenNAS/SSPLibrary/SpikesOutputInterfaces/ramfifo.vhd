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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ramfifo is
generic (TAM: in integer:= 2048; IL: in integer:=11; WL: in integer:=16);
 port (clk  : in std_logic; 
 	wr   : in std_logic; 
	rd	: in std_logic;
	rst: in std_logic;
	empty: out std_logic;
	full: out std_logic;
 	data_in   : in std_logic_vector(WL-1 downto 0); 
 	data_out  : out std_logic_vector(WL-1 downto 0); 
	mem_used : out std_logic_vector(IL-1 downto 0));
end ramfifo;


 
architecture syn of ramfifo is 

	COMPONENT dualram
	generic (TAM: in integer:= TAM; IL: in integer:=IL; WL: in integer:=WL);
	PORT(
		clk : IN std_logic;
	 	wr   : in std_logic; 
 		index_i : in std_logic_vector(IL-1 downto 0); 
 		index_o : in std_logic_vector(IL-1 downto 0); 
 		word_i   : in std_logic_vector(WL-1 downto 0); 
 		word_o  : out std_logic_vector(WL-1 downto 0) 
		);
	END COMPONENT;

	SIGNAL index_i :  std_logic_vector(IL-1 downto 0):=(others=>'0');
	SIGNAL index_o :  std_logic_vector(IL-1 downto 0):=(others=>'0');
	SIGNAL iempty: std_logic;
	SIGNAL ifull: std_logic;
	SIGNAL ramwr: std_logic;
	SIGNAL memused: std_logic_vector(IL-1 downto 0):=(others=>'0');
	SIGNAL dout: std_logic_vector(WL-1 downto 0);


BEGIN

	uut: dualram generic map (TAM,IL,WL)
	PORT MAP(
		clk => clk,
		wr => ramwr,
		index_i => index_i,
		index_o => index_o,
		word_i => data_in,
		word_o => dout
		);

process (clk, wr, rd, rst, ifull, iempty, index_i, index_o, memused) 
begin 
 	if (rst ='0') then
		index_i <= (others=>'0');
		index_o <= (others=>'0');
		memused <= (others=>'0');
	elsif (clk'event and clk = '1') then
   	if (wr = '1' and rd = '1') then
			index_i <= index_i + 1;
			index_o <= index_o + 1;
			--memused <= memused; -- Al ser proceso sincrono y no cambiar memused no es necesaria esta linea.
		elsif (wr = '1' and ifull = '0') then 
			index_i <= index_i + 1;
			memused <= memused + 1;
 		elsif (rd = '1' and iempty = '0') then
			index_o <= index_o + 1;
			memused <= memused - 1;
		end if;
 	end if; 
 end process;

 iempty <= '1' when memused = 0 else '0';
 ifull <= '1' when  memused = TAM-1  else '0';
 empty <= iempty;
 full <= ifull;
 ramwr <= wr and not ifull;
 data_out <= dout when (iempty='0') else (others => 'Z'); -- Puede eliminarse y puentearse la salida de dualram con la salida de la fifo.
 mem_used <= memused; 
 end syn;
 

