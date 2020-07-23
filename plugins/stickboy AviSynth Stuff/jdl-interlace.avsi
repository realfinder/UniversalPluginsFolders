# jdl-interlace.avsi -- Functions for use with interlaced material.
#
# Last modified: 2008-09-13
#
# Written by James D. Lin (stickboy) and assigned to the public domain.
#
# The latest version of this file can be downloaded from:
#   <http://www.avisynth.org/stickboy/>



# JDL_SelectField
#
#   Retrieves the top or bottom field of a clip, regardless of field
#   order.
#
# PARAMETERS:
#   parity : Pass true to retrieve the top field of the clip.
#            Pass false to retrieve the bottom field.
#            These values correspond to those returned by the internal
#              GetParity function.
#            (I use the mnemonic "T" = "T"op = "T"rue to remember.)
#
function JDL_SelectField(clip c, bool parity)
{
    c = c.IsFrameBased() ? c.SeparateFields() : c
    return (c.GetParity() == parity) ? c.SelectEven()
    \                                : c.SelectOdd()
}

function JDL_SelectTopField(clip c) { return c.JDL_SelectField(true) }
function JDL_SelectBottomField(clip c) { return c.JDL_SelectField(false) }


# JDL_ReverseFieldDominance
#
#   Reverses the field-dominance in an interlaced clip.
#
#   Unlike Simon Walters' Reverse Field Dominance plug-in,
#   JDL_ReverseFieldDominance recombines fields instead of shifting
#   scanlines.  See:
#
#     <http://neuron2.net/reverse/reverse.html>
#
#   for descriptions of the two methods.  Although this function uses the
#   field recombination method, it does not lose the first field of video
#   nor should it introduce audio/video desynchronization.
#
# PARAMETERS:
#   "bobFirstLast" : Pass true to bob-deinterlace the first and last frames
#                      of the output clip.
#                    (Default: false)
#
# REQUIRES:
#   jdl-util.avsi (SetParity, Trim2)
#
function JDL_ReverseFieldDominance(clip c, bool "bobFirstLast")
{
    bobFirstLast = Default(bobFirstLast, false)

    originallyFrameBased = c.IsFrameBased()
    oldParity = c.GetParity()
    newClip = originallyFrameBased ? c : c.Weave()

    bookend = bobFirstLast
    \         ? newClip.JDL_SimpleBob().Amplify(0.0).AssumeFPS(newClip)
    \         : newClip.Blackness()
    bookend = bookend.SetParity(oldParity)

    newClip = bookend.Trim2(0, 1) ++ newClip ++ bookend.Trim2(bookend.FrameCount() - 1)
    newClip = newClip.SeparateFields().Trim2(1, -1) # Remove the first and last fields.
    newClip = originallyFrameBased ? newClip.Weave() : newClip

    return (c.FrameCount() == 0)
    \      ? c.ComplementParity()
    \      : newClip
}


# JDL_UnfoldFieldsVertical
#
#   Separates the fields in a clip and stacks them vertically.
#   Regardless of field order, even fields are on top.
#
#   Useful for applying spatial-temporal filters to interlaced
#   video.
#
# PARAMETERS:
#   "flip" : Pass true to flip the bottom field vertically.
#            Useful when dealing with spatial filters.
#            (Default: false)
#
# USAGE:
#   Should be used in conjunction with JDL_FoldFieldsVertical.
#
#   JDL_UnfoldFieldsVertical(true)
#   PixieDust()
#   JDL_FoldFieldsVertical(true)
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_UnfoldFieldsVertical(clip c, bool "flip")
{
    Assert(c.IsFrameBased(), "JDL_UnfoldFieldsVertical: clip must not have separated fields")
    flip = Default(flip, false)
    oldParity = c.GetParity()
    # c = c.IsFrameBased() ? c : c.Weave()
    c.AssumeTFF().SeparateFields().AssumeFrameBased()
    top = SelectEven()
    bottom = SelectOdd()
    StackVertical(top, flip ? bottom.FlipVertical()
    \                       : bottom)
    return (c.FrameCount() == 0)
    \      ? c
    \      : SetParity(oldParity)
}


# JDL_FoldFieldsVertical
#
#   Recombines the fields from a clip that resulted from calling
#   JDL_UnfoldFieldsVertical.  Undoes the work of JDL_UnfoldFieldsVertical.
#
# PARAMETERS:
#   "flip" : Pass true if the bottom field was flipped vertically with
#              JDL_UnfoldFieldsVertical.
#            (Default: false)
#
# USAGE:
#   See JDL_UnfoldFieldsVertical.
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_FoldFieldsVertical(clip c, bool "flip")
{
    Assert(c.IsFrameBased(), "JDL_FoldFieldsVertical: clip must not have separated fields")
    Assert(c.Height() % 2 == 0, "JDL_FoldFieldsVertical: unexpected frame height")
    flip = Default(flip, false)
    oldParity = c.GetParity()
    originalHeight = c.Height() / 2
    top = c.Crop(0, 0, c.Width(), originalHeight)
    bottom = c.Crop(0, originalHeight, c.Width(), originalHeight)
    bottom = flip ? bottom.FlipVertical() : bottom
    Interleave(top, bottom).AssumeFieldBased().AssumeTFF().Weave()
    return (c.FrameCount() == 0)
    \      ? c
    \      : SetParity(oldParity)
}


# JDL_InterlacedResize
#
#   Resizes interlaced material
#
# PARAMETERS:
#   w, h         : The desired width and height of the output clip.
#   "resizeFunc" : The resize function to use for interpolation.
#                  The function must have the signature:
#                    resizeFunc(clip c, int w, int h)
#                  (Default: "LanczosResize")
#
# USAGE:
#   If you wish to use a resize function that does not have the required
#   syntax, make a wrapper function.  For example:
#
#   function BicubicResizeWrapper(clip c, int w, int h)
#   {
#       return c.BicubicResize(w, h, b=0, c=0.75)
#   }
#
#   JDL_InterlacedResize(320, 240, "BicubicResizeWrapper")
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_InterlacedResize(clip c, int w, int h, string "resizeFunc")
{
    resizeFunc = Default(resizeFunc, "LanczosResize")
    c.JDL_SimpleBob()
    Apply(resizeFunc, last, w, h)
    JDL_Interlace()
    return last
}


# JDL_SimpleBob
#
#   A simplistic Bob function.  Losslessly preserves the original
#   scanlines.
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_SimpleBob(clip c)
{
    # Based on Mug Funky's explanation of Bob/BicubicResize's arguments.
    # <http://forum.doom9.org/showthread.php?p=588991#post588991>
    c.Bob(0, 0.5)

    # Preserve the parity of original clip (in case we want to reinterlace
    # later).
    return SetParity(c.GetParity())
}


# JDL_DupeField
#
#   Duplicates the specified field.
#
# PARAMETERS:
#   field : Pass true to duplicate the top field.
#           Pass false to duplicate the bottom field.
#
# REQUIRES:
#   jdl-util.avsi (SetParity)
#
function JDL_DupeField(clip c, bool field)
{
    parity = c.GetParity()
    c = c.JDL_SimpleBob()
    return (field == parity) ? c.SelectEven() : c.SelectOdd()
}


# JDL_Interlace
#
#   Combines frames from a progressive, frame-based clip to produce an
#   interlaced version at half the frame-rate.
#
#   (This discards half of the fields!)
#
function JDL_Interlace(clip c)
{
    Assert(c.IsFrameBased(), "JDL_Interlace: clip must not have separated fields")

    # Based on scharfis_brain's method.
    # <http://forum.doom9.org/showthread.php?p=582059#post582059>
    return (c.FrameCount() == 0)
    \      ? c.AssumeScaledFPS(1, 2)
    \      : c.SeparateFields().SelectEvery(4, 0, 3).Weave()
}
