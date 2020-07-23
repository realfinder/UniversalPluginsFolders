# jdl-util.avsi -- General-purpose, utility functions.
#
# Last modified: 2008-10-16
#
# Written by James D. Lin (stickboy) and assigned to the public domain.
#
# The latest version of this file can be downloaded from:
#   <http://www.avisynth.org/stickboy/>



# These functions are superceded by the more general functions in my
# Min/Max plug-in.  Luckily, AviSynth supports overloaded functions, so
# the plug-in and these functions can co-exist peacefully.  Yay!
#
function Min(val a, val b) { return (a < b) ? a : b }
function Max(val a, val b) { return (a > b) ? a : b }
function Clamp(val n, val low, val high) { return Max(low, Min(n, high)) }


# Returns a double-quote (") character.  I made a function for this because
# I can't (and don't want to) remember the ASCII value.
#
# (See <http://forum.doom9.org/showthread.php?s=&threadid=71597> for an
# even easier way to put double-quotes within strings.)
#
function Quote() { return Chr(34) }


# Returns a newline character.  Again, not something I care to remember.
#
function Endl() { return Chr(10) }


# AssertEval is mentioned in the AviSynth documentation but doesn't exist
# as of 2.52.
#
function AssertEval(string s)
{
    Assert(s)
}


# Throw
#
#   Throws an error.
#
# PARAMETERS:
#   "msg" : The error message.
#           (Default: AviSynth's default assertion string.)
#
function Throw(string "msg")
{
    Assert(false, msg)
}


# Undefined
#
#   Generates an "undefined" variable value.  This function can be used to
#   set an already-defined variable to an undefined state.
#
# USAGE:
#   x = Undefined() # Subsequent calls to Defined(x) will return false.
#
function Undefined(val "dummyArg")
{
    Assert(!Defined(dummyArg), "Undefined: Cannot be called with any arguments.")
    return dummyArg
}


# NullClip
#
#   Generates a null (0 frame) clip using the input clip as a template.
#   Useful to use as a placeholder when conditionally splicing.
#
function NullClip(clip "template")
{
    return BlankClip(template, length=0)
}


# JDL_ImageSource
#
#   A wrapper function to ImageReader.  The syntax and behavior of this
#   function should be a little bit more intuitive than ImageReader's.
#
# PARAMETERS:
#   filenameTemplate : The template string used to generate filenames from
#                        frame numbers.
#                      Should include the full, absolute path.
#   "start", "end"   : The start and end frame numbers (inclusive).
#                      (Default: If not specified, assumes that you want to
#                        load only a single image file instead of an image
#                        sequence.)
#   "fps"            : The desired frame-rate.
#                      (Default: 29.97)
#
function JDL_ImageSource(string filenameTemplate, int "start", int "end", float "fps")
{
    Assert(Defined(start) == Defined(end),
    \      "JDL_ImageSource: <start> and <end> parameters must be used together")

    start = Default(start, 0)
    end = Default(end, start)

    Assert(start >= 0, "JDL_ImageSource: invalid start frame: " + String(start))
    Assert(end >= start, "JDL_ImageSource: invalid end frame: " + String(end))
    Assert(filenameTemplate != "", "JDL_ImageSource: invalid filename template")

    fps = Default(fps, 29.97)

    try
    {
        ImageSource(filenameTemplate, start, end, 1, true, pixel_type="rgb32")
    }
    catch (msg)
    {
        try
        {
            # We're using a version of AviSynth that doesn't support RGB32
            # for ImageSource.  Fall back.
            ImageSource(filenameTemplate, start, end, 1, true)
        }
        catch (msg)
        {
            # ImageReader used to have a bug that generated upside-down
            # images.  This bug was fixed at the same time that the
            # ImageSource function was added.  If we got this far, that
            # implies that ImageSource doesn't exist and that we're still
            # using the version of ImageReader with the upside-down bug.
            ImageReader(filenameTemplate, start, end, 1, true)
            FlipVertical()
        }
    }

    Trim3(start, length=(end - start + 1))
    AssumeFPS(fps)

    return last
}


# Trim2
#
#   A version of Trim with a different syntax.  This version is more
#   suitable than Trim in reusable functions.
#
#   See: <http://forum.doom9.org/showthread.php?s=&threadid=58358>
#
#   Trims the video clip to include frames in the range [start, end).
#
#   If <end> is negative, indicates the number of frames to trim from the
#   end of the clip.  See Usage, below.
#
#   If <end> is omitted, all frames to the end of the clip are included.
#   Equivalent to Trim2(c, start, c.FrameCount()).
#
#   <length> may be used intead of <end>.  <length> must be non-negative.
#
#   <end> and <length> cannot be used together.
#
#   Allows generation of null (0 frame) clips.
#
# PARAMETERS:
#   start, "end"
#   "length"
#
# PRECONDITIONS:
#   0 <= start
#   start <= end || end < 0
#   length >= 0
#
# USAGE:
#   Trim2(0, -1) # removes the last frame
#
#   Trim2(500, 600) # same as Trim2(500, length=100)
#
function Trim2(clip c, int start, int "end", int "length")
{
    Assert(!(Defined(end) && Defined(length)),
    \      "Trim2: <end> and <length> parameters cannot be used together")
    Assert(!Defined(length) || length >= 0,
    \      "Trim2: invalid length: " + String(length))

    end = Defined(end)
    \     ? ((end < 0) ? (c.FrameCount() + end) : end)
    \     : Max(start, c.FrameCount())
    end = Defined(length) ? (start + length) : end

    Assert(start >= 0, "Trim2: start frame out of bounds: " + String(start))
    Assert(end >= start, "Trim2: end frame out of bounds: " + String(end))

    start = Min(start, c.FrameCount())
    end = Min(end, c.FrameCount())

    # We can't use Trim(start, end - 1) in case end == 1
    return (start == end)
    \      ? c.NullClip()
    \      : c.Trim(start, -(end - start))
}


# Trim3
#
#   A version of Trim2 with stricter bounds.  Disallows bounds beyond the
#   end of the clip.  Disallows generation of null (0 frame) clips.
#
# PARAMETERS:
#   start, "end"
#   "length"
#
# PRECONDITIONS:
#   0 <= start
#   start < end <= c.FrameCount() || end < 0
#   length > 0
#
function Trim3(clip c, int start, int "end", int "length")
{
    Assert(!(Defined(end) && Defined(length)),
    \      "Trim3: <end> and <length> parameters cannot be used together")
    Assert(!Defined(length) || length > 0,
    \      "Trim3: invalid length: " + String(length))

    end = Defined(length) ? (start + length) : Default(end, c.FrameCount())
    end = (end < 0) ? (c.FrameCount() + end) : end

    Assert(start >= 0 && start < c.FrameCount(),
    \      "Trim3: start frame out of bounds: " + String(start))
    Assert(end > start && end <= c.FrameCount(),
    \      "Trim3: end frame out of bounds: " + String(end))

    return c.Trim2(start, end)
}


# JDL_LengthenClip
#
#   Appends frames to a clip to give it the specified length.
#
# DEPRECATED:
#   Please use LengthenClip from my ApplyEvery plug-in instead.
#      <http://www.avisynth.org/stickboy/>
#
# PARAMETERS:
#   minLength : The minimum length desired for the clip.
#   "copy"    : If true, the clip will be lengthened by duplicating
#                 its last frame.
#               If false, the clip will be lengthened by appending
#                 blank frames to the end.
#               (Default: false)
#   "color"   : The RGB color to use for appended blank frames.
#               (default: $000000 (black))
#
function JDL_LengthenClip(clip c, int minLength, bool "copy", int "color")
{
    copy = Default(copy, false)
    color = Default(color, $000000)
    try
    {
        # Use the plug-in version if available.
        return c.LengthenClip(minLength, copy, color)
    }
    catch (msg)
    {
        numPadFrames = minLength - c.FrameCount()
        return (numPadFrames > 0)
        \      ? (c ++ (copy
        \               ? c.Trim3(c.FrameCount() - 1).Loop(numPadFrames).Amplify(0.0)
        \               : c.BlankClip(length=numPadFrames, color=color)))
        \      : c
    }
}


# SetParity
#
#   Sets the parity of a clip.
#
# PARAMETERS:
#   parity : true for TFF, false for BFF.
#            These values correspond to those returned by the internal
#              GetParity function.
#            (I use the mnemonic "T" = "T"op = "T"rue to remember.)
#
function SetParity(clip c, bool parity)
{
    return parity ? c.AssumeTFF() : c.AssumeBFF()
}


# AssumeScaledFPS
#
#   Scales a clip's frame-rate by the specified factor.  Attempts to
#   perform an exact calculation without overflow if possible.  Does not
#   add or remove frames nor affect the audio track.
#
# DEPRECATED:
#   AviSynth 2.5.6 has its own internal version of this function.
#
# PARAMETERS:
#   numerator, denominator : The scaling factor.
#
# USAGE:
#   # Sets the clip's frame-rate to 80% (4/5) of its original value.
#   AssumeScaledFPS(4, 5)
#
function AssumeScaledFPS(clip c, int numerator, int denominator)
{
    Assert(denominator != 0, "AssumeScaledFPS: denominator cannot be 0")

    # We need to cancel as many common factors as possible to minimize
    # the chance for overflow.  Unfortunately, AviSynth doesn't provide a
    # gcd function, and writing our own recursively won't be as efficient
    # as we'd like.
    #
    # Instead, we readily abuse the fact that AviSynth internally reduces
    # frame-rates to make the numerator and denominator relatively prime.

    n0 = c.FrameRateNumerator()
    d0 = c.FrameRateDenominator()

    # Make sure that the numerator and denominator are reduced.
    scale = c.AssumeFPS(numerator, denominator)
    n = scale.FrameRateNumerator()
    d = scale.FrameRateDenominator()

    # Cancel any common factors with the original frame-rate.
    x = c.AssumeFPS(n0, d)
    y = c.AssumeFPS(n, d0)

    nx = x.FrameRateNumerator()
    dx = x.FrameRateDenominator()

    ny = y.FrameRateNumerator()
    dy = y.FrameRateDenominator()

    # We've cancelled as many factors as we could.  Multiply the reduced
    # frame-rates. (Assuming overflow doesn't occur, newN and newD will be
    # relatively prime.)
    newN = nx * ny
    newD = dx * dy

    # If we didn't overflow, use newN and newD directly.  Otherwise,
    # resort to floating-point arithmetic.
    #
    # Unfortunately, checking for overflow with (a * b) / a != b produces
    # false positives because AviSynth scripts use only signed integers,
    # and frame-rates internally use unsigned values.
    #
    # Therefore, as a secondary heuristic, check if the integer calculation
    # is equal to the floating-point calculation within some tolerance.
    approximate = (c.FrameRate() * n) / d
    exactClip = (newD == 0) ? c : c.AssumeFPS(newN, newD)

    Assert(approximate <= (Float($7FFFFFFF) * 2),
    \      "AssumeScaledFPS: frame-rate is too high.")

    return (   newD != 0
    \       && (   (   (nx == 0 || newN / nx == ny)
    \               && newD / dx == dy)
    \           || (abs(exactClip.FrameRate() - approximate) <= (exactClip.FrameRate() * 0.0001)) ))
    \      ? exactClip
    \      : c.AssumeFPS(approximate)
}


# JDL_ShiftFrame
#
#   Shifts a frame by the specified offset.
#
# PARAMETERS:
#   "dx", "dy" : The offset amount.
#                Positive values shift to the right or downward.
#                Negative values shift to the left or upward.
#                These values are subject to colorspace constraints
#                  (see the documentation to the internal Crop function
#                  for details).
#                (dx default: 0)
#                (dy default: 0)
#   "color"    : The RGB color to use to fill in the vacated edges.
#                (Default: $000000 (black))
#
function JDL_ShiftFrame(clip c, int "dx", int "dy", int "color")
{
    dx = Default(dx, 0)
    dy = Default(dy, 0)
    color = Default(color, $000000)

    w = c.Width() - Abs(dx)
    h = c.Height() - Abs(dy)

    Assert(w >= 0 && h >= 0,
    \      "JDL_ShiftFrame: the magnitudes of <dx> and <dy> cannot be larger than the frame size")

    c = (dx == 0)
    \   ? c
    \   : ((dx < 0)
    \      ? c.Crop(-dx, 0, w, c.Height()).AddBorders( 0, 0, -dx, 0, color)
    \      : c.Crop(  0, 0, w, c.Height()).AddBorders(dx, 0,   0, 0, color))

    c = (dy == 0)
    \   ? c
    \   : ((dy < 0)
    \      ? c.Crop(0, -dy, c.Width(), h).AddBorders(0,  0, 0, -dy, color)
    \      : c.Crop(0,   0, c.Width(), h).AddBorders(0, dy, 0,   0, color))

    return c
}


# NoArgFunctionWrapper
#
#   A wrapper for filters that take no additional arguments other than a
#   clip.  Useful for using such filters in functions such as Animate or
#   ApplyRange.
#
# DEPRECATED:
#   Starting with AviSynth 2.5.5, this function is no longer necessary.
#
# PARAMETERS:
#   filter : The name of the filter to apply.
#
# USAGE:
#   ApplyRange(100, 200, "NoArgFunctionWrapper", "Greyscale")
#
function NoArgFunctionWrapper(clip c, string filter)
{
    c
    return Eval(filter + "()")
}


# JDL_FunctionDefined
#
#   Determines whether a function is defined.
#
# PARAMETERS:
#   functionName : The name of the function.
#                  Can be the name of a built-in function, a plug-in
#                    function, or a user-defined function.
#   "err_msg"    : If specified, JDL_FunctionDefined will throw an
#                    exception with that error message if the function is
#                    not defined.
#                  If not specified, JDL_FunctionDefined will return true
#                    if the function is defined, false otherwise.
#
# USAGE:
#   # JDL_FunctionDefined can be used to check for script dependencies.  If
#   # a script requires a plug-in or function that isn't found, you can
#   # present a meaningful error message explaining where to download the
#   # necessary files.
#   #
#   JDL_FunctionDefined("Trim2",
#   \                   "This script requires Trim2.  Download it from ...")
#
function JDL_FunctionDefined(string functionName, string "err_msg")
{
    try
    {
        Eval(functionName + "()")

        # If we made it this far, we called the function without any
        # problem; therefore it exists.
        return true
    }
    catch (s)
    {
        # Dependent on AviSynth generating an exception with the message:
        # "Script error: there is no function named ..."
        # Basic idea from mf.
        isDefined = FindStr(s, "there is no function named "
        \                      + Quote() + functionName + Quote())
        \           == 0

        Assert(isDefined || !Defined(err_msg), err_msg)
        return isDefined
    }
}


# HasVideo
#
#   Returns true if the specified clip has a video track, false otherwise.
#
# DEPRECATED:
#   AviSynth 2.5.6 has its own internal version of this function.
#
function HasVideo(clip c)
{
    return c.Width() != 0
}


# HasAudio
#
#   Returns true if the specified clip has an audio track, false otherwise.
#
# DEPRECATED:
#   AviSynth 2.5.6 has its own internal version of this function.
#
function HasAudio(clip c)
{
    return c.AudioRate() != 0
}
