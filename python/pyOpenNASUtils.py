import numpy as np

class SLPFParameters:
    
    """
    def __init__(self, n_bits, freq_div, out_div, fb_div, real_freq_cut, real_gain):
        self._n_bits = n_bits
        self._freq_div = freq_div
        self._out_div = out_div
        self._fb_div = fb_div
        self._real_freq_cut = real_freq_cut
        self._real_gain = real_gain
    """

    def __init__(self, clk, cut_off_freq, gain_db, min_freq_dev):

        param_sig = pyOpenNASUtils.rev_kSIG(clk, cut_off_freq, min_freq_dev)

        self._n_bits = int(param_sig[0])
        self._freq_div = int(param_sig[1])
        temp_w_cut = pyOpenNASUtils.kSIG(clk, self._n_bits, self._freq_div)
        k_div = (2.0 * np.pi * cut_off_freq) / temp_w_cut

        self._fb_div = int(pyOpenNASUtils.rev_kDiv(k_div))
        self._real_freq_cut = float(pyOpenNASUtils.kDiv(self._fb_div)) * temp_w_cut / (2 * np.pi)

        gain = 10 ** (gain_db / 10.0)
        self._out_div = pyOpenNASUtils.rev_kDiv(k_div*gain)        
        self._real_gain = float(pyOpenNASUtils.kDiv(self._out_div)) / pyOpenNASUtils.kDiv(self._fb_div)


    def real_gain_db(self):
        return 10.0 * np.log10(self.real_gain)

    
    # Getters

    @property
    def n_bits(self):
        return self._n_bits
    @property
    def freq_div(self):
        return self._freq_div
    @property
    def out_div(self):
        return self._out_div
    @property
    def fb_div(self):
        return self._fb_div
    @property
    def real_freq_cut(self):
        return self._real_freq_cut
    @property
    def real_gain(self):
        return self._real_gain
    
    # Setters

    @n_bits.setter
    def n_bits(self, value):
        self._n_bits = value    
    @freq_div.setter
    def freq_div(self, value):
        self._freq_div = value
    @out_div.setter
    def out_div(self, value):
        self._out_div = value
    @fb_div.setter
    def fb_div(self, value):
        self._fb_div = value
    @real_freq_cut.setter
    def real_freq_cut(self, value):
        self._real_freq_cut = value
    @real_gain.setter
    def real_gain(self, value):
        self._real_gain = value

 

class pyOpenNASUtils:

    @staticmethod
    def power(exponents, base=10):
        return np.power(base, exponents)

    @staticmethod
    def lin_space(start, stop, num, endpoint=True):
        return np.linspace(start, stop, num, endpoint)

    @staticmethod
    def log_space(start, stop, num, endpoint=True, base=10):
        return np.logspace(start, stop, num, endpoint, base).tolist()
    
    @staticmethod
    def rev_kDiv(div):
        return (div * 2**15) - 1

    @staticmethod
    def kDiv(div):
        return float(div) / 2**15

    @staticmethod
    def kSIG(f_clk, n_bits, freq_div):
        return f_clk * 1000000.0 / ((2**(n_bits-1)) * (freq_div+1))

    @staticmethod
    def rev_kSIG(f_clk, freq, min_freq_div):
        w = freq * 2 * np.pi
        n_bits = 3
        while pyOpenNASUtils.kSIG(f_clk, n_bits + 1, min_freq_div) > w:
            n_bits += 1
        freq_div = (f_clk * 1000000 / (w * 2**(n_bits-1))) - 1
        results = np.array([n_bits, freq_div])
        return results

    @staticmethod
    def compute_normalized_error(desired, real):
        norm_error_acum = 0.0
        for i in range(len(desired)):
            freq_diff = np.abs(desired[i] - real[i])
            norm_error_acum += freq_diff / real[i]
        return norm_error_acum / len(desired)