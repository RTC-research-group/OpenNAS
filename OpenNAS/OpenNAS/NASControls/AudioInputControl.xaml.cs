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
using System.Windows.Controls;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for AudioInputControl.xaml
    /// </summary>
    public partial class AudioInputControl : UserControl, AudioInputControlInterface
    {
        public enum NASAUDIOSOURCE { AC97 = 0, I2S = 1, PDM = 2, I2SPDM = 3 };
        AudioInputControlInterface currentControl;
        public static NASAUDIOSOURCE audioSource;
        public OpenNASCommons commons;
        public AudioInputControl()
        {
            InitializeComponent();
            comboBox.SelectedIndex = 1;
            updateControl();
        }

        private void updateControl()
        {
            audioInputPanel.Children.Clear();

            if (comboBox.SelectedIndex == (int)NASAUDIOSOURCE.AC97)
            {
                AC97CodecControl ac97Control = new AC97CodecControl();
                audioInputPanel.Children.Add(ac97Control);
                currentControl = ac97Control;

            }
            else if (comboBox.SelectedIndex == (int)NASAUDIOSOURCE.I2S)
            {
                I2SAudioControl i2sControl = new I2SAudioControl();
                audioInputPanel.Children.Add(i2sControl);
                currentControl = i2sControl;

            }
            else if (comboBox.SelectedIndex == (int)NASAUDIOSOURCE.PDM)
            {
                PDMInputControl pdmControl = new PDMInputControl();
                audioInputPanel.Children.Add(pdmControl);
                currentControl = pdmControl;

            }
            else if (comboBox.SelectedIndex == (int)NASAUDIOSOURCE.I2SPDM)
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

            audioSource = (NASAUDIOSOURCE)comboBox.SelectedIndex;
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
