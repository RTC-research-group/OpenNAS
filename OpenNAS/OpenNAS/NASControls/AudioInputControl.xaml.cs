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
    /// Interaction logic for AudioInputControl.xaml
    /// </summary>
    public partial class AudioInputControl : UserControl, AudioInputControlInterface
    {
        public enum NASAUDIOSOURCE {AC97 = 0, I2S = 1, PDM = 2, I2SPDM = 3 };
        AudioInputControlInterface currentControl;
        public static NASAUDIOSOURCE audioSource;
        public OpenNASCommons commons;
        public AudioInputControl()
        {
            InitializeComponent();
            comboBox.SelectedIndex = 0;
            updateControl();
        }

        private void updateControl()
        {
            audioInputPanel.Children.Clear();

            if (comboBox.SelectedIndex == 0)
            {
                AC97CodecControl ac97Control = new AC97CodecControl();
                audioInputPanel.Children.Add(ac97Control);
                currentControl = ac97Control;

            }
            else if (comboBox.SelectedIndex == 1)
            {
                I2SAudioControl i2sControl = new I2SAudioControl();
                audioInputPanel.Children.Add(i2sControl);
                currentControl = i2sControl;

            }
            else if (comboBox.SelectedIndex == 2)
            {
                PDMInputControl pdmControl = new PDMInputControl();
                audioInputPanel.Children.Add(pdmControl);
                currentControl = pdmControl;

            }
            else if (comboBox.SelectedIndex == 3)
            {
                I2SPDMInputControl i2spdmControl = new I2SPDMInputControl();
                audioInputPanel.Children.Add(i2spdmControl);
                currentControl = i2spdmControl;

            }


            InitializeControlValues(commons);
        }

        private void comboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            updateControl();

            audioSource =  (NASAUDIOSOURCE)comboBox.SelectedIndex;
        }

        public AudioInput FromControl()
        {
            return currentControl.FromControl();
        }

        public void ToControl(AudioInput audioIput)
        {
            currentControl.ToControl(audioIput);
        }

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
            currentControl.InitializeControlValues(commons);
        }
    }
}
