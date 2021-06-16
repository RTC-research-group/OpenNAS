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

entity Dualram is
	Generic (
		TAM     : integer  := 64; 
		IL      : integer  := 6; 
		WL      : integer  := 32
	);
	Port (
		clk     : in  std_logic; 
		wr      : in  std_logic; 
		index_i : in  std_logic_vector(IL-1 downto 0); 
		index_o : in  std_logic_vector(IL-1 downto 0); 
		word_i  : in  std_logic_vector(WL-1 downto 0); 
		word_o  : out std_logic_vector(WL-1 downto 0)); 
end Dualram;


-- Only XST supports RAM inference
-- Infers Dual Port Distributed Ram 
 
 architecture syn of Dualram is 
	
	type ram_type is array (TAM-1 downto 0) of std_logic_vector (WL-1 downto 0); 
	signal RAM : ram_type; 
 
	begin 
	process (clk) 
	begin 
		if (clk'event and clk = '1') then  
			if (wr = '1') then 
				RAM(conv_integer(index_i)) <= word_i; 
			end if; 
		end if; 
	end process;
 
	word_o <= RAM(conv_integer(index_o)); 
 
 end syn;
 

