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
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace OpenNAS_App.NASComponents
{
    public enum NASTYPE { MONO = 0, STEREO = 1 }
    public enum NASchip { AERNODE = 0, ZTEX = 1, SOC_DOCK = 2, OTHER = 3 }

    public class OpenNASCommons
    {
        public NASTYPE monoStereo;
        public UInt16 nCh;
        public float clockValue;
        public NASchip nasChip;

        private CultureInfo ci = new CultureInfo("en-us");

        public OpenNASCommons(NASTYPE ms, UInt16 nCh, float CLK, NASchip pNASchip)
        {
            this.monoStereo = ms;
            this.nCh = nCh;
            this.clockValue = CLK;
            this.nasChip = pNASchip;
        }

        public void toXML(XmlTextWriter textWriter)
        {
            textWriter.WriteStartElement("OpenNasCommons");
            textWriter.WriteAttributeString("nasChip", nasChip.ToString());
            textWriter.WriteAttributeString("numChannels", nCh.ToString());
            textWriter.WriteAttributeString("monoStereo", monoStereo.ToString());
            textWriter.WriteAttributeString("clockValue", clockValue.ToString(ci));

            textWriter.WriteEndElement();
        }
    }
}
