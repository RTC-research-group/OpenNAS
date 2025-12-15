--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright � 2016  �ngel Francisco Jim��nez-Fern�ndez                     //
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

entity Spike_Int_n_Gen_BW is
	Generic (
		GL          : INTEGER := 12; 
		SAT         : INTEGER := 2047
	);
    Port ( 
		CLK         : in  STD_LOGIC;
		RST         : in  STD_LOGIC;
		FREQ_DIV    : in  STD_LOGIC_VECTOR(7 downto 0);
		spike_in_p  : in  STD_LOGIC;
		spike_in_n  : in  STD_LOGIC;
		spike_out_p : out STD_LOGIC;
		spike_out_n : out STD_LOGIC
	);
end Spike_Int_n_Gen_BW;

architecture Behavioral of Spike_Int_n_Gen_BW is

	signal ciclo      : STD_LOGIC_VECTOR (GL-2 downto 0);	--TOCAR AQUI
	signal ciclo_wise : STD_LOGIC_VECTOR (GL-2 downto 0);
	signal spike      : STD_LOGIC;
	signal integrator : SIGNED (GL-1 downto 0);
	signal data_temp  : STD_LOGIC_VECTOR (GL-2 downto 0);
	signal CE         : STD_LOGIC;
	signal tmp_count  : STD_LOGIC_VECTOR(7 downto 0);
	
	begin

		process(ciclo)
		begin
			for i in 0 to GL-2 loop
				ciclo_wise(GL-2-i) <= ciclo(i);
			end loop;
		end process;

		data_temp <= conv_std_logic_vector(abs(signed(integrator)), GL-1);

		process(spike, integrator)
		begin
			if(integrator > 0) then
				spike_out_p <= spike;
				spike_out_n <= '0';
			elsif (integrator < 0) then
				spike_out_p <= '0';
				spike_out_n <= spike;			
			else
				spike_out_p <= '0';
				spike_out_n <= '0';
			end if;
		end process;


		process(clk, rst, integrator, spike, ciclo, spike_in_p, spike_in_n)
		begin
			
			if(rst = '1') then
				integrator <= (others=>'0');
				ciclo      <= (others=>'0');
				tmp_count  <= (others=>'0');
				CE         <= '0';
				spike      <= '0';
			else
				if(clk = '1' and clk'event) then
					if(spike_in_p = '1' and spike_in_n = '0' and integrator < SAT)then
						integrator <= integrator + 1;
					elsif(spike_in_p = '0' and spike_in_n = '1' and integrator > -SAT)then
						integrator <= integrator-1;			
					end if;
				
					if(freq_div = tmp_count) then
						tmp_count <= (others => '0');
						ciclo     <= ciclo + 1;				
						CE        <= '1';
					else
						tmp_count <= tmp_count + 1;
						CE        <= '0';
					end if;
				
					if(data_temp = 0) then
						spike <= '0';
					else
						if (CE = '1' and (conv_integer(data_temp) > conv_integer(ciclo_wise))) then
							spike <= '1';
						else
							spike <= '0';
						end if;
					end if;
				else
				
				end if;
			end if;
		end process;
end Behavioral;

