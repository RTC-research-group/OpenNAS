--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                      //
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
	Generic (
		SLPF_GL             : INTEGER := 11; 
		SLPF_SAT            : INTEGER := 1023; 
		SHPF_GL             : INTEGER := 17; 
		SHPF_SAT            : INTEGER := 65535
	);
	Port (
		CLK                 : in  STD_LOGIC;		
		RST                 : in  STD_LOGIC;
		CLOCK_DIV           : in  STD_LOGIC_VECTOR(7 downto 0);
		PDM_CLK             : out STD_LOGIC;
		PDM_DAT             : in  STD_LOGIC;
		SHPF_FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
		SLPF_FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
		SLPF_SPIKES_DIV_FB  : in  STD_LOGIC_VECTOR(15 downto 0);
		SLPF_SPIKES_DIV_OUT : in  STD_LOGIC_VECTOR(15 downto 0);
		SPIKES_OUT          : out STD_LOGIC_VECTOR(1 downto 0)
	);
end PDM2Spikes;

architecture Behavioral of PDM2Spikes is
	
	component PDM_Interface is
		Port (
			CLK        : in  STD_LOGIC;		
			RST        : in  STD_LOGIC;
			CLOCK_DIV  : in  STD_LOGIC_VECTOR(7 downto 0);
			PDM_CLK    : out STD_LOGIC;
			PDM_DAT    : in  STD_LOGIC;
			SPIKES_OUT : out STD_LOGIC_VECTOR(1 downto 0)
		);
	end component;

	component spikes_2LPF_fullGain is
		Generic (
			GL             : INTEGER := 16; 
			SAT            : INTEGER := 32536
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

	component spikes_HPF is
		Generic (
			GL          : in INTEGER := 16; 
			SAT         : in INTEGER := 32536
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

	signal spikes_pdm      : STD_LOGIC_VECTOR(1 downto 0);
	signal spikes_hpf_int  : STD_LOGIC_VECTOR(1 downto 0);
	signal spikes_hpf_int2 : STD_LOGIC_VECTOR(1 downto 0);
	signal spikes_int      : STD_LOGIC_VECTOR(1 downto 0);
	signal n_rst           : STD_LOGIC;

	begin

		n_rst <= not RST;

		U_PDM_Interface: PDM_Interface
		Port Map (
			CLK        => clk,
			RST        => rst,
			CLOCK_DIV  => clock_div,
			PDM_CLK    => PDM_CLK,	
			PDM_DAT    => PDM_DAT,	
			spikes_out => spikes_pdm
		);

		U_SHPF1: spikes_HPF
		Generic Map (
			GL          => SHPF_GL, 
			SAT         => SHPF_SAT
		)
		Port Map ( 
			CLK         => CLK,
			RST         => n_rst,
			FREQ_DIV    => SHPF_FREQ_DIV,
			spike_in_p  => spikes_pdm(1),
			spike_in_n  => spikes_pdm(0),
			spike_out_p => spikes_hpf_int(1),
			spike_out_n => spikes_hpf_int(0)
		);

		U_SHPF2: spikes_HPF
		Generic Map (
			GL          => SHPF_GL, 
			SAT         => SHPF_SAT
		)
		Port Map ( 
			CLK         => CLK,
			RST         => n_rst,
			FREQ_DIV    => SHPF_FREQ_DIV,
			spike_in_p  => spikes_hpf_int(1),
			spike_in_n  => spikes_hpf_int(0),
			spike_out_p => spikes_hpf_int2(1),
			spike_out_n => spikes_hpf_int2(0)
		);
			
		U_LPF1: spikes_2LPF_fullGain
		generic Map (
			GL             => SLPF_GL, 
			SAT            => SLPF_SAT
		)
		Port Map ( 
			CLK            => CLK,
			RST            => n_rst,
			FREQ_DIV       => SLPF_FREQ_DIV,
			SPIKES_DIV_FB  => SLPF_SPIKES_DIV_FB,
			SPIKES_DIV_OUT => SLPF_SPIKES_DIV_OUT,
			spike_in_p     => spikes_hpf_int2(1),
			spike_in_n     => spikes_hpf_int2(0),
			spike_out_p    => spikes_int(1),
			spike_out_n    => spikes_int(0)
		);

		SPIKES_OUT <= spikes_int;

end Behavioral;