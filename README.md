# OpenN@S

<h2 name="Description">Description</h2>
<p align="justify">
<!--What OpenNAS is; Its main features-->
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

<p align="justify">
<!--Add some brief instructions and introduction and maybe a link to a videotutorial!-->
 OpenNAS is a five-steps wizard which helps you to design and configurate a NAS in a easy way. Each step is focused on a specific section of the sensor, divided in Commons, Input, Processing and Output. User can set many parameters, like filters attenuation, number of frequencies channels, etc. The meaning of all of these parameters will be detailed in the OpenNAS wiki.
</p>

<p align="justify">
In this brief tutorial, we will guide to the user in how to download, configure and run OpenNAS tool. Until now, we do not have a videotutorial, but we are working on it!
</p>

 <!-- How to install OpenN@S and what prerrequisites are needed. -->
<h3>Software dependencies</h3>
<p align="justify">
The tool has several software dependencies to be executed in your computer. Since OpenNAS is a .NET-based software application, a Microsoft .NET Framework needs to be installed, among others. Next, the OpenNAS software requeriments list is showed:
</p>
  <ul>
    <li>Microsoft .NET Framework 4.5</li>By clicking in this link you will be redirected to the Microsoft .NET Framework download website. User just has to select the desired language and then click on the "Download" button. Once the downloading has been finished, execute the Microsoft .NET Framework installation file. 
	<li>Xilinx ISE or Vivado</li>OpenNAS offers to the user the posibility of automatically generates the .bit file without to create an ISE project manually. For being able to use this feature, Xilinx software tool needs to be installed. Depending of the target FPGA chip, the user will need Xilinx ISE or Xilinx Vivado.
  </ul>
</p>
<h3>Installation</h3>
<p align="justify">
  First step to use OpenNAS software is to download the repository from the RTC-OpenNAS GitHub main webpage. Click on "Clone or download" button, and select "Download ZIP".
</p>
 
<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_download_repo.png">
 
<p align="justify">
  When downloaded, extract the project. There is a main folder, OpenNAS, which contains the OpenNAS.sln file and the OpenNAS C# project folder. To run the OpenNAS software tool, open the OpenNAS project by clicking on OpenNAS.sln, and then the VisualStudio environment will be launched. Click on the "Start" button. Then, the Welcome window of the OpenNAS tool will appear.
</p>

<img align="center" src="https://github.com/RTC-research-group/OpenNAS/blob/master/OpenNAS/Wiki_files/Images/Img_OpenNAS_Welcome.PNG">

<h2 name="Usage">Usage</h2>
<p align="justify">
<!--Add a brief tutorial or user manual in order to make it easy and understandable to work with OpenN@S for a user that has not tried it yet. Add images and stuff. This could easily be the transcription of the videotutorial and some screenshots from it.-->
   
</p>

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
<li>...</li>
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
