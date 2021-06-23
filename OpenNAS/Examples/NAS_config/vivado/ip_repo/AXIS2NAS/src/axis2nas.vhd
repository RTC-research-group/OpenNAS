library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axis2nas_pkg.all;

entity axis2nas is
	port(
		--clk             : in  std_logic;
		--rst_n           : in  std_logic;
		-- AXI Stream interface
		s_axi_tready    : out std_logic;
		s_axi_tvalid    : in  std_logic;
		s_axi_tlast     : in  std_logic;
		s_axi_tdata     : in  std_logic_vector(AXI_BUS_BIT_WIDTH - 1 downto 0);
		-- NAS config interface
		nas_addr_config : out std_logic_vector(NAS_CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		nas_data_config : out std_logic_vector(NAS_CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		nas_wren_config : out std_logic
	);
end entity axis2nas;

architecture rtl of axis2nas is
	
--	signal nas_addr_config_n : std_logic_vector(NAS_CONFIG_BUS_BIT_WIDTH-1 downto 0);
--	signal nas_data_config_n : std_logic_vector(NAS_CONFIG_BUS_BIT_WIDTH-1 downto 0);
--	signal nas_wren_config_n : std_logic;
	
begin
	
	s_axi_tready <= '1'; -- This ready signal should come from the NAS
	nas_wren_config <= s_axi_tvalid;
	nas_addr_config <= s_axi_tdata(AXI_BUS_BIT_WIDTH-1 downto NAS_CONFIG_BUS_BIT_WIDTH);
	nas_data_config <= s_axi_tdata(NAS_CONFIG_BUS_BIT_WIDTH-1 downto 0);
	
--	nas_addr_config <= nas_addr_config_n;
--	nas_data_config <= nas_data_config_n;
--	nas_wren_config <= nas_wren_config_n;
--	
--	process(rst_n, clk)
--	begin
--		if(rst_n = '0') then
--			nas_addr_config_n <= (others=>'0');
--			nas_data_config_n <= (others=>'0');
--			nas_wren_config_n <= '0';
--		
--		elsif(rising_edge(clk)) then
--			
--		end if;
--	end process;
	

end architecture rtl;
