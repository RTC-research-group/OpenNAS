/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                      //
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

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// This class contain Spikes-Low Pass Filter features and parameters
    /// </summary>
    public class SLPFParameters
    {
        /// <summary>
        /// SLPF Number of bits
        /// </summary>
        public UInt16 nBits;
        /// <summary>
        /// SLPF main frequency divider
        /// </summary>
        public UInt16 freqDiv;
        /// <summary>
        /// Output gain controller
        /// </summary>
        public UInt16 outDiv;
        /// <summary>
        /// Internal feedback gain controller
        /// </summary>
        public UInt16 fbDiv;
        /// <summary>
        /// SLPF Cut-off frequency
        /// </summary>
        public double realFcut;
        /// <summary>
        /// Absolute SLPF Gain
        /// </summary>
        public double realGain;
        /// <summary>
        /// SLPF Gain in dB
        /// </summary>
        public double realGaindb
        {
            get
            {
                return 10.0 * Math.Log10(realGain);
            }
        }
        /// <summary>
        /// Construct an SLPFParameters instance with provider parameters
        /// </summary>
        /// <param name="clk">SLPF main clock frequency (in Hz)</param>
        /// <param name="cutOffFreq">SLFP cut-off frequency (in Hz)</param>
        /// <param name="gaindb">SLPF gain in dB</param>
        /// <param name="minFreqDiv">Minium clock frequency divider (final one will be computer automatically)</param>
        public SLPFParameters(double clk, double cutOffFreq, double gaindb, UInt16 minFreqDiv)
        {
            UInt16[] paramSIG = OpenNasUtils.revkSIG(clk, cutOffFreq, minFreqDiv);

            nBits = paramSIG[0];
            freqDiv = paramSIG[1];
            double tempWcut = OpenNasUtils.kSIG(clk, nBits, freqDiv);
            double kdiv = 2 * Math.PI * cutOffFreq / tempWcut;
            fbDiv = OpenNasUtils.revkDiv(kdiv);
            realFcut = OpenNasUtils.kDiv(fbDiv) * tempWcut / (2 * Math.PI);

            double gain = Math.Pow(10, gaindb / 10);
            outDiv = OpenNasUtils.revkDiv(kdiv * gain);
            realGain = OpenNasUtils.kDiv(outDiv) / OpenNasUtils.kDiv(fbDiv);

        }

    }

    /// <summary>
    /// This static class contains some common operations for computing parameters related frequency scales and spike-based filters features
    /// </summary>
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
        /// <summary>
        /// Computes a set of values logaritmically distributed
        /// </summary>
        /// <param name="start">Start value</param>
        /// <param name="stop">End value</param>
        /// <param name="num">Quantity of values</param>
        /// <param name="endpoint">Indicates if should be include last element, true by default</param>
        /// <param name="numericBase">Specify space numeric base, 10 by default</param>
        /// <returns>Log Space</returns>
        public static IEnumerable<double> LogSpace(double start, double stop, int num, bool endpoint = true, double numericBase = 10.0d)
        {
            var y = LinSpace(start, stop, num: num, endpoint: endpoint);
            return Power(y, numericBase);
        }
        /// <summary>
        /// Computes Spikes-Gain Divider 16 bits parameter from an absolute gain
        /// </summary>
        /// <param name="div">Gain as absolute value</param>
        /// <returns>16 bit gain parameter</returns>
        public static UInt16 revkDiv(double div)
        {
            UInt16 result = (UInt16)((div * Math.Pow(2, 15)) - 1);
            return result;
        }
        /// <summary>
        /// Computes Spikes-Gain Divider absolute gain from a 16 bit paramter
        /// </summary>
        /// <param name="div">16 bit gain parameter</param>
        /// <returns>Gain as absolute value</returns>
        public static double kDiv(int div)
        {
            double result = div / Math.Pow(2, 15);
            return result;
        }

        /// <summary>
        /// Computes Spikes Integrate-and-Generate constant from VHDL parameters
        /// </summary>
        /// <param name="Fclk">Clock Frequency</param>
        /// <param name="nBits">Number of bits</param>
        /// <param name="freqDiv">Clock Frequency divisor</param>
        /// <returns>Spikes Integrate-and-Generate constant</returns>
        public static double kSIG(double Fclk, int nBits, UInt16 freqDiv)
        {

            double result = Fclk * 1000000 / (Math.Pow(2, nBits - 1) * (freqDiv + 1));
            return result;

        }
        /// <summary>
        /// Computes Spikes Integrate-and-Generate paramters from an specific clock and target constant
        /// </summary>
        /// <param name="Fclk">Clock frequency</param>
        /// <param name="freq">Spikes Integrate-and-Generate constant</param>
        /// <param name="minFreqDiv">Minium value for clock divisor</param>
        /// <returns>Returns Spikes Integrate-and-Generate parameters </returns>
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
            result[1] = (UInt16)freqDiv;


            return result;

        }

        /// <summary>
        /// Computes normalized error between two list of values
        /// </summary>
        /// <param name="desired">Desired Values</param>
        /// <param name="real">Real values</param>
        /// <returns></returns>
        public static double computeNomalizedError(List<double> desired, List<double> real)
        {
            double normErrorAcum = 0.0f;

            double freqDiff;

            for (int i = 0; i < desired.Count; i++)
            {
                freqDiff = Math.Abs(desired[i] - real[i]);
                normErrorAcum += freqDiff / real[i];
            }

            return normErrorAcum / desired.Count;
        }
    }
}
