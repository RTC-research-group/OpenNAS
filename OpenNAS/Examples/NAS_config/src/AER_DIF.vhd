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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"

entity AER_DIF is
	Port(
		clk          : in  std_logic;
		rst_n        : in  STD_LOGIC;
		spkies_in_up : in  STD_LOGIC;
		spikes_in_un : in  STD_LOGIC;
		spikes_in_yp : in  STD_LOGIC;
		spikes_in_yn : in  STD_LOGIC;
		spikes_out_p : out STD_LOGIC;
		spikes_out_n : out STD_LOGIC
	);
end AER_DIF;

architecture Behavioral of AER_DIF is

	signal spikes_in     : STD_LOGIC_VECTOR(3 downto 0);
	signal spikes_in_tmp : STD_LOGIC_VECTOR(3 downto 0);
	signal spikes_out    : STD_LOGIC_VECTOR(1 downto 0);
	signal spikes_hold   : STD_LOGIC_VECTOR(3 downto 0);
	signal spikes_set    : STD_LOGIC_VECTOR(3 downto 0);
	signal spikes_rst    : STD_LOGIC_VECTOR(3 downto 0);

	signal spikes_extra : STD_LOGIC_VECTOR(1 downto 0);

begin

	spikes_out   <= spikes_extra;
	spikes_out_p <= spikes_out(1);
	spikes_out_n <= spikes_out(0);

	with spikes_in_tmp select spikes_in <=
		(others => '0') when b"0011",
		(others => '0') when b"1100",
		(others => '0') when b"0101",
		(others => '0') when b"1010",
		(others => '0') when b"1111",
		b"0100" when b"0110",
		b"1000" when b"1001",
		b"1000" when b"1011",
		b"0100" when b"0111",
		b"0010" when b"1110",
		b"0001" when b"1101",
		spikes_in_tmp when others;

	--tpo u: 0x0fff - tpo y: 0x0002
	u_AER_HOLDER_AND_FIRE_Up : entity work.AER_HOLDER_AND_FIRE
		Port Map(
			clk        => clk,
			rst        => spikes_rst(3),
			set        => spikes_set(3),
			hold_pulse => spikes_hold(3)
		);

	u_AER_HOLDER_AND_FIRE_Un : entity work.AER_HOLDER_AND_FIRE
		Port Map(
			clk        => clk,
			rst        => spikes_rst(2),
			set        => spikes_set(2),
			hold_pulse => spikes_hold(2)
		);

	u_AER_HOLDER_AND_FIRE_Yp : entity work.AER_HOLDER_AND_FIRE
		Port Map(
			clk        => clk,
			rst        => spikes_rst(1),
			set        => spikes_set(1),
			hold_pulse => spikes_hold(1)
		);

	u_AER_HOLDER_AND_FIRE_Yn : entity work.AER_HOLDER_AND_FIRE
		Port Map(
			clk        => clk,
			rst        => spikes_rst(0),
			set        => spikes_set(0),
			hold_pulse => spikes_hold(0)
		);

	process(rst_n, spikes_in, spikes_hold, clk, spkies_in_up, spikes_in_un, spikes_in_yp, spikes_in_yn)
	begin
		if (rst_n = '0') then
			spikes_set    <= (others => '0');
			spikes_rst    <= (others => '1');
			spikes_extra  <= (others => '0');
			spikes_in_tmp <= (others => '0');
		else
			spikes_in_tmp <= spkies_in_up & spikes_in_un & spikes_in_yp & spikes_in_yn;

			case spikes_hold is
				when b"0000" =>
					spikes_set   <= spikes_in;
					spikes_rst   <= (others => '0');
					spikes_extra <= (others => '0');
				when b"1000" =>         --Retenido U+
					case spikes_in is
						when b"0000" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
						when b"1000" =>
							spikes_set   <= b"1000";
							spikes_rst   <= (others => '0');
							spikes_extra <= b"10";
						when b"0100" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"1000";
							spikes_extra <= (others => '0');
						when b"0010" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"1000";
							spikes_extra <= (others => '0');
						when b"0001" =>
							spikes_set   <= b"0001";
							spikes_rst   <= b"1000";
							spikes_extra <= b"10";
						when others =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
					end case;
				when b"0100" =>         --Retenido U-
					case spikes_in is
						when b"0000" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
						when b"1000" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"0100";
							spikes_extra <= (others => '0');
						when b"0100" =>
							spikes_set   <= b"0100";
							spikes_rst   <= (others => '0');
							spikes_extra <= b"01";
						when b"0010" =>
							spikes_set   <= b"0010";
							spikes_rst   <= b"0100";
							spikes_extra <= b"01";
						when b"0001" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"0100";
							spikes_extra <= (others => '0');
						when others =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
					end case;
				when b"0010" =>         --Retenido Y+
					case spikes_in is
						when b"0000" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
						when b"1000" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"0010";
							spikes_extra <= (others => '0');
						when b"0100" =>
							spikes_set   <= b"0100";
							spikes_rst   <= b"0010";
							spikes_extra <= b"01";
						when b"0010" =>
							spikes_set   <= b"0010";
							spikes_rst   <= (others => '0');
							spikes_extra <= b"01";
						when b"0001" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"0010";
							spikes_extra <= (others => '0');
						when others =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
					end case;
				when b"0001" =>         --Retenido Y-
					case spikes_in is
						when b"0000" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
						when b"1000" =>
							spikes_set   <= b"1000";
							spikes_rst   <= b"0001";
							spikes_extra <= b"10";
						when b"0100" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"0001";
							spikes_extra <= (others => '0');
						when b"0010" =>
							spikes_set   <= (others => '0');
							spikes_rst   <= b"0001";
							spikes_extra <= b"00";
						when b"0001" =>
							spikes_set   <= b"0001";
							spikes_rst   <= (others => '0');
							spikes_extra <= b"10";
						when others =>
							spikes_set   <= (others => '0');
							spikes_rst   <= (others => '0');
							spikes_extra <= (others => '0');
					end case;
				when others =>
					spikes_set   <= spikes_in;
					spikes_rst   <= (others => '1');
					spikes_extra <= (others => '0');
			end case;
		end if;
	end process;

end Behavioral;

