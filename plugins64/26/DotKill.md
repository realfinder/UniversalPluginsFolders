# Description

Spatio-temporal dotcrawl and rainbow remover for AviSynth/AviSynth+.

This is [a port of the VapourSynth plugin DotKill](https://github.com/myrsloik/DotKill).

# Usage

```
DotKillS (clip input, int "iterations")
```

A purely spatial dotcrawl remover that can be safely used on most material after field matching.

## Parameters:

- input\
    A clip to process. It must be in YUV 8..16-bit planar format.
    
- iterations\
    The number of times to apply the internal filter.\
    Usally a number between 1 and 4 will have the best results and using too high values may cause artifacting.\
    Must be greater than or equal to 1.
    Default: 1.
    
---

```
DotKillZ (clip input, int "order", int "offset")
```

A pseudo-spatial dotcrawl and rainbow remover. It only works on NTSC content with rainbows added after 3:2 pulldown. This is true most of the time for anime.

Note that due to its nature only every other final frame will have dotcrawl and rainbows removed. Typically never artifacts if all requirements are met.

## Parameters:

- input\
    A clip to process. It must be in YUV 8..16-bit planar format.
    
- order\
    Field order.\
    Usually 0, note that 1 hasn't been tested due to a lack of test material.\
    Must be either 0 or 1.\
    Default: 0.
    
- offset\
    The cycle offset for the pulldown pattern.\
    Must be between 0 and 4.\
    Can only be determined by trial and error.\
    Default: 0.

---

```
DotKillT (clip input, int "order", int "offset", int "dupthresh", int "tratio", bool "show")
```

A full spatio-temporal dotcrawl and rainbow remover. It only works on NTSC content with rainbows added after 3:2 pulldown. This is true most of the time for anime.

May produce extreme artifacting if dupthresh is set too high.

## Parameters:

- input\
    A clip to process. It must be in YUV 8..16-bit planar format.
    
- order\
    Field order.\
    Usually 0, note that 1 hasn't been tested due to a lack of test material.\
    Must be either 0 or 1.\
    Default: 0.
    
- offset\
    The cycle offset for the pulldown pattern.\
    Must be between 0 and 4.\
    Can only be determined by trial and error.\
    Default: 0.
    
- dupthresh\
    The threshold for determining if a block has changed between fields.\
    Depending on the source material 32-128 are usually reasonable values.\
    A value of 0 makes the function identical to DotKillZ.\
    Must be between 0 and 255.\
    Default: 64.
    
- tratio\
    If more than 1/tratio blocks have changed between fields then temporal filtering won't be considered in that direction.\
    Higher values can make high motion sections less likely to artifact.\
    Default: 3.
    
- show\
    Shows which blocks have been determined to contain no change between fields and therefore will be blended to reduce artifacts.\
    White square means that it will blend with the next frame and black square the previous.
    Default: False.
    
# Building

## Windows

Use solution files.

## Linux

### Requirements

- Git
- C++17 compiler
- CMake >= 3.16

```
git clone https://github.com/Asd-g/AviSynth-DotKill && \
cd AviSynth-DotKill && \
mkdir build && \
cd build && \
cmake .. && \
make -j$(nproc) && \
sudo make install
```
