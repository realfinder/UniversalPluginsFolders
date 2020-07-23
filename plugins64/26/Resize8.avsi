###### Resize8 v1.2        ######        by mawen1250        ######       2015.02.23       ######
###### Requirements: AviSynth v2.6+, RgTools 0.92.1 or Repair v1.0pre                      ######
###### Accept Y8, YV12, YV16, YV24, RGB24, RGB32 input, use AviSynth resizers for scaling  ######
###### Resize8() is the same as normal resizer with some extra features.                   ######
######     Chroma placement is correctly handled by it, while AviSynth resizers doesn't.   ######
###### Resize8_Separate() processes each plane's source position separately,               ######
######     mainly designed for fixing center shift caused by nnedi3, eedi3, eedi2, etc.    ######
######     Note that it doesn't correct chroma placement, so usually the result should be  ######
######     resized back to the original size, such as what many AA functions do.           ######
###### Adaptive anti-ringing algorithm is supported                                        ######
###### Scaling kernel for luma and chroma can be adjusted separately                       ######
######
###### All the parameters with "_c" represents U/V plane in YV12/YV16/YV24 or Alpha plane in RGB32.
###### The ones without "_c" represents Y plane in Y8/YV12/YV16/YV24 or R/G/B plane in RGB24/RGB32.


Function Resize8(clip input, int "target_width", int "target_height", float "src_left", float "src_top",
\                float "src_width", float "src_height",
\                string "kernel", string "kernel_c", float "a1", float "a2", float "a1_c", float "a2_c",
\                val "noring", val "noring_c", string "cplace", bool "Y", bool "U", bool "V", bool "Alpha")
{
    # Properties of input clip
    sCSP     = input.GetCSP()
    IsY8     = sCSP == "Y8"
    IsRGB    = LeftStr(sCSP, 3) == "RGB"
    oCSP     = IsY8 || IsRGB ? "YV24" : sCSP
    Assert(sCSP=="Y8" || sCSP=="YV12" || sCSP=="YV16" || sCSP=="YV24" || sCSP=="RGB24" || sCSP=="RGB32", """Resize8: only accept Y8, YV12, YV16, YV24, RGB24, RGB32 input""")
    
    sw       = input.Width ()
    sh       = input.Height()
    swc      = oCSP=="YV24" ? sw   : sw/2
    shc      = oCSP=="YV12" ? sh/2 : sh
    
    
    # Parameters for size transform
    ow       = Default(target_width,  sw)
    oh       = Default(target_height, sh)
    owc      = oCSP=="YV24" ? ow   : ow/2
    ohc      = oCSP=="YV12" ? oh/2 : oh
    Assert(!(oCSP=="YV16" && ow!=owc*2), """Resize8: width  of YV16 output clip must be MOD2!""")
    Assert(!(oCSP=="YV12" && ow!=owc*2), """Resize8: width  of YV12 output clip must be MOD2!""")
    Assert(!(oCSP=="YV12" && oh!=ohc*2), """Resize8: height of YV12 output clip must be MOD2!""")
    
    src_l    = Default(src_left,   0    )
    src_t    = Default(src_top,    0    )
    src_w    = Default(src_width,  sw   )
    src_h    = Default(src_height, sh   )
    
    src_w    = src_w<=0 ? sw-src_l+src_w : src_w
    src_h    = src_h<=0 ? sh-src_t+src_h : src_h
    src_lc   = oCSP=="YV24" ? src_l    : src_l/2.
    src_tc   = oCSP=="YV12" ? src_t/2. : src_t
    src_wc   = oCSP=="YV24" ? src_w    : src_w/2.
    src_hc   = oCSP=="YV12" ? src_h/2. : src_h
    
    
    # Process
    return Resize8_main(input, ow, oh, owc, ohc, src_l, src_t, src_lc, src_tc, src_w, src_h, src_wc, src_hc,
    \                   kernel, kernel_c, a1, a2, a1_c, a2_c, noring, noring_c, cplace, Y, U, V, Alpha)
}


Function Resize8_Separate(clip input, int "target_width", int "target_height", float "src_left", float "src_top",
\                float "src_width", float "src_height",
\                string "kernel", string "kernel_c", float "a1", float "a2", float "a1_c", float "a2_c",
\                val "noring", val "noring_c", bool "Y", bool "U", bool "V", bool "Alpha")
{
    # Properties of input clip
    sCSP     = input.GetCSP()
    IsY8     = sCSP == "Y8"
    IsRGB    = LeftStr(sCSP, 3) == "RGB"
    oCSP     = IsY8 || IsRGB ? "YV24" : sCSP
    Assert(sCSP=="Y8" || sCSP=="YV12" || sCSP=="YV16" || sCSP=="YV24" || sCSP=="RGB24" || sCSP=="RGB32", """Resize8: only accept Y8, YV12, YV16, YV24, RGB24, RGB32 input""")
    
    sw       = input.Width ()
    sh       = input.Height()
    swc      = oCSP=="YV24" ? sw   : sw/2
    shc      = oCSP=="YV12" ? sh/2 : sh
    
    
    # Parameters for size transform
    ow       = Default(target_width,  sw)
    oh       = Default(target_height, sh)
    owc      = oCSP=="YV24" ? ow   : ow/2
    ohc      = oCSP=="YV12" ? oh/2 : oh
    Assert(!(oCSP=="YV16" && ow!=owc*2), """Resize8: width  of YV16 output clip must be MOD2!""")
    Assert(!(oCSP=="YV12" && ow!=owc*2), """Resize8: width  of YV12 output clip must be MOD2!""")
    Assert(!(oCSP=="YV12" && oh!=ohc*2), """Resize8: height of YV12 output clip must be MOD2!""")
    
    src_l    = Default(src_left,   0    )
    src_t    = Default(src_top,    0    )
    src_w    = Default(src_width,  sw   )
    src_h    = Default(src_height, sh   )
    
    src_w    = src_w<=0 ? sw-src_l+src_w : src_w
    src_h    = src_h<=0 ? sh-src_t+src_h : src_h
    src_r    = sw - src_w - src_l
    src_b    = sh - src_h - src_t
    src_lc   = src_l
    src_tc   = src_t
    src_wc   = swc - src_l - src_r
    src_hc   = shc - src_t - src_b
    
    
    # Process
    return Resize8_main(input, ow, oh, owc, ohc, src_l, src_t, src_lc, src_tc, src_w, src_h, src_wc, src_hc,
    \                   kernel, kernel_c, a1, a2, a1_c, a2_c, noring, noring_c, "MPEG1", Y, U, V, Alpha)
}


Function Resize8_main(clip input, int "ow", int "oh", int "owc", int "ohc",
\                float "src_l", float "src_t", float "src_lc", float "src_tc",
\                float "src_w", float "src_h", float "src_wc", float "src_hc",
\                string "kernel", string "kernel_c", float "a1", float "a2", float "a1_c", float "a2_c",
\                val "noring", val "noring_c", string "cplace", bool "Y", bool "U", bool "V", bool "Alpha")
{
    # All the parameters with "_c" affects U/V plane in YV12/YV16/YV24 or Alpha plane in RGB32.
    # The ones without "_c" affects Y plane in Y8/YV12/YV16/YV24 or R/G/B plane in RGB24/RGB32.
    
    # Properties of input clip
    sCSP     = input.GetCSP()
    IsY8     = sCSP == "Y8"
    IsRGB    = LeftStr(sCSP, 3) == "RGB"
    oCSP     = IsY8 || IsRGB ? "YV24" : sCSP
    Assert(sCSP=="Y8" || sCSP=="YV12" || sCSP=="YV16" || sCSP=="YV24" || sCSP=="RGB24" || sCSP=="RGB32", """Resize8: only accept Y8, YV12, YV16, YV24, RGB24, RGB32 input""")
    
    sw       = input.Width ()
    sh       = input.Height()
    swc      = oCSP=="YV24" ? sw   : sw/2
    shc      = oCSP=="YV12" ? sh/2 : sh
    
    
    # Parameters for resampler
    yhratio  = float(ow ) / float(src_w )
    yvratio  = float(oh ) / float(src_h )
    chratio  = float(owc) / float(src_wc)
    cvratio  = float(ohc) / float(src_hc)
    yup      = yhratio * yvratio>1
    cup      = chratio * cvratio>1
    
    kernel   = Default(kernel,   yup ? "Lanczos4" : "Spline36")
    kernel_c = Default(kernel_c, cup ? "Lanczos"  : "Spline36")
    # "kernel" sets resizing kernel for luma, "kernel_c" sets resizing kernel for chroma
    # Supported kernels: Bicubic, Catmull-Rom, Hermite, Mitchell-Netravali, Robidoux, SoftCubic, SoftCubicXX (XX represents softness:[50-100])
    #                    Point, Bilinear, Gauss/Gaussian, Sinc
    #                    Blankman, Blankman2, Blankman3, Blankman4
    #                    Lanczos, Lanczos2, Lanczos3, Lanczos4
    #                    Spline16, Spline36, Spline64
    # By default, "Lanczos4" is set for luma upscaling, "Lanczos" is set for chroma upscaling, "Spline36" is set for luma/chroma downscaling.
    kernel   = RightStr(kernel  , 6) == "Resize" ? LeftStr(kernel  , StrLen(kernel  )-6) : kernel
    kernel_c = RightStr(kernel_c, 6) == "Resize" ? LeftStr(kernel_c, StrLen(kernel_c)-6) : kernel_c
    
    defa1    = Defined(a1)
    defa2    = Defined(a2)
    a1       = defa1 ? a1 : Resize8_undef()
    a2       = defa2 ? a2 : Resize8_undef()
    a1_c     = Defined(a1_c) ? a1_c : defa1 && kernel==kernel_c ? a1 : Resize8_undef()
    a2_c     = Defined(a2_c) ? a2_c : defa2 && kernel==kernel_c ? a2 : Resize8_undef()
    # "a1",   "a2",  sets parameters for resizer used in luma
    # "a1_c", "a2_c" sets parameters for resizer used in chroma
    # "a1" represents "b" and "a2" represents "c" for kernel "Bicubic"   (default: b = 1/3.,     c = 1/3.)
    # "a1" represents "taps" and "a2" do nothing  for kernel "Blackman"  (default: taps=4,   1<=taps<=100)
    # "a1" represents "taps" and "a2" do nothing  for kernel "Lanczos"   (default: taps=3,   1<=taps<=100)
    # "a1" represents "taps" and "a2" do nothing  for kernel "Sinc"      (default: taps=4,   1<=taps<= 20)
    # "a1" represents "p"    and "a2" do nothing  for kernel "Gauss"     (default:   p=30,   1<=  p <=100)
    # "a1" represents "soft" and "a2" do nothing  for kernel "SoftCubic" (default: soft=75, 50<=soft<=100)
    # for kernel "SoftCubicXX", "XX" represents "soft" and "a1"/"a2" do nothing
    # "a1" do nothing and "a2" do nothing for the rest kernels supported by Resize8:
    # "Catmull-Rom", "Hermite", "Mitchell-Netravali", "Robidoux", "Bilinear", "Point", "Spline16", "Spline36", "Spline64"
    
    
    # Parameters for anti-ringing algorithm
    nrkn     = kernel   == "Point" || kernel   == "Bilinear" || kernel   == "Gauss" || kernel   == "Gaussian" || kernel   == "Hermite" || LeftStr(kernel  , 9) == "SoftCubic"
    nrkn_c   = kernel_c == "Point" || kernel_c == "Bilinear" || kernel_c == "Gauss" || kernel_c == "Gaussian" || kernel_c == "Hermite" || LeftStr(kernel_c, 9) == "SoftCubic"
    noring   = Default(noring,   nrkn   ? False : True  )
    noring_c = Default(noring_c, nrkn_c ? False : noring)
    # "noring" & "noring_c" can be Bool or Float
    # By default, we don't use anti-ringing algorithm for kernels "Point","Bilinear","Gauss"/"Gaussian","Hermite","SoftCubic".
    # When "noring" or "noring_c" is True, adaptive anti-ringing is enabled, when no upscaling is applied, anti-ringing is also automatically disabled.
    # For the default kernel of   upscaling, kernel="Lanczos4"+noring=True is applied for luma, kernel_c="Lanczos"+noring_c=True is applied for chroma.
    # For the default kernel of downscaling, kernel="Spline36"+noring=True is applied for luma/chroma, but the adaptive anti-ringing will turn off anti-ringing.
    #
    # Use repair to remove ringing introduced from resizer
    # noring >= 1          : completely use non-ringing repaired clip
    # 0 < noring < 1       : noring is the weight of non-ringing repaired clip for merging with normally upscaled clip
    # noring <= 0 or False : do not use non-ringing repaired clip
    # noring == True       : adapt the weight of non-ringing repaired clip according to input and output resolution
    Assert(IsFloat(noring  ) || IsBool(noring  ), """Resize8: "noring"   should be either bool or float!""")
    Assert(IsFloat(noring_c) || IsBool(noring_c), """Resize8: "noring_c" should be either bool or float!""")
    
    
    # Parameters for colorspace
    cplace   = Default(cplace,   "MPEG2")
    # Placement of the chroma subsamples. Can be one of these strings:
    # "MPEG1": 4:2:0 subsampling used in MPEG-1. Chroma samples are located on the center of each group of 4 pixels.
    # "MPEG2": Subsampling used in MPEG-2 4:2:x. Chroma samples are located on the left pixel column of the group.
    
    Yt       = Default(Y,        True   )
    Ut       = Default(U,        True   )
    Vt       = Default(V,        True   )
    At       = Default(Alpha,    True   )
    # Control whether to process Y/U/V plane(or R/G/B/A plane for RGB24/RGB32 input)
    Ut       = IsY8 ? False : Ut
    Vt       = IsY8 ? False : Vt
    At       = sCSP=="RGB32" ? At : False
    
    
    # Chroma placement of MPEG-2 YV12(4:2:0) and YV16(4:2:2) is left-aligned,
    #     thus center-aligned resizer can cause chroma shift after scaling.
    # Positive value means left-shift/top-shift, negetive value means right-shift/bottom-shift.
    # chshifta = oCSP=="YV24" || cplace=="MPEG1" ? 0 : 0.25-0.25*chratio # Chroma horizontal shift after scaling
    # cvshifta = oCSP=="YV24" || cplace=="MPEG1" ? 0 : 0                 # Chroma vertical   shift after scaling
    # chshiftb = oCSP=="YV24" || cplace=="MPEG1" ? 0 : 0.25/chratio-0.25 # Chroma horizontal shift before scaling equivalent to that after scaling
    # cvshiftb = oCSP=="YV24" || cplace=="MPEG1" ? 0 : 0                 # Chroma vertical   shift before scaling equivalent to that after scaling
    
    # So we apply shift before scaling to fix the chroma shift
    chfix    = oCSP=="YV24" || cplace=="MPEG1" ? 0 : 0.25-0.25/chratio # Chroma horizontal shift fixing before scaling
    cvfix    = oCSP=="YV24" || cplace=="MPEG1" ? 0 : 0                 # Chroma vertical   shift fixing before scaling
    
    
    # Weight calculation of adaptive anti-ringing algorithm
    res_mul   = yhratio * yvratio
    res_mul   = min(max(res_mul  , 1), 2.25)
    nr_wght   = IsFloat(noring  ) ? noring
    \         : noring   == True  ? Spline(res_mul  , 1, 0, 2.25, 1, 3.5, 0, True)
    \         :                     0
    nr_wght   = min(max(nr_wght  , 0), 1)
    
    res_mul_c = chratio * cvratio
    res_mul_c = min(max(res_mul_c, 1), 2.25)
    nr_wght_c = IsFloat(noring_c) ? noring_c
    \         : noring_c == True  ? Spline(res_mul_c, 1, 0, 2.25, 1, 3.5, 0, True)
    \         :                     0
    nr_wght_c = min(max(nr_wght_c, 0), 1)
    
    
    # Apply resize
    IsY8 ? \
    Eval("""
        Ys   = input
        
        Yo   = Yt                   ? Ys."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , kernel  , a1  , a2  )+""" : NOP()
        
        Yg   = Yt && nr_wght   >  0 ? Ys."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , "Gauss" , 100       )+""" : NOP()
        
        Yr   = Yt && nr_wght   >  0 ? Yo.Resize8_Repair(Yg, 1, -1) : NOP()
        
        Ym   = Yt ?  nr_wght   == 1 ? Yr : nr_wght   >  0 ? Yo.Merge(Yr, nr_wght  ) : Yo : Ys.BlankClip(width=ow , height=oh , color_yuv=$808080)
        
        res  = Ym
    """) : \
    IsRGB ? \
    Eval("""
        As   = At ? input.ShowAlpha("Y8") : NOP()
        Rs   = input.ShowRed  ("Y8")
        Gs   = input.ShowGreen("Y8")
        Bs   = input.ShowBlue ("Y8")
        
        Ao   = At                   ? As."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , kernel_c, a1_c, a2_c)+""" : NOP()
        Ro   = Yt                   ? Rs."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , kernel  , a1  , a2  )+""" : NOP()
        Go   = Ut                   ? Gs."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , kernel  , a1  , a2  )+""" : NOP()
        Bo   = Vt                   ? Bs."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , kernel  , a1  , a2  )+""" : NOP()
        
        Ag   = At && nr_wght_c >  0 ? As."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , "Gauss" , 100       )+""" : NOP()
        Rg   = Yt && nr_wght   >  0 ? Rs."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , "Gauss" , 100       )+""" : NOP()
        Gg   = Ut && nr_wght   >  0 ? Gs."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , "Gauss" , 100       )+""" : NOP()
        Bg   = Vt && nr_wght   >  0 ? Bs."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , "Gauss" , 100       )+""" : NOP()
        
        Ar   = At && nr_wght_c >  0 ? Ao.Resize8_Repair(Ag, 1, -1) : NOP()
        Rr   = Yt && nr_wght   >  0 ? Ro.Resize8_Repair(Rg, 1, -1) : NOP()
        Gr   = Ut && nr_wght   >  0 ? Go.Resize8_Repair(Gg, 1, -1) : NOP()
        Br   = Vt && nr_wght   >  0 ? Bo.Resize8_Repair(Bg, 1, -1) : NOP()
        
        Am   = At ?  nr_wght_c == 1 ? Ar : nr_wght_c >  0 ? Ao.Merge(Ar, nr_wght_c) : Ao : NOP()
        Rm   = Yt ?  nr_wght   == 1 ? Rr : nr_wght   >  0 ? Ro.Merge(Rr, nr_wght  ) : Ro : Rs.BlankClip(width=ow , height=oh , color_yuv=$008080)
        Gm   = Ut ?  nr_wght   == 1 ? Gr : nr_wght   >  0 ? Go.Merge(Gr, nr_wght  ) : Go : Gs.BlankClip(width=ow , height=oh , color_yuv=$008080)
        Bm   = Vt ?  nr_wght   == 1 ? Br : nr_wght   >  0 ? Bo.Merge(Br, nr_wght  ) : Bo : Bs.BlankClip(width=ow , height=oh , color_yuv=$008080)
        
        res  = At ? MergeARGB(Am, Rm, Gm, Bm) : MergeRGB(Rm, Gm, Bm, sCSP)
    """) : \
    Eval("""
        Ys   = input.ConvertToY8()
        Us   = input.UtoY8()
        Vs   = input.VtoY8()
        
        Yo   = Yt                   ? Ys."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , kernel  , a1  , a2  )+""" : NOP()
        Uo   = Ut                   ? Us."""+Resize8_resstr(owc, ohc, src_lc+chfix, src_tc+cvfix, src_wc, src_hc, kernel_c, a1_c, a2_c)+""" : NOP()
        Vo   = Vt                   ? Vs."""+Resize8_resstr(owc, ohc, src_lc+chfix, src_tc+cvfix, src_wc, src_hc, kernel_c, a1_c, a2_c)+""" : NOP()
        
        Yg   = Yt && nr_wght   >  0 ? Ys."""+Resize8_resstr(ow , oh , src_l       , src_t       , src_w , src_h , "Gauss" , 100       )+""" : NOP()
        Ug   = Ut && nr_wght_c >  0 ? Us."""+Resize8_resstr(owc, ohc, src_lc+chfix, src_tc+cvfix, src_wc, src_hc, "Gauss" , 100       )+""" : NOP()
        Vg   = Vt && nr_wght_c >  0 ? Vs."""+Resize8_resstr(owc, ohc, src_lc+chfix, src_tc+cvfix, src_wc, src_hc, "Gauss" , 100       )+""" : NOP()
        
        Yr   = Yt && nr_wght   >  0 ? Yo.Resize8_Repair(Yg, 1, -1) : NOP()
        Ur   = Ut && nr_wght_c >  0 ? Uo.Resize8_Repair(Ug, 1, -1) : NOP()
        Vr   = Vt && nr_wght_c >  0 ? Vo.Resize8_Repair(Vg, 1, -1) : NOP()
        
        Ym   = Yt ?  nr_wght   == 1 ? Yr : nr_wght   >  0 ? Yo.Merge(Yr, nr_wght  ) : Yo : Ys.BlankClip(width=ow , height=oh , color_yuv=$808080)
        Um   = Ut ?  nr_wght_c == 1 ? Ur : nr_wght_c >  0 ? Uo.Merge(Ur, nr_wght_c) : Uo : Us.BlankClip(width=owc, height=ohc, color_yuv=$808080)
        Vm   = Vt ?  nr_wght_c == 1 ? Vr : nr_wght_c >  0 ? Vo.Merge(Vr, nr_wght_c) : Vo : Vs.BlankClip(width=owc, height=ohc, color_yuv=$808080)
        
        res  = YtoUV(Um, Vm, Ym)
    """)
    
    
    return res
}


Function Resize8_resstr(int "ow", int "oh", float "src_l", float "src_t", float "src_w", float "src_h",
\                      string "kernel", float "a1", float "a2")
{
    ow       = string(ow)
    oh       = string(oh)
    src_l    = string(src_l)
    src_t    = string(src_t)
    src_w    = string(src_w)
    src_h    = string(src_h)
    
    
    resstr   = kernel == "Catmull-Rom"           ? "BicubicResize ("+ow+", "+oh+", 0.0   , 0.5   , "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Hermite"               ? "BicubicResize ("+ow+", "+oh+", 0.0   , 0.0   , "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Mitchell-Netravali"    ? "BicubicResize ("+ow+", "+oh+", 1/3.  , 1/3.  , "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Robidoux"              ? "BicubicResize ("+ow+", "+oh+", 0.3782, 0.3109, "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Bicubic"               ? "BicubicResize ("+ow+", "+oh+", "+string(Default(a1, 1/3.))+", "+string(Default(a2, 1/3.))+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "SoftCubic"             ? "BicubicResize ("+ow+", "+oh+", "+string(Default(a1/100., 0.75))+", "+string(Default(1-a1/100., 0.25))+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "SoftCubic100"          ? "BicubicResize ("+ow+", "+oh+", 1.0   , 0.0   , "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : LeftStr(kernel, 9) == "SoftCubic" ? "BicubicResize ("+ow+", "+oh+", "+RightStr(kernel, 2)+"/100., 1-"+RightStr(kernel, 2)+"/100., "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Bilinear"              ? "BilinearResize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Blankman"              ? "BlackmanResize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", "+string(int(Default(a1,  4)))+")"
    \        : kernel == "Blankman2"             ? "BlackmanResize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", 2)"
    \        : kernel == "Blankman3"             ? "BlackmanResize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", 3)"
    \        : kernel == "Blankman4"             ? "BlackmanResize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", 4)"
    \        : kernel == "Gauss"                 ? "GaussResize   ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", "+string(int(Default(a1, 30)))+")"
    \        : kernel == "Gaussian"              ? "GaussResize   ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", "+string(int(Default(a1, 30)))+")"
    \        : kernel == "Lanczos"               ? "LanczosResize ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", "+string(int(Default(a1,  3)))+")"
    \        : kernel == "Lanczos2"              ? "LanczosResize ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", 2)"
    \        : kernel == "Lanczos3"              ? "LanczosResize ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", 3)"
    \        : kernel == "Lanczos4"              ? "Lanczos4Resize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Point"                 ? "PointResize   ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Sinc"                  ? "SincResize    ("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+", "+string(int(Default(a1,  4)))+")"
    \        : kernel == "Spline16"              ? "Spline16Resize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Spline36"              ? "Spline36Resize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        : kernel == "Spline64"              ? "Spline64Resize("+ow+", "+oh+", "+src_l+", "+src_t+", "+src_w+", "+src_h+")"
    \        :                                     "Unknown Kernel"
    Assert(resstr!="Unknown Kernel", """Resize8: Unsupported "kernel" or "kernel_c"!""")
    
    
    return resstr
}


Function Resize8_Repair(clip input, clip source, int "mode", int "modeU", int "modeV")
{
    try
    {
        return input.Repair(source, mode, modeU, modeV)
    }
    catch(error_msg)
    {
        return input.ConvertToYV12().Repair(source.ConvertToYV12(), mode, modeU, modeV).ConvertToY8()
    }
}


Function Resize8_undef() {}


Function GetCSP(clip c)
{
    return c.IsPlanar ? c.IsYV12 ? "YV12" :
    \                   c.IsYV16 ? "YV16" :
    \                   c.IsYV24 ? "YV24" : c.GetCSP_Y8_YV411() :
    \      c.IsYUY2   ? "YUY2"   :
    \      c.IsRGB32  ? "RGB32"  :
    \      c.IsRGB24  ? "RGB24"  : "Unknown"
    
    
    Function GetCSP_Y8_YV411(clip c)
    {
        try
        {
            c.UtoY()
            csp = "YV411"
        }
        catch ( error_msg )
        {
            csp = "Y8"
        }
        
        return csp
    }
}
