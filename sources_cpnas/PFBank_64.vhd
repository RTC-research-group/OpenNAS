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

entity PFBank_64CH is
    Port (
        clock      : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        spikes_in  : in  STD_LOGIC_VECTOR(1 downto 0);
        spikes_out : out STD_LOGIC_VECTOR(127 downto 0)
    );
end PFBank_64CH;

architecture PFBank_arq of PFBank_64CH is

    component spikes_BPF_HQ is
        Generic (
            GL             : INTEGER := 11;
            SAT            : INTEGER := 1023
        );
        Port (
            CLK            : in  STD_LOGIC;
            RST            : in  STD_LOGIC;
            FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);
            SPIKES_DIV     : in  STD_LOGIC_VECTOR(15 downto 0);
            SPIKES_DIV_FB  : in  STD_LOGIC_VECTOR(15 downto 0);
            SPIKES_DIV_OUT : in  STD_LOGIC_VECTOR(15 downto 0);
            spike_in_p     : in  STD_LOGIC;
            spike_in_n     : in  STD_LOGIC;
            spike_out_p    : out STD_LOGIC;
            spike_out_n    : out STD_LOGIC
        );
    end component;

    signal not_rst: std_logic;

    signal QFactor: std_logic_vector(15 downto 0) := x"7FFF";
--    signal QFactor: std_logic_vector(15 downto 0) := x"3FFF";

    begin

        not_rst <= not rst;

        --Ideal cutoff: 22000,0000Hz - Real cutoff: 21998,6733Hz - Error: 0,0060%
        U_BPF_0: spikes_BPF_HQ
        Generic Map (
            GL             => 9,
            SAT            => 255
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5E5C",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(1),
            spike_out_n    => spikes_out(0) 
        );

        --Ideal cutoff: 19685,5071Hz - Real cutoff: 19683,6945Hz - Error: 0,0092%
        U_BPF_1: spikes_BPF_HQ
        Generic Map (
            GL             => 9,
            SAT            => 255
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"546E",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(3),
            spike_out_n    => spikes_out(2) 
        );

        --Ideal cutoff: 17614,5086Hz - Real cutoff: 17612,7811Hz - Error: 0,0098%
        U_BPF_2: spikes_BPF_HQ
        Generic Map (
            GL             => 9,
            SAT            => 255
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4B8C",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(5),
            spike_out_n    => spikes_out(4) 
        );

        --Ideal cutoff: 15761,3879Hz - Real cutoff: 15760,4338Hz - Error: 0,0061%
        U_BPF_3: spikes_BPF_HQ
        Generic Map (
            GL             => 9,
            SAT            => 255
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"439A",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(7),
            spike_out_n    => spikes_out(6) 
        );

        --Ideal cutoff: 14103,2233Hz - Real cutoff: 14102,5193Hz - Error: 0,0050%
        U_BPF_4: spikes_BPF_HQ
        Generic Map (
            GL             => 10,
            SAT            => 511
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"78FB",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(9),
            spike_out_n    => spikes_out(8) 
        );

        --Ideal cutoff: 12619,5047Hz - Real cutoff: 12619,0022Hz - Error: 0,0040%
        U_BPF_5: spikes_BPF_HQ
        Generic Map (
            GL             => 10,
            SAT            => 511
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6C41",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(11),
            spike_out_n    => spikes_out(10) 
        );

        --Ideal cutoff: 11291,8795Hz - Real cutoff: 11291,2134Hz - Error: 0,0059%
        U_BPF_6: spikes_BPF_HQ
        Generic Map (
            GL             => 10,
            SAT            => 511
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"60DD",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(13),
            spike_out_n    => spikes_out(12) 
        );

        --Ideal cutoff: 10103,9261Hz - Real cutoff: 10103,2158Hz - Error: 0,0070%
        U_BPF_7: spikes_BPF_HQ
        Generic Map (
            GL             => 10,
            SAT            => 511
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"56AC",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(15),
            spike_out_n    => spikes_out(14) 
        );

        --Ideal cutoff: 9040,9504Hz - Real cutoff: 9040,4384Hz - Error: 0,0057%
        U_BPF_8: spikes_BPF_HQ
        Generic Map (
            GL             => 10,
            SAT            => 511
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4D8E",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(17),
            spike_out_n    => spikes_out(16) 
        );

        --Ideal cutoff: 8089,8042Hz - Real cutoff: 8089,2207Hz - Error: 0,0072%
        U_BPF_9: spikes_BPF_HQ
        Generic Map (
            GL             => 10,
            SAT            => 511
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4565",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(19),
            spike_out_n    => spikes_out(18) 
        );

        --Ideal cutoff: 7238,7227Hz - Real cutoff: 7238,4068Hz - Error: 0,0044%
        U_BPF_10: spikes_BPF_HQ
        Generic Map (
            GL             => 11,
            SAT            => 1023
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7C31",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(21),
            spike_out_n    => spikes_out(20) 
        );

        --Ideal cutoff: 6477,1785Hz - Real cutoff: 6476,8407Hz - Error: 0,0052%
        U_BPF_11: spikes_BPF_HQ
        Generic Map (
            GL             => 11,
            SAT            => 1023
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6F20",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(23),
            spike_out_n    => spikes_out(22) 
        );

        --Ideal cutoff: 5795,7519Hz - Real cutoff: 5795,4155Hz - Error: 0,0058%
        U_BPF_12: spikes_BPF_HQ
        Generic Map (
            GL             => 11,
            SAT            => 1023
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"636F",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(25),
            spike_out_n    => spikes_out(24) 
        );

        --Ideal cutoff: 5186,0143Hz - Real cutoff: 5185,7073Hz - Error: 0,0059%
        U_BPF_13: spikes_BPF_HQ
        Generic Map (
            GL             => 11,
            SAT            => 1023
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"58F9",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(27),
            spike_out_n    => spikes_out(26) 
        );

        --Ideal cutoff: 4640,4237Hz - Real cutoff: 4639,9752Hz - Error: 0,0097%
        U_BPF_14: spikes_BPF_HQ
        Generic Map (
            GL             => 11,
            SAT            => 1023
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4F9C",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(29),
            spike_out_n    => spikes_out(28) 
        );

        --Ideal cutoff: 4152,2316Hz - Real cutoff: 4151,8443Hz - Error: 0,0093%
        U_BPF_15: spikes_BPF_HQ
        Generic Map (
            GL             => 11,
            SAT            => 1023
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"473C",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(31),
            spike_out_n    => spikes_out(30) 
        );

        --Ideal cutoff: 3715,3993Hz - Real cutoff: 3715,2814Hz - Error: 0,0032%
        U_BPF_16: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7F7D",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(33),
            spike_out_n    => spikes_out(32) 
        );

        --Ideal cutoff: 3324,5236Hz - Real cutoff: 3324,3669Hz - Error: 0,0047%
        U_BPF_17: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7213",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(35),
            spike_out_n    => spikes_out(34) 
        );

        --Ideal cutoff: 2974,7697Hz - Real cutoff: 2974,5474Hz - Error: 0,0075%
        U_BPF_18: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6612",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(37),
            spike_out_n    => spikes_out(36) 
        );

        --Ideal cutoff: 2661,8113Hz - Real cutoff: 2661,6109Hz - Error: 0,0075%
        U_BPF_19: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5B55",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(39),
            spike_out_n    => spikes_out(38) 
        );

        --Ideal cutoff: 2381,7775Hz - Real cutoff: 2381,5731Hz - Error: 0,0086%
        U_BPF_20: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"51B9",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(41),
            spike_out_n    => spikes_out(40) 
        );

        --Ideal cutoff: 2131,2045Hz - Real cutoff: 2131,0190Hz - Error: 0,0087%
        U_BPF_21: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4920",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(43),
            spike_out_n    => spikes_out(42) 
        );

        --Ideal cutoff: 1906,9928Hz - Real cutoff: 1906,8750Hz - Error: 0,0062%
        U_BPF_22: spikes_BPF_HQ
        Generic Map (
            GL             => 12,
            SAT            => 2047
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"416F",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(45),
            spike_out_n    => spikes_out(44) 
        );

        --Ideal cutoff: 1706,3691Hz - Real cutoff: 1706,2951Hz - Error: 0,0043%
        U_BPF_23: spikes_BPF_HQ
        Generic Map (
            GL             => 13,
            SAT            => 4095
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"751A",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(47),
            spike_out_n    => spikes_out(46) 
        );

        --Ideal cutoff: 1526,8518Hz - Real cutoff: 1526,7750Hz - Error: 0,0050%
        U_BPF_24: spikes_BPF_HQ
        Generic Map (
            GL             => 13,
            SAT            => 4095
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"68C8",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(49),
            spike_out_n    => spikes_out(48) 
        );

        --Ideal cutoff: 1366,2206Hz - Real cutoff: 1366,1517Hz - Error: 0,0050%
        U_BPF_25: spikes_BPF_HQ
        Generic Map (
            GL             => 13,
            SAT            => 4095
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5DC2",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(51),
            spike_out_n    => spikes_out(50) 
        );

        --Ideal cutoff: 1222,4884Hz - Real cutoff: 1222,3762Hz - Error: 0,0092%
        U_BPF_26: spikes_BPF_HQ
        Generic Map (
            GL             => 13,
            SAT            => 4095
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"53E4",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(53),
            spike_out_n    => spikes_out(52) 
        );

        --Ideal cutoff: 1093,8775Hz - Real cutoff: 1093,7979Hz - Error: 0,0073%
        U_BPF_27: spikes_BPF_HQ
        Generic Map (
            GL             => 13,
            SAT            => 4095
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4B11",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(55),
            spike_out_n    => spikes_out(54) 
        );

        --Ideal cutoff: 978,7969Hz - Real cutoff: 978,7092Hz - Error: 0,0090%
        U_BPF_28: spikes_BPF_HQ
        Generic Map (
            GL             => 13,
            SAT            => 4095
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"432B",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(57),
            spike_out_n    => spikes_out(56) 
        );

        --Ideal cutoff: 875,8234Hz - Real cutoff: 875,7725Hz - Error: 0,0058%
        U_BPF_29: spikes_BPF_HQ
        Generic Map (
            GL             => 14,
            SAT            => 8191
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7835",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(59),
            spike_out_n    => spikes_out(58) 
        );

        --Ideal cutoff: 783,6830Hz - Real cutoff: 783,6504Hz - Error: 0,0042%
        U_BPF_30: spikes_BPF_HQ
        Generic Map (
            GL             => 14,
            SAT            => 8191
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6B90",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(61),
            spike_out_n    => spikes_out(60) 
        );

        --Ideal cutoff: 701,2363Hz - Real cutoff: 701,2043Hz - Error: 0,0046%
        U_BPF_31: spikes_BPF_HQ
        Generic Map (
            GL             => 14,
            SAT            => 8191
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"603F",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(63),
            spike_out_n    => spikes_out(62) 
        );

        --Ideal cutoff: 627,4633Hz - Real cutoff: 627,4098Hz - Error: 0,0085%
        U_BPF_32: spikes_BPF_HQ
        Generic Map (
            GL             => 14,
            SAT            => 8191
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"561E",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(65),
            spike_out_n    => spikes_out(64) 
        );

        --Ideal cutoff: 561,4515Hz - Real cutoff: 561,4131Hz - Error: 0,0068%
        U_BPF_33: spikes_BPF_HQ
        Generic Map (
            GL             => 14,
            SAT            => 8191
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4D0F",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(67),
            spike_out_n    => spikes_out(66) 
        );

        --Ideal cutoff: 502,3844Hz - Real cutoff: 502,3320Hz - Error: 0,0104%
        U_BPF_34: spikes_BPF_HQ
        Generic Map (
            GL             => 14,
            SAT            => 8191
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"44F3",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(69),
            spike_out_n    => spikes_out(68) 
        );

        --Ideal cutoff: 449,5314Hz - Real cutoff: 449,5118Hz - Error: 0,0044%
        U_BPF_35: spikes_BPF_HQ
        Generic Map (
            GL             => 15,
            SAT            => 16383
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7B66",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(71),
            spike_out_n    => spikes_out(70) 
        );

        --Ideal cutoff: 402,2388Hz - Real cutoff: 402,2128Hz - Error: 0,0065%
        U_BPF_36: spikes_BPF_HQ
        Generic Map (
            GL             => 15,
            SAT            => 16383
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6E6A",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(73),
            spike_out_n    => spikes_out(72) 
        );

        --Ideal cutoff: 359,9216Hz - Real cutoff: 359,8941Hz - Error: 0,0077%
        U_BPF_37: spikes_BPF_HQ
        Generic Map (
            GL             => 15,
            SAT            => 16383
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"62CC",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(75),
            spike_out_n    => spikes_out(74) 
        );

        --Ideal cutoff: 322,0563Hz - Real cutoff: 322,0292Hz - Error: 0,0084%
        U_BPF_38: spikes_BPF_HQ
        Generic Map (
            GL             => 15,
            SAT            => 16383
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5867",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(77),
            spike_out_n    => spikes_out(76) 
        );

        --Ideal cutoff: 288,1747Hz - Real cutoff: 288,1486Hz - Error: 0,0090%
        U_BPF_39: spikes_BPF_HQ
        Generic Map (
            GL             => 15,
            SAT            => 16383
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4F1A",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(79),
            spike_out_n    => spikes_out(78) 
        );

        --Ideal cutoff: 257,8575Hz - Real cutoff: 257,8396Hz - Error: 0,0069%
        U_BPF_40: spikes_BPF_HQ
        Generic Map (
            GL             => 15,
            SAT            => 16383
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"46C8",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(81),
            spike_out_n    => spikes_out(80) 
        );

        --Ideal cutoff: 230,7298Hz - Real cutoff: 230,7181Hz - Error: 0,0051%
        U_BPF_41: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7EAC",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(83),
            spike_out_n    => spikes_out(82) 
        );

        --Ideal cutoff: 206,4560Hz - Real cutoff: 206,4425Hz - Error: 0,0066%
        U_BPF_42: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7158",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(85),
            spike_out_n    => spikes_out(84) 
        );

        --Ideal cutoff: 184,7360Hz - Real cutoff: 184,7282Hz - Error: 0,0042%
        U_BPF_43: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"656C",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(87),
            spike_out_n    => spikes_out(86) 
        );

        --Ideal cutoff: 165,3010Hz - Real cutoff: 165,2906Hz - Error: 0,0063%
        U_BPF_44: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5AC0",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(89),
            spike_out_n    => spikes_out(88) 
        );

        --Ideal cutoff: 147,9106Hz - Real cutoff: 147,9021Hz - Error: 0,0058%
        U_BPF_45: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5134",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(91),
            spike_out_n    => spikes_out(90) 
        );

        --Ideal cutoff: 132,3498Hz - Real cutoff: 132,3420Hz - Error: 0,0059%
        U_BPF_46: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"48A9",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(93),
            spike_out_n    => spikes_out(92) 
        );

        --Ideal cutoff: 118,4260Hz - Real cutoff: 118,4184Hz - Error: 0,0064%
        U_BPF_47: spikes_BPF_HQ
        Generic Map (
            GL             => 16,
            SAT            => 32767
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4104",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(95),
            spike_out_n    => spikes_out(94) 
        );

        --Ideal cutoff: 105,9671Hz - Real cutoff: 105,9604Hz - Error: 0,0063%
        U_BPF_48: spikes_BPF_HQ
        Generic Map (
            GL             => 17,
            SAT            => 65535
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"745A",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(97),
            spike_out_n    => spikes_out(96) 
        );

        --Ideal cutoff: 94,8189Hz - Real cutoff: 94,8151Hz - Error: 0,0040%
        U_BPF_49: spikes_BPF_HQ
        Generic Map (
            GL             => 17,
            SAT            => 65535
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"681D",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(99),
            spike_out_n    => spikes_out(98) 
        );

        --Ideal cutoff: 84,8436Hz - Real cutoff: 84,8366Hz - Error: 0,0082%
        U_BPF_50: spikes_BPF_HQ
        Generic Map (
            GL             => 17,
            SAT            => 65535
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5D28",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(101),
            spike_out_n    => spikes_out(100) 
        );

        --Ideal cutoff: 75,9177Hz - Real cutoff: 75,9111Hz - Error: 0,0086%
        U_BPF_51: spikes_BPF_HQ
        Generic Map (
            GL             => 17,
            SAT            => 65535
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"535B",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(103),
            spike_out_n    => spikes_out(102) 
        );

        --Ideal cutoff: 67,9308Hz - Real cutoff: 67,9248Hz - Error: 0,0088%
        U_BPF_52: spikes_BPF_HQ
        Generic Map (
            GL             => 17,
            SAT            => 65535
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4A96",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(105),
            spike_out_n    => spikes_out(104) 
        );

        --Ideal cutoff: 60,7842Hz - Real cutoff: 60,7780Hz - Error: 0,0102%
        U_BPF_53: spikes_BPF_HQ
        Generic Map (
            GL             => 17,
            SAT            => 65535
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"42BD",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(107),
            spike_out_n    => spikes_out(106) 
        );

        --Ideal cutoff: 54,3894Hz - Real cutoff: 54,3872Hz - Error: 0,0042%
        U_BPF_54: spikes_BPF_HQ
        Generic Map (
            GL             => 18,
            SAT            => 131071
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7771",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(109),
            spike_out_n    => spikes_out(108) 
        );

        --Ideal cutoff: 48,6674Hz - Real cutoff: 48,6651Hz - Error: 0,0048%
        U_BPF_55: spikes_BPF_HQ
        Generic Map (
            GL             => 18,
            SAT            => 131071
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6AE0",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(111),
            spike_out_n    => spikes_out(110) 
        );

        --Ideal cutoff: 43,5474Hz - Real cutoff: 43,5442Hz - Error: 0,0073%
        U_BPF_56: spikes_BPF_HQ
        Generic Map (
            GL             => 18,
            SAT            => 131071
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5FA1",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(113),
            spike_out_n    => spikes_out(112) 
        );

        --Ideal cutoff: 38,9661Hz - Real cutoff: 38,9641Hz - Error: 0,0050%
        U_BPF_57: spikes_BPF_HQ
        Generic Map (
            GL             => 18,
            SAT            => 131071
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"5592",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(115),
            spike_out_n    => spikes_out(114) 
        );

        --Ideal cutoff: 34,8667Hz - Real cutoff: 34,8642Hz - Error: 0,0071%
        U_BPF_58: spikes_BPF_HQ
        Generic Map (
            GL             => 18,
            SAT            => 131071
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4C91",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(117),
            spike_out_n    => spikes_out(116) 
        );

        --Ideal cutoff: 31,1985Hz - Real cutoff: 31,1965Hz - Error: 0,0064%
        U_BPF_59: spikes_BPF_HQ
        Generic Map (
            GL             => 18,
            SAT            => 131071
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"4483",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(119),
            spike_out_n    => spikes_out(118) 
        );

        --Ideal cutoff: 27,9163Hz - Real cutoff: 27,9148Hz - Error: 0,0053%
        U_BPF_60: spikes_BPF_HQ
        Generic Map (
            GL             => 19,
            SAT            => 262143
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"7A9C",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(121),
            spike_out_n    => spikes_out(120) 
        );

        --Ideal cutoff: 24,9794Hz - Real cutoff: 24,9782Hz - Error: 0,0048%
        U_BPF_61: spikes_BPF_HQ
        Generic Map (
            GL             => 19,
            SAT            => 262143
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"6DB6",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(123),
            spike_out_n    => spikes_out(122) 
        );

        --Ideal cutoff: 22,3515Hz - Real cutoff: 22,3502Hz - Error: 0,0057%
        U_BPF_62: spikes_BPF_HQ
        Generic Map (
            GL             => 19,
            SAT            => 262143
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"622B",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(125),
            spike_out_n    => spikes_out(124) 
        );

        --Ideal cutoff: 20,0000Hz - Real cutoff: 19,9988Hz - Error: 0,0062%
        U_BPF_63: spikes_BPF_HQ
        Generic Map (
            GL             => 19,
            SAT            => 262143
        )
        Port Map (
            CLK            => clock,
            RST            => not_rst,
            FREQ_DIV       => x"00",
            SPIKES_DIV     => x"57D7",
            SPIKES_DIV_FB  => QFactor,
            SPIKES_DIV_OUT => x"1012",
            spike_in_p     => spikes_in(1),
            spike_in_n     => spikes_in(0),
            spike_out_p    => spikes_out(127),
            spike_out_n    => spikes_out(126) 
        );

end PFBank_arq;
