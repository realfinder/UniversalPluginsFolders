MaskCrop -- an accelerator works with a mask for Avisynth2.6x/Avisynth+.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

2017/02/20 ver 0.1.1
 New: Addtion a new input clip "maskc" to specify a mask clip directly.
 New: Addtion a parameter "border" to avoid border affects on a mask.
 fix: Default masks expression was modified to "mt_makediff(last,last.loop(2,0,0), U=3,V=3).mt_lut("x 123 < 255 x 133 >  255 0 ? ?", U=3,V=3).Removegrain(1)"
 fix: Default filter expression was modified to "dfttest(sigma=16,tbsize=1,sbsize=16,sosize=12)"
 64bit available.

2016/09/02 ver 0.1

What is this?
A script and a plugin to speed up filtering with a mask.

How to use ? 
 loadplugin("maskcrop.dll")
 Import("maskcrop.avsi")
 maskcrop("mt_motion().mt_inpand().mt_expand()","deblock().dfttest()",8,8,false)
or
 loadplugin("maskcrop.dll")
 Import("maskcrop.avsi")
 mask=mt_motion()
 maskcrop(maskc=mask,8,8,false)

Syntax
 maskcrop(clip clip ,clip "maskc", string "masks", string "filter", int "xMul", int "yMul",Å@bool "chroma", bool "border")
 MaskCropT(clip clip, int "mul", bool "chroma")
 MaskCropL(clip clip, int "mul", bool "chroma")
 MaskCropB(clip clip, int "mul", bool "chroma")
 MaskCropR(clip clip, int "mul", bool "chroma")

Parameters
 maskc (clip default:none)
  A mask clip 

 masks (string default:"mt_makediff(last,last.loop(2,0,0), U=3,V=3).mt_lut("x 123 < 255 x 133 >  255 0 ? ?", U=3,V=3).Removegrain(1)")
  An expression of a mask what you want to apply.

 filter (string default:"dfttest(sigma=16,tbsize=1,sbsize=16,sosize=12)")
  An expression of filters what you want to apply.

 xMul, yMul, mul (int default: xMul=4, yMul=2)
  These parameters adjust width of and height of cropped frames to multiple of xMul and multiple of yMul, respectively.
  Default values satisfy yv12 plane. But some filters require larger values.

 chroma (bool default: true)
  This parameter switches to detect an edge of a mask with chroma, not only luma.

 border (bool default: true)
  crop(4,4,-4,-4) to avoid border affects on a mask.

MaskCrop() is a script to increase efficiency of filtering with a mask.
This script includes four non-clip functions that returns a coordinate value of a square including a mask.
These four functions i.e. MaskCropT(), MaskCropL(), MaskCropB() and MaskCropR() that return top, left, bottom and right coordinate values of square, respectively. 
Then these values are used to crop not only mask clip, but also the clip to filter.
This cropping provides a possibility to accelerate filtering.
If the sum of costs of MaskCrop, cropping a mask clip, cropping a processing clip and overlay was less than the sum of differences of filtering and mt_merge() between full frame and cropped frame, MaskCrop could accelerate filtering.