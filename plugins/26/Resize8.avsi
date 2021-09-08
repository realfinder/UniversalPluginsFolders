# ===============================================================================
# ===============================================================================
# ===============================================================================
#
#   Updated by Hello_Hello 2021.09.07
#   https://forum.doom9.org/showthread.php?t=183057
#
#   Resize8 by mawen1250 2015.02.23
#   http://avisynth.nl/index.php/Resize8
#
# ===============================================================================
#
#   Supports all Avisynth+ colorspaces, bit depths & native resizing kernels.
#   It should support any resizer with the same width, height and named
#   cropping arguments as the native AviSynth resizers.
#
#   Therefore the following could be described as "known" resizers
#   rather than "supported" as such.
#
#   ResampleMT (multithreaded).
#   https://github.com/jpsdr/ResampleMT
#   JincResize (multithreaded)
#   http://avisynth.nl/index.php/JincResize
#   SplineResize (limited to 8 bit video, not multithreaded)
#   http://avisynth.nl/index.php/External_filters#Resizers
#
#   Requirements for the updated version:
#
#   AviSynth+ Revision > 2294 for HBD and YUVA support.
#   AviSynth+ Revision <= 2294 without HBD and YUVA support.
#   AviSynth 2.60 or 2.61 without HBD and YUVA support.
#   RgTools http://avisynth.nl/index.php/RgTools
#
# ===============================================================================
# ===============================================================================
# ===============================================================================

function Resize8(clip source, int "target_width", int "target_height",
\                float "src_left", float "src_top", float "src_width", float "src_height",
\                string "kernel", string "kernel_c", float "a1", float "a2", float "a1_c", float "a2_c",
\                val "noring", val "noring_c", string "cplace", bool "Y", bool "U", bool "V", bool "alpha",
\                bool "chroma", string "rstr", string "rstr_c", bool "separate", bool "show")  {

# ===============================================================================

    AvsVerStrLC = LCase(VersionString())
    IsAvsPlus   = (FindStr(AvsVerStrLC, "avisynth+") > 0)
    IsAvsNeo    = (FindStr(AvsVerStrLC, "avisynth neo") > 0)
    AvsStrNumA  = IsAvsPlus || IsAvsNeo ? FindStr(AvsVerStrLC, "(r") + 2 : 0
    AvsStrNumB  = IsAvsPlus || IsAvsNeo ? FindStr(AvsVerStrLC, ",") : 0
    AvsStrNumC  = (AvsStrNumB > AvsStrNumA) ? AvsStrNumB - AvsStrNumA : undefined()
    AvsBuildNum = (AvsStrNumA > 2) ? int(value(MidStr(AvsVerStrLC, AvsStrNumA, AvsStrNumC))) : 0
    IsAvsHBD    = (AvsBuildNum > 2294)

    R_8   = " Resize8 " + chr(10)

# ===============================================================================
#   Source properties
# ===============================================================================

    pixtype = PixelType(source)
    SourceBits = IsAvsHBD ? BitsPerComponent(source) : 8

    sCSP = IsYUY2(source)  ? "YUY2" :
    \      IsYV411(source) ? "411"  :
    \      (IsAvsHBD && IsY(source))   || IsY8(source)   ? "000" :
    \      (IsAvsHBD && Is420(source)) || IsYV12(source) ? "420" :
    \      (IsAvsHBD && Is422(source)) || IsYV16(source) ? "422" :
    \      (IsAvsHBD && Is444(source)) || IsYV24(source) ? "444" :
    \      IsRGB24(source) ? "RGB24" :
    \      IsRGB32(source) ? "RGB32" :
    \      IsAvsHBD && IsRGB48(source) ? "RGB48" :
    \      IsAvsHBD && IsRGB64(source) ? "RGB64" :
    \      IsAvsHBD && IsPlanarRGB(source)  ? "RGBP"  :
    \      IsAvsHBD && IsPlanarRGBA(source) ? "RGBAP" :
    \      assert(false, R_8 + """ """" + pixtype + """" +
    \             is an unsupported color format """ + chr(10))

    IsAlpha = (IsAvsHBD && HasAlpha(source)) || (sCSP == "RGB32")
    IsRGBSource = (LeftStr(sCSP, 3) == "RGB")
    Sub444 = (sCSP == "444") || IsRGBSource     || (sCSP == "000")
    Sub42x = (sCSP == "422") || (sCSP == "420") || (sCSP == "YUY2")
    Sub420 = (sCSP == "420")
    Sub411 = (sCSP == "411")
    Sub000 = (sCSP == "000")

    sw  = width(source)
    sh  = height(source)
    swc = Sub444 ? sw : sw / (Sub42x ? 2 : 4)
    shc = Sub420 ? sh / 2 : sh

    src_l = default(src_left, 0)
    src_t = default(src_top, 0)
    src_w = default(src_width, sw)
    src_h = default(src_height, sh)
    src_w = (src_w <= 0) ? sw - src_l + src_w : src_w
    src_h = (src_h <= 0) ? sh - src_t + src_h : src_h

# ===============================================================================
#   Parameters for resizing
# ===============================================================================

    separate = default(separate, false)

    ow = default(target_width, sw)
    oh = default(target_height, sh)
    owc = Sub444 ? ow : ow / (Sub42x ? 2 : 4)
    ohc = Sub420 ? oh / 2 : oh

    assert(!Sub411 || (ow == (owc * 4)),
    \     R_8 + " " + pixtype + " output width must be MOD4 " + chr(10))
    assert(!Sub42x || (ow == (owc * 2)),
    \     R_8 + " " + pixtype + " output width must be MOD2 " + chr(10))
    assert(!Sub420 || (oh == (ohc * 2)),
    \     R_8 + " " + pixtype + " output height must be MOD2 " + chr(10))

    !Separate ? Eval("""

    src_lc = Sub444 ? src_l : src_l / (Sub42x ? 2 : 4)
    src_tc = Sub420 ? src_t / 2 : src_t
    src_wc = Sub444 ? src_w : src_w / (Sub42x ? 2 : 4)
    src_hc = Sub420 ? src_h / 2 : src_h

    """) : Eval("""

    src_r  = sw - src_w - src_l
    src_b  = sh - src_h - src_t
    src_lc = src_l
    src_tc = src_t
    src_wc = swc - src_l - src_r
    src_hc = shc - src_t - src_b

    """)

    ratio_w  = float(ow) / float(src_w)
    ratio_h  = float(oh) / float(src_h)
    ratio_wc = float(owc) / float(src_wc)
    ratio_hc = float(ohc) / float(src_hc)
    IsLup    = ((ratio_w * ratio_h) >= 1)
    IsCup    = ((ratio_wc * ratio_hc) >= 1)

# ===============================================================================
#   Determine the resizing kernel
# ===============================================================================

    IsAvsHBD ? eval(""" IsMTResize=FunctionExists("Spline36ResizeMT") """) : eval("""
    try{ test=source.Spline36ResizeMT(640,480) IsMTResize=true }catch(err){ IsMTResize=false } """)

    LumaU = (R8_Luma_UpScale() == "") ?
    \       (IsMTResize ? "Lanczos4ResizeMT" : "Lanczos4Resize") : R8_Luma_UpScale()
    LumaD = (R8_Luma_DownScale() == "") ?
    \       (IsMTResize ? "Spline36ResizeMT" : "Spline36Resize") : R8_Luma_DownScale()
    ChroU = (R8_Chroma_UpScale() == "") ?
    \       (IsMTResize ? "LanczosResizeMT"  : "LanczosResize")  : R8_Chroma_UpScale()
    ChroD = (R8_Chroma_DownScale() == "") ?
    \       (IsMTResize ? "Spline36ResizeMT" : "Spline36Resize") : R8_Chroma_DownScale()

    IsKl = defined(kernel)
    IsKc = defined(kernel_c)
    Kl = default(kernel, IsLup ? LumaU : LumaD)
    Kc = default(kernel_c, IsKl ? kernel : IsCup ? ChroU : ChroD)

    original_Kl = Kl
    original_Kc = Kc

    HasResizeMT_Kl = (RightStr(Kl, 8) == "ResizeMT") || (RightStr(Kl, 8) == "MTResize")
    HasResizeMT_Kc = (RightStr(Kc, 8) == "ResizeMT") || (RightStr(Kc, 8) == "MTResize")
    HasMT_Kl       = !HasResizeMT_Kl && (RightStr(Kl, 2) == "MT")
    HasMT_Kc       = !HasResizeMT_Kc && (RightStr(Kc, 2) == "MT")

    Kl = HasResizeMT_Kl ? LeftStr(Kl, StrLen(Kl) - 8) :
    \    (RightStr(Kl, 6) == "Resize") ? LeftStr(Kl, StrLen(Kl) - 6) :
    \    HasMT_Kl ? LeftStr(Kl, StrLen(Kl) - 2) : Kl
    Kc = HasResizeMT_Kc ? LeftStr(Kc, StrLen(Kc) - 8) :
    \    (RightStr(Kc, 6) == "Resize") ? LeftStr(Kc, StrLen(Kc) - 6) :
    \    HasMT_Kc ? LeftStr(Kc, StrLen(Kc) - 2) : Kc

    assert((((LeftStr(Kl, 9) != "SoftCubic") || (StrLen(Kl) < 10) || (Kl == "SoftCubicXX") ||
    \      (Kl == "SoftCubic100") || (Kl == "SoftCubicMT")) ||
    \      (0 < value(RightStr(Kl, StrLen(Kl) - 9)) <= 100)) &&
    \      (((LeftStr(Kc, 9) != "SoftCubic") || (StrLen(Kc) < 10) || (Kc == "SoftCubicXX") ||
    \      (Kc == "SoftCubic100") || (Kc == "SoftCubicMT")) ||
    \      (0 < value(RightStr(Kc, StrLen(Kc) - 9)) <= 100)),
    \      R_8 + """ When replacing "XX" in SoftCubicXX with an integer """ + chr(10) +
    \      """ "XX" must be greater than zero, & less than or equal to 100 """ + chr(10))

# ===============================================================================
#   Add the appropriate resizer arguments
# ===============================================================================

    IsA1  = defined(a1)
    IsA2  = defined(a2)
    IsA1c = defined(a1_c)
    IsA2c = defined(a2_c)

    arg1_Kl = (Kl == "Catmull-Rom")        ? ", b=0.0, c=0.5" :
    \         (Kl == "Hermite")            ? ", b=0.0, c=0.0" :
    \         (Kl == "Mitchell-Netravali") ? ", b=1.0/3.0, c=1.0/3.0" :
    \         (Kl == "Robidoux")           ? ", b=0.3782, c=0.3109" :
    \         (Kl == "SoftCubic")          ? ", b="+string(default(a1,75)/100.0) +
    \                                        ", c="+string(1.0-(default(a1,75)/100.0)) :
    \         (Kl == "SoftCubic100")       ? ", b=1.0, c=0.0" :
    \         (Kl == "SoftCubicXX")        ? ", b=0.75, c=0.25" :
    \         (LeftStr(Kl,9)=="SoftCubic") ? ", b="+RightStr(Kl,StrLen(Kl)-9)+"/100.0" +
    \                                        ", c=1.0-("+RightStr(Kl,StrLen(Kl)-9)+"/100.0)" :
    \         (Kl == "Bicubic")            ? (IsA1?", b="+string(a1):"") :
    \         (Kl == "Bilinear")           ? "" :
    \         (Kl == "Blankman")           ? (IsA1?", taps="+string(int(a1)):"") :
    \         (Kl == "Blankman2")          ? ", taps=2" :
    \         (Kl == "Blankman3")          ? ", taps=3" :
    \         (Kl == "Blankman4")          ? ", taps=4" :
    \         (Kl == "Gauss")              ? (IsA1?", p="+string(a1):"") :
    \         (Kl == "Jinc")               ? (IsA1?", tap="+string(int(a1)):"") :
    \         (Kl == "Jinc36")             ? "" :
    \         (Kl == "Jinc64")             ? "" :
    \         (Kl == "Jinc144")            ? "" :
    \         (Kl == "Jinc256")            ? "" :
    \         (Kl == "Lanczos")            ? (IsA1?", taps="+string(int(a1)):"") :
    \         (Kl == "Lanczos2")           ? ", taps=2" :
    \         (Kl == "Lanczos3")           ? ", taps=3" :
    \         (Kl == "Lanczos4")           ? "" :
    \         (Kl == "Point")              ? "" :
    \         (Kl == "Sinc")               ? (IsA1?", taps="+string(int(a1)):"") :
    \         (Kl == "SinPow")             ? (IsA1?", p="+string(a1):"") :
    \         (Kl == "SincLin2")           ? (IsA1?", taps="+string(int(a1)):"") :
    \         (Kl == "Spline")             ? (IsA1?", taps="+string(int(a1)):"") :
    \         (Kl == "Spline16")           ? "" :
    \         (Kl == "Spline36")           ? "" :
    \         (Kl == "Spline64")           ? "" :
    \         (Kl == "Spline100")          ? "" :
    \         (Kl == "Spline144")          ? "" :
    \         (Kl == "UserDefined2")       ? (IsA1?", b="+string(a1):"") :
    \         "unKnown"

    arg2_Kl = (Kl == "Bicubic")            ? (IsA2?", c="+string(a2):"") :
    \         (Kl == "Jinc")               ? (IsA2?", blur="+string(a2):"") :
    \         (Kl == "UserDefined2")       ? (IsA2?", c="+string(a2):"") : ""

# -------------------------------------------------------------------------------

    arg1_Kc = !IsA1c && IsA1 && (Kl == Kc) ? arg1_Kl :
    \         (Kc == "Catmull-Rom")        ? ", b=0.0, c=0.5" :
    \         (Kc == "Hermite")            ? ", b=0.0, c=0.0" :
    \         (Kc == "Mitchell-Netravali") ? ", b=1.0/3.0, c=1.0/3.0" :
    \         (Kc == "Robidoux")           ? ", b=0.3782, c=0.3109" :
    \         (Kc == "SoftCubic")          ? ", b="+string(default(a1_c,75)/100.0) +
    \                                        ", c="+string(1.0-(default(a1_c,75)/100.0)) :
    \         (Kc == "SoftCubic100")       ? ", b=1.0, c=0.0" :
    \         (Kc == "SoftCubicXX")        ? ", b=0.75, c=0.25" :
    \         (LeftStr(Kc,9)=="SoftCubic") ? ", b="+RightStr(Kc,StrLen(Kc)-9)+"/100.0" +
    \                                        ", c=1.0-("+RightStr(Kc,StrLen(Kc)-9)+"/100.0)" :
    \         (Kc == "Bicubic")            ? (IsA1c?", b="+string(a1_c):"") :
    \         (Kc == "Bilinear")           ? "" :
    \         (Kc == "Blankman")           ? (IsA1c?", taps="+string(int(a1_c)):"") :
    \         (Kc == "Blankman2")          ? ", taps=2" :
    \         (Kc == "Blankman3")          ? ", taps=3" :
    \         (Kc == "Blankman4")          ? ", taps=4" :
    \         (Kc == "Gauss")              ? (IsA1c?", p="+string(a1_c):"") :
    \         (Kc == "Jinc")               ? (IsA1c?", tap="+string(int(a1_c)):"") :
    \         (Kc == "Jinc36")             ? "" :
    \         (Kc == "Jinc64")             ? "" :
    \         (Kc == "Jinc144")            ? "" :
    \         (Kc == "Jinc256")            ? "" :
    \         (Kc == "Lanczos")            ? (IsA1c?", taps="+string(int(a1_c)):"") :
    \         (Kc == "Lanczos2")           ? ", taps=2" :
    \         (Kc == "Lanczos3")           ? ", taps=3" :
    \         (Kc == "Lanczos4")           ? "" :
    \         (Kc == "Point")              ? "" :
    \         (Kc == "Sinc")               ? (IsA1c?", taps="+string(int(a1_c)):"") :
    \         (Kc == "SinPow")             ? (IsA1c?", p="+string(a1_c):"") :
    \         (Kc == "SincLin2")           ? (IsA1c?", taps="+string(int(a1_c)):"") :
    \         (Kc == "Spline")             ? (IsA1c?", taps="+string(int(a1_c)):"") :
    \         (Kc == "Spline16")           ? "" :
    \         (Kc == "Spline36")           ? "" :
    \         (Kc == "Spline64")           ? "" :
    \         (Kc == "Spline100")          ? "" :
    \         (Kc == "Spline144")          ? "" :
    \         (Kc == "UserDefined2")       ? (IsA1c?", b="+string(a1_c):"") :
    \         "unKnown"

    arg2_Kc = !IsA2c && IsA2 && (Kl == Kc) ? arg2_Kl :
    \         (Kc == "Bicubic")            ? (IsA2c?", c="+string(a2_c):"") :
    \         (Kc == "Jinc")               ? (IsA2c?", blur="+string(a2_c):"") :
    \         (Kc == "UserDefined2")       ? (IsA2c?", c="+string(a2_c):"") : ""

    unKnown_Kl = (arg1_Kl == "unKnown")
    unKnown_Kc = (arg1_Kc == "unKnown")
    arg1_Kl = (arg1_Kl == "unKnown") ? "" : (arg1_Kl != "") ? arg1_Kl : ""
    arg1_Kc = (arg1_Kc == "unKnown") ? "" : (arg1_Kc != "") ? arg1_Kc : ""

# ===============================================================================
#   Restore full resizer names
# ===============================================================================

    Kl = (Kl == "Catmull-Rom") || (Kl == "Hermite") || (Kl == "Mitchell-Netravali") ||
    \    (Kl == "Robidoux") || (LeftStr(Kl, 9) == "SoftCubic") ? "Bicubic" :
    \    (LeftStr(Kl, 8) == "Blackman") ? "Blackman" :
    \    (Kl == "Lanczos2") || (Kl == "Lanczos3") ? "Lanczos" : Kl

    Kc = (Kc == "Catmull-Rom") || (Kc == "Hermite") || (Kc == "Mitchell-Netravali") ||
    \    (Kc == "Robidoux") || (LeftStr(Kc, 9) == "SoftCubic") ? "Bicubic" :
    \    (LeftStr(Kc, 8) == "Blackman") ? "Blackman" :
    \    (Kc == "Lanczos2") || (Kc == "Lanczos3") ? "Lanczos" : Kc

    resizer_Kl = unKnown_Kl ? original_Kl : 
    \            Kl + (!HasResizeMT_Kl && !HasMT_Kl ? "Resize" : "ResizeMT")
    resizer_Kc = unKnown_Kc ? original_Kc :
    \            Kc + (!HasResizeMT_Kc && !HasMT_Kc ? "Resize" : "ResizeMT")

# ===============================================================================
#   Configure rstr & rstr_c
# ===============================================================================

    strLumaU = IsKl ? "" : R8_Luma_UpScale_rstr()
    strLumaD = IsKl ? "" : R8_Luma_DownScale_rstr()
    strChroU = IsKl || IsKc ? "" : R8_Chroma_UpScale_rstr()
    strChroD = IsKl || IsKc ? "" : R8_Chroma_DownScale_rstr()

    IsRstr = defined(rstr)
    rstr   = default(rstr, IsLup ? strLumaU : strLumaD)

    rstr_c = default(rstr_c, IsRstr && (resizer_Kl == resizer_Kc) ? rstr :
    \        IsCup ? strChroU : strChroD)

    rstr   = (rstr != "")   ? ", " + rstr   : ""
    rstr_c = (rstr_c != "") ? ", " + rstr_c : ""

# ===============================================================================
#   Chroma crop before scaling to prevent shift
# ===============================================================================

    cplace = default(cplace, !separate ? "mpeg2" : "mpeg1")
    IsM1 = (cplace == "mpeg1")

    # Chroma placement of MPEG2-YV12(4:2:0), YUY2(4:2:2), YV16(4:2:2) and
    # YV11(4:1:1) is left-aligned, thus center-aligned resizer can cause
    # chroma shift after scaling.
    # Positive value means left-shift / top-shift
    # Negetive value means right-shift / bottom-shift.
    #
    # Chroma horizontal shift after scaling.
    # chshifta = Sub444 || IsM1 ? 0.0 :
    # \          Sub42x ? 0.25 - (0.25 * (owc / src_wc)) :
    # \          Sub411 ? 0.375 - (0.375 * (owc / src_wc)) : 0.0
    # Chroma horizontal shift before scaling equivalent to that after scaling.
    # chshiftb = Sub444 || IsM1 ? 0.0 :
    # chshiftb = Sub42x ? (0.25 / (owc / src_wc)) - 0.25 :
    # \          Sub411 ? (0.375 / (owc / src_wc)) - 0.375 : 0.0

    assert((cplace == "mpeg2") || IsM1,
    \      R_8 + """ cplace must be "mpeg2" or "mpeg1" """ + chr(10))
    assert(!separate || IsM1,
    \ R_8 + """ When separate=true, cplace defaults to "mpeg1" and can't be changed """ +
    \ """ (For separate=false, "mpeg2" is the default, but it can be changed) """ + chr(10))

    chfix = Sub444 || IsM1 || Separate? 0.0 :
    \       Sub42x ? 0.25  - (float(src_wc) * 0.25 /  float(owc)) :
    \       Sub411 ? 0.375 - (float(src_wc) * 0.375 / float(owc)) : 0.0

    src_lf = src_lc + chfix

# ===============================================================================
#   Create strings for resizing
# ===============================================================================

    whstr   = "(" + string(ow)  + ", " + string(oh)
    whstr_c = "(" + string(owc) + ", " + string(ohc)

    srcstr   = ", src_left="  + string(src_l)  + ", src_top="    + string(src_t) +
    \          ", src_width=" + string(src_w)  + ", src_height=" + string(src_h)
    srcstr_c = ", src_left="  + string(src_lf) + ", src_top="    + string(src_tc) +
    \          ", src_width=" + string(src_wc) + ", src_height=" + string(src_hc)

    resizeA = resizer_Kc + whstr   + srcstr   + arg1_Kc + arg2_Kc + rstr_c + ")"
    resizeY = resizer_Kl + whstr   + srcstr   + arg1_Kl + arg2_Kl + rstr   + ")"
    resizeC = resizer_Kc + whstr_c + srcstr_c + arg1_Kc + arg2_Kc + rstr_c + ")"

    gaussY = IsMTResize ? "GaussResizeMT" + whstr   + srcstr   + ",p=100)" :
    \                     "GaussResize"   + whstr   + srcstr   + ",p=100)"
    gaussC = IsMTResize ? "GaussResizeMT" + whstr_c + srcstr_c + ",p=100)" :
    \                     "GaussResize"   + whstr_c + srcstr_c + ",p=100)"

    BlankY   = "BlankClip(width=ow,  height=oh, color=$808080)"
    BlankC   = "BlankClip(width=owc, height=ohc,color=$828282)"
    BlankRGB = "BlankClip(width=owc, height=ohc,color=$000000)"

# ===============================================================================
#   Use RgTools/repair plugin to repair ringing
# ===============================================================================

    # Disable ringing repair for these kernels by default

    nrkn   = (Kl == "Point") || (Kl == "Bilinear") || (Kl == "Gauss") ||
    \        (Kl == "Hermite") || (Kl == "SinPow") || (Kl == "SincLin2") ||
    \        (Kl == "UserDefined2") || (LeftStr(Kl, 9) == "SoftCubic") || unKnown_Kl

    nrkn_c = (Kc == "Point") || (Kc == "Bilinear") || (Kc == "Gauss") ||
    \        (Kc == "Hermite") || (Kc == "SinPow") || (Kc == "SincLin2") ||
    \        (Kc == "UserDefined2") || (LeftStr(Kc, 9) == "SoftCubic") || unKnown_Kc
 
    IsNoring   = defined(noring)
    IsNoring_c = defined(noring_c)
    noring     = default(noring, nrkn || !IsLup ? false : true)
    noring_c   = default(noring_c, IsNoring && (Kl == Kc) ? noring : nrkn_c || !IsCup ? false : true)

    assert((IsBool(noring) || IsFloat(noring)) && (IsBool(noring_c) || IsFloat(noring_c)),
    \      R_8 + """ "noring" must be bool, integer or float """ + chr(10))
    assert((IsBool(noring) || (0 <= noring <= 1)) && (IsBool(noring_c) || (0 <= noring_c <= 1)),
    \      R_8 + """ when "noring" is an integer or float """ + chr(10) +
    \      " the allowed range is 0 to 1 " + chr(10))

# ===============================================================================
#   Weight calculation of adaptive anti-ringing algorithm
# ===============================================================================

    res_mul = IsLup ? float(ow) * float(oh) / float(src_h) / float(src_w) :
    \         float(src_w) * float(src_h) / float(oh) / float(ow)
    res_mul = min(max(res_mul, 1), 2.25)
    nr_wght = IsFloat(noring) ? noring :
    \         (noring == true) ? Spline(res_mul, 1, 0, 2.25, 1, 3.5, 0, true) : 0
    nr_wght = min(max(nr_wght, 0), 1)

    res_mul_c = IsCup ? float(owc) * float(ohc) / float(src_hc) / float(src_wc) :
    \           float(src_wc) * float(src_hc) / float(ohc) / float(owc)
    res_mul_c = min(max(res_mul_c, 1), 2.25)
    nr_wght_c = IsFloat(noring_c) ? noring_c :
    \           (noring_c == true) ? Spline(res_mul_c, 1, 0, 2.25, 1, 3.5, 0, true) : 0
    nr_wght_c   = min(max(nr_wght_c, 0), 1)

# ===============================================================================
#   Control whether to process Y/U/V/A or R/G/B/A planes
# ===============================================================================

    show = default(show, false)
    chroma = default(chroma, true)
    alpha = default(alpha, IsAlpha ? true : false)
    AddAlpha = alpha && !IsAlpha
    At = alpha && IsAlpha && (IsRGBSource || (!IsRGBSource && IsAvsHBD))
    Yt = default(Y, true)
    Ut = default(U, chroma) && !Sub000
    Vt = default(V, chroma) && !Sub000
    Rt = default(Y, true)
    Gt = default(U, true)
    Bt = default(V, true)

    assert(IsAvsHBD || ((!alpha || IsAlpha) || IsRGBSource),
    \      R_8 + " AviSynth+ Revision > 2294 required for YUVA support " + chr(10))
    assert((!alpha || IsAlpha) || ((sCSP != "YUY2") && !Sub411 && !Sub000),
    \      R_8 + " An alpha plane can't be added to " + pixtype + " " + chr(10))
    assert(chroma || !IsRGBSource,
    \      R_8 + " chroma=false only applies to YUV sources " + chr(10))
    assert(((Kl != "Spline") && (Kl != "Spline100") && (Kl != "Spline144") &&
    \      (Kc != "Spline") && (Kc != "Spline100") && (Kc != "Spline144")) ||
    \      (SourceBits == 8), R_8 + 
    \      " The SplineResize plugin only supports 8 bit video " + chr(10))

# ===============================================================================
#   YUV Resize 
# ===============================================================================

    !IsRGBSource && !show ? Eval("""

    As = At ? ExtractA(source) : nop()
    Ys = !Sub000 ? (IsAvsHBD ? ExtractY(source) : ConvertToY8(source)) : source
    Us = !Sub000 ? (IsAvsHBD ? ExtractU(source) : UtoY8(source)) : nop()
    Vs = !Sub000 ? (IsAvsHBD ? ExtractV(source) : VtoY8(source)) : nop()

    Try{

    Ao = At ? As.Eval(resizeY) : nop()
    Yo = Yt ? Ys.Eval(resizeY) : nop()
    Uo = Ut ? Us.Eval(resizeC) : nop()
    Vo = Vt ? Vs.Eval(resizeC) : nop()

    }catch(err){

    Ao = At ? ConvertToYUV420(As).Eval(resizeY) : nop()
    Yo = Yt ? (IsAvsHBD ? ConvertToYUV420(Ys) : ConvertToYV12(Ys)).Eval(resizeY) : nop()
    Uo = Ut ? (IsAvsHBD ? ConvertToYUV420(Us) : ConvertToYV12(Us)).Eval(resizeC) : nop()
    Vo = Vt ? (IsAvsHBD ? ConvertToYUV420(Vs) : ConvertToYV12(Vs)).Eval(resizeC) : nop()

    Ao = At ? ConvertToY(Ao) : nop()
    Yo = Yt ? (IsAvsHBD ? ConvertToY(Yo) : ConvertToY8(Yo)) : nop()
    Uo = Ut ? (IsAvsHBD ? ConvertToY(Uo) : ConvertToY8(Uo)) : nop()
    Vo = Vt ? (IsAvsHBD ? ConvertToY(Vo) : ConvertToY8(Vo)) : nop()

    }

    Ag = At && (nr_wght > 0) ? As.Eval(gaussY) : nop()
    Yg = Yt && (nr_wght > 0) ? Ys.Eval(gaussY) : nop()
    Ug = Ut && (nr_wght_c>0) ? Us.Eval(gaussC) : nop()
    Vg = Vt && (nr_wght_c>0) ? Vs.Eval(gaussC) : nop()

    Ar = At && (nr_wght > 0) ? Ao.Repair(Ag, 1, -1) : nop()
    Yr = Yt && (nr_wght > 0) ? Yo.Repair(Yg, 1, -1) : nop()
    Ur = Ut && (nr_wght_c>0) ? Uo.Repair(Ug, 1, -1) : nop()
    Vr = Vt && (nr_wght_c>0) ? Vo.Repair(Vg, 1, -1) : nop()

    Am = At ? ((nr_wght == 1) ? Ar : (nr_wght > 0) ? Ao.Merge(Ar, nr_wght)  : Ao) : nop()
    Ym = Yt ? ((nr_wght == 1) ? Yr : (nr_wght > 0) ? Yo.Merge(Yr, nr_wght)  : Yo) : Eval("Ys."+BlankY)
    Um = Ut ? ((nr_wght_c==1) ? Ur : (nr_wght_c>0) ? Uo.Merge(Ur, nr_wght_c): Uo) : Eval("Us."+BlankC)
    Vm = Vt ? ((nr_wght_c==1) ? Vr : (nr_wght_c>0) ? Vo.Merge(Vr, nr_wght_c): Vo) : Eval("Vs."+BlankC)

    cspace = Sub444 ? 444 : Sub42x && !Sub420 ? 422 : 420
    ptype = !IsAvsHBD || (!IsAlpha && !AddAlpha) ? pixtype :
    \       BuildPixelType(family=IsAlpha? "YUV" : "YUVA", bits=SourceBits, chroma=cspace)

    res = Sub000 ? Ym :
    \     IsAvsHBD && (sCSP != "YUY2") && !Sub411 ? (At ?
    \     CombinePlanes(Ym, Um, Vm, Am, planes="YUVA", source_planes="YYYY", pixel_type=pixtype) :
    \     CombinePlanes(Ym, Um, Vm, planes="YUV", source_planes="YYY", pixel_type=ptype)) :
    \     (sCSP != "YUY2") ? YtoUV(Um, Vm, Ym) : YtoUV(Um, Vm, Ym).ConvertToYUY2()

    """, "Resize YUV Eval") : !show ? Eval("""

# ===============================================================================
#   RGB Resize
# ===============================================================================

    As = At ? (IsAvsHBD ? ExtractA(source) : ShowAlpha(source, "Y8")) : nop()
    Rs = IsAvsHBD ? ExtractR(source) : ShowRed(source, "Y8")
    Gs = IsAvsHBD ? ExtractG(source) : ShowGreen(source, "Y8")
    Bs = IsAvsHBD ? ExtractB(source) : ShowBlue(source, "Y8")

    Try{

    Ao = At ? As.Eval(resizeA) : nop()
    Ro = Rt ? Rs.Eval(resizeY) : nop()
    Go = Gt ? Gs.Eval(resizeY) : nop()
    Bo = Bt ? Bs.Eval(resizeY) : nop()

    }catch(err){

    Ao = At ? (IsAvsHBD ? ConvertToYUV420(As) : ConvertToYV12(As)).Eval(resizeA) : nop()
    Ro = Rt ? (IsAvsHBD ? ConvertToYUV420(Rs) : ConvertToYV12(Rs)).Eval(resizeY) : nop()
    Go = Gt ? (IsAvsHBD ? ConvertToYUV420(Gs) : ConvertToYV12(Gs)).Eval(resizeY) : nop()
    Bo = Bt ? (IsAvsHBD ? ConvertToYUV420(Bs) : ConvertToYV12(Bs)).Eval(resizeY) : nop()

    Ao = At ? (IsAvsHBD ? ConvertToY(Ao) : ConvertToY8(Ao)) : nop()
    Ro = Rt ? (IsAvsHBD ? ConvertToY(Ro) : ConvertToY8(Ro)) : nop()
    Go = Gt ? (IsAvsHBD ? ConvertToY(Go) : ConvertToY8(Go)) : nop()
    Bo = Bt ? (IsAvsHBD ? ConvertToY(Bo) : ConvertToY8(Bo)) : nop()

    }

    Ag = At && (nr_wght_c>0) ? As.Eval(gaussY) : nop()
    Rg = Rt && (nr_wght > 0) ? Rs.Eval(gaussY) : nop()
    Gg = Gt && (nr_wght > 0) ? Gs.Eval(gaussY) : nop()
    Bg = Bt && (nr_wght > 0) ? Bs.Eval(gaussY) : nop()

    Ar = At && (nr_wght_c>0) ? Ao.Repair(Ag, 1, -1) : nop()
    Rr = Rt && (nr_wght > 0) ? Ro.Repair(Rg, 1, -1) : nop()
    Gr = Gt && (nr_wght > 0) ? Go.Repair(Gg, 1, -1) : nop()
    Br = Bt && (nr_wght > 0) ? Bo.Repair(Bg, 1, -1) : nop()

    Am = At ? ((nr_wght_c==1) ? Ar : (nr_wght_c>0) ? Ao.Merge(Ar, nr_wght_c): Ao) : nop()
    Rm = Rt ? ((nr_wght == 1) ? Rr : (nr_wght > 0) ? Ro.Merge(Rr, nr_wght)  : Ro) : Eval("Rs."+BlankRGB)
    Gm = Gt ? ((nr_wght == 1) ? Gr : (nr_wght > 0) ? Go.Merge(Gr, nr_wght)  : Go) : Eval("Gs."+BlankRGB)
    Bm = Bt ? ((nr_wght == 1) ? Br : (nr_wght > 0) ? Bo.Merge(Br, nr_wght)  : Bo) : Eval("Bs."+BlankRGB)

    cspace = !IsAlpha && !AddAlpha ? sCSP :
    \        IsAlpha ? ((sCSP == "RGB32") ? "RGB24" : "RGB48") :
    \        (sCSP == "RGB24") ? "RGB32" : "RGB64"

    ptype = !IsAlpha && !AddAlpha ? pixtype :
    \       (sCSP == "RGBAP") || (sCSP == "RGBP") ?
    \       BuildPixelType(family=IsAlpha ? "RGB" : "RGBA", bits=SourceBits) : nop()

    res = (sCSP == "RGBAP") && At ?
    \     CombinePlanes(Rm, Gm, Bm, Am, planes="RGBA", source_planes="YYYY", pixel_type=pixtype) :
    \     (sCSP == "RGBAP") || (sCSP == "RGBP") ?
    \     CombinePlanes(Rm, Gm, Bm, planes="RGB", source_planes="YYY", pixel_type=ptype) :
    \     At ? MergeARGB(Am, Rm, Gm, Bm) : MergeRGB(Rm, Gm, Bm, cspace)

    """, "Resize RGB Eval") : show ? Eval("""

# ===============================================================================
#   Display resizing strings using a blank clip
# ===============================================================================

    src_r  = (src_w <= 0) ? src_w : -sw + src_w + src_l
    src_b  = (src_h <= 0) ? src_h : -sh + src_h + src_t
    src_rc = !Separate ? (Sub444 ? src_r : (src_r / (Sub42x ? 2 : 4))) :
    \        -swc + src_l + src_wc
    src_rf = src_rc + chfix
    src_bc = !Separate ? (Sub420 ? src_b / 2 : src_b) : -shc + src_t + src_hc

    srxl=R8_FS(src_l)       srxt=R8_FS(src_t)       srxw=R8_FS(src_w)
    srxh=R8_FS(src_h)       srxr=R8_FS(src_r)       srxb=R8_FS(src_b)
    srxlf=R8_FS(src_lf)     srxtc=R8_FS(src_tc)     srxwc=R8_FS(src_wc)
    srxhc=R8_FS(src_hc)     srxrf=R8_FS(src_rf)     srxbc=R8_FS(src_bc)
    cfx=R8_FS(chfix)        nwl=R8_FS(nr_wght,1)    nwc=R8_FS(nr_wght_c,1)

    dl=", src_left="         dt=", src_top="
    dw=", src_width="        dh=", src_height="
    b1="("                   b2=")"                   Q=",  " 
       
    srxstr   = dl + srxl  + dt + srxt  + dw + srxw  + dh + srxh
    srxstr_c = dl + srxlf + dt + srxtc + dw + srxwc + dh + srxhc

    ltwh  = b1 + srxl  + Q + srxt  + Q + srxw  + Q + srxh  + b2
    ltrb  = b1 + srxl  + Q + srxt  + Q + srxr  + Q + srxb  + b2
    ltwhc = b1 + srxlf + Q + srxtc + Q + srxwc + Q + srxhc + b2
    ltrbc = b1 + srxlf + Q + srxtc + Q + srxrf + Q + srxbc + b2

    resizestrA = resizer_Kc + whstr   + srxstr   + arg1_Kc + arg2_Kc + rstr_c + b2 
    resizestrY = resizer_Kl + whstr   + srxstr   + arg1_Kl + arg2_Kl + rstr   + b2
    resizestrC = resizer_Kc + WHstr_c + srxstr_c + arg1_Kc + arg2_Kc + rstr_c + b2

    formatted = true
    resizestrA = Formatted ? resizestrA :resizeA
    resizestrY = Formatted ? resizestrY :resizeY
    resizestrC = Formatted ? resizestrC :resizeC

    Do_nwKc = !Sub000 && (IsNoring_c || (noring != noring_c))
    Do_textC = !Sub000 && !IsRGBSource && (Ut || Vt) 

    nwKl = (IsRGBSource && Do_nwKc ? "\n" : "") + (!IsNoring && !noring ?
    \      "  Ringing repair disabled by default " +
    \      (!IsLup ? "unless upscaling" : "for " + resizer_Kl) :
    \      !noring ? "  Ringing repair disabled" : "  Weight of " +
    \      (!Do_nwKc ? "" : Kl + " ") + "ringing repair  " + nwl)

    nwKc = !Do_nwKc ? "" : (!IsRGBSource ? "\n" : "") + 
    \      (!IsNoring_c && !noring_c ?
    \      "  Ringing repair disabled by default " +
    \      (!IsCup ? "unless upscaling" : "for " + resizer_Kc) :
    \      !noring_c ? "  Ringing repair disabled" : "  Weight of " +
    \      (!Do_nwKc ? "" : Kc + " ") + "ringing repair  " + nwc)

    textQ = "  Luma  left, top, width, height  " + ltwh +
    \       "\n  Luma  left, top, right, bottom  " + ltrb

    textR = Sub000 || (IsRGBSource && (!IsAlpha || !AT)) ? "" :
    \       "  Chroma  left, top, width, height  " + ltwhc +
    \           "\n  Chroma  left, top, right, bottom  " + ltrbc

    textS = "  Source" + string(SourceBits,"  %.0f bit  ") + pixtype

    textA = Sub000 ? "" : "\n  " + (AddAlpha ? "Adding Alpha Plane" :
    \       !IsAlpha ? "No Alpha Plane" : !At ? "Alpha Plane Disabled" :
    \       "Alpha Plane\n  " + (!IsRGBSource ? resizestrY : resizestrA))

    textY = !IsRGBSource && !Yt ? "\n  Y Plane Disabled" :
    \       (!Rt && !Gt && !Bt) ? "\n  All RGB Planes Disabled" :
    \       (!IsRGBSource ? "  Y Plane\n  " : "  RGB Planes\n  ") + resizestrY

    textC = !Do_textC ? "" :
    \       "  UV Planes\n  " + resizestrC + (Sub42x && !IsM1 ?
    \       "\n\n  Extra UV left crop to prevent chroma shift  " + cfx : "")

    ts=17.5                  tr=ts*0.85               tc=ts*0.9

    ya = AddAlpha || !IsAlpha || !At ? ts : 0.0
    yr = ya + (tr * (Do_textC && Sub42x ? 0.0 : Do_textC ? 3.0 : 6.0))

    scolor1 = AddAlpha || !IsAlpha || !At ? $FFFFFF : !IsRGBSource ? $F0FFFF : $FFFFE0
    scolor2 = Do_nwKc ? $F0FFFF : $FFFFFF

    showstr = BlankClip(width=1280, height=480, pixel_type=pixtype).KillAudio()
             \.subtitle(textQ, size=tc, text_color=$F0FFFF, y=ts,        lsp=20)
             \.subtitle(textR, size=tc, text_color=$FFFFE0, y=(ts*3.5),  lsp=20)
             \.subtitle(textS, size=ts, text_color=$FFFFFF, y=(ts*8),    lsp=20)
             \.subtitle(textA, size=ts, text_color=scolor1, y=(ts*10),   lsp=20)
             \.subtitle(textY, size=ts, text_color=$F0FFFF, y=(ts*14)-ya,lsp=20)
             \.subtitle(textC, size=ts, text_color=$FFFFE0, y=(ts*17)-ya,lsp=20)
             \.subtitle(nwKl,  size=tr, text_color=scolor2, y=(ts*24)-yr,lsp=20)
             \.subtitle(nwKc,  size=tr, text_color=$FFFFE0, y=(ts*24)-yr,lsp=20)

    """, "Show Eval") : nop()

# ===============================================================================
#   Resize8 out
# ===============================================================================

    return !show ? res : showstr  }

# ===============================================================================
# ===============================================================================
#   Format string function (remove zeros)
# ===============================================================================
# ===============================================================================

function R8_FS(float f, int "keep1", int "limit")  {

    keep = (default(Keep1, 0) > 0)
    lim  = (default(limit, 1) > 0)
    Isd  = (abs(round(f) - f) > 0.0005)

    s = !Isd ? string(f,"%.0f") : lim ? string(f,"%.4f") : string(f,"%.6f")
    sl = StrLen(s)
    d = FindStr(s, ".")
    ls = Isd ? LeftStr(s, d) : s
    rs = Isd ? RightStr(s, sl - d) : ""
    rsl = StrLen(rs)
    rx = rs + "x"

    del = (FindStr(rx, "000000x") > 0) ? 6 :
    \     (FindStr(rx, "00000x") > 0)  ? 5 :
    \     (FindStr(rx, "0000x") > 0)   ? 4 :
    \     (FindStr(rx, "000x") > 0)    ? 3 :
    \     (FindStr(rx, "00x") > 0)     ? 2 :
    \     (FindStr(rx, "0x") > 0)      ? 1 : 0

    return ls + MidStr(rs, 1, rsl - del) + (!Isd && keep ? ".0" : "")  }

# ===============================================================================
# ===============================================================================
#   Default resizer and string functions
# ===============================================================================
# ===============================================================================
#
#   The functions below cannot be commented out.
#
#   Change the default resizers by modifying the strings in the appropriate function.
#   For example:
#   function R8_Luma_UpScale() { return "BicubicResizeMT" }
#
#   None of these resizers will be applied when a resizer is specified via the Resize8 kernel argument,
#   as it's used for upscaling and downscaling luma and chroma unless a kernel is also specified for
#   chroma resizing.
#
#   If a chroma resizer is specified via the kernel_c argument, it's used for upscaling and downscaling
#   chroma and the chroma resizers below will be ignored.
#
# -------------------------------------------------------------------------------

    function R8_Luma_UpScale()     { return "" }
    function R8_Luma_DownScale()   { return "" }
    function R8_Chroma_UpScale()   { return "" }
    function R8_Chroma_DownScale() { return "" }

# -------------------------------------------------------------------------------
#
#   The functions below cannot be commented out.
#
#   Default strings for the resizing kernels can be added to the following functions.
#   For example:
#   function R8_Luma_UpScale_rstr() { return "b=0.5, c=0.25" }
#
#   The strings below are completely ignored when a kernel is specified via the Resize8 kernel argument.
#   When a kernel for chroma is specified via the kernel_c argument, the two chroma strings are ignored.
#
#   These strings can be changed using the "rstr" and rstr_c" arguments.
#   The "rstr" argument would replace all four strings below when rstr_c is unspecified and
#   kernel equals kernel_c. rstr="" would clear them all.
#
#   The "rstr_c" argument would replace the two chroma strings below. rstr_c="" would clear them.
#
# -------------------------------------------------------------------------------

    function R8_Luma_UpScale_rstr()     { return "" }
    function R8_Luma_DownScale_rstr()   { return "" }
    function R8_Chroma_UpScale_rstr()   { return "" }
    function R8_Chroma_DownScale_rstr() { return "" }

# ===============================================================================
# ===============================================================================
# ===============================================================================