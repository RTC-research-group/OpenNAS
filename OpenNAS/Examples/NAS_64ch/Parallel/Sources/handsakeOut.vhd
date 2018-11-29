library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity handshakeOut is
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
end handshakeOut;

architecture handout of handshakeOut is
	signal estado: integer range 0 to 5:=0;
	signal sestado:integer range 0 to 5:=0;
	signal data_int: STD_LOGIC_VECTOR (15 downto 0):=(others=>'0');




begin
		dataOut<=data_int;
	
		process(load,ack,estado,datain,estado,data_int)
		begin
			case estado is
				when 0=>
					
					req<='1';
					busy<='0';
					if(load='1') then
						sestado<=3;
					else
						sestado <=0;
					end if;
				when 3 =>	--Estado de setup
		
					busy<='1';
					req <= '1';
					sestado <= 1;
--				when 4 =>	--Estado de setup
--		
--					busy<='1';
--					req <= '1';
--					sestado <= 1;
				when 1=>

					busy<='1';
					req<='0';
					if(ack='0') then
						sestado<=2;
					else
						sestado<=1;
					end if;
				when 2 =>

					busy<='1';
					req <= '1';
					if(ack='1') then
						sestado<=5;
					else
						sestado <= 2;
					end if;
				when 5 =>	--estado de hold
		
					busy<='1';
					req <= '1';
					sestado<=0;
				when others=>

					busy<='1';
					req <= '1';
					sestado<=0;

			end case;
		end process;







--begin
--		
--		process(load,ack,estado,datain,estado,data_int)
--		begin
--			case estado is
--				when 0=>
--					dataOut<=(others=>'Z');
--					req<='1';
--					busy<='0';
--					if(load='1') then
--						sestado<=1;
--					else
--						sestado <=0;
--					end if;
--				when 1=>
--					dataOut<=data_int;
--					busy<='1';
--					req<='0';
--					if(ack='0') then
--						sestado<=2;
--					else
--						sestado<=1;
--					end if;
--				when 2 =>
--					dataOut<=data_int;
--					busy<='1';
--					req <= '1';
--					if(ack='1') then
--						sestado<=3;
--					else
--						sestado <= 2;
--					end if;
--				when 3 =>
--					dataOut<=data_int;
--					busy<='1';
--					req <= '1';
--					sestado <= 0;
--
--			end case;
--		end process;

		process(clk, rst)
		begin
			if(clk='1' and clk'event) then
				if (rst='0') then
					estado <= 0;
				else
					estado<=sestado;	
					if(load='1' and estado=0 ) then
						data_int<=dataIn;
					end if;
				end if;
			end if;
		end process;

end handout;

