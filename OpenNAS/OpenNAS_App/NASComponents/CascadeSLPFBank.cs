/////////////////////////////////////////////////////////////////////////////////
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
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace OpenNAS_App.NASComponents
{
    public enum SLPFType { Order2 = 0, Order4  };

    public class CascadeSLPFBank: AudioProcessingArchitecture
    {

        public int nCH=0;
        public float clk;
        public NASTYPE nasType;
        public SLPFType slpfType;
        public List<double> midFreq;
        public List<double> cutoffFreq;
        public List<double> attenuation;
        private CultureInfo ci = new CultureInfo("en-us");

        public CascadeSLPFBank() { }
        public CascadeSLPFBank(int nCH, float clk, NASTYPE nasType , SLPFType slpfType, double startFreq, double stopFreq, double att)
        {
            double start, stop;

            this.nCH = nCH;
            this.clk = clk;
            this.nasType = nasType;

            this.slpfType = slpfType;

            start = Math.Log10(startFreq);
            stop = Math.Log10(stopFreq);

             this.midFreq = (OpenNasUtils.LogSpace(start, stop, nCH)).ToList<double>();
            

             this.cutoffFreq = computeCutOffFreq(midFreq);

            this.attenuation = new List<double>();
            for(int i=0; i< nCH; i++)
            {
             
                this.attenuation.Add(att);
            }

            this.midFreq.Reverse();
            this.cutoffFreq.Reverse();
        }

        public List<double> computeCutOffFreq(List<double> centerFreq)
        {
            List<double> cutOffFreq = new List<double>();

            double relation = centerFreq[1] / centerFreq[0];

            double firstFreq = Math.Sqrt(centerFreq[0] * centerFreq[1]);

            cutOffFreq.Add(firstFreq / relation);
            cutOffFreq.Add(firstFreq);

            for (int i = 2; i < centerFreq.Count + 1; i++)
            {
                cutOffFreq.Add(cutOffFreq[i - 1] * relation);
            }

            return cutOffFreq;
        }






        private List<SLPFParameters> slpfParam;
        private List<UInt16> attDiv;

        private void computeFiltersParameters()
        {
            slpfParam = new List<SLPFParameters>();
            attDiv = new List<UInt16>();


            for (int i = 0; i < cutoffFreq.Count; i++)
            {
                SLPFParameters slpf = new SLPFParameters(clk, cutoffFreq[i], 0, 2);
                slpfParam.Add(slpf);

            }
            for (int k = 0; k < attenuation.Count; k++)
            {
                double tempAtt = Math.Pow(10, attenuation[k] / 20);

                attDiv.Add(OpenNasUtils.revkDiv(tempAtt));
            }
        }
    
        private void generateCFB(string route)
        {
            computeFiltersParameters();


            StreamWriter sw = new StreamWriter(route + "\\CFBank_" + nCH + ".vhd");

            sw.WriteLine(HDLGenerable.copyLicense());

            sw.WriteLine("library IEEE;");
            sw.WriteLine("use IEEE.STD_LOGIC_1164.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_ARITH.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_UNSIGNED.ALL;");

            sw.WriteLine("");
            string entity = "CFBank_";
            if (slpfType == SLPFType.Order2)
            {
                entity += "2";
            }
            else{
                entity += "4";
            }
            entity += "or_" + nCH + "CH";

            sw.WriteLine("entity " + entity + " is");
            sw.WriteLine("  port(");
            sw.WriteLine("  clock     : in std_logic;");
            sw.WriteLine("   rst             : in std_logic;");
            sw.WriteLine("  spikes_in: in std_logic_vector(1 downto 0);");
            sw.WriteLine("  spikes_out: out std_logic_vector("+(nCH*2-1)+" downto 0)");
            sw.WriteLine(");");
            sw.WriteLine("end "+entity+";");
            sw.WriteLine("");

            sw.WriteLine("architecture CFBank_arq of " + entity + " is");
            sw.WriteLine("");

            string filterName;
            if (slpfType == SLPFType.Order2)
            {
                filterName = "spikes_2BPF_fullGain";
            }
            else
            {
                filterName = "spikes_4BPF_fullGain";
            }

            sw.WriteLine("  component "+filterName+" is");

            sw.WriteLine("  generic (GL: in integer:= 11; SAT: in integer:= 1023);");
            sw.WriteLine("  Port(CLK: in  STD_LOGIC;");
            sw.WriteLine("      RST: in  STD_LOGIC;");
            sw.WriteLine("      FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);");
            sw.WriteLine("      SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("      SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("      SPIKES_DIV_BPF: in STD_LOGIC_VECTOR(15 downto 0);");
            sw.WriteLine("      spike_in_slpf_p: in  STD_LOGIC;");
            sw.WriteLine("      spike_in_slpf_n: in  STD_LOGIC;");
            sw.WriteLine("      spike_in_shf_p: in  STD_LOGIC;");
            sw.WriteLine("      spike_in_shf_n: in  STD_LOGIC;");
            sw.WriteLine("      spike_out_p: out  STD_LOGIC;");
            sw.WriteLine("      spike_out_n: out  STD_LOGIC;");
            sw.WriteLine("      spike_out_lpf_p: out  STD_LOGIC;");
            sw.WriteLine("      spike_out_lpf_n: out  STD_LOGIC);");
            sw.WriteLine("  end component;");


            sw.WriteLine("");

            sw.WriteLine("  signal not_rst: std_logic;");
            for(int i = 0; i < nCH + 1; i++)
            {
                sw.WriteLine("  signal lpf_spikes_"+i+" : std_logic_vector(1 downto 0);");
            }

            sw.WriteLine("begin");
            sw.WriteLine("");

            sw.WriteLine("not_rst <= not rst;");
            sw.WriteLine("");

            double realFreq = slpfParam[0].realFcut;
            double freqError = 100 * ((cutoffFreq[0] - realFreq) / cutoffFreq[0]);
            string filterInfo = "--Ideal cutoff: " + cutoffFreq[0].ToString("0.0000") + "Hz - Real cutoff: " + realFreq.ToString("0.0000") + "Hz - Error: "+ freqError.ToString("0.0000") +"%";
            sw.WriteLine(filterInfo);
            sw.WriteLine("U_BPF_0: " + filterName);
            sw.WriteLine("generic map(GL => "+ slpfParam[0].nBits+", SAT => "+(int) (Math.Pow(2, slpfParam[0].nBits-1)-1)+")");
            sw.WriteLine("Port map(CLK => clock,");
            sw.WriteLine("  RST => not_rst,");
            sw.WriteLine("  FREQ_DIV => x\""+ slpfParam[0].freqDiv.ToString("X2")+"\",");
            sw.WriteLine("  SPIKES_DIV_FB => x\""+ slpfParam[0].fbDiv.ToString("X4") + "\",");
            sw.WriteLine("  SPIKES_DIV_OUT => x\""+ slpfParam[0].outDiv.ToString("X4") + "\",");
            sw.WriteLine("  SPIKES_DIV_BPF => x\""+ attDiv[0].ToString("X4") + "\",");
            sw.WriteLine("  spike_in_slpf_p => spikes_in(1),");
            sw.WriteLine("  spike_in_slpf_n => spikes_in(0),");
            sw.WriteLine("  spike_in_shf_p => '0',");
            sw.WriteLine("  spike_in_shf_n => '0',");
            sw.WriteLine("  spike_out_p => open,");
            sw.WriteLine("  spike_out_n => open, ");
            sw.WriteLine("  spike_out_lpf_p => lpf_spikes_0(1),");
            sw.WriteLine("  spike_out_lpf_n => lpf_spikes_0(0)");
            sw.WriteLine(");");
            sw.WriteLine("");





            for (int k = 1; k < nCH + 1; k++)
            {
                realFreq = slpfParam[k].realFcut;
                freqError = 100 * ((cutoffFreq[k] - realFreq) / cutoffFreq[k]);
                filterInfo = "--Ideal cutoff: " + cutoffFreq[k].ToString("0.0000") + "Hz - Real cutoff: " + realFreq.ToString("0.0000") + "Hz - Error: " + freqError.ToString("0.0000") + "%";
                sw.WriteLine(filterInfo);
                sw.WriteLine("U_BPF_"+k+": " + filterName);
                sw.WriteLine("generic map(GL => " + slpfParam[k].nBits + ", SAT => " + (int)(Math.Pow(2, slpfParam[k].nBits - 1) - 1) + ")");
                sw.WriteLine("Port map(CLK => clock,");
                sw.WriteLine("  RST => not_rst,");
                sw.WriteLine("  FREQ_DIV => x\"" + slpfParam[k].freqDiv.ToString("X2") + "\",");
                sw.WriteLine("  SPIKES_DIV_FB => x\"" + slpfParam[k].fbDiv.ToString("X4") + "\",");
                sw.WriteLine("  SPIKES_DIV_OUT => x\"" + slpfParam[k].outDiv.ToString("X4") + "\",");
                sw.WriteLine("  SPIKES_DIV_BPF => x\"" + attDiv[k-1].ToString("X4") + "\",");
                sw.WriteLine("  spike_in_slpf_p => lpf_spikes_"+(k-1)+"(1),");
                sw.WriteLine("  spike_in_slpf_n => lpf_spikes_" + (k - 1) + "(0),");

                //Cascade Arch
                sw.WriteLine("  spike_in_shf_p => lpf_spikes_" + (k - 1) + "(1),");
                sw.WriteLine("  spike_in_shf_n => lpf_spikes_" + (k - 1) + "(0),");

                //Parallel Arch
                /*sw.WriteLine("  spike_in_shf_p => spikes_in(1),");
                sw.WriteLine("  spike_in_shf_n => spikes_in(0),"); */


                sw.WriteLine("  spike_out_p => spikes_out("+(2*(k-1)+1)+"),");
                sw.WriteLine("  spike_out_n => spikes_out(" + (2 * (k-1)) + "), ");
                sw.WriteLine("  spike_out_lpf_p => lpf_spikes_" + (k) + "(1),");
                sw.WriteLine("  spike_out_lpf_n => lpf_spikes_" + (k) + "(0)");
                sw.WriteLine(");");
                sw.WriteLine("");
            }

            sw.WriteLine("end CFBank_arq;");

            sw.Close();


        }

        override public void generateHDL (string route)
        {
            List<string> dependencies = new List<string>();
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\Spike_Int_n_Gen_BW.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\AER_DIF.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\AER_HOLDER_AND_FIRE.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_div_BW.vhd");
            dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_LPF_fullGain.vhd");

            if (slpfType == SLPFType.Order2)
            {

                dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_2LPF_fullGain.vhd");
                dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_2BPF_fullGain.vhd");
            }
            else
            {
                dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_4LPF_fullGain.vhd");
                dependencies.Add(@"SSPLibrary\SpikeBuildingBlocks\spikes_4BPF_fullGain.vhd");
            }
            copyDependencies(route, dependencies );

            generateCFB(route);

        }

        override public void toXML(XmlTextWriter textWriter)
        {
            int i = 0;

            textWriter.WriteStartElement("CascadeSLPFBank");
            textWriter.WriteAttributeString("nCH", nCH.ToString());
            textWriter.WriteAttributeString("SLPFType", slpfType.ToString());

            textWriter.WriteStartElement("midFreq");
            foreach (double d in midFreq)
            {
                textWriter.WriteStartElement("Freq");
                textWriter.WriteAttributeString("id", i.ToString()); i++;
                textWriter.WriteAttributeString("freq", d.ToString(ci));
                textWriter.WriteEndElement();
            }
            textWriter.WriteEndElement();

            i = 0;
            textWriter.WriteStartElement("cutoffFreq");
            foreach (double d in cutoffFreq)
            {
                textWriter.WriteStartElement("Freq");
                textWriter.WriteAttributeString("id", i.ToString()); i++;
                textWriter.WriteAttributeString("freq", d.ToString(ci));
                textWriter.WriteEndElement();
            }
            textWriter.WriteEndElement();

            i = 0;
            textWriter.WriteStartElement("attenuation");
            foreach (double d in attenuation)
            {
                textWriter.WriteStartElement("Attenuation");
                textWriter.WriteAttributeString("id", i.ToString()); i++;
                textWriter.WriteAttributeString("attenuation", d.ToString(ci));
                textWriter.WriteEndElement();
            }
            textWriter.WriteEndElement();

            textWriter.WriteEndElement();
        }

        public override void WriteTopSignals(StreamWriter sw)
        {
            throw new NotImplementedException();
        }

        public override void WriteComponentArchitecture(StreamWriter sw)
        {
            string entity = "CFBank_";
            if (slpfType == SLPFType.Order2)
            {
                entity += "2";
            }
            else {
                entity += "4";
            }
            entity += "or_" + nCH + "CH";
            sw.WriteLine("--Cascade Filter Bank");
            sw.WriteLine("component " + entity + " is");
            sw.WriteLine("  port(");
            sw.WriteLine("  clock     : in std_logic;");
            sw.WriteLine("   rst             : in std_logic;");
            sw.WriteLine("  spikes_in: in std_logic_vector(1 downto 0);");
            sw.WriteLine("  spikes_out: out std_logic_vector(" + (nCH * 2 - 1) + " downto 0)");
            sw.WriteLine(");");
            sw.WriteLine("end component;");
            sw.WriteLine("");
        }

        public override void WriteComponentInvocation(StreamWriter sw)
        {
            string entity = "CFBank_";
            if (slpfType == SLPFType.Order2)
            {
                entity += "2";
            }
            else {
                entity += "4";
            }
            entity += "or_" + nCH + "CH";
            sw.WriteLine("--Cascade Filter Bank");
            sw.WriteLine("U_" + entity + "_Left: "+entity);
            sw.WriteLine("  port map(");
            sw.WriteLine("  clock =>clock,");
            sw.WriteLine("   rst  => reset,");
            sw.WriteLine("  spikes_in=> spikes_in_left,");
            sw.WriteLine("  spikes_out=>spikes_out_left");
            sw.WriteLine(");");
            sw.WriteLine("");

            if (nasType == NASTYPE.STEREO)
            {
                sw.WriteLine("U_" + entity + "_Rigth: " + entity);
                sw.WriteLine("  port map(");
                sw.WriteLine("  clock =>clock,");
                sw.WriteLine("   rst  => reset,");
                sw.WriteLine("  spikes_in=> spikes_in_rigth,");
                sw.WriteLine("  spikes_out=>spikes_out_rigth");
                sw.WriteLine(");");
                sw.WriteLine("");
            }
        }

        public override string getShortDescription()
        {
            return "Cascade";
        }
    }
    
}
