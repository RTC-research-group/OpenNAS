####### Clock #######

set_property PACKAGE_PIN P15 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]

####### GP_1 --> PDM microph v1 PCB #######

#set_property PACKAGE_PIN G16 [get_ports PDM_CLK_LEFT]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_CLK_LEFT]

#set_property PACKAGE_PIN G14 [get_ports PDM_DAT_LEFT]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_DAT_LEFT]

#set_property PACKAGE_PIN H16 [get_ports PDM_CLK_RIGTH]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_CLK_RIGTH]

#set_property PACKAGE_PIN F16 [get_ports PDM_DAT_RIGTH]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_DAT_RIGTH]

#####################################################################

####### GP_1 --> PDM microph. and line-in with ADC CSxxxx PCB #######

set_property PACKAGE_PIN G17 [get_ports PDM_CLK_LEFT]
set_property IOSTANDARD LVCMOS33 [get_ports PDM_CLK_LEFT]

set_property PACKAGE_PIN H17 [get_ports PDM_DAT_LEFT]
set_property IOSTANDARD LVCMOS33 [get_ports PDM_DAT_LEFT]

#set_property PACKAGE_PIN G18 [get_ports PDM_CLK_RIGTH]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_CLK_RIGTH]

#set_property PACKAGE_PIN F18 [get_ports PDM_DAT_RIGTH]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_DAT_RIGTH]

#set_property PACKAGE_PIN G16 [get_ports i2s_bclk]
#set_property IOSTANDARD LVCMOS33 [get_ports i2s_bclk]

#set_property PACKAGE_PIN G14 [get_ports i2s_d_in]
#set_property IOSTANDARD LVCMOS33 [get_ports i2s_d_in]

#set_property PACKAGE_PIN H16 [get_ports i2s_lr]
#set_property IOSTANDARD LVCMOS33 [get_ports i2s_lr]

#set_property PACKAGE_PIN F16 [get_ports source_sel]
#set_property IOSTANDARD LVCMOS33 [get_ports source_sel]
#######################################################################

####### AER-out interface #######

set_property PACKAGE_PIN M6 [get_ports {AER_DATA_OUT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[0]}]

set_property PACKAGE_PIN N5 [get_ports {AER_DATA_OUT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[1]}]

set_property PACKAGE_PIN L6 [get_ports {AER_DATA_OUT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[2]}]

set_property PACKAGE_PIN P4 [get_ports {AER_DATA_OUT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[3]}]

set_property PACKAGE_PIN L5 [get_ports {AER_DATA_OUT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[4]}]

set_property PACKAGE_PIN P3 [get_ports {AER_DATA_OUT[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[5]}]

set_property PACKAGE_PIN N4 [get_ports {AER_DATA_OUT[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[6]}]

set_property PACKAGE_PIN T1 [get_ports {AER_DATA_OUT[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[7]}]

set_property PACKAGE_PIN M4 [get_ports {AER_DATA_OUT[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[8]}]

set_property PACKAGE_PIN R1 [get_ports {AER_DATA_OUT[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[9]}]

set_property PACKAGE_PIN M3 [get_ports {AER_DATA_OUT[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[10]}]

set_property PACKAGE_PIN R2 [get_ports {AER_DATA_OUT[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[11]}]

set_property PACKAGE_PIN M2 [get_ports {AER_DATA_OUT[12]}]                                               
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[12]}]

set_property PACKAGE_PIN P2 [get_ports {AER_DATA_OUT[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[13]}]

set_property PACKAGE_PIN K5 [get_ports {AER_DATA_OUT[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[14]}]

set_property PACKAGE_PIN N2 [get_ports {AER_DATA_OUT[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AER_DATA_OUT[15]}]



set_property PACKAGE_PIN L4 [get_ports AER_REQ]
set_property IOSTANDARD LVCMOS33 [get_ports AER_REQ]

set_property PACKAGE_PIN N1 [get_ports AER_ACK]
set_property IOSTANDARD LVCMOS33 [get_ports AER_ACK]

########################################################################

############## SpiNNaker interface #################

#set_property PACKAGE_PIN C14 [get_ports {data_2of7_to_spinnaker[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[0]}]

#set_property PACKAGE_PIN D12 [get_ports {data_2of7_to_spinnaker[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[1]}]

#set_property PACKAGE_PIN D13 [get_ports {data_2of7_to_spinnaker[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[2]}]

#set_property PACKAGE_PIN A15 [get_ports {data_2of7_to_spinnaker[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[3]}]

#set_property PACKAGE_PIN A16 [get_ports {data_2of7_to_spinnaker[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[4]}]

#set_property PACKAGE_PIN B13 [get_ports {data_2of7_to_spinnaker[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[5]}]

#set_property PACKAGE_PIN B14 [get_ports {data_2of7_to_spinnaker[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_to_spinnaker[6]}]


#set_property PACKAGE_PIN B17 [get_ports ack_from_spinnaker]
#set_property IOSTANDARD LVCMOS33 [get_ports ack_from_spinnaker]

##SPINNAKER TO DATA

#set_property PACKAGE_PIN C16 [get_ports {data_2of7_from_spinnaker[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[0]}]

#set_property PACKAGE_PIN C17 [get_ports {data_2of7_from_spinnaker[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[1]}]

#set_property PACKAGE_PIN B18 [get_ports {data_2of7_from_spinnaker[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[2]}]

#set_property PACKAGE_PIN A18 [get_ports {data_2of7_from_spinnaker[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[3]}]

#set_property PACKAGE_PIN D15 [get_ports {data_2of7_from_spinnaker[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[4]}]

#set_property PACKAGE_PIN C15 [get_ports {data_2of7_from_spinnaker[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[5]}]

#set_property PACKAGE_PIN B16 [get_ports {data_2of7_from_spinnaker[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data_2of7_from_spinnaker[6]}]


#set_property PACKAGE_PIN D14 [get_ports ack_to_spinnaker]
#set_property IOSTANDARD LVCMOS33 [get_ports ack_to_spinnaker]
########################################################################

########## Output interfaces enables ############################

#set_property PACKAGE_PIN  [get_ports enable_AERout]
#set_property IOSTANDARD LVCMOS33 [get_ports enable_AERout]

#set_property PACKAGE_PIN  [get_ports enable_SpiNNout]
#set_property IOSTANDARD LVCMOS33 [get_ports enable_SpiNNout]

########################################################################

########## LEDs ###########

##LED 0
#set_property PACKAGE_PIN K16 [get_ports NAS_modes[0]]
#set_property IOSTANDARD LVCMOS33 [get_ports NAS_modes[0]]

###LED 1
#set_property PACKAGE_PIN J18 [get_ports NAS_modes[1]]
#set_property IOSTANDARD LVCMOS33 [get_ports NAS_modes[1]]

###LED 2
#set_property PACKAGE_PIN K15 [get_ports NAS_modes[2]]
#set_property IOSTANDARD LVCMOS33 [get_ports NAS_modes[2]]

###LED 3
#set_property PACKAGE_PIN J17 [get_ports test_recive]
#set_property IOSTANDARD LVCMOS33 [get_ports test_recive]

###LED 4
#set_property PACKAGE_PIN U8 [get_ports spinnaker_driver_error]
#set_property IOSTANDARD LVCMOS33 [get_ports spinnaker_driver_error]

###LED 5
#set_property PACKAGE_PIN V7 [get_ports spinnaker_driver_dump]
#set_property IOSTANDARD LVCMOS33 [get_ports spinnaker_driver_dump]

###LED 6
#set_property PACKAGE_PIN U9 [get_ports spinnaker_driver_active]
#set_property IOSTANDARD LVCMOS33 [get_ports spinnaker_driver_active]

###LED 7
#set_property PACKAGE_PIN V9 [get_ports spinnaker_driver_reset]
#set_property IOSTANDARD LVCMOS33 [get_ports spinnaker_driver_reset]

########################################################################

########## Buttons ###########

##Button PB0
#set_property PACKAGE_PIN F13 [get_ports ]
#set_property IOSTANDARD LVCMOS33 [get_ports ]

##Button PB1
#set_property PACKAGE_PIN E16 [get_ports rst_ext]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_ext]

##Button PB2
#set_property PACKAGE_PIN P5 [get_ports rst_ext]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_ext]

##Button PB3
#set_property PACKAGE_PIN R3 [get_ports ]
#set_property IOSTANDARD LVCMOS33 [get_ports ]

########################################################################