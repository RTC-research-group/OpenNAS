import yaml
import os

with open('../../../../OpenNas_TOP_Cascade_STEREO_64ch.yaml') as file:
    with open('./nas_config_params.ncfg', 'w') as config_file:
        register_addr = 0;
        nas_params = yaml.full_load(file)
        interfaces = nas_params.get('AudioInput').get('Interfaces')
        for interface in interfaces:
            if interface.get('Interface') == 'PDM':
                for pdm_idx in range(2):
                    config_file.write(str(register_addr) + os.linesep)
                    config_file.write(str(interface.get('SHPF_FREQ_DIV')) + os.linesep)
                    register_addr += 1
                    config_file.write(str(register_addr) + os.linesep)
                    config_file.write(str(interface.get('SLPF_FREQ_DIV')) + os.linesep)
                    register_addr += 1
                    config_file.write(str(register_addr) + os.linesep)
                    config_file.write(str(interface.get('SLPF_SPIKES_DIV_FB')) + os.linesep)
                    register_addr += 1
                    config_file.write(str(register_addr) + os.linesep)
                    config_file.write(str(interface.get('SLPF_SPIKES_DIV_OUT')) + os.linesep)
                    register_addr += 1

        processing = nas_params.get('AudioProcessing')
        filters = processing[0].get('Channels')
        for filter_idx in range(2):
            for filter in filters:
                config_file.write(str(register_addr) + os.linesep)
                config_file.write(str(filter.get('FREQ_DIV')) + os.linesep)
                register_addr += 1
                config_file.write(str(register_addr) + os.linesep)
                config_file.write(str(filter.get('SPIKES_DIV_FB')) + os.linesep)
                register_addr += 1
                config_file.write(str(register_addr) + os.linesep)
                config_file.write(str(filter.get('SPIKES_DIV_OUT')) + os.linesep)
                register_addr += 1
                config_file.write(str(register_addr) + os.linesep)
                config_file.write(str(filter.get('SPIKES_DIV_BPF')) + os.linesep)
                register_addr += 1
