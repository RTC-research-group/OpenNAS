----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:12:35 05/14/2024 
-- Design Name: 
-- Module Name:    ring_buffer - Behavioral 
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
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.okt_fifo_pkg.all;
 
entity ring_buffer is
  generic (
    RAM_WIDTH : natural;
    RAM_DEPTH : natural
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
 
    -- Write port
    wr_en : in std_logic;
    wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);
 
    -- Read port
    rd_en : in std_logic;
    rd_valid : out std_logic;
    rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);
 
    -- Flags
    empty : out std_logic;
    empty_next : out std_logic;
    full : out std_logic;
    full_next : out std_logic;
 
    -- The number of elements in the FIFO
    fill_count : out integer range RAM_DEPTH - 1 downto 0
  );
end ring_buffer;
 
architecture rtl of ring_buffer is
 
  type ram_type is array (0 to RAM_DEPTH - 1) of
    std_logic_vector(wr_data'range);
  signal ram : ram_type;
 
  subtype index_type is integer range ram_type'range;
  signal head : index_type;
  signal tail : index_type;
 
  signal empty_i, empty_i_next : std_logic;
  signal full_i, full_i_next : std_logic;
  signal empty_next_i, empty_next_i_next : std_logic;
  signal full_next_i, full_next_i_next : std_logic;
  signal fill_count_i, fill_count_next : integer range RAM_DEPTH - 1 downto 0;
 
  -- Increment and wrap
  procedure incr(signal index : inout index_type) is
  begin
    if index = index_type'high then
      index <= index_type'low;
    else
      index <= index + 1;
    end if;
  end procedure;
 
begin
 
  -- Copy internal signals to output (registered)
  empty <= empty_i;
  full <= full_i;
  fill_count <= fill_count_i;
  empty_next <= empty_next_i;
  full_next <= full_next_i;

  -- Combinational next-state logic for fill_count and flags
  fill_count_next <= head - tail + RAM_DEPTH when head < tail else head - tail;
  empty_i_next    <= '1' when fill_count_next = 0 else '0';
  empty_next_i_next <= '1' when fill_count_next <= FIFO_ALM_EMPTY_OFFSET else '0';
  full_i_next     <= '1' when fill_count_next >= RAM_DEPTH - 1 else '0';
  full_next_i_next <= '1' when fill_count_next >= RAM_DEPTH - FIFO_ALM_FULL_OFFSET else '0';

  -- Register fill_count and flags to break critical path
  PROC_FLAGS: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '0' then
        fill_count_i   <= 0;
        empty_i        <= '1';
        empty_next_i   <= '1';
        full_i         <= '0';
        full_next_i    <= '0';
      else
        fill_count_i   <= fill_count_next;
        empty_i        <= empty_i_next;
        empty_next_i   <= empty_next_i_next;
        full_i         <= full_i_next;
        full_next_i    <= full_next_i_next;
      end if;
    end if;
  end process;
 
  -- Update the head pointer in write
  PROC_HEAD : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '0' then
        head <= 0;
      else
 
        if wr_en = '1' and full_i = '0' then
          incr(head);
        end if;
 
      end if;
    end if;
  end process;
 
  -- Update the tail pointer on read and pulse valid
  PROC_TAIL : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '0' then
        tail <= 0;
        rd_valid <= '0';
      else
        rd_valid <= '0';
 
        if rd_en = '1' and empty_i = '0' then
          incr(tail);
          rd_valid <= '1';
        end if;
 
      end if;
    end if;
  end process;
 
  -- Write to and read from the RAM
  PROC_RAM : process(clk)
  begin
    if rising_edge(clk) then
      ram(head) <= wr_data;
      rd_data <= ram(tail);
    end if;
  end process;
 
  -- Update the fill count
  -- (Eliminado: ahora el cálculo y registro de fill_count está en PROC_FLAGS)
 
end architecture;

