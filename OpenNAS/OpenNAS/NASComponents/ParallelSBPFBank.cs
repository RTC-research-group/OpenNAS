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
using System.Globalization;
using System.IO;
using System.Linq;
using System.Xml;
using YamlDotNet.RepresentationModel;

namespace OpenNAS_App.NASComponents
{

    /// <summary>
    /// Class for implementing a bank of SBPF filters with a parallel topology, implements AudioProcessingArchitecture <see cref="AudioProcessingArchitecture"/>
    /// </summary>
    class ParallelSBPFBank : AudioProcessingArchitecture
    {
        /// <summary>
        /// Number of channels
        /// </summary>
        public int nCH = 0;
        /// <summary>
        /// Clock frequency in Hz
        /// </summary>
        public float clk;
        /// <summary>
        /// NAS mono or stereo
        /// </summary>
        public NASTYPE nasType;
        /// <summary>
        /// List of channels mid frequencies
        /// </summary>
        public List<double> midFreq;
        /// <summary>
        /// List of channels real mid frequencies
        /// </summary>
        public List<double> realMidFreq;
        /// <summary>
        /// List of channels Q factor
        /// </summary>
        public List<double> Q;
        /// <summary>
        /// Indivicual channel ouput attenuation, as an absolute value
        /// </summary>
        public List<double> attenuation;
        /// <summary>
        /// Normalized error after filter bank adjustement.
        /// </summary>
        public double nomalizedError;

        private CultureInfo ci = new CultureInfo("en-us");

        /// <summary>
        /// Basic ParallelSBPFBank constructor
        /// </summary>
        public ParallelSBPFBank() { }

        /// <summary>
        /// Main CascadesLPFBank constructor
        /// </summary>
        /// <param name="nCH">Number of channels</param>
        /// <param name="clk">Clock frequency in Hz</param>
        /// <param name="nasType">NAS mono or stereo</param>
        /// <param name="startFreq">Start mid frequency, in Hz</param>
        /// <param name="stopFreq">Last mid frequency, in Hz</param>
        /// <param name="Q">Filters Quality Factor</param>
        /// <param name="att">Filters output attenuation, as an absolute value</param>
        public ParallelSBPFBank(int nCH, float clk, NASTYPE nasType, double startFreq, double stopFreq, double Q, double att)
        {
            double start, stop;

            this.nCH = nCH;
            this.clk = clk;
            this.nasType = nasType;


            start = Math.Log10(startFreq);
            stop = Math.Log10(stopFreq);

            this.midFreq = (OpenNasUtils.LogSpace(start, stop, nCH)).ToList<double>();
            this.midFreq.Reverse();


            this.attenuation = new List<double>();
            this.Q = new List<double>();
            for (int i = 0; i < nCH; i++)
            {
                this.Q.Add(Q);
                this.attenuation.Add(att);
            }

            realMidFreq = new List<double>();
        }

        /// <summary>
        /// Writes SBPF bank features in a XML file
        /// </summary>
        /// <param name="textWriter">XmlTextWriter handler</param>
        public override void toXML(XmlTextWriter textWriter)
        {
            int i = 0;

            textWriter.WriteStartElement("ParallelSBPFBank");
            textWriter.WriteAttributeString("nCH", nCH.ToString());
            textWriter.WriteAttributeString("normError", nomalizedError.ToString(ci));

            textWriter.WriteStartElement("midFreq");
            foreach (double d in midFreq)
            {
                textWriter.WriteStartElement("Freq");
                textWriter.WriteAttributeString("id", i.ToString());
                textWriter.WriteAttributeString("freq", d.ToString(ci));
                textWriter.WriteAttributeString("Q", Q[i].ToString(ci));
                textWriter.WriteAttributeString("attenuation", attenuation[i].ToString(ci));
                i++;
                textWriter.WriteEndElement();
            }
            textWriter.WriteEndElement();
        }



        /// <summary>
        /// Writes SBPF bank features in a YAML file
        /// </summary>
        public override YamlSequenceNode toYAML()
        {
            YamlSequenceNode res = new YamlSequenceNode();
            /*
            YamlSequenceNode ysm_mid = new YamlSequenceNode();
            YamlMappingNode ymn_mid = new YamlMappingNode();
            int i = 0;
            foreach (double d in midFreq)
            {
                ymn_mid.Add(new YamlScalarNode(i.ToString()), new YamlScalarNode(d.ToString()));
                i++;
            }
            ysm_mid.Add(ymn_mid);

            YamlSequenceNode ysm_q = new YamlSequenceNode();
            YamlMappingNode ymn_q = new YamlMappingNode();
            i = 0;
            foreach (double d in Q)
            {
                ymn_q.Add(new YamlScalarNode(i.ToString()), new YamlScalarNode(d.ToString(ci)));
                i++;
            }
            ysm_q.Add(ymn_q);

            YamlSequenceNode ysm_att = new YamlSequenceNode();
            YamlMappingNode ymn_att = new YamlMappingNode();
            i = 0;
            foreach (double d in attenuation)
            {
                ymn_att.Add(new YamlScalarNode(i.ToString()), new YamlScalarNode(d.ToString(ci)));
                i++;
            }
            ysm_att.Add(ymn_att);
            */


            YamlSequenceNode ysm_slpf = new YamlSequenceNode();

            int i = 0;
            for (i = 0; i < nCH; i++)
            {
                ysm_slpf.Add(new YamlMappingNode(
                    new YamlScalarNode("CH"), new YamlScalarNode(i.ToString()),
                    new YamlScalarNode("FREQ_DIV"), new YamlScalarNode("0x" + freqDiv[i].ToString("X2")),
                    new YamlScalarNode("SPIKES_DIV"), new YamlScalarNode("0x" + igDiv[i].ToString("X4")),
                    new YamlScalarNode("SPIKES_DIV_FB"), new YamlScalarNode("0x" + fbDiv[i].ToString("X4")),
                    new YamlScalarNode("SPIKES_DIV_OUT"), new YamlScalarNode("0x" + attDiv[i].ToString("X4"))
                    
                    )
                );
            }

            res.Add(new YamlMappingNode(                
                new YamlScalarNode("NormError"), new YamlScalarNode(nomalizedError.ToString()),
                new YamlScalarNode("Channels"), ysm_slpf
                //new YamlScalarNode("MidFreqs"), ysm_mid,
                //new YamlScalarNode("FilterOrder"), ysm_q,
                //new YamlScalarNode("Attenuation"), ysm_att
            ));

            return res;
        }



        private List<UInt16> nBits;
        private List<UInt16> freqDiv;
        private List<UInt16> igDiv;
        private List<UInt16> fbDiv;
        private List<UInt16> attDiv;
        private List<double> realFcut;

        private void computeFiltersParameters()
        {
            nBits = new List<UInt16>();
            freqDiv = new List<UInt16>();
            igDiv = new List<UInt16>();
            fbDiv = new List<UInt16>();
            attDiv = new List<UInt16>();
            realFcut = new List<double>();

            realMidFreq.Clear();

            for (int i = 0; i < midFreq.Count; i++)
            {
                UInt16[] paramSIG = OpenNasUtils.revkSIG(clk, midFreq[i], 1);
                nBits.Add(paramSIG[0]);
                freqDiv.Add(paramSIG[1]);
                double tempWcut = OpenNasUtils.kSIG(clk, paramSIG[0], paramSIG[1]);
                double wrelation = 2 * Math.PI * midFreq[i] / tempWcut;
                igDiv.Add(OpenNasUtils.revkDiv(wrelation));

                fbDiv.Add((UInt16)(OpenNasUtils.revkDiv(1.0 / Q[i])));

                double realWcut = (OpenNasUtils.kSIG(clk, nBits[i], freqDiv[i]) * OpenNasUtils.kDiv(igDiv[i])) / (2 * Math.PI);
                realMidFreq.Add(realWcut);
            }

            nomalizedError = OpenNasUtils.computeNomalizedError(midFreq, realMidFreq);

            for (int k = 0; k < attenuation.Count; k++)
            {
                double tempAtt = (1.0 / Q[k]) * Math.Pow(10, attenuation[k] / 20);

                attDiv.Add(OpenNasUtils.revkDiv(tempAtt));
            }

            
        }

        /// <summary>
        /// Gets normalized Eror after parameters setup
        /// </summary>
        /// <returns>Normalized Error </returns>
        public override double getNormalizedError()
        {
            if (midFreq == null || realMidFreq == null)
            {
                return 0;
            }
            else
            {
                return nomalizedError;
            }
        }

        private void generatePFB(string route)
        {

            computeFiltersParameters();
            StreamWriter sw = new StreamWriter(route + "\\PFBank_" + nCH + ".vhd");

            sw.WriteLine(HDLGenerable.copyLicense('H'));

            sw.WriteLine("library IEEE;");
            sw.WriteLine("use IEEE.STD_LOGIC_1164.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_ARITH.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_UNSIGNED.ALL;");

            sw.WriteLine("");
            string entity = "PFBank_" + nCH + "CH";

            sw.WriteLine("entity " + entity + " is");
            sw.WriteLine("    Port (");
            sw.WriteLine("        clock      : in  STD_LOGIC;");
            sw.WriteLine("        rst        : in  STD_LOGIC;");
            sw.WriteLine("        spikes_in  : in  STD_LOGIC_VECTOR(1 downto 0);");
            sw.WriteLine("        spikes_out : out STD_LOGIC_VECTOR(" + (nCH * 2 - 1) + " downto 0)");
            sw.WriteLine("    );");
            sw.WriteLine("end " + entity + ";");
            sw.WriteLine("");

            sw.WriteLine("architecture PFBank_arq of " + entity + " is");
            sw.WriteLine("");

            sw.WriteLine("    component spikes_BPF_HQ is");
            sw.WriteLine("        Generic (");
            sw.WriteLine("            GL             : INTEGER := 11;");
            sw.WriteLine("            SAT            : INTEGER := 1023");
            sw.WriteLine("        );");
            sw.WriteLine("        Port (");
            sw.WriteLine("            CLK            : in  STD_LOGIC;");
            sw.WriteLine("            RST            : in  STD_LOGIC;");
            sw.WriteLine("            FREQ_DIV       : in  STD_LOGIC_VECTOR(7 downto 0);");
            sw.WriteLine("            SPIKES_DIV     : in  STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("            SPIKES_DIV_FB  : in  STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("            SPIKES_DIV_OUT : in  STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("            spike_in_p     : in  STD_LOGIC;");
            sw.WriteLine("            spike_in_n     : in  STD_LOGIC;");
            sw.WriteLine("            spike_out_p    : out STD_LOGIC;");
            sw.WriteLine("            spike_out_n    : out STD_LOGIC");
            sw.WriteLine("        );");
            sw.WriteLine("    end component;");
            sw.WriteLine("");

            sw.WriteLine("    signal not_rst: std_logic;");
            sw.WriteLine("");

            sw.WriteLine("    begin");
            sw.WriteLine("");

            sw.WriteLine("        not_rst <= not rst;");
            sw.WriteLine("");


            for (int k = 0; k < nCH; k++)
            {
                double realFreq = (OpenNasUtils.kSIG(clk, nBits[k], freqDiv[k]) * OpenNasUtils.kDiv(igDiv[k])) / (2 * Math.PI);
                double freqError = 100 * ((midFreq[k] - realFreq) / midFreq[k]);
                string filterInfo = "--Ideal cutoff: " + midFreq[k].ToString("0.0000") + "Hz - Real cutoff: " + realFreq.ToString("0.0000") + "Hz - Error: " + freqError.ToString("0.0000") + "%";
                sw.WriteLine("        " + filterInfo);
                sw.WriteLine("        U_BPF_" + k + ": spikes_BPF_HQ");
                sw.WriteLine("        Generic Map (");
                sw.WriteLine("            GL             => " + nBits[k] + ",");
                sw.WriteLine("            SAT            => " + (int)(Math.Pow(2, nBits[k] - 1) - 1));
                sw.WriteLine("        )");
                sw.WriteLine("        Port Map (");
                sw.WriteLine("            CLK            => clock,");
                sw.WriteLine("            RST            => not_rst,");
                sw.WriteLine("            FREQ_DIV       => x\"" + freqDiv[k].ToString("X2") + "\",");
                sw.WriteLine("            SPIKES_DIV     => x\"" + igDiv[k].ToString("X4") + "\",");
                sw.WriteLine("            SPIKES_DIV_FB  => x\"" + fbDiv[k].ToString("X4") + "\",");
                sw.WriteLine("            SPIKES_DIV_OUT => x\"" + attDiv[k].ToString("X4") + "\",");
                sw.WriteLine("            spike_in_p     => spikes_in(1),");
                sw.WriteLine("            spike_in_n     => spikes_in(0),");
                sw.WriteLine("            spike_out_p    => spikes_out(" + (2 * (k) + 1) + "),");
                sw.WriteLine("            spike_out_n    => spikes_out(" + (2 * (k)) + ") ");
                sw.WriteLine("        );");
                sw.WriteLine("");
            }

            sw.WriteLine("end PFBank_arq;");

            sw.Close();

        }

        /// <summary>
        /// Generates a full SBPF bank, copying library files, and generating custom sources
        /// </summary>
        /// <param name="route">Destination files route</param>
        public override void generateHDL(string route)
        {
            List<string> dependencies = new List<string>();

            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\Spike_Int_n_Gen_BW.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\AER_DIF.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\AER_HOLDER_AND_FIRE.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_div_BW.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_BPF_HQ.vhd");

            copyDependencies(route, dependencies);

            generatePFB(route);

        }

        /// <summary>
        /// Not used, either implemented
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteTopSignals(StreamWriter sw)
        {
            throw new NotImplementedException();
        }
        /// <summary>
        /// Writes a SBPF bank component architecture <see cref="CascadeSLPFBank"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentArchitecture(StreamWriter sw)
        {

            string entity = "PFBank_" + nCH + "CH";
            sw.WriteLine("    --Parallel Filter Bank");
            sw.WriteLine("    component " + entity + " is");
            sw.WriteLine("        Port (");
            sw.WriteLine("            clock      : in  STD_LOGIC;");
            sw.WriteLine("            rst        : in  STD_LOGIC;");
            sw.WriteLine("            spikes_in  : in  STD_LOGIC_VECTOR(1 downto 0);");
            sw.WriteLine("            spikes_out : out STD_LOGIC_VECTOR(" + (nCH * 2 - 1) + " downto 0)");
            sw.WriteLine("        );");
            sw.WriteLine("    end component;");
            sw.WriteLine("");
        }

        /// <summary>
        /// Writes a SBPF bank invocation and link signals <see cref="AudioInput"/>
        /// </summary>
        /// <param name="sw">NAS Top file handler</param>
        public override void WriteComponentInvocation(StreamWriter sw)
        {
            string entity = "PFBank_" + nCH + "CH";
            sw.WriteLine("        --Parallel Filter Bank");
            sw.WriteLine("        U_" + entity + "_Left: " + entity);
            sw.WriteLine("        Port Map (");
            sw.WriteLine("            clock      => clock,");
            sw.WriteLine("            rst        => reset,");
            sw.WriteLine("            spikes_in  => spikes_in_left,");
            sw.WriteLine("            spikes_out => spikes_out_left");
            sw.WriteLine("        );");
            sw.WriteLine("");

            if (nasType == NASTYPE.STEREO)
            {
                sw.WriteLine("        --Parallel Filter Bank");
                sw.WriteLine("        U_" + entity + "_Rigth: " + entity);
                sw.WriteLine("        Port Map(");
                sw.WriteLine("            clock      => clock,");
                sw.WriteLine("            rst        => reset,");
                sw.WriteLine("            spikes_in  => spikes_in_rigth,");
                sw.WriteLine("            spikes_out => spikes_out_rigth");
                sw.WriteLine("        );");
                sw.WriteLine("");
            }
        }
        /// <summary>
        /// Gets component short description
        /// </summary>
        /// <returns>Short description</returns>
        public override string getShortDescription()
        {
            return "Parallel";
        }
    }
}
