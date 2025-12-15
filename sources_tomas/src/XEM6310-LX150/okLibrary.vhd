------------------------------------------------------------------------
--okLibrary.vhd 
--
--FrontPanel Library Module Declarations (VHDL)
-- XEM6310
--
-- Copyright (c) 2004-2011 Opal Kelly Incorporated
-- $Rev$ $Date$
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.vcomponents.all;
entity okHost is
	port (
		okUH   : in    std_logic_vector(4 downto 0);
		okHU   : out   std_logic_vector(2 downto 0);
		okUHU  : inout std_logic_vector(31 downto 0);
		okAA   : inout std_logic;
		okClk  : out   std_logic;
		okHE   : out   std_logic_vector(112 downto 0);
		okEH   : in    std_logic_vector(64 downto 0)
	);
end okHost;

architecture archHost of okHost is
	attribute box_type: string;
	attribute iob: string;
	
	component okCoreHarness port (
		okHC   : in    std_logic_vector(38 downto 0);
		okCH   : out   std_logic_vector(37 downto 0);
		okHE   : out   std_logic_vector(112 downto 0);
		okEH   : in    std_logic_vector(64 downto 0));
	end component;
	attribute box_type of okCoreHarness : component is "black_box";
	
	component FDRE port (
		D  : in    std_logic;
		C  : in    std_logic;
		CE : in    std_logic;
		R  : in    std_logic;
		Q  : out   std_logic);
	end component;
	attribute iob of FDRE  : component is "TRUE";
	
	signal okHC            : std_logic_vector(38 downto 0);
	signal okCH            : std_logic_vector(37 downto 0);
	
	signal okUH0_ibufg     : std_logic;
	signal dcm0_clk0       : std_logic;
	signal dcm0_locked     : std_logic;
	
	signal iobf0_o         : std_logic_vector(31 downto 0);
	signal regout0_q       : std_logic_vector(31 downto 0);
	signal regvalid_q      : std_logic_vector(31 downto 0);

	signal okUHx           : std_logic_vector(3 downto 0);
	signal notHC0          : std_logic;
	signal notCH36         : std_logic;
	
	
begin
	okClk            <= okHC(0);
	okHC(38)         <= not(dcm0_locked);
	notHC0           <= not(okHC(0));
	notCH36          <= not(okCH(36));
	
	hi_clk_bufg : IBUFG port map (I=>okUH(0), O=>okUH0_ibufg);
	
	dcm0: DCM_SP  generic map (
		CLKIN_PERIOD       => 9.92,                 -- Input clock period specified in nS
		CLKOUT_PHASE_SHIFT => "FIXED",              -- Output phase shift (NONE, FIXED, VARIABLE)
		PHASE_SHIFT        => -32,                  -- Fixed negative phase shift centers clock in "ctrl_in" data valid window.~1ns (-255 to 255)
		CLK_FEEDBACK       => "1X",                 -- Feedback source (NONE, 1X, 2X)
		DESKEW_ADJUST      => "SOURCE_SYNCHRONOUS", -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
		STARTUP_WAIT       => FALSE                 -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
	) port map (
		CLK0               => dcm0_clk0,            -- Negative phase shifted to clock in CTRL
		LOCKED             => dcm0_locked,          -- 1-bit output: DCM_SP Lock Output
		CLKFB              => okHC(0),              -- 1-bit input: Clock feedback input
		CLKIN              => okUH0_ibufg,          -- 1-bit input: Clock input
		RST                => '0',                  -- 1-bit input: Active high reset input
		PSEN               => '0'
	);
	
	dcm0_bufg : BUFG port map (I=>dcm0_clk0, O=>okHC(0));

	------------------------------------------------------------------------
	-- Bidirectional IOB registers
	------------------------------------------------------------------------
	
	iob_regs : for i in 0 to 31 generate
		
		iobf0: IOBUF port map(IO=>okUHU(i), I=>regout0_q(i), O=>iobf0_o(i), T=>regvalid_q(i));
			
		-- Input Registering
		regin0: FDRE port map(D=>iobf0_o(i), Q=>okHC(i+5), C=>okHC(0), CE=>'1', R=>'0');
		
		-- Output Registering
		regout0: FDRE port map(D=>okCH(i+3), Q=>regout0_q(i), C=>okHC(0), CE=>'1', R=>'0');
			
		-- Tristate Drive
		regvalid: FDRE port map(D=>notCH36, Q=>regvalid_q(i), C=>okHC(0), CE=>'1', R=>'0');
			
	end generate iob_regs;
	
	tbuf  : IOBUF port map (I=>okCH(35), O=>okHC(37), T=>okCH(37), IO=>okAA);

	------------------------------------------------------------------------
	-- Output IOB registers
	------------------------------------------------------------------------
	regctrlout0: FDRE port map(D=>okCH(2), Q=>okHU(2), C=>okHC(0), CE=>'1', R=>'0');
	regctrlout1: FDRE port map(D=>okCH(0), Q=>okHU(0), C=>okHC(0), CE=>'1', R=>'0');
	regctrlout2: FDRE port map(D=>okCH(1), Q=>okHU(1), C=>okHC(0), CE=>'1', R=>'0');

	--------------------------------------------------------------------------
	-- Input IOB registers
	--  - First registered on DCM0 (positive edge)
	--  - Then registered on DCM0 (negative edge)
	--------------------------------------------------------------------------
	regctrlin0a: FDRE port map(D=>okUH(1), Q=>okHC(1), C=>okHC(0), CE=>'1', R=>'0');
	regctrlin1a: FDRE port map(D=>okUH(2), Q=>okHC(2), C=>okHC(0), CE=>'1', R=>'0');
	regctrlin2a: FDRE port map(D=>okUH(3), Q=>okHC(3), C=>okHC(0), CE=>'1', R=>'0');
	regctrlin3a: FDRE port map(D=>okUH(4), Q=>okHC(4), C=>okHC(0), CE=>'1', R=>'0');

	core0 : okCoreHarness port map(okHC=>okHC, okCH=>okCH, okHE=>okHE, okEH=>okEH);
end archHost;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okWireOR is
	generic (
		N     : integer := 2
	);
	port (
		okEH   : out std_logic_vector(64 downto 0);
		okEHx  : in  std_logic_vector(N*65-1 downto 0)
	);
end okWireOR;
architecture archWireOR of okWireOR is
begin
	process (okEHx)
		variable okEH_int : STD_LOGIC_VECTOR(64 downto 0);
	begin
		okEH_int:= '0' & x"0000_0000_0000_0000";
		for i in N-1 downto 0 loop
			okEH_int := okEH_int or okEHx( (i*65+64) downto (i*65) );
		end loop;
		okEH <= okEH_int;
	end process;
end archWireOR;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package FRONTPANEL is

	attribute box_type: string;
	
	component okHost port (
		okUH   : in    std_logic_vector(4 downto 0);
		okHU   : out   std_logic_vector(2 downto 0);
		okUHU  : inout std_logic_vector(31 downto 0);
		okAA   : inout std_logic;
		okClk  : out   std_logic;
		okHE   : out   std_logic_vector(112 downto 0);
		okEH   : in    std_logic_vector(64 downto 0));
	end component;

	component okCoreHarness port (
		okHC   : in    std_logic_vector(38 downto 0);
		okCH   : out   std_logic_vector(37 downto 0);
		okHE   : out   std_logic_vector(112 downto 0);
		okEH   : in    std_logic_vector(64 downto 0));
	end component;
	attribute box_type of okCoreHarness : component is "black_box";

	component okWireIn port (
		okHE       : in  std_logic_vector(112 downto 0);
		ep_addr    : in  std_logic_vector(7 downto 0);
		ep_dataout : out std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okWireIn : component is "black_box";

	component okWireOut port (
		okHE       : in  std_logic_vector(112 downto 0);
		okEH       : out std_logic_vector(64 downto 0);
		ep_addr    : in  std_logic_vector(7 downto 0);
		ep_datain  : in  std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okWireOut : component is "black_box";

	component okTriggerIn port (
		okHE       : in  std_logic_vector(112 downto 0);
		ep_addr    : in  std_logic_vector(7 downto 0);
		ep_clk     : in  std_logic;
		ep_trigger : out std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okTriggerIn : component is "black_box";

	component okTriggerOut port (
		okHE       : in  std_logic_vector(112 downto 0);
		okEH       : out std_logic_vector(64 downto 0);
		ep_addr    : in  std_logic_vector(7 downto 0);
		ep_clk     : in  std_logic;
		ep_trigger : in  std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okTriggerOut : component is "black_box";

	component okPipeIn port (
		okHE       : in  std_logic_vector(112 downto 0);
		okEH       : out std_logic_vector(64 downto 0);
		ep_addr    : in  std_logic_vector(7 downto 0);
		ep_write   : out std_logic;
		ep_dataout : out std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okPipeIn : component is "black_box";

	component okPipeOut port (
		okHE       : in  std_logic_vector(112 downto 0);
		okEH       : out std_logic_vector(64 downto 0);
		ep_addr    : in  std_logic_vector(7 downto 0);
		ep_read    : out std_logic;
		ep_datain  : in  std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okPipeOut : component is "black_box";

	component okBTPipeIn port (
		okHE           : in  std_logic_vector(112 downto 0);
		okEH           : out  std_logic_vector(64 downto 0);
		ep_addr        : in  std_logic_vector(7 downto 0);
		ep_write       : out std_logic;
		ep_blockstrobe : out std_logic;
		ep_dataout     : out std_logic_vector(31 downto 0);
		ep_ready       : in  std_logic);
	end component;
	attribute box_type of okBTPipeIn : component is "black_box";

	component okBTPipeOut port (
		okHE           : in  std_logic_vector(112 downto 0);
		okEH           : out std_logic_vector(64 downto 0);
		ep_addr        : in  std_logic_vector(7 downto 0);
		ep_read        : out std_logic;
		ep_blockstrobe : out std_logic;
		ep_datain      : in  std_logic_vector(31 downto 0);
		ep_ready       : in  std_logic);
	end component;
	attribute box_type of okBTPipeOut : component is "black_box";
	
	component okRegisterBridge port (
		okHE           : in  std_logic_vector(112 downto 0);
		okEH           : out std_logic_vector(64 downto 0);
		ep_address     : out std_logic_vector(31 downto 0);
		ep_write       : out std_logic;
		ep_dataout     : out std_logic_vector(31 downto 0);
		ep_read        : out std_logic;
		ep_datain      : in  std_logic_vector(31 downto 0));
	end component;
	attribute box_type of okRegisterBridge : component is "black_box";

	component okWireOR
	generic (N : integer := 2);
	port (
		okEH   : out std_logic_vector(64 downto 0);
		okEHx  : in  std_logic_vector(N*65-1 downto 0));
	end component;

end FRONTPANEL;