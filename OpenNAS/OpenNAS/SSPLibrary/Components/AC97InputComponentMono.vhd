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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity AC97InputComponentMono is
	Port (
		clock          : std_logic;		
		reset          : std_logic;
		-- AC Link
		ac97_bit_clock : in std_logic;		
		ac97_sdata_in  : in std_logic;		-- Serial data from AC'97
		ac97_sdata_out : out std_logic;		-- Serial data to AC'97
		ac97_synch     : out std_logic;		-- Defines boundries of AC'97 frames, controls warm reset
		audio_reset_b  : out std_logic;		-- AC'97 codec cold reset
		--Spikes Output
		spikes_left    : out std_logic_vector(1 downto 0)
	);

end AC97InputComponentMono;

architecture AC97InputComponentMono_arq of AC97InputComponentMono is

	component AC97Controller is
		Port (
			clock          : in  std_logic;		
			reset          : in  std_logic;
			-- AC Link
			ac97_bit_clock : in  std_logic;		
			ac97_sdata_in  : in  std_logic;		-- Serial data from AC'97
			ac97_sdata_out : out std_logic;		-- Serial data to AC'97
			ac97_synch     : out std_logic;		-- Defines boundries of AC'97 frames, controls warm reset
			audio_reset_b  : out std_logic;		-- AC'97 codec cold reset
			--PCM data
			Data_Ready     : out std_logic;
			left_in_data   : out std_logic_vector(19 downto 0);
			right_in_data  : out std_logic_vector(19 downto 0)
		);
	end component;

	component Spikes_Generator_signed_BW is
		Port ( 
			CLK      : in  std_logic;
			RST      : in  std_logic;
			FREQ_DIV : in  std_logic_vector(15 downto 0);
			DATA_IN  : in  std_logic_vector(19 downto 0);
			WR       : in  std_logic;
			SPIKE_P  : out std_logic;
			SPIKE_N  : out std_logic
		);
	end component;

	signal data_ready    : std_logic;
	signal left_in_data  : std_logic_vector(19 downto 0);
	signal right_in_data : std_logic_vector(19 downto 0);
	signal genDiv        : std_logic_vector(15 downto 0);

	begin

		genDiv<=\

		U_AC97: AC97Controller
		Port Map (
			clock          => clock,
			reset          => reset,
			-- AC Link
			ac97_bit_clock => ac97_bit_clock,
			ac97_sdata_in  => ac97_sdata_in,
			ac97_sdata_out => ac97_sdata_out,
			ac97_synch     => ac97_synch,
			audio_reset_b  => audio_reset_b,
			--PCM data
			Data_Ready     => data_ready,
			left_in_data   => left_in_data,
			right_in_data  => open

		);

		U_Spikes_Gen_Left: Spikes_Generator_signed_BW
		Port map( 
			CLK      => clock,
			RST      => reset,
			FREQ_DIV => genDiv,
			DATA_IN  => left_in_data,
			WR       => Data_Ready,
			SPIKE_P  => spikes_left(1),
			SPIKE_N  => spikes_left(0)
		);

end AC97InputComponentMono_arq;

