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


entity spikes_2BPF_fullGain is
	Generic (
		GL              : INTEGER := 11; 
		SAT             : INTEGER := 1023
	);
    Port ( 
		clk             : in  STD_LOGIC;
		rst_n             : in  STD_LOGIC;
		FREQ_DIV        : in  STD_LOGIC_VECTOR(7 downto 0);
		SPIKES_DIV_FB   : in  STD_LOGIC_VECTOR(15 downto 0);
		SPIKES_DIV_OUT  : in  STD_LOGIC_VECTOR(15 downto 0);				
		SPIKES_DIV_BPF  : in  STD_LOGIC_VECTOR(15 downto 0);
		spike_in_slpf_p : in  STD_LOGIC;
		spike_in_slpf_n : in  STD_LOGIC;  
		spike_in_shf_p  : in  STD_LOGIC;
		spike_in_shf_n  : in  STD_LOGIC;  
		spike_out_p     : out STD_LOGIC;
		spike_out_n     : out STD_LOGIC;
		spike_out_lpf_p : out STD_LOGIC;
		spike_out_lpf_n : out STD_LOGIC
	);
end spikes_2BPF_fullGain;

architecture Behavioral of spikes_2BPF_fullGain is

	signal spikes_out_tmp_p    : STD_LOGIC := '0';
	signal spikes_out_tmp_n    : STD_LOGIC := '0';
	signal spikes_bpf_tmp_p    : STD_LOGIC := '0';
	signal spikes_bpf_tmp_n    : STD_LOGIC := '0';
	signal spikes_bpf_hf_tmp_p : STD_LOGIC := '0';
	signal spikes_bpf_hf_tmp_n : STD_LOGIC := '0';

	begin

		spike_out_lpf_p <= spikes_out_tmp_p;
		spike_out_lpf_n <= spikes_out_tmp_n;


		U_LPF2: entity work.spikes_2LPF_fullGain 
		Generic map (
			GL  => GL, 
			SAT => SAT
		)
		Port map ( 
			clk            => clk,
			rst_n            => rst_n,
			freq_div       => FREQ_DIV,
			spikes_div_fb  => SPIKES_DIV_FB,
			spikes_div_out => SPIKES_DIV_OUT,		
			spike_in_p     => spike_in_slpf_p,
			spike_in_n     => spike_in_slpf_n,
			spike_out_p    => spikes_out_tmp_p,
			spike_out_n    => spikes_out_tmp_n
		);
				
		U_DIF: entity work.AER_DIF
		port map (
			clk          => clk,
			rst_n          => rst_n,
			spkies_in_up => spike_in_shf_p,
			spikes_in_un => spike_in_shf_n,
			spikes_in_yp => spikes_out_tmp_p, 
			spikes_in_yn => spikes_out_tmp_n, 
			spikes_out_p => spikes_bpf_tmp_p,
			spikes_out_n => spikes_bpf_tmp_n
		);			  

		U_BPF_DIV: entity work.spikes_div_BW
		Generic map (
			GL => 8
		)
		Port map (
			clk         => clk,
			rst_n         => rst_n,
			spikes_div  => SPIKES_DIV_BPF(15 downto 8), -- TODO Deberían de coincidir el tamaño de estas señales.
			spike_in_p  => spikes_bpf_tmp_p,
			spike_in_n  => spikes_bpf_tmp_n,
			spike_out_p => spike_out_p,
			spike_out_n => spike_out_n
		);

end Behavioral;

