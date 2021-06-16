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

entity AER_Distributed_Monitor is
	Generic(
		N_SPIKES       : integer := 128;
		LOG_2_N_SPIKES : integer := 7;
		TAM_AER        : integer := 512;
		IL_AER         : integer := 11
	);
	Port(
		clk          : in  std_logic;
		rst_n        : in  std_logic;
		spikes_in    : in  std_logic_vector(N_SPIKES - 1 downto 0);
		aer_data_out : out std_logic_vector(15 downto 0);
		aer_req      : out std_logic;
		aer_ack      : in  std_logic
	);
end AER_Distributed_Monitor;

architecture Behavioral of AER_Distributed_Monitor is

	signal fifo_rd_0           : std_logic;
	signal fifo_rd_1           : std_logic;
	signal fifo_rd_2           : std_logic;
	signal fifo_rd_3           : std_logic;
	signal fifo_empty_0        : std_logic;
	signal fifo_empty_1        : std_logic;
	signal fifo_empty_2        : std_logic;
	signal fifo_empty_3        : std_logic;
	signal aer_fifo_data_out_0 : std_logic_vector(LOG_2_N_SPIKES - 3 downto 0);
	signal aer_fifo_data_out_1 : std_logic_vector(LOG_2_N_SPIKES - 3 downto 0);
	signal aer_fifo_data_out_2 : std_logic_vector(LOG_2_N_SPIKES - 3 downto 0);
	signal aer_fifo_data_out_3 : std_logic_vector(LOG_2_N_SPIKES - 3 downto 0);
	signal aer_out_wr          : std_logic;
	signal aer_out_full        : std_logic;
	signal aer_out_data_in     : std_logic_vector(15 downto 0);
	signal state               : std_logic_vector(1 downto 0);

begin

	U_AER_Distributed_Monitor_Module_0 : entity work.AER_Distributed_Monitor_Module --Parte Baja
		Generic Map(
			N_IN_SPIKES       => N_SPIKES / 4,
			LOG_2_N_IN_SPIKES => LOG_2_N_SPIKES - 2
		)
		Port Map(
			clk               => clk,
			rst_n             => rst_n,
			spikes_in         => spikes_in(N_SPIKES / 4 - 1 downto 0),
			aer_fifo_rd       => fifo_rd_0,
			aer_fifo_data_out => aer_fifo_data_out_0,
			aer_fifo_mem_used => open,
			aer_fifo_empty    => fifo_empty_0
		);

	U_AER_Distributed_Monitor_Module_1 : entity work.AER_Distributed_Monitor_Module
		Generic Map(
			N_IN_SPIKES       => N_SPIKES / 4,
			LOG_2_N_IN_SPIKES => LOG_2_N_SPIKES - 2
		)
		Port Map(
			clk               => clk,
			rst_n             => rst_n,
			spikes_in         => spikes_in(N_SPIKES / 2 - 1 downto N_SPIKES / 4),
			aer_fifo_rd       => fifo_rd_1,
			aer_fifo_data_out => aer_fifo_data_out_1,
			aer_fifo_mem_used => open,
			aer_fifo_empty    => fifo_empty_1
		);

	U_AER_Distributed_Monitor_Module_2 : entity work.AER_Distributed_Monitor_Module
		Generic Map(
			N_IN_SPIKES       => N_SPIKES / 4,
			LOG_2_N_IN_SPIKES => LOG_2_N_SPIKES - 2
		)
		Port Map(
			clk               => clk,
			rst_n             => rst_n,
			spikes_in         => spikes_in(3 * N_SPIKES / 4 - 1 downto N_SPIKES / 2),
			aer_fifo_rd       => fifo_rd_2,
			aer_fifo_data_out => aer_fifo_data_out_2,
			aer_fifo_mem_used => open,
			aer_fifo_empty    => fifo_empty_2
		);

	U_AER_Distributed_Monitor_Module_3 : entity work.AER_Distributed_Monitor_Module --Parte Alta
		Generic Map(
			N_IN_SPIKES       => N_SPIKES / 4,
			LOG_2_N_IN_SPIKES => LOG_2_N_SPIKES - 2
		)
		Port Map(
			clk               => clk,
			rst_n             => rst_n,
			spikes_in         => spikes_in(N_SPIKES - 1 downto 3 * N_SPIKES / 4),
			aer_fifo_rd       => fifo_rd_3,
			aer_fifo_data_out => aer_fifo_data_out_3,
			aer_fifo_mem_used => open,
			aer_fifo_empty    => fifo_empty_3
		);

	U_AER_OUT : entity work.AER_Out
		Generic Map(
			TAM => TAM_AER,
			IL  => IL_AER
		)
		Port Map(
			clk      => clk,
			rst      => rst_n,
			dataIn   => aer_out_data_in,
			newData  => aer_out_wr,
			fifofull => aer_out_full,
			aerout   => aer_data_out,
			req_out  => aer_req,
			ack_out  => aer_ack
		);

	process(clk, rst_n)
	begin
		if (rst_n = '0') then
			state           <= b"00";
			aer_out_wr      <= '0';
			fifo_rd_0       <= '0';
			fifo_rd_1       <= '0';
			fifo_rd_2       <= '0';
			fifo_rd_3       <= '0';
			aer_out_data_in <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (aer_out_full = '0') then --Si no esta llena la fifo de salida
				if (state = b"00" and fifo_empty_0 = '0') then
					fifo_rd_0                                    <= '1';
					fifo_rd_1                                    <= '0';
					fifo_rd_2                                    <= '0';
					fifo_rd_3                                    <= '0';
					--aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
					aer_out_data_in(LOG_2_N_SPIKES - 1 downto 0) <= state & aer_fifo_data_out_0;
					aer_out_wr                                   <= '1';
				elsif (state = b"01" and fifo_empty_1 = '0') then
					fifo_rd_0                                    <= '0';
					fifo_rd_1                                    <= '1';
					fifo_rd_2                                    <= '0';
					fifo_rd_3                                    <= '0';
					--aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
					aer_out_data_in(LOG_2_N_SPIKES - 1 downto 0) <= state & aer_fifo_data_out_1;
					aer_out_wr                                   <= '1';
				elsif (state = b"10" and fifo_empty_2 = '0') then
					fifo_rd_0                                    <= '0';
					fifo_rd_1                                    <= '0';
					fifo_rd_2                                    <= '1';
					fifo_rd_3                                    <= '0';
					--aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
					aer_out_data_in(LOG_2_N_SPIKES - 1 downto 0) <= state & aer_fifo_data_out_2;
					aer_out_wr                                   <= '1';
				elsif (state = b"11" and fifo_empty_3 = '0') then
					fifo_rd_0                                    <= '0';
					fifo_rd_1                                    <= '0';
					fifo_rd_2                                    <= '0';
					fifo_rd_3                                    <= '1';
					--aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
					aer_out_data_in(LOG_2_N_SPIKES - 1 downto 0) <= state & aer_fifo_data_out_3;
					aer_out_wr                                   <= '1';
				else
					fifo_rd_0       <= '0';
					fifo_rd_1       <= '0';
					fifo_rd_2       <= '0';
					aer_out_data_in <= (others => '0');
					fifo_rd_3       <= '0';
					aer_out_wr      <= '0';
				end if;
			end if;
			state <= state + 1;
		end if;
	end process;

end Behavioral;
