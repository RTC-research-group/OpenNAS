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
using System.IO;
using System.Reflection;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;

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

            img_OpenNAS_logo.Source = new BitmapImage(new Uri("..\\Figures\\icons\\main_icon.png", UriKind.Relative));
            img_OpenNAS_logo.MaxWidth = 150;
            img_OpenNAS_logo.MaxHeight = 150;

            img_RTC_logo.Source = new BitmapImage(new Uri("..\\Figures\\icons\\logortc.png", UriKind.Relative));
            img_RTC_logo.MaxWidth = 600;
            img_RTC_logo.MaxHeight = 200;

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
            CheckFolders(route);

            nas.Generate(sourceRoute, constrainRoute, projectRoute);

            nas.ToXML(route);

            string finalMessage = "OpenN@S successfully generated at: " + route;
            finalMessage += "\n\n-------- Generation statistics --------";
            double normalizedError = nas.audioProcessing.getNormalizedError();
            normalizedError = normalizedError * 100.0;
            //normalizedError = (float)System.Math.Round(normalizedError, 6);
            finalMessage += "\n- Normalized Error = " + normalizedError.ToString("0.######") + "%";
            finalMessage += "\n- Elapsed Time: " + nas.generationTime + " ms";
            finalMessage += "\n--------------------------------------------";



            MessageBox.Show(finalMessage);

            if (openFolderCheckBox.IsChecked == true)
                System.Diagnostics.Process.Start("explorer.exe", route);
        }

        private void CheckFolders(string nasRoute)
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

        private void BrowseFolderButton_Click(object sender, RoutedEventArgs e)
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
            switch (wizardControl.CurrentPage.Name)
            {
                case "IntroPage":
                    System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki");
                    break;
                case "Page1":
                    System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki/Step-1:-NAS-commons-settings");
                    break;
                case "Page2":
                    System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki/Step-2:-NAS-audio-input-source");
                    break;
                case "Page3":
                    System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki/Step-3:-NAS-processing-architecture");
                    break;
                case "Page4":
                    System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki/Step-4:-NAS-neuromorphic-output-interface");
                    break;
                case "LastPage":
                    System.Diagnostics.Process.Start("https://github.com/RTC-research-group/OpenNAS/wiki/Step-5:-NAS-destination-folder");
                    break;
            }
        }

        private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
        {
            System.Diagnostics.Process.Start(e.Uri.ToString());
        }
    }
}
