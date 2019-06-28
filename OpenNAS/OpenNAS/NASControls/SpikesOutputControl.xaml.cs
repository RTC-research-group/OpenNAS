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
using System.Windows.Controls;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for SpikesOutputControl.xaml
    /// </summary>
    public partial class SpikesOutputControl : UserControl, SpikesOutputControlInterface
    {
        public enum NASAUDIOOUTPUT { AERMONITOR = 0, SPINNAKERV1 = 1, SPINNAKERV2 = 2, AERNSPINN = 3 };
        SpikesOutputControlInterface currentControl;
        public static NASAUDIOOUTPUT audioOutput;
        public OpenNASCommons commons;

        public SpikesOutputControl()
        {
            InitializeComponent();
            comboBox.SelectedIndex = 0;
            updateControl();
        }

        private void updateControl()
        {
            spikesOutputPanel.Children.Clear();

            SpikesDistributedMonitorControl spikesDistributedMonitor = new SpikesDistributedMonitorControl();
            spikesOutputPanel.Children.Add(spikesDistributedMonitor);
            currentControl = spikesDistributedMonitor;

            if (comboBox.SelectedIndex == Convert.ToInt32(NASAUDIOOUTPUT.AERMONITOR))
            {
                ACK_SpiNN_label.Visibility = System.Windows.Visibility.Hidden;
            }
            else if(comboBox.SelectedIndex == Convert.ToInt32(NASAUDIOOUTPUT.SPINNAKERV1))
            {
                ACK_SpiNN_label.Visibility = System.Windows.Visibility.Visible;
            }
            else if (comboBox.SelectedIndex == Convert.ToInt32(NASAUDIOOUTPUT.SPINNAKERV2))
            {
                ACK_SpiNN_label.Visibility = System.Windows.Visibility.Visible;
            }
            else if (comboBox.SelectedIndex == Convert.ToInt32(NASAUDIOOUTPUT.AERNSPINN))
            {
                ACK_SpiNN_label.Visibility = System.Windows.Visibility.Visible;
            }
            InitializeControlValues(commons);
        }

        private void comboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            updateControl();

            audioOutput = (NASAUDIOOUTPUT)comboBox.SelectedIndex;
        }

        public SpikesOutputInterface FromControl()
        {
            return currentControl.FromControl();
        }

        public void ToControl(SpikesOutputInterface spikesOutput)
        {
            currentControl.ToControl(spikesOutput);
        }

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
            currentControl.InitializeControlValues(commons);
        }
    }
}
