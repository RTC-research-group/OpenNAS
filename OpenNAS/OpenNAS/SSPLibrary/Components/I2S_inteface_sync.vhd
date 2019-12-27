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
-- Create Date:    11:08:35 11/01/2016 
-- Design Name: 
-- Module Name:    I2S_inteface - Behavioral 
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


entity I2S_inteface is
    Port ( 
		clk           : STD_LOGIC;
		rst           : STD_LOGIC;
        -- I2S signals   
		i2s_bclk      : in  STD_LOGIC;
		i2s_d_in      : in  STD_LOGIC;
		i2s_lr        : in  STD_LOGIC;
		-- Audio samples output
		audio_l_out   : out STD_LOGIC_VECTOR (31 downto 0);
		audio_r_out   : out STD_LOGIC_VECTOR (31 downto 0);
		new_sample    : out STD_LOGIC 
	);
end I2S_inteface;

architecture Behavioral of I2S_inteface is
	signal cs         : INTEGER range 0 to 6;
	signal ns         : INTEGER range 0 to 6;
	signal i_i2s_bclk : STD_LOGIC;
	signal i_i2s_d_in : STD_LOGIC;
	signal i_i2s_lr   : STD_LOGIC;
	signal l_bclk     : STD_LOGIC;

	signal shift_left : STD_LOGIC_VECTOR (31 downto 0);
	signal shift_right: STD_LOGIC_VECTOR (31 downto 0);

	begin

		process (clk, rst)
		begin
			if (rst = '0') then
				cs          <= 0; 
				ns          <= 0;
				l_bclk      <= '0';
				i_i2s_bclk  <= '0';
				i_i2s_d_in  <= '0';
				i_i2s_lr    <= '0';
				new_sample  <= '0';
				shift_right <= (others =>'0');
				shift_left  <= (others => '0');
				audio_l_out <= (others => '0');
				audio_r_out <= (others => '0');

			elsif(clk = '1' and clk'event) then
				case cs is
					when 0 =>
						audio_l_out <= (others => '0');
						audio_r_out <= (others => '0');
						if(i_i2s_lr = '0') then
							NS          <= 1;
							shift_right <= (others=>'0');
							shift_left  <= (others=>'0');
						end if;
						new_sample <= '0';
					when 1 =>
						audio_l_out <= (others => '0');
						audio_r_out <= (others => '0');
						if(l_bclk = '0' and i_i2s_bclk = '1') then
							NS <= 2;		
						end if;
					when 2 =>
						audio_l_out <= (others => '0');
						audio_r_out <= (others => '0');
						if(l_bclk = '0' and i_i2s_bclk = '1') then
							shift_left  <= shift_left(30 downto 0) & i_i2s_d_in;
							shift_right <= shift_right;
							if(i_i2s_lr = '1') then
								NS <= 3;
							end if;
						end if;
					when 3 =>
						audio_l_out <= (others => '0');
						audio_r_out <= (others => '0');
						if(l_bclk = '0' and i_i2s_bclk = '1') then
							shift_right <= shift_right(30 downto 0) & i_i2s_d_in;
							if(i_i2s_lr = '0') then
								NS <= 4;
							end if;
						end if;
					when 4 =>
						audio_l_out <= shift_left;
						audio_r_out <= shift_right;
						new_sample  <= '1';
						NS          <= 5;
					when 5=>
						audio_l_out <= (others => '0');
						audio_r_out <= (others => '0');
						shift_left  <= (others=>'0');
						shift_right <=( others=>'0');
						new_sample  <= '0';
						NS          <= 2;
					when others =>
						NS <= 0;
				end case;
			
				cs <= ns;
				l_bclk <= i_i2s_bclk;
				i_i2s_bclk <= i2s_bclk;
				i_i2s_d_in <= i2s_d_in;
				i_i2s_lr <= i2s_lr;
			end if;
					
		end process;

end Behavioral;

