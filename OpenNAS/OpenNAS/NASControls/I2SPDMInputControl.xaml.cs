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
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using OpenNAS_App.NASComponents;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Lógica de interacción para I2SPDMInputControl.xaml
    /// </summary>
    public partial class I2SPDMInputControl : UserControl, AudioInputControlInterface
    {
        OpenNASCommons commons;

        public I2SPDMInputControl()
        {
            InitializeComponent();
        }

        public AudioInput FromControl()
        {
            float clk = commons.clockValue;
            NASTYPE type = commons.monoStereo;
            uint clkDiv = (uint)uc_PDMInputControl.pdmDivUpDowm.Value;

            uint nBits = 20;//(uint)genNbitsUpDowm.Value;
            UInt16 clockDiv = 0x000f;//(UInt16)clockDivUpDowm.Value;

            I2S_PDMAudioInput i2spdm = new I2S_PDMAudioInput(clk, type, clkDiv, (double)uc_PDMInputControl.shpfCutOffUpDowm.Value, (double)uc_PDMInputControl.slpfCutOffUpDowm.Value, (double)uc_PDMInputControl.slpfGainUpDowm.Value, nBits, clockDiv);
            return i2spdm;
        }

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
        }

        public void ToControl(AudioInput audioIput)
        {
            throw new NotImplementedException();
        }
    }
}
