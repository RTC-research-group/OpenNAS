library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity AER_DISTRIBUTED_MONITOR_MODULE is
generic (N_IN_SPIKES: integer:=32; LOG_2_N_IN_SPIKES: integer:=5);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN : in  STD_LOGIC_VECTOR (N_IN_SPIKES-1 downto 0);
           AER_FIFO_RD : in  STD_LOGIC;
           AER_FIFO_DATA_OUT : out  STD_LOGIC_VECTOR (LOG_2_N_IN_SPIKES-1 downto 0);
           AER_FIFO_MEM_USED : out  STD_LOGIC_VECTOR (7 downto 0);
			  AER_FIFO_EMPTY : out  STD_LOGIC);
end AER_DISTRIBUTED_MONITOR_MODULE;

architecture Behavioral of AER_DISTRIBUTED_MONITOR_MODULE is


	component ramfifo is
	generic (TAM: in integer:= 256; IL: in integer:=8; WL: in integer:=LOG_2_N_IN_SPIKES);
	 port (clk  : in std_logic; 
		wr   : in std_logic; 
		rd	: in std_logic;
		rst: in std_logic;
		empty: out std_logic;
		full: out std_logic;
		data_in   : in std_logic_vector(WL-1 downto 0); 
		data_out  : out std_logic_vector(WL-1 downto 0); 
		mem_used : out std_logic_vector(IL-1 downto 0));
	end component;
	
	signal int_spikes: std_logic_vector(N_IN_SPIKES-1 downto 0);
	signal n_spikes: std_logic_vector(LOG_2_N_IN_SPIKES-2 downto 0); --No seria menos 2?
	signal aer_fifo_wr: std_logic :='0';
	signal aer_fifo_full: std_logic:='0';
	signal aer_fifo_data_in: std_logic_vector(LOG_2_N_IN_SPIKES-1 downto 0):=(others=>'0');
begin


process (clk,rst,int_spikes,spikes_in, n_spikes,aer_fifo_full)
variable i: integer range 0 to N_IN_SPIKES/2-1:=0;
begin

	
	if (clk'event and clk='1') then
		if (rst='0') then
			int_spikes<=(others=>'0');
			n_spikes<=(others=>'0');
				aer_fifo_wr<='0';
				aer_fifo_data_in<=(others=>'0');	
				int_spikes<=(others=>'0');
		else
	
			for i in 0 to N_IN_SPIKES/2-1 loop	

					if(spikes_in(2*i)='1' or spikes_in(2*i+1)='1') then
						int_spikes(i)<=spikes_in(2*i) or spikes_in(2*i+1);
						int_spikes(N_IN_SPIKES/2+i)<=spikes_in(2*i+1);
					end if;
			end loop;
			
			if(int_spikes(conv_integer( n_spikes)) = '1') then
		

				int_spikes(conv_integer(n_spikes))<='0';
				int_spikes(N_IN_SPIKES/2+conv_integer(n_spikes))<='0';
				aer_fifo_data_in<=n_spikes & int_spikes(N_IN_SPIKES/2+conv_integer(n_spikes));	--Escribo en la fifo
				aer_fifo_wr<=not aer_fifo_full;
			else
				aer_fifo_wr<='0';
				aer_fifo_data_in<=(others=>'0');
			end if;
			n_spikes<=n_spikes+1;	--apunto al siguiente
		end if;
	end if;

end process;

U_AER_FIFO:	ramfifo 
	 port map(clk  =>clk, 
		wr  => aer_fifo_wr, 
		rd	=> aer_fifo_rd,
		rst=> rst,
		empty=> aer_fifo_empty,
		full=> aer_fifo_full,
		data_in  => aer_fifo_data_in,
		data_out  => aer_fifo_data_out,
		mem_used => aer_fifo_mem_used);
	


end Behavioral;

