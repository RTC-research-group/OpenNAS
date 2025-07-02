--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    (c) 2016  Angel Francisco Jimenez-Fernandez                              //
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity spikes_bpf_hq is
	generic(
		GL  : integer := 12;
		SAT : integer := 2047
	);
	port(
		clk            : in  std_logic;
		rst_n          : in  std_logic;
		freq_div       : in  std_logic_vector(7 downto 0);
		spikes_div     : in  std_logic_vector(15 downto 0);
		spikes_div_fb  : in  std_logic_vector(15 downto 0);
		spikes_div_out : in  std_logic_vector(15 downto 0);
		spike_in_p     : in  std_logic;
		spike_in_n     : in  std_logic;
		spike_out_p    : out std_logic;
		spike_out_n    : out std_logic
	);
end spikes_bpf_hq;

architecture behavioral of spikes_bpf_hq is

	signal spike_out_tmp_p : std_logic;
	signal spike_out_tmp_n : std_logic;

	signal spike_out_tmp2_p : std_logic;
	signal spike_out_tmp2_n : std_logic;

	signal spikes_e_p : std_logic;
	signal spikes_e_n : std_logic;

	signal spikes_div1_p : std_logic;
	signal spikes_div1_n : std_logic;

	signal spikes_div2_p : std_logic;
	signal spikes_div2_n : std_logic;

	signal spikes_fb_p : std_logic;
	signal spikes_fb_n : std_logic;

	signal spikes_fbi_p : std_logic;
	signal spikes_fbi_n : std_logic;

	signal spikes_fbk_p : std_logic;
	signal spikes_fbk_n : std_logic;

begin

	u_hf_1 : entity work.aer_dif
		port map(
			clk          => clk,
			rst_n        => rst_n,
			spikes_in_up => spike_in_p,
			spikes_in_un => spike_in_n,
			spikes_in_yp => spikes_fb_p,
			spikes_in_yn => spikes_fb_n,
			spikes_out_p => spikes_e_p,
			spikes_out_n => spikes_e_n
		);

	u_div_int_1 : entity work.spikes_div_bw
		Generic map(
			GL => 16
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			spikes_div  => spikes_div,
			spikes_in_p => spikes_e_p,
			spikes_in_n => spikes_e_n,
			spike_out_p => spikes_div1_p,
			spike_out_n => spikes_div1_n
		);

	u_int_1 : entity work.spike_int_n_gen_bw
		generic map(
			GL  => GL,
			SAT => SAT
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			freq_div    => freq_div,
			spike_in_p  => spikes_div1_p,
			spike_in_n  => spikes_div1_n,
			spike_out_p => spike_out_tmp_p,
			spike_out_n => spike_out_tmp_n
		);

	u_div_int_2 : entity work.spikes_div_bw
		Generic map(
			GL => 16
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			spikes_div  => spikes_div,
			spikes_in_p => spike_out_tmp_p,
			spikes_in_n => spike_out_tmp_n,
			spike_out_p => spikes_div2_p,
			spike_out_n => spikes_div2_n
		);

	u_int_2 : entity work.spike_int_n_gen_bw
		generic map(
			GL  => GL,
			SAT => SAT
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			freq_div    => freq_div,
			spike_in_p  => spikes_div2_p,
			spike_in_n  => spikes_div2_n,
			spike_out_p => spikes_fbi_p,
			spike_out_n => spikes_fbi_n
		);

	u_div_fb : entity work.spikes_div_bw
		Generic map(
			GL => 16
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			spikes_div  => spikes_div_fb,
			spikes_in_p => spike_out_tmp_p,
			spikes_in_n => spike_out_tmp_n,
			spike_out_p => spikes_fbk_p,
			spike_out_n => spikes_fbk_n
		);

	u_hf_2 : entity work.aer_dif
		port map(
			clk          => clk,
			rst_n        => rst_n,
			spikes_in_up => spikes_fbi_p,
			spikes_in_un => spikes_fbi_n,
			spikes_in_yp => spikes_fbk_n,
			spikes_in_yn => spikes_fbk_p,
			spikes_out_p => spikes_fb_p,
			spikes_out_n => spikes_fb_n
		);

	-- espontaneus activity filter low
	u_hf_out : entity work.aer_dif
		port map(
			clk          => clk,
			rst_n        => rst_n,
			spikes_in_up => spike_out_tmp_p,
			spikes_in_un => spike_out_tmp_n,
			spikes_in_yp => '0',
			spikes_in_yn => '0',
			spikes_out_p => spike_out_tmp2_p,
			spikes_out_n => spike_out_tmp2_n
		);

	u_div_out : entity work.Spikes_div_BW
		Generic map(
			GL => 16
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			spikes_div  => spikes_div_out,
			spikes_in_p => spike_out_tmp2_p,
			spikes_in_n => spike_out_tmp2_n,
			spike_out_p => spike_out_p,
			spike_out_n => spike_out_n
		);

end behavioral;
