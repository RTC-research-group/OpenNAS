"""
--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2016  Angel Francisco Jimenez-Fernandez                    //
--//                                                                             //
--//    This file is part of OpenNAS.                                            //
--//                                                                             //
--//    NSSOC is free software: you can redistribute it and/or modify            //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    NSSOC is distributed in the hope that it will be useful,                 //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

-------------------------------------------------------------------------------
-- Title      : Python file for opening VHDL testbenches result files using PyNAVIS
-- Project    : OpenNAS
-------------------------------------------------------------------------------
-- File       : nas_config_test_analysis.py
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2021-06-03
-- Last update: 2021-06-03
-- Platform   : any
-- Standard   : Python 3
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-20  1.0      dgutierrez	Created
-------------------------------------------------------------------------------
"""

# Import packages
from pyNAVIS import *

# Set the NAS' parameters
nas_num_channels = 64
nas_mono_stereo = 1
nas_polarity = 2

# Set recording platform parameters
aer_address_size = 2
aer_ts_tick = 0.2

# Set pyNAVIS bin size parameter
pynavis_bin_size = 10000

# Create pyNAVIS settings
settings = MainSettings(num_channels=nas_num_channels, mono_stereo=nas_mono_stereo, on_off_both=nas_polarity, address_size=aer_address_size, ts_tick=aer_ts_tick, bin_size=pynavis_bin_size)

# Load file
spikes_info = Loaders.loadAEDAT('path/to/file/name.aedat', settings)