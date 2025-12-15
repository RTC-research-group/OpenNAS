----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:02:24 03/20/2023 
-- Design Name: 
-- Module Name:    okt_sno - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--      This module is a synthetic NAS output generator to test the monitoring 
--      tool of the OKAERTools.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.okt_sno_pkg.all;

entity okt_sno is
    port(
        -- Clock and Reset
        clk        : in  std_logic;
        rst_n      : in  std_logic;
        -- AER DATA OUT
        node_data  : out std_logic_vector(NAS_AER_ADDRESS_BITS - 1 downto 0);
        node_req_n : out std_logic;
        node_ack_n : in  std_logic
    );
end entity okt_sno;

architecture rtl of okt_sno is
    -- FSM states
    type state is (IDLE, REQ, WAIT_ACK, ACK);
    signal r_okt_sno_control_state : state;
begin
    -- Generate the AER data. Use a counter (from 0 to NAS_NUM_CHANNELS * NAS_MONO_STEREO - 1)
    -- to generate the AER data. The AER follows the handshake protocol, so a FSM is needed to
    -- control the 4 steps of the handshake protocol.
    AER_generator: process(clk, rst_n)
        variable counter : integer range 0 to NAS_ADDRESS_COUNT - 1;
    begin
        if rst_n = '0' then
            counter := 0;
            node_data <= (others => '0');
            node_req_n <= '1';
            r_okt_sno_control_state <= IDLE;
        elsif rising_edge(clk) then
            case r_okt_sno_control_state is
                when IDLE =>
                    if node_ack_n = '1' then
                        r_okt_sno_control_state <= REQ;
                    end if;

                when REQ =>
                    node_data <= std_logic_vector(to_unsigned(counter, NAS_AER_ADDRESS_BITS));
                    node_req_n <= '0';
                    r_okt_sno_control_state <= WAIT_ACK;

                when WAIT_ACK =>
                    if node_ack_n = '0' then
                        r_okt_sno_control_state <= ACK;
                    end if;

                when ACK =>
                    node_req_n <= '1';
                    node_data <= (others => '0');
                    if node_ack_n = '1' then
                        counter := counter + 1;
                        if counter = NAS_ADDRESS_COUNT then
                            counter := 0;
                        end if;
                        r_okt_sno_control_state <= IDLE;
                    end if;
                end case;
        end if;
    end process AER_generator;
    

end architecture rtl;

