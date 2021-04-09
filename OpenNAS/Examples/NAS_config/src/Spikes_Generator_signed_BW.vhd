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

entity Spikes_Generator_signed_BW is
	Port(
		clk      : in  std_logic;
		rst      : in  std_logic;
		freq_div : in  std_logic_vector(15 downto 0);
		data_in  : in  std_logic_vector(19 downto 0);
		wr       : in  std_logic;
		spike_p  : out std_logic;
		spike_n  : out std_logic
	);
end Spikes_Generator_signed_BW;

architecture Behavioral of Spikes_Generator_signed_BW is

	signal ciclo      : std_logic_vector(18 downto 0);
	signal ciclo_wise : std_logic_vector(18 downto 0);
	signal pulse      : std_logic;
	signal data_int   : std_logic_vector(19 downto 0);
	signal data_temp  : std_logic_vector(18 downto 0);
	signal ce         : std_logic;
	signal tmp_count  : std_logic_vector(15 downto 0);

begin

	process(clk, rst)
	begin
		if (rst = '0') then
			data_int <= (others => '0');
		elsif (clk = '1' and clk'event) then
			if (wr = '1') then
				data_int <= data_in;
			else

				end if;
		else

			end if;
	end process;

	process(ciclo)                      --combinational bit-wise operation
	begin
		for i in 0 to 18 loop
			ciclo_wise(18 - i) <= ciclo(i);
		end loop;
	end process;

	data_temp <= conv_std_logic_vector(abs (signed(data_int)), 19);

	process(clk, rst)
	begin
		if (rst = '0') then
			ciclo     <= (others => '0');
			tmp_count <= (others => '0');
			ce        <= '0';
			spike_p   <= '0';
			spike_n   <= '0';
			pulse     <= '0';
		else
			if (clk = '1' and clk'event) then
				if (freq_div = tmp_count) then
					tmp_count <= (others => '0');
					ciclo     <= ciclo + 1;
					ce        <= '1';
				else
					tmp_count <= tmp_count + 1;
					ce        <= '0';
				end if;

				if (ce = '1' and (conv_integer(data_temp) > conv_integer(ciclo_wise))) then
					pulse <= '1';
				else
					pulse <= '0';
				end if;

				if (data_int(19) = '1') then
					spike_p <= '0';
					spike_n <= pulse;
				else
					spike_p <= pulse;
					spike_n <= '0';
				end if;
			else
				
				end if;
		end if;
	end process;

end Behavioral;

