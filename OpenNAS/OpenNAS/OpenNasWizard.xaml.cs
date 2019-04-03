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
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace OpenNAS_App
{
    /// <summary>
    /// Interaction logic for OpenNasWizard.xaml
    /// </summary>
    public partial class OpenNasWizard : Window
    {
        private OpenNASArchitecture nas;
        private string route = "";

        public OpenNasWizard()
        {
            InitializeComponent();

            //Checks startup routes and folder
            string baseRoute = System.IO.Path.GetDirectoryName(Assembly.GetEntryAssembly().Location) + "\\Projects";
            bool folderExists = Directory.Exists(baseRoute);
            if (!folderExists)
                Directory.CreateDirectory(baseRoute);
            routeTextBox.Text = baseRoute;
            route = baseRoute;

        }

        private void Wizard_Finish(object sender, RoutedEventArgs e)
        {
            
            OpenNASCommons commons = openNASCommonsControl.FromControl();
            AudioInput audioInput = audioInputControl.FromControl();
            AudioProcessingArchitecture audioProcessing = audioProcessingControl.FromControl();
            SpikesOutputInterface spikesOutput = spikesMonitorControl.FromControl();

            nas = new OpenNASArchitecture(commons, audioInput, audioProcessing, spikesOutput);

            string sourceRoute = route + "\\sources";
            string constrainRoute = route + "\\constraints";
            string projectRoute = route + "\\project";
            checkFolders(route);

            nas.toXML(route);

            nas.Generate(sourceRoute, constrainRoute, projectRoute);

            MessageBox.Show("OpenN@S successfully generated at: " + route);

            if(openFolderCheckBox.IsChecked==true)
                System.Diagnostics.Process.Start("explorer.exe",route);
        }

        private void checkFolders (string nasRoute)
        {
            string sourceRoute = route + "\\sources";
            bool folderExists = Directory.Exists(sourceRoute);
            if (!folderExists)
                Directory.CreateDirectory(sourceRoute);

            string constrainRoute = route + "\\constraints";
            folderExists = Directory.Exists(constrainRoute);
            if (!folderExists)
                Directory.CreateDirectory(constrainRoute);
            string projectRoute = route + "\\project";
            folderExists = Directory.Exists(projectRoute);
            if (!folderExists)
                Directory.CreateDirectory(projectRoute);
        }

        private void Wizard_Next(object sender, Xceed.Wpf.Toolkit.Core.CancelRoutedEventArgs e)
        {
            if (wizardControl.CurrentPage == Page1)
            {
                OpenNASCommons commons = openNASCommonsControl.FromControl();
                audioInputControl.InitializeControlValues(commons);
                audioProcessingControl.InitializeControlValues(commons);
                spikesMonitorControl.InitializeControlValues(commons);
            }
            else if (wizardControl.CurrentPage == Page2)
            {
                audioProcessingControl.computeNas();
            }
        }

        private void browseFolderButton_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (dialog.SelectedPath != "")
            {
                route = dialog.SelectedPath;

                routeTextBox.Text = route;
            }
        }

        private void Wizard_Help(object sender, RoutedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki");
        }
    }
}
