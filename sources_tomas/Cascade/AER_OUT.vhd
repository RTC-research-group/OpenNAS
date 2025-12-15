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


entity AER_OUT is
	Generic (
		TAM      : integer := 2048; 
		IL       : integer  := 11
	);
    Port ( 
		clk      : in  STD_LOGIC;
		rst      : in  STD_LOGIC;
		dataIn   : in  STD_LOGIC_VECTOR (15 downto 0);
		newData  : in  STD_LOGIC;
		fifofull : out STD_LOGIC;
		AEROUT   : out STD_LOGIC_VECTOR (15 downto 0);
		REQ_OUT  : out STD_LOGIC;
		ACK_OUT  : in  STD_LOGIC
	);
end AER_OUT;

architecture Behavioral of AER_OUT is

	component ramfifo is
		Generic (
			TAM      : integer := 2048; 
			IL       : integer := 11; 
			WL       : integer := 16
		);
		Port (
			clk      : in  STD_LOGIC; 
			wr       : in  STD_LOGIC; 
			rd	     : in  STD_LOGIC;
			rst      : in  STD_LOGIC;
			empty    : out STD_LOGIC;
			full     : out STD_LOGIC;
			data_in  : in  STD_LOGIC_VECTOR(WL-1 downto 0); 
			data_out : out STD_LOGIC_VECTOR(WL-1 downto 0); 
			mem_used : out STD_LOGIC_VECTOR(IL-1 downto 0));
	end component;

	component handshakeOut is
		Port (
			rst     : in  STD_LOGIC;
			clk     : in  STD_LOGIC;
			ack     : in  STD_LOGIC;
			dataIn  : in  STD_LOGIC_VECTOR (15 downto 0);
			load    : in  STD_LOGIC;
			req     : out STD_LOGIC;
			dataOut : out STD_LOGIC_VECTOR (15 downto 0);
			busy    : out STD_LOGIC
		);
	end component;

	signal fifo_wr      : STD_LOGIC;
	signal fifo_rd      : STD_LOGIC;
	signal fifo_empty   : STD_LOGIC;
	signal fifo_full    : STD_LOGIC;
	signal aer_data_out : STD_LOGIC_VECTOR (15 downto 0);
	signal aer_load     : STD_LOGIC;
	signal aer_busy     : STD_LOGIC;

	begin

		U_fifo: ramfifo 
		Generic Map (
			TAM      => TAM, 
			IL       => IL, 
			WL       => 16
		) --512 AER events in FIFO
		Port Map (
			clk      => CLK,
			wr       => fifo_wr,
			rd	     => fifo_rd,
			rst      => rst,
			empty    => fifo_empty,
			full     => fifo_full,
			data_in  => dataIn, 
			data_out => aer_data_out, 
			mem_used => open
		);

		U_handshakeOut: handshakeOut
		Port Map (
			rst     => rst,
			clk     => clk,
			ack     => ACK_OUT,
			dataIn  => aer_data_out,
			load    => aer_load,
			req     => REQ_OUT,
			dataOut => AEROUT,
			busy    => aer_busy
		);

		fifofull <= fifo_full;

		fifo_wr  <= (newData and (not fifo_full));

		aer_load <= (not fifo_empty) and (not aer_busy);
		fifo_rd  <= (not fifo_empty) and (not aer_busy);

	
end Behavioral;

