# OpenN@S

<h2 name="Description">Description</h2>
<!--What OpenNAS is; Its main features-->
<p align="justify">
OpenNAS is an open source VHDL-based Neuromorphic Auditory Sensor (NAS) code generator capable of automatically generating the necessary files to create a VHDL project for FPGA. OpenNAS guides designers with a friendly interface and allows NAS specification using a five-steps wizard for later code generation. It includes several audio input interfaces (AC'97 audio codec, I2S ADC and PDM microphones), different processing architectures (cascade and parallel), and a set of neuromorphic output interfaces (parallel AER, Spinnaker). After NAS generation, designers have everything prepared for building and synthesizing the VHDL project for a target FPGA using manufacturer's tools.
</p>

<h2>Table of contents</h2>
<p align="justify">
<ul>
<li><a href="#Description">Description</a></li>
<li><a href="#GettingStarted">Getting started</a></li>
<li><a href="#Usage">Usage</a></li>
<li><a href="#Contributing">Contributing</a></li>
<li><a href="#Credits">Credits</a></li>
<li><a href="#License">License</a></li>
<li><a href="#Cite">Cite this work</a></li>
</ul>
</p>

<h2 name="GettingStarted">Getting started</h2>

<!--Add some brief instructions and introduction and maybe a link to a videotutorial!-->
<p align="justify">
OpenNAS is a five-steps wizard which helps you to design and configurate a NAS in an easy way. Each step is focused on a specific section of the sensor, divided in: Commons, Input, Processing and Output. The user can set many parameters, like filters attenuation and number of frequency channels, among others. The meaning of all of these parameters is detailed in the OpenNAS wiki.
</p>

<p align="justify">
In this brief tutorial, we will guide the user in how to download, configure and run OpenNAS tool. For now, we do not have a videotutorial, but we are working on it!
</p>

<!-- How to install OpenN@S and what prerrequisites are needed. -->
<h3>Prerequisites</h3>
<p align="justify">OpenNAS has been programmed using Visual Studio Community 2015. Hence, user needs to have installed Visual Studio Community 2015 or greater to compile the project. In addition, Microsoft Windows 7 OS or greater is needed, since the .NET Framework version used in this work is not supported by Microsoft Windows XP OS. For Linux or MAC users, Visual Studio Code is not able to compile the OpenNAS project. Thus, a virtual machine with a Microsoft Windows OS installed have to be used.
</p>
 
<h3>Software dependencies</h3>
<p align="justify">
OpenNAS has several software dependencies which needs to be solved before executing it in your computer:
</p>
  <ul>
    <li>Microsoft .NET Framework 4.5</li>By clicking in this link you will be redirected to the Microsoft .NET Framework download website. You only need to select the desired language and then click on the "Download" button. Once the download has finished, execute the Microsoft .NET Framework installation file. 
	<li>Xilinx ISE 14.7</li>OpenNAS offers the posibility of generating the .bit file automatically without creating an ISE project manually. For being able to use this feature, Xilinx software tool needs to be installed. Depending of the target FPGA chip, the user will need Xilinx ISE or Xilinx Vivado.
  </ul>
</p>
<h3>Installation</h3>
<p align="justify">
The first step to use OpenNAS software is to download the repository from the RTC-OpenNAS GitHub main webpage. Click on "Clone or download" button, and select "Download ZIP".
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_download_repo.png" alt="Download OpenNAS repository">
</p>
 
<p align="justify">
When downloaded, extract the project. There is a main folder, OpenNAS, which contains the OpenNAS.sln file and the OpenNAS C# project folder. To run the OpenNAS software tool, open the OpenNAS project by clicking on OpenNAS.sln, and then the VisualStudio environment will be launched. Click on the "Start" button. Then, the Welcome window of the OpenNAS tool will appear.
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_tool_flow.png" alt="OpenNAS tool usage flow">	
</p>



<h2 name="Usage">Usage</h2>
<!--Add a brief tutorial or user manual in order to make it easy and understandable to work with OpenN@S for a user that has not tried it yet. Add images and stuff. This could easily be the transcription of the videotutorial and some screenshots from it.-->
<p align="justify">
Once OpenNAS tool has been executed, and the Welcome screen appears, the user only needs to complete the five steps of the OpenNAS wizard to obtain the generated VHDL files.
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Welcome.PNG" alt="OpenNAS wizard Welcome screen">
</p>

<p align="justify">
The Welcome screen show a brief text which indicates to the user what OpenNAS tool does and also the information about our research group. Click on Next button to move fordward in the wizard.
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Step1.png" alt="OpenNAS wizard step_1 screen">
</p>

<p align="justify">
The first step allows to the user to select the NAS common settings, which are the target FPGA chip and its clock frequency, if the NAS is MONO or STEREO, and the number of frequency channels. A picture of the FPGA-based board selected in NAS chip is showed to the user to quickly identify the needed hardware components. 
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Step2.png" alt="OpenNAS wizard step_2 screen">
</p>

<p align="justify">
In this step, the input audio source must be selected. There are several options, among which we can find the AC'97 audio codec, a pair of Pulse Density Modulation (PDM) microphones and an I2S-based audio codec. Each input option has its own configuration parameters, which the user can set according with its project requirements. 
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Step3.png" alt="OpenNAS wizard step_3 screen">
</p>

<p align="justify">
NAS processing architecture is defined in the step 3, where user can choose either a cascade or parallel architecture. Besides, filters order and filters output attenuation can be set. Finally, the user can define a frequency range between which the NAS will work, set by default as the human audible sounds range (from 20Hz to 22KHz).
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Step4.png" alt="OpenNAS wizard step_4 screen">
</p>

<p align="justify">
Output interface is selected in the fourth step. As in the most of the event-based neuromorphic devices, the AER protocol is used as output. For this reason, the AER monitor is used as output interface by default and then to connect our neuromorphic sensor to the application jAER and to be able to visualize the NAS output in real-time. However, it is also interesting to connect the NAS output to others neuromorphic hardware, as the SpiNNaker board, in which Spiking Neural Networks (SNN) can be deployed and it can get as input data the output spikes from the NAS.
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Step5.png" alt="OpenNAS wizard step_5 screen">
</p>



<p align="justify">
Finally, when all previous steps have been done, the destination folder in which the VHDL files are going to be generated has to be selected by the user. It needs to create a new folder by hand, and then select it as destination folder.
</p>

<p align="center">
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Success.png" alt="OpenNAS wizard success screen">
</p>

<p align="justify">
A new message will appear if the generation process was done successfully, indicating the destination folder. Click on the Ok button to close the message. At this point, the process of the NAS generation has finished. Navigatin to the destination folder, user can find all the VHDL files needed to synthetize and genenerate the NAS .bit file and run it using an FPGA. Apart from VHDL files, OpenNAS also generates a XML file summarizing the parameters selection made by the user.
</p>

<h2 name="Hardware">Hardware deployment</h2>


<h2 name="Contributing">Contributing</h2>
<p align="justify">
New functionalities or improvements to the existing project are welcome. To contribute to this project please follow these guidelines:
<ol align="justify">
<li> Search previous suggestions before making a new one, as yours may be a duplicate.</li>
<li> Fork the project.</li>
<li> Create a branch.</li>
<li> Commit your changes to improve the project.</li>
<li> Push this branch to your GitHub project.</li>
<li> Open a <a href="https://github.com/RTC-research-group/OpenNAS/pulls">Pull Request</a>.</li>
<li> Discuss, and optionally continue committing.</li>
<li> Wait untill the project owner merges or closes the Pull Request.</li>
</ol>
If it is a new feature request (e.g., a new functionality), post an issue to discuss this new feature before you start coding. If the project owner approves it, assign the issue to yourself and then do the steps above.
</p>
<p align="justify">
Thank you for contributing in the OpenN@S project!
</p>

<h2 name="Credits">Credits</h2>
<p align="justify">
The author of the OpenN@S' original idea is Angel F. Jimenez-Fernandez, and its mainly based on the paper <a href="https://ieeexplore.ieee.org/document/7523402/">"A Binaural Neuromorphic Auditory Sensor for FPGA: A Spike Signal Processing Approach"</a>, which was published in 2016 in the journal Transactions on Neural Networks and Learning Systems.
</p>
<p align="justify">
The author would like to thank and give credit to:
<ul align="justify">
<li>Robotics and Technology of Computers Lab.</li>
<li>Gabriel Jimenez-Moreno, for his support and contribution.
</ul>
</p>
	
<p align="justify">
Also, the author would like to thank to the research groups which supports the OpenNAS project and work with it: 	
<ul align="justify">
<li>Neuromorphic Behaving Systems, CITEC (U. Bielefeld), lead by Elisabetta Chicca.</li>
</ul>
</p>

<h2 name="License">License</h2>

<p align="justify">
This project is licensed under the GPL License - see the <a href="https://raw.githubusercontent.com/RTC-research-group/OpenNAS/master/LICENSE">LICENSE.md</a> file for details.
</p>
<p align="justify">
Copyright © 2016 Ángel F. Jiménez-Fernández<br>  
<a href="mailto:ajimenez@atc.us.es">ajimenez@atc.us.es</a>
</p>

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

<h2 name="Cite">Cite this work</h2>
<p align="justify">
<b>APA</b>: Jiménez-Fernández, A., Cerezuela-Escudero, E., Miró-Amarante, L., Domínguez-Morales, M. J., Gomez-Rodriguez, F., Linares-Barranco, A., & Jiménez-Moreno, G. (2017). A Binaural Neuromorphic Auditory Sensor for FPGA: A Spike Signal Processing Approach. IEEE Trans. Neural Netw. Learning Syst., 28(4), 804-818.
</p>
<p align="justify">
<b>ISO 690</b>: JIMÉNEZ-FERNÁNDEZ, Angel, et al. A Binaural Neuromorphic Auditory Sensor for FPGA: A Spike Signal Processing Approach. IEEE Trans. Neural Netw. Learning Syst., 2017, vol. 28, no 4, p. 804-818.
</p>
<p align="justify">
<b>MLA</b>: Jiménez-Fernández, Angel, et al. "A Binaural Neuromorphic Auditory Sensor for FPGA: A Spike Signal Processing Approach." IEEE Trans. Neural Netw. Learning Syst. 28.4 (2017): 804-818.
</p>
<p align="justify">
<b>BibTeX</b>: @article{jimenez2017binaural,
  title={A Binaural Neuromorphic Auditory Sensor for FPGA: A Spike Signal Processing Approach.},
  author={Jim{\'e}nez-Fern{\'a}ndez, Angel and Cerezuela-Escudero, Elena and Mir{\'o}-Amarante, Lourdes and Dom{\'\i}nguez-Morales, Manuel Jesus and Gomez-Rodriguez, Francisco and Linares-Barranco, Alejandro and Jim{\'e}nez-Moreno, Gabriel},
  journal={IEEE Trans. Neural Netw. Learning Syst.},
  volume={28},
  number={4},
  pages={804--818},
  year={2017}
}
</p>
