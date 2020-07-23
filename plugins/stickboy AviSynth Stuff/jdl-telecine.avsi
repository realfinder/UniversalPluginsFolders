# jdl-telecine.avsi -- Functions for use with telecined material.
#
# Last modified: 2010-11-26
#
# Written by James D. Lin (stickboy) and assigned to the public domain.
#
# The latest version of this file can be downloaded from:
#   <http://www.avisynth.org/stickboy/>



# JDL_Telecine
#
#   Telecines a clip.
#
#   Useful for dealing with hybrid material when the final format is
#   interlaced.
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_Telecine(clip c)
{
    Assert(c.IsFrameBased(), "JDL_Telecine: clip must not have separated fields")

    # We need to handle the case of a null-clip manually;
    # otherwise, SelectEvery(...) will generate unwanted blank frames.

    # Unintuitively, DoubleWeave() flips the field order when it combines
    # fields in frame-based clips.  Therefore, we first need to call
    # ComplementParity() so that the parity of the output clip matches
    # that of the original.
    #
    # For more information, see:
    #   <http://www.avisynth.org/stickboy/DoubleWeave.html>
    return (c.FrameCount() == 0)
    \      ? c.AssumeScaledFPS(5, 4)
    \      : c.ComplementParity().DoubleWeave().SelectEvery(8, 0, 2, 3, 5, 6)
    \         .SetParity(c.GetParity())
}


# JDL_IVTCPattern
#
#   Performs manual 3:2 pulldown removal (inverse-telecine) equivalent
#   to the manual IVTC settings in VirtualDub.
#
#   Useful for removing 3:2 pulldown on material that has a consistent
#   telecine pattern.
#
# PARAMETERS:
#   offset  : [0, 4]
#             Offset of the combed frames.
#   "isBFF" : Parity of the clip.
#             Pass true if the clip is BFF, false if TFF.
#             This parameter corresponds to the "Invert Polarity" checkbox
#               in VirtualDub's IVTC dialog; if checked, set this parameter
#               to true. (Unlike AviSynth, VirtualDub always assumes the
#               input video is TFF.)
#             (Default: Determined by the field-order of the clip;
#                       i.e.: c.GetParity() == false)
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_IVTCPattern(clip c, int "offset", bool "isBFF")
{
    Assert(Defined(offset), "JDL_IVTCPattern: no offset specified")
    Assert(offset >= 0 && offset <= 4, "JDL_IVTCPattern: invalid offset")
    Assert(c.IsFrameBased(), "JDL_IVTCPattern: clip must not have separated fields")

    isBFF = Default(isBFF, c.GetParity() == false)
    isBFF ? c.AssumeBFF() : c.AssumeTFF()
    DoubleWeave()

    # We use SelectEvery(10, ...) instead of Pulldown(...) so that we can
    # have a bit more control over which frames we select.  After
    # DoubleWeave(), there will be a number of duplicate progressive
    # frames.  We'll choose frames that were originally "whole" in the
    # source when possible.
    return (c.FrameCount() == 0)
    \      ? c.AssumeScaledFPS(4, 5)
    \      : Eval(Select(offset,
    \                    "SelectEvery(10, 1, 4, 6, 8)",
    \                    "SelectEvery(10, 0, 3, 6, 8)",
    \                    "SelectEvery(10, 0, 2, 5, 8)",
    \                    "SelectEvery(10, 0, 2, 4, 7)",
    \                    "SelectEvery(10, 2, 4, 6, 9)"))
    \        .SetParity(c.GetParity())
}


# JDL_IVTCPattern2
#
#   Same as JDL_IVTCPattern, except blends the duplicated frames generated
#   by IVTC.
#
# PARAMETERS:
#   (see JDL_IVTCPattern)
#
# COLORSPACES:
#   [YUY2, RGB32]
#
function JDL_IVTCPattern2(clip c, int "offset", bool "isBFF")
{
    Assert(Defined(offset), "JDL_IVTCPattern2: no offset specified")
    Assert(offset >= 0 && offset < 5, "JDL_IVTCPattern2: invalid offset")

    overlay = c.JDL_IVTCPattern((offset + 1) % 5, isBFF)
    overlay = overlay.IsRGB32() ? overlay.ResetMask() : overlay

    return Layer(c.JDL_IVTCPattern(offset, isBFF), overlay, "fast")
}


# JDL_IVTCPatternSegment
#
#   Performs manual 3:2 pulldown removal to a specified section of a clip.
#
# PARAMETERS:
#   start, end    : Frames in the range [start, end) are inverse-telecined.
#   telecineFrame : The frame number to a leading combed frame in the
#                     section.
#
#                   Telecined clips usually have three progressive frames
#                     following by two (or fewer) combed frames:
#
#                     p p p c1 c2 p p p c1 c2 p p p c1 c2 p p p ...
#
#                   The value of <telecineFrame> should be the frame number
#                     of the first frame in one of the combed pairs (any of
#                     the frames indicated by <c1>; it doesn't matter
#                     which).
#
# USAGE:
#   AssumeTFF() # ... or AssumeBFF().  You must set the correct field-order
#               #                      of the clip first.
#
#   # Frames 3,4, 8,9, 13,14, ..., 4978,4979 are combed.
#   seg1 = JDL_IVTCPatternSegment(0, 4982, 3)
#
#   # Frames 4985,4986, 4990,4991, ..., 10875,10876 are combed.
#   seg2 = JDL_IVTCPatternSegment(4983, 10877, 4985)
#
#   # Frames 10879,10880, 10884,10885, ..., 15379,15380 are combed.
#   seg3 = JDL_IVTCPatternSegment(10878, 15382, 10884)
#
#   seg1 + seg2 + seg3
#
# REQUIRES:
#   jdl-util.avsi (Trim2)
#
function JDL_IVTCPatternSegment(clip c, int start, int end, int telecineFrame)
{
    Assert(telecineFrame >= 0, "JDL_IVTCPatternSegment: telecineFrame must be >= 0")
    offset = ((telecineFrame - start) % 5 + 5) % 5
    return c.Trim2(start, end).JDL_IVTCPattern(offset)
}


# JDL_DecimatePattern
#
#   Discards the frame with the given offset from every group of five
#   frames.
#
#   A complement to SelectEvery(c, 5, offset).
#
# DEPRECATED:
#   Please use DeleteEvery from my ApplyEvery plug-in instead.
#      <http://www.avisynth.org/stickboy/>
#
# PARAMETERS:
#   offset : [0, 4]
#            The offset the frame to discard.
#
function JDL_DecimatePattern(clip c, int offset)
{
    Assert(Defined(offset), "JDL_DecimatePattern: no offset specified")
    Assert(offset >= 0 && offset < 5, "JDL_DecimatePattern: invalid offset")

    return (c.FrameCount() == 0)
    \      ? c.AssumeScaledFPS(4, 5)
    \      : Eval(Select(offset,
    \                    "c.SelectEvery(5,    1, 2, 3, 4)",
    \                    "c.SelectEvery(5, 0,    2, 3, 4)",
    \                    "c.SelectEvery(5, 0, 1,    3, 4)",
    \                    "c.SelectEvery(5, 0, 1, 2,    4)",
    \                    "c.SelectEvery(5, 0, 1, 2, 3   )"))
}


# JDL_DecimatePattern2
#
#   Same as JDL_DecimatePattern, except blends the duplicated frames.
#
# PARAMETERS:
#   (see JDL_DecimatePattern)
#
# COLORSPACES:
#   [YUY2, RGB32]
#
function JDL_DecimatePattern2(clip c, int "offset")
{
    Assert(Defined(offset), "JDL_DecimatePattern2: no offset specified")
    Assert(offset >= 0 && offset < 5, "JDL_DecimatePattern2: invalid offset")

    overlay = c.JDL_DecimatePattern((offset + 1) % 5)
    overlay = overlay.IsRGB32() ? overlay.ResetMask() : overlay

    return (offset == 4)
    \      ? JDL_DecimatePattern2(c.DuplicateFrame(0), 0)
    \      : Layer(c.JDL_DecimatePattern(offset), overlay, "fast")
}


# JDL_ShowFrameOffset
#
#   Displays the frame number and the offset within the given cycle (frame
#   number modulo cycle).
#
#   Useful for determining telecine patterns.
#
# PARAMETERS:
#   "cycle"  : (Default: 5)
#   "height" : (Default: 40)
#
# REQUIRES:
#   jdl-util.avsi (Trim3)
#
function JDL_ShowFrameOffset(clip c, int "cycle", int "height")
{
    # The clip width must be even, so expand the frame slightly if it's not.
    c = (c.Width() % 2 == 0)
    \   ? c
    \   : c.AddBorders(0, 0, 1, 0)
    frameNumClip = BlankClip(c, color=$000000,
    \                        width=(c.Width() / 2),
    \                        height=Default(height, 40))
    try
    {
        # Use hanfrunz's fast FrameNumber filter if available.  See:
        #   <http://forum.doom9.org/showthread.php?s=&threadid=91968>
        frameNumClip = frameNumClip.FrameNumber()
    }
    catch (err_msg)
    {
        frameNumClip = frameNumClip.ShowFrameNumber()
    }
    offsetClip = frameNumClip.Trim3(0, length=Default(cycle, 5)).Loop().Trim3(0, length=c.FrameCount())
    return StackVertical(c, StackHorizontal(offsetClip, frameNumClip))
}
