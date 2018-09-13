﻿/////////////////////////////////////////////////////////////////////////////////
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
    /// Interaction logic for OpenNASCommonsControl.xaml
    /// </summary>
    public partial class OpenNASCommonsControl : UserControl
    {
        public OpenNASCommonsControl()
        {
            InitializeComponent();

            foreach (var item in Enum.GetValues(typeof(NASTYPE)))
            {
                msComboBox.Items.Add(item.ToString());
            }
            msComboBox.SelectedIndex = 1;

            foreach (var item in Enum.GetValues(typeof(NASchip)))
            {
                nas_chipComboBox.Items.Add(item.ToString());
            }
            nas_chipComboBox.SelectedIndex = 0;
        }


        public OpenNASCommons FromControl()
        {
            NASTYPE ms = (NASTYPE)msComboBox.SelectedIndex;
            UInt16 nch = (UInt16) nChUpDowm.Value;
            float clock = (float) clockFreqUpDowm.Value;
            NASchip nas_chip = (NASchip)nas_chipComboBox.SelectedIndex;

            OpenNASCommons commons = new OpenNASCommons(ms, nch,clock, nas_chip);

            return commons;
        }

        public void ToControl(AudioInput audioIput)
        {

        }

        private void nas_chipComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (nas_chipComboBox.SelectedIndex == (int)NASchip.AERNODE)
            {
                img_platformUsed.Source = new BitmapImage(new Uri("..\\Figures\\NASchips\\AER-Node.png", UriKind.Relative));
                img_platformUsed.MaxWidth = 1616;
                img_platformUsed.MaxHeight = 1022;
            }
            else if (nas_chipComboBox.SelectedIndex == (int)NASchip.ZTEX)
            {
                img_platformUsed.Source = new BitmapImage(new Uri("..\\Figures\\NASchips\\ZTEX.jpg", UriKind.Relative));
                img_platformUsed.MaxWidth = 400;
                img_platformUsed.MaxHeight = 232;
            }
            else if (nas_chipComboBox.SelectedIndex == (int)NASchip.SOC_DOCK)
            {
                img_platformUsed.Source = new BitmapImage(new Uri("..\\Figures\\NASchips\\SOC-DOCK.png", UriKind.Relative));
                img_platformUsed.MaxWidth = 1432;
                img_platformUsed.MaxHeight = 1039;
            }
            else if (nas_chipComboBox.SelectedIndex == (int)NASchip.OTHER)
            {
                img_platformUsed.Source = new BitmapImage(new Uri("..\\Figures\\NASchips\\Other.png", UriKind.Relative));
                img_platformUsed.MaxWidth = 400;
                img_platformUsed.MaxHeight = 232;
            }
        }
    }
}
