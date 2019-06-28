/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                     //
//                                                                             //
//    This file is part of OpenNAS.                                            //
//                                                                             //
//    OpenNAS is free software: you can redistribute it and/or modify          //
//    it under the terms of the GNU General Public License as published by     //
//    the Free Software Foundation, either version 3 of the License, or        //
//    (at your option) any later version.                                      //
//                                                                             //
//    OpenNAS is distributed in the hope that it will be useful,               //
//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
//    GNU General Public License for more details.                             //
//                                                                             //
//    You should have received a copy of the GNU General Public License        //
//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// Enum for defining SpiNNaker interface version: v1 (unidirectional) or v2 (bidirectional)
    /// </summary>
    public enum SPINNIFVERSION
    {
        /// <summary>
        /// Unidirectional communication
        /// </summary>
        V1 = 0,
        /// <summary>
        /// Bidirectional communication
        /// </summary>
        V2 = 1
    }
    class SpiNNaker_AERInterface : SpikesOutputInterface
    {

        public UInt16 nCh;
        public UInt16 aerFifoBits;
        public UInt16 spikeFifoBits;
        public UInt16 moduleVersion;

        public SpiNNaker_AERInterface() { }

        public SpiNNaker_AERInterface(UInt16 nCh, UInt16 aerFifoBits, UInt16 spikeFifoBits, UInt16 moduleVersion)
        {
            this.nCh = nCh;
            this.aerFifoBits = aerFifoBits;
            this.spikeFifoBits = spikeFifoBits;
            this.moduleVersion = moduleVersion;
        }

        public override void generateHDL(string route)
        {
            List<string> dependencies = new List<string>();

            if (moduleVersion.Equals(SPINNIFVERSION.V2))
            {
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_top.h");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link.h");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_control.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_debouncer.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_dump.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_router.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_top.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_user_int.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spinn_aer_if.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_aer2spinn_mapper.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinn2aer_mapper.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link_sync.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link_synchronous_receiver.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link_synchronous_sender.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_switch.v");

                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\AER_IN.vhd");
            }
            else
            {
                dependencies.Add(@"SpiNNakerAERInterface\v1\spinn_aer_if.v");
            }
            
            copyDependencies(route, dependencies);
        }

        public override void toXML(XmlTextWriter textWriter)
        {
            // Start SpiNNaker-AER interface element
            textWriter.WriteStartElement("SpiNNakerAERInterface");
            // Start SpiNNaker version
            textWriter.WriteAttributeString("moduleVersion", moduleVersion.ToString());
            // End SpiNNaker version
            textWriter.WriteEndElement();
            // End SpiNNaker-AER interface element
        }


        public override void WriteComponentArchitecture(StreamWriter sw)
        {

            if (moduleVersion == 2.0)
            {
                sw.WriteLine("");
                sw.WriteLine("-- SpiNNaer-AER interface v2");
                sw.WriteLine("component raggedstone_spinn_aer_if_top is");
                sw.WriteLine("	port(");
                sw.WriteLine("		ext_nreset: in STD_LOGIC;");
                sw.WriteLine("		ext_clk: in std_logic;");
                sw.WriteLine("		");
                sw.WriteLine("		--// display interface (7-segment and leds)");
                sw.WriteLine("		ext_mode_sel: in std_logic;");
                sw.WriteLine("		ext_7seg: out std_logic_vector(7 downto 0);");
                sw.WriteLine("		ext_strobe: out std_logic_vector(3 downto 0);");
                sw.WriteLine("		ext_led2: out std_logic;");
                sw.WriteLine("		ext_led3: out std_logic;");
                sw.WriteLine("		ext_led4: out std_logic;");
                sw.WriteLine("		ext_led5: out std_logic;");
                sw.WriteLine("		--// input from SpiNNaker link interface");
                sw.WriteLine("		data_2of7_from_spinnaker: in std_logic_vector(6 downto 0);");
                sw.WriteLine("		ack_to_spinnaker: out std_logic;");
                sw.WriteLine("		");
                sw.WriteLine("		--// output to SpiNNaker link interface");
                sw.WriteLine("		data_2of7_to_spinnaker: out std_logic_vector(6 downto 0);");
                sw.WriteLine("		ack_from_spinnaker: in std_logic;");
                sw.WriteLine("		");
                sw.WriteLine("		--// input from AER device interface");
                sw.WriteLine("		iaer_data: in std_logic_vector(15 downto 0);");
                sw.WriteLine("		iaer_req: in std_logic;");
                sw.WriteLine("		iaer_ack: out std_logic;");
                sw.WriteLine("		");
                sw.WriteLine("		--// output to AER device interface");
                sw.WriteLine("		oaer_data: out std_logic_vector(15 downto 0);");
                sw.WriteLine("		oaer_req: out std_logic;");
                sw.WriteLine("		oaer_ack: in std_logic");
                sw.WriteLine("	);");
                sw.WriteLine("end component;");
                sw.WriteLine("");

            }
            else //por defecto sera la 1.0
            {
                sw.WriteLine("");
                sw.WriteLine("-- SpiNNaer-AER interface v1");
                sw.WriteLine("component spinn_aer_if is");
                sw.WriteLine("port (");
                sw.WriteLine("    CLK: in  STD_LOGIC;");
                sw.WriteLine("    data_2of7_to_spinnaker: out STD_LOGIC_VECTOR(6 downto 0);");
                sw.WriteLine("    ack_from_spinnaker: in STD_LOGIC;");
                sw.WriteLine("    aer_req: in STD_LOGIC;");
                sw.WriteLine("    aer_data: in STD_LOGIC_VECTOR (15 downto 0);");
                sw.WriteLine("    aer_ack: out STD_LOGIC;");
                sw.WriteLine("    reset: in STD_LOGIC");
                sw.WriteLine(");");
                sw.WriteLine("end component;");
                sw.WriteLine("");
            }
        }

        public override void WriteComponentInvocation(StreamWriter sw)
        {
            sw.WriteLine("--Spikes Distributed Monitor");
            sw.WriteLine(" U_AER_DISTRIBUTED_MONITOR: AER_DISTRIBUTED_MONITOR");
            sw.WriteLine("generic map (N_SPIKES=>" + (2 * nCh) + ", LOG_2_N_SPIKES=>" + ((int)Math.Log(2 * nCh, 2)) + ", TAM_AER=>" + ((int)Math.Pow(2, aerFifoBits)) + ", IL_AER=>" + aerFifoBits + ")");
            sw.WriteLine("Port map (");
            sw.WriteLine("  CLK=>clock,");
            sw.WriteLine("  RST=> reset,");
            sw.WriteLine("  SPIKES_IN=>spikes_out,");
            sw.WriteLine("  AER_DATA_OUT=>AER_DATA_OUT,");
            sw.WriteLine("  AER_REQ=>AER_REQ,");
            sw.WriteLine("  AER_ACK=>AER_ACK);");
            sw.WriteLine("");

            if (moduleVersion == 2.0)
            {
                sw.WriteLine("U_SpiNNaker_driver: raggedstone_spinn_aer_if_top");
                sw.WriteLine("	port map(");
                sw.WriteLine("		ext_nreset=>reset,");
                sw.WriteLine("		ext_clk=>clock,");
                sw.WriteLine("		");
                sw.WriteLine("		--// display interface (7-segment and leds)");
                sw.WriteLine("		ext_mode_sel=>modesel,");
                sw.WriteLine("		ext_7seg=>d_7seg,");
                sw.WriteLine("		ext_strobe=>strobe,");
                sw.WriteLine("		ext_led2=>spinnaker_driver_active,");
                sw.WriteLine("		ext_led3=>spinnaker_driver_reset,");
                sw.WriteLine("		ext_led4=>spinnaker_driver_dump,");
                sw.WriteLine("		ext_led5=>spinnaker_driver_error,");
                sw.WriteLine("		");
                sw.WriteLine("		--// input from SpiNNaker link interface");
                sw.WriteLine("		data_2of7_from_spinnaker=>data_2of7_from_spinnaker,");
                sw.WriteLine("		ack_to_spinnaker=>ack_to_spinnaker,");
                sw.WriteLine("		");
                sw.WriteLine("		--// output to SpiNNaker link interface");
                sw.WriteLine("		data_2of7_to_spinnaker=>data_2of7_to_spinnaker,");
                sw.WriteLine("		ack_from_spinnaker=>ack_from_spinnaker,");
                sw.WriteLine("		");
                sw.WriteLine("		--// input from AER device interface");
                sw.WriteLine("		iaer_data=>AER_DATA_OUT,");
                sw.WriteLine("		iaer_req=>AER_REQ,");
                sw.WriteLine("		iaer_ack=>AER_ACK,");
                sw.WriteLine("		");
                sw.WriteLine("		--// output to AER device interface");
                sw.WriteLine("		oaer_data=>I_AER_DATA_OUT,");
                sw.WriteLine("		oaer_req=>I_AER_REQ,");
                sw.WriteLine("		oaer_ack=>I_AER_ACK");
                sw.WriteLine("		");
                sw.WriteLine("	);");
                sw.WriteLine("");

            }
            else
            {
                sw.WriteLine("--SpiNNaker - AER interface v1");
                sw.WriteLine("  U_spinn_aer_if: spinn_aer_if");
                sw.WriteLine("  port map (");
                sw.WriteLine("    clk=>clock,");
                sw.WriteLine("    data_2of7_to_spinnaker=>data_2of7_to_spinnaker,");
                sw.WriteLine("    ack_from_spinnaker=>ack_from_spinnaker,");
                sw.WriteLine("    aer_req=>AER_REQ,");
                sw.WriteLine("    aer_data=>AER_DATA_OUT,");
                sw.WriteLine("    aer_ack=>AER_ACK,");
                sw.WriteLine("    reset=> n_reset");
                sw.WriteLine("  );");
                sw.WriteLine("");
            }
        }

        public override void WriteTopSignals(StreamWriter sw)
        {
            if (moduleVersion == 2.0)
            {
                sw.WriteLine("--FPGA to SpiNNaker");
                sw.WriteLine("  data_2of7_to_spinnaker: out STD_LOGIC_VECTOR(6 downto 0);");
                sw.WriteLine("  ack_from_spinnaker: in STD_LOGIC;");
                sw.WriteLine("--SpiNNaker to FPGA");
                sw.WriteLine("  data_2of7_from_spinnaker: in STD_LOGIC_VECTOR(6 downto 0);");
                sw.WriteLine("  ack_to_spinnaker: out STD_LOGIC;");
                sw.WriteLine("--SpiNNaker driver - User interface");
                sw.WriteLine("  spinnaker_driver_active: out STD_LOGIC;");
                sw.WriteLine("  spinnaker_driver_reset: out STD_LOGIC;");
                sw.WriteLine("  spinnaker_driver_dump: out STD_LOGIC;");
                sw.WriteLine("  spinnaker_driver_error: out STD_LOGIC");
            }
            else
            {
                sw.WriteLine("--FPGA to SpiNNaker");
                sw.WriteLine("  data_2of7_to_spinnaker: out STD_LOGIC_VECTOR(6 downto 0);");
                sw.WriteLine("  ack_from_spinnaker: in STD_LOGIC");
            }


        }
    }
}
