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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity i2s_to_spikes_stereo is
	Port (
		clock        : in STD_LOGIC;		
		reset        : in STD_LOGIC;
		--I2S Bus
		i2s_bclk     : in  STD_LOGIC;
		i2s_d_in     : in  STD_LOGIC;
		i2s_lr       : in  STD_LOGIC;		  
		--Spikes Output
		spikes_left  : out STD_LOGIC_VECTOR(1 downto 0);		
		spikes_rigth : out STD_LOGIC_VECTOR(1 downto 0)	
	);
end i2s_to_spikes_stereo;

architecture Behavioral of i2s_to_spikes_stereo is
	
	component I2S_inteface is
    Port ( 
		clk           : in  STD_LOGIC;
		rst           : in  STD_LOGIC;   
		i2s_bclk      : in  STD_LOGIC;
		i2s_d_in      : in  STD_LOGIC;
		i2s_lr        : in  STD_LOGIC;
		audio_l_out   : out STD_LOGIC_VECTOR (31 downto 0);
		audio_r_out   : out STD_LOGIC_VECTOR (31 downto 0);
		new_sample    : out STD_LOGIC 
	);
	end component;

	component Spikes_Generator_signed_BW is
	Port ( 
		CLK      : in  STD_LOGIC;
		RST      : in  STD_LOGIC;
		FREQ_DIV : in  STD_LOGIC_VECTOR(15 downto 0);
		DATA_IN  : in  STD_LOGIC_VECTOR(19 downto 0);
		WR       : in  STD_LOGIC;
		SPIKE_P  : out STD_LOGIC;
		SPIKE_N  : out STD_LOGIC
	);
	end component;

	signal data_ready    : STD_LOGIC;
	signal left_in_data  : STD_LOGIC_VECTOR(31 downto 0);
	signal right_in_data : STD_LOGIC_VECTOR(31 downto 0);
	signal genDiv        : STD_LOGIC_VECTOR(15 downto 0);

	begin

		genDiv<=x"000F";

		U_i2s_interface: I2S_inteface 
		Port Map ( 
			CLK         => clock,
			RST         => reset,
			i2s_bclk    => i2s_bclk,
			i2s_d_in    => i2s_d_in,
			i2s_lr      => i2s_lr,
			audio_l_out => left_in_data,
			audio_r_out => right_in_data,
			new_sample  => data_ready 
		);

		U_Spikes_Gen_Left: Spikes_Generator_signed_BW
		Port Map( 
			CLK      => clock,
			RST      => reset,
			FREQ_DIV => genDiv,
			DATA_IN  => left_in_data(31 downto 12),
			WR       => data_ready,
			SPIKE_P  => spikes_left(1),
			SPIKE_N  => spikes_left(0)
		);

		U_Spikes_Gen_Rigth: Spikes_Generator_signed_BW
		Port Map( 
			CLK      => clock,
			RST      => reset,
			FREQ_DIV => genDiv,
			DATA_IN  => right_in_data(31 downto 12),
			WR       => data_ready,
			SPIKE_P  => spikes_rigth(1),
			SPIKE_N  => spikes_rigth(0)
		);

end Behavioral;
