--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jimñénez-Fernández                     //
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


entity spikes_4LPF_fullGain is
generic (GL: in integer:=16; SAT: in integer:=32535);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
				FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
			SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
           SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);				
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
end spikes_4LPF_fullGain;

architecture Behavioral of spikes_4LPF_fullGain is

	component spikes_LPF_fullGain is
		generic (GL: in integer:=16; SAT: in integer:=32536);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
           SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
           SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
	end component;
	
	signal int_spikes0_p: STD_LOGIC :='0';
	signal int_spikes0_n: STD_LOGIC :='0';
	
	signal int_spikes1_p: STD_LOGIC :='0';
	signal int_spikes1_n: STD_LOGIC :='0';

	signal int_spikes2_p: STD_LOGIC :='0';
	signal int_spikes2_n: STD_LOGIC :='0';
	
--	signal int_spikes3_p: STD_LOGIC :='0';
--	signal int_spikes3_n: STD_LOGIC :='0';

	signal spikes_out_tmp_p: STD_LOGIC :='0';
	signal spikes_out_tmp_n: STD_LOGIC :='0';
begin
spike_out_p<=spikes_out_tmp_p;
spike_out_n<=spikes_out_tmp_n;


	U_LPF1: 	spikes_LPF_fullGain
 
	generic map (GL=>GL, SAT=>SAT)
    Port map ( CLK =>CLK,
           RST=>RST,
				FREQ_DIV=>FREQ_DIV,
				SPIKES_DIV_FB=>SPIKES_DIV_FB,
				SPIKES_DIV_OUT=>SPIKES_DIV_OUT,
           spike_in_p=>spike_in_p,
           spike_in_n =>spike_in_n,
           spike_out_p =>int_spikes0_p,
           spike_out_n=>int_spikes0_n);



	U_LPF2: spikes_LPF_fullGain 
	generic map (GL=>GL, SAT=>SAT)
    Port map( CLK =>CLK,
           RST=>RST,
				FREQ_DIV=>FREQ_DIV,
				SPIKES_DIV_FB=>SPIKES_DIV_FB,
				SPIKES_DIV_OUT=>SPIKES_DIV_OUT,		
           spike_in_p=>int_spikes0_p,
           spike_in_n =>int_spikes0_n,
           spike_out_p =>int_spikes1_p,
           spike_out_n=>int_spikes1_n);


	U_LPF3: spikes_LPF_fullGain 
	generic map (GL=>GL, SAT=>SAT)
    Port map( CLK =>CLK,
           RST=>RST,
				FREQ_DIV=>FREQ_DIV,
				SPIKES_DIV_FB=>SPIKES_DIV_FB,
				SPIKES_DIV_OUT=>SPIKES_DIV_OUT,		
           spike_in_p=>int_spikes1_p,
           spike_in_n =>int_spikes1_n,
           spike_out_p =>int_spikes2_p,
           spike_out_n=>int_spikes2_n);

	U_LPF4: spikes_LPF_fullGain 
	generic map (GL=>GL, SAT=>SAT)
    Port map( CLK =>CLK,
           RST=>RST,
				FREQ_DIV=>FREQ_DIV,
				SPIKES_DIV_FB=>SPIKES_DIV_FB,
				SPIKES_DIV_OUT=>SPIKES_DIV_OUT,		
           spike_in_p=>int_spikes2_p,
           spike_in_n =>int_spikes2_n,
           spike_out_p =>spikes_out_tmp_p,
           spike_out_n=>spikes_out_tmp_n);

end Behavioral;

