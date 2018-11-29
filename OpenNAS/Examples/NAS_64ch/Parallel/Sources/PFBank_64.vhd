library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PFBank_64CH is
  port(
  clock     : in std_logic;
   rst             : in std_logic;
  spikes_in: in std_logic_vector(1 downto 0);
  spikes_out: out std_logic_vector(127 downto 0)
);
end PFBank_64CH;

architecture PFBank_arq of PFBank_64CH is

  component spikes_BPF_HQ is
  generic (GL: in integer:= 11; SAT: in integer:= 1023);
  Port(CLK: in  STD_LOGIC;
      RST: in  STD_LOGIC;
      FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
      SPIKES_DIV: in STD_LOGIC_VECTOR(15 downto 0);
      SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
      SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);
      spike_in_p: in  STD_LOGIC;
      spike_in_n: in  STD_LOGIC;
      spike_out_p: out  STD_LOGIC;
      spike_out_n: out  STD_LOGIC);
  end component;

  signal not_rst: std_logic;
begin

not_rst <= not rst;

--Ideal cutoff: 22000,0000Hz - Real cutoff: 21998,9010Hz - Error: 0,0050%
U_BPF_0: spikes_BPF_HQ
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5A96",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(1),
  spike_out_n => spikes_out(0) 
);

--Ideal cutoff: 19685,5071Hz - Real cutoff: 19684,8582Hz - Error: 0,0033%
U_BPF_1: spikes_BPF_HQ
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7996",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(3),
  spike_out_n => spikes_out(2) 
);

--Ideal cutoff: 17614,5086Hz - Real cutoff: 17613,6665Hz - Error: 0,0048%
U_BPF_2: spikes_BPF_HQ
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6CCB",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(5),
  spike_out_n => spikes_out(4) 
);

--Ideal cutoff: 15761,3879Hz - Real cutoff: 15760,6615Hz - Error: 0,0046%
U_BPF_3: spikes_BPF_HQ
generic map(GL => 8, SAT => 127)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6159",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(7),
  spike_out_n => spikes_out(6) 
);

--Ideal cutoff: 14103,2233Hz - Real cutoff: 14102,4434Hz - Error: 0,0055%
U_BPF_4: spikes_BPF_HQ
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7424",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(9),
  spike_out_n => spikes_out(8) 
);

--Ideal cutoff: 12619,5047Hz - Real cutoff: 12618,7745Hz - Error: 0,0058%
U_BPF_5: spikes_BPF_HQ
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"67EC",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(11),
  spike_out_n => spikes_out(10) 
);

--Ideal cutoff: 11291,8795Hz - Real cutoff: 11291,1565Hz - Error: 0,0064%
U_BPF_6: spikes_BPF_HQ
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5CFD",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(13),
  spike_out_n => spikes_out(12) 
);

--Ideal cutoff: 10103,9261Hz - Real cutoff: 10103,3044Hz - Error: 0,0062%
U_BPF_7: spikes_BPF_HQ
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7CCF",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(15),
  spike_out_n => spikes_out(14) 
);

--Ideal cutoff: 9040,9504Hz - Real cutoff: 9040,5143Hz - Error: 0,0048%
U_BPF_8: spikes_BPF_HQ
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6FAE",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(17),
  spike_out_n => spikes_out(16) 
);

--Ideal cutoff: 8089,8042Hz - Real cutoff: 8089,3472Hz - Error: 0,0056%
U_BPF_9: spikes_BPF_HQ
generic map(GL => 9, SAT => 255)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"63EE",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(19),
  spike_out_n => spikes_out(18) 
);

--Ideal cutoff: 7238,7227Hz - Real cutoff: 7238,3404Hz - Error: 0,0053%
U_BPF_10: spikes_BPF_HQ
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7739",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(21),
  spike_out_n => spikes_out(20) 
);

--Ideal cutoff: 6477,1785Hz - Real cutoff: 6476,8217Hz - Error: 0,0055%
U_BPF_11: spikes_BPF_HQ
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6AAE",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(23),
  spike_out_n => spikes_out(22) 
);

--Ideal cutoff: 5795,7519Hz - Real cutoff: 5795,4629Hz - Error: 0,0050%
U_BPF_12: spikes_BPF_HQ
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5F75",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(25),
  spike_out_n => spikes_out(24) 
);

--Ideal cutoff: 5186,0143Hz - Real cutoff: 5185,7263Hz - Error: 0,0056%
U_BPF_13: spikes_BPF_HQ
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"556A",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(27),
  spike_out_n => spikes_out(26) 
);

--Ideal cutoff: 4640,4237Hz - Real cutoff: 4640,2598Hz - Error: 0,0035%
U_BPF_14: spikes_BPF_HQ
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"72A5",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(29),
  spike_out_n => spikes_out(28) 
);

--Ideal cutoff: 4152,2316Hz - Real cutoff: 4152,0277Hz - Error: 0,0049%
U_BPF_15: spikes_BPF_HQ
generic map(GL => 10, SAT => 511)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6695",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(31),
  spike_out_n => spikes_out(30) 
);

--Ideal cutoff: 3715,3993Hz - Real cutoff: 3715,2197Hz - Error: 0,0048%
U_BPF_16: spikes_BPF_HQ
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7A63",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(33),
  spike_out_n => spikes_out(32) 
);

--Ideal cutoff: 3324,5236Hz - Real cutoff: 3324,3811Hz - Error: 0,0043%
U_BPF_17: spikes_BPF_HQ
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6D83",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(35),
  spike_out_n => spikes_out(34) 
);

--Ideal cutoff: 2974,7697Hz - Real cutoff: 2974,5711Hz - Error: 0,0067%
U_BPF_18: spikes_BPF_HQ
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"61FD",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(37),
  spike_out_n => spikes_out(36) 
);

--Ideal cutoff: 2661,8113Hz - Real cutoff: 2661,6393Hz - Error: 0,0065%
U_BPF_19: spikes_BPF_HQ
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"57AE",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(39),
  spike_out_n => spikes_out(38) 
);

--Ideal cutoff: 2381,7775Hz - Real cutoff: 2381,6332Hz - Error: 0,0061%
U_BPF_20: spikes_BPF_HQ
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"75AF",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(41),
  spike_out_n => spikes_out(40) 
);

--Ideal cutoff: 2131,2045Hz - Real cutoff: 2131,1139Hz - Error: 0,0043%
U_BPF_21: spikes_BPF_HQ
generic map(GL => 11, SAT => 1023)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"694E",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(43),
  spike_out_n => spikes_out(42) 
);

--Ideal cutoff: 1906,9928Hz - Real cutoff: 1906,8797Hz - Error: 0,0059%
U_BPF_22: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7DA2",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(45),
  spike_out_n => spikes_out(44) 
);

--Ideal cutoff: 1706,3691Hz - Real cutoff: 1706,3022Hz - Error: 0,0039%
U_BPF_23: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"706B",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(47),
  spike_out_n => spikes_out(46) 
);

--Ideal cutoff: 1526,8518Hz - Real cutoff: 1526,7726Hz - Error: 0,0052%
U_BPF_24: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6497",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(49),
  spike_out_n => spikes_out(48) 
);

--Ideal cutoff: 1366,2206Hz - Real cutoff: 1366,1564Hz - Error: 0,0047%
U_BPF_25: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5A02",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(51),
  spike_out_n => spikes_out(50) 
);

--Ideal cutoff: 1222,4884Hz - Real cutoff: 1222,4378Hz - Error: 0,0041%
U_BPF_26: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"78CF",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(53),
  spike_out_n => spikes_out(52) 
);

--Ideal cutoff: 1093,8775Hz - Real cutoff: 1093,8184Hz - Error: 0,0054%
U_BPF_27: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6C19",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(55),
  spike_out_n => spikes_out(54) 
);

--Ideal cutoff: 978,7969Hz - Real cutoff: 978,7566Hz - Error: 0,0041%
U_BPF_28: spikes_BPF_HQ
generic map(GL => 12, SAT => 2047)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"60BA",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(57),
  spike_out_n => spikes_out(56) 
);

--Ideal cutoff: 875,8234Hz - Real cutoff: 875,7702Hz - Error: 0,0061%
U_BPF_29: spikes_BPF_HQ
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7366",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(59),
  spike_out_n => spikes_out(58) 
);

--Ideal cutoff: 783,6830Hz - Real cutoff: 783,6338Hz - Error: 0,0063%
U_BPF_30: spikes_BPF_HQ
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6742",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(61),
  spike_out_n => spikes_out(60) 
);

--Ideal cutoff: 701,2363Hz - Real cutoff: 701,1913Hz - Error: 0,0064%
U_BPF_31: spikes_BPF_HQ
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5C65",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(63),
  spike_out_n => spikes_out(62) 
);

--Ideal cutoff: 627,4633Hz - Real cutoff: 627,4248Hz - Error: 0,0061%
U_BPF_32: spikes_BPF_HQ
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7C03",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(65),
  spike_out_n => spikes_out(64) 
);

--Ideal cutoff: 561,4515Hz - Real cutoff: 561,4155Hz - Error: 0,0064%
U_BPF_33: spikes_BPF_HQ
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6EF7",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(67),
  spike_out_n => spikes_out(66) 
);

--Ideal cutoff: 502,3844Hz - Real cutoff: 502,3628Hz - Error: 0,0043%
U_BPF_34: spikes_BPF_HQ
generic map(GL => 13, SAT => 4095)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"634B",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(69),
  spike_out_n => spikes_out(68) 
);

--Ideal cutoff: 449,5314Hz - Real cutoff: 449,5059Hz - Error: 0,0057%
U_BPF_35: spikes_BPF_HQ
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7676",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(71),
  spike_out_n => spikes_out(70) 
);

--Ideal cutoff: 402,2388Hz - Real cutoff: 402,2223Hz - Error: 0,0041%
U_BPF_36: spikes_BPF_HQ
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6A00",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(73),
  spike_out_n => spikes_out(72) 
);

--Ideal cutoff: 359,9216Hz - Real cutoff: 359,9041Hz - Error: 0,0049%
U_BPF_37: spikes_BPF_HQ
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5ED9",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(75),
  spike_out_n => spikes_out(74) 
);

--Ideal cutoff: 322,0563Hz - Real cutoff: 322,0426Hz - Error: 0,0043%
U_BPF_38: spikes_BPF_HQ
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7F4E",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(77),
  spike_out_n => spikes_out(76) 
);

--Ideal cutoff: 288,1747Hz - Real cutoff: 288,1585Hz - Error: 0,0056%
U_BPF_39: spikes_BPF_HQ
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"71E9",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(79),
  spike_out_n => spikes_out(78) 
);

--Ideal cutoff: 257,8575Hz - Real cutoff: 257,8416Hz - Error: 0,0061%
U_BPF_40: spikes_BPF_HQ
generic map(GL => 14, SAT => 8191)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"65ED",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(81),
  spike_out_n => spikes_out(80) 
);

--Ideal cutoff: 230,7298Hz - Real cutoff: 230,7190Hz - Error: 0,0047%
U_BPF_41: spikes_BPF_HQ
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"799B",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(83),
  spike_out_n => spikes_out(82) 
);

--Ideal cutoff: 206,4560Hz - Real cutoff: 206,4472Hz - Error: 0,0043%
U_BPF_42: spikes_BPF_HQ
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6CD0",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(85),
  spike_out_n => spikes_out(84) 
);

--Ideal cutoff: 184,7360Hz - Real cutoff: 184,7249Hz - Error: 0,0060%
U_BPF_43: spikes_BPF_HQ
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"615D",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(87),
  spike_out_n => spikes_out(86) 
);

--Ideal cutoff: 165,3010Hz - Real cutoff: 165,2927Hz - Error: 0,0050%
U_BPF_44: spikes_BPF_HQ
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"571F",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(89),
  spike_out_n => spikes_out(88) 
);

--Ideal cutoff: 147,9106Hz - Real cutoff: 147,9034Hz - Error: 0,0049%
U_BPF_45: spikes_BPF_HQ
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"74EF",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(91),
  spike_out_n => spikes_out(90) 
);

--Ideal cutoff: 132,3498Hz - Real cutoff: 132,3448Hz - Error: 0,0038%
U_BPF_46: spikes_BPF_HQ
generic map(GL => 15, SAT => 16383)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"68A2",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(93),
  spike_out_n => spikes_out(92) 
);

--Ideal cutoff: 118,4260Hz - Real cutoff: 118,4203Hz - Error: 0,0048%
U_BPF_47: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"7CD5",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(95),
  spike_out_n => spikes_out(94) 
);

--Ideal cutoff: 105,9671Hz - Real cutoff: 105,9621Hz - Error: 0,0048%
U_BPF_48: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6FB3",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(97),
  spike_out_n => spikes_out(96) 
);

--Ideal cutoff: 94,8189Hz - Real cutoff: 94,8119Hz - Error: 0,0075%
U_BPF_49: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"63F2",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(99),
  spike_out_n => spikes_out(98) 
);

--Ideal cutoff: 84,8436Hz - Real cutoff: 84,8363Hz - Error: 0,0085%
U_BPF_50: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"596E",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(101),
  spike_out_n => spikes_out(100) 
);

--Ideal cutoff: 75,9177Hz - Real cutoff: 75,9132Hz - Error: 0,0059%
U_BPF_51: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7809",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(103),
  spike_out_n => spikes_out(102) 
);

--Ideal cutoff: 67,9308Hz - Real cutoff: 67,9264Hz - Error: 0,0065%
U_BPF_52: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6B68",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(105),
  spike_out_n => spikes_out(104) 
);

--Ideal cutoff: 60,7842Hz - Real cutoff: 60,7795Hz - Error: 0,0078%
U_BPF_53: spikes_BPF_HQ
generic map(GL => 16, SAT => 32767)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"601B",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(107),
  spike_out_n => spikes_out(106) 
);

--Ideal cutoff: 54,3894Hz - Real cutoff: 54,3873Hz - Error: 0,0039%
U_BPF_54: spikes_BPF_HQ
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"72AA",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(109),
  spike_out_n => spikes_out(108) 
);

--Ideal cutoff: 48,6674Hz - Real cutoff: 48,6640Hz - Error: 0,0071%
U_BPF_55: spikes_BPF_HQ
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6699",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(111),
  spike_out_n => spikes_out(110) 
);

--Ideal cutoff: 43,5474Hz - Real cutoff: 43,5447Hz - Error: 0,0063%
U_BPF_56: spikes_BPF_HQ
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5BCE",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(113),
  spike_out_n => spikes_out(112) 
);

--Ideal cutoff: 38,9661Hz - Real cutoff: 38,9645Hz - Error: 0,0039%
U_BPF_57: spikes_BPF_HQ
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7B39",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(115),
  spike_out_n => spikes_out(114) 
);

--Ideal cutoff: 34,8667Hz - Real cutoff: 34,8649Hz - Error: 0,0051%
U_BPF_58: spikes_BPF_HQ
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"6E42",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(117),
  spike_out_n => spikes_out(116) 
);

--Ideal cutoff: 31,1985Hz - Real cutoff: 31,1963Hz - Error: 0,0071%
U_BPF_59: spikes_BPF_HQ
generic map(GL => 17, SAT => 65535)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"62A8",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(119),
  spike_out_n => spikes_out(118) 
);

--Ideal cutoff: 27,9163Hz - Real cutoff: 27,9153Hz - Error: 0,0036%
U_BPF_60: spikes_BPF_HQ
generic map(GL => 18, SAT => 131071)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"75B5",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(121),
  spike_out_n => spikes_out(120) 
);

--Ideal cutoff: 24,9794Hz - Real cutoff: 24,9777Hz - Error: 0,0069%
U_BPF_61: spikes_BPF_HQ
generic map(GL => 18, SAT => 131071)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"6952",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(123),
  spike_out_n => spikes_out(122) 
);

--Ideal cutoff: 22,3515Hz - Real cutoff: 22,3504Hz - Error: 0,0047%
U_BPF_62: spikes_BPF_HQ
generic map(GL => 18, SAT => 131071)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"01",
  SPIKES_DIV => x"5E3E",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(125),
  spike_out_n => spikes_out(124) 
);

--Ideal cutoff: 20,0000Hz - Real cutoff: 19,9992Hz - Error: 0,0040%
U_BPF_63: spikes_BPF_HQ
generic map(GL => 18, SAT => 131071)
Port map(CLK => clock,
  RST => not_rst,
  FREQ_DIV => x"02",
  SPIKES_DIV => x"7E7E",
  SPIKES_DIV_FB => x"3FFF",
  SPIKES_DIV_OUT => x"016D",
  spike_in_p => spikes_in(1),
  spike_in_n => spikes_in(0),
  spike_out_p => spikes_out(127),
  spike_out_n => spikes_out(126) 
);

end PFBank_arq;
