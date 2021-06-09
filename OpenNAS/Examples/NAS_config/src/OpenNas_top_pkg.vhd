library ieee;
use ieee.std_logic_1164.all;
package OpenNas_top_pkg is
	-- Top parameters
	constant CONFIG_BUS_BIT_WIDTH           : integer := 16;
	constant AER_DATA_BUS_BIT_WIDTH         : integer := 16;
	constant SPIKE_BUS_BIT_WIDTH            : integer := 2;
	constant SPIKE_OUT_FILTER_BUS_BIT_WIDTH : integer := 128;
	
	-- PDM2Spikes parameters
	type pdm2spikes_parameter_array is array (0 to 3) of integer range 0 to 65535;
	constant PDM2Spikes_DEFAULT_parameter : pdm2spikes_parameter_array := (16#0005#, 16#0006#, 16#734B#, 16#39C8#);

	-- I2S2Spikes parameters
	constant I2S2Spikes_DEFAULT_parameter : integer := 16#000F#;
	
	-- Filter parameters
	constant NUM_CHANNELS : integer := 64;
	type lpf_bus is array (0 to NUM_CHANNELS) of std_logic_vector(1 downto 0);
	type filter_generic_array is array (0 to NUM_CHANNELS) of integer range 0 to 131072;
	constant GL_parameter : filter_generic_array := (7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11,
		11, 11, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16,
		16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18);
	constant SAT_parameter : filter_generic_array := (63, 63, 127, 127, 127, 127, 127, 127, 255, 255, 255, 255, 255, 255, 511, 511, 511,
		511, 511, 511, 1023, 1023, 1023, 1023, 1023, 1023, 2047, 2047, 2047, 2047, 2047, 2047, 2047, 4095, 4095, 4095, 4095, 4095,
		4095, 8191, 8191, 8191, 8191, 8191, 8191, 16383, 16383, 16383, 16383, 16383, 16383, 32767, 32767, 32767, 32767, 32767, 32767,
		32767, 65535, 65535, 65535, 65535, 65535, 65535, 131071);
		
	type filter_default_parameter_array is array (0 to ((NUM_CHANNELS+1)*4)-1) of integer range 0 to 65535;
	constant FILTER_DEFAULT_parameter : filter_default_parameter_array := (16#04#, 16#77B4#, 16#77B4#, 16#2025#, 16#04#, 16#6B1C#, 16#6B1C#, 16#2025#,
		16#02#, 16#7303#, 16#7303#, 16#2025#, 16#02#, 16#66E9#, 16#66E9#, 16#2025#, 16#03#, 16#7AC8#, 16#7AC8#, 16#2025#, 16#03#, 16#6DDD#, 16#6DDD#, 16#2025#, 
		16#04#, 16#7AE1#, 16#7AE1#, 16#2025#, 16#04#, 16#6DF4#, 16#6DF4#, 16#2025#, 16#02#, 16#7610#, 16#7610#, 16#2025#, 16#02#, 16#69A4#, 16#69A4#, 16#2025#, 
		16#03#, 16#7E0A#, 16#7E0A#, 16#2025#, 16#03#, 16#70C7#, 16#70C7#, 16#2025#, 16#04#, 16#7E24#, 16#7E24#, 16#2025#, 16#04#, 16#70DF#, 16#70DF#, 16#2025#, 
		16#02#, 16#7932#, 16#7932#, 16#2025#, 16#02#, 16#6C72#, 16#6C72#, 16#2025#, 16#02#, 16#6109#, 16#6109#, 16#2025#, 16#03#, 16#73C5#, 16#73C5#, 16#2025#, 
		16#03#, 16#6797#, 16#6797#, 16#2025#, 16#04#, 16#73DD#, 16#73DD#, 16#2025#, 16#02#, 16#7C69#, 16#7C69#,	16#2025#, 16#02#, 16#6F52#, 16#6F52#, 16#2025#, 
		16#02#, 16#639C#, 16#639C#, 16#2025#, 16#03#, 16#76D8#, 16#76D8#, 16#2025#, 16#03#, 16#6A57#, 16#6A57#, 16#2025#, 16#04#, 16#76F1#, 16#76F1#, 16#2025#, 
		16#02#, 16#7FB6#, 16#7FB6#, 16#2025#, 16#02#, 16#7247#, 16#7247#, 16#2025#, 16#02#, 16#6641#, 16#6641#, 16#2025#, 16#03#, 16#79FF#, 16#79FF#, 16#2025#, 
		16#03#, 16#6D29#, 16#6D29#, 16#2025#, 16#04#, 16#7A19#, 16#7A19#, 16#2025#, 16#04#, 16#6D40#, 16#6D40#, 16#2025#, 16#02#, 16#754F#, 16#754F#, 16#2025#, 
		16#02#, 16#68F7#, 16#68F7#, 16#2025#, 16#03#, 16#7D3C#, 16#7D3C#, 16#2025#, 16#03#, 16#700F#, 16#700F#, 16#2025#, 16#04#, 16#7D56#, 16#7D56#, 16#2025#, 
		16#04#, 16#7026#, 16#7026#, 16#2025#, 16#02#, 16#786C#,	16#786C#, 16#2025#, 16#02#, 16#6BC1#, 16#6BC1#, 16#2025#, 16#02#, 16#606A#, 16#606A#, 16#2025#, 
		16#03#, 16#7308#, 16#7308#, 16#2025#, 16#03#, 16#66EE#, 16#66EE#, 16#2025#, 16#04#, 16#7320#, 16#7320#, 16#2025#, 16#02#, 16#7B9E#, 16#7B9E#, 16#2025#, 
		16#02#, 16#6E9C#, 16#6E9C#, 16#2025#, 16#02#, 16#62F9#, 16#62F9#, 16#2025#, 16#03#, 16#7615#, 16#7615#, 16#2025#, 16#03#, 16#69A9#, 16#69A9#, 16#2025#, 
		16#04#, 16#762E#, 16#762E#, 16#2025#, 16#02#, 16#7EE6#, 16#7EE6#, 16#2025#, 16#02#, 16#718C#, 16#718C#, 16#2025#, 16#02#, 16#659A#, 16#659A#, 16#2025#, 
		16#03#, 16#7937#, 16#7937#, 16#2025#, 16#03#, 16#6C77#, 16#6C77#, 16#2025#, 16#04#, 16#7951#, 16#7951#, 16#2025#, 16#04#, 16#6C8E#, 16#6C8E#, 16#2025#, 
		16#02#,	16#748F#, 16#748F#, 16#2025#, 16#02#, 16#684C#, 16#684C#, 16#2025#, 16#03#, 16#7C6F#, 16#7C6F#, 16#2025#, 16#03#, 16#6F57#, 16#6F57#, 16#2025#,
		16#04#, 16#7C89#, 16#7C89#, 16#2025#, 16#04#, 16#6F6F#, 16#6F6F#, 16#2025#, 16#02#, 16#77A7#, 16#77A7#, 16#2025#);
end package OpenNas_top_pkg;

package body OpenNas_top_pkg is
end package body OpenNas_top_pkg;
