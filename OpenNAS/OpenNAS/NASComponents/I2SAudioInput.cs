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
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// This class implements an I2S ADC audio input stage, it includes an I2S interface and  one or two (depending of mono or stereo) synthetic spikes generators. <see cref="AudioInput"/>
    /// </summary>
    public class I2SAudioInput : AudioInput
    {
        /// <summary>
        /// NAS type (mono or stereo)
        /// </summary>
        public NASTYPE nasType;
        /// <summary>
        /// Clock Frequency, in Hz
        /// </summary>
        public float clk;
        /// <summary>
        /// I2S Internal spikes generator number of bits
        /// </summary>
        public uint genNbits;
        /// <summary>
        /// I2S Clock divisor value
        /// </summary>
        public UInt16 genFreqDiv;

        /// <summary>
        /// Gives an instance of an I2S audio input
        /// </summary>
        /// <param name="clk">Nas type (mono or stereo)g</param>
        /// <param name="nasType">NAS type (mono or stereo)</param>
        /// <param name="genNbits">I2S Internal spikes generator number of bits</param>
        /// <param name="genFreqDiv">I2S Clock divisor value</param>
        public I2SAudioInput(float clk, NASTYPE nasType, uint genNbits, UInt16 genFreqDiv)
        {
            this.clk = clk;
            this.nasType = nasType;
            this.genNbits = genNbits;
            this.genFreqDiv = genFreqDiv;
        }

        /// <summary>
        /// Generates a full I2S input stage, copying library files, and generating custom sources
        /// </summary>
        /// <param name="route">Destination files route</param>
        public override void generateHDL(string route)
        {
            List<string> dependencies = new List<string>();
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\Spikes_Generator_signed_BW.vhd");
            dependencies.Add(@"SSPLibrary\Components\I2S_inteface_sync.vhd");
            dependencies.Add(@"SSPLibrary\Components\i2s_to_spikes_stereo.vhd");
            copyDependencies(route, dependencies);
        }
        /// <summary>
        /// Writes I2S input interface settings in a XML file
        /// </summary>
        /// <param name="textWriter">XML text writer handler</param>
        public override void toXML(XmlTextWriter textWriter)
        {
            textWriter.WriteStartElement("I2SAudioADC");
            textWriter.WriteAttributeString("genNbits", genNbits.ToString());
            textWriter.WriteAttributeString("genFreqDiv", genFreqDiv.ToString());
            textWriter.WriteEndElement();
        }

        /// <summary>
        /// Writes I2S input stage component architecture <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentArchitecture(StreamWriter sw)
        {
            sw.WriteLine("--I2S interface Stereo");
            sw.WriteLine("component is2_to_spikes_stereo is");
            sw.WriteLine("port (");
            sw.WriteLine("  clock: in std_logic;");
            sw.WriteLine("  reset: in std_logic;");
            sw.WriteLine("--I2S Bus");
            sw.WriteLine("  i2s_bclk  : in std_logic;");
            sw.WriteLine("  i2s_d_in: in std_logic;");
            sw.WriteLine("  i2s_lr: in std_logic;");
            sw.WriteLine("--Spikes Output");
            sw.WriteLine("  spikes_left: out std_logic_vector(1 downto 0);");
            sw.WriteLine("  spikes_rigth: out std_logic_vector(1 downto 0)");
            sw.WriteLine(");");
            sw.WriteLine("end component;");

        }

        /// <summary>
        /// Writes Hybrid I2S input component invocation and signals link <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentInvocation(StreamWriter sw)
        {
            
            
                sw.WriteLine("--I2S Stereo");
                sw.WriteLine("U_I2S_Stereo: is2_to_spikes_stereo");
                sw.WriteLine("port map (");
                sw.WriteLine("  clock=>clock,");
                sw.WriteLine("  reset=>reset,");

                sw.WriteLine("--I2S Bus");
                sw.WriteLine("  i2s_bclk  => i2s_bclk,");
                sw.WriteLine("   i2s_d_in => i2s_d_in,");
                sw.WriteLine("   i2s_lr => i2s_lr,");
                sw.WriteLine("--Spikes Output");
            sw.WriteLine("  spikes_left=>spikes_in_left,");
            if (nasType == NASTYPE.MONO)
            {
                sw.WriteLine("  spikes_rigth=>open");
            }
            else
            {
                sw.WriteLine("  spikes_rigth=>spikes_in_rigth");
            }
                sw.WriteLine(");");

            sw.WriteLine("");
        }

        /// <summary>
        /// Writes I2S input stage top signals <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteTopSignals(StreamWriter sw)
        {
            sw.WriteLine("--I2S Bus");
            sw.WriteLine("  i2s_bclk      : in  STD_LOGIC;");
            sw.WriteLine("  i2s_d_in: in  STD_LOGIC;");
            sw.WriteLine("  i2s_lr: in  STD_LOGIC;");


        }
    }
}
