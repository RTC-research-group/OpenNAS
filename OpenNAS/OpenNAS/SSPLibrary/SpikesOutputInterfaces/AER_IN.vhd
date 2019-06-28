--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                     //
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
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity AER_IN is
	--generic (TAM: in integer; IL: in integer);
    Port ( i_clk : in  STD_LOGIC;
           i_rst : in  STD_LOGIC;
           --AER handshake
           i_aer_in : in  STD_LOGIC_VECTOR (15 downto 0);
           i_req_in : in  STD_LOGIC;
           o_ack_in : out  STD_LOGIC;
           --AER data output to be processed
		   o_aer_data : out STD_LOGIC_VECTOR(15 downto 0);
		   o_new_aer_data : out std_logic
		   );
end AER_IN;

architecture Behavioral of AER_IN is
	
--FSM
	type state is (reset, idle,
						capture_event, wait_REQ, remove_ACK);
	signal current_state, next_state : state;
	
begin
	
	FSM_clocked : process (i_clk, i_rst)
		begin
			if i_rst = '0' then
				current_state <= reset;
				
			elsif rising_edge(i_clk) then
				current_state <= next_state;
			end if;
			
		end process FSM_clocked;
		
	FSM_transition: process(current_state, i_req_in)
	begin
		next_state <= current_state;
				
		case current_state is
			
			when reset =>
				next_state <= idle;
				
			when idle =>
				if i_req_in = '0' then
					next_state <= capture_event;
				end if;
			
			when capture_event =>
				next_state <= wait_REQ;
				
			when wait_REQ =>
				if i_req_in = '1' then
					next_state <= remove_ACK;
				end if;
				
			when remove_ACK =>
				next_state <= idle;
				
			when others =>
				next_state <= idle;
				
		end case;
	end process FSM_transition;
	
	Output_secuential : process (i_clk)
	begin
		if rising_edge(i_clk) then
			case current_state is
			
				when reset =>
					o_ack_in <= '1';
					o_new_aer_data <= '0';
					o_aer_data <= (others => '0');
					
				when capture_event =>
					o_ack_in <= '0';
					o_aer_data <= i_aer_in;
					o_new_aer_data <= '1';
					
				when wait_REQ =>
				    o_new_aer_data <= '0';
				    
				when remove_ACK =>
					o_ack_in <= '1';
					o_aer_data <= (others => '0');
				
				when others =>
					null;
					
			end case;
		end if;
	end process Output_secuential;
    
end Behavioral;