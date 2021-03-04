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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.OpenNas_top_pkg.all;
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity i2s_to_spikes_stereo is
	generic(
		CONFIG_ADDRESS : integer := 16#0000#;
		CONFIG_OFFSET  : integer := 0
	);
	Port(
		clock        : in  std_logic;
		reset        : in  std_logic;
		--I2S Bus
		i2s_bclk     : in  std_logic;
		i2s_d_in     : in  std_logic;
		i2s_lr       : in  std_logic;
		--Config Bus
		config_data  : in  std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		config_addr  : in  std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		config_wren  : in  std_logic;
		--Spikes Output
		spikes_left  : out std_logic_vector(1 downto 0);
		spikes_rigth : out std_logic_vector(1 downto 0)
	);
end i2s_to_spikes_stereo;

architecture Behavioral of i2s_to_spikes_stereo is

	signal data_ready    : std_logic;
	signal left_in_data  : std_logic_vector(31 downto 0);
	signal right_in_data : std_logic_vector(31 downto 0);

	-- Configurable signals
	type register_bank is array (0 to CONFIG_OFFSET) of std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
	signal config_mem : register_bank;

begin

	U_Config_registers : process(clock, reset)
	begin
		if (reset = '0') then           -- En reset hay que establecer los valores por defecto generados en OpenNAS
			config_mem(0) <= x"000F";

		elsif rising_edge(clock) then
			if config_wren = '1' then
				for c_idx in 0 to CONFIG_OFFSET loop
					if to_integer(unsigned(config_addr)) = CONFIG_ADDRESS + c_idx then
						config_mem(c_idx) <= config_data;
					end if;
				end loop;
			end if;
		end if;
	end process;

	U_i2s_interface : entity work.I2S_inteface
		Port Map(
			clk         => clock,
			rst         => reset,
			i2s_bclk    => i2s_bclk,
			i2s_d_in    => i2s_d_in,
			i2s_lr      => i2s_lr,
			audio_l_out => left_in_data,
			audio_r_out => right_in_data,
			new_sample  => data_ready
		);

	U_Spikes_Gen_Left : entity work.Spikes_Generator_signed_BW
		Port Map(
			CLK      => clock,
			RST      => reset,
			FREQ_DIV => config_mem(0),
			DATA_IN  => left_in_data(31 downto 12),
			WR       => data_ready,
			SPIKE_P  => spikes_left(1),
			SPIKE_N  => spikes_left(0)
		);

	U_Spikes_Gen_Rigth : entity work.Spikes_Generator_signed_BW
		Port Map(
			CLK      => clock,
			RST      => reset,
			FREQ_DIV => config_mem(0),
			DATA_IN  => right_in_data(31 downto 12),
			WR       => data_ready,
			SPIKE_P  => spikes_rigth(1),
			SPIKE_N  => spikes_rigth(0)
		);

end Behavioral;
