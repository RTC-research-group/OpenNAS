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

entity spikes_LPF_fullGain is
	Generic(
		GL  : integer := 16;
		SAT : integer := 32536
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
end spikes_LPF_fullGain;

architecture Behavioral of spikes_LPF_fullGain is

	signal int_spikes_p     : std_logic;
	signal int_spikes_n     : std_logic;
	signal spikes_out_tmp_p : std_logic;
	signal spikes_out_tmp_n : std_logic;
	signal spikes_fb_div_p  : std_logic;
	signal spikes_fb_div_n  : std_logic;

begin

	U_OUT_DIV_out : entity work.spikes_div_BW
		generic map(
			GL => GL
		)
		Port Map(
			clk         => clk,
			rst         => rst,
			spikes_div  => spikes_div_out,
			spike_in_p  => spikes_out_tmp_p,
			spike_in_n  => spikes_out_tmp_n,
			spike_out_p => spike_out_p,
			spike_out_n => spike_out_n
		);

	U_FB_DIV : entity work.spikes_div_BW
		generic map(
			GL => GL
		)
		Port Map(
			clk         => clk,
			rst         => rst,
			spikes_div  => spikes_div_fb,
			spike_in_p  => spikes_out_tmp_p,
			spike_in_n  => spikes_out_tmp_n,
			spike_out_p => spikes_fb_div_p,
			spike_out_n => spikes_fb_div_n
		);

	U_DIF : entity work.AER_Dif
		Port Map(
			clk          => clk,
			rst          => rst,
			spikes_in_up => spike_in_p,
			spikes_in_un => spike_in_n,
			spikes_in_yp => spikes_fb_div_p,
			spikes_in_yn => spikes_fb_div_n,
			spikes_out_p => int_spikes_p,
			spikes_out_n => int_spikes_n
		);

	U_INT : entity work.Spike_Int_n_Gen_BW
		Generic Map(
			GL  => GL,
			SAT => SAT
		)
		Port Map(
			clk         => clk,
			rst         => rst,
			freq_div    => freq_div,
			spike_in_p  => int_spikes_p,
			spike_in_n  => int_spikes_n,
			spike_out_p => spikes_out_tmp_p,
			spike_out_n => spikes_out_tmp_n
		);

end Behavioral;

