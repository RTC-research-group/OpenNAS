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

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:54 02/24/2016 
-- Design Name: 
-- Module Name:    PDM2Spikes - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PDM2Spikes is
generic (SLPF_GL: in integer:=11; SLPF_SAT: in integer:=1023; SHPF_GL: in integer:=17; SHPF_SAT: in integer:=65535);
port (
	clk				: in std_logic;		
	rst				: in std_logic;
	clock_div : in std_logic_vector(7 downto 0);
	PDM_CLK		: out std_logic;
	PDM_DAT		: in std_logic;
	SHPF_FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
	SLPF_FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
	SLPF_SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
   SLPF_SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);
	SPIKES_OUT			: out std_logic_vector(1 downto 0)
	);
end PDM2Spikes;

architecture Behavioral of PDM2Spikes is
	
	component PDM_Interface is
port (
	clk				: in std_logic;		
	rst				: in std_logic;
	clock_div : in std_logic_vector(7 downto 0);
	PDM_CLK		: out std_logic;
	PDM_DAT		: in std_logic;
	SPIKES_OUT			: out std_logic_vector(1 downto 0)
	);
end component;

	component spikes_2LPF_fullGain is
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

component spikes_HPF is
generic (GL: in integer:=16; SAT: in integer:=32536);
	 Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
end component;

signal spikes_pdm: std_logic_vector(1 downto 0);
signal spikes_hpf_int: std_logic_vector(1 downto 0);
signal spikes_hpf_int2: std_logic_vector(1 downto 0);
signal spikes_int: std_logic_vector(1 downto 0);

begin

U_PDM_Interface: PDM_Interface
port map (
  clk=>clk,
  rst=>rst,
	clock_div =>clock_div,
	PDM_CLK	=>	PDM_CLK,	
	PDM_DAT	=>PDM_DAT,	
--Spikes Output
  spikes_out =>spikes_pdm
);

U_SHPF1: 	spikes_HPF
	generic map (GL=>SHPF_GL, SAT=>SHPF_SAT)
    Port map ( CLK =>CLK,
			RST=> (not RST),
			FREQ_DIV=>SHPF_FREQ_DIV,
			spike_in_p=>spikes_pdm(1),
			spike_in_n =>spikes_pdm(0),
			spike_out_p => spikes_hpf_int(1),
			spike_out_n => spikes_hpf_int(0));

U_SHPF2: 	spikes_HPF
	generic map (GL=>SHPF_GL, SAT=>SHPF_SAT)
    Port map ( CLK =>CLK,
			RST=> (not RST),
			FREQ_DIV=>SHPF_FREQ_DIV,
			spike_in_p=>spikes_hpf_int(1),
			spike_in_n =>spikes_hpf_int(0),
			spike_out_p => spikes_hpf_int2(1),
			spike_out_n => spikes_hpf_int2(0));
	
			  
U_LPF1: 	spikes_2LPF_fullGain
 	generic map (GL=>SLPF_GL, SAT=>SLPF_SAT)
    Port map ( CLK =>CLK,
           RST=> (not RST),
		   FREQ_DIV=>SLPF_FREQ_DIV,
		   SPIKES_DIV_FB=>SLPF_SPIKES_DIV_FB,
		   SPIKES_DIV_OUT=>SLPF_SPIKES_DIV_OUT,
           spike_in_p=>spikes_hpf_int2(1),
           spike_in_n =>spikes_hpf_int2(0),
           spike_out_p => spikes_int(1),
           spike_out_n => spikes_int(0));

SPIKES_OUT<=spikes_int;




end Behavioral;
