-- okt_sno module testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.okt_sno_pkg.all;

entity okt_sno_tb is
end okt_sno_tb;

architecture behavior of okt_sno_tb is

    signal clk   : std_logic;
    signal rst_n : std_logic;

    signal node_data  : std_logic_vector(NAS_AER_ADDRESS_BITS - 1 downto 0);
    signal node_req_n : std_logic;
    signal node_ack_n : std_logic;

    -- Clock period definitions
    constant CLK_period : time := 10 ns;

begin

    -- Component Instantiation
    okt_sno : entity work.okt_sno_top
        port map(
            clock        => clk,
            rst_n      => rst_n,
            AER_DATA_OUT => node_data,
            AER_REQ      => node_req_n,
            AER_ACK      => node_ack_n
        );

    -- Clock process definitions
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_period / 2;
        clk <= '1';
        wait for CLK_period / 2;
    end process;

    -- ACK signal process. This process is used to simulate the ack signal from the output module. The ACK signal
    -- must be asserted after the REQ signal is asserted.
    ack_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            node_ack_n <= '1';
        elsif rising_edge(clk) then
            if node_req_n = '0' then
                node_ack_n <= '0';
            else
                node_ack_n <= '1';
            end if;
        end if;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        rst_n <= '0';
        wait for CLK_period * 10;
        rst_n <= '1';
        wait for CLK_period * 10;
        wait;
    end process;

end behavior;
