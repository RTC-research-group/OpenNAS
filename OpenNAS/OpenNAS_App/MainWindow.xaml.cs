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

namespace OpenNAS_App
{
    public partial class MainWindow : Window
    {
        public OpenNASArchitecture nas;
        public MainWindow()
        {
            InitializeComponent();
        }

        private void saveButton_Click(object sender, RoutedEventArgs e)
        {
            string filename = "mixml.txt";

            OpenNASArchitecture nas;
            OpenNASCommons commons = openNASCommonsControl.FromControl();
            AudioInput audioInput = audioInputControl.FromControl();
            AudioProcessingArchitecture audioProcessing = audioProcessingControl.FromControl();
            SpikesOutputInterface spikesOutput = new SpikesDistributedMonitor();

            nas = new OpenNASArchitecture(commons, audioInput, audioProcessing, spikesOutput);

            nas.toXML(filename);

            System.Diagnostics.Process.Start("notepad.exe", filename);
        }

        private void newButton_Click(object sender, RoutedEventArgs e)
        {
            var openNasWizard = new OpenNasWizard();
            openNasWizard.Show();
        }
    }
}

