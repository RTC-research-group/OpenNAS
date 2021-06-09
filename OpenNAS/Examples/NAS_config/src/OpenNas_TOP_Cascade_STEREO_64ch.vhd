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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- @suppress "Deprecated package"
use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"
use work.OpenNas_top_pkg.all;

entity OpenNas_Cascade_STEREO_64ch is
	Port(
		clock         : in  std_logic;
		rst_ext_n     : in  std_logic;
		--PDM Interface
		pdm_clk_left  : out std_logic;
		pdm_dat_lef   : in  std_logic;
		pdm_clk_right : out std_logic;
		pdm_dat_right : in  std_logic;
		--I2S Bus
		i2s_bclk      : in  STD_LOGIC;
		i2s_d_in      : in  STD_LOGIC;
		i2s_lr        : in  STD_LOGIC;
		--Config Bus
		config_data   : in  std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		config_addr   : in  std_logic_vector(CONFIG_BUS_BIT_WIDTH - 1 downto 0);
		config_wren   : in  std_logic;
		--Spikes Source Selector
		source_sel    : in  std_logic;
		--AER Output
		aer_data_out  : out STD_LOGIC_VECTOR(15 downto 0);
		aer_req       : out STD_LOGIC;
		aer_ack       : in  STD_LOGIC
	);
end OpenNas_Cascade_STEREO_64ch;

architecture OpenNas_arq of OpenNas_Cascade_STEREO_64ch is

	--Audio input modules reset signal
	signal pdm_reset_n : std_logic;
	signal i2s_reset_n : std_logic;

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
	signal spikes_out : std_logic_vector(255 downto 0);

begin

	--Output spikes connection
	spikes_out <= spikes_out_rigth & spikes_out_left;

	--Inverted source selector signal
	i_source_sel <= not source_sel;

	--PDM / I2S reset signals
	pdm_reset_n <= rst_ext_n and source_sel;
	i2s_reset_n <= rst_ext_n and i_source_sel;

	--PDM interface
	--Anti-Offset SHPF
	--Ideal cutoff: 20,0000Hz - Real cutoff: 20,2376Hz - Error: -1,1880%
	--Anti-Aliasing SLPF
	--Ideal cutoff: 8000,0000Hz - Real cutoff: 7999,7235Hz - Error: 0,0035%
	--Ideal Gain: -3,0000dB - Real Gain: -3,000dB (0,501)
	U_PDM2Spikes_Left : entity work.PDM2Spikes
		Generic Map(
			CONFIG_ADDRESS => 16#0000#,
			CONFIG_OFFSET  => 3,        -- Don't change this value
			SLPF_GL        => 8,
			SLPF_SAT       => 127,
			SHPF_GL        => 17,
			SHPF_SAT       => 65535
		)
		Port Map(
			clk         => clock,
			rst         => pdm_reset_n,
			clock_div   => x"07",       --PDM clock: +3,125MHz
			pdm_clk     => pdm_clk_left,
			pdm_dat     => pdm_dat_lef,
			--Config Bus
			config_data => config_data,
			config_addr => config_addr,
			config_wren => config_wren,
			--Spikes Output
			spikes_out  => spikes_in_left_pdm
		);

	U_PDM2Spikes_Rigth : entity work.PDM2Spikes
		Generic Map(
			CONFIG_ADDRESS => 16#0004#,
			CONFIG_OFFSET  => 3,        -- Don't change this value
			SLPF_GL        => 8,
			SLPF_SAT       => 127,
			SHPF_GL        => 17,
			SHPF_SAT       => 65535
		)
		Port Map(
			clk         => clock,
			rst         => pdm_reset_n,
			clock_div   => x"07",       --PDM clock: +3,125MHz
			pdm_clk     => pdm_clk_right,
			pdm_dat     => pdm_dat_right,
			--Config Bus
			config_data => config_data,
			config_addr => config_addr,
			config_wren => config_wren,
			--Spikes Output
			spikes_out  => spikes_in_right_pdm
		);

	--I2S Stereo
	U_I2S_Stereo : entity work.i2s_to_spikes_stereo
		Port Map(
			clock        => clock,
			reset        => i2s_reset_n,
			--I2S Bus
			i2s_bclk     => i2s_bclk,
			i2s_d_in     => i2s_d_in,
			i2s_lr       => i2s_lr,
			--Spikes Output
			spikes_left  => spikes_in_left_i2s,
			spikes_rigth => spikes_in_right_i2s
		);

	--Spikes source selector left
	U_SpikesSrcSel_Left : entity work.SpikesSource_Selector
		Port Map(
			source_sel  => source_sel,
			i2s_data    => spikes_in_left_i2s,
			pdm_data    => spikes_in_left_pdm,
			spikes_data => spikes_in_left
		);

	--Spikes source selector right
	U_SpikesSrcSel_Right : entity work.SpikesSource_Selector
		Port Map(
			source_sel  => source_sel,
			i2s_data    => spikes_in_right_i2s,
			pdm_data    => spikes_in_right_pdm,
			spikes_data => spikes_in_rigth
		);

	--Cascade Filter Bank
	U_CFBank_2or_64CH_Left : entity work.CFBank_2or_64CH
		generic map(
			CONFIG_ADDRESS => 16#0009#,
			CONFIG_OFFSET  => 259       -- Don't change this value
		)
		Port Map(
			clock       => clock,
			rst         => rst_ext_n,
			--Config Bus
			config_data => config_data,
			config_addr => config_addr,
			config_wren => config_wren,
			--Output
			spikes_in   => spikes_in_left,
			spikes_out  => spikes_out_left
		);

	U_CFBank_2or_64CH_Rigth : entity work.CFBank_2or_64CH
		generic map(
			CONFIG_ADDRESS => 16#010D#,
			CONFIG_OFFSET  => 259       -- Don't change this value
		)
		Port Map(
			clock       => clock,
			rst         => rst_ext_n,
			--Config Bus
			config_data => config_data,
			config_addr => config_addr,
			config_wren => config_wren,
			--Output
			spikes_in   => spikes_in_rigth,
			spikes_out  => spikes_out_rigth
		);

	--Spikes Distributed Monitor
	U_AER_DISTRIBUTED_MONITOR : entity work.AER_DISTRIBUTED_MONITOR
		Generic Map(
			N_SPIKES       => 256,
			LOG_2_N_SPIKES => 8,
			TAM_AER        => 2048,
			IL_AER         => 11
		)
		Port Map(
			clk          => clock,
			rst_n        => rst_ext_n,
			spikes_in    => spikes_out,
			aer_data_out => aer_data_out,
			aer_req      => aer_req,
			aer_ack      => aer_ack
		);

end OpenNas_arq;
