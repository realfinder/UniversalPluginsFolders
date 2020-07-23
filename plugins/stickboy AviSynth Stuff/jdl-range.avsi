# jdl-range.avsi -- Functions that operate on ranges in a clip.
#
# Last modified: 2008-09-13
#
# Written by James D. Lin (stickboy) and assigned to the public domain.
#
# The latest version of this file can be downloaded from:
#   <http://www.avisynth.org/stickboy/>



# JDL_ApplyRange
#
#   Applies a filter to the specified range of frames in a clip.
#
#   This function is intended primarily for use with AviSynth 2.0x (an
#   internal ApplyRange function was added in AviSynth 2.51).  However,
#   this function offers the following advantages over the internal
#   version:
#   * directly supports filters that take no arguments
#       (fixed in AviSynth 2.55)
#   * supports named filter parameters
#   * allows the range to be of length 1 (fixed in AviSynth 2.52)
#   * allows audio modification (fixed in AviSynth 2.52)
#
# NOTE:
#   Do not use this with filters that modify the frame count.
#
# PARAMETERS:
#   start, end : The filter will be applied to all frames in the range
#                  [start, end].
#   thunk      : The action to perform on the specified frames.
#
# USAGE:
#   JDL_ApplyRange(123, 456, "Tweak(sat=1.1)")
#
# REQUIRES:
#   jdl-util.avsi (Trim2)
#
function JDL_ApplyRange(clip c, int start, int end, string thunk)
{
    Assert(start >= 0 && start < c.FrameCount(),
    \      "JDL_ApplyRange: start frame out of bounds: " + String(start))
    Assert(end >= start && end < c.FrameCount(),
    \      "JDL_ApplyRange: end frame out of bounds: " + String(end))

    c
    filtered = Eval(thunk)
    Assert(c.FrameCount() == filtered.FrameCount(),
    \      "JDL_ApplyRange: should not be used with filters that modify the frame count.  "
    \      + "Use JDL_ApplyRangeOld instead.")

    seg1 = c.Trim2(0, start)
    seg2 = filtered.Trim2(start, end + 1)
    seg3 = c.Trim2(end + 1)

    return seg1 + seg2 + seg3
}


# JDL_ApplyRangeOld
#
#   An old version of JDL_ApplyRange.  This differs from JDL_ApplyRange by
#   splicing before filtering.  This change affects the behavior of:
#   * temporal filters
#   * filters that operate on frame numbers
#   * filters that affect the frame count
#
# REQUIRES:
#   jdl-util.avsi (Trim2, Trim3)
#
function JDL_ApplyRangeOld(clip c, int start, int end, string thunk)
{
    Assert(start >= 0 && start < c.FrameCount(),
    \      "JDL_ApplyRangeOld: start frame out of bounds: " + String(start))
    Assert(end >= start && end < c.FrameCount(),
    \      "JDL_ApplyRangeOld: end frame out of bounds: " + String(end))

    seg1 = c.Trim2(0, start)
    seg2 = c.Trim3(start, end + 1)
    seg3 = c.Trim2(end + 1)

    return seg1 + Eval("seg2." + thunk) + seg3
}


# JDL_ApplyFrame
#
#   Applies a filter to a specific frame in a clip.
#
# PARAMETERS:
#   frame  : The index of the desired frame.
#   thunk  : The action to perform on the specified frame.
#
# USAGE:
#   ApplyFrame(123, "Tweak(sat=1.1)")
#
function JDL_ApplyFrame(clip c, int frame, string thunk)
{
    return JDL_ApplyRange(c, frame, frame, thunk)
}


# JDL_ApplyEvery
#
#   Applies a filter at regular intervals in a clip.
#
# DEPRECATED:
#   Please use my ApplyEvery plug-in instead.
#      <http://www.avisynth.org/stickboy/>
#
# NOTE:
#   If the total number of frames is not a multiple of <interval>, then
#   silent, blank frames will be appended to the end of the output clip.
#   It is the caller's responsibility to remove these afterward as
#   necessary. (See Usage, below, for an example of removing these extra
#   frames.)
#
#   This filter is recursive, and since AviSynth currently does not
#   properly optimize away tail-recursive calls, it can crash AviSynth (and
#   the host program) if there are too many iterations.
#
# PARAMETERS:
#   interval : The interval length, in frames.
#   thunk    : The action to perform on the frames in the interval.
#
# USAGE:
#   # Deletes the 0th frame of every 100.
#   JDL_ApplyEvery(100, "DeleteFrame(0)")
#
#   # Inverts the first two frames of every 5.
#   JDL_ApplyEvery(5, """ApplyRange(0, 1, "Levels", 0, 1.0, 255, 255, 0)""")
#
#   # Reverses every group of 4 frames.
#   JDL_ApplyEvery(4, "Reverse()")
#
#   # How to correct the clip length.
#   # (assumes that <thunk> does not itself modify the frame-count)
#   n = FrameCount()
#   JDL_ApplyEvery(...)
#   Trim(0, -n)
#
# REQUIRES:
#   ApplyEvery <http://www.avisynth.org/stickboy/>
#   jdl-util.avsi (JDL_LengthenClip, NullClip, Trim2)
#
function JDL_ApplyEvery(clip c, int interval, string thunk)
{
    Assert(interval > 0, "JDL_ApplyEvery: interval must be > 0")
    try
    {
        # Use the plug-in version if available.
        return c.ApplyEvery(interval, thunk)
    }
    catch (msg)
    {
        return JDL_ApplyEveryHelper(c.JDL_LengthenClip(Int(Ceil(c.FrameCount() / Float(interval))
        \                                                  * interval)),
        \                           c.NullClip(), interval, thunk, 0)
    }
}

# Helper function to JDL_ApplyEvery; do not call this yourself.
function JDL_ApplyEveryHelper(clip originalClip, clip newClip,
\                             int interval, string thunk,
\                             int curFrame)
{
    originalClip.Trim2(curFrame, length=interval)
    Eval(thunk)
    newClip = newClip + last
    curFrame = curFrame + interval
    return (curFrame >= originalClip.FrameCount())
    \      ? newClip
    \      : JDL_ApplyEveryHelper(originalClip, newClip, interval, thunk, curFrame)
}


# JDL_SimpleApplyEvery
#
#   Applies a filter at regular intervals in a clip.
#
#   Unlike ApplyEvery, JDL_SimpleApplyEvery applies the filter only at
#   specific frame offsets within each interval.
#
#   For these sorts of cases, JDL_SimpleApplyEvery should be much more
#   efficient than ApplyEvery.
#
# PARAMETERS:
#   thunk     : The action to perform on the specified frames.  Must not
#                 add, remove, or re-order frames.  Must not affect the
#                 frame-rate.
#   period    : The interval length, in frames.
#   "offsets" : A comma-separated list of the offsets of each frame to
#                 filter (see Usage, below).
#               Each offset must be in the range [0, period).
#
# USAGE:
#   # Converts frames 1, 3, 11, 13, 21, 23, 31, 33, ... to greyscale.
#   JDL_SimpleApplyEvery("Greyscale()", 10, "1, 3")
#
# REQUIRES:
#   ApplyEvery (DeleteEvery, InterleaveEvery) <http://www.avisynth.org/stickboy/>
#
function JDL_SimpleApplyEvery(clip c, string thunk, int period, string "offsets")
{
    Assert(period > 0, "JDL_SimpleApplyEvery: period must be > 0")

    # A workaround to not being able to pass a variable number arguments
    # to a user-defined function is to package them all up in a string.
    # From there, we can use Eval to pass them along to built-in functions
    # or to plug-ins.

    offsets = Default(offsets, "")
    args = String(period) + ", " + offsets

    c
    Eval(thunk)
    filtered = last
    Eval("filtered.SelectEvery(" + args + ")") # Pull out the frames we want.
    subClip = last

    Eval("c.DeleteEvery(" + args + ")")

    # Inject the filtered frames back in.
    Eval("InterleaveEvery(last, subClip, " + args + ")")

    # SelectEvery/DeleteEvery/InterleaveEvery might have introduced
    # rounding error into the frame-rate, so set it back to its original
    # value.
    Assert(FrameCount() == c.FrameCount(), String(FrameCount()) + " != " + String(c.FrameCount()))
    return AssumeFPS(c)
}


# JDL_DeleteRange
#
#   Deletes a range of frames from a clip.
#
# PARAMETERS:
#   start, end : All frames in the range [start, end] will be deleted.
#
function JDL_DeleteRange(clip c, int start, int end)
{
    Assert(start >= 0 && start < c.FrameCount(),
    \      "JDL_DeleteRange: start frame out of bounds: " + String(start))
    Assert(end >= start && end < c.FrameCount(),
    \      "JDL_DeleteRange: end frame out of bounds: " + String(end))

    return c.Trim2(0, start) ++ c.Trim2(end + 1)
}


# JDL_SingleFrame
#
#   Returns a single frame from a clip.
#
# PARAMETERS:
#   "frame" : The index of the desired frame.
#             (Default: 0)
#
# REQUIRES:
#   jdl-util.avsi (Trim3)
#
function JDL_SingleFrame(clip c, int "frame")
{
    frame = Default(frame, 0)
    return c.Trim3(frame, length=1)
}


# JDL_ReplaceRange
#
#   Replaces a range of frames from a clip with another clip.
#
# PARAMETERS:
#   baseClip     : The target clip.
#   newClip      : The clip containing the replacement frames.
#   start, "end" : All frames from <baseClip> in the range [start, end]
#                    will be replaced by <newClip>.
#                  If <end> is not specified, the number of frames replaced
#                    in <baseClip> will correspond to newClip.FrameCount()
#
# REQUIRES:
#   jdl-util.avsi (Trim2)
#
function JDL_ReplaceRange(clip baseClip, clip newClip, int start, int "end")
{
    Assert(start >= 0 && start < baseClip.FrameCount(),
    \      "JDL_ReplaceRange: start frame out of bounds: " + String(start))
    end = Default(end, start + newClip.FrameCount() - 1)
    length = end - start + 1
    Assert(end >= start && end < baseClip.FrameCount() && length <= newClip.FrameCount(),
    \      "JDL_ReplaceRange: end frame out of bounds: " + String(end))

    c = baseClip.Trim2(0, start) ++ newClip.Trim3(0, length=length) ++ baseClip.Trim2(end + 1)

    Assert(c.FrameCount() == baseClip.FrameCount(), "JDL_ReplaceRange: length mismatch")
    return c
}


# JDL_FreezeRegion
#
#   Freezes a region for the specified range of frames.  Does not affect
#   the audio track.
#
# PARAMETERS:
#   x, y          : The coordinates of the upper-left corner of the region
#                     to freeze.
#   w, h          : The width and height of the region to freeze.
#   start, end    : All frames in the range [start, end] will be frozen.
#   "sourceFrame" : The index of the frame containing the region to copy.
#                   (Default: start)
#
# COLORSPACES:
#   [YUY2, RGB32]
#
# REQUIRES:
#   jdl-util.avsi (Trim2)
#
function JDL_FreezeRegion(clip c, int x, int y, int w, int h, int start, int end, int "sourceFrame")
{
    Assert(start >= 0 && start < c.FrameCount(),
    \      "JDL_FreezeRegion: start frame out of bounds: " + String(start))
    Assert(end >= start && end < c.FrameCount(),
    \      "JDL_FreezeRegion: end frame out of bounds: " + String(end))
    sourceFrame = Default(sourceFrame, start)
    Assert(sourceFrame >= 0 && sourceFrame < c.Framecount(),
    \      "JDL_FreezeRegion: source frame out of bounds: " + String(sourceFrame))
    length = end - start + 1
    copy = c.JDL_SingleFrame(sourceFrame).Crop(x, y, w, h).Loop(length)
    replaced = Layer(c.Trim2(start, length=length),
    \                copy.IsRGB32() ? copy.ResetMask() : copy,
    \                "add", 255, x, y)
    return c.Trim2(0, start) + replaced + c.Trim2(end + 1)
}


# JDL_FreezeLoop
#
#   Like FreezeFrame, except repeats a cycle of frames instead of a single
#   frame.
#
#   Does not affect the audio track.
#
#   See Usage, below.
#
# PARAMETERS:
#   start, end         : All frames in the range [start, end] will be
#                          replaced with the looped frames.
#   loopStart, loopEnd : All frames in the range [loopStart, loopEnd] will
#                          be looped.
#
# USAGE:
#   # Create the following output sequence:
#   # 0 1 2 3 0 1 2 0 1 2 0 1 2 0 1 15 16 17 ...
#   #         ^-------------------^
#   #           Frames [4, 14] are replaced by looping frames [0, 2].
#   #
#   JDL_FreezeLoop(4, 14, 0, 2)
#
# REQUIRES:
#   jdl-util.avsi (Trim2)
#
function JDL_FreezeLoop(clip c, int start, int end, int loopStart, int loopEnd)
{
    Assert(start >= 0 && start < c.FrameCount(),
    \      "JDL_FreezeLoop: start frame out of bounds: " + String(start))
    Assert(loopStart >= 0 && loopStart < c.FrameCount(),
    \      "JDL_FreezeLoop: loop start out of bounds: " + String(loopStart))
    Assert(end >= start && end < c.FrameCount(),
    \      "JDL_FreezeLoop: end frame out of bounds: " + String(end))
    Assert(loopEnd >= loopStart && loopEnd < c.FrameCount(),
    \      "JDL_FreezeLoop: loop end out of bounds: " + String(loopEnd))

    span = end - start + 1
    newClip = c.Trim2(loopStart, loopEnd + 1)
    newClip = newClip.Loop(span / newClip.FrameCount() + 1)

    return AudioDub(JDL_ReplaceRange(c, newClip, start, end), c)
}
