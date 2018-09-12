﻿/////////////////////////////////////////////////////////////////////////////////
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
using System.Xml.Serialization;

namespace OpenNAS_App.NASComponents
{
    public enum AC97AudioSource { LINE_IN=0, MIC_IN=1}


    public class AC97AudioInput : AudioInput
    {
        [XmlAttribute]
        public AC97AudioSource source;
        public NASTYPE nasType;
        public float clk;
        public uint genNbits;
        public UInt16 genFreqDiv;

        public AC97AudioInput (AC97AudioSource source, float clk, NASTYPE nasType, uint genNbits,  UInt16 genFreqDiv)
        {
            this.source = source;
            this.clk = clk;
            this.nasType = nasType;
            this.genNbits = genNbits;
            this.genFreqDiv = genFreqDiv;
        }

        
        override public void toXML(XmlTextWriter textWriter)
        {

            textWriter.WriteStartElement("AC97Codec");
            textWriter.WriteAttributeString("source", source.ToString());
            textWriter.WriteAttributeString("genNbits", genNbits.ToString());
            textWriter.WriteAttributeString("genFreqDiv", genFreqDiv.ToString());
            textWriter.WriteEndElement();
        }



        public override void generateHDL(string route)
        {
            List<string> dependencies = new List<string>();
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\Spikes_Generator_signed_BW.vhd");
            copyDependencies(route, dependencies);

            StreamReader sr = new StreamReader(@"SSPLibrary\Components\AC97Controller.vhd");

            string ac97controller = sr.ReadToEnd();

            string[] ac97parts = ac97controller.Split('\\');

            StreamWriter sw = new StreamWriter(route + "\\AC97Controller.vhd");
            sw.Write(ac97parts[0]);

            if (source == AC97AudioSource.MIC_IN)
                sw.Write(ac97parts[1]);
            else
                sw.Write(ac97parts[2]);
            sw.Write(ac97parts[3]);
            sw.Close();

            if (nasType == NASTYPE.STEREO) { 
                StreamReader sr2 = new StreamReader(@"SSPLibrary\Components\AC97InputComponentStereo.vhd");

                ac97controller = sr2.ReadToEnd();

                string[] ac97genGain = ac97controller.Split('\\');

                sw = new StreamWriter(route + "\\AC97InputComponentStereo.vhd");
                sw.Write(ac97genGain[0]);
                sw.Write("x\"" + genFreqDiv.ToString("X4") + "\";\n");

                sw.Write(ac97genGain[1]);
                sw.Close();
            }
            else
            {
                StreamReader sr2 = new StreamReader(@"SSPLibrary\Components\AC97InputComponentMono.vhd");

                ac97controller = sr2.ReadToEnd();

                string[] ac97genGain = ac97controller.Split('\\');

                sw = new StreamWriter(route + "\\AC97InputComponentMono.vhd");
                sw.Write(ac97genGain[0]);
                sw.Write("x\"" + genFreqDiv.ToString("X4") + "\";\n");

                sw.Write(ac97genGain[1]);
                sw.Close();

            }

            


        }

        public override void WriteTopSignals(StreamWriter sw)
        {


            sw.WriteLine("--AC Link");
            sw.WriteLine("  ac97_bit_clock  : in std_logic;");
            sw.WriteLine("  ac97_sdata_in: in std_logic; --Serial data from AC'97");

            sw.WriteLine("  ac97_sdata_out: out std_logic; --Serial data to AC'97");

            sw.WriteLine("  ac97_synch: out std_logic; --Defines boundries of AC'97 frames, controls warm reset");


            sw.WriteLine("  audio_reset_b: out std_logic; --AC'97 codec cold reset");
        }

        public override void WriteComponentArchitecture(StreamWriter sw)
        {
            if (nasType == NASTYPE.MONO)
            {
                sw.WriteLine("--AC97 interface Mono");
                sw.WriteLine("component AC97InputComponentMono is");
                sw.WriteLine("port (");
                sw.WriteLine("  clock: in std_logic;");
                sw.WriteLine("  reset: in std_logic;");
                sw.WriteLine("--AC Link");
                sw.WriteLine("  ac97_bit_clock  : in std_logic;");
                sw.WriteLine("  ac97_sdata_in: in std_logic; --Serial data from AC'97");
                sw.WriteLine("  ac97_sdata_out: out std_logic; --Serial data to AC'97");
                sw.WriteLine("  ac97_synch: out std_logic; --Defines boundries of AC'97 frames, controls warm reset");
                sw.WriteLine("  audio_reset_b: out std_logic; --AC'97 codec cold reset");
                sw.WriteLine("--Spikes Output");
                sw.WriteLine("  spikes_left: out std_logic_vector(1 downto 0)");
                sw.WriteLine(");");
                sw.WriteLine("end component;");

            }
            else
            {
                sw.WriteLine("--AC97 interface Stereo");
                sw.WriteLine("component AC97InputComponentStereo is");
                sw.WriteLine("port (");
                sw.WriteLine("  clock: in std_logic;");
                sw.WriteLine("  reset: in std_logic;");
                sw.WriteLine("--AC Link");
                sw.WriteLine("  ac97_bit_clock  : in std_logic;");
                sw.WriteLine("  ac97_sdata_in: in std_logic; --Serial data from AC'97");
                sw.WriteLine("  ac97_sdata_out: out std_logic; --Serial data to AC'97");
                sw.WriteLine("  ac97_synch: out std_logic; --Defines boundries of AC'97 frames, controls warm reset");
                sw.WriteLine("  audio_reset_b: out std_logic; --AC'97 codec cold reset");
                sw.WriteLine("--Spikes Output");
                sw.WriteLine("  spikes_left: out std_logic_vector(1 downto 0);");
                sw.WriteLine("  spikes_rigth: out std_logic_vector(1 downto 0)");
                sw.WriteLine(");");
                sw.WriteLine("end component;");
            }
        }

        public override void WriteComponentInvocation(StreamWriter sw)
        {
            if (nasType == NASTYPE.MONO)
            {
                sw.WriteLine("--AC97 interface Mono");
                sw.WriteLine("U_AC97_Mono: AC97InputComponentMono");
                sw.WriteLine("port map (");
                sw.WriteLine("  clock=>clock,");
                sw.WriteLine("  reset=>reset,");
                sw.WriteLine("--AC Link");
                sw.WriteLine("  ac97_bit_clock =>ac97_bit_clock,");
                sw.WriteLine("  ac97_sdata_in=>ac97_sdata_in,");
                sw.WriteLine("  ac97_sdata_out=>ac97_sdata_out,");
                sw.WriteLine("  ac97_synch=>ac97_synch,");
                sw.WriteLine("  audio_reset_b=>audio_reset_b,");
                sw.WriteLine("--Spikes Output");
                sw.WriteLine("  spikes_left=>spikes_in_left");
                sw.WriteLine(");");
            }
            else
            {
                sw.WriteLine("--AC97 interface Stereo");
                sw.WriteLine("U_AC97_Stereo: AC97InputComponentStereo");
                sw.WriteLine("port map (");
                sw.WriteLine("  clock=>clock,");
                sw.WriteLine("  reset=>reset,");
                sw.WriteLine("--AC Link");
                sw.WriteLine("  ac97_bit_clock =>ac97_bit_clock,");
                sw.WriteLine("  ac97_sdata_in=>ac97_sdata_in,");
                sw.WriteLine("  ac97_sdata_out=>ac97_sdata_out,");
                sw.WriteLine("  ac97_synch=>ac97_synch,");
                sw.WriteLine("  audio_reset_b=>audio_reset_b,");
                sw.WriteLine("--Spikes Output");
                sw.WriteLine("  spikes_left=>spikes_in_left,");
                sw.WriteLine("  spikes_rigth=>spikes_in_rigth");
                sw.WriteLine(");");

            }
            sw.WriteLine("");





        }
    }


}
