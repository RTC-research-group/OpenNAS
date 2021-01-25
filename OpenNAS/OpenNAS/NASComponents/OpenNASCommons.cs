/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                      //
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
using System.Globalization;
using System.Xml;
using YamlDotNet.RepresentationModel;

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// Enum for defining NAS TYPE: mono or stereo
    /// </summary>
    public enum NASTYPE
    {
        /// <summary>
        /// Mono-aural NAS
        /// </summary>
        MONO = 0,
        /// <summary>
        /// Bi-aural NAS
        /// </summary>
        STEREO = 1
    }

    /// <summary>
    /// NAS plattaform for synthesis
    /// </summary>
    public enum NASchip
    {
        /// <summary>
        /// AER-Node Board (Spartan 6)
        /// </summary>
        AERNODE = 0,
        /// <summary>
        /// ZTEX Board (Artyx 7)
        /// </summary>
        ZTEX = 1,
        /// <summary>
        /// SOC DOCK Board (Zynq 7000)
        /// </summary>
        SOC_DOCK = 2,
        /// <summary>
        /// Other custom board
        /// </summary>
        OTHER = 3
    }

    /// <summary>
    /// This class contains NAS commons parameters for computing parameters and sources generating
    /// </summary>
    public class OpenNASCommons
    {
        /// <summary>
        /// NAS type, mono or stereo <see cref="NASTYPE"/>
        /// </summary>
        public NASTYPE monoStereo;
        /// <summary>
        /// Number of channels
        /// </summary>
        public UInt16 nCh;
        /// <summary>
        /// Clock Frequency, in Hz
        /// </summary>
        public float clockValue;
        /// <summary>
        /// Target NAS platform <see cref="NASchip"/>
        /// </summary>
        public NASchip nasChip;

        private CultureInfo ci = new CultureInfo("en-us");
        /// <summary>
        /// NAS commons settings constuctor
        /// </summary>
        /// <param name="ms">Mono or stereo NAS</param>
        /// <param name="nCh">Number of channels</param>
        /// <param name="CLK">Clock Frequency, in Hz</param>
        /// <param name="pNASchip">Target NAS platform</param>
        public OpenNASCommons(NASTYPE ms, UInt16 nCh, float CLK, NASchip pNASchip)
        {
            this.monoStereo = ms;
            this.nCh = nCh;
            this.clockValue = CLK;
            this.nasChip = pNASchip;
        }
        /// <summary>
        /// Writes NAS common settings in a XML file
        /// </summary>
        /// <param name="textWriter">XML text writer handler</param>
        public void toXML(XmlTextWriter textWriter)
        {
            textWriter.WriteStartElement("OpenNasCommons");
            textWriter.WriteAttributeString("nasChip", nasChip.ToString());
            textWriter.WriteAttributeString("numChannels", nCh.ToString());
            textWriter.WriteAttributeString("monoStereo", monoStereo.ToString());
            textWriter.WriteAttributeString("clockValue", clockValue.ToString(ci));

            textWriter.WriteEndElement();
        }

        /// <summary>
        /// Writes NAS common settings in a YAML file
        /// </summary>
        public YamlMappingNode toYAML()
        {
            return new YamlMappingNode(
                new YamlScalarNode("NASchip"), new YamlScalarNode(nCh.ToString()),
                new YamlScalarNode("NumChannels"), new YamlScalarNode(nCh.ToString()),
                new YamlScalarNode("MonoStereo"), new YamlScalarNode(monoStereo.ToString()),
                new YamlScalarNode("ClockValue"), new YamlScalarNode(clockValue.ToString(ci))
            );
        }
    }
}
