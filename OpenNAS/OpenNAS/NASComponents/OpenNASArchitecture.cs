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
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;

/// <summary>
/// This namespace groups all the classes for NAS representation and generation, performing components library
/// </summary>
namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// This class contains a full NAS architecture. This is composed byte 3 elements: AudioInput <see cref="AudioInput"/>, AudioProcessingArchitecture <see cref="AudioProcessingArchitecture"/> and a SpikesOutputInterface <see cref="SpikesOutputInterface"/>.
    /// </summary>
    public class OpenNASArchitecture
    {
        /// <summary>
        /// NAS common setting parameters <see cref="OpenNASCommons"/>
        /// </summary>
        public OpenNASCommons nasCommons;
        /// <summary>
        /// NAS audio input stage <see cref="AudioInput"/>
        /// </summary>
        public AudioInput audioInput;
        /// <summary>
        /// NAS main processing block <see cref="AudioProcessingArchitecture"/>
        /// </summary>
        public AudioProcessingArchitecture audioProcessing;
        /// <summary>
        /// NAS events output interface <see cref="SpikesOutputInterface"/>
        /// </summary>
        public SpikesOutputInterface spikesOutput;
        /// <summary>
        /// Basic Open NAS Architecture class constructor
        /// </summary>
        public OpenNASArchitecture() { }
        /// <summary>
        /// Main Open NAS Architecture class constructor
        /// </summary>
        /// <param name="commons">NAS common setting parameters <see cref="OpenNASCommons"/></param>
        /// <param name="ai">NAS audio input stage <see cref="AudioInput"/></param>
        /// <param name="ap">NAS main processing block <see cref="AudioProcessingArchitecture"/></param>
        /// <param name="soi">NAS events output interface <see cref="SpikesOutputInterface"/></param>
        public OpenNASArchitecture(OpenNASCommons commons, AudioInput ai, AudioProcessingArchitecture ap, SpikesOutputInterface soi)
        {
            nasCommons = commons;
            audioInput = ai;
            audioProcessing = ap;
            spikesOutput = soi;
        }

        /// <summary>
        /// Generates a full NAS, copying library files, and generating custom sources
        /// </summary>
        /// <param name="route">Destination files route</param>
        public void Generate (string route)
        {
            //Generate HDL componets
            audioInput.generateHDL(route);
            audioProcessing.generateHDL(route);
            spikesOutput.generateHDL(route);
            //Write Top HDL file
            writeTopFile(route);

            writeConstraints(route);
        }

        /// <summary>
        /// Writes top NAS HDL file, integrating all NAS componentes
        /// </summary>
        /// <param name="route">Destination file route</param>
        private void writeTopFile(string route)
        {

            string nasName = "OpenNas_TOP_"+ audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch";
            StreamWriter sw = new StreamWriter(route + "\\"+nasName+".vhd");

            sw.WriteLine(HDLGenerable.copyLicense());

            sw.WriteLine("library IEEE;");
            sw.WriteLine("use IEEE.STD_LOGIC_1164.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_ARITH.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_UNSIGNED.ALL;");

            sw.WriteLine("");
            
            //Top component signals
            string entity = "OpenNas_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + + nasCommons.nCh+"ch";
            sw.WriteLine("entity " + entity + " is");
            sw.WriteLine("  port(");
            sw.WriteLine("  clock     : in std_logic;");
            sw.WriteLine("  rst_ext   : in std_logic;");
            audioInput.WriteTopSignals(sw);
            spikesOutput.WriteTopSignals(sw);

            sw.WriteLine(");");
            sw.WriteLine("end " + entity + ";");
            sw.WriteLine("");

            sw.WriteLine("architecture OpenNas_arq of " + entity + " is");
            sw.WriteLine("");

            //Components Architecture
            audioInput.WriteComponentArchitecture(sw);
            audioProcessing.WriteComponentArchitecture(sw);
            spikesOutput.WriteComponentArchitecture(sw);
            sw.WriteLine("");
            sw.WriteLine("--Reset signals");
            sw.WriteLine("  signal reset : std_logic;");
            sw.WriteLine("  signal pdm_reset : std_logic;");
            sw.WriteLine("  signal i2s_reset: std_logic; ");
            sw.WriteLine("--Inverted Source selector signal");
            sw.WriteLine("  signal i_source_sel : std_logic;");
            sw.WriteLine("--Left spikes");
            sw.WriteLine("  signal spikes_in_left_i2s : std_logic_vector(1 downto 0);");
            sw.WriteLine("  signal spikes_in_left_pdm : std_logic_vector(1 downto 0);");
            sw.WriteLine("  signal spikes_in_left : std_logic_vector(1 downto 0);");
            sw.WriteLine("  signal spikes_out_left : std_logic_vector("+(nasCommons.nCh*2-1)+" downto 0);");
            
            
            ///////////////////////////////////////spikes_out_left

            if (nasCommons.monoStereo == NASTYPE.STEREO)
            {
                sw.WriteLine("--Rigth spikes");
                sw.WriteLine("signal spikes_in_right_i2s : std_logic_vector(1 downto 0);");
                sw.WriteLine("signal spikes_in_right_pdm : std_logic_vector(1 downto 0);");
                sw.WriteLine("  signal spikes_in_rigth : std_logic_vector(1 downto 0);");
                sw.WriteLine("  signal spikes_out_rigth : std_logic_vector(" + (nasCommons.nCh * 2 - 1) + " downto 0);");
            }

            if (nasCommons.monoStereo == NASTYPE.STEREO)
            {
                sw.WriteLine("--Output spikes");
                sw.WriteLine("  signal spikes_out: std_logic_vector(" + (nasCommons.nCh * 4 - 1) + " downto 0);");
            }
            else
            {
                sw.WriteLine("--Output spikes");
                sw.WriteLine("  signal spikes_out: std_logic_vector(" + (nasCommons.nCh * 2 - 1) + " downto 0);");
            }

            sw.WriteLine("");

            sw.WriteLine("begin");
            sw.WriteLine("");
            sw.WriteLine("--reset<='1';");
            sw.WriteLine("reset<=rst_ext;");
            sw.WriteLine("--Output spikes connection");
            if (nasCommons.monoStereo == NASTYPE.STEREO)
            {
                sw.WriteLine("spikes_out<= spikes_out_rigth & spikes_out_left ;");
            }
            else
            {
                sw.WriteLine("spikes_out<= spikes_out_left ;");
            }

            sw.WriteLine("--Inverted source selector signal");
            sw.WriteLine("i_source_sel <= not source_sel;");
            sw.WriteLine("--PDM / I2S reset signals");
            sw.WriteLine("pdm_reset <= reset and source_sel;");
            sw.WriteLine("i2s_reset <= reset and i_source_sel;");

            audioInput.WriteComponentInvocation(sw);
            audioProcessing.WriteComponentInvocation(sw);
            spikesOutput.WriteComponentInvocation(sw);

            sw.WriteLine("end OpenNas_arq;");

            sw.Close();

        }

        private void writeConstraints(string route)
        {
            string dependencies = null;
            switch (nasCommons.nasChip)
            {
                case NASchip.AERNODE:
                    dependencies = @"Constraints\Node_constraints.ucf";
                    break;
                case NASchip.ZTEX:
                    dependencies = @"Constraints\ZTEX_constraints.xdc";
                    break;
                case NASchip.SOC_DOCK:
                    dependencies = @"Constraints\SOC_DOCK_constraints.xdc";
                    break;
                case NASchip.OTHER:
                    dependencies = @"Constraints\Other_generic_constraints.txt";
                    break;
            }
            string[] s = dependencies.Split('\\');
            System.IO.File.Copy(dependencies, route + "\\" + s[s.Length - 1], true);
        }
        /// <summary>
        /// Writes NAS architecture and settings as a XML file
        /// </summary>
        /// <param name="route">Destination file route</param>
        public void toXML(string route)
        {
            string nasName = "OpenNas_TOP_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch";

            string filename = route + "\\"+nasName+".xml";
            CultureInfo ci = new CultureInfo("en-us");
            XmlTextWriter textWriter;
            textWriter = new XmlTextWriter(filename, null);

            textWriter.WriteStartDocument();
            textWriter.Formatting = Formatting.Indented;
            textWriter.Indentation = 2;

            textWriter.WriteStartElement("OpenNAS");
            textWriter.WriteAttributeString("Version", "1.0");

            nasCommons.toXML(textWriter);
            audioInput.toXML(textWriter);
            audioProcessing.toXML(textWriter);
            spikesOutput.toXML(textWriter);
               
            textWriter.WriteEndElement();
            textWriter.WriteEndDocument();
            textWriter.Close();

        }
    }
}
