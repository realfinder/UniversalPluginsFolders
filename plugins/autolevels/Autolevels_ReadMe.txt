Autolevels 0.4 for Avisynth
Copyright 2007 Theodor Anschütz

Revisions 0.1, 0.2, 0.3 by Theodor Anschütz
Revision 0.4 by Jim Battle
DDigit library by "StainlessS" et al
See autolevels.cpp source code for full revision history.
Built using Microsoft Visual C++ Express 2010 edition, on Windows XP SP3.


This filter is an improvement of the ColorYUV filter's autogain feature.
Basically, it stretches the luma histogram to use the entire valid range.
Unlike ColorYUV, this filter averages the amount of "gain" over consecutive
frames to better handle flashes and to avoid flickering.

No averaging is done when a scene change is detected so no artificial fade
effect is introduced.

Syntax:

    Autolevels(int filterRadius,
	       int sceneChgThresh,
	       string excludeFrames,
	       string matrix,
	       bool debug)

All parameters are optional.

* filterRadius specifies how many frames before and after the current frame
  are used to average the amount of gain. The default is 5.

* sceneChgThresh is the detection threshold for scene changes. This parameter
  takes values between 0 and 255. The default is 5.

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

* matrix is used iff the source content is rgb.  it can have one of three
  values, the same ones used by the greyscale() filter:
     Rec709, Rec601, Average
  This controls how the rgb components are converted to luma when doing the
  luminance histogram.  The level adjustment on rgb pixels is a hack anyway,
  so this is mostly included for completeness.  Rec601 is the default.

* debug reports the current and average min/max luma, and indicates when a
  scene change has been detected.

Examples:

    Autolevels()
    Autolevels(filterRadius=8, sceneChgThresh=10, frameOverrides="E8400-8405,S62908,S63315,N8527-8540")
    Autolevels(debug=true)
    Autolevels(matrix="average")
    Autolevels(sceneChgThresh=255)  [ effectively disables scene change logic ]

Future revisions may include:

  * Fade detection
  * Debug mode will display more information (e.g. gain factor)
  * Improved scene change detection
  * Detect scenes that should be kept dark (may not be easy to do)
  * Option to change the luma cutoff
    (currently it is fixed at 1/256 and 255/256)
