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
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;

namespace OpenNAS_App.NASControls
{
    /// <summary>
    /// Interaction logic for ParallelSBPFBankControl.xaml
    /// </summary>
    public partial class ParallelSBPFBankControl : UserControl, AudioProcessingArchitectureControlInterface
    {
        private CultureInfo ci = new CultureInfo("en-us");
        private float clk;
        private OpenNASCommons commons;

        public ParallelSBPFBankControl()
        {
            InitializeComponent();
            for (int i = 0; i < 2; i++)
            {
                string temp = "[" + i + "]";
                ((DataGridTextColumn)midFreqDataGrid.Columns[i]).Binding = new Binding(temp);
                ((DataGridTextColumn)qFactorDataGrid.Columns[i]).Binding = new Binding(temp);
                ((DataGridTextColumn)attDataGrid.Columns[i]).Binding = new Binding(temp);

            }
        }

        public void computeNas()
        {
            ParallelSBPFBank pfb = (ParallelSBPFBank)FromControl();

            midFreqDataGrid.Items.Clear();
            qFactorDataGrid.Items.Clear();
            attDataGrid.Items.Clear();

            List<double> targetFreq = pfb.midFreq;
            List<double> qFactor = pfb.Q;
            List<double> att = pfb.attenuation;


            for (int i = 0; i < targetFreq.Count; i++)
            {
                string[] s = { i + "", targetFreq[i].ToString(ci) };
                midFreqDataGrid.Items.Add(s);
            }

            for (int i = 0; i < qFactor.Count; i++)
            {
                string[] s = { i + "", qFactor[i].ToString(ci) };
                qFactorDataGrid.Items.Add(s);
            }

            for (int i = 0; i < att.Count; i++)
            {
                string[] s = { i + "", att[i].ToString(ci) };
                attDataGrid.Items.Add(s);
            }
        }

        public AudioProcessingArchitecture FromControl()
        {
            double start, stop, att, q;
            int nCh;
            nCh = Convert.ToInt16(nChTextBox.Text);
            start = (double)startFreqUpDowm.Value;
            stop = (double)stopFreqUpDowm.Value;
            q = (double)qFactorUpDowm.Value;
            att = (double)attUpDowm.Value;


            ParallelSBPFBank cfb = new ParallelSBPFBank(nCh, clk, commons.monoStereo, start, stop, q, att);
            return cfb;

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

        public void ToControl(AudioProcessingArchitecture arch)
        {
            throw new NotImplementedException();
        }

        private void button_Click(object sender, RoutedEventArgs e)
        {
            ParallelSBPFBank pfb = (ParallelSBPFBank)FromControl();
                       
            midFreqDataGrid.Items.Clear();
            qFactorDataGrid.Items.Clear();
            attDataGrid.Items.Clear();

            List<double> targetFreq = pfb.midFreq;
            List<double> qFactor = pfb.Q;
            List<double> att = pfb.attenuation;


            for (int i = 0; i < targetFreq.Count; i++)
            {
                string[] s = { i + "", targetFreq[i].ToString(ci) };
                midFreqDataGrid.Items.Add(s);
            }

            for (int i = 0; i < qFactor.Count; i++)
            {
                string[] s = { i + "", qFactor[i].ToString(ci) };
                qFactorDataGrid.Items.Add(s);
            }

            for (int i = 0; i < att.Count; i++)
            {
                string[] s = { i + "", att[i].ToString(ci) };
                attDataGrid.Items.Add(s);
            }
        }

        private void AttUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
                computeNas();
        }

        private void QFactorUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
            {
                computeNas();
            }
        }

        private void StopFreqUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
            {
                computeNas();
            }
        }

        private void StartFreqUpDowm_ValueChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (commons != null)
            {
                computeNas();
            }
        }

        private void AttUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void QFactorUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void StopFreqUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }

        private void StartFreqUpDowm_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            e.Handled = Regex.IsMatch(e.Text, "[^0-9]+");
        }
    }
}
