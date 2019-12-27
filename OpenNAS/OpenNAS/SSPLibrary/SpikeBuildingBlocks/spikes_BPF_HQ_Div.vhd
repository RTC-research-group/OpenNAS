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


entity spikes_BPF_HQ is
	Generic (
		GL             : integer := 12; 
		SAT            : integer := 2047
	);
    Port ( 
		CLK            : in  STD_LOGIC;
		RST            : in  STD_LOGIC;
		FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
		SPIKES_DIV     : in  STD_LOGIC_VECTOR(15 downto 0);
		SPIKES_DIV_FB  : in  STD_LOGIC_VECTOR(15 downto 0);
		SPIKES_DIV_OUT : in  STD_LOGIC_VECTOR(15 downto 0);
		spike_in_p     : in  STD_LOGIC;
		spike_in_n     : in  STD_LOGIC;
		spike_out_p    : out STD_LOGIC;
		spike_out_n    : out STD_LOGIC
	);
end spikes_BPF_HQ;

architecture Behavioral of spikes_BPF_HQ is

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


	component Spike_Int_n_Gen_BW is
		Generic (
			GL          : integer := 16; 
			SAT         : integer := 32536
		);
		Port (
			CLK         : in  STD_LOGIC;
			RST         : in  STD_LOGIC;
			FREQ_DIV    : in  STD_LOGIC_VECTOR(7 downto 0);
			spike_in_p  : in  STD_LOGIC;
			spike_in_n  : in  STD_LOGIC;
			spike_out_p : out STD_LOGIC;
			spike_out_n : out STD_LOGIC
		);
	end component;

    component spikes_div_BW is
		Port ( 
			CLK         : in  STD_LOGIC;
			RST         : in  STD_LOGIC;
			spikes_div  : in  STD_LOGIC_VECTOR(15 downto 0);
			spike_in_p  : in  STD_LOGIC;
			spike_in_n  : in  STD_LOGIC;
			spike_out_p : out STD_LOGIC;
			spike_out_n : out STD_LOGIC
		);
    end component;
	 
	signal spike_out_tmp_p : STD_LOGIC :='0';
	signal spike_out_tmp_n : STD_LOGIC :='0';

	signal spikes_e_p       : STD_LOGIC :='0';
	signal spikes_e_n       : STD_LOGIC :='0';

	signal spikes_fb_p      : STD_LOGIC :='0';
	signal spikes_fb_n      : STD_LOGIC :='0';

	signal spikes_fbi_p     : STD_LOGIC :='0';
	signal spikes_fbi_n     : STD_LOGIC :='0';
 
	signal spikes_fbk_p     : STD_LOGIC :='0';
	signal spikes_fbk_n     : STD_LOGIC :='0';
	
	signal spikes_e_div_p   : STD_LOGIC :='0';
	signal spikes_e_div_n   : STD_LOGIC :='0';

	signal spikes_fbi_div_p : STD_LOGIC :='0';
	signal spikes_fbi_div_n : STD_LOGIC :='0';

	begin

		U_HF_1: AER_DIF
		Port Map (
			CLK          => clk,
			RST          => RST,
			SPIKES_IN_UP => spike_in_p,
			SPIKES_IN_UN => spike_in_n,
			SPIKES_IN_YP => spikes_fb_p, 
			SPIKES_IN_YN => spikes_fb_n, 
			SPIKES_OUT_P => spikes_e_p,
			SPIKES_OUT_N => spikes_e_n
		);		

		U_DIV_1: spikes_div_BW
		Port Map (
			CLK         => clk,
			RST         => RST,
			spikes_div  => SPIKES_DIV,
			spike_in_p  => spikes_e_p,
			spike_in_n  => spikes_e_n,
			spike_out_p => spikes_e_div_p,
			spike_out_n => spikes_e_div_n
		);

		U_INT_1: Spike_Int_n_Gen_BW 
		Generic Map(
			GL          => GL, 
			SAT         => SAT
		)
		Port Map( 
			CLK         => clk,
			RST         => rst,
			FREQ_DIV    => FREQ_DIV,
			spike_in_p  => spikes_e_div_p,
			spike_in_n  => spikes_e_div_n,
			spike_out_p => spike_out_tmp_p,
			spike_out_n => spike_out_tmp_n
		);

		U_DIV_2: spikes_div_BW
		Port Map (
			CLK         => clk,
			RST         => RST,
			spikes_div  => SPIKES_DIV,
			spike_in_p  => spike_out_tmp_p,
			spike_in_n  => spike_out_tmp_n,
			spike_out_p => spikes_fbi_div_p,
			spike_out_n => spikes_fbi_div_n
		);

		U_INT_2: Spike_Int_n_Gen_BW 
		Generic Map(
			GL          => GL, 
			SAT         => SAT
		)
		Port Map( 
			CLK         => clk,
			RST         => rst,
			FREQ_DIV    => FREQ_DIV,
			spike_in_p  => spikes_fbi_div_p,
			spike_in_n  => spikes_fbi_div_n,
			spike_out_p => spikes_fbi_p,
			spike_out_n => spikes_fbi_n
		);	 

		U_DIV_FB: spikes_div_BW
		Port Map (
			CLK         => clk,
			RST         => RST,
			spikes_div  => SPIKES_DIV_FB,
			spike_in_p  => spike_out_tmp_p,
			spike_in_n  => spike_out_tmp_n,
			spike_out_p => spikes_fbk_p,
			spike_out_n => spikes_fbk_n
		);

		U_HF_2:AER_DIF
		Port Map (
			CLK          => clk,
			RST          => RST,
			SPIKES_IN_UP => spikes_fbi_p,
			SPIKES_IN_UN => spikes_fbi_n,
			SPIKES_IN_YP => spikes_fbk_n, 
			SPIKES_IN_YN => spikes_fbk_p, 
			SPIKES_OUT_P => spikes_fb_p,
			SPIKES_OUT_N => spikes_fb_n
		);

		U_DIV_OUT: spikes_div_BW
		Port Map (
			CLK         => clk,
			RST         => RST,
			spikes_div  => SPIKES_DIV_OUT,
			spike_in_p  => spike_out_tmp_p,
			spike_in_n  => spike_out_tmp_n,
			spike_out_p => spike_out_p,
			spike_out_n => spike_out_n
		);

end Behavioral;

