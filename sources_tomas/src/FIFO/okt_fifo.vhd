library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.okt_global_pkg.all;
use work.okt_fifo_pkg.all;

entity okt_fifo is -- Fifo
    generic(
        DEPTH : integer := 32
    );
    port(
	 --sys 
        clk    : in  std_logic;
        rst_n  : in  std_logic;
	 --in
        w_data : in  std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
        w_en   : in  std_logic;
	 --out
        r_data : out std_logic_vector(BUFFER_BITS_WIDTH - 1 downto 0);
        r_en   : in  std_logic;
	 --state
        empty  : out std_logic;
        full   : out std_logic;
        almost_full : out std_logic;
		  almost_empty : out std_logic
    );
end okt_fifo;

architecture Behavioral of okt_fifo is
    constant ADDR_SIZE : positive         := positive(ceil(log2(real(DEPTH))));
	 type registerFileType is array (0 to DEPTH - 1) of std_logic_vector(r_data'range);
    signal registers   : registerFileType := (others => (others => '0'));
    signal read_addr   : unsigned(ADDR_SIZE downto 0);
    signal write_addr  : unsigned(ADDR_SIZE downto 0);
    signal output      : std_logic_vector(r_data'range);
    signal r_full      : std_logic;
    signal r_almost_full : std_logic;
	 signal r_almost_empty : std_logic;
    
begin
    regFile : process(clk) is
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                --                for I in 0 to DEPTH - 1 loop
                --                    registers(I) <= std_logic_vector(to_unsigned(0, r_data'length));
                --                end loop;
                read_addr  <= to_unsigned(0, read_addr'length);
                write_addr <= to_unsigned(0, write_addr'length);
                output     <= (others => '0');
                r_full     <= '0';
                r_almost_full <= '0';
					 r_almost_empty <= '0';
                
            else
                -- This accounts for the case that the FIFO is full, that is 
                -- that the write address is one less than the read address
                if w_en = '1' and r_en = '0' and ((write_addr = (read_addr - to_unsigned(1, read_addr'length))) or (read_addr = to_unsigned(0, read_addr'length) and write_addr = to_unsigned(DEPTH - 1, write_addr'length))) then
                    r_full <= '1';
                elsif w_en = '0' and r_en = '1' then
                    r_full <= '0';
                else
                    r_full <= r_full;
                end if;
                
					 if write_addr > read_addr then
						 if (write_addr - read_addr) >= to_unsigned(DEPTH - FIFO_ALM_FULL_OFFSET, write_addr'length) then
							  r_almost_full <= '1';
						 elsif (write_addr - read_addr) <= to_unsigned(FIFO_ALM_EMPTY_OFFSET, write_addr'length) then
							  r_almost_empty <= '1';
						 else
							  r_almost_full <= '0';
							  r_almost_empty <= '0';
						 end if;
					 elsif write_addr < read_addr then
						 if (DEPTH - read_addr + write_addr) >= to_unsigned(DEPTH - FIFO_ALM_FULL_OFFSET, write_addr'length) then
							  r_almost_full <= '1';
						 elsif (DEPTH - read_addr + write_addr) <= to_unsigned(FIFO_ALM_EMPTY_OFFSET, write_addr'length) then
							  r_almost_empty <= '1';
						 else
							  r_almost_full <= '0';
							  r_almost_empty <= '0';
						 end if;	
					 end if;
					 
                -- Handle the write enable line
                if w_en = '1' then
                    if (r_full = '0' or r_en = '1') and write_addr < to_unsigned(DEPTH, write_addr'length) then
                        registers(to_integer(write_addr)) <= w_data;
                    end if;

                    if r_full = '0' or r_en = '1' then
                        if write_addr >= to_unsigned(DEPTH - 1, write_addr'length) then
                            write_addr <= to_unsigned(0, write_addr'length);
                        else
                            write_addr <= write_addr + to_unsigned(1, write_addr'length);
                        end if;
                    else
                        write_addr <= write_addr;
                    end if;
                end if;

                -- Handle the read enable line
                output <= registers(to_integer(read_addr));
                if r_en = '1' then
                    if ((read_addr = write_addr) and (r_full = '0')) then
                        output <= std_logic_vector(to_unsigned(0, r_data'length));
                    elsif read_addr < to_unsigned(DEPTH, read_addr'length) then
                        output <= registers(to_integer(read_addr));
                    else
                        output <= output;
                    end if;

                    if (read_addr = write_addr) and (r_full = '0') then
                        read_addr <= read_addr;
                    elsif read_addr >= to_unsigned(DEPTH - 1, read_addr'length) then
                        read_addr <= to_unsigned(0, read_addr'length);
                    else
                        read_addr <= read_addr + to_unsigned(1, read_addr'length);
                    end if;
                end if;
            end if;
        end if;
    end process;

    empty <= '1' when (read_addr = write_addr) and (r_full = '0') else '0';
    full  <= r_full;
    almost_full <= r_almost_full;
	 almost_empty <= r_almost_empty;
    r_data <= output;
end Behavioral;
