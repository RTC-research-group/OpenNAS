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
use ieee.std_logic_arith.all;           -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"

entity Spikes_div_BW is
	Generic(
		GL : integer := 16
	);
	Port(
		clk         : in  std_logic;
		rst_n       : in  std_logic;
		spikes_div  : in  std_logic_vector(GL - 1 downto 0);
		spikes_in_p : in  std_logic;
		spikes_in_n : in  std_logic;
		spike_out_p : out std_logic;
		spike_out_n : out std_logic);
end Spikes_div_BW;

architecture Behavioral of Spikes_div_BW is

	signal ciclo      : std_logic_vector(GL - 2 downto 0);
	signal ciclo_wise : std_logic_vector(GL - 2 downto 0);

	signal data_int  : std_logic_vector(GL - 1 downto 0);
	signal data_temp : std_logic_vector(GL - 2 downto 0);

begin
	--SIN SIGNO!
	data_temp <= data_int(GL - 2 downto 0);

	process(clk, rst_n, ciclo)
	begin
		if (rst_n = '0') then
			data_int   <= (others => '0');
			ciclo_wise <= (others => '0');
		elsif (clk = '1' and clk'event) then
			data_int <= spikes_div(GL - 1 downto 0);
		else
			
		end if;

		for i in 0 to GL - 2 loop
			ciclo_wise(GL - 2 - i) <= ciclo(i);
		end loop;

	end process;

	process(clk, rst_n)
	begin
		if (rst_n = '0') then
			ciclo       <= (others => '0');
			spike_out_p <= '0';
			spike_out_n <= '0';
		elsif (clk = '1' and clk'event) then
			if (spikes_in_n = '1' or spikes_in_p = '1') then
				ciclo <= ciclo + 1;
			else
				ciclo <= ciclo;
			end if;

			if ((conv_integer(data_temp) > conv_integer(ciclo_wise))) then
				if (data_int(GL - 1) = '1') then
					spike_out_p <= spikes_in_n;
					spike_out_n <= spikes_in_p;
				else
					spike_out_p <= spikes_in_p;
					spike_out_n <= spikes_in_n;
				end if;
			else
				spike_out_p <= '0';
				spike_out_n <= '0';
			end if;
		end if;
	end process;

end Behavioral;

