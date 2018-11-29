library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Spikes_Generator_signed_BW is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  FREQ_DIV: in STD_LOGIC_VECTOR(15 downto 0);
			  DATA_IN: in STD_LOGIC_VECTOR(19 downto 0);
			  WR: in STD_LOGIC;
           SPIKE_P : out  STD_LOGIC;
			  SPIKE_N : out  STD_LOGIC);
end Spikes_Generator_signed_BW;

architecture Behavioral of Spikes_Generator_signed_BW is

	signal ciclo: STD_LOGIC_VECTOR (18 downto 0):=(others=>'0');	
	signal ciclo_wise: STD_LOGIC_VECTOR (18 downto 0):=(others=>'0') ;
	signal pulse: STD_LOGIC:='0';
	signal data_int: STD_LOGIC_VECTOR (19 downto 0):=(others=>'0') ;
	signal data_temp: STD_LOGIC_VECTOR (18 downto 0):=(others=>'0') ;

	signal CE: STD_LOGIC:='0';

	signal tmp_count: STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');

begin

	process(clk,rst,ciclo,wr,data_in)
	begin

		if(clk='1' and clk'event) then
			if(rst='0') then
				data_int<=(others=>'0');
			
			elsif (WR='1') then

				data_int<=data_in;

			end if;

		end if;

		for i in 0 to 18 loop
			ciclo_wise(18-i)<=ciclo(i);
		end loop;
		
	end process;

	data_temp<=conv_std_logic_vector(abs(signed(data_int)),19);

	process(clk,rst,data_in,pulse,ciclo,ciclo_wise,data_temp)
	begin
			if(clk='1' and clk'event) then
				if(rst='0') then
					ciclo<=(others=>'0');
					tmp_count<=(others=>'0');
					CE<='0';
					
					Spike_p<='0';
					Spike_n<='0';			

					pulse<='0';	
					
				else
		 
					if(freq_div=tmp_count) then
						tmp_count<=(others=>'0');
						ciclo<=ciclo+1;				
						CE<='1';
					else
						tmp_count<=tmp_count+1;
						CE<='0';
					end if;

--					if (CE='1' and ((conv_integer(ciclo)*conv_integer (data_temp)) mod 524288) < conv_integer(data_temp)) then
					if ( CE='1' and (conv_integer(data_temp) > conv_integer(ciclo_wise) )) then
						pulse<='1';
					else
						pulse<='0';
					end if;
					
					if(data_int(19)='1') then
						Spike_p<='0';
						Spike_n<=pulse;			
					else
						Spike_p<=pulse;
						Spike_n<='0';
					end if;
					
				end if;
				
		end if;
	end process;

end Behavioral;

