
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"
use work.okt_global_pkg.all;
use work.okt_fifo_pkg.all;
use work.okt_top_pkg.all;
use std.env.finish;
use work.okt_cu_pkg.all;

ENTITY okt_ecu_tb IS
END okt_ecu_tb;

ARCHITECTURE behavior OF okt_ecu_tb IS

    --Inputs
    signal clk      : std_logic                                        := '0';
    signal rst_n    : std_logic                                        := '0';
    signal req_n    : std_logic                                        := '0';
    signal aer_data : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0) := (others => '0');

    signal aer_data_r : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0) := (others => '0');
    signal force_ovf  : std_logic;
    signal command  : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0);

    --Outputs
    signal ack_n     : std_logic;
    signal out_data  : std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);  -- @suppress "Signal out_data is never read"
    signal out_rd    : std_logic;
    signal out_ready : std_logic;

    -- Clock period definitions
    constant CLK_period : time := 20 ns;

    type state is (idle, req_fall, req_rise);
    signal current_state, next_state : state;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    okt_ecu : entity work.okt_ecu
        port map(
            clk           => clk,
            rst_n         => rst_n,
            ecu_req_n     => req_n,
            aer_data      => aer_data,
            ecu_out_ack_n => ack_n,
            out_data      => out_data,
            out_rd        => out_rd,
            out_ready     => out_ready,
            cmd           => command
        );

    -- Clock process definitions
    CLK_process : process
    begin
        clk <= '0';
        wait for CLK_period / 2;
        clk <= '1';
        wait for CLK_period / 2;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        report "hold reset state for 100 ns";
        wait for 100 ns;
        force_ovf <= '0';
        rst_n     <= '0';
        wait for CLK_period * 10;
        rst_n     <= '1';
        report "reset deasserted";
        -- insert stimulus here

        report "Send a few AER events";
        command <= Mask_MON;
        wait for 500 us;
        report "Force an overflow for 2 ms";
        force_ovf <= '1';
        wait for 2 ms;
        report "Release overflow";
        force_ovf <= '0';
        wait for 10 ms;
        command <= Mask_IDLE;
        report "End of simulation";
        finish;
    end process;

    signals_update : process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= idle;

        elsif rising_edge(clk) then
            current_state <= next_state;

            if req_n = '1' and ack_n = '0' then
                aer_data_r <= aer_data_r + 1;
            end if;
        end if;
    end process;

    FSM_transition : process(current_state, aer_data_r, ack_n, force_ovf)
    begin
        next_state <= current_state;
        req_n      <= '1';
        aer_data   <= (others => '0');

        case current_state is
            when idle =>
                if ack_n = '1' and force_ovf = '0' then
                    next_state <= req_fall;
                end if;

            when req_fall =>
                req_n    <= '0';
                aer_data <= aer_data_r;
                if ack_n = '0' then
                    next_state <= req_rise;
                end if;

            when req_rise =>
                req_n      <= '1';
                next_state <= idle;

        end case;
    end process;

    read_process : process(out_ready)
    begin
        if (out_ready = '1') then
            out_rd <= '1';
        else
            out_rd <= '0';
        end if;
    end process;

END;
