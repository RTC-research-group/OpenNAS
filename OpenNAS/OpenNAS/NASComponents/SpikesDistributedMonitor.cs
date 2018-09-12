/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//    Copyright © 2016  Ángel Francisco Jimñénez-Fernández                     //
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
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace OpenNAS_App.NASComponents
{
    public class SpikesDistributedMonitor:SpikesOutputInterface
    {

        public UInt16 nCh;
        public UInt16 aerFifoBits;
        public UInt16 spikeFifoBits;

        public SpikesDistributedMonitor() { }

        public SpikesDistributedMonitor(UInt16 nCh, UInt16 aerFifoBits, UInt16 spikeFifoBits)
        {
            this.nCh = nCh;
            this.aerFifoBits = aerFifoBits;
            this.spikeFifoBits = spikeFifoBits;
        }

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

        public override void toXML(XmlTextWriter textWriter)
        { 
            textWriter.WriteStartElement("SpikesDistributedMonitor");
            textWriter.WriteAttributeString("aerFifoBits", aerFifoBits.ToString());
            textWriter.WriteAttributeString("spikeFifoBits", spikeFifoBits.ToString());
            textWriter.WriteEndElement();
        }

                      
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

        public override void WriteComponentInvocation(StreamWriter sw)
        {
            sw.WriteLine("--Spikes Distributed Monitor");
            sw.WriteLine(" U_AER_DISTRIBUTED_MONITOR: AER_DISTRIBUTED_MONITOR");
            sw.WriteLine("generic map (N_SPIKES=>" + (2 * nCh) + ", LOG_2_N_SPIKES=>" + ((int)Math.Log(2 * nCh, 2)) + ", TAM_AER=>" + ((int)Math.Pow(2,aerFifoBits))+", IL_AER=>" + aerFifoBits + ")");
            sw.WriteLine("Port map (");
            sw.WriteLine("  CLK=>clock,");
            sw.WriteLine("  RST=> reset,");
            sw.WriteLine("  SPIKES_IN=>spikes_out,");
            sw.WriteLine("  AER_DATA_OUT=>AER_DATA_OUT,");
            sw.WriteLine("  AER_REQ=>AER_REQ,");
            sw.WriteLine("  AER_ACK=>AER_ACK);");
            sw.WriteLine("");
        }

        public override void WriteTopSignals(StreamWriter sw)
        {

            sw.WriteLine("--AER Output");
            sw.WriteLine("  AER_DATA_OUT: out  STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("  AER_REQ: out  STD_LOGIC;");
            sw.WriteLine("  AER_ACK: in  STD_LOGIC");

        }
    }
}
