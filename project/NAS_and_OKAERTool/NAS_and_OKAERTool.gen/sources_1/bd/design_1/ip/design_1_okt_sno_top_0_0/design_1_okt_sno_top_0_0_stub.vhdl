-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
-- Date        : Wed May 14 10:31:03 2025
-- Host        : us running 64-bit Ubuntu 20.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/arios/Projects/OpenNAS/created_projects/project/NAS_and_OKAERTool/NAS_and_OKAERTool.gen/sources_1/bd/design_1/ip/design_1_okt_sno_top_0_0/design_1_okt_sno_top_0_0_stub.vhdl
-- Design      : design_1_okt_sno_top_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_okt_sno_top_0_0 is
  Port ( 
    clock : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    AER_DATA_OUT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    AER_REQ : out STD_LOGIC;
    AER_ACK : in STD_LOGIC
  );

end design_1_okt_sno_top_0_0;

architecture stub of design_1_okt_sno_top_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clock,rst_n,AER_DATA_OUT[7:0],AER_REQ,AER_ACK";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "okt_sno_top,Vivado 2022.1";
begin
end;
