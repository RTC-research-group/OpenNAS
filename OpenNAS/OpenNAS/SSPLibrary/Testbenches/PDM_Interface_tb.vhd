--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                      //
--//                                                                             //
--//    This file is part of OpenNAS.                                            //
--//                                                                             //
--//    OpenNAS is free software: you can redistribute it and/or modify          //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    OpenNAS is distributed in the hope that it will be useful,               //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------------------
-- Company: RTC Lab., University of Seville
-- Engineer: Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- 
-- Create Date:    10:14:11 12/02/2020 
-- Design Name: 
-- Module Name:    PDM_Interface_tb - Behavioral 
-- Project Name: OpenNAS
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

-------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------
-- Entity
-------------------------------------------------------------------------------
entity PDM_Interface_tb is

end entity PDM_Interface_tb;

-------------------------------------------------------------------------------
-- Architecture Behavioral
-------------------------------------------------------------------------------
architecture Behavioral of PDM_Interface_tb is

    ---------------------------------------------------------------------------
    -- DUT component declaration
    ---------------------------------------------------------------------------
    component PDM_Interface is
        port (
            CLK        : in  std_logic;
            RST        : in  std_logic;
            CLOCK_DIV  : in  std_logic_vector(7 downto 0);
            PDM_CLK    : out std_logic;
            PDM_DAT    : in  std_logic;
            SPIKES_OUT : out std_logic_vector(1 downto 0)
        );
    end component PDM_Interface;

    ---------------------------------------------------------------------------
    -- DUT signals
    ---------------------------------------------------------------------------
    signal CLK        : std_logic := '0';
    signal RST        : std_logic := '0';
    signal CLOCK_DIV  : std_logic_vector(7 downto 0) := (others => '0');
    signal PDM_CLK    : std_logic;
    signal PDM_DAT    : std_logic := '0';
    signal SPIKES_OUT : std_logic_vector(1 downto 0);

    ---------------------------------------------------------------------------
    -- Testbench signals
    ---------------------------------------------------------------------------
    constant c_CLK_period : time := 20 ns; -- 50 MHz main clock

    signal tb_start_read_file : std_logic := '0';
    signal tb_finish_read_file : std_logic := '0';

    constant c_num_pdm_samples : integer := 37500;
    type t_pdm_data_array is array ((c_num_pdm_samples - 1) downto 0) of std_logic;
    signal tb_pdm_sequence_data_array : t_pdm_data_array;
    signal tb_last_pdm_sample_read : std_logic := '0';
    
    signal tb_start_testbench : std_logic := '0';
    signal tb_finish_testbench : std_logic := '0';

begin  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- DUT instantiation
    ---------------------------------------------------------------------------
    DUT: PDM_Interface
        port map (
            CLK        => CLK,
            RST        => RST,
            CLOCK_DIV  => CLOCK_DIV,
            PDM_CLK    => PDM_CLK,
            PDM_DAT    => PDM_DAT,
            SPIKES_OUT => SPIKES_OUT
        );

    ---------------------------------------------------------------------------
    -- Clock generation
    ---------------------------------------------------------------------------
    CLK <= not CLK after c_CLK_period/2;

    ---------------------------------------------------------------------------
    -- Waveform generation
    ---------------------------------------------------------------------------

    -- purpose: Main process
    -- type   : 
    -- inputs : 
    -- outputs:
    p_main_process: process
    begin -- process p_main_process
        
        -- Initial reset: wait until the pdm_data have been read
        RST <= '0';
        wait until tb_finish_read_file = '1';

        -- Hold the reset for 100 ns
        wait for 100 ns;
        RST <= '1';

        -- Keep in idle for 1 us
        wait for 1 us;

        -- Set the start_testbench flag to HIGH
        tb_start_testbench <= '1';

        -- Wait until the last sample has been readed
        wait until tb_last_pdm_sample_read = '1';

        -- Set the finish_testbench flag to HIGH
        tb_finish_testbench <= '1';
        
        -- Report the end of the simulation
        report "End of simulation." severity note;
        
        -- Wait forever
        wait;
    end process p_main_process;

    -- purpose: Read the pdm data from a text file
    -- type   : 
    -- inputs : 
    -- outputs: 
    p_read_pdm_data_from_file: process is
        file f_pdm_data_file_handler : text;
        variable v_pdm_data_file_handler_status : FILE_OPEN_STATUS;
        variable v_data_line : line;
        variable v_data : integer := 0;
        variable v_data_index : integer := 0;
    begin  -- process p_read_pdm_data_from_file

        -- Report the start of the reading process
        report "Starting the pdm_data reading process." severity note;

        -- Set the flag tb_finish_read_file HIGH
        tb_start_read_file <= '1';

        -- Open the file
        file_open(v_pdm_data_file_handler_status, f_pdm_data_file_handler, "D:/Universidad/Repositorios/GitHub/RTC-research-group/OpenNAS/OpenNAS/OpenNAS/OpenNAS/SSPLibrary/Testbenches/PDM_Interface_tb_input_file.txt", read_mode);

        -- Read the file until the end of the file
        while (not endfile(f_pdm_data_file_handler)) loop
            -- Read a line
            readline (f_pdm_data_file_handler, v_data_line);

            -- Read the data contained in the line
            read (v_data_line, v_data);

            -- Store the read value in the array
            tb_pdm_sequence_data_array(v_data_index) <= std_logic(to_unsigned(v_data, 1)(0));

            -- Update the index
            v_data_index := v_data_index + 1;
            
        end loop;

        -- Check the number of read values is equal to the number of samples
        assert v_data_index = c_num_pdm_samples report "The number of loaded values does not match with the expected number of values." severity error;

        -- Report the end of the reading process
        report "End of the pdm_data reading process." severity note;

        -- Set the flag tb_finish_read_file HIGH
        tb_finish_read_file <= '1';
        
        -- Wait forever
        wait;

    end process p_read_pdm_data_from_file;

    -- purpose: Simulation of the PDM microphones stimuli read process
    -- type   : sequential
    -- inputs : PDM_CLK, RST
    -- outputs: 
    p_read_pdm_data: process (PDM_CLK, RST) is
        variable v_pdm_data_index : integer := 0;
    begin  -- process p_read_pdm_data
        if RST = '0' then               -- asynchronous reset (active low)
            -- Clear the input data and set the clk_div
            PDM_DAT <= '0';
            CLOCK_DIV <= x"07";
            
            -- Clear the array index
            v_pdm_data_index := 0;
        elsif PDM_CLK'event and PDM_CLK = '1' then  -- rising clock edge
		
			-- If the testbench is ready to start
			if tb_start_testbench = '1' then
				-- Read a new pdm_data
				PDM_DAT <= tb_pdm_sequence_data_array(v_pdm_data_index);

				-- If this is the last data, start again
				if v_pdm_data_index = (c_num_pdm_samples - 1) then
					v_pdm_data_index := 0;
					tb_last_pdm_sample_read <= '1';
				else
					v_pdm_data_index := v_pdm_data_index + 1;
				end if;
			end if;
            
        end if;
    end process p_read_pdm_data;

    

end architecture Behavioral;

-------------------------------------------------------------------------------

configuration PDM_Interface_tb_Behavioral_cfg of PDM_Interface_tb is
    for Behavioral
    end for;
end PDM_Interface_tb_Behavioral_cfg;

-------------------------------------------------------------------------------
