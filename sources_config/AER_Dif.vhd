----/////////////////////////////////////////////////////////////////////////////////
----//                                                                             //
----//    Copyright � 2016  �ngel Francisco Jim�nez-Fern�ndez                      //
----//                                                                             //
----//    This file is part of OpenNAS.                                            //
----//                                                                             //
----//    OpenNAS is free software: you can redistribute it and/or modify          //
----//    it under the terms of the GNU General Public License as published by     //
----//    the Free Software Foundation, either version 3 of the License, or        //
----//    (at your option) any later version.                                      //
----//                                                                             //
----//    OpenNAS is distributed in the hope that it will be useful,               //
----//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
----//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
----//    GNU General Public License for more details.                             //
----//                                                                             //
----//    You should have received a copy of the GNU General Public License        //
----//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
----//                                                                             //
----/////////////////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity aer_dif is
	port(
		clk          : in  std_logic;
		rst_n          : in  std_logic;
		spikes_in_up : in  std_logic;
		spikes_in_un : in  std_logic;
		spikes_in_yp : in  std_logic;
		spikes_in_yn : in  std_logic;
		spikes_out_p : out std_logic;
		spikes_out_n : out std_logic
	);
end aer_dif;

architecture behavioral of aer_dif is

	signal spikes_in      : std_logic_vector(3 downto 0);
	signal spikes_in_int  : std_logic_vector(1 downto 0);
	signal spikes_out     : std_logic_vector(1 downto 0);
	signal spikes_pol_int : std_logic_vector(1 downto 0);

begin

	spikes_out_p <= spikes_out(1);
	spikes_out_n <= spikes_out(0);

	spikes_in <= spikes_in_up & spikes_in_un & spikes_in_yp & spikes_in_yn;

	with spikes_in select spikes_in_int <=
		(others => '0') when b"0000",
		(others => '0') when b"1100",
		(others => '0') when b"0011",
		(others => '0') when b"1010",
		(others => '0') when b"0101",
		(others => '0') when b"1111",
		b"10" when b"1000",
		b"01" when b"0100",
		b"01" when b"0010",
		b"10" when b"0001",
		b"01" when b"1110",
		b"10" when b"1101",
		b"10" when b"1011",
		b"01" when b"0111",
		b"01" when b"0110",
		b"10" when b"1001";

	process(rst_n, clk)
	begin
		if (rst_n = '0') then
			spikes_pol_int <= b"00";
			spikes_out     <= b"00";
		elsif (clk = '1' and clk'event) then

			if (spikes_in_int = "00") then
				spikes_out <= b"00";
			--                    spikes_pol_int  <=  spikes_pol_int;
			elsif (spikes_pol_int = b"00" and spikes_in_int = "10") then
				spikes_pol_int <= b"10";
				spikes_out     <= b"10";
			elsif (spikes_pol_int = b"00" and spikes_in_int = "01") then
				spikes_pol_int <= b"01";
				spikes_out     <= b"01";
			elsif (spikes_pol_int = b"10" and spikes_in_int = "01") then
				spikes_pol_int <= b"00";
				spikes_out     <= b"00";
			elsif (spikes_pol_int = b"01" and spikes_in_int = "10") then
				spikes_pol_int <= b"00";
				spikes_out     <= b"00";
			elsif (spikes_pol_int = b"01" and spikes_in_int = "01") then
				spikes_pol_int <= b"01";
				spikes_out     <= b"01";
			elsif (spikes_pol_int = b"10" and spikes_in_int = "10") then
				spikes_pol_int <= b"10";
				spikes_out     <= b"10";
			else
				spikes_pol_int <= spikes_pol_int;
				spikes_out     <= b"00";
			end if;

		end if;

	end process;

end behavioral;
