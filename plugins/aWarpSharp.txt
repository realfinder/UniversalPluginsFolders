aWarpSharp - a WarpSharpenning filter for Avisynth 2.5 - beta 1

  this filter is a original warpsharping filter.
  a ISSE compatible cpu & YV12 input is required.

Syntax :
  aWarpSharp(float "depth", int "blurlevel", float "thresh", int "cm")

  depth & blurlevel :
    the settings you may be familiar with in VDub's WarpSharp filter.
    they are the only settings you need to tweak to achieve any effect.
    blurlevel consumes cpu power, but gives a big boost to the warpsharpenning.
    default : 16.0, 2

  thresh :
    a float value. 1.00 mean 100% (max). it's the bump mapping saturation setting.
    default value is recommended for maximum quality. if you tweak this setting,
    keep in mind it would enhance inegality of warping between edges.
    default :  0.5 (50%)

  cm : (chroma mode) 
    cm=0 will disable chroma filtering.
    cm=1 enables chroma warping with luma bump map (recommended).
    cm=2 enables chroma independant warping & bump map.
    default : 2

  Advanced settings are undocumented. they aren't needed anyway.
  (i don't use them, and i think it's better if nobody uses them ^^)

about quality & speed :
  aWarpSharp implements high-quality original warpsharping. "original"
  means the algo used differs on several points to other warpsharping filters.
  the code is fully iSSE optimised with high accuracy. see yourself ^^.
  You should need about 550 Mhz cpu load to warpsharp  640x480 images
  at 25 fps. This is a worst case, i achieved about 40 fps PAL full
  resolution MPEG-2 decoding deinterlacing & warpsharping using
  MPEG2Dec("dvd.d2v").aDeInt().aWarpSharp() with a 1.4 Ghz cpu.

  aWarpSharp is very optmised for my cpu (Athlon XP), but all modern cpus
  would run this filter at the maximal speed allowed by your hardware ^_^.

i hope you'll enjoy my last filter. it's one of the better piece of code i ever
wrote and it was very fun to code. 

for all anime fans and all avisynth users who like stuff i coded in the last months.

Bye ^^,
MarcFD

5 fev 2003 - Copyright (C) 2003 MarcFD