--------------------------------------------------------------------------
-- okHost.vhd
--
--	Description:
--		This file is a simulation replacement for okCore for
--		FrontPanel. It receives data from okHostCalls.v which is 
--		then restructured and timed to communicate with the endpoint
--		simulation modules.
--------------------------------------------------------------------------
-- Copyright (c) 2005-2010 Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.frontpanel.all;
use work.parameters.all;
use work.mappings.all;

library STD;
use std.textio.all;

entity okHost is
	port (
		okUH   : in    std_logic_vector(4 downto 0);
		okHU   : out   std_logic_vector(2 downto 0) := "000";
		okUHU  : inout std_logic_vector(31 downto 0);
		okAA   : inout std_logic;
		okClk  : out   std_logic;
		okHE   : out   std_logic_vector(112 downto 0) := '0' & x"0000000000000000000000000000";
		okEH   : in    std_logic_vector(64 downto 0)
	);
end okHost;

architecture arch of okHost is

	constant DNOP                   : STD_LOGIC_VECTOR(2 downto 0) := "000";
	constant DReset                 : STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant Dwires                 : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant DUpdateWireIns         : STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant DUpdateWireOuts        : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant DTriggers              : STD_LOGIC_VECTOR(2 downto 0) := "011";
	constant DActivateTriggerIn     : STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant DUpdateTriggerOuts     : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant DPipes                 : STD_LOGIC_VECTOR(2 downto 0) := "100";
	constant DWriteToPipeIn         : STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant DReadFromPipeOut       : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant DWriteToBlockPipeIn    : STD_LOGIC_VECTOR(2 downto 0) := "011";
	constant DReadFromBlockPipeOut  : STD_LOGIC_VECTOR(2 downto 0) := "100";
	constant DRegisters             : STD_LOGIC_VECTOR(2 downto 0) := "101";
	constant DWriteRegister         : STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant DReadRegister          : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant DWriteRegisterSet      : STD_LOGIC_VECTOR(2 downto 0) := "011";
	constant DReadRegisterSet       : STD_LOGIC_VECTOR(2 downto 0) := "100";

	constant CReset              : STD_LOGIC_VECTOR(4 downto 0) := "00001";
	constant CSetWireIns         : STD_LOGIC_VECTOR(4 downto 0) := "00100";
	constant CUpdateWireIns      : STD_LOGIC_VECTOR(4 downto 0) := "01000";
	constant CGetWireOutValue    : STD_LOGIC_VECTOR(4 downto 0) := "00010";
	constant CUpdateWireOuts     : STD_LOGIC_VECTOR(4 downto 0) := "01000";
	constant CActivateTriggerIn  : STD_LOGIC_VECTOR(4 downto 0) := "00100";
	constant CUpdateTriggerOuts  : STD_LOGIC_VECTOR(4 downto 0) := "10000";
	constant CIsTriggered        : STD_LOGIC_VECTOR(4 downto 0) := "00010";
	constant CWriteToPipeIn      : STD_LOGIC_VECTOR(4 downto 0) := "00100";
	constant CReadFromPipeOut    : STD_LOGIC_VECTOR(4 downto 0) := "00010";
	constant CWriteToBTPipeIn    : STD_LOGIC_VECTOR(4 downto 0) := "00100";
	constant CReadFromBTPipeOut  : STD_LOGIC_VECTOR(4 downto 0) := "00010";
	
	-- Local okHost signals
	signal hi_clk          : STD_LOGIC;
	signal hi_drive        : STD_LOGIC;
	signal hi_datain       : STD_LOGIC_VECTOR(31 downto 0);
	signal hi_dataout      : STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
	signal hi_cmd          : STD_LOGIC_VECTOR(2 downto 0);
	signal hi_busy         : STD_LOGIC := '0';
	signal ep_command      : STD_LOGIC_VECTOR(4 downto 0);
	signal ep_blockstrobe  : STD_LOGIC;
	signal ep_addr         : STD_LOGIC_VECTOR(7 downto 0);
	signal ep_datain       : STD_LOGIC_VECTOR(31 downto 0);
	signal ep_dataout      : STD_LOGIC_VECTOR(31 downto 0);
	signal ep_ready        : STD_LOGIC;
	signal reg_addr        : STD_LOGIC_VECTOR(31 downto 0);
	signal reg_write       : STD_LOGIC;
	signal reg_write_data  : STD_LOGIC_VECTOR(31 downto 0);
	signal reg_read        : STD_LOGIC;
	signal reg_read_data   : STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
	
begin

-- Mapping of okHost interface to local okHostCall signals 
hi_clk    <= okUH(0);
hi_drive  <= okUH(1);
hi_cmd    <= okUH(4 downto 2);
hi_datain <= okUHU;
okHU(0)   <= hi_busy;
okUHU     <= hi_dataout when (hi_drive = '0') else (others => 'Z');
okClk     <= hi_clk;


-- Endpoint interface mapping
okHE(okHE_CLK)                                     <= hi_clk; 
okHE(okHE_RESET)                                   <= ep_command(0); 
okHE(okHE_READ)                                    <= ep_command(1); 
okHE(okHE_WRITE)                                   <= ep_command(2); 
okHE(okHE_WIREUPDATE)                              <= ep_command(3); 
okHE(okHE_TRIGUPDATE)                              <= ep_command(4); 
okHE(okHE_BLOCKSTROBE)                             <= ep_blockstrobe; 
okHE(okHE_ADDRH downto okHE_ADDRL)                 <= ep_addr; 
okHE(okHE_DATAH downto okHE_DATAL)                 <= ep_dataout;
okHE(okHE_REGADDRH downto okHE_REGADDRL)           <= reg_addr;
okHE(okHE_REGWRITE)                                <= reg_write; 
okHE(okHE_REGWRITEDATAH downto okHE_REGWRITEDATAL) <= reg_write_data;
okHE(okHE_REGREAD)                                 <= reg_read; 

ep_datain     <= okEH(okEH_DATAH downto okEH_DATAL);
ep_ready      <= okEH(okEH_READY);
reg_read_data <= okEH(okEH_REGREADDATAH downto okEH_REGREADDATAL);

process
	variable i                  : INTEGER := 0;
	variable j                  : INTEGER := 0;
	variable k                  : INTEGER := 0;
	variable ep                 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	variable tmp_slv8           : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	variable tmp_slv16          : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	variable tmp_slv32          : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	
	variable pipeLength         : INTEGER := 0;
	variable BlockDelayStates   : INTEGER := 0;
	variable blockSize          : INTEGER := 0;
	variable blockNum           : INTEGER := 0;
	variable registerNum        : INTEGER := 0;
	variable ReadyCheckDelay    : INTEGER := 0;
	variable PostReadyDelay     : INTEGER := 0;
	variable msg_line           : line;
begin
	wait until (hi_cmd'event);
	wait until (falling_edge(hi_clk));

		--------------------------------------------------------------------
		-- Reset
		--------------------------------------------------------------------
		if (hi_cmd = DReset) then
			hi_busy <= '1';
			wait until (falling_edge(hi_clk));
			ep_blockstrobe <= '0';
			ep_command <= CReset;
			ep_addr <= (others => '0');
			ep_dataout <= (others => '0');
			reg_addr <= (others => '0');
			reg_write  <= '0';
			reg_write_data <= (others => '0');
			reg_read  <= '0';
			wait until (falling_edge(hi_clk)); ep_command <= (others => '0');
			wait until (falling_edge(hi_clk)); hi_busy <= '0';

		--------------------------------------------------------------------
		-- Wires
		--------------------------------------------------------------------
		elsif (hi_cmd = DWires) then
			wait until (falling_edge(hi_clk)); 
			
			-- UpdateWireIns
			if (hi_cmd = DUpdateWireIns) then
				wait until (falling_edge(hi_clk)); hi_busy <= '1';
				for i in 0 to 31 loop
					ep := CONV_STD_LOGIC_VECTOR(i, 8);
					wait until (falling_edge(hi_clk));
					ep_command <= CSetWireIns;
					ep_addr <= ep;
					ep_dataout <= hi_datain;
				end loop;
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				ep_dataout <= (others => '0');
				ep_addr <= (others => '0');
				wait until (falling_edge(hi_clk));
				ep_command <= CUpdateWireIns;
				ep_addr <= (others => '0');
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
	
				wait until (falling_edge(hi_clk)); wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
			
			-- UpdateWireOuts
			elsif (hi_cmd = DUpdateWireOuts) then
				wait until (falling_edge(hi_clk)); hi_busy <= '1';
				wait until (falling_edge(hi_clk));
				ep_command <= CUpdateWireOuts;
				ep_addr <= (others => '0');
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				wait until (falling_edge(hi_clk));
				for i in 0 to 31 loop
					ep := CONV_STD_LOGIC_VECTOR(i+32, 8);
					ep_command <= CGetWireOutValue;
					ep_addr <= ep;
					wait until (falling_edge(hi_clk));
					hi_dataout <= ep_datain;
				end loop;
				ep_command <= (others => '0');
				ep_addr <= (others => '0');
				wait until (falling_edge(hi_clk));
				hi_dataout <= (others => '0');
	
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
				
			else
				report "Unsupported host sub-command sent";
			end if;

		--------------------------------------------------------------------
		-- Triggers
		--------------------------------------------------------------------
		elsif (hi_cmd = DTriggers) then
			wait until (falling_edge(hi_clk));
		
			-- ActivateTriggerIn
			if (hi_cmd = DActivateTriggerIn) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				ep := hi_datain(7 downto 0);
				wait until (falling_edge(hi_clk));
				ep_command <= CActivateTriggerIn;
				ep_addr <= ep;
				ep_dataout <= hi_datain;
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				ep_addr <= (others => '0');
				ep_dataout <= (others => '0');
	
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
	
			-- UpdateTriggerOuts
			elsif (hi_cmd = DUpdateTriggerOuts) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				ep_command <= CUpdateTriggerOuts;
				ep_addr <= (others => '0'); 
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				
				for i in 0 to (UPDATE_TO_READOUT_CLOCKS-1) loop
					wait until (falling_edge(hi_clk));
				end loop;
				
				for i in 0 to 31 loop
					ep := CONV_STD_LOGIC_VECTOR(i+96, 8);  -- 96 is 0x60
					ep_command <= CIsTriggered;
					ep_addr <= ep;
					wait until (falling_edge(hi_clk));
					hi_dataout <= ep_datain;
				end loop;
				ep_command <= (others => '0');
				ep_addr <= (others => '0');
	
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';

			else
				report "Unsupported host sub-command sent";
			end if;

		--------------------------------------------------------------------
		-- Pipes
		--------------------------------------------------------------------
		elsif (hi_cmd = DPipes) then
			wait until (falling_edge(hi_clk));
			
			-- WriteToPipeIn
			if (hi_cmd = DWriteToPipeIn) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				j := 0;
				ep := hi_datain(7 downto 0);
				tmp_slv8 := hi_datain(15 downto 8);
				BlockDelayStates := CONV_INTEGER(tmp_slv8);
				wait until (falling_edge(hi_clk));
				tmp_slv32 := hi_datain;
				pipeLength := CONV_INTEGER(tmp_slv32);
				for i in 1 to pipeLength loop
					wait until (falling_edge(hi_clk));
					ep_command <= CWriteToPipeIn;
					ep_addr <= ep;
					ep_dataout <= hi_datain;
					j:=j+4;
					if (j = 1024) then
						for k in 1 to BlockDelayStates loop
							wait until (falling_edge(hi_clk));
							ep_command <= (others => '0');
							ep_addr <= (others => '0');
							ep_dataout <= (others => '0');
						end loop;
						j:=0;
					end if;
				end loop;
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				ep_addr <= (others => '0');
				ep_dataout <= (others => '0');
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
	
			-- ReadFromPipeOut
			elsif (hi_cmd = DReadFromPipeOut) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				j:=0;
				ep := hi_datain(7 downto 0);
				tmp_slv8 := hi_datain(15 downto 8);
				BlockDelayStates := CONV_INTEGER(tmp_slv8);
				wait until (falling_edge(hi_clk));
				tmp_slv32 := hi_datain;
				pipeLength := CONV_INTEGER(tmp_slv32);
				for i in 1 to pipeLength loop
					ep_command <= CReadFromPipeOut;
					ep_addr <= ep;
					wait until (falling_edge(hi_clk));
					if (i = pipeLength) then
						ep_command <= (others => '0');
					end if;
					hi_dataout <= ep_datain;
					j:=j+4;
					if (j = 1024) then
						for k in 1 to BlockDelayStates loop
							ep_command <= (others => '0');
							ep_addr <= (others => '0');
							ep_dataout <= (others => '0');
							wait until (falling_edge(hi_clk));
						end loop;
						j:=0;
					end if;
				end loop;
	
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
				
			-- WriteToBlockPipeIn
			elsif (hi_cmd = DWriteToBlockPipeIn) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				ep := hi_datain(7 downto 0);
				tmp_slv8 := hi_datain(15 downto 8);
				BlockDelayStates := CONV_INTEGER(tmp_slv8);
				wait until (falling_edge(hi_clk)); 
				tmp_slv32 := hi_datain;
				pipeLength := CONV_INTEGER(tmp_slv32);
				wait until (falling_edge(hi_clk)); 
				tmp_slv32 := hi_datain;
				blockSize := CONV_INTEGER(tmp_slv32);
				wait until (falling_edge(hi_clk)); 
				tmp_slv8 := hi_datain(7 downto 0);
				ReadyCheckDelay := CONV_INTEGER(tmp_slv8);
				tmp_slv8 := hi_datain(15 downto 8);
				PostReadyDelay := CONV_INTEGER(tmp_slv8);
				ep_addr <= ep;
				blockNum := pipeLength/blockSize;
				for i in 1 to blockNum loop
					for j in 1 to ReadyCheckDelay loop
						wait until (falling_edge(hi_clk));
					end loop;
					while (ep_ready = '0') loop
						wait until (falling_edge(hi_clk));
					end loop;
					hi_busy <= '0';
					for j in 1 to PostReadyDelay loop
						wait until (falling_edge(hi_clk));
					end loop;
					wait until (falling_edge(hi_clk)); hi_busy <= '1';
					ep_blockstrobe <= '1';
					wait until (falling_edge(hi_clk)); ep_blockstrobe <= '0';
					wait until (falling_edge(hi_clk));
					for j in 1 to blockSize loop
						wait until (falling_edge(hi_clk));
						ep_command <= CWriteToBTPipeIn;
						ep_dataout <= hi_datain;
					end loop;
					for j in 1 to BlockDelayStates loop
						wait until (falling_edge(hi_clk));
						ep_command <= (others => '0');
						ep_dataout <= (others => '0');
					end loop;
				end loop;
				
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				ep_addr <= (others => '0');
				ep_dataout <= (others => '0');
				wait until (falling_edge(hi_clk)); wait until (falling_edge(hi_clk)); wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk)); hi_busy <= '0'; j := 0;
	
			-- ReadFromBlockPipeOut
			elsif (hi_cmd = DReadFromBlockPipeOut) then
				wait until (falling_edge(hi_clk)); hi_busy <= '1';
				ep := hi_datain(7 downto 0);
				tmp_slv8 := hi_datain(15 downto 8);
				BlockDelayStates := CONV_INTEGER(tmp_slv8);
				wait until (falling_edge(hi_clk)); 
				tmp_slv32 := hi_datain;
				pipeLength := CONV_INTEGER(tmp_slv32);
				wait until (falling_edge(hi_clk)); 
				tmp_slv32 := hi_datain;
				blockSize := CONV_INTEGER(tmp_slv32);
				wait until (falling_edge(hi_clk)); 
				tmp_slv8 := hi_datain(7 downto 0);
				ReadyCheckDelay := CONV_INTEGER(tmp_slv8);
				tmp_slv8 := hi_datain(15 downto 8);
				PostReadyDelay := CONV_INTEGER(tmp_slv8);
				ep_addr <= ep;
				blockNum := pipeLength/blockSize;
				for i in 1 to blockNum loop
					for j in 1 to ReadyCheckDelay loop
						wait until (falling_edge(hi_clk));
					end loop;
					while (ep_ready = '0') loop
						wait until (falling_edge(hi_clk));
					end loop;
					hi_busy <= '0';
					for j in 1 to PostReadyDelay loop
						wait until (falling_edge(hi_clk));
					end loop;
					wait until (falling_edge(hi_clk)); hi_busy <= '1';
					ep_blockstrobe <= '1';
					wait until (falling_edge(hi_clk)); ep_blockstrobe <= '0';
					for j in 1 to blockSize loop
						ep_command <= CReadFromPipeOut;
						wait until (falling_edge(hi_clk));
						if (i = pipeLength) then
							ep_command <= (others => '0');
						end if;
						hi_dataout <= ep_datain;
					end loop;
					for j in 1 to BlockDelayStates loop
						ep_command <= (others => '0');
						wait until (falling_edge(hi_clk)); hi_dataout <= (others => '0');
					end loop;
				end loop;
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				ep_addr <= (others => '0');
				ep_dataout <= (others => '0');
				wait until (falling_edge(hi_clk)); wait until (falling_edge(hi_clk)); wait until (falling_edge(hi_clk));
				wait until (falling_edge(hi_clk)); hi_busy <= '0';
			
			else
				report "Unsupported host sub-command sent";
			end if;
			
		--------------------------------------------------------------------
		-- Registers
		--------------------------------------------------------------------
		elsif (hi_cmd = DRegisters) then
			wait until (falling_edge(hi_clk));
			
			-- WriteRegister
			if (hi_cmd = DWriteRegister) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				wait until (falling_edge(hi_clk));
				reg_addr <= hi_datain;
				wait until (falling_edge(hi_clk));
				reg_write_data <= hi_datain;
				wait until (falling_edge(hi_clk));
				reg_write <= '1';
				wait until (falling_edge(hi_clk));
				reg_write <= '0'; 
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
				 
			-- ReadRegister
			elsif (hi_cmd = DReadRegister) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				wait until (falling_edge(hi_clk));
				reg_addr <= hi_datain;
				wait until (falling_edge(hi_clk));
				reg_read <= '1';
				wait until (falling_edge(hi_clk));
				hi_dataout <= reg_read_data ;
				reg_read <= '0'; 
				wait until (falling_edge(hi_clk));
				ep_command <= (others => '0');
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
				
			-- DWriteRegisterSet
			elsif (hi_cmd = DWriteRegisterSet) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				wait until (falling_edge(hi_clk));
				tmp_slv32 :=  hi_datain;
				registerNum := CONV_INTEGER(tmp_slv32);
				for i in 1 to registerNum loop
					wait until (falling_edge(hi_clk));
					reg_addr <= hi_datain;
					wait until (falling_edge(hi_clk));
					reg_write_data <= hi_datain;
					wait until (falling_edge(hi_clk));
					reg_write <= '1';
					wait until (falling_edge(hi_clk));
					reg_write <= '0';
				end loop;
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
				
			-- DReadRegisterSet
			elsif (hi_cmd = DReadRegisterSet) then
				wait until (falling_edge(hi_clk));
				hi_busy <= '1';
				wait until (falling_edge(hi_clk));
				tmp_slv32 :=  hi_datain;
				registerNum := CONV_INTEGER(tmp_slv32);
				for i in 1 to registerNum loop
					wait until (falling_edge(hi_clk));
					reg_addr <= hi_datain;
					wait until (falling_edge(hi_clk));
					reg_read <= '1';
					wait until (falling_edge(hi_clk));
					hi_dataout <= reg_read_data ;
					reg_read <= '0';
					wait until (falling_edge(hi_clk));
				end loop;
				wait until (falling_edge(hi_clk));
				hi_dataout <= (others => '0');
				wait until (falling_edge(hi_clk));
				hi_busy <= '0';
			
			else
				report "Unsupported host sub-command sent";
			end if;
			

		elsif (hi_cmd = DNOP) then
			report "NOP Detected";
			wait until (falling_edge(hi_clk));
		else
			report "Unsupported host command group sent";
		end if;
		
end process;

end arch;
