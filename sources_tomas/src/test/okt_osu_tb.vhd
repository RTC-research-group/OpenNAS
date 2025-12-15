-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.okt_global_pkg.all;
use work.okt_top_pkg.all;

ENTITY okt_osu_tb IS
END okt_osu_tb;

ARCHITECTURE behavior OF okt_osu_tb IS 

	-- inputs
	signal clk   				:  std_logic;
	signal rst_n 				:  std_logic;
	signal aer_data  			:  std_logic_vector (32 - 1 downto 0);
	signal req_data_n 		:  std_logic;
	signal ecu_ack_n 			:  std_logic;
	signal cmd 					:  std_logic_vector (3 - 1 downto 0);
	signal node_ack_n 		:  std_logic;

	-- outputs
	signal node_data 		 	: std_logic_vector(32 - 1 downto 0);
	signal node_req_n 		: std_logic;
	signal out_ack_n 			: std_logic;

	signal out_osu_data 		: std_logic_vector(32 - 1 downto 0);
	signal out_osu_wr 		: std_logic;
	signal out_osu_ready 	: std_logic;
	
  
	type state is (idle, req_fall, req_rise, req_fall_1, req_rise_1);
	signal current_state, next_state, current_state_0, next_state_0 : state;
  
  constant CLK_period : time := 20 ns;
		  

BEGIN

	okt_osu : entity work.okt_osu
		port map(
			clk           				=> clk,
			rst_n      	  				=> rst_n,
			aer_in_data   				=> aer_data,
			req_in_data_n 				=> req_data_n,
			ecu_in_ack_n  				=> ecu_ack_n,
			cmd           				=> cmd,
			in_data  					=> out_osu_data,
			in_wr    					=> out_osu_wr,
			in_ready 					=> out_osu_ready,
			node_in_data  				=> node_data,
			node_req_n    				=> node_req_n,
			node_in_osu_ack_n    	=> node_ack_n,
			ecu_node_out_ack_n    	=> out_ack_n
		);
		
	CLK_process : process
	begin
		clk <= '0';
		wait for CLK_period / 2;
		clk <= '1';
		wait for CLK_period / 2;
	end process;
	
		
  --  Test Bench Statements
	stim_proc : process
	begin
	-- reset the system
		rst_n          <= '0';
		--node_data <= x"00000000";
		wait for CLK_period * 5;
		rst_n          <= '1';

		-- insert stimulus here
		wait for CLK_period * 5;
		cmd <= b"100";

		--req_data_n <= '1';
		
--		wait for CLK_period * 20;
--		aer_data <= x"00880088";
--		cmd <= b"001";
--		ecu_ack_n <= '0';
--		node_ack_n <= '0';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '0';
		while 0<1 loop
			node_ack_n <= '1';
			wait until node_req_n = '0';
			wait for CLK_period * 1;
			node_ack_n <= '0';
			wait until node_req_n = '1';
			wait for CLK_period * 1;
		end loop;

--		wait for CLK_period * 5;
--		req_data_n <= '1';
--		aer_data <= x"00770077";
--		cmd <= b"010";
--		ecu_ack_n <= '0';
--		node_ack_n <= '0';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '0';
--		node_ack_n <= '1';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '1';
--		node_ack_n <= '0';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '1';
--		node_ack_n <= '1';
--		
--		wait for CLK_period * 20;
--		req_data_n <= '0';
--		aer_data <= x"00FF00FF";
--		cmd <= b"011";
--		ecu_ack_n <= '0';
--		node_ack_n <= '0';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '0';
--		node_ack_n <= '1';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '1';
--		node_ack_n <= '0';
--		wait for CLK_period * 5;
--		ecu_ack_n <= '1';
--		node_ack_n <= '1';
--		
--		wait for CLK_period * 20;
--		req_data_n <= '1';
--		aer_data <= x"00330033";
--		cmd <= b"100";
--		
--		wait for CLK_period * 20;
--		aer_data <= x"00110011";
--		cmd <= b"111";
		
		wait;
	end process;
	
signals_update : process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= idle;


        elsif rising_edge(clk) then
            current_state <= next_state;
				
        end if;
    end process; 

-- REVISAR, SÉ QUE ESTÁ MAL PERO ME FUNCIONA PARA LO QUE NECESITO
    FSM_transition : process(current_state, out_osu_data, out_osu_ready, out_osu_wr)
    begin
        next_state <= current_state;
        out_osu_data   <= (others => '0');
		  out_osu_wr    <= '0';
		  
		  if out_osu_ready = '1' then
        case current_state is
            when idle =>
                next_state <= req_fall;
					 
            when req_fall =>
                out_osu_wr    <= '1';
                out_osu_data <= x"0000001B"; 
                next_state <= req_rise;

            when req_rise =>
                out_osu_wr    <= '1';
                out_osu_data <= x"00060F03"; 
                next_state <= req_fall_1;

            when req_fall_1 =>
                out_osu_wr    <= '1';
                out_osu_data <= x"00000005"; 
                next_state <= req_rise_1;

            when req_rise_1 =>
                out_osu_wr    <= '1';
                out_osu_data <= x"00000903"; 
                next_state <= req_fall;

        end case;
		  end if;
    end process;
    
--    read_process : process(out_osu_ready)
--    begin
--        if(out_osu_ready = '1') then
--            out_osu_wr <= '1';
--        else
--            out_osu_wr <= '0';
--        end if;
--    end process;
		
  --  End Test Bench 
  END;
