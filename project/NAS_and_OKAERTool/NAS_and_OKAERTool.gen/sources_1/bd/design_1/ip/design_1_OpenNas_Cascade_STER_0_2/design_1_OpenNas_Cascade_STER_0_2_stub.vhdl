-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
-- Date        : Wed May  7 09:42:34 2025
-- Host        : us running 64-bit Ubuntu 20.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/arios/Projects/OpenNAS/created_projects/project/NAS_and_OKAERTool/NAS_and_OKAERTool.gen/sources_1/bd/design_1/ip/design_1_OpenNas_Cascade_STER_0_2/design_1_OpenNas_Cascade_STER_0_2_stub.vhdl
-- Design      : design_1_OpenNas_Cascade_STER_0_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_OpenNas_Cascade_STER_0_2 is
  Port ( 
    clock : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    pdm_clk_left : out STD_LOGIC;
    pdm_dat_left : in STD_LOGIC;
    pdm_clk_right : out STD_LOGIC;
    pdm_dat_right : in STD_LOGIC;
    i2s_bclk : in STD_LOGIC;
    i2s_d_in : in STD_LOGIC;
    i2s_lr : in STD_LOGIC;
    source_sel : in STD_LOGIC;
    config_data : in STD_LOGIC_VECTOR ( 15 downto 0 );
    config_addr : in STD_LOGIC_VECTOR ( 15 downto 0 );
    config_wren : in STD_LOGIC;
    aer_data_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    aer_req : out STD_LOGIC;
    aer_ack : in STD_LOGIC
  );

end design_1_OpenNas_Cascade_STER_0_2;

architecture stub of design_1_OpenNas_Cascade_STER_0_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clock,rst_n,pdm_clk_left,pdm_dat_left,pdm_clk_right,pdm_dat_right,i2s_bclk,i2s_d_in,i2s_lr,source_sel,config_data[15:0],config_addr[15:0],config_wren,aer_data_out[7:0],aer_req,aer_ack";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "OpenNas_Cascade_STEREO_64ch,Vivado 2022.1";
begin
end;
