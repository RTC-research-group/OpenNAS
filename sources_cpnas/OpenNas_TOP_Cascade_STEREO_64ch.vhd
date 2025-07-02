--///////////////////////////////////////////////////////////////////////////////
--//                                                                           //
--//    Copyright © 2016  Angel Francisco Jimenez-Fernandez                    //
--//                                                                           //
--//    This file is part of OpenNAS.                                          //
--//                                                                           //
--//    OpenNAS is free software: you can redistribute it and/or modify        //
--//    it under the terms of the GNU General Public License as published by   //
--//    the Free Software Foundation, either version 3 of the License, or      //
--//    (at your option) any later version.                                    //
--//                                                                           //
--//    OpenNAS is distributed in the hope that it will be useful,             //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of         //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the            //
--//    GNU General Public License for more details.                           //
--//                                                                           //
--//    You should have received a copy of the GNU General Public License      //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.        //
--//                                                                           //
--///////////////////////////////////////////////////////////////////////////////


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OpenNas_Cascade_STEREO_64ch is
    Port (
        clock   : in std_logic;
        rst_ext : in std_logic;
        --PDM Interface
        PDM_CLK_LEFT  : out std_logic;
        PDM_DAT_LEFT  : in std_logic;
        PDM_CLK_RIGTH  : out std_logic;
        PDM_DAT_RIGTH  : in std_logic;
        --I2S Bus
        i2s_bclk      : in  STD_LOGIC;
        i2s_d_in: in  STD_LOGIC;
        i2s_lr: in  STD_LOGIC;
        --Spikes Source Selector
        source_sel: in std_logic;
        --AER Output
        AER_DATA_OUT : out STD_LOGIC_VECTOR(15 downto 0);
        AER_REQ      : out STD_LOGIC;
        AER_ACK      : in  STD_LOGIC
    );
end OpenNas_Cascade_STEREO_64ch;

architecture OpenNas_arq of OpenNas_Cascade_STEREO_64ch is

    --PDM interface
    component PDM2Spikes is
        Generic (
            SLPF_GL             : in integer;
            SLPF_SAT            : in integer;
            SHPF_GL             : in integer;
            SHPF_SAT            : in integer
        );
        Port (
            clk                 : in  STD_LOGIC;
            rst                 : in  STD_LOGIC;
            clock_div           : in  STD_LOGIC_VECTOR(7 downto 0);
            --PDM Signals
            PDM_CLK             : out STD_LOGIC;
            PDM_DAT             : in  STD_LOGIC;
            --Anti-Offset SHPF
            SHPF_FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
            --Anti-Aliasing SLPF
            SLPF_FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
            SLPF_SPIKES_DIV_FB  : in  STD_LOGIC_VECTOR(15 downto 0);
            SLPF_SPIKES_DIV_OUT : in  STD_LOGIC_VECTOR(15 downto 0);
            --Spikes Output
            SPIKES_OUT          : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    --I2S interface Stereo
    component i2s_to_spikes_stereo is
        Port (
            clock        : in std_logic;
            reset        : in std_logic;
            --I2S Bus
            i2s_bclk     : in std_logic;
            i2s_d_in     : in std_logic;
            i2s_lr       : in std_logic;
            --Spikes Output
            spikes_left  : out std_logic_vector(1 downto 0);
            spikes_rigth : out std_logic_vector(1 downto 0)
        );
    end component;

    --Spikes Input Source Selector
    component SpikesSource_Selector is
        Port (
            --Source selector jumper
            source_sel  : in std_logic;
            --Spikes input from I2S bus
            i2s_data    : in std_logic_vector(1 downto 0);
            --Spikes input from PDM microph.
            pdm_data    : in std_logic_vector(1 downto 0);
            --Spikes from source selected
            spikes_data : out std_logic_vector(1 downto 0)
        );
    end component;

    --Cascade Filter Bank
    component CFBank_2or_64CH is
        Port (
            clock      : in  std_logic;
            rst        : in  std_logic;
            spikes_in  : in  std_logic_vector(1 downto 0);
            spikes_out : out std_logic_vector(127 downto 0)
        );
    end component;
    
        --Parallel Filter Bank
    component PFBank_64CH is
        Port (
            clock      : in  STD_LOGIC;
            rst        : in  STD_LOGIC;
            spikes_in  : in  STD_LOGIC_VECTOR(1 downto 0);
            spikes_out : out STD_LOGIC_VECTOR(127 downto 0)
        );
    end component;

    --Spikes Distributed Monitor
    component AER_DISTRIBUTED_MONITOR is
        Generic (   
            N_SPIKES       : INTEGER := 128;
            LOG_2_N_SPIKES : INTEGER := 7;
            TAM_AER        : INTEGER := 512;
            IL_AER         : INTEGER := 11
        );
        Port (
            CLK            : in  STD_LOGIC;
            RST            : in  STD_LOGIC;
            SPIKES_IN      : in  STD_LOGIC_VECTOR(N_SPIKES - 1 downto 0);
            AER_DATA_OUT   : out STD_LOGIC_VECTOR(15 downto 0);
            AER_REQ        : out STD_LOGIC;
            AER_ACK        : in  STD_LOGIC);
    end component;

    --Reset signals
    signal reset : std_logic;

    --Audio input modules reset signal
    signal pdm_reset : std_logic;
    signal i2s_reset: std_logic; 

    --Inverted Source selector signal
    signal i_source_sel : std_logic;

    --Audio input modules out spikes signal
    signal spikes_in_left_i2s : std_logic_vector(1 downto 0);
    signal spikes_in_left_pdm : std_logic_vector(1 downto 0);

    --Left spikes
    signal spikes_in_left  : std_logic_vector(1 downto 0);
    signal spikes_out_left : std_logic_vector(127 downto 0);

    --Audio input modules out spikes signal
    signal spikes_in_right_i2s : std_logic_vector(1 downto 0);
    signal spikes_in_right_pdm : std_logic_vector(1 downto 0);

    --Rigth spikes
    signal spikes_in_rigth  : std_logic_vector(1 downto 0);
    signal spikes_out_rigth : std_logic_vector(127 downto 0);

    --Output spikes
    signal spikes_out: std_logic_vector(255 downto 0);


    begin

        reset <= rst_ext;

        --Output spikes connection
        spikes_out <= spikes_out_rigth & spikes_out_left ;

    --Inverted source selector signal
    i_source_sel <= not source_sel;

    --PDM / I2S reset signals
    pdm_reset <= reset and source_sel;
    i2s_reset <= reset and i_source_sel;


        --PDM interface
        --Anti-Offset SHPF
        --Ideal cutoff: 20,0000Hz - Real cutoff: 23,3137Hz - Error: -16,5686%
        --Anti-Aliasing SLPF
    --Ideal cutoff: 8000,0000Hz - Real cutoff: 7999,5176Hz - Error: 0,0060%
    --Ideal Gain: -3,0000dB - Real Gain: -3,000dB (0,501)
        U_PDM2Spikes_Left: PDM2Spikes
        Generic Map (
            SLPF_GL             => 8,
            SLPF_SAT            => 127,
            SHPF_GL             => 17,
            SHPF_SAT            => 65535
        )
        Port Map (
            clk                 => clock,
            rst                 => pdm_reset,
            clock_div           => x"07", --PDM clock: +3,000MHz
            PDM_CLK             => PDM_CLK_LEFT,
            PDM_DAT             => PDM_DAT_LEFT,
            SHPF_FREQ_DIV       => x"04",
            SLPF_FREQ_DIV       => x"06",
            SLPF_SPIKES_DIV_FB  => x"7818",
            SLPF_SPIKES_DIV_OUT => x"3C30",
            --Spikes Output
            spikes_out          => spikes_in_left_pdm
        );

        U_PDM2Spikes_Rigth: PDM2Spikes
        Generic Map (
            SLPF_GL             => 8,
            SLPF_SAT            => 127,
            SHPF_GL             => 17,
            SHPF_SAT            => 65535
        )
        Port Map (
            clk                 => clock,
            rst                 => pdm_reset,
            clock_div           => x"07", --PDM clock: +3,000MHz
            PDM_CLK             => PDM_CLK_RIGTH,
            PDM_DAT             => PDM_DAT_RIGTH,
            SHPF_FREQ_DIV       => x"04",
            SLPF_FREQ_DIV       => x"06",
            SLPF_SPIKES_DIV_FB  => x"7818",
            SLPF_SPIKES_DIV_OUT => x"3C30",
            --Spikes Output
            spikes_out          => spikes_in_right_pdm
        );

        --I2S Stereo
        U_I2S_Stereo: i2s_to_spikes_stereo
        Port Map (
            clock        => clock,
            reset        => i2s_reset,
            --I2S Bus
            i2s_bclk     => i2s_bclk,
            i2s_d_in     => i2s_d_in,
            i2s_lr       => i2s_lr,
            --Spikes Output
            spikes_left  =>spikes_in_left_i2s,
            spikes_rigth => spikes_in_right_i2s
        );
        --Spikes source selector left
        U_SpikesSrcSel_Left: SpikesSource_Selector
        Port Map (
            source_sel  => source_sel,
            i2s_data    => spikes_in_left_i2s,
            pdm_data    => spikes_in_left_pdm,
            spikes_data => spikes_in_left
        );

        --Spikes source selector right
        U_SpikesSrcSel_Right: SpikesSource_Selector
        Port Map(
            source_sel  => source_sel,
            i2s_data    => spikes_in_right_i2s,
            pdm_data    => spikes_in_right_pdm,
            spikes_data => spikes_in_rigth
        );
        --Cascade Filter Bank
        U_CFBank_2or_64CH_Left: CFBank_2or_64CH
        Port Map (
            clock      => clock,
            rst        => reset,
            spikes_in  => spikes_in_left,
            spikes_out => spikes_out_left
        );

        U_PFBank_64CH_Left: PFBank_64CH
        Port Map (
            clock      => clock,
            rst        => reset,
            spikes_in  => spikes_in_left,
            spikes_out => spikes_out_rigth
        );


        --Spikes Distributed Monitor
        U_AER_DISTRIBUTED_MONITOR: AER_DISTRIBUTED_MONITOR
        Generic Map (
            N_SPIKES       =>256,
            LOG_2_N_SPIKES =>8,
            TAM_AER        =>2048,
            IL_AER         =>11
        )
        Port Map (
            CLK            => clock,
            RST            => reset,
            SPIKES_IN      => spikes_out,
            AER_DATA_OUT   => AER_DATA_OUT,
            AER_REQ        => AER_REQ,
            AER_ACK        => AER_ACK
        );

end OpenNas_arq;
