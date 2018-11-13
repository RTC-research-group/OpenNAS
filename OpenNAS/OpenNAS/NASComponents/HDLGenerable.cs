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

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// Abstract class for VHDL generation of NAS components. Integrates templates of different methods which will be called for NAS generation.
    /// </summary>
    public abstract class HDLGenerable
    {
        public void copyDependencies(string route, List<string> dependencies)
        {
            for (int i = 0; i < dependencies.Count; i++)
            {
                string[] s = dependencies[i].Split('\\');
                System.IO.File.Copy(dependencies[i], route + "\\" + s[s.Length - 1], true);
            }

        }

        public abstract void generateHDL(string route);

        public abstract void WriteTopSignals(StreamWriter sw);

        public abstract void WriteComponentArchitecture(StreamWriter sw);

        public abstract void WriteComponentInvocation(StreamWriter sw);

        public static string copyLicense()
        {
            string license;

            license =  "--///////////////////////////////////////////////////////////////////////////////\n";
            license += "--//                                                                           //\n";
            license += "--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                   //\n";
            license += "--//                                                                           //\n";
            license += "--//    This file is part of OpenNAS.                                          //\n";
            license += "--//                                                                           //\n";
            license += "--//    OpenNAS is free software: you can redistribute it and/or modify        //\n";
            license += "--//    it under the terms of the GNU General Public License as published by   //\n";
            license += "--//    the Free Software Foundation, either version 3 of the License, or      //\n";

            license += "--//    (at your option) any later version.                                    //\n";
            license += "--//                                                                           //\n";
            license += "--//    OpenNAS is distributed in the hope that it will be useful,             //\n";
            license += "--//    but WITHOUT ANY WARRANTY; without even the implied warranty of         //\n";
            license += "--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the            //\n";

            license += "--//    GNU General Public License for more details.                           //\n";
            license += "--//                                                                           //\n";
            license += "--//    You should have received a copy of the GNU General Public License      //\n";
            license += "--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.        //\n";
            license += "--//                                                                           //\n";
            license += "--///////////////////////////////////////////////////////////////////////////////\n\n";

            return license;
        }
    }
}
