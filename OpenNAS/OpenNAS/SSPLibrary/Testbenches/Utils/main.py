__author__ = "Daniel Gutierrez-Galan"
__copyright__ = "Copyright 2020, OpenNAS"
__credits__ = ["University of Seville"]
__license__ = "GPL"
__version__ = "1.0.0"
__maintainer__ = "Daniel Gutierrez-Galan"
__email__ = "dgutierrez@atc.us.es"
__status__ = "Development"

#---------------------------------------
# File name: main.py
# Author: Daniel Gutierrez-Galan
# Date created: 12/02/2020
# Date last modified: 12/02/2020
# Python Version: 2.7
#---------------------------------------

#
# Imports
#
import OpenNAS_simulation_utils
import matplotlib.pyplot as plt
import numpy as np
import math

#
# Code
#

relative_path = "..\\Files\\"
base_file_name = "pdm_data_sequence"
signal_type = "sin"
"""
# List of input signal frequencies (in Hz)
signal_frequencies = [100, 166, 278, 464, 774, 1291, 2154, 3593, 5994, 10000]
# List of ISI thresholds for each signal frequency at the input
input_spikes_thresholds = [2.5e2, 2e2, 1.1e2, 1e2, 6e1, 5e1, 4e1, 2e1, 1.5e1, 1e1]
# List of ISI thresholds for each signal frequency at the output
output_spikes_thresholds = [5e3, 3e3, 1.8e3, 1e3, 6e2, 3.9e2, 2e2, 1.4e2, 8e1, 5e1]
"""

# List of input signal frequencies (in Hz)
signal_frequencies = [19,28,41,59,85,123,178,256,369,531,765,1103,1588,2288,3295,4745,6834,9843,14176,20417]
# List of ISI thresholds for each signal frequency at the input
input_spikes_thresholds = [7.0e2, 5.0e2, 4.5e2, 4.0e2, 3.0e2, 2.0e2, 1.5e2, 1.2e2, 1.0e2, 8.0e1, 5.5e1, 4.5e1, 3.5e1, 2.5e1, 3.0e1, 2.0e1, 1.5e1, 1.2e1, 1.0e1, 6]
# List of ISI thresholds for each signal frequency at the output
output_spikes_thresholds = [2.0e4, 1.5e4, 1.0e4, 8.0e3, 5.0e3, 4.0e3, 2.5e3, 1.9e3, 1.2e3, 9.0e2, 6.0e2, 4.0e2, 3.0e2, 2.0e2, 1.5e2, 1.0e2, 7.0e1, 5.0e1, 3.0e1, 2.0e1]

signal_amplitude = 1
signal_numsamples = [1644730, 1116070, 762190, 529660, 367640, 254060, 175560, 122070, 84680, 58850, 40840, 28330, 19670, 13650, 9480, 6580, 4570, 3170, 2200, 1530]

file_extension = ".txt"

# Array to save all the file names
filenames = []

num_frequencies = len(signal_frequencies)

# For each file
for file_index in range(num_frequencies):
	# Create the names of each file to be openned (input and output spikes files)
	# Base name
	full_name = relative_path + base_file_name + "_" + signal_type + "_" + str(signal_frequencies[file_index]) + "Hz" + "_" + "amplitude" + str(signal_amplitude) + "_" + str(signal_numsamples[file_index]) + "samples"
	# Input spikes file
	full_name_input_spikes = full_name + "_" + "input_spikes" + file_extension
	# Output spikes file
	full_name_output_spikes = full_name + "_" + "output_spikes" + file_extension
	
	# Add both files to the list
	filenames.append(full_name_input_spikes)
	filenames.append(full_name_output_spikes)

# Then, call to the pre-process function to remove the "ps" word for the timestamps and change the file extension
OpenNAS_simulation_utils.pre_process_testbench_files_to_csv(filenames)

mean_latencies_values = []
std_latencies_values = []

mean_gain_values = []
std_gain_values = []

# For each frequency
for file_index in range(num_frequencies):
	
	#------------------------------------------------------------------
	# Reading and preprocessing data
	#------------------------------------------------------------------

	# First, read the input spikes and the input spikes timestamps (timestamps are in picoseconds)
	file_input_spikes, file_input_timestamps = OpenNAS_simulation_utils.load_pre_processed_testbench_file(filenames[file_index*2].replace('.txt', '.csv'))
	# Convert from string to float and from picoseconds to microseconds (*1e-6)
	file_input_timestamps_us = OpenNAS_simulation_utils.convertTimeResolution(file_input_timestamps, 1.0e-6)
	# Convert timestamp resolution from ps to 0.2us multiple
	OpenNAS_simulation_utils.transformTimestampsToMultipleOfValue(file_input_spikes, file_input_timestamps, 200000, filenames[file_index*2].replace('.txt', '_02us.csv'))

	# Second, read the output spikes and the output spikes timestamps (timestamps are also in picoseconds)
	file_output_spikes, file_output_timestamps = OpenNAS_simulation_utils.load_pre_processed_testbench_file(filenames[(file_index*2) + 1].replace('.txt', '.csv'))
	# Convert from string to float and from picoseconds to microseconds (*1e-6)
	file_output_timestamps_us = OpenNAS_simulation_utils.convertTimeResolution(file_output_timestamps, 1.0e-6)
	# Convert timestamp resolution from ps to 0.2us multiple
	OpenNAS_simulation_utils.transformTimestampsToMultipleOfValue(file_output_spikes, file_output_timestamps, 200000, filenames[(file_index*2) + 1].replace('.txt', '_02us.csv'))
	
	#------------------------------------------------------------------
	# Calculating and plotting the InterSpike Interval (ISI). NOTE: the formula has been modified!!
	#------------------------------------------------------------------
	input_spikes_isi_values, input_spikes_isi_values_ts = OpenNAS_simulation_utils.calculateInterSpikeInterval(file_input_spikes, file_input_timestamps_us)
	output_spikes_isi_values, output_spikes_isi_values_ts = OpenNAS_simulation_utils.calculateInterSpikeInterval(file_output_spikes, file_output_timestamps_us)

	#OpenNAS_simulation_utils.plotInterSpikeIntervalInputAndOutput(signal_frequencies[file_index], input_spikes_isi_values_ts, input_spikes_isi_values, output_spikes_isi_values_ts, output_spikes_isi_values)
	
	#------------------------------------------------------------------
	# Save the maximum ISI values
	#------------------------------------------------------------------
	input_spikes_max_isi_values_indexs = OpenNAS_simulation_utils.getIndexesMaximumISIValuesFromThreshold(input_spikes_isi_values, input_spikes_thresholds[file_index])

	output_spikes_max_isi_values_indexs = OpenNAS_simulation_utils.getIndexesMaximumISIValuesFromThreshold(output_spikes_isi_values, output_spikes_thresholds[file_index])

	#------------------------------------------------------------------
	# Estimate the middle point between two consecutives ISI values for the output ISI values
	#------------------------------------------------------------------
	num_output_max_isi_values_indexs = len(output_spikes_max_isi_values_indexs)
	output_signal_measurement_point_timestamps = []
	
	print("Estimating the middle point between two consecutives ISI values timestamps for output signal")
	for i in range(num_output_max_isi_values_indexs - 1):
		print("----------------------------")
		index0 = output_spikes_max_isi_values_indexs[i]
		index1 = output_spikes_max_isi_values_indexs[i + 1]
		print("Index i: " + str(index0))
		print("Index i+1: " + str(index1))		

		index0_ts = output_spikes_isi_values_ts[index0]
		index1_ts = output_spikes_isi_values_ts[index1]
		print("Ts of Index i: " + str(index0_ts))
		print("Ts of Index i+1: " + str(index1_ts))

		middle_point = (index1_ts + index0_ts) / 2.0
		print("Middle point: " + str(middle_point))
		print("----------------------------")

		output_signal_measurement_point_timestamps.append(middle_point)
	
	num_input_max_isi_values_indexs = len(input_spikes_max_isi_values_indexs)
	input_signal_measurement_point_timestamps = []

	print("Taking the ISI max values timestamps for input signal")
	for i in range(num_input_max_isi_values_indexs - 1):
		print("----------------------------")
		index = input_spikes_max_isi_values_indexs[i]
		print("Index i: " + str(index))

		index_ts = input_spikes_isi_values_ts[index]
		print("Ts of Index i: " + str(index_ts))

		input_signal_measurement_point_timestamps.append(index_ts)
		print("----------------------------")

	num_input_signal_measurement_point_timestamps = len(input_signal_measurement_point_timestamps)
	num_output_signal_measurement_point_timestamps = len(output_signal_measurement_point_timestamps)

	min_signal_measurement_point_timestamps = min(num_input_signal_measurement_point_timestamps, num_output_signal_measurement_point_timestamps)
	
	latency_values = []

	print("Calculating time differences between input and output signal based on their max ISI values")
	for i in range(min_signal_measurement_point_timestamps):
		print("----------------------------")
		print("Iteration " + str(i))

		input_measure_point_ts = input_signal_measurement_point_timestamps[i]
		output_measure_point_ts = output_signal_measurement_point_timestamps[i]

		print("Measure point for input signal: " + str(input_measure_point_ts))
		print("Measure point for output signal: " + str(output_measure_point_ts))

		latency = output_measure_point_ts - input_measure_point_ts
		print("Latency value: " + str(latency))
		latency_values.append(latency)
		print("----------------------------")

	mean_latency = np.mean(latency_values) #mean_latency / float(min_num_isi_values)
	std_latency = np.std(latency_values)
	print("Mean latency " + str(mean_latency) + " us")
	print("STD of the mean latency " + str(std_latency) + " us")

	mean_latencies_values.append(mean_latency)
	std_latencies_values.append(std_latency)
	
	"""
	#mean_gain, std_gain = OpenNAS_simulation_utils.estimateMeanGainFromSpikesNumber(input_spikes_isi_values, input_spikes_isi_values_ts, input_spikes_max_isi_values_indexs, \
																output_spikes_isi_values, output_spikes_isi_values_ts, output_spikes_max_isi_values_indexs, \
																file_input_spikes, file_input_timestamps, file_output_spikes, file_output_timestamps)

	mean_gain_values.append(mean_gain)
	std_gain_values.append(std_gain)
	"""
	
	print(" ")
	print(" ")
	print("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+")
	print("Counting spikes...")
	print("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+")

	num_input_spikes_in_ranges = []
	num_output_spikes_in_ranges = []

	print("------Input-----")
	for i in range(num_input_signal_measurement_point_timestamps-1):
		print("----------------------------")
		print("Iteration " + str(i))
		ts_0 = input_signal_measurement_point_timestamps[i]
		ts_1 = input_signal_measurement_point_timestamps[i + 1]
		print("Range: " + str(ts_0) + " to " + str(ts_1))

		num_spikes_in_range = OpenNAS_simulation_utils.countSpikesBetweenTimeRange(ts_0, ts_1, file_input_spikes, file_input_timestamps_us)
		print("Number of spikes: " + str(num_spikes_in_range))
		num_input_spikes_in_ranges.append(num_spikes_in_range)
		print("----------------------------")

	print("------Output-----")
	for i in range(num_output_signal_measurement_point_timestamps-1):
		print("----------------------------")
		print("Iteration " + str(i))
		ts_0 = output_signal_measurement_point_timestamps[i]
		ts_1 = output_signal_measurement_point_timestamps[i + 1]
		print("Range: " + str(ts_0) + " to " + str(ts_1))

		num_spikes_in_range = OpenNAS_simulation_utils.countSpikesBetweenTimeRange(ts_0, ts_1, file_output_spikes, file_output_timestamps_us)
		print("Number of spikes: " + str(num_spikes_in_range))
		num_output_spikes_in_ranges.append(num_spikes_in_range)
		print("----------------------------")

	print("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+")
	print("End counting spikes...")
	print("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+")

	mean_num_input_spikes_in_ranges = np.mean(num_input_spikes_in_ranges)
	std_num_input_spikes_in_ranges = np.std(num_input_spikes_in_ranges)

	mean_num_output_spikes_in_ranges = np.mean(num_output_spikes_in_ranges)
	std_num_output_spikes_in_ranges = np.std(num_output_spikes_in_ranges)

	print("Mean of the number of input spikes for all ranges: " + str(mean_num_input_spikes_in_ranges) + "with std of: " + str(std_num_input_spikes_in_ranges))

	print("Mean of the number of output spikes for all ranges: " + str(mean_num_output_spikes_in_ranges) + "with std of: " + str(std_num_output_spikes_in_ranges))



	temp = mean_num_output_spikes_in_ranges / mean_num_input_spikes_in_ranges

	gain = math.log10(temp) 
	gain = gain * 20.0

	print("Gain: " + str(gain))

	print(" ")
	print(" ")
	print(" ")
	print(" ")
	mean_gain_values.append(gain)
	

labels = []

for i in range(len(signal_frequencies)):
  labels.append(str(signal_frequencies[i]))

x_pos = np.arange(len(labels))

fig, ax = plt.subplots()
ax.bar(x_pos, mean_latencies_values, yerr=std_latencies_values, align='center', alpha=0.5, ecolor='black', capsize=10)
ax.set_ylabel(r'Time ($\mu$s)')
ax.set_xlabel('Frequency (Hz)')
ax.set_xticks(x_pos)
ax.set_xticklabels(labels)
ax.set_title('Latency of the PDM2Spikes module over frequencies')
ax.yaxis.grid(True)
#plt.yscale("log")
###########
ax.plot(x_pos, mean_latencies_values, 'ro-')
##########
# Save the figure and show
plt.tight_layout()
plt.savefig('bar_plot_with_error_bars.png')
plt.show()

"""
plt.plot(signal_frequencies, mean_latencies_values, 'o-')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Time (us)')
plt.title('Latency variation over signal frequency')
plt.show()
"""

"""
phase_values = OpenNAS_simulation_utils.convertFromTimeToPhase(mean_latencies_values, signal_frequencies)
plt.plot(signal_frequencies, phase_values)
plt.xscale("log")
plt.savefig('phase.png')
plt.show()

plt.plot(signal_frequencies, mean_gain_values)
plt.xscale("log")
plt.savefig('gain.png')
plt.show()
"""

phase_values = OpenNAS_simulation_utils.convertFromTimeToPhase(mean_latencies_values, signal_frequencies)
phase_values_neg = [-x for x in phase_values]

fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)
fig.suptitle('PDM2Spikes Bode diagram')

ax1.plot(signal_frequencies, mean_gain_values, 'o-')
ax1.set_xscale("log")
ax1.set_ylim(-31, -15)
ax1.set_ylabel('Gain (dB)')
ax1.grid(True)

ax2.plot(signal_frequencies, phase_values_neg, 'o-')
ax2.set_xscale("log")
ax2.set_ylim(-8, -3)
ax2.set_ylabel('Phase (rad)')

plt.setp(ax1.get_xticklabels(), visible=False)
plt.xlabel('Frequency (Hz)')

plt.grid(True)

plt.savefig('PDM2Spikes_module_bode_diagram.png')
plt.show()

print("End of the script")
