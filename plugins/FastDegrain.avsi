###################################################################
# Fast Degrain by Sagekilla                                       #
#                                                                 #
# Easy to use alias for MDegrain 1, 2, or 3.                      #
# Features optional sharpening if you should desire.              #
#                                                                 #
# Required plugins: HQDn3d.dll / LimitedSharpenFaster.avs         #
#                    MT.dll / mt_masktools.dll / MVTools2.dll     #
#                                                                 #
###################################################################

# Fast Degrain Syntax
#
# degrain = MVDegrain 1, 2, or 3. Each is increasingly stronger and slower.
# blksize = MVAnalsye blksize. See MVTools documentation for details.
# overlap = MVAnalyse overlap. Must be even and < blksize/2. Higher values are better, but slower.
# pel     = MVAnalyse subpixel accuracy. Higher values give better MVs and lowers speed. 
# thSAD   = Affects degraining: Low values reduce degraining, high values raise it.
# limit   = Limits max MVDegrain change. Decrease if you experience artifacts.
# sharp   = Enables LSF sharpening. Disable for speed and compression boost.
# str     = LSF's sharpening strength. Increase for more sharpening.
# ss      = Supersampling for LSF, values over 1 decrease edge aliasing.
# sft     = Dampens LSF sharpening (It weakens the sharpening)
# oshoot  = Sharpening limit, increase it too much and it causes haloing.

##################
#
# My Changes:
#
# chroma parameter
# plane variable
# pel default to 2
# enable use of external prefiltered clip with "pre" parameter
#
##################

function FastDegrain( clip src, clip "pre", int "degrain", int "blksize", int "overlap", int "pel", 
 \                    int "thSAD", int "limit", bool "sharp", int "str", int "ss", int "sft", int "oshoot", bool "chroma", bool "SMTM")
{
degrain = default( degrain,         2 ) # Degraining method (1 - 3)
blksize = default( blksize,         8 ) # MAnalyse block size (4, 8, 16)
overlap = default( overlap, blksize/2 ) # MVAnalyse block overlap (even, ov<=blksize/2)
pel     = default( pel,             2 ) # MVAnalyse pel (1, 2, 4)
thSAD   = default( thSAD,         400 ) # MVDegrain thSAD
limit   = default( limit,         255 ) # MVDegrain limit (0 - 255)
sharp   = default( sharp,       false ) # Toggles LSF
str     = default( str,           160 ) # LSF strength
ss      = default( ss,            1.5 ) # LSF supersampling
sft     = default( sft,            30 ) # LSF soft
oshoot  = default( oshoot,          1 ) # LSF overshoot
chroma  = default( chroma,       true ) # enables chroma processing
plane	= (chroma) ? 4 : 0

try {
    SMTMdefaultmode = GetMTMode()
    SMTM = (SMTMdefaultmode!=0)
} catch(err_msg) {SMTM = false}

# Sharpen the video a bit to counter the slight loss of detail and texture.
# I prefer how the video looks with this before. You can also do this after degraining.
src = (sharp==true) ? src.LimitedSharpenFaster(strength=str,ss_x=ss,ss_y=ss,soft=sft,overshoot=oshot) : src

(SMTM) ? SetMTMode(2) : NOP()

# Create our Super clip for MV search. Then, search for motion vectors.
super = src.MSuper(pel=pel, chroma=chroma)
search_super = (defined(pre)) ? pre.MSuper(pel=pel, chroma=chroma) : super

bvec3 = (degrain>=3) ? MAnalyse( search_super, isb=true, delta=3, blksize=blksize, overlap=overlap, chroma=chroma ) : NOP()
bvec2 = (degrain>=2) ? MAnalyse( search_super, isb=true, delta=2, blksize=blksize, overlap=overlap, chroma=chroma ) : NOP()
bvec1 = (degrain>=1) ? MAnalyse( search_super, isb=true, delta=1, blksize=blksize, overlap=overlap, chroma=chroma ) : NOP()
fvec1 = (degrain>=1) ? MAnalyse( search_super, isb=false, delta=1, blksize=blksize, overlap=overlap, chroma=chroma ) : NOP()
fvec2 = (degrain>=2) ? MAnalyse( search_super, isb=false, delta=2, blksize=blksize, overlap=overlap, chroma=chroma ) : NOP()
fvec3 = (degrain>=3) ? MAnalyse( search_super, isb=false, delta=3, blksize=blksize, overlap=overlap, chroma=chroma ) : NOP()

# Degraining the video using MVDegrain. Nothing special here.
src = (degrain==1) ? src.MDegrain1( super, bvec1, fvec1, limit=limit, plane=plane ) : src
src = (degrain==2) ? src.MDegrain2( super, bvec1, fvec1, bvec2, fvec2, limit=limit, plane=plane ) : src
src = (degrain>=3) ? src.MDegrain3( super, bvec1, fvec1, bvec2, fvec2, bvec3, fvec3, limit=limit, plane=plane ) : src

(SMTM) ? SetMTMode(SMTMdefaultmode) : NOP()
return src
}