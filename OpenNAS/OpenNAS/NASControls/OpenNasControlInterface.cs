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

using OpenNAS_App.NASComponents;

namespace OpenNAS_App.NASControls
{
    public interface AudioInputControlInterface
    {
        void InitializeControlValues(OpenNASCommons commons);
        AudioInput FromControl();
        void ToControl(AudioInput audioIput);
    }
    public interface AudioProcessingArchitectureControlInterface
    {
        void InitializeControlValues(OpenNASCommons commons);
        AudioProcessingArchitecture FromControl();
        void ToControl(AudioProcessingArchitecture arch);
        void computeNas();

    }
    public interface SpikesOutputControlInterface
    {
        void InitializeControlValues(OpenNASCommons commons);
        SpikesOutputInterface FromControl();
        void ToControl(SpikesOutputInterface spikesOutput);
    }
}
