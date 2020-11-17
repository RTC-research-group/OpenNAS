__author__ = "Daniel Gutierrez-Galan"
__copyright__ = "Copyright 2020, OpenNAS"
__credits__ = ["University of Seville"]
__license__ = "GPL"
__version__ = "1.0.0"
__maintainer__ = "Daniel Gutierrez-Galan"
__email__ = "dgutierrez@atc.us.es"
__status__ = "Development"

#---------------------------------------
# File name: OpenNAS_simulation_utils.py
# Author: Daniel Gutierrez-Galan
# Date created: 12/02/2020
# Date last modified: 12/02/2020
# Python Version: 2.7
#---------------------------------------

#
# Imports
#
import numpy as np
import matplotlib.pyplot as plt
import math

#
# Functions
#

def pre_process_testbench_files_to_csv(file_names_list):
	num_files_to_pre_process = len(file_names_list)
	
	for file_index in range(num_files_to_pre_process):
		original_file_name = file_names_list[file_index]
		pre_processed_file_name = original_file_name.replace('.txt', '.csv')
		
		original_file_handler = open(original_file_name, "r")
		pre_processed_file_handler = open(pre_processed_file_name, "w")
		
		for file_line in original_file_handler:
			line_fields = file_line.split(";")
			
			line_fields[1] = line_fields[1].replace(' ps', '')
			
			pre_processed_file_handler.write(line_fields[0] + ";" + line_fields[1])
	
	original_file_handler.close()
	pre_processed_file_handler.close()

def load_pre_processed_testbench_file(file_name):
	file_name_handler = open(file_name, "r")

	timestamps = []
	spike_values = []

	for file_line in file_name_handler:
		line_fields = file_line.split(";")

		spike_values.append(line_fields[0])
		timestamps.append(line_fields[1])
	
	file_name_handler.close()
	
	return spike_values, timestamps
	
def convertTimeResolution(timestamp_values, time_factor):
	new_timestamps_values = [float(x) * time_factor for x in timestamp_values]
	return new_timestamps_values
	
	
def calculateInterSpikeInterval(spikes_from_file, timestamps_from_file):

	timestamps = []

	for ts_index in range(len(timestamps_from_file)):
		if int(spikes_from_file[ts_index]) != 0 and int(spikes_from_file[ts_index]) != -1:
			timestap_val = int(timestamps_from_file[ts_index])
			timestap_val = float(timestap_val)
			timestamps.append(timestap_val)
	
	ISI_values = []
	timestamps_ISI_values = []

    # First, we need to know how many timestamps have to be processed
	num_timestamps = len(timestamps)

	for ts_index in range(1, num_timestamps - 1):
		# We take the first timestamp
		timestamp_t0 = timestamps[ts_index-1]
		# And the second timestamp
		timestamp_t1 = timestamps[ts_index]

		# The inter-spike interval is computed as the subtraction
		# between the second timestamp and the first one
		isi_val = timestamp_t1 - timestamp_t0

		# We save the obtained result
		ISI_values.append(isi_val)
		timestamps_ISI_values.append(timestamp_t1)

	return ISI_values, timestamps_ISI_values

def plotInterSpikeIntervalInputAndOutput(signal_frequency_value, input_spikes_isi_values_ts, input_spikes_isi_values, output_spikes_isi_values_ts, output_spikes_isi_values):
	fig, ax = plt.subplots()
	#ax.plot(input_spikes_isi_values_ts, input_spikes_isi_values, 'b-o', file_input_timestamps_us, file_input_spikes, 'r.-')
	#ax.plot(output_spikes_isi_values_ts, output_spikes_isi_values, 'b-o', file_output_timestamps_us, file_output_spikes, 'r.-')
	ax.plot(input_spikes_isi_values_ts, input_spikes_isi_values,'r-o', output_spikes_isi_values_ts, output_spikes_isi_values, 'b-o')
	ax.set_title("Inter-Spike Interval comparison: Input vs Output")
	ax.set_ylabel(r'ISI ($\mu$s)')
	ax.set_xlabel(r'Time ($\mu$s)')
	ax.legend(['Input', 'Output'], title='Signal freq.: ' + str(signal_frequency_value) + ' Hz')
	#ax.xaxis.grid(True)
	plt.savefig('isi_values_in_out_freq_' + str(signal_frequency_value) + 'Hz.png')
	plt.show()
	
def getIndexesMaximumISIValuesFromThreshold(isi_values_list, threshold):
	# Declare the list to return
	max_isi_values_indexes = []
	# First, get the number of isi values
	num_isi_values = len(isi_values_list)
	# For each isi value, compare it with the threshold
	for isi_value_index in range(num_isi_values):
		# Get the value
		isi_value = isi_values_list[isi_value_index]
		# Compare with the threshold
		if isi_value >= threshold:
			max_isi_values_indexes.append(isi_value_index)

	return max_isi_values_indexes


def estimateMeanLatencyFromMaxISIValues(input_max_isi_values, input_max_isi_values_ts, input_max_isi_values_indexes, \
										output_max_isi_values, output_max_isi_values_ts, output_max_isi_values_indexes, \
											signal_freq):
	# First, we need to know the minimum number of elements
	num_input_isi_values = len(input_max_isi_values_indexes)
	num_output_isi_values = len(output_max_isi_values_indexes)

	min_num_isi_values = min(num_input_isi_values, num_output_isi_values)
	#print("Minimum number of max. ISI values: ")
	#print(min_num_isi_values)

	signal_period = (1.0/float(signal_freq)) * 1e6 # from seconds to microseconds
	#print("Signal period: ")
	#print(signal_period)

	quarter_signal_period = signal_period / 4.0
	#print("Quarter of a period: ")
	#print(quarter_signal_period)

	# For each isi value, calculate the difference while calculate the mean
	mean_latency = 0.0
	latency_values = []
	for isi_value_index in range(min_num_isi_values):
		print("-------------------------------------------------------------")
		print("Iteration number " + str(isi_value_index))
		input_ts_index = input_max_isi_values_indexes[isi_value_index]
		output_ts_index = output_max_isi_values_indexes[isi_value_index]

		input_isi_val_ts = input_max_isi_values_ts[input_ts_index]
		print("Timestamp input: "+ str(input_isi_val_ts))

		output_isi_val_ts = output_max_isi_values_ts[output_ts_index]
		print("Timestamp output: " + str(output_isi_val_ts))

		# Output_ts - Input_ts since the output has a delay
		latency = abs(output_isi_val_ts - input_isi_val_ts)
		print("Diff: " + str(latency))
		latency_without_phase = abs(latency - quarter_signal_period)
		print("Diff without the phase: " + str(latency_without_phase))
		#mean_latency = mean_latency + latency_without_phase
		latency_values.append(latency_without_phase)
		print("-------------------------------------------------------------")
	
	# Finally, calculate the final mean
	mean_latency = np.mean(latency_values) #mean_latency / float(min_num_isi_values)
	std_latency = np.std(latency_values)
	print("Mean latency for signal_freq " + str(signal_freq) + " Hz is: " + str(mean_latency) + " ps")
	print("STD of the mean latency for signal_freq " + str(signal_freq) + " Hz is: " + str(std_latency) + " ps")

	mean_latency_us = mean_latency
	std_latency_us = std_latency
	print("Mean latency in microseconds is: " + str(mean_latency_us))
	print("STD of mean latency in microseconds is: " + str(std_latency_us))

	return mean_latency_us, std_latency_us

def estimateMeanGainFromSpikesNumber(input_max_isi_values, input_max_isi_values_ts, input_max_isi_values_indexes, \
										output_max_isi_values, output_max_isi_values_ts, output_max_isi_values_indexes, \
										input_spikes, input_spikes_ts, output_spikes, output_spikes_ts):
	mean_gain = 0.0
	std_gain = 0.0

	input_num_spikes_between_max_isi = []

	for max_isi_val_index in range(len(input_max_isi_values_indexes)-1):
		print("----------Input-----------------")
		input_max_isi_val_index_0 = input_max_isi_values_indexes[max_isi_val_index]
		print("ts_0 index: " + str(input_max_isi_val_index_0))
		input_max_isi_val_index_1 = input_max_isi_values_indexes[max_isi_val_index+1]
		print("ts_1 index: " + str(input_max_isi_val_index_1))

		input_max_isi_val_ts_0 = input_max_isi_values_ts[input_max_isi_val_index_0]
		print("ts_0 value: " + str(input_max_isi_val_ts_0))
		input_max_isi_val_ts_1 = input_max_isi_values_ts[input_max_isi_val_index_1]
		print("ts_1 value: " + str(input_max_isi_val_ts_1))

		input_max_isi_val_ts_mean = (input_max_isi_val_ts_0 + input_max_isi_val_ts_1) / 2.0

		input_max_isi_interval_num_spikes = countSpikesBetweenTimeRange(input_max_isi_val_ts_0, input_max_isi_val_ts_mean, input_spikes, input_spikes_ts)
		
		input_num_spikes_between_max_isi.append(input_max_isi_interval_num_spikes)

		print("Num. of spikes for interval " + str(input_max_isi_val_ts_0) + " and " + str(input_max_isi_val_ts_1) + " = " + str(input_max_isi_interval_num_spikes))
		print("---------------------------")

	output_num_spikes_between_max_isi = []

	for max_isi_val_index in range(len(output_max_isi_values_indexes)-1):
		print("------------Output---------------")
		output_max_isi_val_index_0 = output_max_isi_values_indexes[max_isi_val_index]
		print("ts_0 index: " + str(output_max_isi_val_index_0))
		output_max_isi_val_index_1 = output_max_isi_values_indexes[max_isi_val_index+1]
		print("ts_1 index: " + str(output_max_isi_val_index_1))

		output_max_isi_val_ts_0 = output_max_isi_values_ts[output_max_isi_val_index_0]
		print("ts_0 value: " + str(output_max_isi_val_ts_0))
		output_max_isi_val_ts_1 = output_max_isi_values_ts[output_max_isi_val_index_1]
		print("ts_1 value: " + str(output_max_isi_val_ts_1))
		
		output_max_isi_val_ts_mean = (output_max_isi_val_ts_0 + output_max_isi_val_ts_1) / 2.0

		output_max_isi_interval_num_spikes = countSpikesBetweenTimeRange(output_max_isi_val_ts_0, output_max_isi_val_ts_mean, output_spikes, output_spikes_ts)
		
		output_num_spikes_between_max_isi.append(output_max_isi_interval_num_spikes)
		
		print("Num. of spikes for interval " + str(output_max_isi_val_ts_0) + " and " + str(output_max_isi_val_ts_mean) + " = " + str(output_max_isi_interval_num_spikes))
		print("---------------------------")

	

	return mean_gain, std_gain

def convertFromTimeToPhase(latency_values, frequency_values):

	# Convert from frequency values to period values
	period_values = [1.0/x for x in frequency_values]

	# Convert from latency values in microseconds to seconds
	latency_values_sec = [x*1.0e-6 for x in latency_values]

	# Rule of 3
	phase_values = [(latency_values_sec[i]*360.0) / period_values[i] for i in range(len(latency_values_sec)) ]

	# Convert from degrees to rad
	phase_values = [(phase_values[i] * math.pi ) / 180.0 for i in range(len(phase_values))]

	return phase_values

def countSpikesBetweenTimeRange(start_timestamp, end_fimestamp, spikes, timestamps):
	counter = 0

	for index in range(len(timestamps)):
		ts = timestamps[index]
		ts = float(ts)
		#ts = ts * 1.0e-6

		if(ts >= start_timestamp and ts <= end_fimestamp):
			spike = spikes[index]
			if(int(spike) == 1):
				counter = counter + 1

	return counter

def transformTimestampsToMultipleOfValue(spike_values, timestamp_values, multiple_value, filename):

	ts_multiple = [float(x)/multiple_value for x in timestamp_values]

	ts_multiple_floor = [int(x) for x in ts_multiple]

	ts_multiple_floor_float = [x * 1.0 for x in ts_multiple_floor]
	
	multiple_value_us = multiple_value * 1.0e-6
	
	res = [x * multiple_value_us for x in ts_multiple_floor_float]
	
	filename_handler = open(filename, "w")
	
	for i in range(len(spike_values)):
		filename_handler.write(spike_values[i] + ";" + str(res[i]) + "\n")
	
	filename_handler.close()
	
	#return res