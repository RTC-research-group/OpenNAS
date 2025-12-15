
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:02:24 03/20/2023 
-- Design Name: 
-- Module Name:    okt_sno_top - Behavioral 
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
--      This module is the top module of the synthetic NAS output generator to test the monitoring
--      tool of the OKAERTools.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use work.okt_sno_pkg.all;

entity okt_sno_top is
    port(
        clock        : in  std_logic;
        rst_n      : in  std_logic;
        -- AER OUTPUT interface
        AER_DATA_OUT : out std_logic_vector(NAS_AER_ADDRESS_BITS - 1 downto 0);
        AER_REQ      : out std_logic;
        AER_ACK      : in  std_logic
    );
end okt_sno_top;

architecture Behavioral of okt_sno_top is
    --latch signals
    signal node_ack_n_latch_0, node_ack_n_latch_1 : std_logic;

begin

    -- Instantiate the OKT_SNO module
    okt_sno_inst : entity work.okt_sno
        port map(
            clk        => clock,
            rst_n      => rst_n,
            node_data  => AER_DATA_OUT,
            node_req_n => AER_REQ,
            node_ack_n => node_ack_n_latch_1
        );

    -- Double latch the node_ack_n signal to avoid metastability
    ACK_latch : process(clock, rst_n)
    begin
        if rst_n = '0' then
            node_ack_n_latch_0 <= '1';
            node_ack_n_latch_1 <= '1';
        elsif rising_edge(clock) then
            node_ack_n_latch_0 <= AER_ACK;
            node_ack_n_latch_1 <= node_ack_n_latch_0;
        end if;
    end process ACK_latch;

end Behavioral;
