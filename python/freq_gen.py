
# from asyncio.windows_events import NULL
from enum import Enum
from click import File
import numpy as np
import os
dirname = os.path.dirname(__file__)


from pyOpenNASUtils import pyOpenNASUtils
from pyOpenNASUtils import SLPFParameters
# from HDLGenerable import HDLGenerable

from pyOpenNASCommons import NASTYPE


class SLPFType(Enum):
    Order2 = 0
    Order4 = 1

class CascadeSLPFBank:

    def __init__(self):
        self._num_ch = 32
        self._clk = 0
        self._nas_type = NASTYPE.MONO
        self._slpf_type = SLPFType.Order2
        self._mid_freq = pyOpenNASUtils.log_space(start=20, stop=22000, num=32)
        self._attenuation = [12 for i in range(32)]
        self._cutoff_freq = []
        self._normalized_error = 0
        self._real_mid_freq = []

    def __init__(self, num_ch, clk, nas_type, slpf_type, start_freq, stop_freq, att):
        self._num_ch = num_ch
        self._clk = clk
        self._nas_type = nas_type
        self._slpf_type = slpf_type

        start = np.log10(start_freq)
        stop = np.log10(stop_freq)
        self._mid_freq = pyOpenNASUtils.log_space(start=start, stop=stop, num=num_ch)

        self._cutoff_freq = self.compute_cutoff_freq(self._mid_freq)

        self._attenuation = [att for i in range(num_ch)]
        self._mid_freq.reverse()
        self._cutoff_freq.reverse()

        self._normalized_error = 0
        self._real_mid_freq = []


    def compute_cutoff_freq(self, center_freq):
        cutoff_freq = []
        relation = center_freq[1] / center_freq[0]
        first_freq = np.sqrt(center_freq[0] * center_freq[1])

        cutoff_freq.append(first_freq / relation)
        cutoff_freq.append(first_freq)

        for i in range(2, len(center_freq) + 1, 1):
            cutoff_freq.append(cutoff_freq[i - 1] * relation)

        return cutoff_freq


    def compute_filters_parameters(self):   ## TODO: May contain errors
        slpf_param = []
        att_div = []
        
        real_cutoff_freq = []

        for i in range(len(self._cutoff_freq)):
            slpf = SLPFParameters(self._clk, self._cutoff_freq[i], 0, 2)
            slpf_param.append(slpf)
            real_cutoff_freq.append(slpf.real_freq_cut)

        for i in range(len(self._attenuation)):
            temp_att = np.power(10, self._attenuation[i]/20)
            att_div.append(int(pyOpenNASUtils.rev_kDiv(temp_att)))
        
        self._real_mid_freq = []
        for i in range(len(real_cutoff_freq) - 1):
            mid_freq = np.sqrt(real_cutoff_freq[i] * real_cutoff_freq[i + 1])
            self._real_mid_freq.append(mid_freq)

        self._normalized_error = pyOpenNASUtils.compute_normalized_error(self._mid_freq, self._real_mid_freq)

        return slpf_param, att_div


    def get_normalized_error(self):
        if self._mid_freq == NULL or self._real_mid_freq == NULL:
            return 0
        else:
            return self._normalized_error


    def generate_CFB(self, path):

        slpf_param, att_div = self.compute_filters_parameters()
        
        lines = []

        # lines.append(HDLGenerable.copy_license('H'))

        entity = "CFBank_"
        if self._slpf_type == SLPFType.Order2:
            entity += "2"
        else:
            entity += "4"
        
        entity += "or_" + str(self._num_ch) + "CH"

        lines.append("architecture CFBank_arq of " + entity + " is\n")

        realFreq =  slpf_param[0].real_freq_cut

        freqError = 100 * ((self._cutoff_freq[0] - realFreq) / self._cutoff_freq[0])
        filterInfo = "--Ideal cutoff: " + "{:.4f}".format(self._cutoff_freq[0]) + "Hz - Real cutoff: " + "{:.4f}".format(realFreq) + "Hz - Error: " + "{:.4f}".format(freqError) + "%"
        lines.append("        " + filterInfo + "\n")
        # lines.append("        U_BPF_0: " + filterName + "\n")
        # lines.append("            GL              => " + str(int(slpf_param[0].n_bits)) + ",\n")
        # lines.append("            SAT             => " + str((int)(np.power(2, slpf_param[0].n_bits - 1) - 1)) + "\n")
        lines.append("            FREQ_DIV        => x\"" + "{:02X}".format(int(slpf_param[0].freq_div)) + "\",\n")   #X2
        lines.append("            SPIKES_DIV_FB   => x\"" + "{:04X}".format(int(slpf_param[0].fb_div)) + "\",\n")     #X4
        lines.append("            SPIKES_DIV_OUT  => x\"" + "{:04X}".format(int(slpf_param[0].out_div)) + "\",\n")    #X4
        lines.append("            SPIKES_DIV_BPF  => x\"" + "{:04X}".format(int(att_div[0])) + "\",\n")               #X4



        for k in range(1, self._num_ch + 1):
            realFreq = slpf_param[k].real_freq_cut
            freqError = 100 * ((self._cutoff_freq[k] - realFreq) / self._cutoff_freq[k])
            lines.append("Filter_" + str(k) + "\n")
            filterInfo = "--Ideal cutoff: " + "{:.4f}".format(self._cutoff_freq[k]) + "Hz - Real cutoff: " + "{:.4f}".format(realFreq) + "Hz - Error: " + "{:.4f}".format(freqError) + "%"
            lines.append("        " + filterInfo + "\n")
            # lines.append("        U_BPF_" + str(k) + ": " + filterName + "\n")
            # lines.append("            GL              => " + str(int(slpf_param[k].n_bits)) + ",\n")
            # lines.append("            SAT             => " + str((int)(np.power(2, slpf_param[k].n_bits - 1) - 1)) + "\n")
            lines.append("            FREQ_DIV        => x\"" + "{:02X}".format(int(slpf_param[k].freq_div)) + "\",\n") #X2
            lines.append("            SPIKES_DIV_FB   => x\"" + "{:04X}".format(int(slpf_param[k].fb_div)) + "\",\n")   #X4
            lines.append("            SPIKES_DIV_OUT  => x\"" + "{:04X}".format(int(slpf_param[k].out_div)) + "\",\n")  #X4
            lines.append("            SPIKES_DIV_BPF  => x\"" + "{:04X}".format(int(att_div[k - 1])) + "\",\n")         #X4
            # lines.append("            spike_in_slpf_p => lpf_spikes_" + str(k - 1) + "(1),\n")
            # lines.append("            spike_in_slpf_n => lpf_spikes_" + str(k - 1) + "(0),\n")
            # #Cascade Arch
            # lines.append("            spike_in_shf_p  => lpf_spikes_" + str(k - 1) + "(1),\n")
            # lines.append("            spike_in_shf_n  => lpf_spikes_" + str(k - 1) + "(0),\n")
            # #Parallel Arch
            # lines.append("            spike_out_p     => spikes_out(" + str(2 * (k - 1) + 1) + "),\n")
            # lines.append("            spike_out_n     => spikes_out(" + str(2 * (k - 1)) + "), \n")
            # lines.append("            spike_out_lpf_p => lpf_spikes_" + str(k) + "(1),\n")
            # lines.append("            spike_out_lpf_n => lpf_spikes_" + str(k) + "(0)\n")
        
        with open(path + os.sep + 'CFBank_' + str(self._num_ch) + '.vhd', 'w') as f:
            f.writelines(lines)
        

    
    def generate_CFB_debug_params(self, path):
        slpf_param, att_div = self.compute_filters_parameters()
        
        lines = []

        realFreq =  slpf_param[0].real_freq_cut

        freqError = 100 * ((self._cutoff_freq[0] - realFreq) / self._cutoff_freq[0])

        lines.append("`ifdef FILTRO_0\n")
        lines.append("`define FREQ_DIV:" + str(int(slpf_param[0].freq_div)) + "\n")   #X2
        lines.append("`define SPIKES_DIV_FB:" + str(int(slpf_param[0].fb_div)) + "\n")     #X4
        lines.append("`define SPIKES_DIV_OUT:" + str(int(slpf_param[0].out_div)) + "\n")     #X4
        lines.append("`define SPIKES_DIV_BPF:" + str(int(att_div[0])) + "\n")     #X4
        lines.append("`endif\n")


        for k in range(1, self._num_ch + 1):
            realFreq = slpf_param[k].real_freq_cut
            freqError = 100 * ((self._cutoff_freq[k] - realFreq) / self._cutoff_freq[k])

            lines.append("`ifdef FILTRO_" + str(k) + "\n")
            lines.append("`define FREQ_DIV:" + str(int(slpf_param[k].freq_div)) + "\n")   #X2
            lines.append("`define SPIKES_DIV_FB:" + str(int(slpf_param[k].fb_div)) + "\n")   #X4
            lines.append("`define SPIKES_DIV_OUT:" + str(int(slpf_param[k].out_div)) + "\n")  #X4
            lines.append("`define SPIKES_DIV_BPF:" + str(int(att_div[k - 1])) + "\n")         #X4
            lines.append("`endif\n")

        
        with open(path + os.sep + 'CFBank_' + str(self._num_ch) + '.txt', 'w') as f:
            f.writelines(lines)


    def get_short_description(self):
        return 'Cascade'






coch = CascadeSLPFBank(64, 48, NASTYPE.STEREO, SLPFType.Order2, 10000, 20000, -12)

# coch.generate_CFB('D:\Repositorios\\\GitHub\\pyOpenNAS')

# coch.generate_CFB_debug_params('/Users/jpdominguez/GitHub/pyNAS_freq_generator/src')

coch.generate_CFB('.')