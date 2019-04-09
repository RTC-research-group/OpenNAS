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
using System;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for AC97CodecControl.xaml
    /// </summary>
    public partial class AC97CodecControl : UserControl, AudioInputControlInterface
    {
        public AC97CodecControl()
        {
            InitializeComponent();
            foreach (var item in Enum.GetValues(typeof(AC97AudioSource)))
            {
                comboBox.Items.Add(item);
            }
            comboBox.SelectedIndex = 0;
        }

        OpenNASCommons commons;

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
            clockDivUpDowm_ValueChanged(null, null);
        }
        public AudioInput FromControl()
        {
            uint nBits = (uint)genNbitsUpDowm.Value;
            UInt16 clockDiv = (UInt16)clockDivUpDowm.Value;
            AC97AudioInput ac97 = new AC97AudioInput((AC97AudioSource)comboBox.SelectedIndex, commons.clockValue, commons.monoStereo, nBits, clockDiv);
            return ac97;

        }

        public void ToControl(AudioInput audioIput)
        {

        }

        private void clockDivUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
            {
                uint nBits = (uint)genNbitsUpDowm.Value;
                uint clockDiv = (uint)clockDivUpDowm.Value;

                float kgen = 1000 * commons.clockValue / ((float)Math.Pow(2, nBits - 1) * (clockDiv + 1));
                kgenText.Text = kgen.ToString("0.0000");
                float max = kgen * (float)Math.Pow(2, nBits - 1);

                maxText.Text = max.ToString("0.0000");
            }



        }

        private void ClockDivUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void GenNbitsUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }
    }
}


