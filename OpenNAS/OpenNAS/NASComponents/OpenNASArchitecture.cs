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


using OpenNAS_App.NASControls;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Xml;

/// <summary>
/// This namespace groups all the classes for NAS representation and generation, performing components library
/// </summary>
namespace OpenNAS_App.NASComponents
{
    /// <summary>
    /// This class contains a full NAS architecture. This is composed byte 3 elements: AudioInput <see cref="AudioInput"/>, AudioProcessingArchitecture <see cref="AudioProcessingArchitecture"/> and a SpikesOutputInterface <see cref="SpikesOutputInterface"/>.
    /// </summary>
    public class OpenNASArchitecture
    {
        /// <summary>
        /// NAS common setting parameters <see cref="OpenNASCommons"/>
        /// </summary>
        public OpenNASCommons nasCommons;
        /// <summary>
        /// NAS audio input stage <see cref="AudioInput"/>
        /// </summary>
        public AudioInput audioInput;
        /// <summary>
        /// NAS main processing block <see cref="AudioProcessingArchitecture"/>
        /// </summary>
        public AudioProcessingArchitecture audioProcessing;
        /// <summary>
        /// NAS events output interface <see cref="SpikesOutputInterface"/>
        /// </summary>
        public SpikesOutputInterface spikesOutput;
        /// <summary>
        /// Basic Open NAS Architecture class constructor
        /// </summary>
        public OpenNASArchitecture() { }
        /// <summary>
        /// Main Open NAS Architecture class constructor
        /// </summary>
        /// <param name="commons">NAS common setting parameters <see cref="OpenNASCommons"/></param>
        /// <param name="ai">NAS audio input stage <see cref="AudioInput"/></param>
        /// <param name="ap">NAS main processing block <see cref="AudioProcessingArchitecture"/></param>
        /// <param name="soi">NAS events output interface <see cref="SpikesOutputInterface"/></param>
        public OpenNASArchitecture(OpenNASCommons commons, AudioInput ai, AudioProcessingArchitecture ap, SpikesOutputInterface soi)
        {
            nasCommons = commons;
            audioInput = ai;
            audioProcessing = ap;
            spikesOutput = soi;
        }

        /// <summary>
        /// Generates a full NAS, copying library files, and generating custom sources and tcl script
        /// </summary>
        /// <param name="sourceRoute">Destination of source files</param>
        /// <param name="constraintsRoute">Destination of constraints files</param>
        /// <param name="projectRoute">Destination of tcl file for automatic project generation</param>
        public void Generate(string sourceRoute, string constraintsRoute, string projectRoute)
        {
            //Generate HDL componets
            audioInput.generateHDL(sourceRoute);
            audioProcessing.generateHDL(sourceRoute);
            spikesOutput.generateHDL(sourceRoute);
            //Write Top HDL file
            WriteTopFile(sourceRoute);

            WriteConstraints(constraintsRoute);

            //Write .tcl file to generate the project
            if (nasCommons.nasChip == NASchip.AERNODE)
            {
                WriteProjectTCL(projectRoute);
            }

        }

        /// <summary>
        /// Writes top NAS HDL file, integrating all NAS componentes
        /// </summary>
        /// <param name="route">Destination file route</param>
        private void WriteTopFile(string route)
        {

            string nasName = "OpenNas_TOP_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch";
            StreamWriter sw = new StreamWriter(route + "\\" + nasName + ".vhd");

            sw.WriteLine(HDLGenerable.copyLicense('H'));

            sw.WriteLine("library IEEE;");
            sw.WriteLine("use IEEE.STD_LOGIC_1164.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_ARITH.ALL;");
            sw.WriteLine("use IEEE.STD_LOGIC_UNSIGNED.ALL;");

            sw.WriteLine("");

            //Top component signals
            string entity = "OpenNas_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + +nasCommons.nCh + "ch";
            sw.WriteLine("entity " + entity + " is");
            sw.WriteLine("  port(");
            sw.WriteLine("  clock     : in std_logic;");
            sw.WriteLine("  rst_ext   : in std_logic;");
            audioInput.WriteTopSignals(sw);
            spikesOutput.WriteTopSignals(sw);

            sw.WriteLine(");");
            sw.WriteLine("end " + entity + ";");
            sw.WriteLine("");

            sw.WriteLine("architecture OpenNas_arq of " + entity + " is");
            sw.WriteLine("");

            //Components Architecture
            audioInput.WriteComponentArchitecture(sw);
            audioProcessing.WriteComponentArchitecture(sw);
            spikesOutput.WriteComponentArchitecture(sw);
            sw.WriteLine("");
            sw.WriteLine("--Reset signals");
            sw.WriteLine("  signal reset : std_logic;");

            AudioInputControl.NASAUDIOSOURCE nasInputIF = AudioInputControl.audioSource;
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("--Audio input modules reset signal");
                sw.WriteLine("  signal pdm_reset : std_logic;");
                sw.WriteLine("  signal i2s_reset: std_logic; ");
                sw.WriteLine("--Inverted Source selector signal");
                sw.WriteLine("  signal i_source_sel : std_logic;");
                sw.WriteLine("--Audio input modules out spikes signal");
                sw.WriteLine("  signal spikes_in_left_i2s : std_logic_vector(1 downto 0);");
                sw.WriteLine("  signal spikes_in_left_pdm : std_logic_vector(1 downto 0);");
            }

            sw.WriteLine("--Left spikes");
            sw.WriteLine("  signal spikes_in_left : std_logic_vector(1 downto 0);");
            sw.WriteLine("  signal spikes_out_left : std_logic_vector(" + (nasCommons.nCh * 2 - 1) + " downto 0);");


            ///////////////////////////////////////spikes_out_left

            if (nasCommons.monoStereo == NASTYPE.STEREO)
            {
                if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
                {
                    sw.WriteLine("--Audio input modules out spikes signal");
                    sw.WriteLine("  signal spikes_in_right_i2s : std_logic_vector(1 downto 0);");
                    sw.WriteLine("  signal spikes_in_right_pdm : std_logic_vector(1 downto 0);");
                }
                sw.WriteLine("--Rigth spikes");
                sw.WriteLine("  signal spikes_in_rigth : std_logic_vector(1 downto 0);");
                sw.WriteLine("  signal spikes_out_rigth : std_logic_vector(" + (nasCommons.nCh * 2 - 1) + " downto 0);");
            }

            if (nasCommons.monoStereo == NASTYPE.STEREO)
            {
                sw.WriteLine("--Output spikes");
                sw.WriteLine("  signal spikes_out: std_logic_vector(" + (nasCommons.nCh * 4 - 1) + " downto 0);");
            }
            else
            {
                sw.WriteLine("--Output spikes");
                sw.WriteLine("  signal spikes_out: std_logic_vector(" + (nasCommons.nCh * 2 - 1) + " downto 0);");
            }

            sw.WriteLine("");

            sw.WriteLine("begin");
            sw.WriteLine("");
            sw.WriteLine("reset<=rst_ext;");
            sw.WriteLine("--Output spikes connection");
            if (nasCommons.monoStereo == NASTYPE.STEREO)
            {
                sw.WriteLine("spikes_out<= spikes_out_rigth & spikes_out_left ;");
            }
            else
            {
                sw.WriteLine("spikes_out<= spikes_out_left ;");
            }

            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("--Inverted source selector signal");
                sw.WriteLine("i_source_sel <= not source_sel;");
                sw.WriteLine("--PDM / I2S reset signals");
                sw.WriteLine("pdm_reset <= reset and source_sel;");
                sw.WriteLine("i2s_reset <= reset and i_source_sel;");
            }

            audioInput.WriteComponentInvocation(sw);
            audioProcessing.WriteComponentInvocation(sw);
            spikesOutput.WriteComponentInvocation(sw);

            sw.WriteLine("end OpenNas_arq;");

            sw.Close();

            SpikesOutputControl.NASAUDIOOUTPUT nasOutputIF = SpikesOutputControl.audioOutput;
            //SpiNNaker v1
            if (nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV1)
            {
                WriteSpiNNakerIF(1, route);
            }
            //SpiNNaker v2
            if (nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV2)
            {
                WriteSpiNNakerIF(2, route);
            }

        }

        /// <summary>
        /// Writes NAS constraint file for a specific board
        /// </summary>
        /// <param name="route">Destination file route</param>
        private void WriteConstraints(string route)
        {
            string fileExtension = ".";
            string fileName = "_constraints";

            switch (nasCommons.nasChip)
            {
                case NASchip.AERNODE:
                    fileName = "Node" + fileName;
                    fileExtension = fileExtension + "ucf";
                    break;
                case NASchip.ZTEX:
                    fileName = "ZTEX" + fileName;
                    fileExtension = fileExtension + "xdc";
                    break;
                case NASchip.SOC_DOCK:
                    fileName = "SOC_DOCK" + fileName;
                    fileExtension = fileExtension + "xdc";
                    break;
                case NASchip.OTHER:
                    fileName = "other" + fileName;
                    fileExtension = fileExtension + "xdc";
                    break;
                default:
                    break;
            }

            StreamWriter sw = new StreamWriter(route + "\\" + fileName + fileExtension);
            string signal_name = "";

            SpikesOutputControl.NASAUDIOOUTPUT nasOutputIF = SpikesOutputControl.audioOutput;
            bool isAERMonitor = (nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.AERMONITOR);

            sw.WriteLine(HDLGenerable.copyLicense('C'));

            sw.WriteLine("### External clock ###");
            switch (nasCommons.nasChip)
            {
                case NASchip.AERNODE:
                    signal_name = isAERMonitor ? "\"clock\"" : "\"i_ext_clock\"";
                    sw.WriteLine("NET "+ signal_name + " LOC = \"ab13\";");
                    break;
                case NASchip.ZTEX:
                    signal_name = isAERMonitor ? "clock" : "i_ext_clock";
                    sw.WriteLine("set_property PACKAGE_PIN P15 [get_ports " + signal_name + "]");
                    sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports "+ signal_name + "]");
                    break;
                default:
                    signal_name = isAERMonitor ? "clock" : "i_ext_clock";
                    sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                    sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                    break;
            }
            sw.WriteLine("");

            sw.WriteLine("### External reset button ###");
            switch (nasCommons.nasChip)
            {
                case NASchip.AERNODE:
                    signal_name = isAERMonitor ? "\"rst_ext\"" : "\"i_ext_reset\"";
                    sw.WriteLine("NET " + signal_name + " LOC = \"A20\";");
                    break;
                case NASchip.ZTEX:
                    signal_name = isAERMonitor ? "rst_ext" : "i_ext_reset";
                    sw.WriteLine("## Button PB2");
                    sw.WriteLine("set_property PACKAGE_PIN P5 [get_ports " + signal_name + "]");
                    sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                    break;
                default:
                    sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                    sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                    break;
            }
            sw.WriteLine("");

            sw.WriteLine("### GP_1 connector: audio input source ###");
            sw.WriteLine("#2:VDD | 4:SDOUT          | 6:SCLK          | 8:LRCK           | 10:SRC_SEL   #");
            sw.WriteLine("#      |                  |                 |                  |              #");
            sw.WriteLine("#1:GND | 3:PDM_DAT_LEFT   | 5:PDM_CLK_LEFT  | 7:PDM_CLK_RIGTH  | 9:PDM_DATA_R #");
            sw.WriteLine("");

            AudioInputControl.NASAUDIOSOURCE nasInputIF = AudioInputControl.audioSource;

            //AC'97
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.AC97)
            {
                sw.WriteLine("### AC97 ADC ###");
                switch (nasCommons.nasChip)
                {
                    case NASchip.AERNODE:
                        break;
                    case NASchip.ZTEX:
                        break;
                    default:
                        break;
                }
                sw.WriteLine("");
            }
            //I2S
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2S) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("### I2S interface ###");
                switch (nasCommons.nasChip)
                {
                    case NASchip.AERNODE:
                        signal_name = isAERMonitor ? "\"i2s_bclk\"" : "\"i_nas_i2s_bclk\"";
                        sw.WriteLine("NET " + signal_name + " LOC = \"C19\";");

                        signal_name = isAERMonitor ? "\"i2s_d_in\"" : "\"i_nas_i2s_din\"";
                        sw.WriteLine("NET " + signal_name + " LOC = \"F17\";");

                        signal_name = isAERMonitor ? "\"i2s_lr\"" : "\"i_nas_i2s_lr\"";
                        sw.WriteLine("NET " + signal_name + " LOC = \"B20\";");
                        break;
                    case NASchip.ZTEX:
                        signal_name = isAERMonitor ? "i2s_bclk" : "i_nas_i2s_bclk";
                        sw.WriteLine("set_property PACKAGE_PIN G16 [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        signal_name = isAERMonitor ? "i2s_d_in" : "i_nas_i2s_din";
                        sw.WriteLine("set_property PACKAGE_PIN G14 [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        signal_name = isAERMonitor ? "i2s_lr" : "i_nas_i2s_lr";
                        sw.WriteLine("set_property PACKAGE_PIN H16 [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");

                        break;
                    default:
                        signal_name = isAERMonitor ? "i2s_bclk" : "i_nas_i2s_bclk";
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        signal_name = isAERMonitor ? "i2s_d_in" : "i_nas_i2s_din";
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        signal_name = isAERMonitor ? "i2s_lr" : "i_nas_i2s_lr";
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        break;
                }
                sw.WriteLine("");
            }
            //PDM
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.PDM) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("### PDM interface ###");
                switch (nasCommons.nasChip)
                {
                    case NASchip.AERNODE:
                        signal_name = isAERMonitor ? "\"PDM_CLK_LEFT\"" : "\"i_nas_pdm_clk_left\"";
                        sw.WriteLine("NET " + signal_name + " LOC = \"D18\";");
                        signal_name = isAERMonitor ? "\"PDM_DAT_LEFT\"" : "\"i_nas_pdm_data_left\"";
                        sw.WriteLine("NET " + signal_name + " LOC = \"G16\" | pulldown;");
                        sw.WriteLine("");

                        if(nasCommons.monoStereo == NASTYPE.STEREO)
                        {
                            signal_name = isAERMonitor ? "\"PDM_CLK_RIGTH\"" : "\"i_nas_pdm_clk_rigth\"";
                            sw.WriteLine("NET " + signal_name + " LOC = \"C18\";");
                            signal_name = isAERMonitor ? "\"PDM_DAT_RIGTH\"" : "\"i_nas_pdm_data_rigth\"";
                            sw.WriteLine("NET " + signal_name + " LOC = \"B18\" | pulldown;");
                        }
                        
                        break;

                    case NASchip.ZTEX:
                        signal_name = isAERMonitor ? "PDM_CLK_LEFT" : "i_nas_pdm_clk_left";
                        sw.WriteLine("set_property PACKAGE_PIN G17 [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        signal_name = isAERMonitor ? "PDM_DAT_LEFT" : "i_nas_pdm_data_left";
                        sw.WriteLine("set_property PACKAGE_PIN H17 [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        if (nasCommons.monoStereo == NASTYPE.STEREO)
                        {
                            signal_name = isAERMonitor ? "PDM_CLK_RIGTH" : "i_nas_pdm_clk_rigth";
                            sw.WriteLine("set_property PACKAGE_PIN G18 [get_ports " + signal_name + "]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                            sw.WriteLine("");

                            signal_name = isAERMonitor ? "PDM_DAT_RIGTH" : "i_nas_pdm_data_rigth";
                            sw.WriteLine("set_property PACKAGE_PIN F18 [get_ports " + signal_name + "]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        }

                        break;
                    default:
                        signal_name = isAERMonitor ? "PDM_CLK_LEFT" : "i_nas_pdm_clk_left";
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        signal_name = isAERMonitor ? "PDM_DAT_LEFT" : "i_nas_pdm_data_left";
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        sw.WriteLine("");

                        if (nasCommons.monoStereo == NASTYPE.STEREO)
                        {
                            signal_name = isAERMonitor ? "PDM_CLK_RIGTH" : "i_nas_pdm_clk_rigth";
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                            sw.WriteLine("");

                            signal_name = isAERMonitor ? "PDM_DAT_RIGTH" : "i_nas_pdm_data_rigth";
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports " + signal_name + "]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        }
                        break;
                }
                sw.WriteLine("");
            }
            //I2S + PDM
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("### Source selector pin (I2S or PDM micr.) ###");
                sw.WriteLine("# With jumper: I2S");
                sw.WriteLine("# Without jumper: PDM");
                switch (nasCommons.nasChip)
                {
                    case NASchip.AERNODE:
                        signal_name = isAERMonitor ? "\"source_sel\"" : "\"i_nas_source_sel\"";
                        sw.WriteLine("NET " + signal_name + " LOC = \"A18\" | pullup;");
                        break;
                    case NASchip.ZTEX:
                        signal_name = isAERMonitor ? "source_sel" : "i_nas_source_sel";
                        sw.WriteLine("set_property PACKAGE_PIN F16 [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        break;
                    default:
                        sw.WriteLine("set_property PACKAGE_PIN xx [get_ports " + signal_name + "]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports " + signal_name + "]");
                        break;
                }
                sw.WriteLine("");
            }

            //Output interfaces

            //AER interface
            if(nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.AERMONITOR || nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.AERNSPINN)
            {
                sw.WriteLine("### AER out bus & protocol handshake ###");
                switch (nasCommons.nasChip)
                {
                    case NASchip.AERNODE:
                        sw.WriteLine("NET \"AER_DATA_OUT<0>\" LOC = \"M2\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<1>\" LOC = \"K1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<2>\" LOC = \"J1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<3>\" LOC = \"H2\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<4>\" LOC = \"F1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<5>\" LOC = \"E1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<6>\" LOC = \"D2\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<7>\" LOC = \"B1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<8>\" LOC = \"C1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<9>\" LOC = \"D1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<10>\" LOC = \"F2\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<11>\" LOC = \"G1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<12>\" LOC = \"H1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<13>\" LOC = \"K2\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<14>\" LOC = \"L1\"; ");
                        sw.WriteLine("NET \"AER_DATA_OUT<15>\" LOC = \"M1\"; ");
                        sw.WriteLine("");
                        sw.WriteLine("NET \"AER_REQ\" LOC = \"N3\"; ");
                        sw.WriteLine("NET \"AER_ACK\" LOC = \"U3\"; ");
                        sw.WriteLine("");
                        break;
                    case NASchip.ZTEX:
                        sw.WriteLine("set_property PACKAGE_PIN M6 [get_ports {AER_DATA_OUT[0]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[0]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN N5 [get_ports {AER_DATA_OUT[1]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[1]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN L6 [get_ports {AER_DATA_OUT[2]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[2]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN P4 [get_ports {AER_DATA_OUT[3]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[3]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN L5 [get_ports {AER_DATA_OUT[4]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[4]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN P3 [get_ports {AER_DATA_OUT[5]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[5]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN N4 [get_ports {AER_DATA_OUT[6]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[6]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN T1 [get_ports {AER_DATA_OUT[7]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[7]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN M4 [get_ports {AER_DATA_OUT[8]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[8]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN R1 [get_ports {AER_DATA_OUT[9]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[9]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN M3 [get_ports {AER_DATA_OUT[10]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[10]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN R2 [get_ports {AER_DATA_OUT[11]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[11]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN M2 [get_ports {AER_DATA_OUT[12]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[12]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN P2 [get_ports {AER_DATA_OUT[13]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[13]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN K5 [get_ports {AER_DATA_OUT[14]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[14]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN N2 [get_ports {AER_DATA_OUT[15]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[15]}]");
                        sw.WriteLine("");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN L4 [get_ports AER_REQ]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports AER_REQ]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN N1 [get_ports AER_ACK]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports AER_ACK]");
                        sw.WriteLine("");

                        break;
                    default:
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[0]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[0]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[1]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[1]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[2]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[2]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[3]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[3]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[4]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[4]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[5]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[5]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[6]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[6]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[7]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[7]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[8]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[8]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[9]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[9]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[10]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[10]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[11]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[11]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[12]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[12]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[13]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[13]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[14]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[14]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {AER_DATA_OUT[15]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[15]}]");
                        sw.WriteLine("");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports AER_REQ]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports AER_REQ]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports AER_ACK]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports AER_ACK]");
                        sw.WriteLine("");
                        
                        break;
                }
                sw.WriteLine("");
            }
            else if(nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV1 || nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV2 || nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.AERNSPINN)
            {
                sw.WriteLine("### SpiNNaker link data bus from FPGA & ack from SpiNNaker ###");
                switch (nasCommons.nasChip)
                {
                    case NASchip.AERNODE:
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<0>\" LOC = \"F1\" ; ");
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<1>\" LOC = \"F2\" ;");
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<2>\" LOC = \"E1\" ; ");
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<3>\" LOC = \"D1\" ;");
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<4>\" LOC = \"D2\" ; ");
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<5>\" LOC = \"C1\" ;");
                        sw.WriteLine("NET \"o_data_out_to_spinnaker<6>\" LOC = \"B1\" ; ");
                        sw.WriteLine("");
                        sw.WriteLine("NET \"i_ack_out_from_spinnaker\" LOC = \"H1\" | pulldown;");

                        break;
                    case NASchip.ZTEX:
                        sw.WriteLine("set_property PACKAGE_PIN C14 [get_ports {o_data_out_to_spinnaker[0]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[0]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN D12 [get_ports {o_data_out_to_spinnaker[1]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[1]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN D13 [get_ports {o_data_out_to_spinnaker[2]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[2]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN A15 [get_ports {o_data_out_to_spinnaker[3]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[3]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN A16 [get_ports {o_data_out_to_spinnaker[4]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[4]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN B13 [get_ports {o_data_out_to_spinnaker[5]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[5]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN B14 [get_ports {o_data_out_to_spinnaker[6]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[6]}]");
                        sw.WriteLine("");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN B17 [get_ports i_ack_out_from_spinnaker]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports i_ack_out_from_spinnaker]");

                        sw.WriteLine("");
                        break;
                    default:
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[0]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[0]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[1]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[1]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[2]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[2]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[3]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[3]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[4]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[4]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[5]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[5]}]");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {o_data_out_to_spinnaker[6]}]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {o_data_out_to_spinnaker[6]}]");
                        sw.WriteLine("");
                        sw.WriteLine("");
                        sw.WriteLine("set_property PACKAGE_PIN XX [get_ports i_ack_out_from_spinnaker]");
                        sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports i_ack_out_from_spinnaker]");
                        sw.WriteLine("");
                        break;
                }

                if (nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV2)
                {
                    sw.WriteLine("### SpiNNaker link data bus from SpiNNaker & ack from FPGA ###");
                    switch (nasCommons.nasChip)
                    {
                        case NASchip.AERNODE:
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<0>\" LOC = \"N1\" ; ");
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<1>\" LOC = \"M1\" ;");
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<2>\" LOC = \"M2\" ; ");
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<3>\" LOC = \"L1\" ;");
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<4>\" LOC = \"K1\" ; ");
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<5>\" LOC = \"K2\" ;");
                            sw.WriteLine("NET \"i_data_in_from_spinnaker<6>\" LOC = \"J1\" ; ");
                            sw.WriteLine("");

                            sw.WriteLine("NET \"o_ack_in_to_spinnaker\" LOC = \"G1\" | pulldown;");
                            sw.WriteLine("");

                            sw.WriteLine("### SpiNN-AER interface status LEDs");
                            sw.WriteLine("NET \"o_spinn_ui_status_active\" LOC = \"F20\"; #active");
                            sw.WriteLine("NET \"o_spinn_ui_status_reset\" LOC = \"N22\"; #reset");
                            sw.WriteLine("NET \"o_spinn_ui_status_dump\" LOC = \"R22\"; #dump");
                            sw.WriteLine("NET \"o_spinn_ui_status_error\" LOC = \"G20\"; #error");

                            break;
                        case NASchip.ZTEX:
                            sw.WriteLine("set_property PACKAGE_PIN C16 [get_ports {i_data_in_from_spinnaker[0]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[0]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN C17 [get_ports {i_data_in_from_spinnaker[1]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[1]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN B18 [get_ports {i_data_in_from_spinnaker[2]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[2]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN A18 [get_ports {i_data_in_from_spinnaker[3]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[3]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN D15 [get_ports {i_data_in_from_spinnaker[4]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[4]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN C15 [get_ports {i_data_in_from_spinnaker[5]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[5]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN B16 [get_ports {i_data_in_from_spinnaker[6]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[6]}]");
                            sw.WriteLine("");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN D14 [get_ports o_ack_in_to_spinnaker]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_ack_in_to_spinnaker]");
                            sw.WriteLine("");

                            sw.WriteLine("### SpiNN-AER interface status LEDs");
                            sw.WriteLine("set_property PACKAGE_PIN U8 [get_ports o_spinn_ui_status_error]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_error]");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN V7 [get_ports o_spinn_ui_status_dump]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_dump]");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN U9 [get_ports o_spinn_ui_status_active]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_active]");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN V9 [get_ports o_spinn_ui_status_reset]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_reset]");
                            sw.WriteLine("");

                            sw.WriteLine("");


                            break;
                        default:
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[0]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[0]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[1]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[1]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[2]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[2]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[3]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[3]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[4]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[4]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[5]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[5]}]");
                            sw.WriteLine("");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports {i_data_in_from_spinnaker[6]}]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports {i_data_in_from_spinnaker[6]}]");
                            sw.WriteLine("");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports o_ack_in_to_spinnaker]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_ack_in_to_spinnaker]");
                            sw.WriteLine("");
                            sw.WriteLine("");

                            sw.WriteLine("### SpiNN-AER interface status LEDs");
                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports o_spinn_ui_status_error]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_error]");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports o_spinn_ui_status_dump]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_dump]");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports o_spinn_ui_status_active]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_active]");
                            sw.WriteLine("");

                            sw.WriteLine("set_property PACKAGE_PIN XX [get_ports o_spinn_ui_status_reset]");
                            sw.WriteLine("set_property IOSTANDARD LVCMOS33 [get_ports o_spinn_ui_status_reset]");
                            sw.WriteLine("");
                            break;
                    }

                    sw.WriteLine("");
                }
            }

            sw.Close();
        }

        /// <summary>
        /// Writes a tcl script for automatic NAS project generation
        /// </summary>
        /// <param name="route">Destination file route</param>
        private void WriteProjectTCL(string route)
        {
            string nasName = "OpenNas_TOP_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch";
            StreamWriter sw = new StreamWriter(route + "\\" + nasName + ".tcl");

            sw.WriteLine(HDLGenerable.copyLicense('C'));

            sw.WriteLine("#");
            sw.WriteLine("# Input files");
            sw.WriteLine("#");
            sw.WriteLine("");

            sw.WriteLine("# where the design will be compiled and where all output will be created");
            sw.WriteLine("set compile_directory OpenNas");
            sw.WriteLine("");

            sw.WriteLine("# the top-level of our HDL source:");
            string entity = "OpenNas_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + +nasCommons.nCh + "ch";
            sw.WriteLine("set top_name " + entity);
            sw.WriteLine("");

            sw.WriteLine("# input source files:");
            sw.WriteLine("");

            sw.WriteLine("# WARNING: OpenNas TOP Cascade STEREO 64ch module could have different names");
            sw.WriteLine("set hdl_files [ list \\");

            /******************* Input *******************/

            AudioInputControl.NASAUDIOSOURCE nasInputIF = AudioInputControl.audioSource;

            //AC'97
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.AC97)
            {
                sw.WriteLine("  ../../sources/AC97Controller.vhd \\");
                sw.WriteLine("  ../../sources/AC97InputComponentStereo.vhd \\");
            }
            //I2S
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2S) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("  ../../sources/I2S_inteface_sync.vhd \\");
                sw.WriteLine("  ../../sources/Spikes_Generator_signed_BW.vhd \\");
                sw.WriteLine("  ../../sources/i2s_to_spikes_stereo.vhd \\");
            }
            //PDM
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.PDM) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("  ../../sources/PDM_Interface.vhd \\");
                sw.WriteLine("  ../../sources/PDM2Spikes.vhd \\");
                sw.WriteLine("  ../../sources/spikes_HPF.vhd \\");
            }
            //I2S + PDM
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("  ../../sources/SpikesSource_Selector.vhd \\");
            }

            /******************* Processing *******************/

            AudioProcessingControl.NASAUDIOPROCESSING nasProcessingArch = AudioProcessingControl.audioProcessing;

            //Filters' commons
            sw.WriteLine("  ../../sources/AER_HOLDER_AND_FIRE.vhd \\");
            sw.WriteLine("  ../../sources/AER_DIF.vhd \\");
            sw.WriteLine("  ../../sources/spikes_div_BW.vhd \\");
            sw.WriteLine("  ../../sources/Spike_Int_n_Gen_BW.vhd \\");

            string nasFBankFileName = "  ../../sources/";

            //Cascade SLPFB
            if (nasProcessingArch == AudioProcessingControl.NASAUDIOPROCESSING.CASCADE_SLPFB)
            {
                sw.WriteLine("  ../../sources/spikes_LPF_fullGain.vhd \\");
                sw.WriteLine("  ../../sources/spikes_2LPF_fullGain.vhd \\");
                sw.WriteLine("  ../../sources/spikes_2BPF_fullGain.vhd \\");

                nasFBankFileName += "C";
            }

            //Parallel SLPFB
            if (nasProcessingArch == AudioProcessingControl.NASAUDIOPROCESSING.PARALLEL_SLPFB)
            {
                nasFBankFileName += "P";
            }

            //Parallel SBPFB
            if (nasProcessingArch == AudioProcessingControl.NASAUDIOPROCESSING.PARALLEL_SBPFB)
            {
                sw.WriteLine("  ../../sources/spikes_BPF_HQ_Div.vhd \\");
                nasFBankFileName += "P";
            }

            nasFBankFileName += "FBank_" + nasCommons.nCh + ".vhd \\";

            sw.WriteLine(nasFBankFileName);

            /******************* Output *******************/

            SpikesOutputControl.NASAUDIOOUTPUT nasOutputIF = SpikesOutputControl.audioOutput;

            //AER interface
            sw.WriteLine("  ../../sources/AER_DISTRIBUTED_MONITOR_MODULE.vhd \\");
            sw.WriteLine("  ../../sources/AER_DISTRIBUTED_MONITOR.vhd \\");
            sw.WriteLine("  ../../sources/DualPortRAM.vhd \\");
            sw.WriteLine("  ../../sources/ramfifo.vhd \\");
            sw.WriteLine("  ../../sources/handsakeOut.vhd \\");
            sw.WriteLine("  ../../sources/AER_OUT.vhd \\");

            //SpiNNaker v1
            if (nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV1)
            {
                sw.WriteLine("  ../../sources/spinn_aer_if.v \\");
            }
            //SpiNNaker v2
            if (nasOutputIF == SpikesOutputControl.NASAUDIOOUTPUT.SPINNAKERV2)
            {
                sw.WriteLine("  ../../sources/spinn_aer_if.v \\");
            }

            /****** Top ******/
            string nasTopFileName = "  ../../sources/" + nasName + ".vhd \\";
            sw.WriteLine(nasTopFileName);

            sw.WriteLine("]");
            sw.WriteLine("");

            sw.WriteLine("# constraints with pin placements. This file will need to be replaced if you");
            sw.WriteLine("# are using a different Xilinx device or board.");
            switch (nasCommons.nasChip)
            {
                case NASchip.AERNODE:
                    sw.WriteLine("set constraints_file      ../../constraints/Node_constraints.ucf");
                    break;
                case NASchip.ZTEX:
                    sw.WriteLine("set constraints_file      ../../constraints/ZTEX_constraints.xdc");
                    break;
                case NASchip.SOC_DOCK:
                    sw.WriteLine("set constraints_file      ../../constraints/SOC_DOCK_constraints.xdc");
                    break;
                case NASchip.OTHER:
                    sw.WriteLine("set constraints_file      ../../constraints/Other_generic_constraints.xdc");
                    break;
                default:
                    break;
            }

            sw.WriteLine("");

            sw.WriteLine("# Remember: set variable_name value for user variables");

            sw.WriteLine("# implement the design");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Set cableserver host");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("");

            sw.WriteLine("# If your starter kit is connected to a remote machine, edit the following");
            sw.WriteLine("# line to include the name of the Xilinx CableServer host PC:");
            sw.WriteLine("");

            sw.WriteLine("set cableserver_host {}");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Set Tcl Variables");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("");

            sw.WriteLine("set version_number \"1.0\"");
            sw.WriteLine("");
            sw.WriteLine("set proj $top_name");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Welcome");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("");
            sw.WriteLine("puts \"Running Xilinx Tcl script \\\"NAS_projectgen.tcl\\\" from OpenNAS, version $version_number.\"");
            sw.WriteLine("");

            sw.WriteLine("if { $cableserver_host == \"\" } {");
            sw.WriteLine("  puts \"Running with Spartan6 board connected to the local PC.\\n\"");
            sw.WriteLine("} else {");
            sw.WriteLine("  puts \"Running with Spartan6 board connected to $cableserver_host.\\n\"");
            sw.WriteLine("}");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Create a directory in which to run");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("");

            sw.WriteLine("#");
            sw.WriteLine("# Setting a compilation directory");
            sw.WriteLine("#");
            sw.WriteLine("");

            sw.WriteLine("# Run in the compile directory");
            sw.WriteLine("# If the directory doesn't already exist then create it.");
            sw.WriteLine("if {![file isdirectory $compile_directory]} {");
            sw.WriteLine("  file mkdir $compile_directory");
            sw.WriteLine("}");
            sw.WriteLine("");

            sw.WriteLine("# change to the directory");
            sw.WriteLine("cd $compile_directory");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Create a new project or open project");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("# This if-then-else statement looks to see if this is the first time the");
            sw.WriteLine("# script has been run - if so, it will setup the project.  If not, the");
            sw.WriteLine("# project already exists - therefore, it will simply open the project.");
            sw.WriteLine("");

            sw.WriteLine("#");
            sw.WriteLine("# Project creation and settings");
            sw.WriteLine("#");
            sw.WriteLine("");

            sw.WriteLine("set proj_exists [file exists $proj.xise]");
            sw.WriteLine("");

            sw.WriteLine("if {$proj_exists == 0} {");
            sw.WriteLine("	");

            sw.WriteLine("  puts \"Creating a new project...\"");
            sw.WriteLine("  ");

            sw.WriteLine("  # Create new project");
            sw.WriteLine("  project new $proj.xise");
            sw.WriteLine("  # Project settings");
            sw.WriteLine("  project set family Spartan6");
            sw.WriteLine("  project set device xc6slx150t");
            sw.WriteLine("  project set package fgg484");
            sw.WriteLine("  project set speed -3");
            sw.WriteLine("  ");

            sw.WriteLine("  # Add files to the project (must come after the settings)");
            sw.WriteLine("  foreach filename $hdl_files {");
            sw.WriteLine("      xfile add $filename");
            sw.WriteLine("      puts \"Adding file $filename to the project.\"");
            sw.WriteLine("  }");
            sw.WriteLine("  xfile add $constraints_file");
            sw.WriteLine("  # Test to see if $source_directory is set ...");
            sw.WriteLine("  if { ! [catch {set source_directory $source_directory}] } {");
            sw.WriteLine("      project set \"Macro Search Path\" $source_directory -process Translate");
            sw.WriteLine("  }");
            sw.WriteLine("  ");
            sw.WriteLine("} else {");
            sw.WriteLine("  puts \"Opening the existing project...\"");
            sw.WriteLine("  # Open the previously created project");
            sw.WriteLine("  project open $proj.xise");
            sw.WriteLine("}");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Implementation Properties");
            sw.WriteLine("# See TCL chapter of the Xilinx Development System Reference Guide for");
            sw.WriteLine("# how to set controls on the various processes.");
            sw.WriteLine("# These are included as examples.");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("# MAP");
            sw.WriteLine("#project set \"Map Effort Level\" Medium -process map");
            sw.WriteLine("#project set \"Perform Timing-Driven Packing and Placement\" true -process map");
            sw.WriteLine("#project set \"Register Duplication\" true -process map");
            sw.WriteLine("#project set \"Retiming\" true -process map");
            sw.WriteLine("#");
            sw.WriteLine("# PAR");
            sw.WriteLine("#project set \"Place & Route Effort Level (Overall)\" Standard");
            sw.WriteLine("#project set \"Extra Effort (Highest PAR level only)\" Normal");
            sw.WriteLine("");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Implement Design");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("");

            sw.WriteLine("#");
            sw.WriteLine("# Running processes");
            sw.WriteLine("#");
            sw.WriteLine("");

            sw.WriteLine("puts -nonewline \"Would you like run the Generate Programming File process ? y/n : \"");
            sw.WriteLine("flush stdout");
            sw.WriteLine("");

            sw.WriteLine("set genBitFile [gets stdin]");
            sw.WriteLine("");

            sw.WriteLine("if {$genBitFile == \"y\"} {");
            sw.WriteLine("	process run \"Generate Programming File\"");
            sw.WriteLine("  #process run \"Implement Design\" -force rerun_all");
            sw.WriteLine("  puts \"Running...\"");
            sw.WriteLine("} elseif {$genBitFile == \"n\"} {");
            sw.WriteLine("	puts \"User does not want to generate the .bit file...\"");
            sw.WriteLine("} else {");
            sw.WriteLine("	puts \"Unknown option...\"");
            sw.WriteLine("}");
            sw.WriteLine("");

            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Close Project");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("project close");
            sw.WriteLine("");
            /*
            sw.WriteLine("#########################################################################");
            sw.WriteLine("# Download");
            sw.WriteLine("#########################################################################");
            sw.WriteLine("");

            sw.WriteLine("#");
            sw.WriteLine("# Programming the device");
            sw.WriteLine("#");
            sw.WriteLine("");

            sw.WriteLine("# The following code was adapted from ISE.pm");
            sw.WriteLine("");

            sw.WriteLine("puts -nonewline \"Would you like to program the device? y/n: \"");
            sw.WriteLine("flush stdout");
            sw.WriteLine("");

            sw.WriteLine("set progDevice [gets stdin]");
            sw.WriteLine("");

            sw.WriteLine("if {$progDevice != \"y\"} {");
            sw.WriteLine("	puts \"User does not want to program the device...\"");
            sw.WriteLine("} else {");
            sw.WriteLine("  set impact_script_filename impact_script.scr");
            sw.WriteLine("  set bit_filename $top_name.bit");
            sw.WriteLine("  if {[catch {set f_id [open $impact_script_filename w]} msg]} {");
            sw.WriteLine("    puts \"Can't create $impact_script_filename\"");
            sw.WriteLine("    puts $msg");
            sw.WriteLine("    exit");
            sw.WriteLine("  }");
            sw.WriteLine("");

            sw.WriteLine("  # Assume Spartan6 starter kit");
            sw.WriteLine("");

            sw.WriteLine("  if { $cableserver_host == \"\" } {");
            sw.WriteLine("          # Assume using locally connected board (not using VMware or Linux via VNC)");
            sw.WriteLine("          puts $f_id \"setMode -bscan\"");
            sw.WriteLine("          puts $f_id \"setCable -p usb21\"");
            sw.WriteLine("  } else {");
            sw.WriteLine("        # Assume using cableserver on cableserver_host");
            sw.WriteLine("        puts $f_id \"setMode -bscan\"");
            sw.WriteLine("        puts $f_id \"setCable -p usb21 -server $cableserver_host\"");
            sw.WriteLine("  }");
            sw.WriteLine("  puts $f_id \"addDevice -position 1 -file $bit_filename\"");
            sw.WriteLine("  puts $f_id \"addDevice -p 2 -part xcf08p\"");
            sw.WriteLine("  puts $f_id \"addDevice -p 3 -part xcf32p\"");
            sw.WriteLine("  puts $f_id \"readIdcode -p 1\"");
            sw.WriteLine("  puts $f_id \"program -p 1\"");
            sw.WriteLine("  puts $f_id \"quit\"");
            sw.WriteLine("");

            sw.WriteLine("  close $f_id");
            sw.WriteLine("");

            sw.WriteLine("  puts \"\\n\"");
            sw.WriteLine("  puts \"  Switch on the board, connect the USB cable.\"");
            sw.WriteLine("  puts -nonewline \"  Press Enter when you are ready to download...\\a\"");
            sw.WriteLine("  flush stdout");
            sw.WriteLine("");

            sw.WriteLine("  # The \"gets\" command fails with the following message, if running within");
            sw.WriteLine("  # the ISE Project Navigator GUI.");
            sw.WriteLine("  #");
            sw.WriteLine("  #   channel \"stdin\" wasn't opened for reading");
            sw.WriteLine("");

            sw.WriteLine("  if [catch {gets stdin ignore_me} msg] {");
            sw.WriteLine("    puts \"\\n\\n *** $msg\"");
            sw.WriteLine("    puts \" *** Carrying on regardless...\\n\"");
            sw.WriteLine("    flush stdout");
            sw.WriteLine("  }");
            sw.WriteLine("");

            sw.WriteLine("  set impact_p [open \"|impact -batch $impact_script_filename\" r]");
            sw.WriteLine("  while {![eof $impact_p]} { gets $impact_p line ; puts $line }");
            sw.WriteLine("  close $impact");
            sw.WriteLine("}");

            sw.WriteLine("");
            */
            sw.WriteLine("puts \"\\nEnd of ISE Tcl script.\\n\\n\"");

            sw.Close();

        }

        /// <summary>
        /// Writes a VHDL file for interfacing NAS with SpiNNaker
        /// </summary>
        /// <param name="version">Interface version. 1 for unidirectional communication, 2 for bidirectional communication</param>
        /// <param name="route">Destination file route</param>
        private void WriteSpiNNakerIF(int version, string route)
        {
            string moduleName = "SpiNNakerNAS_if" + version.ToString();
            string fileExtension = ".vhd";

            StreamWriter sw = new StreamWriter(route + "\\" + moduleName + fileExtension);

            sw.WriteLine(HDLGenerable.copyLicense('H'));
            sw.WriteLine("");

            sw.WriteLine("library IEEE;");
            sw.WriteLine("use IEEE.STD_LOGIC_1164.ALL;");
            sw.WriteLine("");

            sw.WriteLine("-- Uncomment the following library declaration if using");
            sw.WriteLine("-- arithmetic functions with Signed or Unsigned values");
            sw.WriteLine("use IEEE.NUMERIC_STD.ALL;");
            sw.WriteLine("");
            sw.WriteLine("");

            sw.WriteLine("entity "+ moduleName + " is");
            sw.WriteLine("    port(");
            sw.WriteLine("        ----Clock and external reset button----");
            sw.WriteLine("        i_ext_clock : in std_logic;");
            sw.WriteLine("        i_ext_reset : in std_logic;");
            sw.WriteLine("        ----Spikes source: from external world to FPGA----");
            sw.WriteLine("        --NAS--");
            AudioInputControl.NASAUDIOSOURCE nasInputIF = AudioInputControl.audioSource;

            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.AC97)
            {
                sw.WriteLine("        --AC Link");
                sw.WriteLine("        i_nas_ac97_bit_clock  : in std_logic;");
                sw.WriteLine("        i_nas_ac97_sdata_in : in std_logic;");
                sw.WriteLine("        i_nas_ac97_sdata_out : out std_logic;");
                sw.WriteLine("        i_nas_ac97_synch : out std_logic;");
                sw.WriteLine("        i_nas_audio_reset_b : out std_logic;");
            }
            if((nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2S) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("        --I2S Bus");
                sw.WriteLine("        i_nas_i2s_bclk : in  std_logic;");
                sw.WriteLine("        i_nas_i2s_din : in  std_logic;");
                sw.WriteLine("        i_nas_i2s_lr : in  std_logic;");
            }
            if((nasInputIF == AudioInputControl.NASAUDIOSOURCE.PDM) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("        --PDM");
                sw.WriteLine("        i_nas_pdm_clk_left : in std_logic;");
                sw.WriteLine("        i_nas_pdm_data_left : in std_logic;");
                if(version == 2)
                {
                    sw.WriteLine("        i_nas_pdm_clk_rigth : in std_logic;");
                    sw.WriteLine("        i_nas_pdm_data_rigth : in std_logic;");
                }
            }
            if(nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("        --Spikes source selector");
                sw.WriteLine("        i_nas_source_sel : in std_logic;");
            }

            sw.WriteLine("        ----Processing interface----");
            sw.WriteLine("        --Data: FPGA to SpiNNaker");
            sw.WriteLine("        o_data_out_to_spinnaker: out std_logic_vector(6 downto 0);");
            sw.WriteLine("        i_ack_out_from_spinnaker: in std_logic"+(version == 1?"":";"));
            if(version == 2)
            {
                sw.WriteLine("        --Data: SpiNNaker to FPGA");
                sw.WriteLine("        i_data_in_from_spinnaker : in std_logic_vector(6 downto 0);");
                sw.WriteLine("        o_ack_in_to_spinnaker : out std_logic;");
                sw.WriteLine("        --SpiNNaker driver - User interface");
                sw.WriteLine("        o_spinn_ui_status_active : out std_logic;");
                sw.WriteLine("        o_spinn_ui_status_reset : out std_logic;");
                sw.WriteLine("        o_spinn_ui_status_dump : out std_logic;");
                sw.WriteLine("        o_spinn_ui_status_error : out std_logic");
            }
            
            sw.WriteLine("    );");
            sw.WriteLine("end "+ moduleName+";");
            sw.WriteLine("");

            sw.WriteLine("architecture " + moduleName + "_arch of " + moduleName + " is");
            sw.WriteLine("");

            sw.WriteLine("-- Component declarations");
            sw.WriteLine("");

            sw.WriteLine("    ---------------------------");
            sw.WriteLine("    ----------- NAS -----------");
            sw.WriteLine("    ---------------------------");
            sw.WriteLine("    component OpenNas_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch is");
            sw.WriteLine("    port(");
            sw.WriteLine("        clock : in std_logic;");
            sw.WriteLine("        rst_ext : in std_logic;");
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.AC97)
            {
                sw.WriteLine("        --AC Link");
                sw.WriteLine("        ac97_bit_clock  : in std_logic;");
                sw.WriteLine("        ac97_sdata_in : in std_logic;");
                sw.WriteLine("        ac97_sdata_out : out std_logic;");
                sw.WriteLine("        ac97_synch : out std_logic;");
                sw.WriteLine("        audio_reset_b : out std_logic;");
            }
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2S) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("        --I2S Bus");
                sw.WriteLine("        i2s_bclk : in  std_logic;");
                sw.WriteLine("        i2s_d_in : in  std_logic;");
                sw.WriteLine("        i2s_lr : in  std_logic;");
            }
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.PDM) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("        --PDM");
                sw.WriteLine("        pdm_clk_left : in std_logic;");
                sw.WriteLine("        pdm_data_left : in std_logic;");
                if(nasCommons.monoStereo == NASTYPE.STEREO)
                {
                    sw.WriteLine("        pdm_clk_rigth : in std_logic;");
                    sw.WriteLine("        pdm_data_rigth : in std_logic;");
                }
            }
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("        --Spikes source selector");
                sw.WriteLine("        source_sel : in std_logic;");
            }

            sw.WriteLine("        --AER Output");
            sw.WriteLine("        AER_DATA_OUT : out std_logic_vector(15 downto 0);");
            sw.WriteLine("        AER_REQ : out std_logic;");
            sw.WriteLine("        AER_ACK : in std_logic");
            sw.WriteLine("        );");
            sw.WriteLine("    end component;");
            sw.WriteLine("");

            sw.WriteLine("    -------------------------------------------");
            sw.WriteLine("    ----------- SpiNNaker interface -----------");
            sw.WriteLine("    -------------------------------------------");
            if(version == 2)
            {
                sw.WriteLine("    component raggedstone_spinn_aer_if_top is");
                sw.WriteLine("    port(");
                sw.WriteLine("        ext_nreset: in std_logic;");
                sw.WriteLine("        ext_clk: in std_logic;");
                sw.WriteLine("        --// display interface (7-segment and leds)");
                sw.WriteLine("        ext_mode_sel: in std_logic;");
                sw.WriteLine("        ext_7seg: out std_logic_vector(7 downto 0);");
                sw.WriteLine("        ext_strobe: out std_logic_vector(3 downto 0);");
                sw.WriteLine("        ext_led2: out std_logic;");
                sw.WriteLine("        ext_led3: out std_logic;");
                sw.WriteLine("        ext_led4: out std_logic;");
                sw.WriteLine("        ext_led5: out std_logic;");
                sw.WriteLine("        --// input from SpiNNaker link interface");
                sw.WriteLine("        data_2of7_from_spinnaker: in std_logic_vector(6 downto 0);");
                sw.WriteLine("        ack_to_spinnaker: out std_logic;");
                sw.WriteLine("        --// output to SpiNNaker link interface");
                sw.WriteLine("        data_2of7_to_spinnaker: out std_logic_vector(6 downto 0);");
                sw.WriteLine("        ack_from_spinnaker: in std_logic;");
                sw.WriteLine("        --// input from AER device interface");
                sw.WriteLine("        iaer_data: in std_logic_vector(15 downto 0);");
                sw.WriteLine("        iaer_req: in std_logic;");
                sw.WriteLine("        iaer_ack: out std_logic;");
                sw.WriteLine("        --// output to AER device interface");
                sw.WriteLine("        oaer_data: out std_logic_vector(15 downto 0);");
                sw.WriteLine("        oaer_req: out std_logic;");
                sw.WriteLine("        oaer_ack: in std_logic");
                
            }
            else if (version == 1)
            {
                sw.WriteLine("    component spinn_aer_if is");
                sw.WriteLine("    port (");
                sw.WriteLine("        clk: in  STD_LOGIC;");
                sw.WriteLine("        data_2of7_to_spinnaker: out STD_LOGIC_VECTOR(6 downto 0);");
                sw.WriteLine("        ack_from_spinnaker: in STD_LOGIC;");
                sw.WriteLine("        aer_req: in STD_LOGIC;");
                sw.WriteLine("        aer_data: in STD_LOGIC_VECTOR(15 downto 0);");
                sw.WriteLine("        aer_ack: out STD_LOGIC;");
                sw.WriteLine("        reset: in STD_LOGIC");
            }
            else
            {

            }

            sw.WriteLine("    );");
            sw.WriteLine("    end component;");
            sw.WriteLine("");

            if(version == 2)
            {
                sw.WriteLine("    -------------------------------------");
                sw.WriteLine("    ----------- AER In module -----------");
                sw.WriteLine("    -------------------------------------");
                sw.WriteLine("    component AER_IN is");
                sw.WriteLine("    port(");
                sw.WriteLine("        i_clk : in  std_logic;");
                sw.WriteLine("        i_rst : in  std_logic;");
                sw.WriteLine("        --AER handshake");
                sw.WriteLine("        i_aer_in : in  std_logic_vector (15 downto 0);");
                sw.WriteLine("        i_req_in : in  std_logic;");
                sw.WriteLine("        o_ack_in : out  std_logic;");
                sw.WriteLine("        --AER data output to be processed");
                sw.WriteLine("        o_aer_data : out std_logic_vector(15 downto 0);");
                sw.WriteLine("        o_new_aer_data : out std_logic");
                sw.WriteLine("        );");
                sw.WriteLine("    end component;");
                sw.WriteLine("");
            }
            

            sw.WriteLine("    -------------------------------------------");
            sw.WriteLine("    ----------- Signals declaration -----------");
            sw.WriteLine("    -------------------------------------------");
            sw.WriteLine("");

            sw.WriteLine("    --Reset signals");
            sw.WriteLine("    signal reset : std_logic;");
            sw.WriteLine("    signal n_reset : std_logic;");
            sw.WriteLine("");

            sw.WriteLine("    --Signals to connect AER interface from OpenNAS module to SpiNN-AER interface module");
            sw.WriteLine("    signal aer_data_NAS_to_spinn : std_logic_vector(15 downto 0);");
            sw.WriteLine("    signal aer_req_NAS_to_spinn : std_logic;");
            sw.WriteLine("    signal aer_ack_NAS_to_spinn : std_logic;");
            sw.WriteLine("");

            if(version == 2)
            {
                sw.WriteLine("    --Signals to connect AER interface from SpiNN-AER interface module with AER processing module");
                sw.WriteLine("    signal aer_data_spinn_to_fpga : std_logic_vector(15 downto 0);");
                sw.WriteLine("    signal aer_req_spinn_to_fpga : std_logic;");
                sw.WriteLine("    signal aer_ack_spinn_to_fpga : std_logic;");
                sw.WriteLine("");

                sw.WriteLine("    --AER events from SpiNNaker to be processed");
                sw.WriteLine("    signal aer_data_from_spinn : std_logic_vector(15 downto 0);");
                sw.WriteLine("    signal new_aer_data_from_spinn : std_logic;");
                sw.WriteLine("");

                sw.WriteLine("    --Unconnected signals");
                sw.WriteLine("    signal modesel: std_logic;");
                sw.WriteLine("    signal d_7seg: std_logic_vector(7 downto 0);");
                sw.WriteLine("    signal strobe: std_logic_vector(3 downto 0);");
                sw.WriteLine("");
            }

            sw.WriteLine("    begin");
            sw.WriteLine("");

            sw.WriteLine("        reset <= i_ext_reset;");
            sw.WriteLine("        n_reset <= not i_ext_reset;");
            sw.WriteLine("");

            if(version == 2)
            {
                sw.WriteLine("        --TEMP");
                sw.WriteLine("        modesel<= n_reset;");
                sw.WriteLine("");
            }

            sw.WriteLine("        U_NAS: OpenNas_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch is");
            sw.WriteLine("        port map(");
            sw.WriteLine("            clock => i_ext_clock,");
            sw.WriteLine("            rst_ext => reset,");
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.AC97)
            {
                sw.WriteLine("            --AC Link");
                sw.WriteLine("            ac97_bit_clock => i_nas_ac97_bit_clock,");
                sw.WriteLine("            ac97_sdata_in => i_nas_ac97_sdata_in,");
                sw.WriteLine("            ac97_sdata_out => i_nas_ac97_sdata_out,");
                sw.WriteLine("            ac97_synch => i_nas_ac97_synch,");
                sw.WriteLine("            audio_reset_b => i_nas_audio_reset_b,");
            }
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2S) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("            --I2S Bus");
                sw.WriteLine("            i2s_bclk => i_nas_i2s_bclk,");
                sw.WriteLine("            i2s_d_in => i_nas_i2s_din,");
                sw.WriteLine("            i2s_lr => i_nas_i2s_lr,");
            }
            if ((nasInputIF == AudioInputControl.NASAUDIOSOURCE.PDM) || (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM))
            {
                sw.WriteLine("            --PDM");
                sw.WriteLine("            pdm_clk_left => i_nas_pdm_clk_left,");
                sw.WriteLine("            pdm_data_left => i_nas_pdm_data_left,");
                if(nasCommons.monoStereo == NASTYPE.STEREO)
                {
                    sw.WriteLine("            pdm_clk_rigth => i_nas_pdm_clk_rigth,");
                    sw.WriteLine("            pdm_data_rigth => i_nas_pdm_data_rigth,");
                }
            }
            if (nasInputIF == AudioInputControl.NASAUDIOSOURCE.I2SPDM)
            {
                sw.WriteLine("            --Spikes source selector");
                sw.WriteLine("            source_sel => i_nas_source_sel,");
            }
            sw.WriteLine("            --AER Output");
            sw.WriteLine("            AER_DATA_OUT => aer_data_NAS_to_spinn,");
            sw.WriteLine("            AER_REQ => aer_req_NAS_to_spinn,");
            sw.WriteLine("            AER_ACK => aer_ack_NAS_to_spinn");
            sw.WriteLine("        );");
            sw.WriteLine("");

            if(version == 2)
            {
                sw.WriteLine("        U_SpiNNaker_driver: raggedstone_spinn_aer_if_top");
            }
            else if(version == 1)
            {
                sw.WriteLine("        U_SpiNNaker_driver: spinn_aer_if");
            }
            else
            {

            }

            sw.WriteLine("        port map(");
            if(version == 2)
            {
                sw.WriteLine("            ext_nreset => reset,");
                sw.WriteLine("            ext_clk => i_ext_clock,");
                sw.WriteLine("            --// display interface (7-segment and leds)");
                sw.WriteLine("            ext_mode_sel => modesel,");
                sw.WriteLine("            ext_7seg => d_7seg,");
                sw.WriteLine("            ext_strobe => strobe,");
                sw.WriteLine("            ext_led2 => o_spinn_ui_status_active,");
                sw.WriteLine("            ext_led3 => o_spinn_ui_status_reset,");
                sw.WriteLine("            ext_led4 => o_spinn_ui_status_dump,");
                sw.WriteLine("            ext_led5 => o_spinn_ui_status_error,");
                sw.WriteLine("            --// input from SpiNNaker link interface");
                sw.WriteLine("            data_2of7_from_spinnaker => i_data_in_from_spinnaker,");
                sw.WriteLine("            ack_to_spinnaker => o_ack_in_to_spinnaker,");
                sw.WriteLine("            --// output to SpiNNaker link interface");
                sw.WriteLine("            data_2of7_to_spinnaker => o_data_out_to_spinnaker,");
                sw.WriteLine("            ack_from_spinnaker => i_ack_out_from_spinnaker,");
                sw.WriteLine("            --// input from AER device interface");
                sw.WriteLine("            iaer_data => aer_data_NAS_to_spinn,");
                sw.WriteLine("            iaer_req => aer_req_NAS_to_spinn,");
                sw.WriteLine("            iaer_ack => aer_ack_NAS_to_spinn,");
                sw.WriteLine("            --// output to AER device interface");
                sw.WriteLine("            oaer_data => aer_data_spinn_to_fpga,");
                sw.WriteLine("            oaer_req => aer_req_spinn_to_fpga,");
                sw.WriteLine("            oaer_ack => aer_ack_spinn_to_fpga");
                sw.WriteLine("        );");
            }
            else if (version == 1)
            {
                sw.WriteLine("            clk => i_ext_clock,");
                sw.WriteLine("            data_2of7_to_spinnaker => o_data_out_to_spinnaker,");
                sw.WriteLine("            ack_from_spinnaker => i_ack_out_from_spinnaker,");
                sw.WriteLine("            aer_req => aer_req_NAS_to_spinn,");
                sw.WriteLine("            aer_data => aer_data_NAS_to_spinn,");
                sw.WriteLine("            aer_ack => aer_ack_NAS_to_spinn,");
                sw.WriteLine("            reset => n_reset");
                sw.WriteLine("        );");
                sw.WriteLine("");
            }
            else
            {

            }
            sw.WriteLine("");

            if(version == 2)
            {
                sw.WriteLine("        U_AER_in: AER_IN");
                sw.WriteLine("        port map(");
                sw.WriteLine("            i_clk => i_ext_clock,");
                sw.WriteLine("            i_rst => reset,");
                sw.WriteLine("            --AER handshake");
                sw.WriteLine("            i_aer_in => aer_data_spinn_to_fpga,");
                sw.WriteLine("            i_req_in => aer_req_spinn_to_fpga,");
                sw.WriteLine("            o_ack_in => aer_ack_spinn_to_fpga,");
                sw.WriteLine("            --AER data output to be processed");
                sw.WriteLine("            o_aer_data => aer_data_from_spinn,");
                sw.WriteLine("            o_new_aer_data => new_aer_data_from_spinn");
                sw.WriteLine("        );");
                sw.WriteLine("");
            }


            sw.WriteLine("end Behavioral;");

            sw.Close();

            List<string> dependencies = new List<string>();

            if (version == 2)
            {
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_top.h");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link.h");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_control.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_debouncer.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_dump.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_router.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_top.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\raggedstone_spinn_aer_if_user_int.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spinn_aer_if.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_aer2spinn_mapper.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinn2aer_mapper.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link_sync.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link_synchronous_receiver.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_spinnaker_link_synchronous_sender.v");
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spio_switch.v");

                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\AER_IN.vhd");
            }
            else
            {
                dependencies.Add(@"SSPLibrary\SpikesOutputInterfaces\spinn_aer_if.v");
            }

            for (int i = 0; i < dependencies.Count; i++)
            {
                string[] s = dependencies[i].Split('\\');
                System.IO.File.Copy(dependencies[i], route + "\\" + s[s.Length - 1], true);
            }
        }

        /// <summary>
        /// Writes NAS architecture and settings as a XML file
        /// </summary>
        /// <param name="route">Destination file route</param>
        public void ToXML(string route)
        {
            string nasName = "OpenNas_TOP_" + audioProcessing.getShortDescription() + "_" + nasCommons.monoStereo.ToString("G") + "_" + nasCommons.nCh + "ch";

            string filename = route + "\\" + nasName + ".xml";
            CultureInfo ci = new CultureInfo("en-us");
            XmlTextWriter textWriter;
            textWriter = new XmlTextWriter(filename, null);

            textWriter.WriteStartDocument();
            textWriter.Formatting = Formatting.Indented;
            textWriter.Indentation = 2;

            textWriter.WriteStartElement("OpenNAS");
            textWriter.WriteAttributeString("Version", "1.0");

            nasCommons.toXML(textWriter);
            audioInput.toXML(textWriter);
            audioProcessing.toXML(textWriter);
            spikesOutput.toXML(textWriter);

            textWriter.WriteEndElement();
            textWriter.WriteEndDocument();
            textWriter.Close();

        }
    }
}
