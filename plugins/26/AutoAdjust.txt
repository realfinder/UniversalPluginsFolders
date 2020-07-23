
  +---------------------------------------------------------------------------------+
  |                                                                                 |
  |                    Automatic adjustement plugin: AutoAdjust()                   |
  |                                                                                 |
  |                               v2.60 by "LaTo INV."                              |
  |                                                                                 |
  |                                 15 November 2015                                |
  |                                                                                 |
  +---------------------------------------------------------------------------------+



      I.    DESCRIPTION
      II.   DISCLAIMER
      III.  INSTALLATION
      IV.   REQUIREMENTS
      V.    MULTITHREADING
      VI.   USAGE
      VII.  GENERAL SETTINGS
      VIII. AUTOGAIN SETTINGS
      IX.   AUTOBALANCE SETTINGS
      X.    CHANGELOG



 I. DESCRIPTION :
 ================

  AutoAdjust is an automatic adjustement filter. It calculates statistics of clip,
  stabilizes them temporally and uses them to adjust luminance gain & color balance.

  AutoAdjust have a smoothing & dithering algorithm to avoid banding issue.
  Calculations are made in 32bits float to avoid rounding errors and
  are internally multithreaded and SSE2/AVX2 optimized.

  For manual adjustments, see all plugins in "SmoothAdjust" package.



 II. DISCLAIMER :
 ================

  This program is free for non-commercial use only and must be distributed
  in its original form without any modification, including this documentation file.
  This program is provided as-is in the hope it will be useful but 
  without any warranty, including any hypothetical damages or issues.

  The official home page is "http://forum.doom9.org/showthread.php?t=167573",
  it always contains the latest version of this program.
  This page acts as the official support center, also the author is reachable
  through his member page: "http://forum.doom9.org/member.php?u=131032".

  This plugin has required a lot of work and much coding hours, so if you like
  it and feel the need to reward or inspire the author then please consider donating.
  Donations are a fast, easy and secure operation through Paypal: simply follow the
  link into the "Donate.url" shortcut (you do not need a Paypal account to donate).
  All donations will be very useful and I thank in advance all the generous people,
  also if you are on the doom9's forum please specify your nickname when donating.



 III. INSTALLATION :
 ===================

  There are different versions of AutoAdjust to suit all installations of Avisynth.
   - x86 builds are for Avisynth 32bits
   - x64 builds are for Avisynth 64bits



 IV. REQUIREMENTS :
 ==================

  - Avisynth v2.6.x or Avisynth Plus
  - YUV Planar (Y8, YV411, YV12, YV16, YV24)
  - 8bits or 16bits (MSB/LSB)



 V. MULTITHREADING :
 ===================
  AutoAdjust is internally multithreaded with official Avisynth version. 
  If AvisynthPlus or AvisynthMT is detected, internal multithreading is automatically disabled
  even if external multithreading isn't used (this can be reactivated in parameters).

  AutoAdjust is designed to work with external multithreading, so fastest MT mode can be used.
  With AvisynthPlus, this plugin is a MT_NICE_FILTER (automatic register, no need to call SetFilterMtMode).
  With AvisynthMT, SetMtMode(1) must be called before AutoAdjust.



 VI. USAGE :
 ===========

    AutoAdjust ( [clip], external_clip,
                 auto_gain,
                 dark_limit, bright_limit, gamma_limit, 
                 dark_exclude, bright_exclude, 
                 gain_mode, chroma_process, avg_safety,
                 input_tv, output_tv,
                 auto_balance,
                 chroma_limit, balance_str,
                 scd_threshold, temporal_radius, change_status,
                 use_interp, use_dither,
                 high_quality, high_bitdepth, 
                 threads_count, asm_opt,
                 debug_view )



 VII. GENERAL SETTINGS :
 =======================

    external_clip [default: none]
    -----------------------------
     Use external analyze clip to retrieve clip's statistics
      --> EXAMPLE: black borders need to be cropped before analyze of the clip
                   " src = last
                     crp = src.crop(xx,xx,xx,xx)
                     AutoAdjust(src, external_clip = crp) "

    scd_threshold [default: 12]
    ---------------------------
     Threshold for scenechange detection [useful range: 8~16]
      0   = all frames are detected as scene change
      100 = no scene change are detected

    temporal_radius [default: 20]
    -----------------------------
     Radius for temporal stabilization in each direction [useful range: 10~30]
      0  = no temporal averaging
      xx = number of frames used in averaging

    change_status [default: "empty"]
    --------------------------------
     Override the scenechange detection algorithm
      --> EXAMPLES: - "100"          = force scenechange at frame 100
                    - "!200-300"     = force no scenechange at each frame between 200~300
                    - "!400;500-600" = force no scenechange at frame 400
                                     & force scenechange at each frame between 500~600


    use_interp [default: true]
    --------------------------
     Use histogram smoothing

    use_dither [default: true]
    --------------------------
     Use output dithering

    high_quality [default: false]
    -----------------------------
     Use high quality interpolation (slower)

    high_bitdepth [default: false]
    ------------------------------
     Use stacked 16 bits clips


    threads_count [default: 0]
    --------------------------
     Number of internal threads
      0  = automatic choice  [=cores in Avs2.6 and =1 in Avs+/AvsMT]
      xx = number of threads [max = 16]

    asm_opt [default: 0]
    --------------------
     Use ASM optimization when available
      0 = automatic choice
      1 = use C code
      2 = use SSE2 code
      3 = use AVX2 code


    debug_view [default: false]
    ---------------------------
     Show the debug view at fullscreen resolution



 VIII. AUTOGAIN SETTINGS :
 =========================

    auto_gain [default: false]
    --------------------------
     Enable automatic luminance gain


    dark_limit [default: 1.50]
    --------------------------
     Amount of allowed change for dark pixels
      1.0  = no gain
      10.0 = no limit

    bright_limit [default: 1.50]
    ----------------------------
     Amount of allowed change for bright pixels
      1.0  = no gain
      10.0 = no limit

    gamma_limit [default: 1.25]
    ---------------------------
     Amount of allowed change for gamma processing
      1.0  = no gain
      10.0 = no limit


    dark_exclude [default: 0.50]
    ----------------------------
     Amount of excluded darkest pixels in "mimimum" calculation (in percentile of pixels)
      0.0 = no excluded pixels
      1.0 = 1% of excluded pixels

    bright_exclude [default: 0.50]
    ------------------------------
     Amount of excluded brightest pixels in "maximum" calculation (in percentile of pixels)
      0.0 = no excluded pixels
      1.0 = 1% of excluded pixels


    gain_mode [default: 0]
    ----------------------
     Gain adjustement mode
      0 = contrast expansion
      1 = levels adjustement

    chroma_process [default: 100]
    -----------------------------
     Amount of chroma processing
      0   = no change
      200 = maximum change

    avg_safety [default: 0.25]
    --------------------------
     Safety of the min/max averaging system between frames
      0.0 = more stable
      1.0 = more conservative
   

    input_tv [default: true]
    ------------------------
     Enable input tv range

    output_tv [default: true]
    -------------------------
     Enable output tv range



 IX. AUTOBALANCE SETTINGS :
 ==========================

    auto_balance [default: false]
    -----------------------------
     Enable automatic color balance


    chroma_limit [default: 1.05]
    ----------------------------
     Amount of allowed change for chroma pixels
      1.0 = no balance
      2.0 = no limit

    balance_str [default: 0.75]
    ---------------------------
     Strength of the balance adjustement
      0.0 = no balance
      1.0 = full balance
   


 X. CHANGELOG :
 ==============

  - v2.60: updated for Avs v2.6.0 final
           fixed AVX2 crash with Win7 without SP1

  - v2.50: fixed crash with external_clip
           fixed chroma processing bug
           removed temporal_radius=-1
           reintroduced internal caching

  - v2.40: optimized frame access & frame cache
           fixed potential freeze with very slow source filter

  - v2.20: optimized memory usage with very long clip
           fixed crash with ffdshow_source() and external MT

  - v2.00: dropped Avs v2.5.x support
           added AVX2 code (40% faster)
           modified plugin to be thread-safe (MT_NICE_FILTER)
           removed internal caching
           added frame cache hints
           improved debug_view

  - v1.90: changed name of plugin & parameters
           added color balance
           added C version
           fixed regression from v1.75 (bug at scenechange)

  - v1.75: added avg_safety parameter
           fixed a minor bug in temporal averaging
           tweaked multi-threading code

  - v1.60: split 'tv_range' into 'input_tv' & 'output_tv'
           fixed possible freeze in MT code
           added explicit error messages

  - v1.45: fixed bugs inside multi-threading code
           removed user32 dependency
           added AVX2 detection (for future opt)

  - v1.40: used new C++11 features
           rewritten multi-threading (native)
           speed optimization (10% faster)
           exception-safe code
           added a high quality interpolation mode
           improved core algorithm
           fixed various little things

  - v1.02: fixed minor things & bugs
           dropped ICL builds support

  - v1.00: first stable release

