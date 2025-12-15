
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.math_real.all;

package okt_global_pkg is
    constant BUFFER_BITS_WIDTH         		: integer := 32;
    constant OK_UH_WIDTH_BUS           		: integer := 5;
    constant OK_HU_WIDTH_BUS           		: integer := 3;
    constant OK_UHU_WIDTH_BUS          		: integer := 32;
    constant OK_EH_WIDTH_BUS           		: integer := 65;
    constant OK_HE_WIDTH_BUS           		: integer := 113;
    constant OK_NUM_okEHx_END_POINTS   		: integer := 2;
    constant LEDS_BITS_WIDTH           		: integer := 8;
	constant TIMESTAMP_BITS_WIDTH 			: integer := 32;
end okt_global_pkg;

package body okt_global_pkg is
end okt_global_pkg;
