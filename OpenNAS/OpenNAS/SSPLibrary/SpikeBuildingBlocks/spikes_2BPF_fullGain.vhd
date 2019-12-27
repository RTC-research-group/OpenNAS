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
		CLK             : in  STD_LOGIC;
		RST             : in  STD_LOGIC;
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

	component AER_DIF is
    Port ( 
		CLK          : in  STD_LOGIC;
		RST          : in  STD_LOGIC;
		SPIKES_IN_UP : in  STD_LOGIC;
		SPIKES_IN_UN : in  STD_LOGIC;
		SPIKES_IN_YP : in  STD_LOGIC;
		SPIKES_IN_YN : in  STD_LOGIC;
		SPIKES_OUT_P : out STD_LOGIC;
		SPIKES_OUT_N : out STD_LOGIC
	);
	end component;


	component spikes_2LPF_fullGain is
	Generic (
		GL             : integer := 16;
		SAT            : integer := 32536
	);
    Port ( 
		CLK            : in  STD_LOGIC;
		RST            : in  STD_LOGIC;
		FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
		SPIKES_DIV_FB  : in  STD_LOGIC_VECTOR(15 downto 0);
		SPIKES_DIV_OUT : in  STD_LOGIC_VECTOR(15 downto 0);
		spike_in_p     : in  STD_LOGIC;
		spike_in_n     : in  STD_LOGIC;
		spike_out_p    : out STD_LOGIC;
		spike_out_n    : out STD_LOGIC
	);
	end component;

    component spikes_div_BW is
	Generic (
		GL: integer := 16
	);
    Port ( 
		CLK         : in  STD_LOGIC;
		RST         : in  STD_LOGIC;
		spikes_div  : in  STD_LOGIC_VECTOR(GL-1 downto 0);
		spike_in_p  : in  STD_LOGIC;
		spike_in_n  : in  STD_LOGIC;
		spike_out_p : out STD_LOGIC;
		spike_out_n : out STD_LOGIC
	);
    end component;

	signal spikes_out_tmp_p    : STD_LOGIC := '0';
	signal spikes_out_tmp_n    : STD_LOGIC := '0';
	signal spikes_bpf_tmp_p    : STD_LOGIC := '0';
	signal spikes_bpf_tmp_n    : STD_LOGIC := '0';
	signal spikes_bpf_hf_tmp_p : STD_LOGIC := '0';
	signal spikes_bpf_hf_tmp_n : STD_LOGIC := '0';

	begin

		spike_out_lpf_p <= spikes_out_tmp_p;
		spike_out_lpf_n <= spikes_out_tmp_n;


		U_LPF2: spikes_2LPF_fullGain 
		Generic map (
			GL  => GL, 
			SAT => SAT
		)
		Port map ( 
			CLK            => CLK,
			RST            => RST,
			FREQ_DIV       => FREQ_DIV,
			SPIKES_DIV_FB  => SPIKES_DIV_FB,
			SPIKES_DIV_OUT => SPIKES_DIV_OUT,		
			spike_in_p     => spike_in_slpf_p,
			spike_in_n     => spike_in_slpf_n,
			spike_out_p    => spikes_out_tmp_p,
			spike_out_n    => spikes_out_tmp_n
		);
				
		U_DIF:AER_DIF
		port map (
			CLK          => clk,
			RST          => RST,
			SPIKES_IN_UP => spike_in_shf_p,
			SPIKES_IN_UN => spike_in_shf_n,
			SPIKES_IN_YP => spikes_out_tmp_p, 
			SPIKES_IN_YN => spikes_out_tmp_n, 
			SPIKES_OUT_P => spikes_bpf_tmp_p,
			SPIKES_OUT_N => spikes_bpf_tmp_n
		);			  

		U_BPF_DIV: spikes_div_BW
		Generic map (
			GL => 8
		)
		Port map (
			CLK         => clk,
			RST         => RST,
			spikes_div  => SPIKES_DIV_BPF(15 downto 8),
			spike_in_p  => spikes_bpf_tmp_p,
			spike_in_n  => spikes_bpf_tmp_n,
			spike_out_p => spike_out_p,
			spike_out_n => spike_out_n
		);

end Behavioral;

