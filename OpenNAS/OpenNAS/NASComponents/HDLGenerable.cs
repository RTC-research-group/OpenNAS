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

using System.Collections.Generic;
using System.IO;

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// Abstract class for VHDL generation of NAS components. Integrates templates of different methods which will be called for NAS generation.
    /// </summary>
    public abstract class HDLGenerable
    {
        /// <summary>
        /// This function copy the dependency of a HDL module
        /// </summary>
        /// <param name="route">The route of dependency files destination</param>
        /// <param name="dependencies">The list of all dependencies</param>
        public void copyDependencies(string route, List<string> dependencies)
        {
            for (int i = 0; i < dependencies.Count; i++)
            {
                string[] s = dependencies[i].Split('\\');
                System.IO.File.Copy(dependencies[i], route + "\\" + s[s.Length - 1], true);
            }

        }
        /// <summary>
        /// Generate the specific component top file HDL
        /// </summary>
        /// <param name="route">The route of dependency files destination</param>
        public abstract void generateHDL(string route);

        /// <summary>
        /// Writes the I/O signals in NAS top file
        /// </summary>
        /// <param name="sw">Handle to NAS top file</param>
        public abstract void WriteTopSignals(StreamWriter sw);

        /// <summary>
        /// Writes the component architectura in NAS top file
        /// </summary>
        /// <param name="sw">Handle to NAS top file</param>
        public abstract void WriteComponentArchitecture(StreamWriter sw);

        /// <summary>
        /// Writes the component invocation in NAS top file
        /// </summary>
        /// <param name="sw">Handle to NAS top file</param>
        public abstract void WriteComponentInvocation(StreamWriter sw);

        /// <summary>
        /// Summarizes the current NAS license as an string, to be copied as files header
        /// </summary>
        /// /// <param name="fileType">Indicates the file's extension to copy the license</param>
        /// <returns>Current NAS license</returns>
        public static string copyLicense(char fileType)
        {
            string license;
            string commentFormat;

            if (fileType == 'H')
            {
                commentFormat = "--";
            }
            else if (fileType == 'C')
            {
                commentFormat = "#";
            }
            else
            {
                commentFormat = "//";
            }
            license = commentFormat + "///////////////////////////////////////////////////////////////////////////////\n";
            license += commentFormat + "//                                                                           //\n";
            license += commentFormat + "//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                   //\n";
            license += commentFormat + "//                                                                           //\n";
            license += commentFormat + "//    This file is part of OpenNAS.                                          //\n";
            license += commentFormat + "//                                                                           //\n";
            license += commentFormat + "//    OpenNAS is free software: you can redistribute it and/or modify        //\n";
            license += commentFormat + "//    it under the terms of the GNU General Public License as published by   //\n";
            license += commentFormat + "//    the Free Software Foundation, either version 3 of the License, or      //\n";
            license += commentFormat + "//    (at your option) any later version.                                    //\n";
            license += commentFormat + "//                                                                           //\n";
            license += commentFormat + "//    OpenNAS is distributed in the hope that it will be useful,             //\n";
            license += commentFormat + "//    but WITHOUT ANY WARRANTY; without even the implied warranty of         //\n";
            license += commentFormat + "//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the            //\n";
            license += commentFormat + "//    GNU General Public License for more details.                           //\n";
            license += commentFormat + "//                                                                           //\n";
            license += commentFormat + "//    You should have received a copy of the GNU General Public License      //\n";
            license += commentFormat + "//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.        //\n";
            license += commentFormat + "//                                                                           //\n";
            license += commentFormat + "///////////////////////////////////////////////////////////////////////////////\n\n";

            return license;
        }
    }
}
