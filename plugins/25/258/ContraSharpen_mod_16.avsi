###### Contra-Sharpen mod 16 1.6 ######      by mawen1250      ######    2013.11.18    ######
###### Requirements: masktools v2.0a48, mvtools v2.5.11.3/v2.6.0.5, dither v1.24.0     ######
###### RemoveGrain v1.0pre, nnedi3 v0.9.4, TEdgeMask v0.9, tcanny v1.0, MSharpen v1.10 ######
###### f3kdb v1.5.1 (preset="Deband"), nnedi3_resize16 v3.0 (ss_hq=True)               ######

Function CSmod16(clip filtered, clip "source", clip "pclip", bool "lsb_in", bool "lsb", int "dither", bool "chroma", string "preset",
\ int "edgemode", val "edgemask", float "edgethr", float "tcannysigma", bool "mergesrc",
\ float "ss_w", float "ss_h", bool "ss_hq", bool "nr", string "ssmethod", string "filter_ss", bool "ssrep", bool "ssout", bool "ssoutc",
\ int "preblur", bool "prec", bool "usepasf", bool "sspre",
\ int "Smethod", val "kernel", float "secure", string "filter_nr",
\ int "dbr", int "dbY", int "dbCb", int "dbCr", int "dbgY", int "dbgC", float "dbthr", float "dbelast",
\ val "Smode", float "strength", float "divisor", float "index", float "Szrp", float "Spwr", float "SdmpLo", float "SdmpHi",
\ bool "Slimit", bool "Tlimit", bool "limitsrc", float "Sovershoot", float "Sundershoot", float "Tovershoot", float "Tundershoot",
\ float "Soft",
\ bool "limit", int "Repmode", int "RepmodeU", float "thr", float "thrc", float "elast",
\ bool "chromamv", int "blksize", int "overlap", int "thSAD", int "thSCD1", int "thSCD2",
\ bool "truemotion", bool "MVglobal", int "pel", int "pelsearch", int "search", int "searchparam", int "MVsharp", int "DCT")
{

###############################################################################################################################
lsb_in   = Default(lsb_in,  True   )
lsb      = Default(lsb,     True   )
dither   = Default(dither,  6      )
chroma   = Default(chroma,  False  )

defsrc   = Defined(source   )
defpclp  = Defined(pclip    )
filtered8=           !lsb_in ? filtered : filtered.DitherPost(mode=dither)
source8  = defsrc  ? !lsb_in ? source   : source  .DitherPost(mode=dither)  : NOP()
pclip8   = defpclp ? !lsb_in ? pclip    : pclip   .DitherPost(mode=dither)  : NOP()
filtered =            lsb_in ? filtered : filtered.Dither_convert_8_to_16()
source   = defsrc  ?  lsb_in ? source   : source  .Dither_convert_8_to_16() : NOP()
pclip    = defpclp ?  lsb_in ? pclip    : pclip   .Dither_convert_8_to_16() : NOP()
sw       = filtered.Width()
sh       = filtered.Height()/2
HD       = (sw > 1024 || sh > 576) ? True : False

###############################################################################################################################
dbr      = Default(dbr,     HD?16:10)
dbY      = Default(dbY,     56     )
dbCb     = Default(dbCb,    40     )
dbCr     = Default(dbCr,    40     )
dbGY     = Default(dbGY,    0      )
dbGC     = Default(dbGC,    0      )
dbthr    = Default(dbthr,   0.35   )
dbelast  = Default(dbelast, 3.0    )

###############################################################################################################################
preset   = Default(preset,  defsrc ? "Faster" : "Medium" )

pnum     = preset == "Very Fast" ?  0
\        : preset == "Faster"    ?  1
\        : preset == "Fast"      ?  2
\        : preset == "Medium"    ?  3
\        : preset == "Slow"      ?  4
\        : preset == "Slower"    ?  5
\        : preset == "Very Slow" ?  6
\        : preset == "Noise"     ?  7
\        : preset == "Grain"     ?  8
\        : preset == "Detail"    ?  9
\        : preset == "Deband"    ? 10
\        :                         11
Assert( pnum < 11,  """CSmod16: "preset" is invalid""" )

deffss      = Defined(filter_ss)

deffnr      = Defined(filter_nr)
filter_nr   = Default(filter_nr, preset == "Deband" ?
\             "f3kdb(range=dbr, Y=dbY, Cb=chroma?dbCb:0, Cr=chroma?dbCr:0, grainY=dbgY, grainC=chroma?dbgC:0, input_mode=1, output_mode=1)
\             .Dither_limit_dif16(method, thr=dbthr, elast=dbelast, Y=3, U=chroma?3:1, V=chroma?3:1)" : NOP())
deffnr      = preset == "Deband" ? True : deffnr

###############################################################################################################################
# Preset groups:                                 Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                        Faster        Medium        Slower        Noise         Detail

edgemode    = Default(edgemode,    Select(pnum,  0,     0,     0,     0,     0,     0,     0,     2,     2,     2,     2     ))
# 0 = Sharpening all, 1 = Sharpening only edge, 2 = Sharpening only non-edge.
# By default, edgemode=2 is tuned for enhancing noise/small detail.
# It will automatically set [ss_w=1, ss_h=1, preblur=0, kernel=5, Slimit=False, Tlimit=True(when limit=False)].

edgemask    = Default(edgemask,    Select(pnum,  1,     1,     3,     6,     6,     6,     5,     6,     6,     6,     6     ))
#  1: Same as edgemaskHQ=False in LSFmod(min/max), 2: Same as edgemaskHQ=True in LSFmod,
#  3: Same as sharpening mask in MCTD(prewitt),    4: MSharpen mask,
#  5: tcanny mask(less sensitive to noise),        6: prewitt mask with mt_hysteresis(less sensitive to noise),
# -1: Same as mtype=1 in TAA(sobel),              -2: Same as mtype=2 in TAA(roberts),
# -3: Same as mtype=3 in TAA(prewitt),            -4: Same as mtype=4 in TAA(TEdgeMask),
# -5: Same as mtype=5 in TAA(tcanny),             -6: Same as mtype=6 in TAA(MSharpen),
# -7: My own method of tcanny usage of AA mask.
# 1~6 are masks tweaked for Sharpening, -1~-7 are masks tweaked for AA.
# Otherwise define a custom edge mask clip, only luma is taken to merge all planes.

edgethr     = Default(edgethr,     Select(pnum,  32.0,  32.0,  32.0,  32.0,  32.0,  32.0,  32.0,  24.0,  32.0,  48.0,  24.0  ))
# Tweak edge mask threshold EXCEPT edgemask mode -2/-1.

tcannysigma = Default(tcannysigma, 1.2        )   #Tweak tcanny's sigma in edgemask mode -7/-5/5.
mergesrc    = Default(mergesrc,    False      )   #Whether to merge clip "source" instead of clip "filtered" at the end of processing.

###############################################################################################################################
# Preset groups:                          Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                 Faster        Medium        Slower        Noise         Detail

ss_w     = Default(ss_w,    Select(pnum,  1.00,  1.00,  1.25,  1.25,  1.50,  1.50,  1.50,  1.00,  1.00,  1.00,  1.00  ))
# Super sampling multiplier of width.
ss_h     = Default(ss_h,    Select(pnum,  1.00,  1.00,  1.25,  1.25,  1.50,  1.50,  1.50,  1.00,  1.00,  1.00,  1.00  ))
# Super sampling multiplier of height.
nr       = Default(nr,      Select(pnum,  False, False, False, False,  True, True,  True,  False, False, False, False ))
# True using non-ringing resize in super sampling.

ss_hq    = Default(ss_hq,   False  )   #True using nnedi3_resize16 in super sampling, False using non-ringing Spline64Resize.
ssout    = Default(ssout,   False  )   #Output in super sampling resolution.
ssoutc   = Default(ssoutc,  True   )   #Whether to output correct chroma when (chroma==False && ssout==True).
ssrep    = Default(ssrep,   False  )   #When limiting sharpening to source clip, whether to repair in super sampling resolution.
ss_w     = max    (ss_w,    1.00   )
ss_h     = max    (ss_h,    1.00   )
wss      = (ss_w > 1.0 || ss_h > 1.0) ? Round(sw*ss_w/8.0)*8 : sw
hss      = (ss_w > 1.0 || ss_h > 1.0) ? Round(sh*ss_h/8.0)*8 : sh
ss       = (wss == sw) && (hss == sh) ? False : True
ssout    = ss ? ssout : False
ssrep    = ss ? ssrep : False
ssoutc   = (!chroma && ssout) ? ssoutc : False
ssrep    = ssout ? True : ssrep

###############################################################################################################################
# Preset groups:                          Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                 Faster        Medium        Slower        Noise         Detail

preblur  = Default(preblur, Select(pnum,  0,     -1,    -1,    -1,   -6,    -6,    -6,     0,     1,     -6,    1     ))
# Pre-filtering, 0 = disable, -1 = Gaussian Blur radius=1(RG11), -2 = Gaussian Blur radius=2(RG11+RG20),
# -3 = Gaussian Blur radius=3(RG11+RG20+RG20), -4 = Median Blur radius=1(RG4),
# -5 = Average Blur radius=1(RG20) -6 = (RG4+RG11), -7 = (RG19+RG4),
# 1 = MinBlur16(mode=1)(RG11|RG4), 2 = MinBlur16(mode=2)(RG20|RG4), 3 = MinBlur16(mode=3)(SBR|RG4), 
# 4 = MinBlur16(mode=4)(Gaussian|Median radius=2), 5 = MinBlur16(mode=5)(Gaussian|Median radius=3).
# "preblur" is ignored when pclip is defined.
# Now Dither_median16 is very slow without optimization, if you want stronger pre-filter you can use other method such as MDegrain.

prec     = Default(prec,    True   )   #Whether to process chroma plane in preblur.
usepasf  = Default(usepasf, False  )
# Whether to use pre-filtered clip as input(filtered) clip, which will reduce noise/halo/ring from input clip.
sspre    = Default(sspre,   deffss )
# When True apply pre-filter in super sampling clip, when False apply pre-filter in original resolution.
# By default it is False unless filter_ss is defined.
usepasf  = (preblur==0 && !defpclp) ? False : usepasf

###############################################################################################################################
# Preset groups:                          Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                 Faster        Medium        Slower        Noise         Detail

Smethod  = Default(Smethod, ss_w*ss_h>=4?3:1)   #Sharpen Method - 1: 3x3 kernel, 2: Min/Max, 3: Min/Max + 3x3 kernel.

kernel   = Default(kernel,  Select(pnum,  1,     1,     6,     6,     3,     3,     3,     8,     7,     3,     5     ))
# 1: Gaussian Blur radius=1(RG11),      2: Average Blur(RG20),
# 3: Gaussian Blur radius=2(RG11+RG20), 4: Gaussian Blur radius=3(RG11+RG20+RG20),
# 5: Median Blur(RG4),                  6: Median Blur + Gaussian Blur(RG4+RG11)
# 7: for grain enhance(RG19+RG4),       8: for noise enhance(MinBlur radius=1)
# Otherwise define a custom kernel in string such as kernel="Dither_removegrain16(20, 11)".

secure   = Default(secure,  Select(pnum,  0.25,  0.25,  0.125, 0.125, 0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00  ))
# Threshold(on an 8-bit scale) to avoid banding & oil painting (or face wax) effect of sharpening, set 0 to disable it.(from LSFmod)

###############################################################################################################################
# Preset groups:                          Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                 Faster        Medium        Slower        Noise         Detail

Smode    = Default(Smode,   Select(pnum,  0,     3,     3,     3,     3,     3,     3,     3,     3,     3,     3     ))
# Sharpen Mode - 0: None, 1: Linear, 2: Non-linear 1, 3:Non-linear 2(from LSFmod Smode=5), Otherwise define a custom Smode in string.

strength = Default(strength,Select(pnum,  100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 80.0  ))

divisor  = Default(divisor, 1.5    )
index    = Default(index,   0.8    )
Szrp     = Default(Szrp,    16.0   )
Spwr     = Default(Spwr,    4.0    )
SdmpLo   = Default(SdmpLo,  4.0    )
SdmpHi   = Default(SdmpHi,  48.0   )
miSpwr   = 1.0 / Spwr
Szrp16   = Szrp * 256
Szrp2p   = Szrp * Szrp
divisor16= divisor * 256

###############################################################################################################################
limit    = Default(limit,   True   )
limit    = defsrc || deffss || usepasf || deffnr ? limit : False
# Whether to limit sharpening to source clip, only takes effect when (Defined(source) || Defined(filter_ss) || usepasf || Defined(filter_nr)) == True.
Repmode  = Default(Repmode, 1      )
RepmodeU = Default(RepmodeU,Repmode)

###############################################################################################################################
# Preset groups:                                 Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                        Faster        Medium        Slower        Noise         Detail

Soft        = Default(Soft,        Select(pnum,  0,     0,     -2,    -2,    -2,    -2,    -2,    0,     -2,    -2,    -2    ))
# Soft the sharpening effect (-1 = old autocalculate, -2 = new autocalculate, 0 = disable, (0, 100] = enable).
# Disabled when (limit==True && thr==0 && thrc==0).(from LSFmod)

Slimit      = Default(Slimit,      Select(pnum,  False, False, !limit,!limit,!limit,!limit,!limit,False, False, !limit,!limit))
# Spatial limit with overshoot and undershoot. Disabled when (limit==True && thr==0 && thrc==0).

Tlimit      = Default(Tlimit,      Select(pnum,  False, False, False, False, False, !limit,!limit,!limit,!limit,False, False ))
# Use MC Temporal limit at the end of sharpening.(from MCTD)

limitsrc = Default(limitsrc,False  )

elast    = Default(elast,   4.0    )
thr      = Default(thr ,    limit ? 0.0 : pnum>=7&&pnum<=10 ? strength/(elast*10.) : strength/(elast*5.))
thrc     = Default(thrc,    thr/2. )
# Allow pixels sharpen more than the source by [thr/thrc](luma/chroma)(on an 8-bit scale). Set to 0 to disable this function.
thrc     = chroma ? thrc : 0

Sovershoot  = Default(Sovershoot,  strength/120.0)   #(on an 8-bit scale)
Sundershoot = Default(Sundershoot, Sovershoot    )   #(on an 8-bit scale)
Tovershoot  = Default(Tovershoot,  strength/32.0 )   #(on an 8-bit scale)
Tundershoot = Default(Tundershoot, Tovershoot    )   #(on an 8-bit scale)
Sovershoot  = max(Sovershoot,  0)
Sundershoot = max(Sundershoot, 0)
Tovershoot  = max(Tovershoot,  0)
Tundershoot = max(Tundershoot, 0)

###############################################################################################################################
# Preset groups:                                 Very Fast     Fast          Slow          Very Slow     Grain         Deband
# Preset groups:                                        Faster        Medium        Slower        Noise         Detail

bs          = HD ? 16 :  8
bs2         = HD ? 32 : 16
chromamv    = Default(chromamv,    Select(pnum,  False, False, False, chroma,chroma,True,  True,  chroma,chroma,chroma,chroma))
blksize     = Default(blksize,     Select(pnum,  bs2,   bs2,   bs2,   bs2,   bs,    bs,    bs,    bs,    bs,    bs,    bs    ))
ol          = blksize/2
ol2         = blksize/4
overlap     = Default(overlap,     Select(pnum,  ol2,   ol2,   ol2,   ol2,   ol,    ol,    ol,    ol,    ol,    ol,    ol    ))
thSAD       = Default(thSAD,       300         )
thSCD1      = Default(thSCD1,      300         )
thSCD2      = Default(thSCD2,      100         )
truemotion  = Default(truemotion,  False       )
MVglobal    = Default(MVglobal,    False       )
pel         = Default(pel,         Select(pnum,  1,     1,     1,     1,     HD?1:2,HD?1:2,HD?1:2,1,     1,     1,     1     ))
pelsearch   = Default(pelsearch,   Select(pnum,  1,     2,     2,     2,     2,     2,     2,     2,     2,     2,     2     ))
search      = Default(search,      Select(pnum,  2,     2,     4,     4,     4,     5,     3,     4,     4,     4,     4     ))
searchparam = Default(searchparam, Select(pnum,  1,     2,     2,     2,     2,     2,     2,     2,     2,     2,     2     ))
MVsharp     = Default(MVsharp,     2           )
DCT         = Default(DCT,         0           )

###############################################################################################################################
ssmethod = Defined(ssmethod) ? ssmethod
\        :             ss_hq ? "nnedi3_resize16(wss, hss, mixed=False, lsb_in=True, lsb=True, Y=3, U=chroma||ssoutc?3:1, V=chroma||ssoutc?3:1)"
\        :                     "CSmod16_nrSpline64Resize16(wss, hss, chroma=chroma||ssoutc, nr=nr)"
# You can define your own super sampling method with ssmethod.

ch21     = chroma ? 2 : 1
ch31     = chroma ? 3 : 1
ch41     = chroma ? 4 : 1
ch32     = chroma ? 3 : 2
ch34     = chroma ? 3 : 4
Slimit   = limit && thr==0 && thrc==0 ? False : Slimit
Soft     = limit && thr==0 && thrc==0 ? 0
\        : Soft <= -2  ? (1.0+(2.0/(ss_w+ss_h))) * sqrt(strength)
\        : Soft == -1  ? sqrt( (((ss_w+ss_h)/2.0-1.0)*100.0) ) * 10
\        : Soft <= 100 ? Soft : 100

###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

# super sampling, filtering in ss clip
source      = defsrc ? source  : filtered
source8     = defsrc ? source8 : source.DitherPost(mode=dither)
filtered_os = filtered
filtered_ss = ss ? Eval("filtered."+ssmethod) : filtered
source_ss   = ss ? defsrc ? Eval("source."+ssmethod) : filtered_ss : source
filtered    = deffss ? Eval("filtered_ss."+filter_ss) : filtered_ss
filtered_ds = ss ? deffss ? filtered.CSmod16_nrSpline64Resize16(sw, sh, chroma=chroma, nr=0) : filtered_os : filtered
filtered_ss8= filtered_ss.DitherPost(mode=-1)

Assert( (isFrameBased(filtered_os)),                              """CSmod16: input clip "filtered" must be Frame Based!""" )
Assert( (isFrameBased(source)),                                     """CSmod16: input clip "source" must be Frame Based!""" )
Assert( (source.Width() == sw && source.Height()/2 == sh), """CSmod16: resolution of "filtered" and "source" must match!""" )

###############################################################################################################################
# pre-filtering before sharpening
fforpre     = sspre ? filtered : filtered_ds

pre         = defpclp     ? pclip
\           : preblur<=-7 ? fforpre.Dither_removegrain16(19, chroma?prec?19:0:-1).Dither_removegrain16(4 , chroma?prec?4 :0:-1)
\           : preblur==-6 ? fforpre.Dither_removegrain16(4 , chroma?prec?4 :0:-1).Dither_removegrain16(11, chroma?prec?11:0:-1)
\           : preblur==-5 ? fforpre.Dither_removegrain16(20, chroma?prec?20:0:-1)
\           : preblur==-4 ? fforpre.Dither_removegrain16(4 , chroma?prec?4 :0:-1)
\           : preblur==-3 ? fforpre.Dither_removegrain16(11, chroma?prec?11:0:-1).Dither_removegrain16(20, chroma?prec?20:0:-1)
\                                  .Dither_removegrain16(20, chroma?prec?20:0:-1)
\           : preblur==-2 ? fforpre.Dither_removegrain16(11, chroma?prec?11:0:-1).Dither_removegrain16(20, chroma?prec?20:0:-1)
\           : preblur==-1 ? fforpre.Dither_removegrain16(11, chroma?prec?11:0:-1)
\           : preblur>= 1 ? fforpre.MinBlur16(preblur, chroma ? (prec ? 3 : 2) : 1)
\           :               filtered
# You can define your own pre-filtered clip with pclip.

pre8        = defpclp ? pclip8 : pre.DitherPost(mode=dither)
pre_ds      = (pre.Width() == sw && pre.Height()/2 == sh) ? pre : pre.CSmod16_nrSpline64Resize16(sw, sh, chroma=chroma)
pre         = ss ? (pre.Width() == wss && pre.Height()/2 == hss) ? pre : Eval("pre."+ssmethod) : pre_ds
pclip_ds8   = defpclp ? (pclip8.Width() == sw && pclip8.Height() == sh) ? pclip8 : pclip8.Spline36Resize(sw, sh) : NOP()
pre_ds8     = defpclp ? pclip_ds8 : pre_ds.DitherPost(mode=-1)
pre8        = pre.DitherPost(mode=-1)

# whether to use pre-filtered clip as main clip
filtered    = usepasf ? pre    : filtered
filtered_ds = usepasf ? pre_ds : filtered_ds

###############################################################################################################################
# generate edge mask
prefinal8 = ssout ? Tlimit&&!chroma&&chromamv ? pre8.MergeChroma(filtered_ss8) : pre8 : Tlimit&&!chroma&&chromamv ? pre_ds8.MergeChroma(filtered8) : pre_ds8
srcfinal8 = ssout ? source_ss.DitherPost(mode=dither)                                 : source8

prewittm  = mt_edge(prefinal8, "prewitt", Round(edgethr*0.5), 255, 0, 0, V=1, U=1)
edgemask  = IsClip(edgemask) ? edgemask
\         : IsInt (edgemask) ?
\           edgemask == -1   ? mt_edge(prefinal8, "sobel", 7, 7, 5, 5, U=1, V=1).mt_inflate(U=1, V=1)
\         : edgemask == -2   ? mt_edge(prefinal8, "roberts", 0, 4, 0, 4, U=1, V=1).mt_inflate(U=1, V=1)
\         : edgemask == -3   ? mt_edge(prefinal8, "prewitt", 0, 255, 0, 0, V=1, U=1)
\                             .mt_lut("x " + string(edgethr) + " <= x 1 >> x 1.4 ^ ?", U=1, V=1)
\                             .RemoveGrain(4, -1).mt_inflate(U=1, V=1)
\         : edgemask == -4   ? TEdgeMask(prefinal8, link=2, preblur=False, valon=-1, U=0, V=0)
\                             .mt_lut("x " + string(edgethr/5.0) + " <= x 1 >> x 4 << ?", U=1, V=1)
\                             .mt_deflate(U=1, V=1).RemoveGrain(HD ? 20 : 11, -1)
\         : edgemask == -5   ? tcanny(srcfinal8, sigma=tcannysigma, mode=1, plane=1)
\                             .mt_lut("x " + string(edgethr) + " <= x 1 >> x 1 << ?", U=1, V=1)
\                             .RemoveGrain(HD ? 20 : 11, -1).mt_inflate(U=1, V=1)
\         : edgemask == -6   ? MSharpen(prefinal8, threshold=Round(edgethr/5.0), strength=0, mask=True, highq=False)
\                             .RemoveGrain(HD ? 20 : 11, -1)
\         : edgemask <= -7   ? tcanny(srcfinal8, sigma=tcannysigma, mode=1, plane=1)
\                             .mt_lut("x " + string(edgethr) + " <= 0 x " + string(edgethr) + " - 6 << ?", U=1, V=1)
\                             .RemoveGrain(HD ? 20 : 11, -1).mt_inflate(U=1, V=1)
\         : edgemask ==  1   ? prefinal8.mt_edge(thY1=0, thY2=255, mode="min/max", U=1, V=1)
\                             .mt_lut("x " + string(edgethr) + " / 0.86 ^ 255 *", U=1, V=1)
\                             .mt_inflate(U=1, V=1).mt_inflate(U=1, V=1).Removegrain(11, -1)
\         : edgemask ==  2   ? mt_logic(prefinal8.mt_edge(thY1=0, thY2=255, "8 16 8 0 0 0 -8 -16 -8 4", U=1, V=1),
\                                       prefinal8.mt_edge(thY1=0, thY2=255, "8 0 -8 16 0 -16 8 0 -8 4", U=1, V=1),
\                                       "max", U=1, V=1).mt_lut("x " + string(edgethr*4.0) + " / 0.86 ^ 255 *", U=1, V=1)
\                             .mt_inflate(U=1, V=1).mt_inflate(U=1, V=1).RemoveGrain(11, -1)
\         : edgemask ==  3   ? mt_edge(prefinal8, "prewitt", Round(edgethr*0.25), 255, 0, 0, V=1, U=1)
\                             .mt_lut("x 1.8 ^", U=1, V=1).RemoveGrain(4, -1).mt_inflate(U=1, V=1).RemoveGrain(20,-1)
\         : edgemask ==  4   ? MSharpen(prefinal8, threshold=Round(edgethr/10.0), strength=0, mask=True, highq=False)
\                             .RemoveGrain(HD ? 20 : 11, -1)
\         : edgemask ==  5   ? tcanny(srcfinal8, sigma=tcannysigma, mode=1, plane=1)
\                             .mt_lut("x " + string(edgethr*0.5) + " <= 0 x " + string(edgethr*0.5) + " - 2.4 ^ ?", U=1, V=1)
\                             .RemoveGrain(HD ? 20 : 11, -1).mt_inflate(U=1, V=1)
\         :                    mt_hysteresis(prewittm.RemoveGrain(4, -1), prewittm, U=1, V=1)
\                             .RemoveGrain(HD ? 20 : 11, -1).mt_inflate(U=1, V=1)
\         :                    Assert(False, """CSmod16: "edgemask" should be int or clip!""")

###############################################################################################################################
# unsharp
dark_limit   = pre.CSmod16_inpand16(U=ch31, V=ch31)
bright_limit = pre.CSmod16_expand16(U=ch31, V=ch31)
minmaxavg    = CSmod16_average16(dark_limit, bright_limit, U=ch31, V=ch31)

method     = Smethod <= 1     ? pre : minmaxavg

method     = Smethod == 2     ? method
\          : IsString(kernel) ? Eval("method."+kernel)
\          : IsInt   (kernel) ?
\            kernel <= 1      ? method.Dither_removegrain16(11, chroma?11:-1)
\          : kernel == 2      ? method.Dither_removegrain16(20, chroma?20:-1)
\          : kernel == 3      ? method.Dither_removegrain16(11, chroma?11:-1).Dither_removegrain16(20, chroma?20:-1)
\          : kernel == 4      ? method.Dither_removegrain16(11, chroma?11:-1).Dither_removegrain16(20, chroma?20:-1)
\                                     .Dither_removegrain16(20, chroma?20:-1)
\          : kernel == 5      ? method.Dither_removegrain16(4 , chroma?4 :-1)
\          : kernel == 6      ? method.Dither_removegrain16(4 , chroma?4 :-1).Dither_removegrain16(11, chroma?11:-1)
\          : kernel == 7      ? method.Dither_removegrain16(19, chroma?19:-1).Dither_removegrain16(4 , chroma?4 :-1)
\          :                    method.MinBlur16(1, chroma?3:1)
\          :                    Assert(False, """CSmod16: "kernel" should be int or string!""")

method     = secure >  0      ? pre.Dither_limit_dif16(method, thr=secure, elast=10.0, U=ch31, V=ch31) : method

###############################################################################################################################
# making difference clip for sharpening
sharpdiff  = Dither_sub16(pre, method, U=ch31, V=ch31, dif=True)
noise      = usepasf || (preblur==0 && !defpclp) ? sharpdiff : Dither_sub16(filtered, method, U=ch31, V=ch31, dif=True)

# filtering in nr clip
filtered   = deffnr ? Eval("method." + filter_nr).Dither_add16(noise, U=ch31, V=ch31, dif=True) : filtered
filtered_ds= ss ? deffnr      ? filtered.CSmod16_nrSpline64Resize16(sw, sh, chroma=chroma, nr=0)
\               : filtered_ds : filtered

###############################################################################################################################
# sharpening diff generate mode
sharpdiff  = IsString(Smode)  ? sharpdiff.Dither_lut16(Smode, U=ch31, V=ch31)
\          : IsInt   (Smode)  ?
\            Smode <= 0       ? sharpdiff
\          : Smode == 1       ? sharpdiff.Dither_lut16("x 32768 == x  x 32768 - "+string(strength/50.0)+" * 32768 + ?", U=ch31, V=ch31)
\          : Smode == 2       ? sharpdiff.Dither_lut16("x 32768 == x  x 32768 - "+String(divisor16)+" / Abs "+String(index)+" ^ "+String(strength*12.8)+" * x 32768 > 1 -1 ? * 32768 + ?", U=ch31, V=ch31)
\          :                    sharpdiff.Dither_lut16("x 32768 == x  x 32768 - abs "+string(Szrp16)+" / "+string(miSpwr)+" ^ "+string(Szrp16*strength/100.0)+" * x 32768 > 1 -1 ? * x 32768 - 256 / 2 ^ "+string(Szrp2p+SdmpLo)+" * x 32768 - 256 / 2 ^ "+string(SdmpLo)+" + "+string(Szrp2p)+" * / * "+string(SdmpHi==0 ? 1 : Pow(Szrp/SdmpHi, 4)+1)+" 1 "+string(SdmpHi)+" 0 == 0 x 32768 - 256 / abs "+string(SdmpHi)+" / 4 ^ ? + / * 32768 + ?", U=ch31, V=ch31)
\          :                    Assert(False,  """CSmod16: "Smode" should be int or string!""")

# x==32768 ? x : (abs(x-32768)/Szrp16)^(miSpwr)*(Szrp16*strength/100.0)*(x>32768 ? 1 : -1) * (((x-32768)/256)^2*(Szrp^2+SdmpLo) / (((x-32768)/256)^2+SdmpLo)*Szrp^2) * ((1+ SdmpHi==0 ? 0 : (Szrp/SdmpHi)^4) / (1+ SdmpHi==0 ? 0 : (abs((x-32768)/256)/SdmpHi)^4)) + 32768

###############################################################################################################################
# spatial limit
srcfinal   = ssout ? source_ss : source
fltfinal   = ssout ? filtered  : filtered_ds
limitclp   = limitsrc ? srcfinal : fltfinal

sclp       = Slimit ? Dither_add16(pre, sharpdiff, U=ch31, V=ch31, dif=True) : NOP()
sclp       = Slimit ? sclp.CSmod16_clamp16(bright_limit, dark_limit, Sovershoot, Sundershoot, U=ch31, V=ch31) : NOP()

###############################################################################################################################
# Soft
sharpdiff  = Slimit ? Dither_sub16(sclp, pre, U=ch31, V=ch31, dif=True) : sharpdiff
sharpdiffS = sharpdiff.Dither_removegrain16(19, chroma ? 19 : -1)
wmask      = sharpdiff.Dither_lut16(Y=Round(-655.35*Soft), U=chroma?Round(-655.35*Soft):1, V=chroma?Round(-655.35*Soft):1)
sharpdiffW = Soft == 100 ? sharpdiffS : Dither_merge16(sharpdiff, sharpdiffS, wmask, luma=False, U=ch31, V=ch31)
sharpdiff  = Soft ==   0 ? sharpdiff  : CSmod16_limitdiff16(sharpdiff, sharpdiffW, U=ch31, V=ch31)

###############################################################################################################################
# the difference achieved by filtering
allD       = limit  ? ssrep ? Dither_sub16(source_ss, filtered, U=ch31, V=ch31, dif=True)
\                           : Dither_sub16(source, filtered_ds, U=ch31, V=ch31, dif=True) : NOP()

# limiting sharpening to source clip
sharpdiff  = !ssrep && ss ? sharpdiff.CSmod16_nrSpline64Resize16(sw, sh, chroma=chroma, nr=0) : sharpdiff
ssDD       = limit ? sharpdiff.Dither_repair16(allD, mode=Repmode, modeU=chroma ? RepmodeU : -1) : sharpdiff
ssDD       = limit ? ssDD.CSmod16_limitdiff16(sharpdiff, U=ch31, V=ch31) : ssDD
ssDDl      = thr  > 0 ? sharpdiff.Dither_limit_dif16(limit ? ssDD : sharpdiff.CSmod16_gen_null_diff(), thr=thr , elast=elast, Y=3, U=1, V=1) : ssDD
ssDDc      = thrc > 0 ? sharpdiff.Dither_limit_dif16(limit ? ssDD : sharpdiff.CSmod16_gen_null_diff(), thr=thrc, elast=elast, Y=1, U=3, V=3) : ssDD
ssDD       = thr  > 0 || thrc > 0 ? thr == thrc ?
\                       sharpdiff.Dither_limit_dif16(limit ? ssDD : sharpdiff.CSmod16_gen_null_diff(), thr=thr , elast=elast, Y=3, U=3, V=3) : ssDDl.MergeChroma(ssDDc) : ssDD
ssDD       = ssrep && ss && !ssout ? ssDD.CSmod16_nrSpline64Resize16(sw, sh, chroma=chroma, nr=0) : ssDD

# add difference clip to clip "filtered" of ss/original resolution
sclp       = ssout ? Dither_add16(filtered, ssDD, U=ch31, V=ch31, dif=True) : Dither_add16(filtered_ds, ssDD, U=ch31, V=ch31, dif=True)

###############################################################################################################################
# temporal limit
fltfinal8  = ssout ? filtered.DitherPost(mode=-1) : filtered_ds.DitherPost(mode=-1)
limitclp8  = limitsrc ? srcfinal8 : fltfinal8

sMVS       = prefinal8.MSuper(hpad=0, vpad=0, pel=pel, levels=0, sharp=MVsharp, chroma=chromamv)
rMVS       = usepasf || (preblur==0 && !defpclp) ? sMVS
\                                                : limitclp8.MSuper(hpad=0, vpad=0, pel=pel, levels=1, sharp=MVsharp, chroma=chroma)
f1v        = MAnalyse(sMVS, isb=False, delta=1, truemotion=truemotion, blksize=blksize, overlap=overlap, pelsearch=pelsearch, search=search, searchparam=searchparam, DCT=DCT, global=MVglobal, chroma=chromamv)
b1v        = MAnalyse(sMVS, isb=True,  delta=1, truemotion=truemotion, blksize=blksize, overlap=overlap, pelsearch=pelsearch, search=search, searchparam=searchparam, DCT=DCT, global=MVglobal, chroma=chromamv)
f1c        = MCompensate(limitclp8, rMVS, f1v, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
b1c        = MCompensate(limitclp8, rMVS, b1v, thSAD=thSAD, thSCD1=thSCD1, thSCD2=thSCD2)
Tmax       = limitclp8.mt_logic(f1c, "max", U=ch31, V=ch31).mt_logic(b1c, "max", U=ch31, V=ch31).Dither_convert_8_to_16()
Tmin       = limitclp8.mt_logic(f1c, "min", U=ch31, V=ch31).mt_logic(b1c, "min", U=ch31, V=ch31).Dither_convert_8_to_16()
Tmax       = lsb_in ? limitclp.Dither_limit_dif16(Tmax, thr=0.75, elast=2.0, U=ch31, V=ch31) : Tmax
Tmin       = lsb_in ? limitclp.Dither_limit_dif16(Tmin, thr=0.75, elast=2.0, U=ch31, V=ch31) : Tmin
sclp       = Tlimit ? sclp.CSmod16_clamp16(Tmax, Tmin, Tovershoot, Tundershoot, U=ch31, V=ch31) : sclp

###############################################################################################################################
# merge with edge mask and output correct chroma
merged_ss  = mergesrc ? source_ss : filtered_ss
merged_os  = mergesrc ? source    : filtered_os

end        = edgemode <= 0 ? chroma ? sclp
\                                   : ssout ? ssoutc ? sclp.MergeChroma(merged_ss)
\                                                    : sclp
\                                           : sclp.MergeChroma(merged_os)
\          : edgemode == 1 ? ssout ? Dither_merge16_8(merged_ss, sclp, edgemask,
\                                    luma=chroma, Y=3, U=ssoutc?ch32:ch31, V=ssoutc?ch32:ch31)
\                                  : Dither_merge16_8(merged_os, sclp, edgemask,
\                                    luma=chroma, Y=3, U=ch32,             V=ch32            )
\                          : ssout ? Dither_merge16_8(sclp, merged_ss, edgemask,
\                                    luma=chroma, Y=3, U=ssoutc?ch34:ch31, V=ssoutc?ch34:ch31)
\                                  : Dither_merge16_8(sclp, merged_os, edgemask,
\                                    luma=chroma, Y=3, U=ch34,             V=ch34            )

return lsb ? end : end.DitherPost(mode=dither)
}

###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

Function MinBlur16(clip clp, int "mode", int "uv"){

mode  = Default(mode, 1)
uv    = Default(uv,   3)

uv2   = (uv==2) ? 1  : uv
rg4   = (uv==3) ? 4  : -1
rg11  = (uv==3) ? 11 : -1
rg20  = (uv==3) ? 20 : -1

RG11  = (mode<=1) ? clp.Dither_removegrain16(11, rg11)
\     : (mode==2) ? clp.Dither_removegrain16(20, rg20)
\     : (mode==3) ? clp.sbr16(uv=uv2)
\     : (mode==4) ? clp.Dither_removegrain16(11, rg11).Dither_removegrain16(20, rg20)
\     :             clp.Dither_removegrain16(11, rg11).Dither_removegrain16(20, rg20).Dither_removegrain16(20, rg20)
RG4   = (mode<=3) ? clp.Dither_removegrain16(4,  rg4 )
\     : (mode==4) ? clp.Dither_median16(2, 2, 0, U=uv2, V=uv2)
\     :             clp.Dither_median16(3, 3, 0, U=uv2, V=uv2)

return CSmod16_min_dif16(RG11, RG4, clp, U=uv, V=uv)
}


Function sbr16(clip clp, int "uv") {
uv       = Default(uv, 1)
uv2      = (uv==2) ? 1  : uv
rg11     = (uv==3) ? 11 : -1

rg11D    = Dither_sub16(clp, clp.Dither_removegrain16(11, rg11), U=uv2, V=uv2, dif=True)
rg11Dr   = rg11D.Dither_removegrain16(11, rg11)

abrg11D  = rg11D.Dither_lut16("x 32768 - abs", U=uv2, V=uv2)
Ddiff    = Dither_sub16(rg11D, rg11Dr, U=uv2, V=uv2, dif=True)
abDdiff  = Ddiff.Dither_lut16("x 32768 - abs", U=uv2, V=uv2)
abDDD    = Dither_sub16(abDdiff, abrg11D, U=uv2, V=uv2, dif=True)

Dmask1   = abDDD.Dither_lut16("x 32768 < 65535 0 ?", U=uv2, V=uv2)
Ddiffg   = Ddiff.Dither_lut16("x 32768 == x  x 32768 < 0 65535 ? ?", U=uv2, V=uv2).Crop(0, 0, 0, -Ddiff.Height()/2)
rg11Dg   = rg11D.Dither_lut16("x 32768 == x  x 32768 < 0 65535 ? ?", U=uv2, V=uv2).Crop(0, 0, 0, -rg11D.Height()/2)
Dmask2   = mt_lutxy(Ddiffg, rg11Dg, "x 128 - y 128 - * 0 < 0 255 ?", U=uv2, V=uv2)

DD1      = Dither_merge16(rg11D, Ddiff, Dmask1, luma=False, U=uv2, V=uv2)
DD2      = Dither_merge16_8(DD1.CSmod16_gen_null_diff(), DD1, Dmask2, luma=False, U=uv2, V=uv2)

return clp.Dither_sub16(DD2, U=uv, V=uv, dif=True)
}

###############################################################################################################################

Function CSmod16_nrSpline64Resize16(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", bool "chroma", val "nr", bool "hpgauss") {

  w             = input.Width()
  h             = input.Height()/2
  
  target_width  = Default(target_width,      w)
  target_height = Default(target_height,     h)
  src_left      = Default(src_left,          0)
  src_top       = Default(src_top,           0)
  src_width     = Default(src_width,         w)
  src_height    = Default(src_height,        h)
  chroma        = Default(chroma,         True)
  nr            = Default(nr,             True)
  hpgauss       = Default(hpgauss,        True)

  nr        = IsInt(nr) ? Float(nr) : nr
  Assert( IsFloat(nr) || IsBool(nr), """CSmod16_nrSpline64Resize16: "nr" should be either bool or float!""" )

  res_mul   = Float( target_width * target_height ) / Float( w * h )
  res_mul   = min( max( res_mul, 1 ), 2.25 )
  nr_weight = IsFloat(nr)       ? nr
  \         : nr /* == True  */ ? Spline( res_mul, 1, 0, 2.25, 1, 3.5, 0, True )
  \         :    /* == False */   0
  nr_weight = min( max( nr_weight, 0 ), 1 )
  wmaskv    = Round(-65535*nr_weight)

    try {
    inputp = chroma ? input
	\               : input.ConvertToY8
	conv   = True
  } catch ( error_msg ) {
    inputp = input
	conv   = False
  }
  
  resize = input.Dither_resize16(target_width, target_height, src_left, src_top, src_width, src_height, kernel="Spline64", Y=3, U=chroma?3:1, V=chroma?3:1)
  nrres  = hpgauss ? input.Dither_resize16(target_width, target_height, src_left, src_top, src_width, src_height, kernel="Gaussian", a1=100, Y=3, U=chroma?3:1, V=chroma?3:1) : inputp.DitherPost(mode=-1, Y=3, U=chroma?3:1, V=chroma?3:1).GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100).Dither_convert_8_to_16()
  nrres  = hpgauss||chroma||!conv ? nrres : Eval("nrres.ConvertTo"+input.CSmod16_GetCSP())
  wmask  = resize.Dither_lut16(Y=wmaskv, U=chroma?wmaskv:1, V=chroma?wmaskv:1)

  resize = nr_weight == 0 ? resize
  \      : nr_weight == 1 ? resize.Dither_repair16(nrres, 1, chroma ? 1 : -1)
  \      :                  Dither_merge16(resize, resize.Dither_repair16(nrres, 1, chroma ? 1 : -1), wmask, luma=False, Y=3, U=chroma?3:1, V=chroma?3:1)
  
  return resize
}

###############################################################################################################################

Function CSmod16_GetCSP(clip c) {
  return c.IsPlanar ? c.IsYV12 ? "YV12" :
  \                   c.IsYV16 ? "YV16" :
  \                   c.IsYV24 ? "YV24" : c.CSmod16_Y8_YV411 :
  \      c.IsYUY2   ? "YUY2"   :
  \      c.IsRGB32  ? "RGB32"  :
  \      c.IsRGB24  ? "RGB24"  : "Unknown"
}


Function CSmod16_Y8_YV411(clip c) {
  try {
    c.UtoY
    csp = "YV411"
  } catch ( error_msg ) {
    csp = "Y8"
  }
  return csp
}

###############################################################################################################################

Function CSmod16_inpand16(clip input, int "Y", int "U", int "V")
{
Y          = Default(Y,        3)
U          = Default(U,        1)
V          = Default(V,        1)

input_msb  = input.Crop(0, 0, 0, input.Height()/2)
inpand_msb = input_msb.mt_inpand(Y=Y, U=U, V=V)
inpand_16  = inpand_msb.Dither_convert_8_to_16()

return inpand_16.Dither_repair16(input, Y==3?1:Y==2?0:-1, U==3?1:U==2?0:-1, V==3?1:V==2?0:-1)
}


Function CSmod16_expand16(clip input, int "Y", int "U", int "V")
{
Y          = Default(Y,        3)
U          = Default(U,        1)
V          = Default(V,        1)

input_msb  = input.Crop(0, 0, 0, input.Height()/2)
expand_msb = input_msb.mt_lut("x 1 +", Y=Y, U=U, V=V).mt_expand(Y=Y, U=U, V=V)
expand_16  = expand_msb.Dither_convert_8_to_16()

return expand_16.Dither_repair16(input, Y==3?1:Y==2?0:-1, U==3?1:U==2?0:-1, V==3?1:V==2?0:-1)
}


Function CSmod16_average16(clip input1, clip input2, int "Y", int "U", int "V")
{
Y          = Default(Y,        3)
U          = Default(U,        3)
V          = Default(V,        3)

hmask = input1.CSmod16_gen_null_diff()

return Dither_merge16(input1, input2, hmask, luma=False, Y=Y, U=U, V=V)
}


Function CSmod16_limitdiff16(clip diff1, clip diff2, int "Y", int "U", int "V")
{
Y          = Default(Y,        3)
U          = Default(U,        3)
V          = Default(V,        3)

sh         = diff1.Height()/2

nulldiff   = diff1.CSmod16_gen_null_diff(lsb_in=True)
maxdif     = Dither_max_dif16(diff1, diff2, nulldiff, Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)
bin_stack  = mt_lutxy(diff1, maxdif, "x y == 255 0 ?", Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)
bin_msb    = bin_stack.Crop(0, 0, 0, sh)
bin_lsb    = bin_stack.Crop(0, sh, 0, 0)
bin        = mt_logic(bin_msb, bin_lsb, "min", Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)

return Dither_merge16_8(diff1, diff2, bin, luma=False, Y=Y, U=U, V=V)
}


Function CSmod16_min_dif16(clip src1, clip src2, clip ref, int "Y", int "U", int "V")
{
Y          = Default(Y,        3)
U          = Default(U,        3)
V          = Default(V,        3)

sh         = ref.Height()/2

maxdif     = Dither_max_dif16(src1, src2, ref, Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)
bin_stack  = mt_lutxy(src1, maxdif, "x y == 255 0 ?", Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)
bin_msb    = bin_stack.Crop(0, 0, 0, sh)
bin_lsb    = bin_stack.Crop(0, sh, 0, 0)
bin        = mt_logic(bin_msb, bin_lsb, "min", Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)

return Dither_merge16_8(src1, src2, bin, luma=False, Y=Y, U=U, V=V)
}


Function CSmod16_clamp16(clip c, clip bright_limit, clip dark_limit, float "overshoot", float "undershoot", int "Y", int "U", int "V")
{
Y          = Default(Y,          3)
U          = Default(U,          1)
V          = Default(V,          1)
overshoot  = Default(overshoot,  0)
undershoot = Default(undershoot, 0)
os16       = string(overshoot *256)
us16       = string(undershoot*256)

brightdiff = Dither_sub16(c, bright_limit, Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1, dif=True)
darkdiff   = Dither_sub16(c,   dark_limit, Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1, dif=True)

brightDdec = brightdiff.Dither_lut16("x " + os16 + " - 32768 > x " + os16 + " - 32768 ?", Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)
darkDdec   = darkdiff  .Dither_lut16("x " + us16 + " + 32768 < x " + us16 + " + 32768 ?", Y=Y==3?3:1, U=U==3?3:1, V=V==3?3:1)

return c.Dither_sub16(brightDdec, Y=Y, U=U, V=V, dif=True).Dither_sub16(darkDdec, Y=Y, U=U, V=V, dif=True)
}


Function CSmod16_gen_null_diff(clip input, bool "lsb_in", bool "lsb")
{
    lsb_in     = Default(lsb_in, True  )
    lsb        = Default(lsb,    lsb_in)
    
    input      = lsb_in ? input.Crop(0, 0, 0, input.Height()/2) : input
    output     = input.BlankClip(color_yuv=$808080)
    output     = lsb    ? StackVertical(output, input.BlankClip(color_yuv=$000000)) : output
    
    return output
}