#
# Various Sharpen functions ...
#
# Sharp.avsi
#
#



#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\VARIABLEBLUR_25_DLL_20050524\variableblur.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\DCTFUN4B_25_DLL_20060205\dctfun4b.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\DEGRAINMEDIAN_20061008\degrainmedian.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\MASKTOOLS-V2_0A48\mt_masktools-25.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\REMOVEGRAIN-1_0\removegrain.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\REMOVEGRAINHD_20071126\removegrainhd.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SHARPFUNCTION_ASHARP_25_DLL_20030118\asharp.dll")

#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SHARPFUNCTION_WARPSHARP_20080325\warpsharp.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SHARPFUNCTION_AWARPSHARP_25_DLL_20030203\awarpsharp.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SHARPFUNCTION_AWARPSHARP_20090619\awarpsharp.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SHARPFUNCTION_UNSHARPHQ_V04\unsharphq_v04.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\DCTFILTER_25_DLL_20030221\dctfilter.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\FFT3DFILTER_20070220\fft3dfilter.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\TTEMPSMOOTH_25_DLL_20051117\ttempsmooth.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\VAGUEDENOISER_25_DLL_20050926\vaguedenoiser.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\HQDN3D_25_DLL_20050125\hqdn3d.dll")

#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\MVTOOLS-V2_5_11_3\mvtools2.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\REMOVEGRAIN-1_0\repair.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\NNEDI2\nnedi2.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\MASKTOOLS-V1_5_8\masktools.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\DEEN_25_DLL_20050705\deen.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SANGNOM_25_DLL_20040118\sangnom.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\GRADFUN2DB-V1_0\gradfun2db.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\ADDGRAINC_25_DLL_20060610\addgrainc.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\AVERAGE_V11\average.dll")
#LoadPlugin("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\DFTTESTV_1_6\dfttest.dll")

#Import("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\MINBLUR\minblur.avsi")
#Import("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\GRADFUN2DBMOD_V1_5\gradfun2dbmod_v1_5.avsi")
#Import("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\HQDERING\hqdering.avsi")
#Import("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\DEHALO_ALPHA\dehalo_alpha.avsi")
#Import("C:\PROGRAM FILES\AVISYNTH 2.5\PLUGINS\SEESAW\seesaw.avsi")


#
# SSSharp() function ...
#
# http://forum.doom9.org/showthread.php?t=132330
#
function SSSharp(clip c, float "rad", bool "ssw", float "strength", int "iter", bool "ss", int "denoise")
{
  rad      = Default(rad,      0.25)
  ssw      = Default(ssw,      true)
  strength = Default(strength, 4.0)
  iter     = Default(iter,     1)
  ss       = Default(ss,       true)
  denoise  = Default(denoise,  iter)

  c
  w        = width(c)
  h        = height(c)

  sswc = ssw ? c.ssw() : c

  ush  = unsharp(vary=rad, varc=1, strength=strength)

  (iter >= 1) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >=c1) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 2) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >=c2) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 3) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >=c3) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 4) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >=c4) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  
  return (last)
}

#
# SSSharp2() function ...
#
# http://forum.doom9.org/showthread.php?t=132330
# http://forum.doom9.org/showthread.php?t=132330&page=3
#
# replace SSW() function with SSW2() function ...
#
function SSSharp2(clip c, float "rad", bool "ssw", float "strength", int "iter", bool "ss", int "denoise")
{
  rad      = Default(rad,      0.25)
  ssw      = Default(ssw,      true)
  strength = Default(strength, 4.0)
  iter     = Default(iter,     1)
  ss       = Default(ss,       true)
  denoise  = Default(denoise,  iter)

  c
  w        = width(c)
  h        = height(c)

  sswc = ssw ? c.ssw2() : c

  ush  = unsharp(vary=rad, varc=1, strength=strength)

  (iter >= 1) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 1) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 2) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 2) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 3) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 3) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 4) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 4) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  
  return (last)
}


#
# SSSharpHQ() function ...
#
# http://forum.doom9.org/showthread.php?t=132330
#
# replace unSharp() function with unSarpHQ() function ...
#
function SSSharpHQ(clip c, float "rad", bool "ssw", float "strength", int "iter", bool "ss", int "denoise")
{
  rad      = Default(rad,      0.25)
  ssw      = Default(ssw,      true)
  strength = Default(strength, 4.0)
  iter     = Default(iter,     1)
  ss       = Default(ss,       true)
  denoise  = Default(denoise,  iter)

  c
  w        = width(c)
  h        = height(c)

  sswc = ssw ? c.ssw() : c

##  unsharpHQ(float STR = 5.0)
#  ush  = unsharpHQ(rad * 10.0)
  ush  = unsharpHQ(strength)

  (iter >= 1) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 1) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 2) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 2) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 3) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 3) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 4) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 4) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  
  return (last)
}

#
# SSSharpHQ2() function ...
#
# http://forum.doom9.org/showthread.php?t=132330
# http://forum.doom9.org/showthread.php?t=132330&page=3
#
# replace unSharp() function with unSharpHQ() function ...
# replace SSW() function with SSW2() function ...
#
function SSSharpHQ2(clip c, float "rad", bool "ssw", float "strength", int "iter", bool "ss", int "denoise")
{
  rad      = Default(rad,      0.25)
  ssw      = Default(ssw,      true)
  strength = Default(strength, 4.0)
  iter     = Default(iter,     1)
  ss       = Default(ss,       true)
  denoise  = Default(denoise,  iter)

  c
  w        = width(c)
  h        = height(c)

  sswc = ssw ? c.ssw2() : c

##  unsharpHQ(float STR = 5.0)
#  ush  = unsharpHQ(rad * 10.0)
  ush  = unsharpHQ(strength)

  (iter >= 1) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 1) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 2) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 2) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 3) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 3) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  (iter >= 4) ? MT_Merge(ush, sswc, spline64resize((ss ? w * 4 : w), (ss ? h * 4 : h)).halomaskM(hbias=-128, hthr=256, \
  agmrad=(ss ? round(rad * 4) : round(rad))).spline64resize(w, h)) : last
  (denoise >= 4) ? degrainmedian(mode=3).dctfun4b(2, 2) : last
  
  return (last)
}

#
# Supported functions() and so on...
# for SSSharp(), SSSharp2(), SSSharpHQ(), SSSharpHQ2() functions ...
#
# http://forum.doom9.org/showthread.php?t=132330
#
# version 0.1, optimizations by Didee
#
function halomaskM(clip c, int "hthr", int "hbias", int "agmrad")
{
  hthr   = Default(hthr, 256)
  hbias  = Default(hbias, -128)
  agmrad = Default(agmrad, 1)

  s      = c
  Mblur  = (agmrad == 1) ? s.removegrain(4, -1) : s.Quantile(radius_y=agmrad, radius_u=-1, radius_v=-1)
  Gblur  = (agmrad <= 5) ? s.binomialblur(vary=agmrad, varc=0) : s.gaussianblur(vary=agmrad, varc=0)
  maskM  = mt_lutxy(Mblur, Gblur, "y x - abs " + string(hthr) + " * " + string(hbias) + " +", U=1, V=1)

  return (maskM)                                
}

#
# Supported functions() and so on...
# for SSSharp(), SSSharp2(), SSSharpHQ(), SSSharpHQ2() functions ...
#
# http://forum.doom9.org/showthread.php?t=132330
#
# version 0.1, optimizations by Didee
#
function halomaskMR(clip c, int "hthr", int "hbias")
{
  hthr  = Default(hthr, 256)
  hbias = Default(hbias, -128)
	
  s     = c
  Ablur = s.removegrain(4)
  Gblur = s.gaussianblur(vary=1, varc=0)
  mask3 = mt_lutxy(Ablur, Gblur, "y x - abs " + string(hthr) + " * " + string(hbias) + " +", U=1, V=1)

  return (mask3)
}


#
# Supported functions() and so on...
# for SSSharp(), SSSharp2(), SSSharpHQ(), SSSharpHQ2() functions ...
#
# http://forum.doom9.org/showthread.php?t=132330
#
# version 0.1, optimizations by Didee
#
function SSW(clip c)
{
  c#.unsharp()
  w = width(c)
  h = height(c)

  spline64resize(w * 3, h * 3)

  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)

  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)
  awarpsharp(cm=0, depth=3, blurlevel=1, thresh=0.99)

  Spline64Resize(w, h)

  return (last)
}



#
# Supported functions() and so on...
# for SSSharp(), SSSharp2(), SSSharpHQ(), SSSharpHQ2() functions ...
#
# http://forum.doom9.org/showthread.php?t=132330
#
# version 0.1, optimizations by Didee
#
function SSW2(clip c)
{
  c#.unsharp()
  w = width(c)
  h = height(c)

  spline64resize(w * 3, h * 3)

  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)

  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)
  awarpsharp2(chroma=2, depth=2, blur=1, thresh=253)

  Spline64Resize(w, h)

  return (last)
}