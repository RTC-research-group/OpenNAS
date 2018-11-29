library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CFBank_2or_64CH is
  port(
  clock     : in std_logic;
   rst             : in std_logic;
  spikes_in: in std_logic_vector(1 downto 0);
  spikes_out: out std_logic_vector(127 downto 0)
);
end CFBank_2or_64CH;

architecture CFBank_arq of CFBank_2or_64CH is

  component spikes_2BPF_fullGain is
  generic (GL: in integer:= 11; SAT: in integer:= 1023);
  Port(CLK: in  STD_LOGIC;
      RST: in  STD_LOGIC;
      FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
      SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
      SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);
      SPIKES_DIV_BPF: in STD_LOGIC_VECTOR(15 downto 0);
      spike_in_slpf_p: in  STD_LOGIC;
      spike_in_slpf_n: in  STD_LOGIC;
      spike_in_shf_p: in  STD_LOGIC;
      spike_in_shf_n: in  STD_LOGIC;
      spike_out_p: out  STD_LOGIC;
      spike_out_n: out  STD_LOGIC;
      spike_out_lpf_p: out  STD_LOGIC;
      spike_out_lpf_n: out  STD_LOGIC);
  end component;

  signal not_rst: std_logic;
  signal lpf_spikes_0 : std_logic_vector(1 downto 0);
  signal lpf_spikes_1 : std_logic_vector(1 downto 0);
  signal lpf_spikes_2 : std_logic_vector(1 downto 0);
  signal lpf_spikes_3 : std_logic_vector(1 downto 0);
  signal lpf_spikes_4 : std_logic_vector(1 downto 0);
  signal lpf_spikes_5 : std_logic_vector(1 downto 0);
  signal lpf_spikes_6 : std_logic_vector(1 downto 0);
  signal lpf_spikes_7 : std_logic_vector(1 downto 0);
  signal lpf_spikes_8 : std_logic_vector(1 downto 0);
  signal lpf_spikes_9 : std_logic_vector(1 downto 0);
  signal lpf_spikes_10 : std_logic_vector(1 downto 0);
  signal lpf_spikes_11 : std_logic_vector(1 downto 0);
  signal lpf_spikes_12 : std_logic_vector(1 downto 0);
  signal lpf_spikes_13 : std_logic_vector(1 downto 0);
  signal lpf_spikes_14 : std_logic_vector(1 downto 0);
  signal lpf_spikes_15 : std_logic_vector(1 downto 0);
  signal lpf_spikes_16 : std_logic_vector(1 downto 0);
  signal lpf_spikes_17 : std_logic_vector(1 downto 0);
  signal lpf_spikes_18 : std_logic_vector(1 downto 0);
  signal lpf_spikes_19 : std_logic_vector(1 downto 0);
  signal lpf_spikes_20 : std_logic_vector(1 downto 0);
  signal lpf_spikes_21 : std_logic_vector(1 downto 0);
  signal lpf_spikes_22 : std_logic_vector(1 downto 0);
  signal lpf_spikes_23 : std_logic_vector(1 downto 0);
  signal lpf_spikes_24 : std_logic_vector(1 downto 0);
  signal lpf_spikes_25 : std_logic_vector(1 downto 0);
  signal lpf_spikes_26 : std_logic_vector(1 downto 0);
  signal lpf_spikes_27 : std_logic_vector(1 downto 0);
  signal lpf_spikes_28 : std_logic_vector(1 downto 0);
  signal lpf_spikes_29 : std_logic_vector(1 downto 0);
  signal lpf_spikes_30 : std_logic_vector(1 downto 0);
  signal lpf_spikes_31 : std_logic_vector(1 downto 0);
  signal lpf_spikes_32 : std_logic_vector(1 downto 0);
  signal lpf_spikes_33 : std_logic_vector(1 downto 0);
  signal lpf_spikes_34 : std_logic_vector(1 downto 0);
  signal lpf_spikes_35 : std_logic_vector(1 downto 0);
  signal lpf_spikes_36 : std_logic_vector(1 downto 0);
  signal lpf_spikes_37 : std_logic_vector(1 downto 0);
  signal lpf_spikes_38 : std_logic_vector(1 downto 0);
  signal lpf_spikes_39 : std_logic_vector(1 downto 0);
  signal lpf_spikes_40 : std_logic_vector(1 downto 0);
  signal lpf_spikes_41 : std_logic_vector(1 downto 0);
  signal lpf_spikes_42 : std_logic_vector(1 downto 0);
  signal lpf_spikes_43 : std_logic_vector(1 downto 0);
  signal lpf_spikes_44 : std_logic_vector(1 downto 0);
  signal lpf_spikes_45 : std_logic_vector(1 downto 0);
  signal lpf_spikes_46 : std_logic_vector(1 downto 0);
  signal lpf_spikes_47 : std_logic_vector(1 downto 0);
  signal lpf_spikes_48 : std_logic_vector(1 downto 0);
  signal lpf_spikes_49 : std_logic_vector(1 downto 0);
  signal lpf_spikes_50 : std_logic_vector(1 downto 0);
  signal lpf_spikes_51 : std_logic_vector(1 downto 0);
  signal lpf_spikes_52 : std_logic_vector(1 downto 0);
  signal lpf_spikes_53 : std_logic_vector(1 downto 0);
  signal lpf_spikes_54 : std_logic_vector(1 downto 0);
  signal lpf_spikes_55 : std_logic_vector(1 downto 0);
  signal lpf_spikes_56 : std_logic_vector(1 downto 0);
  signal lpf_spikes_57 : std_logic_vector(1 downto 0);
  signal lpf_spikes_58 : std_logic_vector(1 downto 0);
  signal lpf_spikes_59 : std_logic_vector(1 downto 0);
  signal lpf_spikes_60 : std_logic_vector(1 downto 0);
  signal lpf_spikes_61 : std_logic_vector(1 downto 0);
  signal lpf_spikes_62 : std_logic_vector(1 downto 0);
  signal lpf_spikes_63 : std_logic_vector(1 downto 0);
  signal lpf_spikes_64 : std_logic_vector(1 downto 0);
begin

not_rst <= not rst;

--Ideal cutoff: 23257,3762Hz - Real cutoff: 23256,0352Hz - Error: 0,0058%
U_BPF_0: spikes_2BPF_fullGain
generic map(GL => 7, SAT => 63)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"77B4",
  SPIKES_DIV_OUT => x"77B4",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => spikes_in(1),
  spike_in_slpf_n => spikes_in(0),
  spike_in_shf_p => '0',
  spike_in_shf_n => '0',
  spike_out_p => open,
  spike_out_n => open, 
  spike_out_lpf_p => lpf_spikes_0(1),
  spike_out_lpf_n => lpf_spikes_0(0)
);

--Ideal cutoff: 20810,6020Hz - Real cutoff: 20809,3097Hz - Error: 0,0062%
U_BPF_1: spikes_2BPF_fullGain
generic map(GL => 7, SAT => 63)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"6B1C",
  SPIKES_DIV_OUT => x"6B1C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_0(1),
  spike_in_slpf_n => lpf_spikes_0(0),
  spike_in_shf_p => lpf_spikes_0(1),
  spike_in_shf_n => lpf_spikes_0(0),
  spike_out_p => spikes_out(1),
  spike_out_n => spikes_out(0), 
  spike_out_lpf_p => lpf_spikes_1(1),
  spike_out_lpf_n => lpf_spikes_1(0)
);

--Ideal cutoff: 18621,2388Hz - Real cutoff: 18620,4870Hz - Error: 0,0040%
U_BPF_2: spikes_2BPF_fullGain
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7303",
  SPIKES_DIV_OUT => x"7303",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_1(1),
  spike_in_slpf_n => lpf_spikes_1(0),
  spike_in_shf_p => lpf_spikes_1(1),
  spike_in_shf_n => lpf_spikes_1(0),
  spike_out_p => spikes_out(3),
  spike_out_n => spikes_out(2), 
  spike_out_lpf_p => lpf_spikes_2(1),
  spike_out_lpf_n => lpf_spikes_2(0)
);

--Ideal cutoff: 16662,2058Hz - Real cutoff: 16661,2346Hz - Error: 0,0058%
U_BPF_3: spikes_2BPF_fullGain
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"66E9",
  SPIKES_DIV_OUT => x"66E9",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_2(1),
  spike_in_slpf_n => lpf_spikes_2(0),
  spike_in_shf_p => lpf_spikes_2(1),
  spike_in_shf_n => lpf_spikes_2(0),
  spike_out_p => spikes_out(5),
  spike_out_n => spikes_out(4), 
  spike_out_lpf_p => lpf_spikes_3(1),
  spike_out_lpf_n => lpf_spikes_3(0)
);

--Ideal cutoff: 14909,2714Hz - Real cutoff: 14908,7851Hz - Error: 0,0033%
U_BPF_4: spikes_2BPF_fullGain
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7AC8",
  SPIKES_DIV_OUT => x"7AC8",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_3(1),
  spike_in_slpf_n => lpf_spikes_3(0),
  spike_in_shf_p => lpf_spikes_3(1),
  spike_in_shf_n => lpf_spikes_3(0),
  spike_out_p => spikes_out(7),
  spike_out_n => spikes_out(6), 
  spike_out_lpf_p => lpf_spikes_4(1),
  spike_out_lpf_n => lpf_spikes_4(0)
);

--Ideal cutoff: 13340,7531Hz - Real cutoff: 13340,2132Hz - Error: 0,0040%
U_BPF_5: spikes_2BPF_fullGain
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"6DDD",
  SPIKES_DIV_OUT => x"6DDD",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_4(1),
  spike_in_slpf_n => lpf_spikes_4(0),
  spike_in_shf_p => lpf_spikes_4(1),
  spike_in_shf_n => lpf_spikes_4(0),
  spike_out_p => spikes_out(9),
  spike_out_n => spikes_out(8), 
  spike_out_lpf_p => lpf_spikes_5(1),
  spike_out_lpf_n => lpf_spikes_5(0)
);

--Ideal cutoff: 11937,2495Hz - Real cutoff: 11936,5145Hz - Error: 0,0062%
U_BPF_6: spikes_2BPF_fullGain
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7AE1",
  SPIKES_DIV_OUT => x"7AE1",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_5(1),
  spike_in_slpf_n => lpf_spikes_5(0),
  spike_in_shf_p => lpf_spikes_5(1),
  spike_in_shf_n => lpf_spikes_5(0),
  spike_out_p => spikes_out(11),
  spike_out_n => spikes_out(10), 
  spike_out_lpf_p => lpf_spikes_6(1),
  spike_out_lpf_n => lpf_spikes_6(0)
);

--Ideal cutoff: 10681,4005Hz - Real cutoff: 10680,8980Hz - Error: 0,0047%
U_BPF_7: spikes_2BPF_fullGain
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"6DF4",
  SPIKES_DIV_OUT => x"6DF4",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_6(1),
  spike_in_slpf_n => lpf_spikes_6(0),
  spike_in_shf_p => lpf_spikes_6(1),
  spike_in_shf_n => lpf_spikes_6(0),
  spike_out_p => spikes_out(13),
  spike_out_n => spikes_out(12), 
  spike_out_lpf_p => lpf_spikes_7(1),
  spike_out_lpf_n => lpf_spikes_7(0)
);

--Ideal cutoff: 9557,6720Hz - Real cutoff: 9557,2054Hz - Error: 0,0049%
U_BPF_8: spikes_2BPF_fullGain
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7610",
  SPIKES_DIV_OUT => x"7610",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_7(1),
  spike_in_slpf_n => lpf_spikes_7(0),
  spike_in_shf_p => lpf_spikes_7(1),
  spike_in_shf_n => lpf_spikes_7(0),
  spike_out_p => spikes_out(15),
  spike_out_n => spikes_out(14), 
  spike_out_lpf_p => lpf_spikes_8(1),
  spike_out_lpf_n => lpf_spikes_8(0)
);

--Ideal cutoff: 8552,1646Hz - Real cutoff: 8551,6498Hz - Error: 0,0060%
U_BPF_9: spikes_2BPF_fullGain
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"69A4",
  SPIKES_DIV_OUT => x"69A4",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_8(1),
  spike_in_slpf_n => lpf_spikes_8(0),
  spike_in_shf_p => lpf_spikes_8(1),
  spike_in_shf_n => lpf_spikes_8(0),
  spike_out_p => spikes_out(17),
  spike_out_n => spikes_out(16), 
  spike_out_lpf_p => lpf_spikes_9(1),
  spike_out_lpf_n => lpf_spikes_9(0)
);

--Ideal cutoff: 7652,4407Hz - Real cutoff: 7652,1835Hz - Error: 0,0034%
U_BPF_10: spikes_2BPF_fullGain
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7E0A",
  SPIKES_DIV_OUT => x"7E0A",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_9(1),
  spike_in_slpf_n => lpf_spikes_9(0),
  spike_in_shf_p => lpf_spikes_9(1),
  spike_in_shf_n => lpf_spikes_9(0),
  spike_out_p => spikes_out(19),
  spike_out_n => spikes_out(18), 
  spike_out_lpf_p => lpf_spikes_10(1),
  spike_out_lpf_n => lpf_spikes_10(0)
);

--Ideal cutoff: 6847,3716Hz - Real cutoff: 6847,0275Hz - Error: 0,0050%
U_BPF_11: spikes_2BPF_fullGain
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"70C7",
  SPIKES_DIV_OUT => x"70C7",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_10(1),
  spike_in_slpf_n => lpf_spikes_10(0),
  spike_in_shf_p => lpf_spikes_10(1),
  spike_in_shf_n => lpf_spikes_10(0),
  spike_out_p => spikes_out(21),
  spike_out_n => spikes_out(20), 
  spike_out_lpf_p => lpf_spikes_11(1),
  spike_out_lpf_n => lpf_spikes_11(0)
);

--Ideal cutoff: 6126,9992Hz - Real cutoff: 6126,6797Hz - Error: 0,0052%
U_BPF_12: spikes_2BPF_fullGain
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7E24",
  SPIKES_DIV_OUT => x"7E24",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_11(1),
  spike_in_slpf_n => lpf_spikes_11(0),
  spike_in_shf_p => lpf_spikes_11(1),
  spike_in_shf_n => lpf_spikes_11(0),
  spike_out_p => spikes_out(23),
  spike_out_n => spikes_out(22), 
  spike_out_lpf_p => lpf_spikes_12(1),
  spike_out_lpf_n => lpf_spikes_12(0)
);

--Ideal cutoff: 5482,4130Hz - Real cutoff: 5482,1754Hz - Error: 0,0043%
U_BPF_13: spikes_2BPF_fullGain
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"70DF",
  SPIKES_DIV_OUT => x"70DF",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_12(1),
  spike_in_slpf_n => lpf_spikes_12(0),
  spike_in_shf_p => lpf_spikes_12(1),
  spike_in_shf_n => lpf_spikes_12(0),
  spike_out_p => spikes_out(25),
  spike_out_n => spikes_out(24), 
  spike_out_lpf_p => lpf_spikes_13(1),
  spike_out_lpf_n => lpf_spikes_13(0)
);

--Ideal cutoff: 4905,6400Hz - Real cutoff: 4905,4039Hz - Error: 0,0048%
U_BPF_14: spikes_2BPF_fullGain
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7932",
  SPIKES_DIV_OUT => x"7932",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_13(1),
  spike_in_slpf_n => lpf_spikes_13(0),
  spike_in_shf_p => lpf_spikes_13(1),
  spike_in_shf_n => lpf_spikes_13(0),
  spike_out_p => spikes_out(27),
  spike_out_n => spikes_out(26), 
  spike_out_lpf_p => lpf_spikes_14(1),
  spike_out_lpf_n => lpf_spikes_14(0)
);

--Ideal cutoff: 4389,5460Hz - Real cutoff: 4389,3452Hz - Error: 0,0046%
U_BPF_15: spikes_2BPF_fullGain
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"6C72",
  SPIKES_DIV_OUT => x"6C72",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_14(1),
  spike_in_slpf_n => lpf_spikes_14(0),
  spike_in_shf_p => lpf_spikes_14(1),
  spike_in_shf_n => lpf_spikes_14(0),
  spike_out_p => spikes_out(29),
  spike_out_n => spikes_out(28), 
  spike_out_lpf_p => lpf_spikes_15(1),
  spike_out_lpf_n => lpf_spikes_15(0)
);

--Ideal cutoff: 3927,7472Hz - Real cutoff: 3927,5169Hz - Error: 0,0059%
U_BPF_16: spikes_2BPF_fullGain
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"6109",
  SPIKES_DIV_OUT => x"6109",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_15(1),
  spike_in_slpf_n => lpf_spikes_15(0),
  spike_in_shf_p => lpf_spikes_15(1),
  spike_in_shf_n => lpf_spikes_15(0),
  spike_out_p => spikes_out(31),
  spike_out_n => spikes_out(30), 
  spike_out_lpf_p => lpf_spikes_16(1),
  spike_out_lpf_n => lpf_spikes_16(0)
);

--Ideal cutoff: 3514,5316Hz - Real cutoff: 3514,3458Hz - Error: 0,0053%
U_BPF_17: spikes_2BPF_fullGain
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"73C5",
  SPIKES_DIV_OUT => x"73C5",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_16(1),
  spike_in_slpf_n => lpf_spikes_16(0),
  spike_in_shf_p => lpf_spikes_16(1),
  spike_in_shf_n => lpf_spikes_16(0),
  spike_out_p => spikes_out(33),
  spike_out_n => spikes_out(32), 
  spike_out_lpf_p => lpf_spikes_17(1),
  spike_out_lpf_n => lpf_spikes_17(0)
);

--Ideal cutoff: 3144,7880Hz - Real cutoff: 3144,6144Hz - Error: 0,0055%
U_BPF_18: spikes_2BPF_fullGain
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"6797",
  SPIKES_DIV_OUT => x"6797",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_17(1),
  spike_in_slpf_n => lpf_spikes_17(0),
  spike_in_shf_p => lpf_spikes_17(1),
  spike_in_shf_n => lpf_spikes_17(0),
  spike_out_p => spikes_out(35),
  spike_out_n => spikes_out(34), 
  spike_out_lpf_p => lpf_spikes_18(1),
  spike_out_lpf_n => lpf_spikes_18(0)
);

--Ideal cutoff: 2813,9431Hz - Real cutoff: 2813,7533Hz - Error: 0,0067%
U_BPF_19: spikes_2BPF_fullGain
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"73DD",
  SPIKES_DIV_OUT => x"73DD",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_18(1),
  spike_in_slpf_n => lpf_spikes_18(0),
  spike_in_shf_p => lpf_spikes_18(1),
  spike_in_shf_n => lpf_spikes_18(0),
  spike_out_p => spikes_out(37),
  spike_out_n => spikes_out(36), 
  spike_out_lpf_p => lpf_spikes_19(1),
  spike_out_lpf_n => lpf_spikes_19(0)
);

--Ideal cutoff: 2517,9044Hz - Real cutoff: 2517,7627Hz - Error: 0,0056%
U_BPF_20: spikes_2BPF_fullGain
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7C69",
  SPIKES_DIV_OUT => x"7C69",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_19(1),
  spike_in_slpf_n => lpf_spikes_19(0),
  spike_in_shf_p => lpf_spikes_19(1),
  spike_in_shf_n => lpf_spikes_19(0),
  spike_out_p => spikes_out(39),
  spike_out_n => spikes_out(38), 
  spike_out_lpf_p => lpf_spikes_20(1),
  spike_out_lpf_n => lpf_spikes_20(0)
);

--Ideal cutoff: 2253,0102Hz - Real cutoff: 2252,8557Hz - Error: 0,0069%
U_BPF_21: spikes_2BPF_fullGain
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"6F52",
  SPIKES_DIV_OUT => x"6F52",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_20(1),
  spike_in_slpf_n => lpf_spikes_20(0),
  spike_in_shf_p => lpf_spikes_20(1),
  spike_in_shf_n => lpf_spikes_20(0),
  spike_out_p => spikes_out(41),
  spike_out_n => spikes_out(40), 
  spike_out_lpf_p => lpf_spikes_21(1),
  spike_out_lpf_n => lpf_spikes_21(0)
);

--Ideal cutoff: 2015,9840Hz - Real cutoff: 2015,8544Hz - Error: 0,0064%
U_BPF_22: spikes_2BPF_fullGain
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"639C",
  SPIKES_DIV_OUT => x"639C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_21(1),
  spike_in_slpf_n => lpf_spikes_21(0),
  spike_in_shf_p => lpf_spikes_21(1),
  spike_in_shf_n => lpf_spikes_21(0),
  spike_out_p => spikes_out(43),
  spike_out_n => spikes_out(42), 
  spike_out_lpf_p => lpf_spikes_22(1),
  spike_out_lpf_n => lpf_spikes_22(0)
);

--Ideal cutoff: 1803,8940Hz - Real cutoff: 1803,8340Hz - Error: 0,0033%
U_BPF_23: spikes_2BPF_fullGain
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"76D8",
  SPIKES_DIV_OUT => x"76D8",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_22(1),
  spike_in_slpf_n => lpf_spikes_22(0),
  spike_in_shf_p => lpf_spikes_22(1),
  spike_in_shf_n => lpf_spikes_22(0),
  spike_out_p => spikes_out(45),
  spike_out_n => spikes_out(44), 
  spike_out_lpf_p => lpf_spikes_23(1),
  spike_out_lpf_n => lpf_spikes_23(0)
);

--Ideal cutoff: 1614,1167Hz - Real cutoff: 1614,0472Hz - Error: 0,0043%
U_BPF_24: spikes_2BPF_fullGain
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"6A57",
  SPIKES_DIV_OUT => x"6A57",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_23(1),
  spike_in_slpf_n => lpf_spikes_23(0),
  spike_in_shf_p => lpf_spikes_23(1),
  spike_in_shf_n => lpf_spikes_23(0),
  spike_out_p => spikes_out(47),
  spike_out_n => spikes_out(46), 
  spike_out_lpf_p => lpf_spikes_24(1),
  spike_out_lpf_n => lpf_spikes_24(0)
);

--Ideal cutoff: 1444,3048Hz - Real cutoff: 1444,2530Hz - Error: 0,0036%
U_BPF_25: spikes_2BPF_fullGain
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"76F1",
  SPIKES_DIV_OUT => x"76F1",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_24(1),
  spike_in_slpf_n => lpf_spikes_24(0),
  spike_in_shf_p => lpf_spikes_24(1),
  spike_in_shf_n => lpf_spikes_24(0),
  spike_out_p => spikes_out(49),
  spike_out_n => spikes_out(48), 
  spike_out_lpf_p => lpf_spikes_25(1),
  spike_out_lpf_n => lpf_spikes_25(0)
);

--Ideal cutoff: 1292,3578Hz - Real cutoff: 1292,2813Hz - Error: 0,0059%
U_BPF_26: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7FB6",
  SPIKES_DIV_OUT => x"7FB6",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_25(1),
  spike_in_slpf_n => lpf_spikes_25(0),
  spike_in_shf_p => lpf_spikes_25(1),
  spike_in_shf_n => lpf_spikes_25(0),
  spike_out_p => spikes_out(51),
  spike_out_n => spikes_out(50), 
  spike_out_lpf_p => lpf_spikes_26(1),
  spike_out_lpf_n => lpf_spikes_26(0)
);

--Ideal cutoff: 1156,3963Hz - Real cutoff: 1156,3494Hz - Error: 0,0041%
U_BPF_27: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7247",
  SPIKES_DIV_OUT => x"7247",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_26(1),
  spike_in_slpf_n => lpf_spikes_26(0),
  spike_in_shf_p => lpf_spikes_26(1),
  spike_in_shf_n => lpf_spikes_26(0),
  spike_out_p => spikes_out(53),
  spike_out_n => spikes_out(52), 
  spike_out_lpf_p => lpf_spikes_27(1),
  spike_out_lpf_n => lpf_spikes_27(0)
);

--Ideal cutoff: 1034,7386Hz - Real cutoff: 1034,6867Hz - Error: 0,0050%
U_BPF_28: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"6641",
  SPIKES_DIV_OUT => x"6641",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_27(1),
  spike_in_slpf_n => lpf_spikes_27(0),
  spike_in_shf_p => lpf_spikes_27(1),
  spike_in_shf_n => lpf_spikes_27(0),
  spike_out_p => spikes_out(55),
  spike_out_n => spikes_out(54), 
  spike_out_lpf_p => lpf_spikes_28(1),
  spike_out_lpf_n => lpf_spikes_28(0)
);

--Ideal cutoff: 925,8797Hz - Real cutoff: 925,8404Hz - Error: 0,0042%
U_BPF_29: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"79FF",
  SPIKES_DIV_OUT => x"79FF",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_28(1),
  spike_in_slpf_n => lpf_spikes_28(0),
  spike_in_shf_p => lpf_spikes_28(1),
  spike_in_shf_n => lpf_spikes_28(0),
  spike_out_p => spikes_out(57),
  spike_out_n => spikes_out(56), 
  spike_out_lpf_p => lpf_spikes_29(1),
  spike_out_lpf_n => lpf_spikes_29(0)
);

--Ideal cutoff: 828,4732Hz - Real cutoff: 828,4272Hz - Error: 0,0056%
U_BPF_30: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"6D29",
  SPIKES_DIV_OUT => x"6D29",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_29(1),
  spike_in_slpf_n => lpf_spikes_29(0),
  spike_in_shf_p => lpf_spikes_29(1),
  spike_in_shf_n => lpf_spikes_29(0),
  spike_out_p => spikes_out(59),
  spike_out_n => spikes_out(58), 
  spike_out_lpf_p => lpf_spikes_30(1),
  spike_out_lpf_n => lpf_spikes_30(0)
);

--Ideal cutoff: 741,3144Hz - Real cutoff: 741,2890Hz - Error: 0,0034%
U_BPF_31: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7A19",
  SPIKES_DIV_OUT => x"7A19",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_30(1),
  spike_in_slpf_n => lpf_spikes_30(0),
  spike_in_shf_p => lpf_spikes_30(1),
  spike_in_shf_n => lpf_spikes_30(0),
  spike_out_p => spikes_out(61),
  spike_out_n => spikes_out(60), 
  spike_out_lpf_p => lpf_spikes_31(1),
  spike_out_lpf_n => lpf_spikes_31(0)
);

--Ideal cutoff: 663,3250Hz - Real cutoff: 663,2873Hz - Error: 0,0057%
U_BPF_32: spikes_2BPF_fullGain
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"6D40",
  SPIKES_DIV_OUT => x"6D40",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_31(1),
  spike_in_slpf_n => lpf_spikes_31(0),
  spike_in_shf_p => lpf_spikes_31(1),
  spike_in_shf_n => lpf_spikes_31(0),
  spike_out_p => spikes_out(63),
  spike_out_n => spikes_out(62), 
  spike_out_lpf_p => lpf_spikes_32(1),
  spike_out_lpf_n => lpf_spikes_32(0)
);

--Ideal cutoff: 593,5404Hz - Real cutoff: 593,5110Hz - Error: 0,0049%
U_BPF_33: spikes_2BPF_fullGain
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"754F",
  SPIKES_DIV_OUT => x"754F",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_32(1),
  spike_in_slpf_n => lpf_spikes_32(0),
  spike_in_shf_p => lpf_spikes_32(1),
  spike_in_shf_n => lpf_spikes_32(0),
  spike_out_p => spikes_out(65),
  spike_out_n => spikes_out(64), 
  spike_out_lpf_p => lpf_spikes_33(1),
  spike_out_lpf_n => lpf_spikes_33(0)
);

--Ideal cutoff: 531,0974Hz - Real cutoff: 531,0591Hz - Error: 0,0072%
U_BPF_34: spikes_2BPF_fullGain
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"68F7",
  SPIKES_DIV_OUT => x"68F7",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_33(1),
  spike_in_slpf_n => lpf_spikes_33(0),
  spike_in_shf_p => lpf_spikes_33(1),
  spike_in_shf_n => lpf_spikes_33(0),
  spike_out_p => spikes_out(67),
  spike_out_n => spikes_out(66), 
  spike_out_lpf_p => lpf_spikes_34(1),
  spike_out_lpf_n => lpf_spikes_34(0)
);

--Ideal cutoff: 475,2237Hz - Real cutoff: 475,2080Hz - Error: 0,0033%
U_BPF_35: spikes_2BPF_fullGain
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7D3C",
  SPIKES_DIV_OUT => x"7D3C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_34(1),
  spike_in_slpf_n => lpf_spikes_34(0),
  spike_in_shf_p => lpf_spikes_34(1),
  spike_in_shf_n => lpf_spikes_34(0),
  spike_out_p => spikes_out(69),
  spike_out_n => spikes_out(68), 
  spike_out_lpf_p => lpf_spikes_35(1),
  spike_out_lpf_n => lpf_spikes_35(0)
);

--Ideal cutoff: 425,2282Hz - Real cutoff: 425,2119Hz - Error: 0,0038%
U_BPF_36: spikes_2BPF_fullGain
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"700F",
  SPIKES_DIV_OUT => x"700F",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_35(1),
  spike_in_slpf_n => lpf_spikes_35(0),
  spike_in_shf_p => lpf_spikes_35(1),
  spike_in_shf_n => lpf_spikes_35(0),
  spike_out_p => spikes_out(71),
  spike_out_n => spikes_out(70), 
  spike_out_lpf_p => lpf_spikes_36(1),
  spike_out_lpf_n => lpf_spikes_36(0)
);

--Ideal cutoff: 380,4924Hz - Real cutoff: 380,4747Hz - Error: 0,0046%
U_BPF_37: spikes_2BPF_fullGain
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7D56",
  SPIKES_DIV_OUT => x"7D56",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_36(1),
  spike_in_slpf_n => lpf_spikes_36(0),
  spike_in_shf_p => lpf_spikes_36(1),
  spike_in_shf_n => lpf_spikes_36(0),
  spike_out_p => spikes_out(73),
  spike_out_n => spikes_out(72), 
  spike_out_lpf_p => lpf_spikes_37(1),
  spike_out_lpf_n => lpf_spikes_37(0)
);

--Ideal cutoff: 340,4630Hz - Real cutoff: 340,4422Hz - Error: 0,0061%
U_BPF_38: spikes_2BPF_fullGain
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7026",
  SPIKES_DIV_OUT => x"7026",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_37(1),
  spike_in_slpf_n => lpf_spikes_37(0),
  spike_in_shf_p => lpf_spikes_37(1),
  spike_in_shf_n => lpf_spikes_37(0),
  spike_out_p => spikes_out(75),
  spike_out_n => spikes_out(74), 
  spike_out_lpf_p => lpf_spikes_38(1),
  spike_out_lpf_n => lpf_spikes_38(0)
);

--Ideal cutoff: 304,6448Hz - Real cutoff: 304,6312Hz - Error: 0,0045%
U_BPF_39: spikes_2BPF_fullGain
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"786C",
  SPIKES_DIV_OUT => x"786C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_38(1),
  spike_in_slpf_n => lpf_spikes_38(0),
  spike_in_shf_p => lpf_spikes_38(1),
  spike_in_shf_n => lpf_spikes_38(0),
  spike_out_p => spikes_out(77),
  spike_out_n => spikes_out(76), 
  spike_out_lpf_p => lpf_spikes_39(1),
  spike_out_lpf_n => lpf_spikes_39(0)
);

--Ideal cutoff: 272,5949Hz - Real cutoff: 272,5850Hz - Error: 0,0036%
U_BPF_40: spikes_2BPF_fullGain
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"6BC1",
  SPIKES_DIV_OUT => x"6BC1",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_39(1),
  spike_in_slpf_n => lpf_spikes_39(0),
  spike_in_shf_p => lpf_spikes_39(1),
  spike_in_shf_n => lpf_spikes_39(0),
  spike_out_p => spikes_out(79),
  spike_out_n => spikes_out(78), 
  spike_out_lpf_p => lpf_spikes_40(1),
  spike_out_lpf_n => lpf_spikes_40(0)
);

--Ideal cutoff: 243,9168Hz - Real cutoff: 243,8986Hz - Error: 0,0074%
U_BPF_41: spikes_2BPF_fullGain
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"606A",
  SPIKES_DIV_OUT => x"606A",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_40(1),
  spike_in_slpf_n => lpf_spikes_40(0),
  spike_in_shf_p => lpf_spikes_40(1),
  spike_in_shf_n => lpf_spikes_40(0),
  spike_out_p => spikes_out(81),
  spike_out_n => spikes_out(80), 
  spike_out_lpf_p => lpf_spikes_41(1),
  spike_out_lpf_n => lpf_spikes_41(0)
);

--Ideal cutoff: 218,2557Hz - Real cutoff: 218,2459Hz - Error: 0,0045%
U_BPF_42: spikes_2BPF_fullGain
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7308",
  SPIKES_DIV_OUT => x"7308",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_41(1),
  spike_in_slpf_n => lpf_spikes_41(0),
  spike_in_shf_p => lpf_spikes_41(1),
  spike_in_shf_n => lpf_spikes_41(0),
  spike_out_p => spikes_out(83),
  spike_out_n => spikes_out(82), 
  spike_out_lpf_p => lpf_spikes_42(1),
  spike_out_lpf_n => lpf_spikes_42(0)
);

--Ideal cutoff: 195,2943Hz - Real cutoff: 195,2859Hz - Error: 0,0043%
U_BPF_43: spikes_2BPF_fullGain
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"66EE",
  SPIKES_DIV_OUT => x"66EE",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_42(1),
  spike_in_slpf_n => lpf_spikes_42(0),
  spike_in_shf_p => lpf_spikes_42(1),
  spike_in_shf_n => lpf_spikes_42(0),
  spike_out_p => spikes_out(85),
  spike_out_n => spikes_out(84), 
  spike_out_lpf_p => lpf_spikes_43(1),
  spike_out_lpf_n => lpf_spikes_43(0)
);

--Ideal cutoff: 174,7485Hz - Real cutoff: 174,7390Hz - Error: 0,0054%
U_BPF_44: spikes_2BPF_fullGain
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7320",
  SPIKES_DIV_OUT => x"7320",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_43(1),
  spike_in_slpf_n => lpf_spikes_43(0),
  spike_in_shf_p => lpf_spikes_43(1),
  spike_in_shf_n => lpf_spikes_43(0),
  spike_out_p => spikes_out(87),
  spike_out_n => spikes_out(86), 
  spike_out_lpf_p => lpf_spikes_44(1),
  spike_out_lpf_n => lpf_spikes_44(0)
);

--Ideal cutoff: 156,3642Hz - Real cutoff: 156,3572Hz - Error: 0,0045%
U_BPF_45: spikes_2BPF_fullGain
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7B9E",
  SPIKES_DIV_OUT => x"7B9E",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_44(1),
  spike_in_slpf_n => lpf_spikes_44(0),
  spike_in_shf_p => lpf_spikes_44(1),
  spike_in_shf_n => lpf_spikes_44(0),
  spike_out_p => spikes_out(89),
  spike_out_n => spikes_out(88), 
  spike_out_lpf_p => lpf_spikes_45(1),
  spike_out_lpf_n => lpf_spikes_45(0)
);

--Ideal cutoff: 139,9140Hz - Real cutoff: 139,9043Hz - Error: 0,0070%
U_BPF_46: spikes_2BPF_fullGain
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"6E9C",
  SPIKES_DIV_OUT => x"6E9C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_45(1),
  spike_in_slpf_n => lpf_spikes_45(0),
  spike_in_shf_p => lpf_spikes_45(1),
  spike_in_shf_n => lpf_spikes_45(0),
  spike_out_p => spikes_out(91),
  spike_out_n => spikes_out(90), 
  spike_out_lpf_p => lpf_spikes_46(1),
  spike_out_lpf_n => lpf_spikes_46(0)
);

--Ideal cutoff: 125,1945Hz - Real cutoff: 125,1855Hz - Error: 0,0071%
U_BPF_47: spikes_2BPF_fullGain
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"62F9",
  SPIKES_DIV_OUT => x"62F9",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_46(1),
  spike_in_slpf_n => lpf_spikes_46(0),
  spike_in_shf_p => lpf_spikes_46(1),
  spike_in_shf_n => lpf_spikes_46(0),
  spike_out_p => spikes_out(93),
  spike_out_n => spikes_out(92), 
  spike_out_lpf_p => lpf_spikes_47(1),
  spike_out_lpf_n => lpf_spikes_47(0)
);

--Ideal cutoff: 112,0235Hz - Real cutoff: 112,0170Hz - Error: 0,0058%
U_BPF_48: spikes_2BPF_fullGain
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7615",
  SPIKES_DIV_OUT => x"7615",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_47(1),
  spike_in_slpf_n => lpf_spikes_47(0),
  spike_in_shf_p => lpf_spikes_47(1),
  spike_in_shf_n => lpf_spikes_47(0),
  spike_out_p => spikes_out(95),
  spike_out_n => spikes_out(94), 
  spike_out_lpf_p => lpf_spikes_48(1),
  spike_out_lpf_n => lpf_spikes_48(0)
);

--Ideal cutoff: 100,2382Hz - Real cutoff: 100,2332Hz - Error: 0,0050%
U_BPF_49: spikes_2BPF_fullGain
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"69A9",
  SPIKES_DIV_OUT => x"69A9",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_48(1),
  spike_in_slpf_n => lpf_spikes_48(0),
  spike_in_shf_p => lpf_spikes_48(1),
  spike_in_shf_n => lpf_spikes_48(0),
  spike_out_p => spikes_out(97),
  spike_out_n => spikes_out(96), 
  spike_out_lpf_p => lpf_spikes_49(1),
  spike_out_lpf_n => lpf_spikes_49(0)
);

--Ideal cutoff: 89,6927Hz - Real cutoff: 89,6877Hz - Error: 0,0055%
U_BPF_50: spikes_2BPF_fullGain
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"762E",
  SPIKES_DIV_OUT => x"762E",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_49(1),
  spike_in_slpf_n => lpf_spikes_49(0),
  spike_in_shf_p => lpf_spikes_49(1),
  spike_in_shf_n => lpf_spikes_49(0),
  spike_out_p => spikes_out(99),
  spike_out_n => spikes_out(98), 
  spike_out_lpf_p => lpf_spikes_50(1),
  spike_out_lpf_n => lpf_spikes_50(0)
);

--Ideal cutoff: 80,2566Hz - Real cutoff: 80,2537Hz - Error: 0,0036%
U_BPF_51: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"7EE6",
  SPIKES_DIV_OUT => x"7EE6",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_50(1),
  spike_in_slpf_n => lpf_spikes_50(0),
  spike_in_shf_p => lpf_spikes_50(1),
  spike_in_shf_n => lpf_spikes_50(0),
  spike_out_p => spikes_out(101),
  spike_out_n => spikes_out(100), 
  spike_out_lpf_p => lpf_spikes_51(1),
  spike_out_lpf_n => lpf_spikes_51(0)
);

--Ideal cutoff: 71,8133Hz - Real cutoff: 71,8099Hz - Error: 0,0048%
U_BPF_52: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"718C",
  SPIKES_DIV_OUT => x"718C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_51(1),
  spike_in_slpf_n => lpf_spikes_51(0),
  spike_in_shf_p => lpf_spikes_51(1),
  spike_in_shf_n => lpf_spikes_51(0),
  spike_out_p => spikes_out(103),
  spike_out_n => spikes_out(102), 
  spike_out_lpf_p => lpf_spikes_52(1),
  spike_out_lpf_n => lpf_spikes_52(0)
);

--Ideal cutoff: 64,2582Hz - Real cutoff: 64,2554Hz - Error: 0,0045%
U_BPF_53: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"659A",
  SPIKES_DIV_OUT => x"659A",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_52(1),
  spike_in_slpf_n => lpf_spikes_52(0),
  spike_in_shf_p => lpf_spikes_52(1),
  spike_in_shf_n => lpf_spikes_52(0),
  spike_out_p => spikes_out(105),
  spike_out_n => spikes_out(104), 
  spike_out_lpf_p => lpf_spikes_53(1),
  spike_out_lpf_n => lpf_spikes_53(0)
);

--Ideal cutoff: 57,4980Hz - Real cutoff: 57,4945Hz - Error: 0,0061%
U_BPF_54: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7937",
  SPIKES_DIV_OUT => x"7937",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_53(1),
  spike_in_slpf_n => lpf_spikes_53(0),
  spike_in_shf_p => lpf_spikes_53(1),
  spike_in_shf_n => lpf_spikes_53(0),
  spike_out_p => spikes_out(107),
  spike_out_n => spikes_out(106), 
  spike_out_lpf_p => lpf_spikes_54(1),
  spike_out_lpf_n => lpf_spikes_54(0)
);

--Ideal cutoff: 51,4490Hz - Real cutoff: 51,4469Hz - Error: 0,0040%
U_BPF_55: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"6C77",
  SPIKES_DIV_OUT => x"6C77",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_54(1),
  spike_in_slpf_n => lpf_spikes_54(0),
  spike_in_shf_p => lpf_spikes_54(1),
  spike_in_shf_n => lpf_spikes_54(0),
  spike_out_p => spikes_out(109),
  spike_out_n => spikes_out(108), 
  spike_out_lpf_p => lpf_spikes_55(1),
  spike_out_lpf_n => lpf_spikes_55(0)
);

--Ideal cutoff: 46,0363Hz - Real cutoff: 46,0341Hz - Error: 0,0048%
U_BPF_56: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7951",
  SPIKES_DIV_OUT => x"7951",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_55(1),
  spike_in_slpf_n => lpf_spikes_55(0),
  spike_in_shf_p => lpf_spikes_55(1),
  spike_in_shf_n => lpf_spikes_55(0),
  spike_out_p => spikes_out(111),
  spike_out_n => spikes_out(110), 
  spike_out_lpf_p => lpf_spikes_56(1),
  spike_out_lpf_n => lpf_spikes_56(0)
);

--Ideal cutoff: 41,1931Hz - Real cutoff: 41,1916Hz - Error: 0,0036%
U_BPF_57: spikes_2BPF_fullGain
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"6C8E",
  SPIKES_DIV_OUT => x"6C8E",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_56(1),
  spike_in_slpf_n => lpf_spikes_56(0),
  spike_in_shf_p => lpf_spikes_56(1),
  spike_in_shf_n => lpf_spikes_56(0),
  spike_out_p => spikes_out(113),
  spike_out_n => spikes_out(112), 
  spike_out_lpf_p => lpf_spikes_57(1),
  spike_out_lpf_n => lpf_spikes_57(0)
);

--Ideal cutoff: 36,8594Hz - Real cutoff: 36,8573Hz - Error: 0,0058%
U_BPF_58: spikes_2BPF_fullGain
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"748F",
  SPIKES_DIV_OUT => x"748F",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_57(1),
  spike_in_slpf_n => lpf_spikes_57(0),
  spike_in_shf_p => lpf_spikes_57(1),
  spike_in_shf_n => lpf_spikes_57(0),
  spike_out_p => spikes_out(115),
  spike_out_n => spikes_out(114), 
  spike_out_lpf_p => lpf_spikes_58(1),
  spike_out_lpf_n => lpf_spikes_58(0)
);

--Ideal cutoff: 32,9816Hz - Real cutoff: 32,9800Hz - Error: 0,0051%
U_BPF_59: spikes_2BPF_fullGain
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"684C",
  SPIKES_DIV_OUT => x"684C",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_58(1),
  spike_in_slpf_n => lpf_spikes_58(0),
  spike_in_shf_p => lpf_spikes_58(1),
  spike_in_shf_n => lpf_spikes_58(0),
  spike_out_p => spikes_out(117),
  spike_out_n => spikes_out(116), 
  spike_out_lpf_p => lpf_spikes_59(1),
  spike_out_lpf_n => lpf_spikes_59(0)
);

--Ideal cutoff: 29,5118Hz - Real cutoff: 29,5106Hz - Error: 0,0042%
U_BPF_60: spikes_2BPF_fullGain
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"7C6F",
  SPIKES_DIV_OUT => x"7C6F",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_59(1),
  spike_in_slpf_n => lpf_spikes_59(0),
  spike_in_shf_p => lpf_spikes_59(1),
  spike_in_shf_n => lpf_spikes_59(0),
  spike_out_p => spikes_out(119),
  spike_out_n => spikes_out(118), 
  spike_out_lpf_p => lpf_spikes_60(1),
  spike_out_lpf_n => lpf_spikes_60(0)
);

--Ideal cutoff: 26,4071Hz - Real cutoff: 26,4053Hz - Error: 0,0068%
U_BPF_61: spikes_2BPF_fullGain
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"03",
  SPIKES_DIV_FB => x"6F57",
  SPIKES_DIV_OUT => x"6F57",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_60(1),
  spike_in_slpf_n => lpf_spikes_60(0),
  spike_in_shf_p => lpf_spikes_60(1),
  spike_in_shf_n => lpf_spikes_60(0),
  spike_out_p => spikes_out(121),
  spike_out_n => spikes_out(120), 
  spike_out_lpf_p => lpf_spikes_61(1),
  spike_out_lpf_n => lpf_spikes_61(0)
);

--Ideal cutoff: 23,6289Hz - Real cutoff: 23,6277Hz - Error: 0,0050%
U_BPF_62: spikes_2BPF_fullGain
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"7C89",
  SPIKES_DIV_OUT => x"7C89",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_61(1),
  spike_in_slpf_n => lpf_spikes_61(0),
  spike_in_shf_p => lpf_spikes_61(1),
  spike_in_shf_n => lpf_spikes_61(0),
  spike_out_p => spikes_out(123),
  spike_out_n => spikes_out(122), 
  spike_out_lpf_p => lpf_spikes_62(1),
  spike_out_lpf_n => lpf_spikes_62(0)
);

--Ideal cutoff: 21,1431Hz - Real cutoff: 21,1420Hz - Error: 0,0050%
U_BPF_63: spikes_2BPF_fullGain
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"04",
  SPIKES_DIV_FB => x"6F6F",
  SPIKES_DIV_OUT => x"6F6F",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_62(1),
  spike_in_slpf_n => lpf_spikes_62(0),
  spike_in_shf_p => lpf_spikes_62(1),
  spike_in_shf_n => lpf_spikes_62(0),
  spike_out_p => spikes_out(125),
  spike_out_n => spikes_out(124), 
  spike_out_lpf_p => lpf_spikes_63(1),
  spike_out_lpf_n => lpf_spikes_63(0)
);

--Ideal cutoff: 18,9187Hz - Real cutoff: 18,9178Hz - Error: 0,0050%
U_BPF_64: spikes_2BPF_fullGain
generic map(GL => 18, SAT => 131071)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV_FB => x"77A7",
  SPIKES_DIV_OUT => x"77A7",
  SPIKES_DIV_BPF => x"02DC",
  spike_in_slpf_p => lpf_spikes_63(1),
  spike_in_slpf_n => lpf_spikes_63(0),
  spike_in_shf_p => lpf_spikes_63(1),
  spike_in_shf_n => lpf_spikes_63(0),
  spike_out_p => spikes_out(127),
  spike_out_n => spikes_out(126), 
  spike_out_lpf_p => lpf_spikes_64(1),
  spike_out_lpf_n => lpf_spikes_64(0)
);

end CFBank_arq;
