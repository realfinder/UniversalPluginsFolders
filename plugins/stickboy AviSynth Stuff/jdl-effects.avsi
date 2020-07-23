# jdl-effects.avsi -- Functions for creating effects.
#                     Also includes miscellaneous, exotic, and specialized
#                     functions.
#
# Last modified: 2008-09-13
#
# Written by James D. Lin (stickboy) and assigned to the public domain.
#
# The latest version of this file can be downloaded from:
#   <http://www.avisynth.org/stickboy/>



# JDL_Blackout
#
#   Blacks out a clip.  Does not affect the audio track.
#
# USAGE:
#   Intended to be used with ApplyRange.  For example:
#
#   ApplyRange(0, 10, "JDL_Blackout", "") # Black out frames [0, 10]
#
function JDL_Blackout(clip c, string "unused")
{
    # return AudioDub(c.BlankClip(color=$000000), c)
    return c.Levels(0, 1.0, 255, 0, 0)
}


# JDL_Silence
#
#   Silences a clip.  Does not affect the video track.
#
# USAGE:
#   Intended to be used with ApplyRange.  For example:
#
#   ApplyRange(0, 10, "JDL_Silence", "") # Silence frames [0, 10]
#
function JDL_Silence(clip c, string "unused")
{
    # return AudioDub(c, c.BlankClip())
    return c.Amplify(0.0)
}


# JDL_FadeIO
#
#   Fades a clip.
#
#   Unlike FadeIO/FadeIn/FadeOut, does not add additional frames.
#
# DEPRECATED:
#   AviSynth 2.5.6 adds FadeIn0/FadeOut0/FadeIO0 functions that should do
#   the same thing.
#
# PARAMETERS:
#   "start" : If specified, the number of frames to fade at the beginning
#               of the clip.
#             (Default: 0)
#   "end"   : if specified, the number of frames to fade at the end of the
#               clip.
#             (Default: 0)
#
# REQUIRES:
#   jdl-util.avsi (Trim2)
#
function JDL_FadeIO(clip c, int "start", int "end")
{
    start = Default(start, 0)
    end = Default(end, 0)
    Assert(start != 0 || end != 0, "JDL_FadeIO: no frames specified")
    Assert(start >= 0 && end >= 0, "JDL_FadeIO: invalid number of frames to fade")

    c = (start == 0) ? c : c.Trim2(1).FadeIn(start)
    c = (end == 0) ? c : c.Trim2(0, -1).FadeOut(end)
    return c
}


# JDL_FadeAudio
#
#   Fades audio in a clip.  Does not affect the video track.
#
#   Unlike FadeIO/FadeIn/FadeOut, does not add additional frames.
#
# PARAMETERS:
#   "start" : If specified, the number of frames to fade at the beginning
#               of the clip.
#             (Default: 0)
#   "end"   : If specified, the number of frames to fade at the end of the
#               clip.
#             (Default: 0)
#
function JDL_FadeAudio(clip c, int "start", int "end")
{
    return AudioDub(c, c.JDL_FadeIO(start, end))
}


# JDL_FadeVideo
#
#   Fades the video in a clip.  Does not affect the audio track.
#
#   Unlike FadeIO/FadeIn/FadeOut, does not add additional frames.
#
# PARAMETERS:
#   "start" : If specified, the number of frames to fade at the beginning
#               of the clip.
#             (Default: 0)
#   "end"   : If specified, the number of frames to fade at the end of the
#               clip.
#             (Default: 0)
#
function JDL_FadeVideo(clip c, int "start", int "end")
{
    video = c.JDL_FadeIO(start, end)
    return c.HasAudio() ? AudioDub(video, c)
    \                   : video
}


# JDL_Invert
#
#   Inverts a clip.
#
#   This function is intended primarily for use with AviSynth 2.52 and
#   earlier (an internal Invert function was added in AviSynth 2.53).
#   However, as of 2.53, the internal Invert function operates only in
#   RGB32.
#
# COLORSPACES:
#   [YUY2, RGB24?, RGB32]
#
function JDL_Invert(clip c)
{
    return c.Levels(0, 1.0, 255, 255, 0)
}


# JDL_Wipe
#
#   Combines two clips using a wipe transition.  The audio tracks are
#   blended during the transition.
#
# PARAMETERS:
#   c1          : The first clip.
#   c2          : The second clip.
#   overlap     : The desired number of transitional frames.
#   "direction" : The wipe direction, one of:
#                   { "right", "left", "up", "down" }
#                 (Default: "right")
#
# REQUIRES:
#   jdl-util.avsi (Trim2, Trim3)
#   SelectByString (SelectByStringEval) <http://www.avisynth.org/stickboy/>
#
function JDL_Wipe(clip c1, clip c2, int overlap, string "direction")
{
    Assert(   c1.Width() == c2.Width()
    \      && c1.Height() == c2.Height(),
    \      "JDL_Wipe: clips must have identical frame sizes")
    Assert(c1.FrameRate() == c2.FrameRate(),
    \      "JDL_Wipe: clips must have identical frame-rates")
    Assert(overlap > 0, "JDL_Wipe: invalid overlap length: " + String(overlap))
    Assert(c1.FrameCount() > overlap && c2.FrameCount() > overlap,
    \      "JDL_Wipe: each clip must have more than <overlap> frames")

    direction = Default(direction, "right")

    head = c1.Trim2(0, length=(c1.FrameCount() - overlap - 1))
    tail = c2.Trim2(overlap + 1)

    trans1 = c1.Trim3(c1.FrameCount() - overlap - 1)
    trans2 = c2.Trim3(0, length=(overlap + 1))
    Assert(trans1.FrameCount() == trans2.FrameCount(), "JDL_Wipe: bad math")

    trans = SelectByStringEval(direction,
    \                          "right", """Animate(0, overlap + 1, "JDL_SpliceHorizontal",
    \                                              trans2, trans1, 0,
    \                                              trans2, trans1, c1.Width())""",
    \                          "left",  """Animate(0, overlap + 1, "JDL_SpliceHorizontal",
    \                                              trans1, trans2, c1.Width(),
    \                                              trans1, trans2, 0)""",
    \                          "down",  """Animate(0, overlap + 1, "JDL_SpliceVertical",
    \                                              trans2, trans1, 0,
    \                                              trans2, trans1, c1.Height())""",
    \                          "up",    """Animate(0, overlap + 1, "JDL_SpliceVertical",
    \                                              trans1, trans2, c1.Height(),
    \                                              trans1, trans2, 0)""",
    \                          else="""Throw("JDL_Wipe: invalid direction")""")

    video = head + trans + tail
    audio = Dissolve(c1, c2, overlap + 1)
    Assert(video.FrameCount() == c1.FrameCount() + c2.FrameCount() - overlap - 1,
    \      "JDL_Wipe: bad math")
    Assert(video.FrameCount() == audio.FrameCount(), "JDL_Wipe: video/audio mismatch")
    return c1.HasAudio() ? AudioDub(video, audio)
    \                    : video
}


# JDL_SpliceHorizontal
#
#   Helper function to JDL_Wipe.
#
function JDL_SpliceHorizontal(clip c1, clip c2, int x)
{
    # In case we're dealing with YUY2 or YV12 video, crop only on even
    # boundaries.
    x = (c1.IsRGB() || x % 2 == 0) ? x : (x - 1)
    return (x == 0)
    \      ? c2
    \      : ((x == c1.Width())
    \         ? c1
    \         : StackHorizontal(c1.Crop(0, 0, x, 0),
    \                           c2.Crop(x, 0, c2.Width() - x, 0)))
}


# JDL_SpliceVertical
#
#   Helper function to JDL_Wipe.
#
function JDL_SpliceVertical(clip c1, clip c2, int y)
{
    # In case we're dealing with YV12 video, crop only on even
    # boundaries.
    y = (!c1.IsYV12() || y % 2 == 0) ? y : (y - 1)
    return (y == 0)
    \      ? c2
    \      : ((y == c1.Height())
    \         ? c1
    \         : StackVertical(c1.Crop(0, 0, 0, y),
    \                         c2.Crop(0, y, 0, c2.Height() - y)))
}


# JDL_MaskTransition
#
#   Combines two clips using the specified mask clip.  The audio tracks are
#   blended during the transition.
#
# PARAMETERS:
#   c1             : The first clip.
#   c2             : The second clip.
#   transitionMask : The mask clip.
#                    The mask should start as white and end as black.
#                    The mask clip should use the full PC [0, 255] luma
#                      range (call ColorYUV(levels="TV->PC") on the mask
#                      clip if necessary).
#
# REQUIRES:
#   jdl-util.avsi (Trim2, Trim3)
#
function JDL_MaskTransition(clip c1, clip c2, clip transitionMask)
{
    Assert(   c1.Width() == c2.Width()
    \      && c1.Width() == transitionMask.Width()
    \      && c1.Height() == c2.Height()
    \      && c1.Height() == transitionMask.Height(),
    \      "JDL_MaskTransition: clips must have identical frame sizes")
    Assert(   c1.FrameRate() == c2.FrameRate()
    \      && c1.FrameRate() == transitionMask.FrameRate(),
    \      "JDL_MaskTransition: clips must have identical frame-rates")

    overlap = transitionMask.FrameCount()
    Assert(overlap > 0, "JDL_MaskTransition: invalid overlap length: " + String(overlap))

    Assert(c1.FrameCount() >= overlap && c2.FrameCount() >= overlap,
    \      "JDL_MaskTransition: clips must be longer than the transition")

    head = c1.Trim2(0, length=(c1.FrameCount() - overlap))
    tail = c2.Trim2(overlap)

    trans1 = c1.Trim3(c1.FrameCount() - overlap)
    trans2 = c2.Trim3(0, length=overlap)
    Assert(trans1.FrameCount() == trans2.FrameCount(), "JDL_MaskTransition: bad math")
    trans = Overlay(trans2, trans1, mask=transitionMask)

    video = head + trans + tail
    audio = Dissolve(c1, c2, overlap)
    Assert(video.FrameCount() == audio.FrameCount(), "JDL_MaskTransition: video/audio mismatch")
    return c1.HasAudio ? AudioDub(video, audio)
    \                  : video
}


# JDL_Fill
#
#   Fills the specified rectangle with the specified color
#
# PARAMETERS:
#   x, y  : The coordinates for the upper-left corner of the rectangle.
#   w, h  : The rectangle width and height.
#   color : The RGB color for the rectangle.
#
# COLORSPACES:
#   [YUY2, RGB32]
#
function JDL_Fill(clip c, int x, int y, int w, int h, int color)
{
    Assert(x >= 0 && y >= 0 && w > 0 && h > 0, "JDL_Fill: invalid region")
    fill = c.BlankClip(width=w, height=h, color=color)
    fill = fill.IsRGB32() ? fill.ResetMask() : fill
    return Layer(c, fill, op="add", x=x, y=y)
}


# JDL_Slow
#
#   Slows a clip by the specified amount.
#
# PARAMETERS:
#   rate        : The new playback rate.
#                 e.g. 0.5 will set the playback rate to 50% of its
#                   original speed
#   "blend"     : Pass true to blend frames; pass false to duplicate
#                   existing frames only.
#                 If true, <rate> must be > 2/3.
#                 (Default: false)
#   "keepPitch" : Pass true to try to preserve the audio pitch.
#                 (Default: false)
#
# COLORSPACES:
#   [YUY2]
#
function JDL_Slow(clip c, float rate, bool "blend", bool "keepPitch")
{
    Assert(rate > 0 && rate < 1, "JDL_Slow: rate must be in the range (0, 1)")

    blend = Default(blend, false)
    keepPitch = Default(keepPitch, false)

    Assert(!blend || rate >= (2.0 / 3.0), "JDL_Slow: rate must be > 2/3 for blending")

    oldFrameRate = c.FrameRate()
    oldSampleRate = c.AudioRate()

    c = c.AssumeFPS(Round(oldFrameRate * rate))
    c = blend ? c.ConvertFPS(oldFrameRate) : c.ChangeFPS(oldFrameRate)
    c = keepPitch ? c.TimeStretch(tempo=(100.0 * rate))
    \             : c.AssumeSampleRate(Round(oldSampleRate * rate)).ResampleAudio(oldSampleRate)
    return c
}


# JDL_ReplaceFirstScanline
#
#   Replaces the first scanline in a video with a copy of the second.
#   Intended to throw away closed-captioning artifacts without changing
#   the frame size or aspect-ratio.
#
function JDL_ReplaceFirstScanline(clip c)
{
    return StackVertical(c.Crop(0, 1, 0, 1),
    \                    c.Crop(0, 1, 0, 0))
}


# JDL_SplitYUV
#
#   Separates the Y, U, V channels for easy examination, stacking them
#   in the following arrangement:
#       Y
#     --+--
#     U | V
#
function JDL_SplitYUV(clip c)
{
    Assert(c.IsYUV(), "JDL_SplitYUV: video must be YUY2 or YV12")
    y = c.Tweak(sat=0, coring=false) # This seems faster than YToUV(c, c).UToY()
    u = c.UToY()
    v = c.VToY()
    return StackVertical(y, StackHorizontal(u, v))
}


# JDL_MergeYUV
#
#   Recombines split Y, U, V channels formed by JDL_SplitYUV.
#
function JDL_MergeYUV(clip c)
{
    Assert(c.IsYUV(), "JDL_MergeYUV: video must be YUY2 or YV12")
    Assert(c.Width() % 2 == 0, "JDL_MergeYUV: unexpected frame width")

    originalHeight = c.IsYV12() ? (c.Height() * 2 / 3) : (c.Height() / 2)

    y = c.Crop(0, 0, c.Width(), originalHeight)
    uv = c.Crop(0, originalHeight, c.Width(), c.Height() - originalHeight)

    chromaWidth = c.Width() / 2

    u = uv.Crop(0, 0, chromaWidth, uv.Height())
    v = uv.Crop(chromaWidth, 0, chromaWidth, uv.Height())

    return YToUV(u, v, y)
}


# JDL_SplitRGB
#
#   Separates the R, G, B channels for easy examination, stacking them
#   in the following arrangement:
#     R | G | B
#
function JDL_SplitRGB(clip c)
{
    Assert(c.IsRGB(), "JDL_SplitRGB: video must be RGB")
    r = c.RGBAdjust(1, 0, 0, 0)
    g = c.RGBAdjust(0, 1, 0, 0)
    b = c.RGBAdjust(0, 0, 1, 0)
    return StackHorizontal(r, g, b)
}


# JDL_SplitScreenCompare
#
#   Performs a split-screen comparison.  Displays the left half of the
#   first clip beside the right half of the second clip.
#
# USAGE:
#   JDL_SplitScreenCompare(PixieDust(3), MipSmooth(preset="movieHQ"))
#
function JDL_SplitScreenCompare(clip leftClip, clip rightClip)
{
    Assert(   leftClip.Width() == rightClip.Width()
    \      && leftClip.Height() == rightClip.Height()
    \      && leftClip.FrameRate() == rightClip.FrameRate(),
    \      "JDL_SplitScreenCompare: clips must identical attributes")

    return JDL_SpliceHorizontal(leftClip, rightClip, leftClip.Width() / 2)
}
