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
    /// This class implements a distributed spikes monitor. This converts a set of input spikes (channels) to AER events, and includes a 4-phase hand-shake unit for events propagation. <see cref="SpikesOutputInterface"/>
    /// </summary>
    public class SpikesDistributedMonitor : SpikesOutputInterface
    {
        /// <summary>
        /// Number of channels
        /// </summary>
        public UInt16 nCh;
        /// <summary>
        /// AER Events ouput fifo depth 
        /// </summary>
        public UInt16 aerFifoDepth;
        /// <summary>
        /// Input spikes fifo depth
        /// </summary>
        public UInt16 spikeFifoDepth;

        /// <summary>
        /// Gives an empty instance of SpikesDistributedMonitor
        /// </summary>
        public SpikesDistributedMonitor() { }

        /// <summary>
        /// Gives an instance of SpikesDistributedMonitor 
        /// </summary>
        /// <param name="nCh">Number of channels</param>
        /// <param name="aerFifoBits">AER Events ouput fifo depth</param>
        /// <param name="spikeFifoBits">Input spikes fifo depth</param>
        public SpikesDistributedMonitor(UInt16 nCh, UInt16 aerFifoBits, UInt16 spikeFifoBits)
        {
            this.nCh = nCh;
            this.aerFifoDepth = aerFifoBits;
            this.spikeFifoDepth = spikeFifoBits;
        }
        /// <summary>
        /// Generates a SpikesDistributedMonitor output stage, copying library files, and generating custom sources
        /// </summary>
        /// <param name="route">Destination files route</param>
        public override void generateHDL(string route)
        {
            List<string> dependencies = new List<string>();
            dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\AER_DISTRIBUTED_MONITOR.vhd");
            dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\AER_DISTRIBUTED_MONITOR_MODULE.vhd");
            dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\AER_OUT.vhd");
            dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\handsakeOut.vhd");
            dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\ramfifo.vhd");
            dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\DualPortRAM.vhd");


            copyDependencies(route, dependencies);
        }

        /// <summary>
        /// Writes SpikesDistributedMonitor output settings in a XML file
        /// </summary>
        /// <param name="textWriter">XML text writer handler</param>
        public override void toXML(XmlTextWriter textWriter)
        {
            textWriter.WriteStartElement("SpikesDistributedMonitor");
            textWriter.WriteAttributeString("aerFifoDepth", aerFifoDepth.ToString());
            textWriter.WriteAttributeString("spikeFifoDepth", spikeFifoDepth.ToString());
            textWriter.WriteEndElement();
        }

        /// <summary>
        /// Writes a SpikesDistributedMonitor output stage component architecture <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>              
        public override void WriteComponentArchitecture(StreamWriter sw)
        {
            sw.WriteLine("--Spikes Distributed Monitor");
            sw.WriteLine("component AER_DISTRIBUTED_MONITOR is");
            sw.WriteLine("generic(N_SPIKES: integer:=128; LOG_2_N_SPIKES: integer:=7; TAM_AER: in integer; IL_AER: in integer);");
            sw.WriteLine("Port(");
            sw.WriteLine("  CLK: in  STD_LOGIC;");
            sw.WriteLine("  RST: in  STD_LOGIC;");
            sw.WriteLine("  SPIKES_IN: in  STD_LOGIC_VECTOR(N_SPIKES - 1 downto 0);");
            sw.WriteLine("  AER_DATA_OUT: out  STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("  AER_REQ: out  STD_LOGIC;");
            sw.WriteLine("  AER_ACK: in  STD_LOGIC);");
            sw.WriteLine("end component;");
        }

        /// <summary>
        /// Writes a SpikesDistributedMonitor output component invocation and link signals<see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentInvocation(StreamWriter sw)
        {
            sw.WriteLine("--Spikes Distributed Monitor");
            sw.WriteLine(" U_AER_DISTRIBUTED_MONITOR: AER_DISTRIBUTED_MONITOR");
            sw.WriteLine("generic map (N_SPIKES=>" + (2 * nCh) + ", LOG_2_N_SPIKES=>" + ((int)Math.Log(2 * nCh, 2)) + ", TAM_AER=>" + ((int)Math.Pow(2, aerFifoDepth)) + ", IL_AER=>" + aerFifoDepth + ")");
            sw.WriteLine("Port map (");
            sw.WriteLine("  CLK=>clock,");
            sw.WriteLine("  RST=> reset,");
            sw.WriteLine("  SPIKES_IN=>spikes_out,");
            sw.WriteLine("  AER_DATA_OUT=>AER_DATA_OUT,");
            sw.WriteLine("  AER_REQ=>AER_REQ,");
            sw.WriteLine("  AER_ACK=>AER_ACK);");
            sw.WriteLine("");
        }

        /// <summary>
        /// Writes SpikesDistributedMonitor output stage top signals <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteTopSignals(StreamWriter sw)
        {

            sw.WriteLine("--AER Output");
            sw.WriteLine("  AER_DATA_OUT: out  STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("  AER_REQ: out  STD_LOGIC;");
            sw.WriteLine("  AER_ACK: in  STD_LOGIC");

        }
    }
}
