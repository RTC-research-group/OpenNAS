﻿/////////////////////////////////////////////////////////////////////////////////
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
using System;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for PDMInputControl.xaml
    /// </summary>
    public partial class PDMInputControl : UserControl, AudioInputControlInterface
    {
        public PDMInputControl()
        {
            InitializeComponent();
        }

        public AudioInput FromControl()
        {
            float clk = commons.clockValue;
            NASTYPE type = commons.monoStereo;
            uint clkDiv = (uint)pdmDivUpDowm.Value;
            PDMAudioInput pdm = new PDMAudioInput(clk, type, clkDiv, (double)shpfCutOffUpDowm.Value, (double)slpfCutOffUpDowm.Value, (double)slpfGainUpDowm.Value);
            return pdm;
        }

        OpenNASCommons commons;

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
            pdmDivUpDowm_ValueChanged(null, null);
        }

        public void ToControl(AudioInput audioIput)
        {
            throw new NotImplementedException();
        }

        private void pdmDivUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
            {
                sysClockTextBox.Text = commons.clockValue.ToString("00.00");
                double pdmDiv = 2 * (double)pdmDivUpDowm.Value;
                double pdmClock = commons.clockValue / pdmDiv;
                pdmClockTextBox.Text = pdmClock.ToString("0.000");
            }
        }

        private void PdmDivUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void ShpfCutOffUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void SlpfCutOffUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void SlpfGainUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }
    }
}
