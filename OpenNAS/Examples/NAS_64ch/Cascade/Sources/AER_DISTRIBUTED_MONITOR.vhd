library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity AER_DISTRIBUTED_MONITOR is
generic (N_SPIKES: integer:=128; LOG_2_N_SPIKES: integer:=7; TAM_AER: in integer; IL_AER: in integer);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN : in  STD_LOGIC_VECTOR (N_SPIKES-1 downto 0);
           AER_DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           AER_REQ : out  STD_LOGIC;
           AER_ACK : in  STD_LOGIC);
end AER_DISTRIBUTED_MONITOR;



architecture Behavioral of AER_DISTRIBUTED_MONITOR is

component AER_DISTRIBUTED_MONITOR_MODULE is
generic (N_IN_SPIKES: integer:=N_SPIKES/4; LOG_2_N_IN_SPIKES: integer:=LOG_2_N_SPIKES-2);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN : in  STD_LOGIC_VECTOR (N_IN_SPIKES-1 downto 0);
           AER_FIFO_RD : in  STD_LOGIC;
           AER_FIFO_DATA_OUT : out  STD_LOGIC_VECTOR (LOG_2_N_IN_SPIKES-1 downto 0);
           AER_FIFO_MEM_USED : out  STD_LOGIC_VECTOR (7 downto 0);
			  AER_FIFO_EMPTY : out  STD_LOGIC);
end component;

component AER_OUT is
	generic (TAM: in integer; IL: in integer);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  dataIn : in  STD_LOGIC_VECTOR (15 downto 0);
           newData : in  STD_LOGIC;
			  fifofull: out  STD_LOGIC;
           AEROUT : out  STD_LOGIC_VECTOR (15 downto 0);
           REQ_OUT : out  STD_LOGIC;
           ACK_OUT : in  STD_LOGIC);
end component;
	
signal fifo_rd_0:std_logic:='0';
signal fifo_rd_1:std_logic:='0';
signal fifo_rd_2:std_logic:='0';
signal fifo_rd_3:std_logic:='0';
signal fifo_empty_0:std_logic:='0';
signal fifo_empty_1:std_logic:='0';
signal fifo_empty_2:std_logic:='0';
signal fifo_empty_3:std_logic:='0';
signal aer_fifo_data_out_0 :  STD_LOGIC_VECTOR (LOG_2_N_SPIKES-3 downto 0);
signal aer_fifo_data_out_1 :  STD_LOGIC_VECTOR (LOG_2_N_SPIKES-3 downto 0);
signal aer_fifo_data_out_2 :  STD_LOGIC_VECTOR (LOG_2_N_SPIKES-3 downto 0);
signal aer_fifo_data_out_3 :  STD_LOGIC_VECTOR (LOG_2_N_SPIKES-3 downto 0);
signal aer_out_wr:std_logic:='0';
signal aer_out_full:std_logic:='0';
signal aer_out_data_in: STD_LOGIC_VECTOR (15 downto 0);
signal state:std_logic_vector (1 downto 0):=(others=>'0');
begin



U_AER_DISTRIBUTED_MONITOR_MODULE_0: AER_DISTRIBUTED_MONITOR_MODULE --Parte Baja
 Port map( clk =>clk,
           rst =>rst,
           SPIKES_IN =>SPIKES_IN(N_SPIKES/4-1 downto 0),
           AER_FIFO_RD =>fifo_rd_0,
           AER_FIFO_DATA_OUT =>aer_fifo_data_out_0,
           AER_FIFO_MEM_USED =>open,
			  AER_FIFO_EMPTY =>fifo_empty_0
			  );

U_AER_DISTRIBUTED_MONITOR_MODULE_1: AER_DISTRIBUTED_MONITOR_MODULE  
 Port map( clk =>clk,
           rst =>rst,
           SPIKES_IN =>SPIKES_IN(N_SPIKES/2-1 downto N_SPIKES/4),
           AER_FIFO_RD =>fifo_rd_1,
           AER_FIFO_DATA_OUT =>aer_fifo_data_out_1,
           AER_FIFO_MEM_USED =>open,
			  AER_FIFO_EMPTY =>fifo_empty_1
			  );

U_AER_DISTRIBUTED_MONITOR_MODULE_2: AER_DISTRIBUTED_MONITOR_MODULE  
 Port map( clk =>clk,
           rst =>rst,
           SPIKES_IN =>SPIKES_IN(3*N_SPIKES/4-1 downto N_SPIKES/2),
           AER_FIFO_RD =>fifo_rd_2,
           AER_FIFO_DATA_OUT =>aer_fifo_data_out_2,
           AER_FIFO_MEM_USED =>open,
			  AER_FIFO_EMPTY =>fifo_empty_2
			  );

U_AER_DISTRIBUTED_MONITOR_MODULE_3: AER_DISTRIBUTED_MONITOR_MODULE  --Parte Alta
 Port map( clk =>clk,
           rst =>rst,
           SPIKES_IN =>SPIKES_IN(N_SPIKES-1 downto 3*N_SPIKES/4),
           AER_FIFO_RD =>fifo_rd_3,
           AER_FIFO_DATA_OUT =>aer_fifo_data_out_3,
           AER_FIFO_MEM_USED =>open,
			  AER_FIFO_EMPTY =>fifo_empty_3
			  );


U_AER_OUT: AER_OUT 
Generic map(TAM=> TAM_AER, IL=> IL_AER)
    Port map( clk =>clk,
           rst =>rst,
			  dataIn =>aer_out_data_in,
           newData =>aer_out_wr,
			  fifofull=>aer_out_full,
           AEROUT =>AER_DATA_OUT,
           REQ_OUT =>AER_REQ,
           ACK_OUT=>AER_ACK);


process(clk,rst,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_empty_3,aer_out_full,aer_fifo_data_out_0,aer_fifo_data_out_1,aer_fifo_data_out_2,aer_fifo_data_out_3)
begin

if(rst='0') then
	state<=b"00";
	aer_out_wr<='0';
	fifo_rd_0<='0';
	fifo_rd_1<='0';
	fifo_rd_2<='0';
	fifo_rd_3<='0';	
elsif(clk'event and clk='1') then
	if(aer_out_full ='0') then	--Si no esta llena la fifo de salida
		if(state=b"00" and fifo_empty_0='0') then
			fifo_rd_0<='1';
			fifo_rd_1<='0';
			fifo_rd_2<='0';
			fifo_rd_3<='0';		
			aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
			aer_out_data_in(LOG_2_N_SPIKES-1 downto 0)<=state & aer_fifo_data_out_0;
			aer_out_wr<='1';
		elsif(state=b"01" and fifo_empty_1='0') then
			fifo_rd_0<='0';
			fifo_rd_1<='1';
			fifo_rd_2<='0';
			fifo_rd_3<='0';			
			aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
			aer_out_data_in(LOG_2_N_SPIKES-1 downto 0)<=state & aer_fifo_data_out_1;
			aer_out_wr<='1';
		elsif(state=b"10" and fifo_empty_2='0') then
			fifo_rd_0<='0';
			fifo_rd_1<='0';
			fifo_rd_2<='1';
			fifo_rd_3<='0';			
			aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
			aer_out_data_in(LOG_2_N_SPIKES-1 downto 0)<=state & aer_fifo_data_out_2;
			aer_out_wr<='1';	
		elsif(state=b"11" and fifo_empty_3='0') then
			fifo_rd_0<='0';
			fifo_rd_1<='0';
			fifo_rd_2<='0';
			fifo_rd_3<='1';			
			aer_out_data_in(15 downto LOG_2_N_SPIKES)<=(others=>'0');
			aer_out_data_in(LOG_2_N_SPIKES-1 downto 0)<=state & aer_fifo_data_out_3;
			aer_out_wr<='1';				
		else
			fifo_rd_0<='0';
			fifo_rd_1<='0';
			fifo_rd_2<='0';
			fifo_rd_3<='0';				
			aer_out_wr<='0';	
		end if;
	end if;
	state<=state+1;
end if;



end process;



end Behavioral;