library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OpenNas_Cascade_MONO_64ch is
  port(
  clock     : in std_logic;
  rst_ext	: in std_logic;
--I2S Bus
  i2s_bclk      : in  STD_LOGIC;
  i2s_d_in: in  STD_LOGIC;
  i2s_lr: in  STD_LOGIC;
--AER Output
  AER_DATA_OUT: out  STD_LOGIC_VECTOR(15 downto 0);
  AER_REQ: out  STD_LOGIC;
  AER_ACK: in  STD_LOGIC
);
end OpenNas_Cascade_MONO_64ch;

architecture OpenNas_arq of OpenNas_Cascade_MONO_64ch is

--I2S interface Stereo
component is2_to_spikes_stereo is
port (
  clock: in std_logic;
  reset: in std_logic;
--I2S Bus
  i2s_bclk  : in std_logic;
  i2s_d_in: in std_logic;
  i2s_lr: in std_logic;
--Spikes Output
  spikes_left: out std_logic_vector(1 downto 0);
  spikes_rigth: out std_logic_vector(1 downto 0)
);
end component;
--Cascade Filter Bank
component CFBank_2or_64CH is
  port(
  clock     : in std_logic;
   rst             : in std_logic;
  spikes_in: in std_logic_vector(1 downto 0);
  spikes_out: out std_logic_vector(127 downto 0)
);
end component;

--Spikes Distributed Monitor
component AER_DISTRIBUTED_MONITOR is
generic(N_SPIKES: integer:=128; LOG_2_N_SPIKES: integer:=7; TAM_AER: in integer; IL_AER: in integer);
Port(
  CLK: in  STD_LOGIC;
  RST: in  STD_LOGIC;
  SPIKES_IN: in  STD_LOGIC_VECTOR(N_SPIKES - 1 downto 0);
  AER_DATA_OUT: out  STD_LOGIC_VECTOR(15 downto 0);
  AER_REQ: out  STD_LOGIC;
  AER_ACK: in  STD_LOGIC);
end component;

--Reset siganl
  signal reset : std_logic;
--Left spikes
  signal spikes_in_left : std_logic_vector(1 downto 0);
  signal spikes_out_left : std_logic_vector(127 downto 0);
--Output spikes
  signal spikes_out: std_logic_vector(127 downto 0);

begin

reset<=rst_ext;
--Output spikes connection
spikes_out<= spikes_out_left ;
--I2S Stereo
U_I2S_Stereo: is2_to_spikes_stereo
port map (
  clock=>clock,
  reset=>reset,
--I2S Bus
  i2s_bclk  => i2s_bclk,
   i2s_d_in => i2s_d_in,
   i2s_lr => i2s_lr,
--Spikes Output
  spikes_left=>spikes_in_left,
  spikes_rigth=>open
);

--Cascade Filter Bank
U_CFBank_2or_64CH_Left: CFBank_2or_64CH
  port map(
  clock =>clock,
   rst  => reset,
  spikes_in=> spikes_in_left,
  spikes_out=>spikes_out_left
);

--Spikes Distributed Monitor
 U_AER_DISTRIBUTED_MONITOR: AER_DISTRIBUTED_MONITOR
generic map (N_SPIKES=>128, LOG_2_N_SPIKES=>7, TAM_AER=>2048, IL_AER=>11)
Port map (
  CLK=>clock,
  RST=> reset,
  SPIKES_IN=>spikes_out,
  AER_DATA_OUT=>AER_DATA_OUT,
  AER_REQ=>AER_REQ,
  AER_ACK=>AER_ACK);

end OpenNas_arq;
