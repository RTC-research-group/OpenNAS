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

using System.Collections.Generic;
using System.Xml;
using YamlDotNet.RepresentationModel;

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// Interface for implement XML functionallities
    /// </summary>
    public interface XMLSeriarizableElement
    {
        /// <summary>
        /// Writes components settings in a XML file
        /// </summary>
        /// <param name="textWriter">XML text writer handler</param>
        void toXML(XmlTextWriter textWriter);
        //List<YamlMappingNode> toYAML();
    }

    public abstract class AudioInput : HDLGenerable, XMLSeriarizableElement
    {
        public abstract void toXML(XmlTextWriter textWriter);
        public abstract YamlSequenceNode toYAML();
    }



    public abstract class AudioProcessingArchitecture : HDLGenerable, XMLSeriarizableElement
    {
        public abstract string getShortDescription();
        public abstract void toXML(XmlTextWriter textWriter);
        public abstract YamlSequenceNode toYAML();

        public abstract double getNormalizedError();
    }

    public abstract class SpikesOutputInterface : HDLGenerable, XMLSeriarizableElement
    {
        public abstract void toXML(XmlTextWriter textWriter);
        public abstract YamlSequenceNode toYAML();
    }


}
