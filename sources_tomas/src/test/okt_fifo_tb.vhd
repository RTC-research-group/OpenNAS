
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.okt_global_pkg.all;
use std.textio.all;                     -- Imports the standard textio package.

--  A testbench has no ports.
entity Fifo_tb is
end Fifo_tb;

architecture behavior of Fifo_tb is
    signal rst_n, w_en, r_en, empty, full : std_logic;
    signal w_data, r_data                 : std_logic_vector(31 downto 0);
    constant clk_period                   : time      := 10 ns;
    signal clk                            : std_logic := '1';
    signal runTest                        : std_logic := '1';

    -- This function encapsulates the assertion checking code for standard logic vectors
    function slvAssert(expected : std_logic_vector; actual : std_logic_vector; testName : String) return BOOLEAN is
        variable myLine       : line;
        -- We have to choose an arbitariliy high value for the size of the String (really annoying)
        variable errorMessage : String(1 to 4096);
    begin
        write(myLine, String'("Expecting: "));
        write(myLine, to_bitvector(expected));
        write(myLine, String'(", Got: "));
        write(myLine, to_bitvector(actual));
        write(myLine, testName);
        assert myLine'length < errorMessage'length; -- make sure S is big enough
        if myLine'length > 0 then
            read(myLine, errorMessage(1 to myLine'length));
        end if;
        assert actual = expected report errorMessage severity error;

        return (actual = expected);
    end slvAssert;

begin
    -- Instatiate the FIFO with a depth of 4
    FifoInst : entity work.okt_fifo
        generic map(
            DEPTH => 4
        )
        port map(
            clk    => clk,
            rst_n  => rst_n,
            w_data => w_data,
            w_en   => w_en,
            r_data => r_data,
            r_en   => r_en,
            empty  => empty,
            full   => full
        );

    -- Create the clock
    clockProc : process
    begin
        if runTest = '1' then
            wait for clk_period / 2;
            clk <= not clk;
        else
            wait;
        end if;
    end process;

    -- Provide Stimulus and assertions
    testProc : process
        variable expectedValue : std_logic_vector(r_data'range) := x"00000000";
        -- We have to create an arbitraily large number for a string (super annoying)
        variable result        : Boolean;  -- @suppress "Variable result is never read"
    begin
        -- Initialize important signals
        rst_n <= '1';
        w_en  <= '0';
        r_en  <= '0';
        wait until rising_edge(clk);

        -- Reset the FIFO
        rst_n <= '0';
        wait until rising_edge(clk);

        rst_n <= '1';
        wait until rising_edge(clk);

        -- Test out a basic use case, fill up the FIFO then read all the 
        -- Values out, we expect to write only 4 values in and read those 
        -- same values out
        assert empty = '1' report "Empty Check 1 failed" severity error;
        assert full = '0' report "Full Check 1 failed" severity error;

        w_data <= x"00000001";
        w_en   <= '1';
        wait until rising_edge(clk);

        w_en <= '0';

        wait until rising_edge(clk);

        assert empty = '0' report "Empty Check 2 failed" severity error;
        assert full = '0' report "Full Check 2 failed" severity error;
        expectedValue := x"00000000";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 1 failed"));

        r_en <= '1';

        wait until rising_edge(clk);

        r_en <= '0';

        wait until rising_edge(clk);

        assert empty = '1' report "Empty Check 3 failed" severity error;
        assert full = '0' report "Full Check 3 failed" severity error;
        expectedValue := x"00000001";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 2 failed"));

        wait until rising_edge(clk);

        w_data <= x"00000002";
        w_en   <= '1';

        wait until rising_edge(clk);

        w_data <= x"00000003";
        w_en   <= '1';

        wait until rising_edge(clk);

        w_data <= x"00000004";
        w_en   <= '1';

        wait until rising_edge(clk);

        w_data <= x"00000005";
        w_en   <= '1';

        wait until rising_edge(clk);

        w_en <= '0';

        wait until rising_edge(clk);

        assert empty = '0' report "Empty Check 4 failed" severity error;
        assert full = '1' report "Full Check 4 failed" severity error;

        w_data <= x"00000006";
        w_en   <= '1';

        wait until rising_edge(clk);

        w_en <= '0';

        wait until rising_edge(clk);

        assert empty = '0' report "Empty Check 5 failed" severity error;
        assert full = '1' report "Full Check 5 failed" severity error;

        wait until rising_edge(clk);

        r_en <= '1';

        wait until rising_edge(clk);

        wait until falling_edge(clk);
        assert empty = '0' report "Empty Check 6 failed" severity error;
        assert full = '0' report "Full Check 6 failed" severity error;
        expectedValue := x"00000002";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 3 failed"));

        wait until falling_edge(clk);

        assert empty = '0' report "Empty Check 7 failed" severity error;
        assert full = '0' report "Full Check 7 failed" severity error;
        expectedValue := x"00000003";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 4 failed"));

        wait until falling_edge(clk);

        assert empty = '0' report "Empty Check 8 failed" severity error;
        assert full = '0' report "Full Check 8 failed" severity error;
        expectedValue := x"00000004";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 5 failed"));

        wait until rising_edge(clk);
        assert empty = '0' report "Empty Check 9 failed" severity error;

        wait until falling_edge(clk);

        assert full = '0' report "Full Check 9 failed" severity error;
        expectedValue := x"00000005";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 6 failed"));

        wait until rising_edge(clk);

        r_en <= '0';

        wait until rising_edge(clk);

        assert empty = '1' report "Empty Check 10 failed" severity error;
        assert full = '0' report "Full Check 10 failed" severity error;

        -- A really wild edge case will be tested below
        -- The FIFO will be completly filled up and written to when it is 
        -- also read from. We expect the FIFO will store a value and write out
        -- a value when it is also full
        wait until rising_edge(clk);

        w_data <= x"00000007";
        w_en   <= '1';
        wait until rising_edge(clk);

        w_data <= x"00000008";
        w_en   <= '1';
        wait until rising_edge(clk);

        assert empty = '0' report "Empty Check 11 failed" severity error;
        assert full = '0' report "Full Check 11 failed" severity error;

        w_data <= x"00000009";
        w_en   <= '1';
        wait until rising_edge(clk);

        w_data <= x"0000000A";
        w_en   <= '1';
        wait until rising_edge(clk);

        -- Now that the FIFO Full we stop writing values in 
        w_data <= x"00000000";
        w_en   <= '0';
        wait until rising_edge(clk);

        assert empty = '0' report "Empty Check 12 failed" severity error;
        assert full = '1' report "Full Check 12 failed" severity error;

        -- Now put in a value and expect to read out a 
        w_en   <= '1';
        r_en   <= '1';
        w_data <= x"0000000B";
        wait until rising_edge(clk);

        w_en   <= '0';
        r_en   <= '0';
        w_data <= x"00000000";
        wait until rising_edge(clk);

        -- Now that we have read one value off we expect to read 4 more off
        assert empty = '0' report "Empty Check 13 failed" severity error;
        assert full = '1' report "Full Check 13 failed" severity error;
        expectedValue := x"00000007";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 7 failed"));
        wait until rising_edge(clk);
        
        r_en <= '1';
        wait until rising_edge(clk);
        r_en <= '0';
        wait until rising_edge(clk);
        
        w_data <= x"00000001";
        w_en   <= '1';
        r_en   <= '1';
        wait until rising_edge(clk);
        
        w_data <= x"00000001";
        w_en   <= '1';
        r_en   <= '1';
        wait until rising_edge(clk);
        
        w_data <= x"00000001";
        w_en   <= '1';
        r_en   <= '1';
        wait until rising_edge(clk);
        
        w_data <= x"00000001";
        w_en   <= '1';
        r_en   <= '1';
        wait until rising_edge(clk);
        
        w_data <= x"00000000";
        w_en   <= '0';
        r_en   <= '0';
        
        wait until rising_edge(clk);
        r_en <= '1';

        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert empty = '0' report "Empty Check 14 failed" severity error;
        assert full = '0' report "Full Check 14 failed" severity error;
        expectedValue := x"00000001";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 8 failed"));

        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert empty = '0' report "Empty Check 15 failed" severity error;
        assert full = '0' report "Full Check 15 failed" severity error;
        expectedValue := x"00000001";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 9 failed"));

        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert empty = '0' report "Empty Check 16 failed" severity error;
        assert full = '0' report "Full Check 16 failed" severity error;
        expectedValue := x"00000001";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 10 failed"));

        wait until rising_edge(clk);
        r_en          <= '0';
        wait until falling_edge(clk);
        assert empty = '1' report "Empty Check 14 failed" severity error;
        assert full = '0' report "Full Check 14 failed" severity error;
        expectedValue := x"00000000";
        result        := slvAssert(expectedValue, r_data, String'(" r_data check 11 failed"));

        -- End the test
        assert false report "end of test" severity note;
        runTest <= '0';
        -- Wait forever, this will finish the simulation
        wait;
    end process;
end behavior;
