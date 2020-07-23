################################################################################################
###                                                                                          ###
###                           Simple MDegrain Mod - SMDegrain()                              ###
###                                                                                          ###
###                       Mod by Dogway - Original idea by Caroliano                         ###
###                                                                                          ###
###          Special Thanks: Sagekilla, Didée, cretindesalpes, Gavino and MVtools people     ###
###                                                                                          ###
###                       v2.1d (Dogway's mod) - 09 September 2012                           ###
###                                                                                          ###
################################################################################################
###
### General purpose simple degrain function. Pure temporal denoiser. Basically a wrapper(function)/frontend of mvtools2+mdegrain
### with some common related options added. Aim is at accessibility and quality but not targeted to any specific kind of source.
### The reason behind is to keep it simple so aside masktools2 you will only need MVTools2.
###
### Check documentation for deep explanation on settings and defaults.
### Doom10 thread: (http://doom10.org/index.php?topic=2178.0)
###
################################################################################################

function SMDegrain (clip input   , int "tr"      , int "thSAD"    , int  "thSADC" , bool "RefineMotion",  val  "contrasharp", clip "CClip"      , bool "interlaced" ,  int   "plane" ,  int   "Globals",               \
                     int "pel"   , int "subpixel", val "prefilter", int  "blksize", int  "overlap"     ,  int  "search"     , bool "truemotion" , int  "limit"      ,  int   "limitc",  int   "thSCD1" , int "thSCD2",  \
                    bool "chroma", int "hpad"    , int "vpad"     , bool "lsb"    , bool "lsb_in"      ,  bool "lsb_out"    , int  "mode"       , val  "Show"       ,  float "Str"   ,  float "Amp"){



# Defaults & Conditionals


tr           = default( tr,       3 )
thSAD        = default( thSAD,  400 )
thSAD2=int(thSAD/2)
thSADC       = default( thSADC, thSAD2)
RefineMotion = default( RefineMotion,false)

lsb_in       = default( lsb_in,  false)
lsb_out      = default( lsb_out, false)
lsb          = default( lsb    , lsb_in || lsb_out)
mode         = default( mode, 0 )

Globals      = default( Globals,  0 )
GlobalR = Globals == 1        ? true : false
GlobalO = Globals == 3        ? true : false
if1     = Defined(CClip)      ? true : false

Contrasharp  = default( Contrasharp, !GlobalO && if1 ? true : false)
Interlaced   = default( Interlaced,  false)

w       = input.width ()
h       = input.height()
sShow   = IsString(show)      ? true : false
preclip = IsClip(prefilter)   ? true : false
planar  = IsYUY2(input)       ? true : false
ifC     = IsBool(Contrasharp) ? true : false
if0     = ifC ? (Contrasharp  ? true : false) : (Contrasharp > 0.0 ? true : false)
if2     = if0 && lsb && !GlobalO                                   ? true : false
if3     = tr > 3                                                   ? true : false
if4     = (w > 1279 ||  h > (lsb_in ? 1439 : 719))                 ? true : false
if5     = interlaced ? (GetParity(input)                           ? true : false) : nop()


pel          = default( pel, if4 ? 1 : 2 )
subpixel     = default( subpixel,  2 )
prefilter    = default( prefilter, 0 )
pelclip      = pel>1 && subpixel == 3 ? true : false
Str          = default( Str, 1.0 )
Amp          = default( Amp, 0.0625 )

blksize      = default( blksize,  if4 ? 16 : 8 )
blk2=blksize/2
overlap      = default( overlap,  blk2 )
ovl2=overlap/2
search       = default( search,   4 )
truemotion   = default( truemotion, !if4)
thSCD1       = default( thSCD1,  int(pow((blksize*2.5),2)))
thSCD2       = default( thSCD2,  130 )


plane        = default( plane,    4 )
chroma       = default( chroma,    true)
Chr          = chroma ? 3 : 1
plane0       = plane!=0        ? true : false
U            = plane0 && plane!=2 ? 3 : 2
V            = plane0 && plane!=1 ? 3 : 2
Uin          = lsb_in ? 3 : u
Vin          = lsb_in ? 3 : v


hpad         = if4 ? 0 : blksize
vpad         = if4 ? 0 : blksize
limit        = default( limit,  255 )
limitc       = default( limitc,limit)

Show         = default( Show,  false)




# Error Report

                Assert(blksize==4 || blksize==8 || blksize==16 || blksize==32,"MAnalyse: Block's size must be 4x4, 8x4, 8x8, 16x2, 16x8, 16x16, 32x16, 32x32")
                Assert(overlap <= blk2,              "Overlap must be at least half blksize or less")
                Assert(overlap == overlap-overlap%2, "MAnalyse: overlap must be an even figure")
                Assert(IsBool(Show) || sShow,        "'Show' only accepts bool inputs (true,false), or string modes ('Speed','Memory',Quality')")
                Assert(preclip || IsInt(prefilter),  "'prefilter' only accepts integers and clip inputs")
                Assert(ifC     || IsInt(Contrasharp),"'Contrasharp' only accepts integers and bool inputs")
interlaced    ? Assert(h%4==0,                       "Interlaced sources require mod 4 height sizes")             : nop()
lsb_in        ? Assert(!interlaced,                  "Interlaced 16 bit stacked clip is not a recognized format") : nop()
planar && if0 ? Assert(ifC,                          "LSFmod doesn't support YUY2 sources")                       : nop()
RefineMotion  ? Assert(blksize > 7,                  "For RefineMotion you need a blksize of at least 8")         : nop()
lsb_in        ? Assert(lsb,                          "lsb_in  requires: lsb=true")                                : nop()
lsb_out       ? Assert(lsb,                          "lsb_out requires: lsb=true")                                : nop()



# RefineMotion Variables

halfblksize  = RefineMotion ?  blk2                                     : nop() # MRecalculate works with half block size
halfoverlap  = RefineMotion ? (overlap == 2 ? overlap : ovl2+ovl2%2)    : nop() # Halve the overlap to suit the halved block size
halfthSAD    = RefineMotion || if3 ?     thSAD2                         : nop() # MRecalculate uses a more strict thSAD, which defaults to 150 (half of function's default of 300)
halfthSADC   =                 if3 ? int(thSADC/2)                      : nop() # For MDegrainN()






# Input preparation for: LSB_IN, Interlacing, Planar and MSuper optimization when pel=2

inputY  = planar      ? (lsb_in   ? Dither_YUY2toPlanar16(input)          : Interleaved2planar(input))                          : input

inputP  = !interlaced ? (pel == 2 ? inputY.AssumeFrameBased()             : inputY)                                             : \
                        (if5      ? inputY.AssumeTFF().SeparateFields()   : inputY.AssumeBFF().SeparateFields())

input8h = lsb_in      ?             inputP. Ditherpost(mode=6)                                                                  : nop()
input8y = planar      ? (lsb_in   ? input8h.Dither_YUY2toInterleaved()    : inputP)                                             : inputP
input8  = lsb_in      ? (planar   ? input8y.Interleaved2planar()                                                                : \
                                    input8h)                                                                                    : input8y



# Prefilter

bug_wa = interlaced && planar && chroma ? 1 : Chr # bug: crash prevention workaround (http://forum.doom9.org/showthread.php?p=1546684#post1546684)

pref   = !GlobalR ? ( preclip       ?  prefilter                                                                  : \
                    ((prefilter==0) ?  inputP                                                                     : \
                     (prefilter==1) ?  input8.MinBlur(1,Chr,planar)                                               : \
                     (prefilter==2) ?  input8.MinBlur(2,Chr,planar)                                               : \
                     (prefilter==3) ?  (!planar && lsb ? Dither_merge16_8(inputP.Dfttest(sstring="0.0:4.0 0.2:9.0 1.0:15.0",tbsize=1,u=chroma,v=chroma,lsb=true,lsb_in=lsb_in,quiet=true), lsb_in?inputP:inputP.Dither_convert_8_to_16(),          \
                                                                   lsb_in?inputP.Dither_lut16("x 4096 < 65535 x 19200 > 0 65535 x 4096 - 65535 19200 4096 - / * - ? ?",u=1,v=1).Ditherpost(mode=6,u=Chr,   v=Chr)                                  \
                                                                         :inputP.mt_lut(      "x 16 < 255 x 75 > 0 255 x 16 - 255 75 16 - / * - ? ?",u=1,v=1), luma=chroma,                       u=Chr,   v=Chr)                                : \
                                                             mt_merge( planar ?  Dfttest(!lsb_in?inputP.Planar2Interleaved(!chroma):input8y,sstring="0.0:4.0 0.2:9.0 1.0:15.0",tbsize=1,u=chroma,v=chroma,dither=1).Interleaved2Planar(!chroma)  : \
                                                                                 Dfttest(        inputP,                                    sstring="0.0:4.0 0.2:9.0 1.0:15.0",tbsize=1,u=chroma,v=chroma,dither=1),input8y,                       \
                                                                          input8.mt_lut(      "x 16 < 255 x 75 > 0 255 x 16 - 255 75 16 - / * - ? ?",u=1,v=1), luma=planar?false:chroma,          u=bug_wa,v=bug_wa))                            : \
                      Assert(false,    "Mode must be between 0~3: "+string(prefilter))))                          : \
                      input8





# Default Auto-Prefilter - Luma expansion TV->PC (up to 16% more values for motion estimation)

pref   = !GlobalR ? (!planar && lsb ? ((!preclip ? ((lsb_in && prefilter==0) || prefilter==3 ) : false)                                                       ? \
                     pref.Dither_Luma_Rebuild(S0=Str,c=Amp,lsb_in=true,uv=Chr)  : \
                     pref.Dither_Luma_Rebuild(S0=Str,c=Amp,lsb   =true,uv=Chr)) : \
                                      ((!preclip ?  (lsb_in && prefilter==0)    :                false)                                                       ? \
                     pref.Ditherpost(mode=6,u=Chr,v=Chr).Dither_YUY2toInterleaved().Interleaved2planar(!chroma).Dither_Luma_Rebuild(S0=Str,c=Amp,uv=Chr   )   : \
                     pref.                                                                                      Dither_Luma_Rebuild(S0=Str,c=Amp,uv=bug_wa))) : \
                     pref





(sShow ? false : !Show) ? eval("""


# Subpixel 3

pclip  = pelclip              ?    pref.nnedi3_rpow2(rfactor=pel,nns=4,qual=2)  : nop()
pclip2 = pelclip && !GlobalR  ?  input8.nnedi3_rpow2(rfactor=pel,nns=4,qual=2)  : nop()




# Motion vectors search


super_search =                             pelclip ? MSuper(pref,     pel=pel,               chroma=chroma, hpad=hpad, vpad=vpad,          pelclip=pclip,  rfilter=4, planar=planar) : \
                                                     MSuper(pref,     pel=pel,sharp=subpixel,chroma=chroma, hpad=hpad, vpad=vpad                        ,  rfilter=4, planar=planar)
super_render = !GlobalR ?                 (pelclip ? MSuper(input8,   pel=pel,               chroma=plane0, hpad=hpad, vpad=vpad,levels=1, pelclip=pclip2           , planar=planar) : \
                                                     MSuper(input8,   pel=pel,sharp=subpixel,chroma=plane0, hpad=hpad, vpad=vpad,levels=1                           , planar=planar)): super_search
Recalculate  = !GlobalR && RefineMotion ? (pelclip ? MSuper(pref,     pel=pel,               chroma=chroma, hpad=hpad, vpad=vpad,levels=1, pelclip=pclip            , planar=planar) : \
                                                     MSuper(pref,     pel=pel,sharp=subpixel,chroma=chroma, hpad=hpad, vpad=vpad,levels=1                           , planar=planar)): nop()
!if3  ? eval("
bv6  =   interlaced && (tr > 2)                  ? (!GlobalR  ? super_search.MAnalyse(isb = true, delta = 6,  overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         bv6) :  nop()
bv6  =   interlaced && (tr > 2) && RefineMotion &&  !GlobalR  ?   MRecalculate           (Recalculate, bv6,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  bv6
bv4  =   interlaced && (tr > 1)                  ? (!GlobalR  ? super_search.MAnalyse(isb = true, delta = 4,  overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         bv4) :  nop()
bv4  =   interlaced && (tr > 1) && RefineMotion &&  !GlobalR  ?   MRecalculate           (Recalculate, bv4,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  bv4
bv3  =  !interlaced ? ((tr > 2)                  ? (!GlobalR  ? super_search.MAnalyse(isb = true, delta = 3,  overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         bv3) :  nop()) : nop()
bv3  =  !interlaced ? ((tr > 2  && RefineMotion &&  !GlobalR) ?   MRecalculate           (Recalculate, bv3,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  bv3               )   : nop()
bv2  =  (interlaced ||  tr > 1)                  ? (!GlobalR  ? super_search.MAnalyse(isb = true, delta = 2,  overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         bv2) :  nop()
bv2  = ((interlaced ||  tr > 1) && RefineMotion &&  !GlobalR) ?   MRecalculate           (Recalculate, bv2,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  bv2
bv1  =  !interlaced ?                              (!GlobalR  ? super_search.MAnalyse(isb = true, delta = 1,  overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         bv1        ) : nop()
bv1  =  !interlaced ?            ( RefineMotion &&  !GlobalR  ?   MRecalculate           (Recalculate, bv1,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  bv1               ) : nop()

fv1  =  !interlaced ?                              (!GlobalR  ? super_search.MAnalyse(isb = false, delta = 1, overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         fv1        ) : nop()
fv1  =  !interlaced ?            ( RefineMotion &&  !GlobalR  ?   MRecalculate           (Recalculate, fv1,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  fv1               ) : nop()
fv2  =  (interlaced ||  tr > 1)                  ? (!GlobalR  ? super_search.MAnalyse(isb = false, delta = 2, overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         fv2) :  nop()
fv2  = ((interlaced ||  tr > 1) && RefineMotion &&  !GlobalR) ?   MRecalculate           (Recalculate, fv2,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  fv2
fv3  =  !interlaced ? ((tr > 2)                  ? (!GlobalR  ? super_search.MAnalyse(isb = false, delta = 3, overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         fv3) :  nop()) : nop()
fv3  =  !interlaced ? ((tr > 2  && RefineMotion &&  !GlobalR) ?   MRecalculate           (Recalculate, fv3,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  fv3               )   : nop()
fv4  =   interlaced && (tr > 1)                  ? (!GlobalR  ? super_search.MAnalyse(isb = false, delta = 4, overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         fv4) :  nop()
fv4  =   interlaced && (tr > 1) && RefineMotion &&  !GlobalR  ?   MRecalculate           (Recalculate, fv4,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  fv4
fv6  =   interlaced && (tr > 2)                  ? (!GlobalR  ? super_search.MAnalyse(isb = false, delta = 6, overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma, truemotion=truemotion) :         fv6) :  nop()
fv6  =   interlaced && (tr > 2) && RefineMotion &&  !GlobalR  ?   MRecalculate           (Recalculate, fv6,   overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma, truemotion=truemotion) :  fv6 " )     : \
 \
eval("
tr2    = tr*2
vmulti =                   !GlobalR ? super_search.MAnalyse( multi=true,overlap=    overlap,blksize=    blksize,   search=search,chroma=chroma,truemotion=truemotion, delta = interlaced ? tr2 : tr) : vmulti
vmulti = RefineMotion   ? (!GlobalR ? MRecalculate (Recalculate, vmulti,overlap=halfoverlap,blksize=halfblksize, thSAD=halfthSAD,chroma=chroma,truemotion=truemotion,    tr = interlaced ? tr2 : tr) : vmulti) : vmulti
vmulti =                   !GlobalR ? (interlaced ? vmulti.SelectEvery (4, 2, 3) : vmulti) : vmulti.SelectRangeEvery (Rtr*2, tr2, 0, false)")



# Finally, MDegrain


output  = !GlobalO ? (interlaced ?
 \        ((lsb ?     ( if3  ? input8.MDegrainN(super_render, vmulti, tr, thSAD2=halfthSAD, thSADC2=halfthSADC, thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true) :
 \                 (tr == 3) ? input8.MDegrain3(super_render, bv2, fv2, bv4, fv4, bv6, fv6,                     thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true) :
 \                 (tr == 2) ? input8.MDegrain2(super_render, bv2, fv2, bv4, fv4,                               thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true) :
 \                             input8.MDegrain1(super_render, bv2, fv2,                                         thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true)):
 \                    ( if3  ? input8.MDegrainN(super_render, vmulti, tr, thSAD2=halfthSAD, thSADC2=halfthSADC, thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=false):
 \                 (tr == 3) ? input8.MDegrain3(super_render, bv2, fv2, bv4, fv4, bv6, fv6,                     thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar)          :
 \                 (tr == 2) ? input8.MDegrain2(super_render, bv2, fv2, bv4, fv4,                               thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar)          :
 \                             input8.MDegrain1(super_render, bv2, fv2,                                         thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar))))       :
 \         (lsb ?     ( if3  ? input8.MDegrainN(super_render, vmulti, tr, thSAD2=halfthSAD, thSADC2=halfthSADC, thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true) :
 \                 (tr == 3) ? input8.MDegrain3(super_render, bv1, fv1, bv2, fv2, bv3, fv3,                     thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true) :
 \                 (tr == 2) ? input8.MDegrain2(super_render, bv1, fv1, bv2, fv2,                               thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true) :
 \                             input8.MDegrain1(super_render, bv1, fv1,                                         thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=true)):
 \                    ( if3  ? input8.MDegrainN(super_render, vmulti, tr, thSAD2=halfthSAD, thSADC2=halfthSADC, thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar,lsb=false):
 \                 (tr == 3) ? input8.MDegrain3(super_render, bv1, fv1, bv2, fv2, bv3, fv3,                     thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar)          :
 \                 (tr == 2) ? input8.MDegrain2(super_render, bv1, fv1, bv2, fv2,                               thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar)          :
 \                             input8.MDegrain1(super_render, bv1, fv1,                                         thSAD=thSAD, thSADC=thSADC, thSCD1=thSCD1, thSCD2=thSCD2, limit=limit, limitc=limitc, plane=plane, planar=planar))))       : nop()


# LSB_IN merging

outputI= !GlobalO && planar && (lsb || ifC) ? output.Planar2Interleaved()                                                                              : nop()
!GlobalO && lsb   ? eval("
blnkclp= lsb_in  || (if2 && !planar) ? BlankClip (lsb_in?input8h:input8, pixel_type="+Chr(34)+"YV12"+Chr(34)+", color_yuv=0)                           : nop()
output = lsb && planar               ? Dither_YUY2toPlanar16(outputI)                                                                                  : output
output = lsb_in   ? (!if4            ? Dither_merge16_8 (inputY,output,DitherBuildMask(input8h,output.Ditherpost(mode=6,u=u,v=v)),u=u,v=v)             : \
                                       Dither_merge16_8 (inputY,output,mt_lutxy(input8h,output.Ditherpost(mode=6,u=u,v=v),expr="+Chr(34)+"x y == 0 255 ?"+Chr(34)+",y=3,u=u,v=v).mt_expand(u=u,v=v),u=u,v=v)) : output") : nop()



# Contrasharp (only sharpens luma)

ifC && if0 && if4 ? eval("
global Super           = super_render
global cb1             = !if3 ? (interlaced ? bv2 : bv1) : vmulti.SelectEvery (tr2, 0)
global cf1             = !if3 ? (interlaced ? fv2 : fv1) : vmulti.SelectEvery (tr2, 1)") : nop()

!GlobalO && if0   ? eval("

CCh   =       if1 ? CClip.height() : nop()
ref8  =       if1 ? (h == CCh*2)   : nop()
ref16 =       if1 ? (h == CCh/2)   : nop()

interlaced && if1 ? Assert(!ref16, "+Chr(34)+"Interlaced 16 bit stacked CClip is not a recognized format"+Chr(34)+")         : nop()

CClip = planar ?  (if1 ?  (lsb_in ? (ref8 ? CClip.Interleaved2planar(true) : CClip.Dither_YUY2toPlanar16().DitherPost(mode=-1,u=1,v=1).Dither_YUY2toInterleaved().Interleaved2planar(true))                         : \
                                     (interlaced ? (if5 ? CClip.AssumeTFF().SeparateFields().Interleaved2planar(true) : CClip.AssumeBFF().SeparateFields().Interleaved2planar(true))                                : \
                                     (ref16 ? CClip.Dither_YUY2toPlanar16().DitherPost(mode=-1,u=1,v=1).Dither_YUY2toInterleaved().Interleaved2planar(true) : CClip.Interleaved2planar(true))))                     : \
                          (lsb_in ?  inputY.DitherPost(mode=-1,u=1,v=1).Dither_YUY2toInterleaved().Interleaved2planar(true)                                                                                         : \
                                     inputP))                                                                                                                                                                       : \
                  (if1 ?  (lsb_in ? (ref8 ? CClip : CClip.DitherPost(mode=-1,u=1,v=1))                                                                                                                              : \
                                     (interlaced ? (if5 ? CClip.AssumeTFF().SeparateFields()                          : CClip.AssumeBFF().SeparateFields()) : (ref16 ? CClip.DitherPost(mode=-1,u=1,v=1) : CClip))) : \
                          (lsb_in ?  input.DitherPost(mode=-1,u=1,v=1)                                                                                                                                              : \
                                     inputP))")                                                                                                                                                                     : nop()


!GlobalO && if2   ? eval("
OutTO8  = output.DitherPost(mode=-1,u=1,v=1)
OutTO8P = planar  ? OutTO8.Dither_YUY2toInterleaved()                                                                                                       : nop()
ctr16   = ifC     ? ContrasharpeningHD (planar ? OutTO8P.Interleaved2planar(true):OutTO8, CClip, planar=planar, HD=if4)                                     : \
                    LSFmod(OutTO8,source=CClip,defaults="+Chr(34)+"slow"+Chr(34)+",strength=Contrasharp,soothe=false,Lmode=0,soft=0,keep=0)


ctr16P  = planar  ? ctr16.Planar2Interleaved(true)  : ctr16
ctr16   = StackVertical (ctr16P, planar ? BlankClip  (ctr16P, pixel_type="+Chr(34)+"YUY2"+Chr(34)+", color_yuv=0,length=1) : blnkclp )
ctr16   = planar  ? Dither_merge16_8(output, ctr16.Dither_YUY2toPlanar16(),  DitherBuildMask(ctr16P.Dither_YUY2toPlanar(),OutTo8), u=2,v=2)                 : \
                    Dither_merge16_8(output, ctr16,                          DitherBuildMask(ctr16P,OutTO8),                       u=2,v=2)
ctr16   = MergeChroma(ctr16, output)                                                                                                                     ") : nop()



# Globals Output

GlobalO || Globals == 2  ? (!if3 ? eval("
global Super           = super_render
global bv6             = bv6
global bv4             = bv4
global bv3             = bv3
global bv2             = bv2
global bv1             = bv1

global fv1             = fv1
global fv2             = fv2
global fv3             = fv3
global fv4             = fv4
global fv6             = fv6
") : eval("
global bv1             =                                            vmulti.SelectEvery (tr2, 0)
global bv2             = interlaced ? bv1                         : vmulti.SelectEvery (tr2, 2)
global bv3             =                                            vmulti.SelectEvery (tr2, 4)
global bv4             = interlaced ? vmulti.SelectEvery (tr2, 2) : nop()
global bv6             = interlaced ? bv3                         : nop()

global fv1             =                                            vmulti.SelectEvery (tr2, 1)
global fv2             = interlaced ? fv1                         : vmulti.SelectEvery (tr2, 3)
global fv3             =                                            vmulti.SelectEvery (tr2, 5)
global fv4             = interlaced ? vmulti.SelectEvery (tr2, 3) : nop()
global fv6             = interlaced ? fv3                         : nop()
global Super           = super_render
global vmulti          = vmulti
global Rtr             = tr")) : nop()



# Output

!GlobalO ? (lsb_out ? (if0 ? ctr16 : output)  : \
                      (if0 ? (lsb ?  (interlaced ?  ctr16.weave().DitherPost(u=u,v=v,mode=6,interlaced=true)               :  ctr16.DitherPost(mode=mode,u=Uin,v=Vin))                                                                    : \
                                     (interlaced ? (ifC ? ContraSharpeningHD(output, CClip, planar=planar, HD=if4).weave() : LSFmod(output,source=CClip,defaults="slow",strength=Contrasharp,soothe=false,Lmode=0,soft=0,keep=0).weave()) : \
                                                   (ifC ? ContraSharpeningHD(output, CClip, planar=planar, HD=if4)         : LSFmod(output,source=CClip,defaults="slow",strength=Contrasharp,soothe=false,Lmode=0,soft=0,keep=0))))       : \
                             (lsb ?  (interlaced ? output.weave().DitherPost(u=u,v=v,mode=6,interlaced=true)               : output.DitherPost(mode=mode,u=Uin,v=Vin)) : (interlaced ? output.weave() : output))))                          \
         :  input

!GlobalO ? (planar ? (lsb ? Dither_YUY2toInterleaved() : (ifC ? MergeChroma(Planar2Interleaved(true), outputI) : Planar2Interleaved())) : last) : last """) : \
 \
 \
 \
 \
 \
eval("""

##############
# SHOW PANEL #
##############


  # Common Variables

w2    = w*1.0
h2    = h*1.0
AR    = w2/h2
lsp   = interlaced?15:30
lsp   = AR < 1.9 ? lsp : floor(AR < 1.9 ? lsp : ((AR>2.4) ? 0 : lsp-((AR-1.9)*(lsp/(2.4-1.9)))))
ys    = round(lsb_in ? h2/12 : (interlaced?h2/15:h2/6))
s     = floor(((interlaced?w2/1.6:w2)/720.0)*16.0)
mod8  = interlaced?h/2%8:h%8
type  = planar?"YUY2":"YV12"

Wadd  = w2/40
Wadd2 = Wadd/2
w1    = round(w2+Wadd+Wadd2)
w3    = (w2/3)+Wadd/1.5
w2    = round(w1+w3)
w3    = round(w1+(w3+Wadd2)*1.96)
w3sq  = string(round(w3*1.01))
w3s   = string(w3)

  # Panel Separator

blkclp = BlankClip(interlaced?assumeframebased(pref):pref,length=1, pixel_type=type,color=$161616).crop(0,mod8,0,0).separatefields().assumeframebased().separatefields()
         StackHorizontal(pref,interleave(selecteven(blkclp).addborders(2,0,0,0,color=$7f7f7f).crop(0,0,-2,0),selectodd(blkclp)).weave().assumefieldbased().weave().addborders(0,mod8/2,0,mod8/2,color=$161616))

  # Color Guide Squares

hin=lsb_in?h/2:h
a=interlaced?hin*0.37:hin*0.74
b=interlaced?hin*0.40:hin*0.80
c=interlaced?hin*0.43:hin*0.86

!planar ? mt_merge(mt_lut(yexpr="127",uexpr="183",vexpr="47" ,u=3,v=3) ,mt_lutspa(mode="absolute", yexpr="x "+w3s+" >= x "+w3sq+" <= & y "+string(a)+" >= y "+string(interlaced?hin*0.3835:hin*0.767)+" <= & & 255 0 ?").trim(0,-1).FreezeFrame(0, FrameCount(pref)-1, 0),luma=true) : nop()
!planar ? mt_merge(mt_lut(yexpr="81" ,uexpr="91" ,vexpr="240",u=3,v=3) ,mt_lutspa(mode="absolute", yexpr="x "+w3s+" >= x "+w3sq+" <= & y "+string(b)+" >= y "+string(interlaced?hin*0.4135:hin*0.827)+" <= & & 255 0 ?").trim(0,-1).FreezeFrame(0, FrameCount(pref)-1, 0),luma=true) : nop()
!planar ? mt_merge(mt_lut(yexpr="210",uexpr="16" ,vexpr="146",u=3,v=3) ,mt_lutspa(mode="absolute", yexpr="x "+w3s+" >= x "+w3sq+" <= & y "+string(c)+" >= y "+string(interlaced?hin*0.4435:hin*0.887)+" <= & & 255 0 ?").trim(0,-1).FreezeFrame(0, FrameCount(pref)-1, 0),luma=true) : nop()


  # Parameters List

blue  = sShow ? (show=="Speed"   ? true : false) : false
red   = sShow ? (show=="Memory"  ? true : false) : false
yellow= sShow ? (show=="Quality" ? true : false) : false

Color = sShow ? (blue   ? $00aef0 : \
                 red    ? $ff0000 : \
                 yellow ? $ffff00 : \
                 Assert(false,    "Revise typo for possible color guide modes: 'Speed','Memory','Quality'")) : nop()



varn = "\n\n\n\n\n"
sp   = !GlobalR && str==1.0 ? "  " : ""

Subtitle("SMDegrain Mod v2.1",text_color=red||blue||yellow?Color:$7f7f7f,halo_color=$000000,font="VERDANA",size=s*2,x=w1,y=lsb_in?h/40:(interlaced?h/50:h/20))

Subtitle("BASIC"   ,lsp=lsp,text_color=$ffffff,font="COURIER NEW",size=s,x=w1,y=ys)
Subtitle(            "\n\ntr           = " + string(tr)                                                                              + \
         varn+varn+      "chroma       = " + string(chroma)                                                                          ,lsp=lsp,text_color=red||blue               ?Color:$ffffff,font="COURIER NEW",size=s,x=w1,y=ys)
Subtitle(          "\n\n\nthSAD(C)     = " + string( GlobalO?"bypass":string(thSAD)     + "(" + string(plane0?thSADC:"bypass") + ")")+ \
         varn+           "CClip        = " + string( GlobalO?"bypass":(defined(CClip)?"defined":"undefined"))                        + \
                     "\n\nInterlaced   = " + string(interlaced)                                                                      ,lsp=lsp,text_color=                               $ffffff,font="COURIER NEW",size=s,x=w1,y=ys)
Subtitle(varn+           "RefineMotion = " + string( GlobalO?"bypass":RefineMotion)                                                  ,lsp=lsp,text_color=yellow                  ?Color:$ffffff,font="COURIER NEW",size=s,x=w1,y=ys)
Subtitle(varn+       "\n\nContrasharp  = " + string( GlobalO?"bypass":contrasharp)                                                   ,lsp=lsp,text_color=yellow&&!GlobalO        ?Color:$ffffff,font="COURIER NEW",size=s,x=w1,y=ys)
Subtitle(varn+varn+    "\nplane        = " + string( GlobalO?"bypass":(plane==0?"0 (Luma)":plane==1?"1 (U plane)":plane==2?"2 (V plane)":plane==3?"3 (Chroma)":"4(Luma+Chroma)")),lsp=lsp,text_color=(red||blue)&&!GlobalO?Color:$ffffff,font="COURIER NEW",size=s,x=w1,y=ys)
Subtitle("<-- "+string(IsClip(prefilter)||prefilter!=0?"Prefiltered clip ":"Clip ")+"converted to PC levels\n"+"    ready to be used for the motion search",lsp=lsp,text_color=$ffffff,font="COURIER NEW",size=s,x=w1,y=(interlaced||lsb_in?h/2:h)-int(ys/1.5))

Subtitle("ADVANCED",lsp=lsp,text_color=$7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)
Subtitle(              "\n\npel        = " + string(pel)                                                                             ,lsp=lsp,text_color=red                     ?Color:$7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)
Subtitle(            "\n\n\nsubpixel   = " + string( pel==1 ?"bypass":subpixel)                                                      ,lsp=lsp,text_color=(yellow||blue)&&pel!=1  ?Color:$7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)
Subtitle(varn+varn+    "\n\ntruemotion = " + string( GlobalR?"bypass":truemotion)                                                    ,lsp=lsp,text_color=(yellow||blue)&&!GlobalR?Color:$7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)
Subtitle(varn+           "\nStr        = " + (GlobalR?string("bypass"):string(Str,"%1.2f"))+sp+" Brightness"                         + \
         varn+             "search     = " + string( GlobalR?"bypass":search)                                                        ,lsp=lsp,text_color=yellow&&!GlobalR        ?Color:$7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)
Subtitle(varn+     "\n\n\n\nblksize    = " + string( GlobalR?"bypass":blksize)                                                       + \
                         "\noverlap    = " + string( GlobalR?"bypass":overlap)                                                       ,lsp=lsp,text_color=(red||blue)&&!GlobalR   ?Color:$7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)
Subtitle(varn+             "prefilter  = " + (GlobalR?string("bypass"):(preclip?"Clip"+sp+" Variable":(prefilter==1?"1"+sp+"    MinBlur(1)":prefilter==2?"2"+sp+"    MinBlur(2)":prefilter==3?"3"+sp+"    Dfttest":"0"+sp+"    OFF"))) + \
                       "\n\nAmp        = " + (GlobalR||str==1.0?string("bypass"):string(Amp,"%1.2f"))+" Amplitude"                   + \
         varn+           "\nlimit(C)   = " + (GlobalO?string("bypass"):string(limit)     + "(" + string(limitc) + ")")               ,lsp=lsp,text_color=                               $7f7f7f,font="COURIER NEW",size=s,x=w2,y=ys)

Subtitle("OTHERS"  ,lsp=lsp,text_color=$494949,font="COURIER NEW",size=s,x=w3,y=ys)
Subtitle(             "\n\n\nthSCD1(2) = " + (GlobalO?string("bypass"):string(thSCD1) + "(" + string(thSCD2) + ")")                  + \
                    "\n\n\n\nlsb_out   = " + string(lsb_out)                                                                         + \
                      "\n\n\nGlobals   = " + string(Globals==0 ? "0 (OFF)" : Globals==1 ? "1 (Import)" : Globals==2 ? "2 (Export)" : "3 (E.Only)"),lsp=lsp,text_color=                  $494949,font="COURIER NEW",size=s,x=w3,y=ys)
Subtitle(               "\n\nhpad(v)   = " + string(hpad)   + "(" + string(vpad)   + ")"                                             ,lsp=lsp,text_color=red||blue               ?Color:$494949,font="COURIER NEW",size=s,x=w3,y=ys)
Subtitle(varn+              "lsb       = " + string(lsb)                                                                             ,lsp=lsp,text_color=yellow                  ?Color:$494949,font="COURIER NEW",size=s,x=w3,y=ys)
Subtitle(varn+            "\nlsb_in    = " + string(lsb_in)                                                                          ,lsp=lsp,text_color=red                     ?Color:$494949,font="COURIER NEW",size=s,x=w3,y=ys)
Subtitle(varn+        "\n\n\nmode      = " + (GlobalO||(lsb_out||!lsb)?string("bypass"):interlaced?"6 (locked)":string(mode))        ,lsp=lsp,text_color=yellow&&!GlobalO&&lsb   ?Color:$494949,font="COURIER NEW",size=s,x=w3,y=ys)

Subtitle("   Speed"   ,lsp=interlaced?15:30,text_color=planar?$00aef0:$7f7f7f,font="COURIER NEW",size=s,x=w3,y=int(a-1))
Subtitle("   Memory"  ,lsp=interlaced?17:34,text_color=planar?$ff0000:$7f7f7f,font="COURIER NEW",size=s,x=w3,y=int(b-1))
Subtitle("   Quality" ,lsp=interlaced?19:38,text_color=planar?$ffff00:$7f7f7f,font="COURIER NEW",size=s,x=w3,y=int(c-1))

lsb_out ? StackVertical (last, BlankClip (last, pixel_type=type, color_yuv=0,length=1)) : last""")}





########################################################
#                                                      #
# HELPER FUNCTIONS: For Contrasharp and YUY2 handling  #
#                                                      #
########################################################

########################################
## Didée's functions:

 # contra-sharpening: sharpen the denoised clip, but don't add more to any pixel than what was removed previously.
 # script function from Didée, at the VERY GRAINY thread (http://forum.doom9.org/showthread.php?p=1076491#post1076491)

 # In final version 2.0d ContraHD() was merged, to allow proper HD sharpening.
 # In this case global variables of (before denoising) source MSuper and forward and backward
 # compensated motion vectors are necessary as: Super, cb1 and cf1, if used as a stand alone function.
 # Don't know who made (mod) it, so I can't give proper credits, sorry.

FUNCTION ContraSharpeningHD(clip denoised, clip original, bool "HD", bool "planar", int "overshoot"){
HD        = default(HD    ,false)
planar    = default(planar,false)
overshoot = default(overshoot,0)

HD ? eval("""
cb1=original.MCompensate(Super, cb1, planar=planar)
cf1=original.MCompensate(Super, cf1, planar=planar)
pmax = original.mt_logic(cb1, "max").mt_logic(cf1, "max")
pmin = original.mt_logic(cb1, "min").mt_logic(cf1, "min")""") : nop()

s    = denoised.MinBlur(HD?2:1,1,planar=planar)                                   # Damp down remaining spots of the denoised clip.
allD = mt_makediff(original,denoised)                                             # The difference achieved by the denoising.
ssD  = mt_makediff(s,HD?s.removegrain(20,-1,planar=planar).\
                          removegrain(20,-1,planar=planar):\
                        s.removegrain(11,-1,planar=planar))                       # The difference of a simple kernel blur.
ssDD = ssD.repair(HD?ssD.repair(allD,1,planar=planar):allD,HD?12:1,planar=planar) # Limit the difference to the max of what the denoising removed locally.
ssDD = SSDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?")                       # abs(diff) after limiting may not be bigger than before.

denoised.mt_adddiff(ssDD,U=2,V=2)                                                 # Apply the limited difference. (Sharpening is just inverse blurring)
HD ? mt_clamp(last,pmax,pmin,overshoot,overshoot,chroma="copy first") : last
}

 # MinBlur   by Didée (http://avisynth.org/mediawiki/MinBlur)
 # Nifty Gauss/Median combination (Modified for Planar input)

function MinBlur(clip clp, int "r", int "uv", bool "planar"){

r      = default(r,1)
uv     = default(uv,3)
planar = default(planar,false)

uv2    = (uv==2) ? 1  : uv
rg4    = (uv==3) ? 4  : -1
rg11   = (uv==3) ? 11 : -1
rg20   = (uv==3) ? 20 : -1
medf   = (uv==3) ? 1  : -200
uvm2   = r==2 ? (uv==3?2:uv==2?0:-1) : nop()
uvm3   = r==3 ? (uv==3?3:uv==2?0:-1) : nop()

RG11D = (r==0) ? mt_makediff(clp,clp.sbr(),U=uv2,V=uv2)
 \    : (r==1) ? mt_makediff(clp,clp.removegrain(11,rg11,planar=planar),U=uv2,V=uv2)
 \    : (r==2) ? mt_makediff(clp,clp.removegrain(11,rg11,planar=planar).removegrain(20,rg20,planar=planar),U=uv2,V=uv2)
 \    :          mt_makediff(clp,clp.removegrain(11,rg11,planar=planar).removegrain(20,rg20,planar=planar).removegrain(20,rg20,planar=planar),U=uv2,V=uv2)
RG4D  = (r<=1) ? mt_makediff(clp,clp.removegrain(4,rg4,planar=planar),U=uv2,V=uv2)
 \    : (r==2) ? mt_makediff(clp,clp.Quantile(radius_y=2, radius_u=uvm2, radius_v=uvm2 ,planar=planar), U=uv2,V=uv2)
 \    :          mt_makediff(clp,clp.Quantile(radius_y=3, radius_u=uvm3, radius_v=uvm3, planar=planar), U=uv2,V=uv2)
DD    = mt_lutxy(RG11D,RG4D,"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?",U=uv2,V=uv2)
clp.mt_makediff(DD,U=uv,V=uv)
}


########################################
## cretindesalpes' functions: (http://forum.doom9.org/showthread.php?p=1505297#post1505297)

# Converts 16 bit interleaved YUY2 to 16bit planar YUY2 suitable for Ditherpost. (Use right before Ditherpost; this format is not suitable for filtering)

function Dither_YUY2toPlanar16(c){c
my = Dither_get_msb().ConvertToYV12()
ly = Dither_get_lsb().ConvertToYV12()
u = UToY ().ConvertToYV12 ()
v = VToY ().ConvertToYV12 ()
YToUV (u, v, StackVertical (StackVertical (my, my), StackVertical (ly, ly)))}


# Converts 8 bit interleaved YUY2 to 8 bit planar YUY2 ready for either 8 or 16 bit processing also suitable for Ditherpost

function Dither_YUY2toPlanar(c){c
y = ConvertToYV12 ()
u = UToY ().ConvertToYV12 ()
v = VToY ().ConvertToYV12 ()
YToUV (u, v, StackVertical (y, y))}


# Converts back the above special planar formats to normal interleaved YUY2

function Dither_YUY2toInterleaved(c){c
y = Crop (0, 0, 0, Height () /(2)).ConvertToYUY2 ()
u = UToY ().ConvertToYUY2 ()
v = VToY ().ConvertToYUY2 ()
YToUV (u, v, y)}



# Converts luma (and chroma) to PC levels, and optionally allows tweaking for pumping up the darks. (for the clip to be fed to motion search only)
# By courtesy of cretindesalpes. (http://forum.doom9.org/showthread.php?p=1548318#post1548318)

function Dither_Luma_Rebuild (clip src, float "s0", float "c",int "uv", bool "lsb", bool "lsb_in", bool "lsb_out", int "mode"){
lsb_in  = Default( lsb_in  ,false)
lsb_out = Default( lsb_out ,false)
lsb     = Default( lsb     ,lsb_in || lsb_out)
mode    = Default( mode ,6)
uv      = Default(uv,    3)
s0      = Default(s0,  2.0)
c       = Default(c,  1.0/16)

	k = (s0 - 1) * c
	t = lsb_in ? "x 4096 - 56064 / 0 1 clip" : "x 16 - 219 / 0 1 clip"
	e = String(k)+" "+String(1+c)+" "+String((1+c)*c)+" "+t+" "+String(c)
\		+" + / - * "+t+" 1 "+String(k)+" - * + "+String(lsb?65536:255)+" *"
src
lsb ? (lsb_in ? Dither_lut16 (yexpr=e,expr="x 32768 - 32768 * 28672 / 32768 +",y=3, u=uv, v=uv)  : \
                Dither_lut8  (yexpr=e,expr="x 128 - 32768 * 112 / 32768 +"    ,y=3, u=uv, v=uv)) : \
                mt_lut       (yexpr=e,expr="x 128 - 128 * 112 / 128 +"        ,y=3, u=uv, v=uv)
lsb_out ? last : (lsb ? Ditherpost(mode=mode,u=uv,v=uv) : last)}