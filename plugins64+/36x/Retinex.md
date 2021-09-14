## Description

The Retinex theory and algorithm mainly aims at simulating the color constancy feature of HVS(Human Visual System).

The light perceived by visual receptors can be separated into illuminance and reflectance. Retinex estimates the illuminance and derive the reflectance from the light, the filtered result of which is an image represents the reflectance characteristics of the scene, regardless of the illuminance.

Retinex is a very powerful filter in dynamic range compression, local contrast enhancement, color constancy, de-fog, etc.

This is [a port of the VapourSynth plugin Retinex](https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Retinex).

### Requirements:

- AviSynth+ 3.6 or later

- Microsoft VisualC++ Redistributable Package 2022 (can be downloaded from [here](https://github.com/abbodi1406/vcredist/releases)) (Windows only)

### Usage:

```
MSRCP (clip clip, float[] "sigma", float "lower_thr", float "upper_thr", bool "fulls", bool "fulld", float "chroma_protect")
```

MSR(Multi Scale Retinex) is the most successful implementation of Retinex, based on center/surround theory.

MSRCP(Multi Scale Retinex with Chromaticity Preservation) is based on MSR. It applies MSR on intensity channel, and adjust UV/RGB according to the filtering result of intensity channel to preserve chromaticity.

As MSRCP preserves chromaticity, it is excellent for dynamic range compression and local contrast enhancement, while it doesn't eliminate color cast. To implement the full color constancy feature of Retinex, it is recommended to use MSRCR(Multi Scale Retinex with Color Restoration) instead.

This function accept 8-16bit integer Gray/YUV/RGB input. Sub-sampled format is not supported. If you want to process YUV420/YUV422 clip, convert it to YUV444 or RGB first.

For processing in YUV444 and RGB, the filtering results are different. The intensity channel on which MSR is applied, is Y for YUV444 input and (R+G+B)/3 for RGB input. Since Y is a weighted average of R, G, B, processing in YUV444 may produce imbalanced chromaticity preservation. Also when chroma_protect is larger than 1 (default 1.2), the saturation of YUV444 processing result will be different from that of RGB processing result.

### Parameters:

- clip\
    A clip to process. It must be in Y/YUV444/RGB 8..16-bit planar format.

- sigma\
    Sigma of Gaussian function to apply Gaussian filtering.\
    Assign an array of multiple sigma to apply MSR.\
    Basically, in SSR(Single Scale Retinex), small sigma result in stronger dynamic range compression and local contrast enhancement, while large sigma result in better color rendition. To afford an acceptable trade-off between these features, MSR combines different scales to compute the final Retinex output.\
    It is recommended by most researches to use 3 different scales (balance between speed and quality).\
    Default: [25, 80, 250].

- lower_thr\
    After applying MSR, a normalization is applied to the value range [Floor, Ceil] of the Retinex output.\
    This parameter define the ratio of pixel number to determine the Floor of value range.\
    0: means using the minimum value in the Retinex output.\
    Increase it to enhance the global contrast of the output image.\
    Must be positive and less then 1.0 and the sum of lower_thr and upper_thr must be less than 1.0.\
    Default: 0.001.

- upper_thr\
    After applying MSR, a normalization is applied to the value range [Floor,Ceil] of the Retinex output.\
    This parameter define the ratio of pixel number to determine the Ceil of value range.\
    0: means using the maximum value in the Retinex output.\
    Increase it if there are some extreme bright parts in the Retinex output which makes the whole image too dark.\
    Must be positive and less then 1.0 and the sum of lower_thr and upper_thr must be less than 1.0.\
    Default: 0.001.
    
- fulls\
    Determine the value range of input clip.\
    True: Full range/PC range.\
    False: Limited range/TV range.\
    Default: True for RGB input, False for YUV/Gray input.
    
- fulld\
    Determine the value range of output clip.\
    True: Full range/PC range.\
    False: Limited range/TV range.\
    Set different value for fulls and fulld will result in range conversion.\
    Default: fulls.

- chroma_protect\
    The base of log function to attenuate chroma adjustment.\
    It could avoid extreme chroma amplifying, while the saturation of the result is changed.\
    1: No attenuation.\
    Must be equal to or greater than 1.0.\
    It is only available for YUV input.\
    Default: 1.2.
    
---

```
MSRCR (clip clip, float[] "sigma", float "lower_thr", float "upper_thr", bool "fulls", bool "fulld", float "restore")
```

MSRCR(Multi Scale Retinex with Color Restoration) is based on MSR. It applies MSR to each spectral channel (e.g. R, G and B), and modify the MSR output by multiplying it by a color restoration function of the chromaticity.

When MSR is applied to each spectral channel, it assumes the image obey gray world assumption. Otherwise, if the image violates gray world assumption, the MSR will produce grayish image by decreasing the color saturation, thus the color restoration step is proposed to solve this problem. However, for images with nice color balance, MSRCR still produces a desaturated look. Hence it is recommended to use MSRCP in most cases, and only apply MSRCR to the images with color cast. Also since MSRCR applies MSR to each spectral channel instead of intensity channel, it is slower than MSRCP.

### Parameters:

- clip\
    A clip to process. It must be in RGB 8..16-bit planar format.

- sigma\
    Sigma of Gaussian function to apply Gaussian filtering.\
    Assign an array of multiple sigma to apply MSR.\
    Basically, in SSR(Single Scale Retinex), small sigma result in stronger dynamic range compression and local contrast enhancement, while large sigma result in better color rendition. To afford an acceptable trade-off between these features, MSR combines different scales to compute the final Retinex output.\
    It is recommended by most researches to use 3 different scales (balance between speed and quality).\
    Default: [25, 80, 250].

- lower_thr\
    After applying MSR, a normalization is applied to the value range [Floor, Ceil] of the Retinex output.\
    This parameter define the ratio of pixel number to determine the Floor of value range.\
    0: means using the minimum value in the Retinex output.\
    Increase it to enhance the global contrast of the output image.\
    Must be positive and less then 1.0 and the sum of lower_thr and upper_thr must be less than 1.0.\
    Default: 0.001.

- upper_thr\
    After applying MSR, a normalization is applied to the value range [Floor,Ceil] of the Retinex output.\
    This parameter define the ratio of pixel number to determine the Ceil of value range.\
    0: means using the maximum value in the Retinex output.\
    Increase it if there are some extreme bright parts in the Retinex output which makes the whole image too dark.\
    Must be positive and less then 1.0 and the sum of lower_thr and upper_thr must be less than 1.0.\
    Default: 0.001.
    
- fulls\
    Determine the value range of input clip.\
    True: Full range/PC range.\
    False: Limited range/TV range.\
    Default: True.
    
- fulld\
    Determine the value range of output clip.\
    True: Full range/PC range.\
    False: Limited range/TV range.\
    Set different value for fulls and fulld will result in range conversion.\
    Default: fulls.

- restore\
    The strength of the nonlinearity for color restoration function.\
    Larger value result in stronger restoration.\
    It is a multiplier in a log function, so try to adjust it in a large scale (e.g. multiply it by a power of 10) if you want to see any difference.\
    Must be positive value.\
    Default: 125.0.

### Building:

- Windows\
    Use solution files.

- Linux
    ```
    Requirements:
        - Git
        - C++17 compiler
        - CMake >= 3.16
    ```
    ```
    git clone https://github.com/Asd-g/AviSynth-Retinex && \
    cd AviSynth-Retinex && \
    mkdir build && \
    cd build && \
    
    cmake ..
    make -j$(nproc)
    sudo make install
    ```
