-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
-- Date        : Tue Apr 29 11:25:17 2025
-- Host        : us running 64-bit Ubuntu 20.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_okt_top_0_2_stub.vhdl
-- Design      : design_1_okt_top_0_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    rst : in STD_LOGIC;
    clock : out STD_LOGIC;
    okUH : in STD_LOGIC_VECTOR ( 4 downto 0 );
    okHU : out STD_LOGIC_VECTOR ( 2 downto 0 );
    okUHU : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    okAA : inout STD_LOGIC;
    rome_a_data : in STD_LOGIC_VECTOR ( 15 downto 0 );
    rome_a_req_n : in STD_LOGIC;
    rome_a_ack_n : out STD_LOGIC;
    rome_b_data : in STD_LOGIC_VECTOR ( 15 downto 0 );
    rome_b_req_n : in STD_LOGIC;
    rome_b_ack_n : out STD_LOGIC;
    node_data : in STD_LOGIC_VECTOR ( 27 downto 0 );
    node_req_n : in STD_LOGIC;
    node_out_ack_n : out STD_LOGIC;
    out_data : out STD_LOGIC_VECTOR ( 27 downto 0 );
    out_req_n : out STD_LOGIC;
    out_ack_n : in STD_LOGIC;
    config_data : out STD_LOGIC_VECTOR ( 15 downto 0 );
    config_addr : out STD_LOGIC_VECTOR ( 15 downto 0 );
    config_en : out STD_LOGIC_VECTOR ( 1 downto 0 );
    leds : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,clock,okUH[4:0],okHU[2:0],okUHU[31:0],okAA,rome_a_data[15:0],rome_a_req_n,rome_a_ack_n,rome_b_data[15:0],rome_b_req_n,rome_b_ack_n,node_data[27:0],node_req_n,node_out_ack_n,out_data[27:0],out_req_n,out_ack_n,config_data[15:0],config_addr[15:0],config_en[1:0],leds[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "okt_top,Vivado 2022.1";
begin
end;
