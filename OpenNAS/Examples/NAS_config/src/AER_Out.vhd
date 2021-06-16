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

entity AER_Out is
	Generic(
		TAM : integer := 2048;
		IL  : integer := 11
	);
	Port(
		clk      : in  std_logic;
		rst      : in  std_logic;
		dataIn   : in  std_logic_vector(15 downto 0);
		newData  : in  std_logic;
		fifofull : out std_logic;
		aerout   : out std_logic_vector(15 downto 0);
		req_out  : out std_logic;
		ack_out  : in  std_logic
	);
end AER_Out;

architecture Behavioral of AER_Out is

	signal fifo_wr      : STD_LOGIC;
	signal fifo_rd      : STD_LOGIC;
	signal fifo_empty   : STD_LOGIC;
	signal fifo_full    : STD_LOGIC;
	signal aer_data_out : STD_LOGIC_VECTOR(15 downto 0);
	signal aer_load     : STD_LOGIC;
	signal aer_busy     : STD_LOGIC;

begin

	U_fifo : entity work.Ramfifo
		Generic Map(
			TAM => TAM,
			IL  => IL,
			WL  => 16
		)                               --512 AER events in FIFO
		Port Map(
			clk      => clk,
			wr       => fifo_wr,
			rd       => fifo_rd,
			rst_n    => rst,
			empty    => fifo_empty,
			full     => fifo_full,
			data_in  => dataIn,
			data_out => aer_data_out,
			mem_used => open
		);

	U_handshakeOut : entity work.Handshake_Out
		Port Map(
			rst     => rst,
			clk     => clk,
			ack     => ack_out,
			dataIn  => aer_data_out,
			load    => aer_load,
			req     => req_out,
			dataOut => aerout,
			busy    => aer_busy
		);

	fifofull <= fifo_full;

	fifo_wr <= (newData and (not fifo_full));

	aer_load <= (not fifo_empty) and (not aer_busy);
	fifo_rd  <= (not fifo_empty) and (not aer_busy);

end Behavioral;

