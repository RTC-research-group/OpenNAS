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

entity spikes_2BPF_fullGain is
	Generic(
		GL  : integer := 11;
		SAT : integer := 1023
	);
	Port(
		clk             : in  std_logic;
		rst_n           : in  std_logic;
		freq_div        : in  std_logic_vector(7 downto 0);
		spikes_div_fb   : in  std_logic_vector(15 downto 0);
		spikes_div_out  : in  std_logic_vector(15 downto 0);
		spikes_div_bpf  : in  std_logic_vector(15 downto 0);
		spike_in_slpf_p : in  std_logic;
		spike_in_slpf_n : in  std_logic;
		spike_in_shf_p  : in  std_logic;
		spike_in_shf_n  : in  std_logic;
		spike_out_p     : out std_logic;
		spike_out_n     : out std_logic;
		spike_out_lpf_p : out std_logic;
		spike_out_lpf_n : out std_logic
	);
end spikes_2BPF_fullGain;

architecture Behavioral of spikes_2BPF_fullGain is

	signal spikes_out_tmp_p : std_logic := '0';
	signal spikes_out_tmp_n : std_logic := '0';
	signal spikes_bpf_tmp_p : std_logic := '0';
	signal spikes_bpf_tmp_n : std_logic := '0';

begin

	spike_out_lpf_p <= spikes_out_tmp_p;
	spike_out_lpf_n <= spikes_out_tmp_n;

	U_LPF2 : entity work.Spikes_2LPF_FullGain
		Generic map(
			GL  => GL,
			SAT => SAT
		)
		Port map(
			clk            => clk,
			rst_n          => rst_n,
			freq_div       => freq_div,
			spikes_div_fb  => spikes_div_fb,
			spikes_div_out => spikes_div_out,
			spike_in_p     => spike_in_slpf_p,
			spike_in_n     => spike_in_slpf_n,
			spike_out_p    => spikes_out_tmp_p,
			spike_out_n    => spikes_out_tmp_n
		);

	U_DIF : entity work.AER_Dif
		port map(
			clk          => clk,
			rst_n        => rst_n,
			spkies_in_up => spike_in_shf_p,
			spikes_in_un => spike_in_shf_n,
			spikes_in_yp => spikes_out_tmp_p,
			spikes_in_yn => spikes_out_tmp_n,
			spikes_out_p => spikes_bpf_tmp_p,
			spikes_out_n => spikes_bpf_tmp_n
		);

	U_BPF_DIV : entity work.Spikes_div_BW
		Generic map(
			GL => 8
		)
		Port map(
			clk         => clk,
			rst_n       => rst_n,
			spikes_div  => spikes_div_bpf(15 downto 8),
			spikes_in_p => spikes_bpf_tmp_p,
			spikes_in_n => spikes_bpf_tmp_n,
			spike_out_p => spike_out_p,
			spike_out_n => spike_out_n
		);

end Behavioral;

