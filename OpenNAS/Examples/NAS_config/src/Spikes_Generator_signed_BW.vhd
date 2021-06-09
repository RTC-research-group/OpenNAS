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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Spikes_Generator_signed_BW is
    Port ( 
		clk      : in  STD_LOGIC;
		rst_n      : in  STD_LOGIC;
		freq_div : in  STD_LOGIC_VECTOR(15 downto 0);
		data_in  : in  STD_LOGIC_VECTOR(19 downto 0);
		wr       : in  STD_LOGIC;
		spikes_p  : out STD_LOGIC;
		spikes_n  : out STD_LOGIC
	);
end Spikes_Generator_signed_BW;

architecture Behavioral of Spikes_Generator_signed_BW is

	signal ciclo      : STD_LOGIC_VECTOR (18 downto 0);	
	signal ciclo_wise : STD_LOGIC_VECTOR (18 downto 0);
	signal pulse      : STD_LOGIC;
	signal data_int   : STD_LOGIC_VECTOR (19 downto 0);
	signal data_temp  : STD_LOGIC_VECTOR (18 downto 0);
	signal ce         : STD_LOGIC;
	signal tmp_count  : STD_LOGIC_VECTOR(15 downto 0);

	begin

		process(clk, rst_n)
		begin
			if(rst_n = '0') then
				data_int <= (others => '0');
			elsif(clk = '1' and clk'event) then
				if (wr = '1') then
					data_int <= data_in;
				else

				end if;
			else

			end if;
		end process;

		process(ciclo) --combinational bit-wise operation
		begin
			for i in 0 to 18 loop
				ciclo_wise(18-i) <= ciclo(i);
			end loop;
		end process;

		data_temp <= conv_std_logic_vector(abs(signed(data_int)),19);

		process(clk, rst_n, data_in, pulse, ciclo, ciclo_wise, data_temp)
		begin
			if(rst_n = '0') then
				ciclo     <= (others=>'0');
				tmp_count <= (others=>'0');
				ce        <= '0';
				spikes_p   <= '0';
				spikes_n   <= '0';			
				pulse     <= '0';	
			else
				if(clk = '1' and clk'event) then
					if(freq_div = tmp_count) then
						tmp_count <= (others=>'0');
						ciclo     <= ciclo+1;				
						ce        <= '1';
					else
						tmp_count <= tmp_count+1;
						ce        <= '0';
					end if;

					if (ce = '1' and (conv_integer(data_temp) > conv_integer(ciclo_wise))) then
						pulse <= '1';
					else
						pulse <= '0';
					end if;

					if(data_int(19) = '1') then
						spikes_p <= '0';
						spikes_n <= pulse;			
					else
						spikes_p <= pulse;
						spikes_n <= '0';
					end if;
				else
				
				end if;
			end if;
		end process;

end Behavioral;

