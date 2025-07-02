# Neuromorphic Auditory Sensor Configurable (NAS Config)

## Description
*To be completed.*

## Sensor Architecture
The Neuromorphic Auditory Sensor (NAS) is organized hierarchically, resembling a file and folder structure. Below is the representation of the sensor's architecture:
```
OpenNas_TOP_Cascade_STEREO_64ch
    ├── PDM2Spikes
    │   └── PDM_Interface
    ├── i2s_to_spikes_stereo
    │   ├── Spikes_Generator_signed_BW 
    │   └── I2S_inteface
    ├── SpikesSource_Selector
    ├── CFBank_64
    │   └── Spikes_2BPF_fullGain
    │       ├── Spikes_2LPF_fullGain
    │       │    └── Spikes_LPF_fullGain
    │       │        ├── Spikes_div_BW
    │       │        ├── Spike_Int_n_Gen_BW
    │       │        └── AER_Dif
    │       ├── Spikes_div_BW
    │       └── AER_Dif
    └── AER_Distributed_Monitor
        ├── AER_Distributed_Monitor_Module
        │   └── ramfifo
        │       └── DualPortRAM
        └── AER_Out
            ├── Handshake_Out 
            └── ramfifo
                └── DualPortRAM
```

### Notes
- The top-level module is `OpenNas_TOP_Cascade_STEREO_64ch`, which integrates all submodules.
- Each submodule is responsible for specific tasks, such as signal processing, spike generation, or data communication.

## Sensor Configuration
The NAS sensor includes several configurable modules. Below is a list of these modules, their register addresses, and default values:

### Configurable Modules
1. **PDM2Spikes**
    - **Registers (Left PDM):**
        - `0x0000`: Spike threshold (default: `0x0005`)
        - `0x0001`: Spike threshold (default: `0x0006`)
        - `0x0002`: Spike threshold (default: `0x734B`)
        - `0x0003`: Spike threshold (default: `0x39C8`)

    - **Registers (Right PDM):**
        - `0x0004`: Spike threshold (default: `0x0005`)
        - `0x0005`: Spike threshold (default: `0x0006`)
        - `0x0006`: Spike threshold (default: `0x734B`)
        - `0x0007`: Spike threshold (default: `0x39C8`)

2. **i2s_to_spikes_stereo**
    - **Registers:**
        - `0x0008`: Spike threshold (default: `0x0005`)

3. **CFBank_2or_64CH**
   - **Registers (Left Bank):**
     - Address range: `0x0009` to `0x010C` (260 registers in total).
     - Default values: Defined in the `FILTER_DEFAULT_parameter` constant in `OpenNas_top_pkg.vhd`.
     - Example default values:
       - `0x0009`: `0x0004`
       - `0x000A`: `0x77B4`
       - `0x000B`: `0x77B4`
       - `0x000C`: `0x2025`
       - (Refer to the full constant definition for all default values.)
    
    - **Registers (Right Bank):**
        - Address range: `0x010D` to `0x0210` (260 registers in total).
        - Default values: Defined in the `FILTER_DEFAULT_parameter` constant in `OpenNas_top_pkg.vhd`.
        - Example default values:
        - `0x010D`: `0x0004`
        - `0x010E`: `0x77B4`
        - `0x010F`: `0x77B4`
        - `0x0110`: `0x2025`
        - (Refer to the full constant definition for all default values.)

