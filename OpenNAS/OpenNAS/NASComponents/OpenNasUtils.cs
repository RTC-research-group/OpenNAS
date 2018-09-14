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

namespace OpenNAS_App.NASComponents
{
    public class SLPFParameters
    {
        public UInt16 nBits;
        public UInt16 freqDiv;
        public UInt16 outDiv;
        public UInt16 fbDiv;
        public double realFcut;
        public double realGain;

        public double realGaindb
        {
            get
            {
                return 10.0 * Math.Log10(realGain);
            }
        }

        public SLPFParameters(double clk, double cutOffFreq, double gaindb, UInt16 minFreqDiv)
        {
            UInt16[] paramSIG = OpenNasUtils.revkSIG(clk, cutOffFreq, minFreqDiv);

            nBits = paramSIG[0];
            freqDiv = paramSIG[1];
            double tempWcut = OpenNasUtils.kSIG(clk, nBits, freqDiv);
            double kdiv = 2 * Math.PI * cutOffFreq / tempWcut;
            fbDiv = OpenNasUtils.revkDiv(kdiv);
            realFcut = OpenNasUtils.kDiv(fbDiv) * tempWcut/(2*Math.PI);

            double gain = Math.Pow(10, gaindb / 10);
            outDiv = OpenNasUtils.revkDiv(kdiv*gain);
            realGain = OpenNasUtils.kDiv(outDiv) / OpenNasUtils.kDiv(fbDiv);

        }
        
        
        
        
        
    }


   public static class OpenNasUtils
    {

        public static IEnumerable<double> Arange(double start, int count)
        {
            return Enumerable.Range((int)start, count).Select(v => (double)v);
        }

        public static IEnumerable<double> Power(IEnumerable<double> exponents, double baseValue = 10.0d)
        {
            return exponents.Select(v => Math.Pow(baseValue, v));
        }

        public static IEnumerable<double> LinSpace(double start, double stop, int num, bool endpoint = true)
        {
            var result = new List<double>();
            if (num <= 0)
            {
                return result;
            }

            if (endpoint)
            {
                if (num == 1)
                {
                    return new List<double>() { start };
                }

                var step = (stop - start) / ((double)num - 1.0d);
                result = Arange(0, num).Select(v => (v * step) + start).ToList();
            }
            else
            {
                var step = (stop - start) / (double)num;
                result = Arange(0, num).Select(v => (v * step) + start).ToList();
            }

            return result;
        }

        public static IEnumerable<double> LogSpace(double start, double stop, int num, bool endpoint = true, double numericBase = 10.0d)
        {
            var y = LinSpace(start, stop, num: num, endpoint: endpoint);
            return Power(y, numericBase);
        }

        public static UInt16 revkDiv(double div)
        {
            UInt16 result = (UInt16)((div * Math.Pow(2, 15))-1);
            return result;
        }

        public static double kDiv(int div)
        {
            double result = div / Math.Pow(2, 15);
            return result;
        }

        public static double kSIG(double Fclk, int nBits, UInt16 freqDiv)
        {

            double result = Fclk * 1000000 / (Math.Pow(2, nBits - 1) * (freqDiv + 1));
            return result;

        }

        public static UInt16[] revkSIG(double Fclk, double freq, UInt16 minFreqDiv)
        {

            double w = freq * 2 * Math.PI;
            UInt16 nBits = 3;
            while (kSIG(Fclk, nBits + 1, minFreqDiv) > w)
            {
                nBits++;
            }

            double freqDiv = (Fclk * 1000000 / (w * Math.Pow(2, nBits - 1))) - 1;

            UInt16[] result = new UInt16[2];
            result[0] = nBits;
            result[1] = (UInt16) freqDiv;
            

            return result;

        }
    }
}
