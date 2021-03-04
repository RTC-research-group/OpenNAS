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
use work.OpenNas_top_pkg.all;

entity OpenNas_Cascade_STEREO_8ch is
	Port(
		clock        : in  std_logic;
		rst_ext      : in  std_logic;
		--I2S Bus
		i2s_bclk     : in  std_logic;
		i2s_d_in     : in  std_logic;
		i2s_lr       : in  std_logic;
		--Config Bus
		config_data  : in  std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		config_addr  : in  std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		config_wren  : in  std_logic;
		--AER Output
		aer_data_out : out std_logic_vector(AER_DATA_BUS_BIT_WIDTH - 1 downto 0);
		aer_req      : out std_logic;
		aer_ack      : in  std_logic
	);
end OpenNas_Cascade_STEREO_8ch;

architecture OpenNas_arq of OpenNas_Cascade_STEREO_8ch is

	--Reset signals
	signal reset : std_logic;

	--Left spikes
	signal spikes_in_left  : std_logic_vector(SPIKE_BUS_BIT_WIDTH - 1 downto 0);
	signal spikes_out_left : std_logic_vector(AER_DATA_BUS_BIT_WIDTH - 1 downto 0);

	--Rigth spikes
	signal spikes_in_rigth  : std_logic_vector(SPIKE_BUS_BIT_WIDTH - 1 downto 0);
	signal spikes_out_rigth : std_logic_vector(AER_DATA_BUS_BIT_WIDTH - 1 downto 0);

	--Output spikes
	signal spikes_out : std_logic_vector((AER_DATA_BUS_BIT_WIDTH * 2) - 1 downto 0);

begin

	reset <= rst_ext;

	--Output spikes connection
	spikes_out <= spikes_out_rigth & spikes_out_left;

	--I2S Stereo
	U_I2S_Stereo : entity work.i2s_to_spikes_stereo
		generic map(
			CONFIG_ADDRESS => 16#0000#,
			CONFIG_OFFSET  => 0
		)
		Port Map(
			clock        => clock,
			reset        => reset,
			--I2S Bus
			i2s_bclk     => i2s_bclk,
			i2s_d_in     => i2s_d_in,
			i2s_lr       => i2s_lr,
			-- Config Bus
			config_data  => config_data,
			config_addr  => config_addr,
			config_wren  => config_wren,
			--Spikes Output
			spikes_left  => spikes_in_left,
			spikes_rigth => spikes_in_rigth
		);

	--Cascade Filter Bank
	U_CFBank_2or_8CH_Left : entity work.CFBank_2or_8CH
		Port Map(
			clock      => clock,
			rst        => reset,
			spikes_in  => spikes_in_left,
			spikes_out => spikes_out_left
		);

	U_CFBank_2or_8CH_Rigth : entity work.CFBank_2or_8CH
		Port Map(
			clock      => clock,
			rst        => reset,
			spikes_in  => spikes_in_rigth,
			spikes_out => spikes_out_rigth
		);

	--Spikes Distributed Monitor
	U_AER_DISTRIBUTED_MONITOR : entity work.AER_DISTRIBUTED_MONITOR
		Generic Map(
			N_SPIKES       => 32,
			LOG_2_N_SPIKES => 5,
			TAM_AER        => 2048,
			IL_AER         => 11
		)
		Port Map(
			CLK          => clock,
			RST          => reset,
			SPIKES_IN    => spikes_out,
			AER_DATA_OUT => aer_data_out,
			AER_REQ      => aer_req,
			AER_ACK      => aer_ack
		);

end OpenNas_arq;
