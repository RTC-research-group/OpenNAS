library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dualram is
generic (TAM: in integer:= 64; IL: in integer:=6; WL: in integer:=32);
 port (clk  : in std_logic; 
 	wr   : in std_logic; 
 	index_i : in std_logic_vector(IL-1 downto 0); 
 	index_o : in std_logic_vector(IL-1 downto 0); 
 	word_i   : in std_logic_vector(WL-1 downto 0); 
 	word_o  : out std_logic_vector(WL-1 downto 0)); 
end dualram;


-- Only XST supports RAM inference
-- Infers Dual Port Distributed Ram 
 
 architecture syn of dualram is 
 type ram_type is array (TAM-1 downto 0) of std_logic_vector (WL-1 downto 0); 
 signal RAM : ram_type; 
 
 begin 
 process (clk, index_i, word_i, wr) 
 begin 
 	if (clk'event and clk = '1') then  
 		if (wr = '1') then 
 			RAM(conv_integer(index_i)) <= word_i; 
 		end if; 
 	end if; 
 end process;
 
 word_o <= RAM(conv_integer(index_o)); 
 
 end syn;
 

