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
using System.Collections.Generic;
using System.Globalization;
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

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for AudioProcessingControl.xaml
    /// </summary>
    public partial class AudioProcessingControl : UserControl, AudioProcessingArchitectureControlInterface
    {
        private CultureInfo ci = new CultureInfo("en-us");
        public enum NASAUDIOPROCESSING { CASCADE_SLPFB = 0, PARALLEL_SLPFB = 1, PARALLEL_SBPFB = 2};
        public static NASAUDIOPROCESSING audioProcessing;
        private AudioProcessingArchitectureControlInterface currentControl;
        public OpenNASCommons commons;

        public AudioProcessingControl()
        {
            InitializeComponent();
            comboBox.SelectedIndex = 0;

            updateActiveControl();
      
        }

        private void updateActiveControl()
        {
            archPanel.Children.Clear();

            if (comboBox.SelectedIndex == 0)
            {
                
                CascadeSLPFBankControl cascadeControl = new CascadeSLPFBankControl();
                archPanel.Children.Add(cascadeControl);
                currentControl = cascadeControl;
            }
            else if (comboBox.SelectedIndex == 1)
            {
                ParallelSLPFBankControl parallelControl = new ParallelSLPFBankControl();
                archPanel.Children.Add(parallelControl);
                currentControl = parallelControl;
            }
            else 
            {
                ParallelSBPFBankControl parallelControl = new ParallelSBPFBankControl();
                archPanel.Children.Add(parallelControl);
                currentControl = parallelControl;
            }

            InitializeControlValues(this.commons);
        }


        public AudioProcessingArchitecture FromControl()
        {

            return currentControl.FromControl();

        }

        public void ToControl(AudioProcessingArchitecture arch)
        {
            currentControl.ToControl(arch);
        }

        private void comboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            updateActiveControl();

            audioProcessing = (NASAUDIOPROCESSING)comboBox.SelectedIndex;
        }

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
            currentControl.InitializeControlValues(this.commons);
        }

        public void computeNas()
        {
            currentControl.computeNas();
        }
    }
}
