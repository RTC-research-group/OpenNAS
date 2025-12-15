library ieee;
use ieee.std_logic_1164.all;
use work.okt_top_pkg.all;


package okt_cu_pkg is
	constant Mask_IDLE   : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := (others => '0');
    constant Mask_MON    : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := "000001";
	constant Mask_PASS   : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := "000010";
	constant Mask_SEQ    : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := "000100";
	constant Mask_CONF_1 : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := "001000";
	constant Mask_CONF_2 : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := "010000";
	constant Mask_CONF_3 : std_logic_vector(COMMAND_BIT_WIDTH - 1 downto 0) := "100000";
    --constant COMMAND_BIT_WIDTH : integer := 3; -- ECU, PASSTROUGH
    --	constant MODE_BUS_WIDTH		: integer := 4;
end okt_cu_pkg;

package body okt_cu_pkg is

end okt_cu_pkg;
