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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity AER_DIF is
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
end AER_DIF;

architecture Behavioral of AER_DIF is

	component AER_HOLDER_AND_FIRE is
		Port ( 
			CLK        : in  STD_LOGIC;
			RST        : in  STD_LOGIC;
			SET        : in  STD_LOGIC;
			HOLD_PULSE : out STD_LOGIC
		);
	end component;
    
	signal SPIKES_IN      : STD_LOGIC_VECTOR(3 downto 0);
	signal SPIKES_IN_TEMP : STD_LOGIC_VECTOR(3 downto 0);
    signal SPIKES_OUT     : STD_LOGIC_VECTOR(1 downto 0);
	signal SPIKES_HOLD    : STD_LOGIC_VECTOR(3 downto 0);
	signal SPIKES_SET     : STD_LOGIC_VECTOR(3 downto 0);
	signal SPIKES_RST     : STD_LOGIC_VECTOR(3 downto 0);

	signal SPIKES_EXTRAS  : STD_LOGIC_VECTOR(1 downto 0);
	
	begin

		SPIKES_OUT   <= SPIKES_EXTRAS;
		SPIKES_OUT_P <= SPIKES_OUT(1);
		SPIKES_OUT_N <= SPIKES_OUT(0);

		WITH SPIKES_IN_TEMP SELECT
			SPIKES_IN<=
				(others=>'0')  when b"0011",
				(others=>'0')  when b"1100",		
				(others=>'0')  when b"0101",
				(others=>'0')  when b"1010",
				(others=>'0')  when b"1111",		
				b"0100"		   when b"0110",
				b"1000" 	   when b"1001",
				b"1000"		   when b"1011",
				b"0100"		   when b"0111",		
				b"0010"		   when b"1110",		
				b"0001"		   when b"1101",
				SPIKES_IN_TEMP when OTHERS;


		--tpo u: 0x0fff - tpo y: 0x0002
		u_AER_HOLDER_AND_FIRE_Up:AER_HOLDER_AND_FIRE
		Port Map (
			CLK        => clk,
			RST        => SPIKES_RST(3),
			SET        => SPIKES_SET(3),
			HOLD_PULSE => SPIKES_HOLD(3)
		);
		
		u_AER_HOLDER_AND_FIRE_Un:AER_HOLDER_AND_FIRE
		Port Map (
			CLK        => clk,
			RST        => SPIKES_RST(2),
			SET        => SPIKES_SET(2),
			HOLD_PULSE => SPIKES_HOLD(2)
		);

		u_AER_HOLDER_AND_FIRE_Yp:AER_HOLDER_AND_FIRE
		Port Map (
			CLK        => clk,
			RST        => SPIKES_RST(1),
			SET        => SPIKES_SET(1),
			HOLD_PULSE => SPIKES_HOLD(1)			  
		);
		
		u_AER_HOLDER_AND_FIRE_Yn:AER_HOLDER_AND_FIRE
		Port Map (
			CLK        => clk,
			RST        => SPIKES_RST(0),
			SET        => SPIKES_SET(0),
			HOLD_PULSE => SPIKES_HOLD(0)
		);

		process(rst, spikes_in, spikes_hold, clk, SPIKES_IN_UP, SPIKES_IN_UN, SPIKES_IN_YP, SPIKES_IN_YN)
		begin
			if(rst = '1') then
				SPIKES_SET     <= (others=>'0');
				SPIKES_RST     <= (others=>'1');
				SPIKES_EXTRAS  <= (others=>'0');
				SPIKES_IN_TEMP <= (others=>'0');
			else
				SPIKES_IN_TEMP <= SPIKES_IN_UP & SPIKES_IN_UN & SPIKES_IN_YP & SPIKES_IN_YN;

				case SPIKES_HOLD is
					when b"0000" =>
						SPIKES_SET    <= SPIKES_IN;
						SPIKES_RST    <= (others=>'0');
						SPIKES_EXTRAS <= (others=>'0');
					when b"1000" =>	--Retenido U+
						case SPIKES_IN is
							when b"0000" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= (others=>'0');
							when b"1000" =>
								SPIKES_SET    <= b"1000";
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= b"10";
							when b"0100" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"1000";
								SPIKES_EXTRAS <= (others=>'0');
							when b"0010" =>
								SPIKES_SET    <=( others=>'0');
								SPIKES_RST    <= b"1000";
								SPIKES_EXTRAS <= (others=>'0');
							when b"0001" =>
								SPIKES_SET    <= b"0001";
								SPIKES_RST    <= b"1000";
								SPIKES_EXTRAS <= b"10";
							when others =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= (others=>'0');
						end case;
					when b"0100" =>--Retenido U-
						case SPIKES_IN is
							when b"0000" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= (others=>'0');
							when b"1000" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"0100";
								SPIKES_EXTRAS <= (others=>'0');
							when b"0100" =>
								SPIKES_SET    <= b"0100";
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= b"01";
							when b"0010" =>
								SPIKES_SET    <= b"0010";
								SPIKES_RST    <= b"0100";
								SPIKES_EXTRAS <= b"01";
							when b"0001" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"0100";
								SPIKES_EXTRAS <= (others=>'0');
							when others =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');		
								SPIKES_EXTRAS <= (others=>'0');							
							end case;
					when b"0010" =>--Retenido Y+
						case SPIKES_IN is
							when b"0000" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= (others=>'0');
							when b"1000" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"0010";
								SPIKES_EXTRAS <= (others=>'0');
							when b"0100" =>
								SPIKES_SET    <= b"0100";
								SPIKES_RST    <= b"0010";
								SPIKES_EXTRAS <= b"01";
							when b"0010" =>
								SPIKES_SET    <= b"0010";
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= b"01";
							when b"0001" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"0010";
								SPIKES_EXTRAS <= (others=>'0');
							when others =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');		
								SPIKES_EXTRAS <= (others=>'0');		
							end case;							
					when b"0001"=>--Retenido Y-
						case SPIKES_IN is
							when b"0000" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= (others=>'0');
							when b"1000" =>
								SPIKES_SET    <= b"1000";
								SPIKES_RST    <= b"0001";
								SPIKES_EXTRAS <= b"10";
							when b"0100" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"0001";
								SPIKES_EXTRAS <= (others=>'0');
							when b"0010" =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= b"0001";
								SPIKES_EXTRAS <= b"00";
							when b"0001" =>
								SPIKES_SET    <= b"0001";
								SPIKES_RST    <= (others=>'0');
								SPIKES_EXTRAS <= b"10";
							when others =>
								SPIKES_SET    <= (others=>'0');
								SPIKES_RST    <= (others=>'0');		
								SPIKES_EXTRAS <= (others=>'0');		
							end case;							
					when others =>
						SPIKES_SET    <= SPIKES_IN;
						SPIKES_RST    <= (others=>'1');
						SPIKES_EXTRAS <= (others=>'0');
				end case;
			end if;
		end process;
		
end Behavioral;

