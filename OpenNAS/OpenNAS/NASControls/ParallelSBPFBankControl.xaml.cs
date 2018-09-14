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
using System.Globalization;

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
            button_Click(null, null);
        }

        public AudioProcessingArchitecture FromControl()
        {
            double start, stop, att,q;
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
    }
}
