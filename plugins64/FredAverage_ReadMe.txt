FredAverage, (not to be confused with RedAverage):- https://forum.doom9.org/showthread.php?t=174520
Requires VS2008 CPP runtimes.

dll's for avs v2.58 & avs v2.60/+ x86 & x64.

A simple average filter for Avisynth v2.60 standard colorspaces, only. (v2.58 colorspaces for v2.58 dll)

Returns a clip where each return frame is a single color average of input frame, same size and colorspace as input.
Does an invert on result if Bool Invert==true.


ColorSpace, YV12, YV16, YV24, YV411, Y8, YUY2, RGB24, RGB32, only.

Return clip Y, U and V, or R, G and B, will be channel averages, unless Invert==True, where channels averages will be inverted. 

FredAverage(clip c, Bool "Invert"=false,Bool "TV_YUV"=False)

	Invert,      Default false == sampled average. Otherwise Inverted average.
	TV_YUV,      Default false, If True(And YUV), then photo negative invert around TV levels mid Y(125.5), rather than 127.5.

Returns clip same colorspace and size as input.
      
StainlessS.      
