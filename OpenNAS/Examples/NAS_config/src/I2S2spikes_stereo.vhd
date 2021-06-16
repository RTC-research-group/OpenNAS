--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright � 2016  �ngel Francisco Jim�nez-Fern�ndez                      //
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
-- Create Date:    11:30:32 11/01/2016 
-- Design Name: 
-- Module Name:    i2s_to_spikes_stereo - Behavioral 
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
library ieee;
use ieee.std_logic_1164.all;

entity I2S2spikes_stereo is
	Port(
		clk          : in  std_logic;
		rst_n        : in  std_logic;
		--I2S Bus
		i2s_bclk     : in  std_logic;
		i2s_d_in     : in  std_logic;
		i2s_lr       : in  std_logic;
		--Spikes Output
		spikes_left  : out std_logic_vector(1 downto 0);
		spikes_rigth : out std_logic_vector(1 downto 0)
	);
end I2S2spikes_stereo;

architecture Behavioral of I2S2spikes_stereo is

	signal data_ready    : std_logic;
	signal left_in_data  : std_logic_vector(31 downto 0);
	signal right_in_data : std_logic_vector(31 downto 0);
	signal genDiv        : std_logic_vector(15 downto 0);

begin

	genDiv <= x"000F";

	U_i2s_interface : entity work.I2S_inteface
		Port Map(
			clk         => clk,
			rst_n       => rst_n,
			i2s_bclk    => i2s_bclk,
			i2s_d_in    => i2s_d_in,
			i2s_lr      => i2s_lr,
			audio_l_out => left_in_data,
			audio_r_out => right_in_data,
			new_sample  => data_ready
		);

	U_Spikes_Gen_Left : entity work.Spikes_Generator_signed_BW
		Port Map(
			clk      => clk,
			rst_n    => rst_n,
			freq_div => genDiv,
			data_in  => left_in_data(31 downto 12),
			wr       => data_ready,
			spikes_p => spikes_left(1),
			spikes_n => spikes_left(0)
		);

	U_Spikes_Gen_Rigth : entity work.Spikes_Generator_signed_BW
		Port Map(
			clk      => clk,
			rst_n    => rst_n,
			freq_div => genDiv,
			data_in  => right_in_data(31 downto 12),
			wr       => data_ready,
			spikes_p => spikes_rigth(1),
			spikes_n => spikes_rigth(0)
		);

end Behavioral;
