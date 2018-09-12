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
    /// Interaction logic for SpikesDistributedMonitor.xaml
    /// </summary>
    public partial class SpikesDistributedMonitorControl : UserControl, SpikesOutputControlInterface
    {
        public SpikesDistributedMonitorControl()
        {
            InitializeComponent();
        }

        public SpikesOutputInterface FromControl()
        {
            
            UInt16 aerFifoBits = (UInt16)aerFifoUpDowm.Value;
            UInt16 spikesFifoBits = (UInt16)spikesFifoUpDowm.Value;

            UInt16 nch;
            if (commons.monoStereo == NASTYPE.MONO)
            {
                nch = commons.nCh;
            }
            else{
                nch = (UInt16)(2*commons.nCh);
            }

            return new SpikesDistributedMonitor(nch, aerFifoBits, spikesFifoBits);
        }
        OpenNASCommons commons;

        public void InitializeControlValues(OpenNASCommons commons)
        {
            this.commons = commons;
            UpdateMemoryValues();
        }

        public void UpdateMemoryValues()
        {


            if (this.commons != null)
            {
                UInt16 nch;
                if (commons.monoStereo == NASTYPE.MONO)
                {
                    nch = (UInt16)(commons.nCh);
                }
                else {
                    nch = (UInt16)(2 * commons.nCh);
                }

                totalSignalsText.Text = "" + (2 * nch);

                double memory;

                memory = (Math.Log(commons.nCh, 2) + 1) * Math.Pow(2, (double)aerFifoUpDowm.Value);

                memory += (commons.nCh * 2) * Math.Pow(2, (double)spikesFifoUpDowm.Value);

                totalBitsText.Text = memory.ToString();
            }


        }

        public void ToControl(SpikesOutputInterface spikesOutput)
        {
            
        }

        private void spikesFifoUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            UpdateMemoryValues();
        }
    }
}
