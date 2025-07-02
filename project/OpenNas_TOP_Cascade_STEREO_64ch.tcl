#///////////////////////////////////////////////////////////////////////////////
#//                                                                           //
#//    Copyright © 2016  Angel Francisco Jimenez-Fernandez                    //
#//                                                                           //
#//    This file is part of OpenNAS.                                          //
#//                                                                           //
#//    OpenNAS is free software: you can redistribute it and/or modify        //
#//    it under the terms of the GNU General Public License as published by   //
#//    the Free Software Foundation, either version 3 of the License, or      //
#//    (at your option) any later version.                                    //
#//                                                                           //
#//    OpenNAS is distributed in the hope that it will be useful,             //
#//    but WITHOUT ANY WARRANTY; without even the implied warranty of         //
#//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the            //
#//    GNU General Public License for more details.                           //
#//                                                                           //
#//    You should have received a copy of the GNU General Public License      //
#//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.        //
#//                                                                           //
#///////////////////////////////////////////////////////////////////////////////


#///////////////////////////////////////////////////////////////////////
#/////////////////////////////// README ////////////////////////////////
#///////////////////////////////////////////////////////////////////////
# For running the script:
#     -Open ISE Design Suite 32/64 Bit Command Prompt
#     -Change the current directory to which the .tcl file is located
#     -Write the command: xtclsh scriptname.tcl
#///////////////////////////////////////////////////////////////////////

#
# Input files
#

# where the design will be compiled and where all output will be created
set compile_directory OpenNas

# the top-level of our HDL source:
set top_name OpenNas_Cascade_STEREO_64ch

# input source files:

# WARNING: OpenNas TOP module could have different names
set hdl_files [ list \
  ../../sources/I2S_inteface_sync.vhd \
  ../../sources/Spikes_Generator_signed_BW.vhd \
  ../../sources/i2s_to_spikes_stereo.vhd \
  ../../sources/AER_HOLDER_AND_FIRE.vhd \
  ../../sources/AER_DIF.vhd \
  ../../sources/spikes_div_BW.vhd \
  ../../sources/Spike_Int_n_Gen_BW.vhd \
  ../../sources/spikes_LPF_fullGain.vhd \
  ../../sources/spikes_2LPF_fullGain.vhd \
  ../../sources/spikes_2BPF_fullGain.vhd \
  ../../sources/CFBank_64.vhd \
  ../../sources/AER_DISTRIBUTED_MONITOR_MODULE.vhd \
  ../../sources/AER_DISTRIBUTED_MONITOR.vhd \
  ../../sources/DualPortRAM.vhd \
  ../../sources/ramfifo.vhd \
  ../../sources/handsakeOut.vhd \
  ../../sources/AER_OUT.vhd \
  ../../sources/OpenNas_TOP_Cascade_STEREO_64ch.vhd \
]
add_files -norecurse -fileset $obj $hdl_files

# constraints with pin placements. This file will need to be replaced if you
# are using a different Xilinx device or board.
set constraints_file      ../../constraints/Node_constraints.ucf

# Remember: set variable_name value for user variables
# implement the design
#////////////////////////////////////////////////////////////////////////
#// Set cableserver host                                               //
#////////////////////////////////////////////////////////////////////////

# If your starter kit is connected to a remote machine, edit the following
# line to include the name of the Xilinx CableServer host PC:

set cableserver_host {}

#////////////////////////////////////////////////////////////////////////
#// Set Tcl Variables                                                  //
#////////////////////////////////////////////////////////////////////////

set version_number "1.0"

set proj $top_name

#////////////////////////////////////////////////////////////////////////
#// Welcome                                                            //
#////////////////////////////////////////////////////////////////////////

puts "Running Xilinx Tcl script \"NAS_projectgen.tcl\" from OpenNAS, version $version_number."

if { $cableserver_host == "" } {
  puts "Running with Spartan6 board connected to the local PC.\n"
} else {
  puts "Running with Spartan6 board connected to $cableserver_host.\n"
}

#////////////////////////////////////////////////////////////////////////
#// Create a directory in which to run                                 //
#////////////////////////////////////////////////////////////////////////

#
# Setting a compilation directory
#

# Run in the compile directory
# If the directory doesn't already exist then create it.
if {![file isdirectory $compile_directory]} {
  file mkdir $compile_directory
}

# change to the directory
cd $compile_directory

#////////////////////////////////////////////////////////////////////////
#// Create a new project or open project                               //
#////////////////////////////////////////////////////////////////////////
# This if-then-else statement looks to see if this is the first time the
# script has been run - if so, it will setup the project.  If not, the
# project already exists - therefore, it will simply open the project.

#
# Project creation and settings
#

set proj_exists [file exists $proj.xise]

if {$proj_exists == 0} {
	
  puts "Creating a new project..."
  
  # Create new project
  project new $proj.xise
  # Project settings
  project set family Spartan6
  project set device xc6slx150t
  project set package fgg484
  project set speed -3
  
  # Add files to the project (must come after the settings)
  foreach filename $hdl_files {
      xfile add $filename
      puts "Adding file $filename to the project."
  }
  xfile add $constraints_file
  # Test to see if $source_directory is set ...
  if { ! [catch {set source_directory $source_directory}] } {
      project set "Macro Search Path" $source_directory -process Translate
  }
  
} else {
  puts "Opening the existing project..."
  # Open the previously created project
  project open $proj.xise
}

#////////////////////////////////////////////////////////////////////////
# Implementation Properties
# See TCL chapter of the Xilinx Development System Reference Guide for
# how to set controls on the various processes.
# These are included as examples.
#////////////////////////////////////////////////////////////////////////
# MAP
#project set "Map Effort Level" Medium -process map
#project set "Perform Timing-Driven Packing and Placement" true -process map
#project set "Register Duplication" true -process map
#project set "Retiming" true -process map
#
# PAR
#project set "Place & Route Effort Level (Overall)" Standard
#project set "Extra Effort (Highest PAR level only)" Normal


#////////////////////////////////////////////////////////////////////////
#// Implement Design                                                   //
#////////////////////////////////////////////////////////////////////////

#
# Running processes
#

puts -nonewline "Would you like run the Generate Programming File process ? y/n : "
flush stdout

set genBitFile [gets stdin]

if {$genBitFile == "y"} {
	process run "Generate Programming File"
  #process run "Implement Design" -force rerun_all
  puts "Running..."
} elseif {$genBitFile == "n"} {
	puts "User does not want to generate the .bit file..."
} else {
	puts "Unknown option..."
}

#////////////////////////////////////////////////////////////////////////
#// Close Project                                                      //
#////////////////////////////////////////////////////////////////////////
project close

puts "\nEnd of Tcl script.\n\n"
