from enum import Enum

import xml.etree.ElementTree as ET

class NASTYPE(Enum):
    MONO = 0
    STEREO = 1

class NASCHIP(Enum):
    AERNODE = 0
    ZTEX = 1
    SOC_DOCK = 2
    OTHER = 3

class pyOpenNASCommons:

    #create getters and setters for the following variables: mono_stereo, num_ch, clock_value and nas_chip
    def __init__(self, mono_stereo, num_ch, clock_value, nas_chip):
        self._mono_stereo = mono_stereo
        self._num_ch = num_ch
        self._clock_value = clock_value
        self._nas_chip = nas_chip
    
    @property
    def mono_stereo(self):
        return self._mono_stereo
    
    @mono_stereo.setter
    def mono_stereo(self, mono_stereo):
        self._mono_stereo = mono_stereo
    
    @property
    def num_ch(self):
        return self._num_ch
    
    @num_ch.setter
    def num_ch(self, num_ch):
        self._num_ch = num_ch
    
    @property
    def clock_value(self):
        return self._clock_value
    
    @clock_value.setter
    def clock_value(self, clock_value):
        self._clock_value = clock_value
    
    @property
    def nas_chip(self):
        return self._nas_chip
    
    @nas_chip.setter
    def nas_chip(self, value):
        self._nas_chip = value


    def toXML(self, element_tree):
        subelement = ET.SubElement(element_tree, 'OpenNASCommons')
        subelement.set('nasChip', str(self._nas_chip.name))
        subelement.set('numChannels', str(self._num_ch))
        subelement.set('monoStereo', str(self._mono_stereo.name))
        subelement.set('clockValueMHz', str(self._clock_value))


# pyOpenNASCommons(NASTYPE.MONO, 2, 48000, NASCHIP.AERNODE).toXML('pyOpenNASCommons.xml')