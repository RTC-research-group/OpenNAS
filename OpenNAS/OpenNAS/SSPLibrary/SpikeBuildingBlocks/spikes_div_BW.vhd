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

entity spikes_div_BW is
	Generic (
		GL          : INTEGER := 16
	);
    Port ( 
		CLK         : in  STD_LOGIC;
		RST         : in  STD_LOGIC;	 
		spikes_div  : in  STD_LOGIC_VECTOR(GL-1 downto 0);
		SPIKE_IN_P  : in  STD_LOGIC;
		SPIKE_IN_N  : in  STD_LOGIC;           
		spike_out_p : out STD_LOGIC;
		spike_out_n : out STD_LOGIC);
end spikes_div_BW;

architecture Behavioral of spikes_div_BW is

	signal ciclo      : STD_LOGIC_VECTOR (GL-2 downto 0);	
	signal ciclo_wise : STD_LOGIC_VECTOR (GL-2 downto 0);

	signal data_int   : STD_LOGIC_VECTOR (GL-1 downto 0);
	signal data_temp  : STD_LOGIC_VECTOR (GL-2 downto 0);

	begin
		--SIN SIGNO!
		data_temp <= data_int(GL-2 downto 0);

		process(clk, rst, ciclo, spikes_div)
		begin
			if(rst = '1') then
				data_int   <= (others => '0');
				ciclo_wise <= (others => '0');
			elsif(clk = '1' and clk'event) then
				data_int <= spikes_div(GL-1 downto 0);
			else
			
			end if;
			
			for i in 0 to GL-2 loop
				ciclo_wise(GL-2-i) <= ciclo(i);
			end loop;
			
		end process;

		process(clk, rst, spikes_div, ciclo, ciclo_wise, data_temp)
		begin
			if(rst = '1') then
				ciclo       <= (others => '0');
				spike_out_p <= '0';
				spike_out_n <= '0';
			elsif(clk = '1' and clk'event) then
				if(Spike_in_n = '1' or Spike_in_p = '1') then
					ciclo <= ciclo + 1;				
				else
					ciclo <= ciclo;
				end if;
				
				if((conv_integer(data_temp) > conv_integer(ciclo_wise))) then
					if(data_int(GL-1) = '1') then
						spike_out_p <= Spike_in_n;
						spike_out_n <= Spike_in_p;			
					else
						spike_out_p <= Spike_in_p;
						spike_out_n <= Spike_in_n;
					end if;
				else
				  spike_out_p <= '0';
				  spike_out_n <= '0';
				end if;	
			end if;
		end process;

end Behavioral;

