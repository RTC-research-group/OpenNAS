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

entity CFBank_2or_8CH is
    Port (
        clock      : in  std_logic;
        rst        : in  std_logic;
        spikes_in  : in  std_logic_vector(1 downto 0);
        spikes_out : out std_logic_vector(15 downto 0)
    );
end CFBank_2or_8CH;

architecture CFBank_arq of CFBank_2or_8CH is

    signal not_rst: std_logic;
    signal lpf_spikes_0   : std_logic_vector(1 downto 0);
    signal lpf_spikes_1   : std_logic_vector(1 downto 0);
    signal lpf_spikes_2   : std_logic_vector(1 downto 0);
    signal lpf_spikes_3   : std_logic_vector(1 downto 0);
    signal lpf_spikes_4   : std_logic_vector(1 downto 0);
    signal lpf_spikes_5   : std_logic_vector(1 downto 0);
    signal lpf_spikes_6   : std_logic_vector(1 downto 0);
    signal lpf_spikes_7   : std_logic_vector(1 downto 0);
    signal lpf_spikes_8   : std_logic_vector(1 downto 0);

    begin

        not_rst <= not rst;

        --Ideal cutoff: 36279,8110Hz - Real cutoff: 36278,4233Hz - Error: 0,0038%
        U_BPF_0: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 7,
            SAT             => 63
        )
        Port Map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"700A",
            SPIKES_DIV_OUT  => x"700A",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => spikes_in(1),
            spike_in_slpf_n => spikes_in(0),
            spike_in_shf_p  => '0',
            spike_in_shf_n  => '0',
            spike_out_p     => open,
            spike_out_n     => open, 
            spike_out_lpf_p => lpf_spikes_0(1),
            spike_out_lpf_n => lpf_spikes_0(0)
        );

        --Ideal cutoff: 13340,7531Hz - Real cutoff: 13340,2132Hz - Error: 0,0040%
        U_BPF_1: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6DDD",
            SPIKES_DIV_OUT  => x"6DDD",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_0(1),
            spike_in_slpf_n => lpf_spikes_0(0),
            spike_in_shf_p  => lpf_spikes_0(1),
            spike_in_shf_n  => lpf_spikes_0(0),
            spike_out_p     => spikes_out(1),
            spike_out_n     => spikes_out(0), 
            spike_out_lpf_p => lpf_spikes_1(1),
            spike_out_lpf_n => lpf_spikes_1(0)
        );

        --Ideal cutoff: 4905,6400Hz - Real cutoff: 4905,4039Hz - Error: 0,0048%
        U_BPF_2: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7932",
            SPIKES_DIV_OUT  => x"7932",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_1(1),
            spike_in_slpf_n => lpf_spikes_1(0),
            spike_in_shf_p  => lpf_spikes_1(1),
            spike_in_shf_n  => lpf_spikes_1(0),
            spike_out_p     => spikes_out(3),
            spike_out_n     => spikes_out(2), 
            spike_out_lpf_p => lpf_spikes_2(1),
            spike_out_lpf_n => lpf_spikes_2(0)
        );

        --Ideal cutoff: 1803,8940Hz - Real cutoff: 1803,8340Hz - Error: 0,0033%
        U_BPF_3: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"76D8",
            SPIKES_DIV_OUT  => x"76D8",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_2(1),
            spike_in_slpf_n => lpf_spikes_2(0),
            spike_in_shf_p  => lpf_spikes_2(1),
            spike_in_shf_n  => lpf_spikes_2(0),
            spike_out_p     => spikes_out(5),
            spike_out_n     => spikes_out(4), 
            spike_out_lpf_p => lpf_spikes_3(1),
            spike_out_lpf_n => lpf_spikes_3(0)
        );

        --Ideal cutoff: 663,3250Hz - Real cutoff: 663,2873Hz - Error: 0,0057%
        U_BPF_4: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"6D40",
            SPIKES_DIV_OUT  => x"6D40",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_3(1),
            spike_in_slpf_n => lpf_spikes_3(0),
            spike_in_shf_p  => lpf_spikes_3(1),
            spike_in_shf_n  => lpf_spikes_3(0),
            spike_out_p     => spikes_out(7),
            spike_out_n     => spikes_out(6), 
            spike_out_lpf_p => lpf_spikes_4(1),
            spike_out_lpf_n => lpf_spikes_4(0)
        );

        --Ideal cutoff: 243,9168Hz - Real cutoff: 243,8986Hz - Error: 0,0074%
        U_BPF_5: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"606A",
            SPIKES_DIV_OUT  => x"606A",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_4(1),
            spike_in_slpf_n => lpf_spikes_4(0),
            spike_in_shf_p  => lpf_spikes_4(1),
            spike_in_shf_n  => lpf_spikes_4(0),
            spike_out_p     => spikes_out(9),
            spike_out_n     => spikes_out(8), 
            spike_out_lpf_p => lpf_spikes_5(1),
            spike_out_lpf_n => lpf_spikes_5(0)
        );

        --Ideal cutoff: 89,6927Hz - Real cutoff: 89,6877Hz - Error: 0,0055%
        U_BPF_6: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 15,
            SAT             => 16383
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"762E",
            SPIKES_DIV_OUT  => x"762E",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_5(1),
            spike_in_slpf_n => lpf_spikes_5(0),
            spike_in_shf_p  => lpf_spikes_5(1),
            spike_in_shf_n  => lpf_spikes_5(0),
            spike_out_p     => spikes_out(11),
            spike_out_n     => spikes_out(10), 
            spike_out_lpf_p => lpf_spikes_6(1),
            spike_out_lpf_n => lpf_spikes_6(0)
        );

        --Ideal cutoff: 32,9816Hz - Real cutoff: 32,9800Hz - Error: 0,0051%
        U_BPF_7: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 17,
            SAT             => 65535
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"684C",
            SPIKES_DIV_OUT  => x"684C",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_6(1),
            spike_in_slpf_n => lpf_spikes_6(0),
            spike_in_shf_p  => lpf_spikes_6(1),
            spike_in_shf_n  => lpf_spikes_6(0),
            spike_out_p     => spikes_out(13),
            spike_out_n     => spikes_out(12), 
            spike_out_lpf_p => lpf_spikes_7(1),
            spike_out_lpf_n => lpf_spikes_7(0)
        );

        --Ideal cutoff: 12,1280Hz - Real cutoff: 12,1274Hz - Error: 0,0049%
        U_BPF_8: entity work.spikes_2BPF_fullGain
        Generic Map (
            GL              => 18,
            SAT             => 131071
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7FD7",
            SPIKES_DIV_OUT  => x"7FD7",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_7(1),
            spike_in_slpf_n => lpf_spikes_7(0),
            spike_in_shf_p  => lpf_spikes_7(1),
            spike_in_shf_n  => lpf_spikes_7(0),
            spike_out_p     => spikes_out(15),
            spike_out_n     => spikes_out(14), 
            spike_out_lpf_p => lpf_spikes_8(1),
            spike_out_lpf_n => lpf_spikes_8(0)
        );

end CFBank_arq;
