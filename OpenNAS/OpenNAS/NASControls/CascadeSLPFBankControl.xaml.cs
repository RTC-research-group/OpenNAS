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
using System.Collections.Generic;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for CascadeSLPFBankControl.xaml
    /// </summary>
    public partial class CascadeSLPFBankControl : UserControl, AudioProcessingArchitectureControlInterface
    {
        private CultureInfo ci = new CultureInfo("en-us");
        private float clk;
        private OpenNASCommons commons;

        public CascadeSLPFBankControl()
        {
            InitializeComponent();
            for (int i = 0; i < 2; i++)
            {
                string temp = "[" + i + "]";
                ((DataGridTextColumn)midFreqDataGrid.Columns[i]).Binding = new Binding(temp);
                ((DataGridTextColumn)cutOffFreqDataGrid.Columns[i]).Binding = new Binding(temp);
                ((DataGridTextColumn)attDataGrid.Columns[i]).Binding = new Binding(temp);

            }

            foreach (var item in Enum.GetValues(typeof(SLPFType)))
            {
                slpfTypecomboBox.Items.Add(item);
            }
            slpfTypecomboBox.SelectedIndex = 0;

        }

        private void button_Click(object sender, RoutedEventArgs e)
        {

            CascadeSLPFBank cfb = (CascadeSLPFBank)FromControl();



            midFreqDataGrid.Items.Clear();
            cutOffFreqDataGrid.Items.Clear();
            attDataGrid.Items.Clear();

            List<double> targetFreq = cfb.midFreq;
            List<double> cutOffFreq = cfb.cutoffFreq;
            List<double> att = cfb.attenuation;


            for (int i = 0; i < targetFreq.Count; i++)
            {
                string[] s = { i + "", targetFreq[i].ToString(ci) };
                midFreqDataGrid.Items.Add(s);
            }

            for (int i = 0; i < cutOffFreq.Count; i++)
            {
                string[] s = { i + "", cutOffFreq[i].ToString(ci) };
                cutOffFreqDataGrid.Items.Add(s);
            }

            for (int i = 0; i < att.Count; i++)
            {
                string[] s = { i + "", att[i].ToString(ci) };
                attDataGrid.Items.Add(s);
            }

        }

        public void InitializeControlValues(OpenNASCommons commons)
        {
            if (commons != null)
            {
                nChTextBox.Text = commons.nCh + "";
                //          clockTextBox.Text = commons.cloclkValue + "";

                clk = commons.clockValue;

                this.commons = commons;
            }
        }
        public AudioProcessingArchitecture FromControl()
        {
            double start, stop, att;
            int nCh;
            nCh = Convert.ToInt16(nChTextBox.Text);
            start = (double)startFreqUpDowm.Value;
            stop = (double)stopFreqUpDowm.Value;
            att = (double)attUpDowm.Value;
            SLPFType slpfType = (SLPFType)slpfTypecomboBox.SelectedValue;

            CascadeSLPFBank cfb = new CascadeSLPFBank(nCh, clk, commons.monoStereo, slpfType, start, stop, att);
            return cfb;

        }

        public void ToControl(AudioProcessingArchitecture arch)
        {
            CascadeSLPFBank cfb = (CascadeSLPFBank)arch;
        }

        public void computeNas()
        {
            button_Click(null, null);
        }

        private void AttUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
                computeNas();
        }
    }
}
