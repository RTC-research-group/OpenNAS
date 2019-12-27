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

entity ramfifo is
	Generic (
		TAM      : INTEGER := 2048; 
		IL       : INTEGER := 11; 
		WL       : INTEGER := 16
	);
	Port (
		clk      : in  STD_LOGIC; 
		wr       : in  STD_LOGIC; 
		rd	     : in  STD_LOGIC;
		rst      : in  STD_LOGIC;
		empty    : out STD_LOGIC;
		full     : out STD_LOGIC;
		data_in  : in  STD_LOGIC_VECTOR(WL-1 downto 0); 
		data_out : out STD_LOGIC_VECTOR(WL-1 downto 0); 
		mem_used : out STD_LOGIC_VECTOR(IL-1 downto 0)
	);
end ramfifo;


 
architecture syn of ramfifo is 

	component dualram
		Generic (
			TAM     : INTEGER := TAM; 
			IL      : INTEGER := IL; 
			WL      : INTEGER := WL
		);
		Port(
			clk     : in  STD_LOGIC;
			wr      : in  STD_LOGIC; 
			index_i : in  STD_LOGIC_VECTOR(IL-1 downto 0); 
			index_o : in  STD_LOGIC_VECTOR(IL-1 downto 0); 
			word_i  : in  STD_LOGIC_VECTOR(WL-1 downto 0); 
			word_o  : out STD_LOGIC_VECTOR(WL-1 downto 0) 
		);
	end component;

	signal index_i : STD_LOGIC_VECTOR(IL-1 downto 0);
	signal index_o : STD_LOGIC_VECTOR(IL-1 downto 0);
	signal iempty  : STD_LOGIC;
	signal ifull   : STD_LOGIC;
	signal ramwr   : STD_LOGIC;
	signal memused : STD_LOGIC_VECTOR(IL-1 downto 0);
	signal dout    : STD_LOGIC_VECTOR(WL-1 downto 0);


	begin

		uut: dualram 
		Generic map (
			TAM     => TAM,
			IL      => IL,
			WL      => WL
		)
		Port map(
			clk     => clk,
			wr      => ramwr,
			index_i => index_i,
			index_o => index_o,
			word_i  => data_in,
			word_o  => dout
		);

		process (clk, wr, rd, rst, ifull, iempty, index_i, index_o, memused) 
		begin 
			if (rst = '0') then
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
				else
				
				end if;
			end if; 
		end process;

		iempty   <= '1' when memused = 0 else '0';
		ifull    <= '1' when memused = TAM-1  else '0';
		empty    <= iempty;
		full     <= ifull;
		ramwr    <= wr and not ifull;
		data_out <= dout when (iempty = '0') else (others => 'Z'); -- Puede eliminarse y puentearse la salida de dualram con la salida de la fifo.
		mem_used <= memused; 
end syn;
 

