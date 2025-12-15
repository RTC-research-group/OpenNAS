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
        --I2S Bus
        i2s_bclk      : in  STD_LOGIC;
        i2s_d_in: in  STD_LOGIC;
        i2s_lr: in  STD_LOGIC;
        --AER Output
        AER_DATA_OUT : out STD_LOGIC_VECTOR(15 downto 0);
        AER_REQ      : out STD_LOGIC;
        AER_ACK      : in  STD_LOGIC
    );
end OpenNas_Cascade_STEREO_64ch;

architecture OpenNas_arq of OpenNas_Cascade_STEREO_64ch is

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

    --Cascade Filter Bank
    component CFBank_2or_64CH is
        Port (
            clock      : in  std_logic;
            rst        : in  std_logic;
            spikes_in  : in  std_logic_vector(1 downto 0);
            spikes_out : out std_logic_vector(127 downto 0)
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

    --Left spikes
    signal spikes_in_left  : std_logic_vector(1 downto 0);
    signal spikes_out_left : std_logic_vector(127 downto 0);

    --Rigth spikes
    signal spikes_in_rigth  : std_logic_vector(1 downto 0);
    signal spikes_out_rigth : std_logic_vector(127 downto 0);

    --Output spikes
    signal spikes_out: std_logic_vector(255 downto 0);


    begin

        reset <= rst_ext;

        --Output spikes connection
        spikes_out <= spikes_out_rigth & spikes_out_left ;

        --I2S Stereo
        U_I2S_Stereo: i2s_to_spikes_stereo
        Port Map (
            clock        => clock,
            reset        => reset,
            --I2S Bus
            i2s_bclk     => i2s_bclk,
            i2s_d_in     => i2s_d_in,
            i2s_lr       => i2s_lr,
            --Spikes Output
            spikes_left  => spikes_in_left,
            spikes_rigth => spikes_in_rigth
        );

        --Cascade Filter Bank
        U_CFBank_2or_64CH_Left: CFBank_2or_64CH
        Port Map (
            clock      => clock,
            rst        => reset,
            spikes_in  => spikes_in_left,
            spikes_out => spikes_out_left
        );

        U_CFBank_2or_64CH_Rigth: CFBank_2or_64CH
        Port Map (
            clock      => clock,
            rst        => reset,
            spikes_in  => spikes_in_rigth,
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
