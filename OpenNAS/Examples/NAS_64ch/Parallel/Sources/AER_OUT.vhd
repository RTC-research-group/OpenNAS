library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity AER_OUT is
	generic (TAM: in integer; IL: in integer);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  dataIn : in  STD_LOGIC_VECTOR (15 downto 0);
           newData : in  STD_LOGIC;
			  fifofull: out  STD_LOGIC;
           AEROUT : out  STD_LOGIC_VECTOR (15 downto 0);
           REQ_OUT : out  STD_LOGIC;
           ACK_OUT : in  STD_LOGIC);
end AER_OUT;

architecture Behavioral of AER_OUT is

component ramfifo is
generic (TAM: in integer; IL: in integer; WL: in integer);
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

component handshakeOut is
	PORT (
		rst: in std_logic;
		clk: in std_logic;
		ack: in STD_LOGIC;
		dataIn: in STD_LOGIC_VECTOR (15 downto 0);
		load: in std_logic;
		req: out STD_LOGIC;
		dataOut: out STD_LOGIC_VECTOR (15 downto 0);
		busy: out STD_LOGIC
		);
end component;

signal fifo_wr:STD_LOGIC;
signal fifo_rd:STD_LOGIC;
signal fifo_empty: STD_LOGIC;
signal fifo_full: STD_LOGIC;
signal aer_data_out: STD_LOGIC_VECTOR (15 downto 0);
signal aer_load: STD_LOGIC;
signal aer_busy: STD_LOGIC;

begin

U_fifo: ramfifo 
generic map (TAM=> 2048, IL=>11, WL=>16) --512 AER events in FIFO

port map
	(clk =>CLK,
 	wr=>fifo_wr,
	rd	=>fifo_rd,
	rst=>rst,
	empty=>fifo_empty,
	full=>fifo_full,
 	data_in =>dataIn, 
 	data_out=>aer_data_out, 
	mem_used=>open);

U_handshakeOut: handshakeOut
	PORT Map(
		rst=>rst,
		clk=>clk,
		ack=>ACK_OUT,
		dataIn=>aer_data_out,
		load=>aer_load,
		req=>REQ_OUT,
		dataOut=>AEROUT,
		busy=>aer_busy
		);
	
	fifofull<=fifo_full;
	
	fifo_wr<=(newData and (not fifo_full));

	aer_load<=(not fifo_empty) and (not aer_busy);
	fifo_rd<=(not fifo_empty) and (not aer_busy);

	
end Behavioral;

