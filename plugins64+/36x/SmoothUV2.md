# Description

SmoothUV2 is a spatial derainbow filter. The luma is returned unchanged. This is [a port of the VapourSynth plugin SmoothUV](https://github.com/dubhater/vapoursynth-smoothuv).

SSHiQ2 is general purpose spatial denoiser. This an updated version of SSHiQ from SmoothUV v1.4.0.

# Requirement

AviSynth+.

# Usage

```
SmoothUV2 (clip, int "radius", int "threshold", int "interlaced", int "opt", int "dither")
```

## Parameters:

- clip\
    A clip to process. It must be in YUV 8..16-bit planar format and must have at least three planes.
    
- radius\
    Must be between 1 and 7 for 4:2:0 subsampling and between 1 and 3 for 4:2:2/4:4:4 subsampling.\
    Larger values smooth more.\
    Default: 3.
    
- threshold\
    Must be between 0 and 450.\
    Larger values smooth more.\
    Default: 270.
    
- interlaced\
    Whether the frame is interlaced.\
    -1: If frame properties are supported and frame property "_FieldBased" exists - "_FieldBased" value is used.\
    If frame properties aren't supported or there is no property "_FieldBased" - 0.\
    0: Progressive frame.\
    1: Interlaced frame.\
    Default: -1.
    
- opt\
    Sets which cpu optimizations to use.\
    -1: Auto-detect.\
    0: Use C++ code.\
    1: Use SSE2 code.\
    2: Use SSSE3 code.\
    3: Use SSE4.1 code.\
    4: Use AVX2 code.\
    5: Use AVX-512 code.\
    Default: -1.
    
- dither\
    How to convert the internal 16-bit calculation to the clip depth (when clip depth < 16-bit).\
    -1: Rounding.\
    0: Ordered dither.\
    1: Error diffusion (Floyd-Steinberg).\
    Default: -1.
    
---

```
SSHiQ2 (clip, int "rY", int "rC", int "tY", int "tC", int "strY", int "strC", bool "HQY", bool "HQC", int "interlaced", int "opt", int "dither")
```

## Parameters:

- clip\
    A clip to process. It must be in YUV 8..16-bit planar format and must have at least three planes.
    
- rY, rC\
    Radius respectively for luma and chroma planes.\
    Controls how far from the current pixel neighbors are used.\
    rY Must be between 1 and 7.\
    rC Must be between 1 and 7 for 4:2:0 subsampling and between 1 and 3 for 4:2:2/4:4:4 subsampling.\
    Larger values smooth more.\
    Default: rY = 5; rC = 3.
    
- tY, tC\
    Threshold respectively for luma and chroma planes.\
    Must be between 0 and 450.\
    Set to 0 for copying the plane.\
    Larger values smooth more.\
    Default: tY = 20; tC =30.
    
- strY, strC\
    Strength respectively for luma and chroma planes.\
    It is only used for HiQ mode and it controls how much of the smoothed version should be used at best for calculating the new pixel.\
    Must be between 0 and 255.\
    Default: strY = 240; strC = strY.
    
- HQY, HQC\
    Enables HiQ mode.\
    Edge processing strength gets automatically reduced.\
    Default: HQY = HQC = true.
    
- interlaced\
    Whether the frame is interlaced.\
    -1: If frame properties are supported and frame property "_FieldBased" exists - "_FieldBased" value is used.\
    If frame properties aren't supported or there is no property "_FieldBased" - 0.\
    0: Progressive frame.\
    1: Interlaced frame.\
    Default: -1.
    
- opt\
    Sets which cpu optimizations to use.\
    -1: Auto-detect.\
    0: Use C++ code.\
    1: Use SSE2 code.\
    2: Use SSSE3 code.\
    3: Use SSE4.1 code.\
    4: Use AVX2 code.\
    5: Use AVX-512 code.\
    Default: -1.
    
- dither\
    How to convert the internal 16-bit calculation to the clip depth (when clip depth < 16-bit).\
    -1: Rounding.\
    0: Ordered dither.\
    1: Error diffusion (Floyd-Steinberg).\
    Default: -1.

# Building

## Windows

Use solution files.

## Linux

### Requirements

- Git
- C++17 compiler
- CMake >= 3.16

```
git clone https://github.com/Asd-g/AviSynth-SmoothUV2 && \
cd AviSynth-SmoothUV2 && \
mkdir build && \
cd build && \
cmake .. && \
make -j$(nproc) && \
sudo make install
```
