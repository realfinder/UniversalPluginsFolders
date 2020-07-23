Autolevels 0.6 for Avisynth, Jan. 2011

Revisions 0.1-0.3 by Theodor Anschütz, Copyright 2007
Revisions 0.4-0.6 by Jim Battle

This code uses the DDigit library, by "StainlessS" et al
See autolevels.cpp source code for full revision history.
Built using Microsoft Visual C++ Express 2010 edition, on Windows XP SP3.

Function:

Sometimes a video source will need to be adjusted because it is too dark, or
too bright, or the contrast is too high or low, or the gamma value is wrong.
By looking at the histogram of the video stream, it is often evident that the
range of luma values of a video source is poorly distributed among the
possible range of luma.

The avisynth built-in filter called levels() can be used to remap the luma
value of all pixels to a more desirable distribution (or to intentionally
to a "bad" one to achieve some effect).  It is documented here:

    http://avisynth.org/mediawiki/Levels

A continuous range of values is montonically mapped to a different range.
levels() does it using this equation:

    output = [(input - input_low) / (input_high - input_low)] ^ (1/gamma)
           * (output_high - output_low) + output_low

In English, luma values less than or equal to input_low get mapped to 0.0 and
values greater or equal to input_high get mapped to 1.0, and everything
between is linearly interpolated.  This intermediate value is raised to a
power; note that 0.0 remains and 0.0 and 1.0 remains at 1.0, only values in
between are changed.  The pixel luma values then get mapped into the range of
output_low to output_high.

One shortcoming of levels() is that the mapping parameters must be manually
specified, which can be especially difficult as the input range often shifts
during a video due to varying lighting conditions.

The ColorYUV() filter has an "autogain=true" option which measures the luma
frame by frame and does a kind of levels() adjustment.  A disadvantage of
this approach is it can produce video that has sudden and unpleasant shifts
in the brightness.

The autolevels() filter averages luma statistics from the frames in the
vicinity of the current frame and uses that to decide how to set the
appropriate input_low, input_high, and optionally gamma.  It also offers a
number of optional parameters for controlling how this averaging is
performed.

Filter Interface:

Autolevels() syntax (don't be alarmed; the default is great for most of
them); some groups of parameters that operate together have been set off by
spaces to make the grouping obvious:

    Autolevels(clip,
               int filterRadius,        default: 5 frames on either side
               int sceneChgThresh,      default: 20
               string frameOverrides,   default: ""

               float gamma,             default: 1.0
               bool autogamma,          default: false
               float midpoint,          default: 0.5

               bool autolevel,          default: true

               int input_low,           default: measured by statistics
               int input_high,          default: measured by statistics
               int output_low,          default:  16 for yuv,   0 for rgb
               int output_high,         default: 235 for yuv, 255 for rgb

               bool coring,             default: false

               float ignore,            default: 1.0/256.0
               float ignore_low,        default: 1.0/256.0
               float ignore_high,       default: 1.0/256.0

               int border,              default: 0
               int border_l,            default: 0
               int border_r,            default: 0
               int border_t,            default: 0
               int border_b,            default: 0

               bool debug)              default: false

All parameters are optional.  The filter has a second interface:

    Autogamma(clip,
              ... same as before ...
             );

The only difference is that autogamma() has the parameter autogamma true by
default and autolevel false by default.

Parameters:

* filterRadius specifies how many frames before and after the current frame
  are used to average the amount of gain.  The default is 5.  The higher
  the frame right the larger this number should be.

* sceneChgThresh is the detection threshold for scene changes. This parameter
  takes values between 0 and 255; the default is 20.  When the min or max
  luma of consecutive frames changes by more than this amount, it is assumed
  to be caused by a scene change.  This information is used to prevent the
  rolling average to cross a scene boundary.  A smaller number makes the
  trigger more sensitive, at the cost of false positives.

* frameOverrides is a string parameter that allows special handling of certain
  frames.  It is a comma-separated list; each list entry is one of the letters
  {S, N, E}, followed by a frame number or frame range. A range is two frame
  numbers separated by a dash. Depending on the preceding letter code, the
  frame / frame range is treated as follows:

  S<frame>: Assume a scene start at <frame>
            (overrides scene change auto detection)

  N<frame> or N<start-end>:
    Assume there is no scene start at <frame> or frames <start> to <end>,
    resp. (overrides scene change auto detection)

  E<frame> or E<start-end>:
    Leave <frame> or frames <start> to <end> unchanged, resp.

* gamma is used to manually specify a gamma adjustment, and has the same
  meaning as the gamma parameter of the levels() filter.  Although the gamma
  correction is done at the time as the autolevels histogram stretching,
  logically it is as if the gamma is done after the histogram has been
  stretched.  The default value of gamma is 1.0, which means it has no effect.
  This parameter is ignored if the autogamma option is true.

* autogamma is a boolean flag; setting it to true causes the filter to
  estimate a gamma correction parameter, which is then applied after the
  any autolevel histogram adjustment.  This is done by computing the mean
  luma of the frame and then computing a gamma which will move the mean
  to the midpoint luma value.

  The midpoint is 0.5 by default, but can overridden by specifying a midpoint
  parameter value.  The value is normalized to 0.0 being minimum intensity and
  1.0 being the maximum intensity.  I find a value of 0.4 to typically be
  more pleasing than 0.5 in many cases.  This parameter is ignored unless
  autogamma is true.

* autolevel specifies whether the luma histogram stretching is to be performed
  or not.  This is parameter is useful if you want to use autogamma only
  without the preceding autolevel adjustment.

* input_low specifies the point in the luma range which corresponds to the
  blackest pixel; any pixels with a lower luma also map to black.
  autolevels() normally determines this value itself, but if this value is
  specified, it takes priority over the frame statistics.
  
* input_high specifies the point in the luma range which corresponds to the
  brightest pixel; any pixels with a greater luma map to the same color.
  autolevels() normally determines this value itself, but if this value is
  specified, it takes priority over the frame statistics.

* output_low specifies what the blackest pixel value is in the post-adjusted
  image.  It defaults to 16 for yuv images and 0 for rgb images.

* output_high specifies what the brightest pixel value is in the post-adjusted
  image.  It defaults to 235 for yuv images and 255 for rgb images.

* coring is another feature implemented to allow autolevels() to be a
  superset of the built-in filter levels().  Note, though, that coring
  defaults to true for levels(), while it defaults to false for autolevels(),
  to match the behavior of older versions of autolevels().

  This parameter is ignored for rgb video sources.

  Like levels(), if coring is true, input/output low/high parameters are
  applied after the 16..235 luma range has been mapped to 0..255 and before
  it has been mapped back.

  If input_low and input_high are not manually specified and are
  automatically determined by the autolevels algorithm, the front end
  remapping of the luma range for "coring" is ignored and the low cutoff of
  the histogram is mapped to 0.0 and the high cutoff is mapped to 1.0.

* ignore, ignore_low, and ignore_high are used to control how much of the
  low and high tails of the luma histogram are to be ignored when computing
  the image statistics.  In versions 0.4 and earlier, this was hardwired to
  be 1.0/256.0, or about 0.4%, of all pixels.  This remains the default for
  backwards compatibility.

  If "ignore" is set, it applies to both the high and low tails of the
  histogram; "ignore_low" can be used to set the fraction of pixels ignored
  on the low (dark) tail of the distribution, while "ignore_high" does the
  same for the high (bright) tail.  Values up to 0.45 are allowed, but
  anything above a few percent leads to very bad range clipping.

* By default, statistics are gathered over the entire image, and these
  statistics drive the autolevel and autogamma behavior.  The border
  parameters can be used to specify that a band of pixels on one or more sides
  of the image should not be included in the statistics.  Whether a border is
  specified or not, the entire image is always processed.  Specifying
  "border=N" indicates that the N pixels from the left, right, top, and bottom
  edges are to be ignored.  "border_l" specifies the zone on the left edge to
  ignore; "border_r" does the same for the right edge, "border_t" for the top
  edge, and "border_b" for the bottom edge.  If both "border" and a specified
  border, say "border_t" are specified, the larger value is used.

  This feature is useful if the edges of the frame contain defects or
  brightness rolloff that aren't representative of the image in whole and
  might adversely affect the algorithm.

* debug reports some statistics about the frame, and reports when a scene
  change has been detected.

Examples:

    autolevels()
    autolevels(filterRadius=8, sceneChgThresh=10, frameOverrides="E8400-8405,S62908,S63315,N8527-8540")
    autolevels(debug=true)
    autolevels(matrix="average")
    autolevels(sceneChgThresh=255)  [ effectively disables scene change logic ]
    autolevels(autolevel=false, autogamma=true)  [ autogamma only ]
    autolevels(ignore=1.0/500.0, gamma=1.5)
    autolevels(border=32)
    autogamma()

Future revisions may include:

  * add an equalization mode, perhaps allowing more than one possible target
    distribution (uniform, or gaussian)
  * make debug mode more informative
  * improved scene change detection: use mean statistics, or maybe histogram
    correlation, or maybe 2nd order statistics
  * detect scenes that should be kept dark (may not be easy to do)
