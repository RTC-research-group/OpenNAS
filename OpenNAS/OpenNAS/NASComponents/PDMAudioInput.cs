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
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// This class implements a PDM MIC audio input stage. <see cref="AudioInput"/> 
    /// </summary>
    public class PDMAudioInput : AudioInput
    {
        /// <summary>
        /// NAS type (mono or stereo)
        /// </summary>
        public NASTYPE nasType;
        /// <summary>
        /// Clock Frequency, in Hz
        /// </summary>
        public float clk;
        /// <summary>
        /// Clock divider factor for generating PDM clock
        /// </summary>
        public uint clkDiv;
        /// <summary>
        /// PDM Input SHPF cut-off frequency, in Hz
        /// </summary>
        public double shpfCutOff;
        /// <summary>
        /// PDM Output SLPF cut-off frequency, in Hz
        /// </summary>
        public double slpfCutOff;
        /// <summary>
        /// PDM Output SLPF gain, as absolute value
        /// </summary>
        public double slpfGain;
        /// <summary>
        /// Gives an instance of PDM audio input
        /// </summary>
        /// <param name="clk">Clock frequency in Hz</param>
        /// <param name="nasType">NAS type (mono or stereo)</param>
        /// <param name="clkDiv">Clock divider factor for generating PDM clock</param>
        /// <param name="shpfCutOff"> PDM Input SHPF cut-off frequency, in Hz</param>
        /// <param name="slpfCutOff">PDM Output SLPF cut-off frequency, in Hz</param>
        /// <param name="slpfGain">PDM Output SLPF gain, as absolute value</param>
        public PDMAudioInput(float clk, NASTYPE nasType, uint clkDiv, double shpfCutOff, double slpfCutOff, double slpfGain)
        {
            this.clk = clk;
            this.nasType = nasType;
            this.clkDiv = clkDiv;
            this.shpfCutOff = shpfCutOff;
            this.slpfCutOff = slpfCutOff;
            this.slpfGain = slpfGain;
        }

        /// <summary>
        /// Generates a PDM input stage, copying library files, and generating custom sources
        /// </summary>
        /// <param name="route">Destination files route</param>
        public override void generateHDL(string route)
        {
            List<string> dependencies = new List<string>();
            dependencies.Add(@"SSPLibrary\Components\PDM_Interface.vhd");
            dependencies.Add(@"SSPLibrary\Components\PDM2Spikes.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\Spike_Int_n_Gen_BW.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\AER_DIF.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\AER_HOLDER_AND_FIRE.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_div_BW.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_LPF_fullGain.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_2LPF_fullGain.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_HPF.vhd");
            
            copyDependencies(route, dependencies);
        }

        /// <summary>
        /// Writes PDM input interface settings in a XML file
        /// </summary>
        /// <param name="textWriter">XML text writer handler</param>
        public override void toXML(XmlTextWriter textWriter)
        {
            textWriter.WriteStartElement("PDMInput");
            textWriter.WriteAttributeString("clkDiv", clkDiv.ToString());
            textWriter.WriteAttributeString("shpfCutOff", shpfCutOff.ToString());
            textWriter.WriteAttributeString("slpfCutOff", slpfCutOff.ToString());
            textWriter.WriteAttributeString("slpfGain", slpfGain.ToString());
            textWriter.WriteEndElement();
        }

        /// <summary>
        /// Writes a PDM input stage component architecture <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentArchitecture(StreamWriter sw)
        {
            sw.WriteLine("--PDM interface");
            sw.WriteLine("component PDM2Spikes is");
            sw.WriteLine("generic (SLPF_GL: in integer; SLPF_SAT: in integer; SHPF_GL: in integer; SHPF_SAT: in integer);");
            sw.WriteLine("port (");
            sw.WriteLine("  clk: in std_logic;");
            sw.WriteLine("  rst: in std_logic;");
            sw.WriteLine("  clock_div: in std_logic_vector(7 downto 0);");
            sw.WriteLine("--PDM Signals");
            sw.WriteLine("  PDM_CLK  : out std_logic;");
            sw.WriteLine("  PDM_DAT: in std_logic;");
            sw.WriteLine("--Anti-Offset SHPF");
            sw.WriteLine("  SHPF_FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);");
            sw.WriteLine("--Anti-Aliasing SLPF");
            sw.WriteLine("  SLPF_FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);");
            sw.WriteLine("  SLPF_SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("  SLPF_SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("--Spikes Output");
            sw.WriteLine("  SPIKES_OUT: out std_logic_vector(1 downto 0)");
            sw.WriteLine(");");
            sw.WriteLine("end component;");
            sw.WriteLine("");
            
        }

        /// <summary>
        /// Writes a PDM input component invocation and link signals<see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentInvocation(StreamWriter sw)
        {
            SLPFParameters slpf = new SLPFParameters(clk, slpfCutOff, slpfGain, 3);

            SLPFParameters shpf = new SLPFParameters(clk, shpfCutOff, 0, 3);

            
            double pdmClock = clk / (clkDiv * 2);
            sw.WriteLine("");
            sw.WriteLine("--PDM interface");

            double realFreq = OpenNasUtils.kSIG(clk, shpf.nBits, shpf.freqDiv)/(2*Math.PI);
            double freqError = 100 * ((shpfCutOff - realFreq) / shpfCutOff);
            sw.WriteLine("--Anti-Offset SHPF");
            string filterInfo = "--Ideal cutoff: " + shpfCutOff.ToString("0.0000") + "Hz - Real cutoff: " + realFreq.ToString("0.0000") + "Hz - Error: " + freqError.ToString("0.0000") + "%";
            sw.WriteLine(filterInfo);

            realFreq = slpf.realFcut;
            freqError = 100 * ((slpfCutOff - realFreq) / slpfCutOff);
            sw.WriteLine("--Anti-Aliasing SLPF");
            filterInfo = "--Ideal cutoff: " + slpfCutOff.ToString("0.0000") + "Hz - Real cutoff: " + realFreq.ToString("0.0000") + "Hz - Error: " + freqError.ToString("0.0000") + "%";
            sw.WriteLine(filterInfo);
            filterInfo = "--Ideal Gain: " + slpfGain.ToString("0.0000") + "dB - Real Gain: " + slpf.realGaindb.ToString("0.000") + "dB ("+ slpf.realGain.ToString("0.000") + ")";
            sw.WriteLine(filterInfo);
            sw.WriteLine("");

            sw.WriteLine("U_PDM2Spikes_Left: PDM2Spikes");
            sw.WriteLine("generic map(SLPF_GL => " + slpf.nBits + ", SLPF_SAT => " + (int)(Math.Pow(2, slpf.nBits - 1) - 1) + ", SHPF_GL => " + shpf.nBits + ", SHPF_SAT => " + (int)(Math.Pow(2, shpf.nBits - 1) - 1) + " )");
            sw.WriteLine("port map (");
            sw.WriteLine("clk => clock,");
            sw.WriteLine("rst => reset,");
            sw.WriteLine("clock_div => x\""+(this.clkDiv-1).ToString("X2")+"\", --PDM clock: +"+pdmClock.ToString("0.000")+"MHz");
            sw.WriteLine("PDM_CLK => PDM_CLK_LEFT,");
            sw.WriteLine("PDM_DAT => PDM_DAT_LEFT,");
            sw.WriteLine("SHPF_FREQ_DIV => x\"" + shpf.freqDiv.ToString("X2") + "\",");
            sw.WriteLine("SLPF_FREQ_DIV => x\"" + slpf.freqDiv.ToString("X2") + "\",");
            sw.WriteLine("SLPF_SPIKES_DIV_FB => x\"" + slpf.fbDiv.ToString("X4") + "\",");
            sw.WriteLine("SLPF_SPIKES_DIV_OUT => x\"" + slpf.outDiv.ToString("X4") + "\",");
            sw.WriteLine("--Spikes Output");
            sw.WriteLine("spikes_out => spikes_in_left");
            sw.WriteLine(");");
            sw.WriteLine("");

            if (nasType == NASTYPE.STEREO)
            {

                sw.WriteLine("U_PDM2Spikes_Rigth: PDM2Spikes");
                sw.WriteLine("generic map(SLPF_GL => " + slpf.nBits + ", SLPF_SAT => " + (int)(Math.Pow(2, slpf.nBits - 1) - 1) + ", SHPF_GL => " + shpf.nBits + ", SHPF_SAT => " + (int)(Math.Pow(2, shpf.nBits - 1) - 1) + " )");
                sw.WriteLine("port map (");
                sw.WriteLine("clk => clock,");
                sw.WriteLine("rst => reset,");
                sw.WriteLine("clock_div => x\""+(this.clkDiv-1).ToString("X2")+"\", --PDM clock: +" + pdmClock.ToString("0.000") + "MHz");
                sw.WriteLine("PDM_CLK => PDM_CLK_RIGTH,");
                sw.WriteLine("PDM_DAT => PDM_DAT_RIGTH,");
                sw.WriteLine("SHPF_FREQ_DIV => x\"" + shpf.freqDiv.ToString("X2") + "\",");
                sw.WriteLine("SLPF_FREQ_DIV => x\"" + slpf.freqDiv.ToString("X2") + "\",");
                sw.WriteLine("SLPF_SPIKES_DIV_FB => x\"" + slpf.fbDiv.ToString("X4") + "\",");
                sw.WriteLine("SLPF_SPIKES_DIV_OUT => x\"" + slpf.outDiv.ToString("X4") + "\",");
                sw.WriteLine("--Spikes Output");
                sw.WriteLine("spikes_out => spikes_in_rigth");
                sw.WriteLine(");");
                sw.WriteLine("");

            }

        }
        /// <summary>
        /// Writes PDM input stage top signals <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteTopSignals(StreamWriter sw)
        {
            sw.WriteLine("--PDM Interface");
            sw.WriteLine("  PDM_CLK_LEFT  : out std_logic;");
            sw.WriteLine("  PDM_DAT_LEFT  : in std_logic;");
            if (nasType == NASTYPE.STEREO)
            {
                sw.WriteLine("  PDM_CLK_RIGTH  : out std_logic;");
                sw.WriteLine("  PDM_DAT_RIGTH  : in std_logic;");
            }
        }
    }
}
