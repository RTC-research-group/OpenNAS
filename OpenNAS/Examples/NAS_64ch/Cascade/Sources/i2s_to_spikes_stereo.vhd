----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:30:32 11/01/2016 
-- Design Name: 
-- Module Name:    is2_to_spikes_stereo - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity is2_to_spikes_stereo is
port(
	clock		: in std_logic;		
	reset				: in std_logic;
	 
	 --I2S Bus
	i2s_bclk      : in  STD_LOGIC;
   i2s_d_in      : in  STD_LOGIC;
   i2s_lr        : in  STD_LOGIC;
			  
		--Spikes Output
	spikes_left		: out std_logic_vector(1 downto 0);		
	spikes_rigth	: out std_logic_vector(1 downto 0)	);
end is2_to_spikes_stereo;

architecture Behavioral of is2_to_spikes_stereo is
	
	component I2S_inteface is
    Port ( clk           : in  STD_LOGIC;
			  rst           : in  STD_LOGIC;
           
           i2s_bclk      : in  STD_LOGIC;
           i2s_d_in      : in  STD_LOGIC;
           i2s_lr        : in  STD_LOGIC;
			  
			  audio_l_out   : out STD_LOGIC_VECTOR (31 downto 0);
           audio_r_out   : out STD_LOGIC_VECTOR (31 downto 0);
           new_sample    : out STD_LOGIC );
	end component;

	


	component Spikes_Generator_signed_BW is
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
				  FREQ_DIV: in STD_LOGIC_VECTOR(15 downto 0);
					  DATA_IN: in STD_LOGIC_VECTOR(19 downto 0);
					  WR: in STD_LOGIC;
					  SPIKE_P : out  STD_LOGIC;
					  SPIKE_N : out  STD_LOGIC);
		end component;

	signal data_ready : std_logic;
	signal left_in_data : std_logic_vector(31 downto 0);
	signal right_in_data : std_logic_vector(31 downto 0);
	signal genDiv : std_logic_vector(15 downto 0);

begin

genDiv<=x"000F";

U_i2s_interface: I2S_inteface 
    Port map ( CLK =>clock,
				  RST =>reset,
           
           i2s_bclk  => i2s_bclk,
           i2s_d_in  => i2s_d_in,
           i2s_lr    => i2s_lr,
			  
			  audio_l_out  =>left_in_data,
           audio_r_out  => right_in_data,
           new_sample   =>data_ready );


U_Spikes_Gen_Left: Spikes_Generator_signed_BW
		 Port map( CLK =>clock,
				  RST =>reset,
				  FREQ_DIV=>genDiv,
				  DATA_IN=>left_in_data(31 downto 12),
				  WR=>Data_Ready,
				  SPIKE_P =>spikes_left(1),
				  SPIKE_N =>spikes_left(0)
				  );

	U_Spikes_Gen_Rigth: Spikes_Generator_signed_BW
		 Port map( CLK =>clock,
				  RST =>reset,
				  FREQ_DIV=>genDiv,
				  DATA_IN=>right_in_data(31 downto 12),
				  WR=>Data_Ready,
				  SPIKE_P =>spikes_rigth(1),
				  SPIKE_N =>spikes_rigth(0)
				  );


end Behavioral;
