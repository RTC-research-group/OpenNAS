/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//    Copyright © 2016  Ángel Francisco Jimñénez-Fernández                     //
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
    /// Interaction logic for SpikesOutputControl.xaml
    /// </summary>
    public partial class SpikesOutputControl : UserControl, SpikesOutputControlInterface
    {
        SpikesOutputControlInterface currentControl;
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

            if (comboBox.SelectedIndex == 0)
            {
                SpikesDistributedMonitorControl spikesDistributedMonitor = new SpikesDistributedMonitorControl();
                spikesOutputPanel.Children.Add(spikesDistributedMonitor);
                currentControl = spikesDistributedMonitor;
            }
            InitializeControlValues(commons);
        }

        private void comboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            updateControl();
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
