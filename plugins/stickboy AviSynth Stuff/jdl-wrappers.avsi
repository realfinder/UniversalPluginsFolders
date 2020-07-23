# jdl-wrappers.avsi -- Various wrapper functions.
#
# Last modified: 2006-09-24
#
# Written by James D. Lin (stickboy) and assigned to the public domain.
#
# The latest version of this file can be downloaded from:
#   <http://www.avisynth.org/stickboy/>



# AudioGraphWrapper
#
#   Wrapper function to AudioGraph.  Displays each channel separately
#   below the video.  Each channel is displayed below the preceding
#   channel.
#
# PARAMETERS:
#   "frameRadius"   : (Default: 1)
#   "channelHeight" : The height to add to the bottom of the clip for each
#                       channel.
#                     (Default: 100)
#
# REQUIRES:
#   AudioGraph <http://forum.doom9.org/showthread.php?s=&threadid=59412>
#
function AudioGraphWrapper(clip c, int "frameRadius", int "channelHeight",
\                          int "curChannel")
{
    Assert(c.AudioChannels() > 0, "AudioGraphWrapper: clip has no audio")

    frameRadius = Default(frameRadius, 1)
    channelHeight = Default(channelHeight, 100)
    curChannel = Default(curChannel, 1)

    bottom = AudioDub(c.BlankClip(height=channelHeight), c.GetChannel(curChannel))
    bottom = bottom.AudioGraph(frameRadius)

    c = StackVertical(c, bottom)

    return (curChannel == c.AudioChannels())
    \      ? c
    \      : c.AudioGraphWrapper(frameRadius, channelHeight,
    \                            curChannel=(curChannel + 1))
}


# TemporalSoftenPreset
#
#   A wrapper function to TemporalSoften to specify presets.
#
# PARAMETERS:
#   "radius"
#   "luma_threshold"
#   "chroma_threshold"
#   "scenechange"
#   "mode"
#   "preset"           : The preset name, one of:
#                          { "default", "sh0dan-soft",
#                            "sh0dan-medium", "sh0dan-heavy" }
#                        (Default: "default")
#
# USAGE:
#   TemporalSoftenPreset(4, 4, 8, 15, 12)
#   TemporalSoftenPreset(preset="default")
#   TemporalSoftenPreset(preset="default", radius=2)
#
# REQUIRES:
#   SelectByString (SelectByStringEval) <http://www.avisynth.org/stickboy/>
#
function TemporalSoftenPreset(clip c, int "radius",
\                             int "luma_threshold",
\                             int "chroma_threshold",
\                             int "scenechange", int "mode",
\                             string "preset")
{
    preset = Default(preset, "default")

    # We can get Eval to assign multiple variables at once
    # by putting linebreaks in our strings.  Evil!
    SelectByStringEval(preset,
    \                  "default",       "r  =  4
                                         L  =  4
                                         ch =  8
                                         sc = 15
                                         m  =  2",
    \                  "sh0dan-soft",   "r  =  2
                                         L  =  3
                                         ch =  3
                                         sc =  6
                                         m  =  2",
    \                  "sh0dan-medium", "r  =  3
                                         L  =  5
                                         ch =  5
                                         sc = 10
                                         m  =  2",
    \                  "sh0dan-heavy",  "r  =  4
                                         L  =  8
                                         ch =  8
                                         sc = 10
                                         m  =  2",
    \                  else="""Throw("TemporalSoftenPreset: invalid preset")""")

    radius = Default(radius, r)
    luma_threshold = Default(luma_threshold, L)
    chroma_threshold = Default(chroma_threshold, ch)
    scenechange = Default(scenechange, sc)
    mode = Default(mode, m)

    return c.TemporalSoften(radius, luma_threshold, chroma_threshold,
    \                       scenechange, mode)
}


# LevelsWrapper
#
#   A wrapper function to Levels with named, optional parameters.
#
# PARAMETERS:
#   "input_low"   : (Default: 0)
#   "gamma"       : (Default: 1.0)
#   "input_high"  : (Default: 255)
#   "output_low"  : (Default: 0)
#   "output_high" : (Default: 255)
#
# USAGE:
#   LevelsWrapper(0, 1.2, 255, 0, 255)
#   LevelsWrapper(0, 1.2, 255)
#   LevelsWrapper(gamma=1.2)
#
function LevelsWrapper(clip c,
\                      int "input_low", float "gamma", int "input_high",
\                      int "output_low", int "output_high")
{
    return c.Levels(Default(input_low, 0),
    \               Default(gamma, 1.0),
    \               Default(input_high, 255),
    \               Default(output_low, 0),
    \               Default(output_high, 255))
}


# CropWrapper
#
#   A wrapper function to Crop with named, optional parameters.
#
#   <left>, <right>, and <width> cannot all be used together.
#   <top>, <bottom, and <height> cannot all be used together.
#
#   All other combinations of parameters are allowed.  If <width> or
#   <height> is specified without <left>/<right> or <top>/<bottom>
#   respectively, the cropped region will be centered within the video
#   frame.  See Usage, below.
#
# PARAMETERS:
#   "left", "top", "width", "height" : Same as the corresponding arguments
#                                        to Crop.
#                                      For compatibility with Crop,
#                                        negative values for width and
#                                        height may be used to specify
#                                        right and bottom margins,
#                                        respectively.
#   "right", "bottom"
#
# USAGE:
#   # For the examples below, assume that the input clip has a frame size
#   # of 720x480.
#
#   # Removes 16 pixels from the left and 8 pixels from the bottom; the new
#   # frame size is 704x472.
#   CropWrapper(left=16, bottom=8)
#
#   # This example is equivalent to CropWrapper(left=20)
#   CropWrapper(right=0, width=700)
#
#   # This example is equivalent to
#   # CropWrapper(left=200, right=200, top=120, bottom=120)
#   CropWrapper(width=320, height=240)
#
#   # CropWrapper supports Crop syntax.
#   CropWrapper(8, 0, 704, 480)
#   CropWrapper(8, 0, -8, 0)
#
function CropWrapper(clip c, int "left", int "top", int "width", int "height", int "right", int "bottom")
{
    Assert(   Defined(left) || Defined(right) || Defined(width)
    \      || Defined(top) || Defined(bottom) || Defined(height),
    \      "CropWrapper: nothing to do!")
    Assert(!(Defined(left) && Defined(right) && Defined(width)),
    \      "CropWrapper: <left>, <right>, and <width> parameters cannot all be used together")
    Assert(!(Defined(top) && Defined(bottom) && Defined(height)),
    \      "CropWrapper: <top>, <bottom>, and <height> parameters cannot all be used together")

    (Defined(width) && width <= 0) ? Eval("right = -width
                                           width = Undefined()")
    \                              : NOP()
    (Defined(height) && height <= 0) ? Eval("bottom = -height
                                             height = Undefined()")
    \                                : NOP()

    w0 = c.Width()
    h0 = c.Height()

    left = Default(left, Defined(width)
    \                    ? (Defined(right)
    \                       ? (w0 - width - right)
    \                       : ((w0 - width) / 2))
    \                    : 0)

    top = Default(top, Defined(height)
    \                  ? (Defined(bottom)
    \                     ? (h0 - height - bottom)
    \                     : ((h0 - height) / 2))
    \                  : 0)

    right = Default(right, 0)
    bottom = Default(bottom, 0)

    Assert(left >= 0, "CropWrapper: <left> must be >= 0")
    Assert(top >= 0, "CropWrapper: <top> must be >= 0")
    Assert(right >= 0, "CropWrapper: <right> must be >= 0")
    Assert(bottom >= 0, "CropWrapper: <bottom> must be >= 0")

    width = Default(width, w0 - left - right)
    height = Default(height, h0 - top - bottom)

    Assert(width > 0 && (left + width) <= w0, "CropWrapper: invalid width: " + String(width))
    Assert(height > 0 && (top + height) <= h0, "CropWrapper: invalid height: " + String(height))

    return (width == w0 && height == h0)
    \      ? c
    \      : c.Crop(left, top, width, height)
}


# AssumeFPS, ChangeFPS, ConvertFPS
#
#   Overloaded wrapper functions to AssumeFPS, ChangeFPS, and ConvertFPS to
#   provide accurate NTSC framerates by name.
#
#   Idea from tritical.  See
#   <http://forum.doom9.org/showthread.php?t=104681>
#
# DEPRECATED:
#   AviSynth 2.5.7 has its own internal versions of these functions.
#
# PARAMETERS:
#   preset : The preset name.  One of:
#              { "ntsc_film", "ntsc_video", "ntsc_double", "film", "pal" }
#
# REQUIRES:
#   SelectByString <http://www.avisynth.org/stickboy/>
#
function AssumeFPS (clip c, string preset) { return c.JDL_FPSPreset("AssumeFPS",  preset) }
function ChangeFPS (clip c, string preset) { return c.JDL_FPSPreset("ChangeFPS",  preset) }
function ConvertFPS(clip c, string preset) { return c.JDL_FPSPreset("ConvertFPS", preset) }

# Helper function to the AssumeFPS/ChangeFPS/ConvertFPS wrappers; do not
# call this yourself.
function JDL_FPSPreset(clip c, string fpsFunc, string preset)
{
    args = SelectByString(preset,
    \                     "ntsc_film",   "(24000, 1001)",
    \                     "ntsc_video",  "(30000, 1001)",
    \                     "ntsc_double", "(60000, 1001)",
    \                     "film",        "(24)",
    \                     "pal",         "(25)",
    \                     else="")
    Assert(args != "", fpsFunc + ": invalid preset")

    c
    return Eval(fpsFunc + args)
}
