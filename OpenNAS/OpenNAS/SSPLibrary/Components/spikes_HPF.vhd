--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                     //
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


entity spikes_HPF is
generic (GL: in integer:=16; SAT: in integer:=32536);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
end spikes_HPF;

architecture Behavioral of spikes_HPF is

	component AER_DIF is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN_UP: in STD_LOGIC;
           SPIKES_IN_UN: in STD_LOGIC;
           SPIKES_IN_YP: in STD_LOGIC;
           SPIKES_IN_YN: in STD_LOGIC;
           HOLD_TIME_U:  in STD_LOGIC_VECTOR(15 downto 0);
           HOLD_TIME_Y:  in STD_LOGIC_VECTOR(15 downto 0);
		   SPIKES_OUT_P: out STD_LOGIC;
		   SPIKES_OUT_N: out STD_LOGIC);
	end component;


	component Spike_Int_n_Gen_BW is
	generic (GL: in integer:=16; SAT: in integer:=32536);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
	end component;

    component spikes_div_BW is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
		   spikes_div: in STD_LOGIC_VECTOR(15 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
    end component;

	
	signal int_spikes_p: STD_LOGIC :='0';
	signal int_spikes_n: STD_LOGIC :='0';

	signal spikes_out_tmp_p: STD_LOGIC :='0';
	signal spikes_out_tmp_n: STD_LOGIC :='0';
	signal spikes_out_tmp_p2: STD_LOGIC :='0';
	signal spikes_out_tmp_n2: STD_LOGIC :='0';

begin
spike_out_p<=int_spikes_p;
spike_out_n<=int_spikes_n;

	U_DIF:AER_DIF
	port map (
			  CLK =>clk,
			  RST =>RST,
			  HOLD_TIME_U=>(others=>'1'),
           HOLD_TIME_Y=>(others=>'1'),
           SPIKES_IN_UP=>spike_in_p,
			  SPIKES_IN_UN=>spike_in_n,
           SPIKES_IN_YP=>spikes_out_tmp_p2, 
			  SPIKES_IN_YN=>spikes_out_tmp_n2, 
			  SPIKES_OUT_P=>int_spikes_p,
			  SPIKES_OUT_N=>int_spikes_n
			  );			  

	U_INT: Spike_Int_n_Gen_BW 
		generic map(GL=> GL, SAT=>SAT)
		 Port map( CLK =>clk,
				  RST =>rst,
				  FREQ_DIV=>FREQ_DIV,
				  spike_in_p =>int_spikes_p,
				  spike_in_n =>int_spikes_n,
				  spike_out_p =>spikes_out_tmp_p,
				  spike_out_n =>spikes_out_tmp_n);

--    U_SP_DIV_out: spikes_div_BW
--	port map (
--			  CLK =>clk,
--			  RST =>RST,
--		   spikes_div=>SPIKES_DIV_OUT,
  --         spike_in_p=>spikes_out_tmp_p,
    --       spike_in_n=>spikes_out_tmp_n,
--           spike_out_p=>spike_out_p,
--           spike_out_n=>spike_out_n);

--process(clk)
--begin
--    if(clk='1' and clk'event) then
        spikes_out_tmp_p2<=spikes_out_tmp_p;
        spikes_out_tmp_n2<=spikes_out_tmp_n;
--    end if;

--end process;

end Behavioral;

