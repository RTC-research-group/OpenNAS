








create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/okt_sno_top_0_AER_DATA_OUT[0]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[1]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[2]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[3]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[4]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[5]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[6]} {design_1_i/okt_sno_top_0_AER_DATA_OUT[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[0]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[1]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[2]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[3]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[4]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[5]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[6]} {design_1_i/OpenNas_Parallel_STE_0_aer_data_out[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/okt_top_0_config_data[0]} {design_1_i/okt_top_0_config_data[1]} {design_1_i/okt_top_0_config_data[2]} {design_1_i/okt_top_0_config_data[3]} {design_1_i/okt_top_0_config_data[4]} {design_1_i/okt_top_0_config_data[5]} {design_1_i/okt_top_0_config_data[6]} {design_1_i/okt_top_0_config_data[7]} {design_1_i/okt_top_0_config_data[8]} {design_1_i/okt_top_0_config_data[9]} {design_1_i/okt_top_0_config_data[10]} {design_1_i/okt_top_0_config_data[11]} {design_1_i/okt_top_0_config_data[12]} {design_1_i/okt_top_0_config_data[13]} {design_1_i/okt_top_0_config_data[14]} {design_1_i/okt_top_0_config_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[0]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[1]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[2]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[3]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[4]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[5]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[6]} {design_1_i/OpenNas_Cascade_STER_0_aer_data_out[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/okt_top_0_config_en[0]} {design_1_i/okt_top_0_config_en[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 8 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/okt_top_0_leds[0]} {design_1_i/okt_top_0_leds[1]} {design_1_i/okt_top_0_leds[2]} {design_1_i/okt_top_0_leds[3]} {design_1_i/okt_top_0_leds[4]} {design_1_i/okt_top_0_leds[5]} {design_1_i/okt_top_0_leds[6]} {design_1_i/okt_top_0_leds[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {design_1_i/okt_top_0_out_data[0]} {design_1_i/okt_top_0_out_data[1]} {design_1_i/okt_top_0_out_data[2]} {design_1_i/okt_top_0_out_data[3]} {design_1_i/okt_top_0_out_data[4]} {design_1_i/okt_top_0_out_data[5]} {design_1_i/okt_top_0_out_data[6]} {design_1_i/okt_top_0_out_data[7]} {design_1_i/okt_top_0_out_data[8]} {design_1_i/okt_top_0_out_data[9]} {design_1_i/okt_top_0_out_data[10]} {design_1_i/okt_top_0_out_data[11]} {design_1_i/okt_top_0_out_data[12]} {design_1_i/okt_top_0_out_data[13]} {design_1_i/okt_top_0_out_data[14]} {design_1_i/okt_top_0_out_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {design_1_i/okt_top_0_config_addr[0]} {design_1_i/okt_top_0_config_addr[1]} {design_1_i/okt_top_0_config_addr[2]} {design_1_i/okt_top_0_config_addr[3]} {design_1_i/okt_top_0_config_addr[4]} {design_1_i/okt_top_0_config_addr[5]} {design_1_i/okt_top_0_config_addr[6]} {design_1_i/okt_top_0_config_addr[7]} {design_1_i/okt_top_0_config_addr[8]} {design_1_i/okt_top_0_config_addr[9]} {design_1_i/okt_top_0_config_addr[10]} {design_1_i/okt_top_0_config_addr[11]} {design_1_i/okt_top_0_config_addr[12]} {design_1_i/okt_top_0_config_addr[13]} {design_1_i/okt_top_0_config_addr[14]} {design_1_i/okt_top_0_config_addr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {design_1_i/okt_top_0/inst/status_cu[0]} {design_1_i/okt_top_0/inst/status_cu[1]} {design_1_i/okt_top_0/inst/status_cu[2]} {design_1_i/okt_top_0/inst/status_cu[3]} {design_1_i/okt_top_0/inst/status_cu[4]} {design_1_i/okt_top_0/inst/status_cu[5]} {design_1_i/okt_top_0/inst/status_cu[6]} {design_1_i/okt_top_0/inst/status_cu[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list design_1_i/config_1_Dout]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list design_1_i/i2s_bclk_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list design_1_i/i2s_d_in_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list design_1_i/i2s_lr_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list design_1_i/Net]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list design_1_i/okt_sno_top_0_AER_REQ]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list design_1_i/okt_top_0_out_req_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list design_1_i/okt_top_0_port_c_ack_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list design_1_i/okt_top_0_rome_a_ack_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list design_1_i/okt_top_0_rome_b_ack_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list design_1_i/OpenNas_Cascade_STER_0_aer_req]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list design_1_i/OpenNas_Cascade_STER_0_pdm_clk_left]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list design_1_i/OpenNas_Cascade_STER_0_pdm_clk_right]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list design_1_i/OpenNas_Parallel_STE_0_aer_req]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list design_1_i/out_ack_n_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list design_1_i/pdm_dat_left_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list design_1_i/pdm_dat_right_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list design_1_i/source_sel_0_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list design_1_i/xlslice_0_Dout]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out1]
