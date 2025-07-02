-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
-- Date        : Mon May  5 14:39:06 2025
-- Host        : us running 64-bit Ubuntu 20.04.6 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_OpenNas_Parallel_STE_0_0_stub.vhdl
-- Design      : design_1_OpenNas_Parallel_STE_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
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

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clock,rst_n,pdm_clk_left,pdm_dat_left,pdm_clk_right,pdm_dat_right,i2s_bclk,i2s_d_in,i2s_lr,source_sel,config_data[15:0],config_addr[15:0],config_wren,aer_data_out[7:0],aer_req,aer_ack";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "OpenNas_Parallel_STEREO_64ch,Vivado 2022.1";
begin
end;
