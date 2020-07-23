# AVSLib :: 'clip' package :: 'channels' module :: Avisynth < 2.5.6 RGB channels functions
# Copyright (c) 2005, 2007 George Zarkadas (gzarkadas@users.sourceforge.net)

# This program is free software; you can redistribute it and/or modify it under the terms of 
# the GNU General Public License as published by the Free Software Foundation; either 
# version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
# PURPOSE.  See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; 
# if not, write to the "Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
# MA  02111-1307  USA"

# REQUIRES: RGBManipulate plugin, developed by Tonny Petersen(tsp@person.dk) 
# and included in this distribution.

# since we will only be imported from filters :: channels we do not
# need to load any module except the plugin's one.

global __load__ = LoadModule("plugins", "channels", "rgb")

# THE FUNCTIONS BELOW ARE INTENDED FOR AVISYNTH VERSION 2.55 AND BEFORE
# Versions 2.56 and later incorporate those functions into the Avisynth core. 

	# In proper use of the function 'c' is guaranteed to be RGB32 (and 
	# 'pixel_type' to be valid). Thus, the branch {ConvertToRGB32} will 
	# never be executed. So it is moved to the final else clause.
	#
	Function __show_rgb_convert(clip c, string pixel_type)
	{
		pixel_type = pixel_type == "RGB" ? "RGB32" : pixel_type
		return pixel_type == c.ColorSpace ? c : ( \
			pixel_type == "YV12" ? \
				c.ConvertToYV12(matrix="PC.601") : ( \
			pixel_type == "YUY2" ? \
				c.ConvertToYUY2(matrix="PC.601") : ( \
			pixel_type == "RGB24" ? \
				c.ConvertToRGB24() \
			: c.ConvertToRGB32() )))
	}

# The assertions simulate the behavior of Avisynth 2.5.6 core functions:
# 1. First c is checked and then pixel_type
# 2. Although error message states RGB32, all RGB (24,32) are accepted.
# 3. The default output pixel type is RGB32 (even if input is RGB24)

# The 'ShowRed' Avisynth 2.5.6 and later function
#
Function ShowRed(clip c, string "pixel_type")
{
	pixel_type = UCase(Default(pixel_type, "RGB32"))
	Assert(c.IsRGB, "ShowRed: RGB32 data only")
	Assert(IsPixelType(pixel_type, true), "ShowRed" + __show_pxtype_msg)
	return __show_rgb_convert( RGBManipulate_RToRGB(c), pixel_type)
}

# The 'ShowGreen' Avisynth 2.5.6 and later function
#
Function ShowGreen(clip c, string "pixel_type")
{
	pixel_type = UCase(Default(pixel_type, "RGB32"))
	Assert(c.IsRGB, "ShowGreen: RGB32 data only")
	Assert(IsPixelType(pixel_type, true), "ShowGreen" + __show_pxtype_msg)
	return __show_rgb_convert( RGBManipulate_GToRGB(c), pixel_type)
}

# The 'ShowBlue' Avisynth 2.5.6 and later function
#
Function ShowBlue(clip c, string "pixel_type")
{
	pixel_type = UCase(Default(pixel_type, "RGB32"))
	Assert(c.IsRGB, "ShowBlue: RGB32 data only")
	Assert(IsPixelType(pixel_type, true), "ShowBlue" + __show_pxtype_msg)
	return __show_rgb_convert( RGBManipulate_BToRGB(c), pixel_type)
}

# the RGBManipulate plugin only accepts RGB clips as input.
# In order to simulate the Avisynth's 2.5.6 channel merge behavior
# we must convert YUV clips before passing them to the plugin.
	
	# if c is YUV extracts only luma channel and converts to RGB32
	# (without upscaling) else returns c unchanged
	#
	Function __merge_rgb_adjust(clip c)
	{
		return c.IsYUV \
			? c.Greyscale().ConvertToRGB32(matrix="PC.601") \
			: c
	}	

# The 'MergeARGB' Avisynth 2.5.6 and later function
#
Function MergeARGB(clip clipA, clip clipR, clip clipG, clip clipB)
{
	clipA = __merge_rgb_adjust(clipA)
	Assert(!clipA.IsRGB24, "MergeARGB: Alpha source channel may not be RGB24")
	clipR = __merge_rgb_adjust(clipR)
	clipG = __merge_rgb_adjust(clipG)
	clipB = __merge_rgb_adjust(clipB)
	rw = clipR.Width
	gw = clipG.Width
	Assert(clipA.Width == rw && rw == gw && gw == clipB.Width, \
		"MergeARGB: All clips must have the same width.")
	rh = clipR.Height
	gh = clipG.Height
	Assert(clipA.Height == rh && rh == gh && gh == clipB.Height, \
		"MergeARGB: All clips must have the same height.")
	return RGBManipulate_MergeRGB(clipR, clipG, clipB, clipA)
}

# The 'MergeRGB' Avisynth 2.5.6 and later function
#
Function MergeRGB(clip clipR, clip clipG, clip clipB, string "pixel_type")
{
	pixel_type = UCase(Default(pixel_type, "RGB32"))
	Assert(pixel_type == "RGB32" || pixel_type == "RGB24", \
		"MergeRGB: supports the following output pixel types: RGB24, or RGB32")
	clipR = __merge_rgb_adjust(clipR)
	clipG = __merge_rgb_adjust(clipG)
	clipB = __merge_rgb_adjust(clipB)
	gw = clipG.Width
	Assert(clipR.Width == gw && gw == clipB.Width, \
		"MergeRGB: All clips must have the same width.")
	gh = clipG.Height
	Assert(clipR.Height == gh && gh == clipB.Height, \
		"MergeRGB: All clips must have the same height.")
	ret = RGBManipulate_MergeRGB(clipR, clipG, clipB, alphachannel=3)
	return pixel_type == "RGB32" ? ret : ret.ConvertToRGB24()
}
