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
use ieee.std_logic_arith.all; -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all; -- @suppress "Deprecated package"

entity AER_Distributed_Monitor_Module is
	Generic (
		N_IN_SPIKES       : integer := 32; 
		LOG_2_N_IN_SPIKES : integer := 5
	);
	Port ( 
		clk               : in  std_logic;
		rst_n               : in  std_logic;
		spikes_in         : in  std_logic_vector (N_IN_SPIKES-1 downto 0);
		aer_fifo_rd       : in  std_logic;
		aer_fifo_data_out : out std_logic_vector (LOG_2_N_IN_SPIKES-1 downto 0);
		aer_fifo_mem_used : out std_logic_vector (7 downto 0);
		aer_fifo_empty    : out std_logic
	);
end AER_Distributed_Monitor_Module;

architecture Behavioral of AER_Distributed_Monitor_Module is
	
	signal int_spikes       : std_logic_vector(N_IN_SPIKES-1 downto 0);
	signal n_spikes         : std_logic_vector(LOG_2_N_IN_SPIKES-2 downto 0); --No seria menos 2?
	signal aer_fifo_wr      : std_logic;
	signal aer_fifo_full    : std_logic;
	signal aer_fifo_data_in : std_logic_vector(LOG_2_N_IN_SPIKES-1 downto 0);

	begin
		process (clk,rst_n)
			-- variable i: integer range 0 to N_IN_SPIKES/2-1 := 0;
		begin
			if(rst_n = '0') then
				-- i                := 0;
				int_spikes       <= (others => '0');
				n_spikes         <= (others=>'0');
				aer_fifo_wr      <= '0';
				aer_fifo_data_in <= (others=>'0');	
				int_spikes       <= (others=>'0');
			else
				if (clk'event and clk = '1') then
					for i in 0 to N_IN_SPIKES/2-1 loop	
						if(spikes_in(2*i) = '1' or spikes_in(2*i+1) = '1') then
							int_spikes(i)               <= spikes_in(2*i) or spikes_in(2*i+1);
							int_spikes(N_IN_SPIKES/2+i) <= spikes_in(2*i+1);
						end if;
					end loop;
						
					if(int_spikes(conv_integer( n_spikes)) = '1') then
						int_spikes(conv_integer(n_spikes)) <= '0';
						int_spikes(N_IN_SPIKES/2+conv_integer(n_spikes)) <= '0';
						aer_fifo_data_in                   <= n_spikes & int_spikes(N_IN_SPIKES/2+conv_integer(n_spikes));	--Escribo en la fifo
						aer_fifo_wr                        <= not aer_fifo_full;
					else
						aer_fifo_wr                        <= '0';
						aer_fifo_data_in                   <= (others=>'0');
					end if;
					
					n_spikes <= n_spikes+1;	--apunto al siguiente
				else
				
				end if;
			end if;

		end process;

		U_AER_Fifo: entity	work.Ramfifo
		Generic Map (
			TAM      => 256, 
			IL       => 8, 
			WL       => LOG_2_N_IN_SPIKES
		)
		Port Map (
			clk      => clk, 
			wr       => aer_fifo_wr, 
			rd	     => aer_fifo_rd,
			rst_n      => rst_n,
			empty    => aer_fifo_empty,
			full     => aer_fifo_full,
			data_in  => aer_fifo_data_in,
			data_out => aer_fifo_data_out,
			mem_used => aer_fifo_mem_used
		);
		
end Behavioral;

