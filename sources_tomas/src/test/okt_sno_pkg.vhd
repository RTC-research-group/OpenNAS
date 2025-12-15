library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.math_real.all;

package okt_sno_pkg is
    constant NAS_NUM_CHANNELS       : integer := 64;
    constant NAS_MONO_STEREO        : integer := 2; -- 1: mono, 2: stereo
    constant NAS_ADDRESS_COUNT      : integer := NAS_NUM_CHANNELS * 2 * NAS_MONO_STEREO; -- NAS_NUM_CHANNELS * 2 since positive and negative spikes are per channel
    constant NAS_AER_ADDRESS_BITS   : integer := 8; --integer(ceil(log2(real(NAS_ADDRESS_COUNT)))); 
end okt_sno_pkg;

package body okt_sno_pkg is
end okt_sno_pkg;