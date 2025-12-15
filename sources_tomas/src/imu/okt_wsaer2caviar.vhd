--------------------------------------------------------------------------------
-- Company: ini
-- Engineer: Alejandro Linares
--
-- Create Date:    14:16:08 06/17/14
-- Design Name:    
-- Module Name:    okt_wsaer2caviar 
-- Project Name:   VISUALIZE
-- Target Device:  Latticed LFE3-17EA-7ftn256i
-- Tool versions:  Diamond x64 3.0.0.97
-- Description: Module to convert word-serial AER from DAViS to CAVIAR parallel AER
--
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity okt_wsaer2caviar is
  port (
    WSAER_data : in std_logic_vector(9 downto 0); --bit 0 is polarity and bit 9 row / column.
	WSAER_req : in std_logic; --active low and synchronized
	WSAER_ack : out std_logic;--Supossed to be active low

    -- clock and reset inputs
	CLK : in std_logic;
    RST : in std_logic;

	row_delay: in unsigned (4 downto 0);
    -- AER monitor interface
    CAVIAR_ack    : in  std_logic;  -- needs synchronization
    CAVIAR_req    : out std_logic;
    CAVIAR_data   : out  std_logic_vector(16 downto 0));

end okt_wsaer2caviar;

architecture Structural of okt_wsaer2caviar is
   signal dWSAER_req,d1WSAER_req,d2WSAER_req, WSAER_data9, last9: std_logic;
   signal latched_ev : std_logic_vector (9 downto 0);
   type tst is (idle, req, row, row_ack, col, col_ack, send, send_ack);
   signal cs, ns: tst;
   signal cnt: unsigned (4 downto 0);
begin
process (CLK,RST)
begin
   if (RST='1') then
      CAVIAR_data <= (others => '0');
	  cs <= idle;
	  cnt <= (others => '0');
   elsif (CLK'event and CLK='1') then
      cs <= ns;
	  case cs is
	     when idle => cnt <= (others=>'0');
	     when row => 
			cnt <= cnt +1;
			if (cnt = row_delay) then
				CAVIAR_data (16 downto 9) <= WSAER_data(7 downto 0);
			end if;
		 when col => 
			CAVIAR_data (8 downto 0) <= WSAER_data(8 downto 0);
		 when others => null;
	  end case;
   end if;
end process;

process (cs, WSAER_req, CAVIAR_ack, cnt, row_delay)
begin
  CAVIAR_req <= '1';
  WSAER_ack <= '1';
  case cs is
      when idle =>
		if WSAER_req = '0' then 
		   ns <= req;
		else ns <= idle;
		end if;
	  when req =>
	    if WSAER_data(9) = '0' then
		   ns <= row;
		else 
		   ns <= col;
		end if;
	  when row => WSAER_ack <= '1';
		if (cnt = row_delay) then
		   ns <= row_ack; 
		else 
		   ns <= row;
		end if;
	  when row_ack => WSAER_ack <= '0';
		if WSAER_req = '0' then
		   ns <= row_ack;
		else ns <= idle;
		end if;
	  when col => WSAER_ack <= '1';
		   ns <= col_ack; 
	  when col_ack => WSAER_ack <= '0';
	    if WSAER_req = '0' then
		   ns <= col_ack;
		else ns <= send;
		end if;
	  when send => CAVIAR_req <= '0';
	    if CAVIAR_ack = '0' then
		  ns <= send_ack;
		else ns <= send;
	    end if;
	  when send_ack =>
	    if CAVIAR_ack = '1' then
		  ns <= idle;
		else ns <= send_ack;
		end if;
	  when others => ns <= idle;
  end case;
end process;
end Structural;
  
