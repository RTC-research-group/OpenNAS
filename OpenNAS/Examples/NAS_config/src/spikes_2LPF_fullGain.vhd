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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"

entity spikes_2LPF_fullGain is
	Generic(
		GL  : integer := 16;
		SAT : integer := 32535
	);
	Port(
		clk            : in  std_logic;
		rst            : in  std_logic;
		freq_div       : in  std_logic_vector(7 downto 0);
		spikes_div_fb  : in  std_logic_vector(15 downto 0);
		spikes_div_out : in  std_logic_vector(15 downto 0);
		spike_in_p     : in  std_logic;
		spike_in_n     : in  std_logic;
		spike_out_p    : out std_logic;
		spike_out_n    : out std_logic
	);
end spikes_2LPF_fullGain;

architecture Behavioral of spikes_2LPF_fullGain is

	signal int_spikes_p       : std_logic;
	signal int_spikes_n       : std_logic;
	signal spikes_out_tmp_p   : std_logic;
	signal spikes_out_tmp_n   : std_logic;
	signal spikes_div_fb_int  : std_logic_vector(15 downto 0);
	signal spikes_div_out_int : std_logic_vector(15 downto 0);

begin

	spike_out_p <= spikes_out_tmp_p;
	spike_out_n <= spikes_out_tmp_n;

	U_LPF1 : entity work.spikes_LPF_fullGain
		Generic Map(
			GL  => GL,
			SAT => SAT
		)
		Port Map(
			clk            => clk,
			rst            => rst,
			freq_div       => freq_div,
			spikes_div_fb  => spikes_div_fb,
			spikes_div_out => spikes_div_out,
			spike_in_p     => spike_in_p,
			spike_in_n     => spike_in_n,
			spike_out_p    => int_spikes_p,
			spike_out_n    => int_spikes_n
		);

	spikes_div_fb_int  <= spikes_div_fb + x"0000";
	spikes_div_out_int <= spikes_div_out + x"0000";

	U_LPF2 : entity work.spikes_LPF_fullGain
		Generic Map(
			GL  => GL,
			SAT => SAT
		)
		Port Map(
			clk            => clk,
			rst            => rst,
			freq_div       => freq_div,
			spikes_div_fb  => spikes_div_fb_int,
			spikes_div_out => spikes_div_out_int,
			spike_in_p     => int_spikes_p,
			spike_in_n     => int_spikes_n,
			spike_out_p    => spikes_out_tmp_p,
			spike_out_n    => spikes_out_tmp_n
		);

end Behavioral;

