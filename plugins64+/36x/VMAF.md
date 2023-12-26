## Description

VMAF is a perceptual video quality assessment algorithm developed by Netflix. Refer to the [FAQ](https://github.com/Netflix/vmaf/blob/master/FAQ.md) page for frequently asked questions of VMAF.

This is [a port of the VapourSynth plugin VMAF](https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VMAF).

[vmaf](https://github.com/Netflix/vmaf) is used.

### Requirements:

- AviSynth 2.60 / AviSynth+ 3.4 or later for VMAF
- AviSynth+ 3.6 or later for VMAF2

### Usage:

```
VMAF (clip reference, clip distorted, string log_path, int "log_format", int[] "model", int[] "feature", string "cambi_opt")
```

### Parameters:

- reference, distorted\
    Clips to calculate VMAF score.\
    Must be in YUV 8..10-bit planar format with minimum three planes.

- log_path\
    Sets the path of the log file.

- log_format\
    Sets the format of the log file.\
    0: xml\
    1: json\
    2: csv\
    Default: 0.

- model\
    Sets which model to use.\
    Refer to [this](https://github.com/Netflix/vmaf/blob/master/resource/doc/models.md), [this](https://netflixtechblog.com/toward-a-better-quality-metric-for-the-video-community-7ed94e752a30) and [this](https://github.com/Netflix/vmaf/blob/master/resource/doc/conf_interval.md) for more details.\
    0: vmaf_v0.6.1\
    1: vmaf_v0.6.1neg (NEG mode)\
    2: vmaf_b_v0.6.3 (Confidence Interval)\
    3: vmaf_4k_v0.6.1

- feature\
    0: PSNR\
    1: PSNR-HVS\
    2: SSIM\
    3: MS-SSIM\
    4: CIEDE2000\
    5: CAMBI

- cambi_opt\
    Additional options for feature CAMBI:
    - enc_width, enc_height\
        Encoding/processing resolution to compute the banding score, useful in cases where scaling was applied to the input prior to the computation of metrics.\
        enc_width must be between 320 and 7680.\
        enc_height must be between 200 and 4320.\
        Default: Same as input image.
    - window_size\
        Window size to compute CAMBI.\
        Must be between 15 and 127.\
        Default: 63 (corresponds to ~1 degree at 4K resolution and 1.5H).
    - topk\
        Ratio of pixels for the spatial pooling computation.\
        Must be between 0.0001 and 1.0.\
        Default: 0.6.
    - tvi_threshold\
        Visibilty threshold for luminance ΔL < tvi_threshold*L_mean for BT.1886.\
        Must be between 0.0001 and 1.0.\
        Default: 0.019.
    - max_log_contrast\
        Maximum contrast in log luma level (2^max_log_contrast) at 10-bits, e.g., 2 is equivalent to 4 luma levels at 10-bit and 1 luma level at 8-bit.\
        Must be between 0 and 5.\
        Default: 2.
    - enc_bitdepth\
        Encoding bitdepth.\
        Must be between 6 and 16.\
        Default: Clips bitdepth.
    - eotf\
        Determines the EOTF used to compute the visibility thresholds.\
        Must be either `bt1886` or `pq`.\
        Default: `bt1886`.

        Format: `option_name=value`.\
        If more than one option is specified, the options must be separated by space.\
        Usage example: `cambi_opt="windows_size=120 enc_width=1280 enc_height=720"`.

---

```
VMAF2 (clip reference, clip "distorted", int[] "feature", string "cambi_opt")
```

- reference, "distorted"\
    Clips to calculate the score.\
    Must be in YUV 8..10-bit planar format with minimum three planes.\
    `distorted` must be specified when feature != 5.

- feature\
    0: PSNR\
    1: PSNR-HVS\
    2: SSIM\
    3: MS-SSIM\
    4: CIEDE2000\
    5: CAMBI

- cambi_opt\
    Additional options for feature CAMBI:
    - enc_width, enc_height\
        Encoding/processing resolution to compute the banding score, useful in cases where scaling was applied to the input prior to the computation of metrics.\
        enc_width must be between 320 and 7680.\
        enc_height must be between 200 and 4320.\
        Default: Same as input image.
    - window_size\
        Window size to compute CAMBI.\
        Must be between 15 and 127.\
        Default: 63 (corresponds to ~1 degree at 4K resolution and 1.5H).
    - topk\
        Ratio of pixels for the spatial pooling computation.\
        Must be between 0.0001 and 1.0.\
        Default: 0.6.
    - tvi_threshold\
        Visibilty threshold for luminance ΔL < tvi_threshold*L_mean for BT.1886.\
        Must be between 0.0001 and 1.0.\
        Default: 0.019.
    - max_log_contrast\
        Maximum contrast in log luma level (2^max_log_contrast) at 10-bits, e.g., 2 is equivalent to 4 luma levels at 10-bit and 1 luma level at 8-bit.\
        Must be between 0 and 5.\
        Default: 2.
    - enc_bitdepth\
        Encoding bitdepth.\
        Must be between 6 and 16.\
        Default: Clips bitdepth.
    - eotf\
        Determines the EOTF used to compute the visibility thresholds.\
        Must be either `bt1886` or `pq`.\
        Default: `bt1886`.

        Format: `option_name=value`.\
        If more than one option is specified, the options must be separated by space.\
        Usage example: `cambi_opt="windows_size=120 enc_width=1280 enc_height=720"`.

Frame property with the name of the used feature is set.

### Building:

```
Requirements:
    - Git
    - GCC C++17 compiler
    - CMake >= 3.16
    - AviSynth library
    - meson
```
```
git clone --recurse-submodules https://github.com/Asd-g/AviSynth-VMAF && \
cd AviSynth-VMAF/vmaf && \
mkdir vmaf_install && \
meson setup libvmaf libvmaf/build --buildtype release --default-library static --prefix $(pwd)/vmaf_install && \
meson install -C libvmaf/build && \
cd .. && \
cmake -B build .
cmake --build build
```
