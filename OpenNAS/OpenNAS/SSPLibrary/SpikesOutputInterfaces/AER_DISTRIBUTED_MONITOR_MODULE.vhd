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

entity AER_DISTRIBUTED_MONITOR_MODULE is
	Generic (
		N_IN_SPIKES       : INTEGER := 32; 
		LOG_2_N_IN_SPIKES : INTEGER := 5
	);
	Port ( 
		CLK               : in  STD_LOGIC;
		RST               : in  STD_LOGIC;
		SPIKES_IN         : in  STD_LOGIC_VECTOR (N_IN_SPIKES-1 downto 0);
		AER_FIFO_RD       : in  STD_LOGIC;
		AER_FIFO_DATA_OUT : out STD_LOGIC_VECTOR (LOG_2_N_IN_SPIKES-1 downto 0);
		AER_FIFO_MEM_USED : out STD_LOGIC_VECTOR (7 downto 0);
		AER_FIFO_EMPTY    : out STD_LOGIC
	);
end AER_DISTRIBUTED_MONITOR_MODULE;

architecture Behavioral of AER_DISTRIBUTED_MONITOR_MODULE is

	component ramfifo is
		Generic (
			TAM      : in INTEGER := 256; 
			IL       : in INTEGER := 8; 
			WL       : in INTEGER := LOG_2_N_IN_SPIKES
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
			mem_used : out STD_LOGIC_VECTOR(IL-1 downto 0)
		);
	end component;
	
	signal int_spikes       : STD_LOGIC_VECTOR(N_IN_SPIKES-1 downto 0);
	signal n_spikes         : STD_LOGIC_VECTOR(LOG_2_N_IN_SPIKES-2 downto 0); --No seria menos 2?
	signal aer_fifo_wr      : STD_LOGIC;
	signal aer_fifo_full    : STD_LOGIC;
	signal aer_fifo_data_in : STD_LOGIC_VECTOR(LOG_2_N_IN_SPIKES-1 downto 0);

	begin


		process (clk,rst,int_spikes,spikes_in, n_spikes,aer_fifo_full)
			variable i: integer range 0 to N_IN_SPIKES/2-1 := 0;
		begin
			if(rst = '0') then
				i                := 0;
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

		U_AER_FIFO:	ramfifo
		Generic Map (
			TAM      => 256, 
			IL       => 8, 
			WL       => LOG_2_N_IN_SPIKES
		)
		Port Map (
			clk      => clk, 
			wr       => aer_fifo_wr, 
			rd	     => aer_fifo_rd,
			rst      => rst,
			empty    => aer_fifo_empty,
			full     => aer_fifo_full,
			data_in  => aer_fifo_data_in,
			data_out => aer_fifo_data_out,
			mem_used => aer_fifo_mem_used
		);
		
end Behavioral;

