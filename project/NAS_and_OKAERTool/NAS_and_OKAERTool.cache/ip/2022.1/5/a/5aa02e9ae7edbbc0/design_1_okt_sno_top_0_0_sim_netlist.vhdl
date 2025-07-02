-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
-- Date        : Wed May 14 10:31:03 2025
-- Host        : us running 64-bit Ubuntu 20.04.6 LTS
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_okt_sno_top_0_0_sim_netlist.vhdl
-- Design      : design_1_okt_sno_top_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a200tfbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno is
  port (
    AER_REQ : out STD_LOGIC;
    rst_n_0 : out STD_LOGIC;
    AER_DATA_OUT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    clock : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    node_ack_n_latch_1 : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno is
  signal \AER_generator.counter[7]_i_3_n_0\ : STD_LOGIC;
  signal \AER_generator.counter_reg\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_r_okt_sno_control_state_reg_n_0_[0]\ : STD_LOGIC;
  signal \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\ : STD_LOGIC;
  signal \FSM_onehot_r_okt_sno_control_state_reg_n_0_[2]\ : STD_LOGIC;
  signal \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\ : STD_LOGIC;
  signal counter : STD_LOGIC;
  signal node_data : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \node_data[7]_i_1_n_0\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \^rst_n_0\ : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \AER_generator.counter[1]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \AER_generator.counter[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \AER_generator.counter[3]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \AER_generator.counter[4]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \AER_generator.counter[6]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \AER_generator.counter[7]_i_2\ : label is "soft_lutpair1";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_onehot_r_okt_sno_control_state_reg[0]\ : label is "idle:0001,req:0010,wait_ack:0100,ack:1000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_r_okt_sno_control_state_reg[1]\ : label is "idle:0001,req:0010,wait_ack:0100,ack:1000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_r_okt_sno_control_state_reg[2]\ : label is "idle:0001,req:0010,wait_ack:0100,ack:1000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_r_okt_sno_control_state_reg[3]\ : label is "idle:0001,req:0010,wait_ack:0100,ack:1000";
  attribute SOFT_HLUTNM of \node_data[0]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \node_data[1]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \node_data[2]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \node_data[3]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \node_data[4]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \node_data[5]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \node_data[6]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \node_data[7]_i_2\ : label is "soft_lutpair6";
begin
  rst_n_0 <= \^rst_n_0\;
\AER_generator.counter[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \AER_generator.counter_reg\(0),
      O => p_0_in(0)
    );
\AER_generator.counter[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \AER_generator.counter_reg\(0),
      I1 => \AER_generator.counter_reg\(1),
      O => p_0_in(1)
    );
\AER_generator.counter[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \AER_generator.counter_reg\(0),
      I1 => \AER_generator.counter_reg\(1),
      I2 => \AER_generator.counter_reg\(2),
      O => p_0_in(2)
    );
\AER_generator.counter[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => \AER_generator.counter_reg\(1),
      I1 => \AER_generator.counter_reg\(0),
      I2 => \AER_generator.counter_reg\(2),
      I3 => \AER_generator.counter_reg\(3),
      O => p_0_in(3)
    );
\AER_generator.counter[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => \AER_generator.counter_reg\(2),
      I1 => \AER_generator.counter_reg\(0),
      I2 => \AER_generator.counter_reg\(1),
      I3 => \AER_generator.counter_reg\(3),
      I4 => \AER_generator.counter_reg\(4),
      O => p_0_in(4)
    );
\AER_generator.counter[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => \AER_generator.counter_reg\(3),
      I1 => \AER_generator.counter_reg\(1),
      I2 => \AER_generator.counter_reg\(0),
      I3 => \AER_generator.counter_reg\(2),
      I4 => \AER_generator.counter_reg\(4),
      I5 => \AER_generator.counter_reg\(5),
      O => p_0_in(5)
    );
\AER_generator.counter[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \AER_generator.counter[7]_i_3_n_0\,
      I1 => \AER_generator.counter_reg\(6),
      O => p_0_in(6)
    );
\AER_generator.counter[7]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\,
      I1 => node_ack_n_latch_1,
      O => counter
    );
\AER_generator.counter[7]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \AER_generator.counter[7]_i_3_n_0\,
      I1 => \AER_generator.counter_reg\(6),
      I2 => \AER_generator.counter_reg\(7),
      O => p_0_in(7)
    );
\AER_generator.counter[7]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000000000000000"
    )
        port map (
      I0 => \AER_generator.counter_reg\(5),
      I1 => \AER_generator.counter_reg\(3),
      I2 => \AER_generator.counter_reg\(1),
      I3 => \AER_generator.counter_reg\(0),
      I4 => \AER_generator.counter_reg\(2),
      I5 => \AER_generator.counter_reg\(4),
      O => \AER_generator.counter[7]_i_3_n_0\
    );
\AER_generator.counter_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(0),
      Q => \AER_generator.counter_reg\(0)
    );
\AER_generator.counter_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(1),
      Q => \AER_generator.counter_reg\(1)
    );
\AER_generator.counter_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(2),
      Q => \AER_generator.counter_reg\(2)
    );
\AER_generator.counter_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(3),
      Q => \AER_generator.counter_reg\(3)
    );
\AER_generator.counter_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(4),
      Q => \AER_generator.counter_reg\(4)
    );
\AER_generator.counter_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(5),
      Q => \AER_generator.counter_reg\(5)
    );
\AER_generator.counter_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(6),
      Q => \AER_generator.counter_reg\(6)
    );
\AER_generator.counter_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => counter,
      CLR => \^rst_n_0\,
      D => p_0_in(7),
      Q => \AER_generator.counter_reg\(7)
    );
\FSM_onehot_r_okt_sno_control_state[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FEFEFEBA"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => node_ack_n_latch_1,
      I2 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[2]\,
      I3 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[0]\,
      I4 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\,
      O => \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0\
    );
\FSM_onehot_r_okt_sno_control_state_reg[0]\: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => clock,
      CE => \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0\,
      D => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\,
      PRE => \^rst_n_0\,
      Q => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[0]\
    );
\FSM_onehot_r_okt_sno_control_state_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clock,
      CE => \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[0]\,
      Q => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\
    );
\FSM_onehot_r_okt_sno_control_state_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clock,
      CE => \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      Q => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[2]\
    );
\FSM_onehot_r_okt_sno_control_state_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clock,
      CE => \FSM_onehot_r_okt_sno_control_state[3]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[2]\,
      Q => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\
    );
\node_data[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(0),
      O => node_data(0)
    );
\node_data[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(1),
      O => node_data(1)
    );
\node_data[2]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(2),
      O => node_data(2)
    );
\node_data[3]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(3),
      O => node_data(3)
    );
\node_data[4]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(4),
      O => node_data(4)
    );
\node_data[5]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(5),
      O => node_data(5)
    );
\node_data[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(6),
      O => node_data(6)
    );
\node_data[7]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\,
      O => \node_data[7]_i_1_n_0\
    );
\node_data[7]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[1]\,
      I1 => \AER_generator.counter_reg\(7),
      O => node_data(7)
    );
\node_data[7]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rst_n,
      O => \^rst_n_0\
    );
\node_data_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(0),
      Q => AER_DATA_OUT(0)
    );
\node_data_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(1),
      Q => AER_DATA_OUT(1)
    );
\node_data_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(2),
      Q => AER_DATA_OUT(2)
    );
\node_data_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(3),
      Q => AER_DATA_OUT(3)
    );
\node_data_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(4),
      Q => AER_DATA_OUT(4)
    );
\node_data_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(5),
      Q => AER_DATA_OUT(5)
    );
\node_data_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(6),
      Q => AER_DATA_OUT(6)
    );
\node_data_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      CLR => \^rst_n_0\,
      D => node_data(7),
      Q => AER_DATA_OUT(7)
    );
node_req_n_reg: unisim.vcomponents.FDPE
     port map (
      C => clock,
      CE => \node_data[7]_i_1_n_0\,
      D => \FSM_onehot_r_okt_sno_control_state_reg_n_0_[3]\,
      PRE => \^rst_n_0\,
      Q => AER_REQ
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno_top is
  port (
    AER_DATA_OUT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    AER_REQ : out STD_LOGIC;
    clock : in STD_LOGIC;
    AER_ACK : in STD_LOGIC;
    rst_n : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno_top;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno_top is
  signal node_ack_n_latch_0 : STD_LOGIC;
  signal node_ack_n_latch_1 : STD_LOGIC;
  signal okt_sno_inst_n_1 : STD_LOGIC;
begin
node_ack_n_latch_0_reg: unisim.vcomponents.FDPE
     port map (
      C => clock,
      CE => '1',
      D => AER_ACK,
      PRE => okt_sno_inst_n_1,
      Q => node_ack_n_latch_0
    );
node_ack_n_latch_1_reg: unisim.vcomponents.FDPE
     port map (
      C => clock,
      CE => '1',
      D => node_ack_n_latch_0,
      PRE => okt_sno_inst_n_1,
      Q => node_ack_n_latch_1
    );
okt_sno_inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno
     port map (
      AER_DATA_OUT(7 downto 0) => AER_DATA_OUT(7 downto 0),
      AER_REQ => AER_REQ,
      clock => clock,
      node_ack_n_latch_1 => node_ack_n_latch_1,
      rst_n => rst_n,
      rst_n_0 => okt_sno_inst_n_1
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    clock : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    AER_DATA_OUT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    AER_REQ : out STD_LOGIC;
    AER_ACK : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_okt_sno_top_0_0,okt_sno_top,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "okt_sno_top,Vivado 2022.1";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clock : signal is "xilinx.com:signal:clock:1.0 clock CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clock : signal is "XIL_INTERFACENAME clock, FREQ_HZ 48000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of rst_n : signal is "xilinx.com:signal:reset:1.0 rst_n RST";
  attribute X_INTERFACE_PARAMETER of rst_n : signal is "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0";
begin
inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_okt_sno_top
     port map (
      AER_ACK => AER_ACK,
      AER_DATA_OUT(7 downto 0) => AER_DATA_OUT(7 downto 0),
      AER_REQ => AER_REQ,
      clock => clock,
      rst_n => rst_n
    );
end STRUCTURE;
