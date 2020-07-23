#####################################################################################
# 
# TemporalDegrain_ChromaMod V1.0 (6/4/2009) by onesloth
# 
# Mod of Temporal Degrain V1.23 by Didee and Sagekilla
# 
# When fed chroma=false will disable all processing of chroma in TemporalDegrain()
# giving big speed bonus for greyscale sources.
# 
# Requires:
# http://avisynth.org/mediawiki/Temporal_Degrain
# 
# Syntax:
# chroma parameter is only syntax difference from TemporalDegrain()
# see above link for syntax explanation
#                       
######################################################################################


function TemporalDegrain_ChromaMod ( clip input, clip "denoise", bool "GPU", int "sigma", int "bw", int "bh", int "pel", 
 \                         int "blksize", int "ov", bool "truemotion", int "degrain", int "limit", int "SAD1", int "SAD2", int "HQ", bool "chroma" )
{
o       = input
GPU     = default( GPU,   false ) # Use FFT3DGPU -- helpful if you have a fast GPU
sigma   = default( sigma,    16 ) # Default seems to work fine -- Higher values don't help much
bw      = default( bw,       16 ) # FFT3D block width
bh      = default( bh,       16 ) # FFT3D block height
pel     = default( pel,       2 ) # Higher values increase motion vector quality at the cost of speed
blksize = default( blksize,   8 ) # use 16 for more speed, or for HD resolutions like 1080p
ov      = default( ov, blksize/2) # Increase for better motion vectors but slower speed. Max is blksize/2
truemotion = default(truemotion,false)
degrain = default( degrain,   2 ) # MVDegrain 1, 2 or 3
limit   = default( limit,   255 ) # Limits maximum change of a pixel. Default means no limit
SAD1    = default( SAD1,    400 ) # Threshold for degraining. Decrease if you suffer from ghosting
SAD2    = default( SAD2,    300 ) # See above
HQ      = default( HQ,        1 ) # How much to clean up clip for motion vector searching
s2      = floor ( sigma * 0.625 ) # See sigma
s3      = floor ( sigma * 0.375 ) # See sigma
s4      = floor ( sigma * 0.250 ) # See sigma
ow      = bw / 2                  # Don't adjust unless you need speed
oh      = bh / 2                  # See above
ov      = (ov*2>blksize) ? blksize/2 : ov
chroma  = default( chroma, true ) # Causes only Luma to be processed when false.
plane	= (chroma==false) ? 0 : 4


# "srch" is a prefiltered clip on which the motion search is done.
# Here, we simply use FFT3DFilter. You can also use your own. Basically, you shouldn't use
# a clip with "a tiny bit of filtering". The search clip should ideally be "dead calm."
filter = defined(denoise) ? denoise : (GPU==true) ?
 \ o.FFT3DGPU(sigma=sigma, sigma2=s2 , sigma3=s3, sigma4=s4, bt=4, bw=bw, bh=bh, ow=ow, oh=oh) : 
 \ o.FFT3DFilter(sigma=sigma, sigma2=s2, sigma3=s3, sigma4=s4, bt=4, bw=bw, bh=bh, ow=ow, oh=oh)

filter = (HQ>=1) ?
 \		(chroma==false) ?
 \			filter.HQdn3D(4,0,6,0)
 \		: filter.HQdn3D(4,3,6,3)
 \	: filter


# "spat" is a prefiltered clip which is used to limit the effect of the 1st MV-denoise stage.
# For simplicity, we just use the same FFT3DFilter. There's lots of other possibilities.
spat   = filter
spatD  = mt_makediff(o,spat)


# Motion vector search (With very basic parameters. Add your own parameters as needed.)
srch = filter
srch_super = filter.MSuper(pel=pel, chroma=chroma)

bvec3  = (degrain==3) ? 
 \       srch_super.MAnalyse(isb=true, delta=3, blksize=blksize, overlap=ov, truemotion=truemotion, chroma=chroma) : BlankClip
bvec2  = (degrain>=2) ? 
 \       srch_super.MAnalyse(isb=true,  delta=2, blksize=blksize, overlap=ov, truemotion=truemotion, chroma=chroma) : BlankClip
bvec1  = srch_super.MAnalyse(isb=true,  delta=1, blksize=blksize, overlap=ov, truemotion=truemotion, chroma=chroma)
fvec1  = srch_super.MAnalyse(isb=false, delta=1, blksize=blksize, overlap=ov, truemotion=truemotion, chroma=chroma)
fvec2  = (degrain>=2) ? 
 \       srch_super.MAnalyse(isb=false, delta=2, blksize=blksize, overlap=ov, truemotion=truemotion, chroma=chroma) : BlankClip
fvec3  = (degrain==3) ? 
 \       srch_super.MAnalyse(isb=false, delta=3, blksize=blksize, overlap=ov, truemotion=truemotion, chroma=chroma) : BlankClip

 
# First MV-denoising stage. Usually here's some temporal-medianfiltering going on.
# For simplicity, we just use MVDegrain.
o_super = o.MSuper(pel=2, levels=1, chroma=chroma)

NR1    = (degrain==3) ? o.MDegrain3(o_super, bvec1, fvec1, bvec2, fvec2, bvec3, fvec3, thSAD=SAD1, limit=limit, plane=plane) : 
 \       (degrain==2) ? o.MDegrain2(o_super, bvec1, fvec1, bvec2, fvec2, thSAD=SAD1, limit=limit, plane=plane) :
 \                      o.MDegrain1(o_super, bvec1, fvec1, thSAD=SAD1, limit=limit, plane=plane)
NR1D   = mt_makediff(o,NR1)


# Limit NR1 to not do more than what "spat" would do.
DD     = mt_lutxy(spatD,NR1D,"x 128 - abs y 128 - abs < x y ?")
NR1x   = (chroma==false) ? o.mt_makediff(DD) : o.mt_makediff(DD,U=2,V=2)


# Second MV-denoising stage. We use MVDegrain2.
NR1x_super = NR1x.MSuper(pel=2, levels=1, chroma=chroma)

NR2    = (degrain==3) ? NR1x.MDegrain3(NR1x_super, bvec1, fvec1, bvec2, fvec2, bvec3, fvec3, thSAD=SAD2, limit=limit, plane=plane) : 
 \       (degrain==2) ? NR1x.MDegrain2(NR1x_super, bvec1, fvec1, bvec2, fvec2, thSAD=SAD2, limit=limit, plane=plane) :
 \                      NR1x.MDegrain1(NR1x_super, bvec1, fvec1, thSAD=SAD2, limit=limit, plane=plane)

# Temporal filter to remove last bits of dancing pixels, YMMV.
NR2 = (HQ>=2) ?
 \		(chroma==false) ?
 \			NR2.HQDn3D(0,0,4,0)
 \		: NR2.HQDn3D(0,0,4,1)
 \	: NR2

# Contra-sharpening: sharpen the denoised clip, but don't add more than what was removed previously.
# Here: A simple area-based version with relaxed restriction. The full version is more complicated.
s      = NR2.minblur(1,1)                    # Damp down remaining spots of the denoised clip.
allD   = mt_makediff(o,NR2)                  # The difference achieved by the denoising.
ssD    = mt_makediff(s,s.removegrain(11,-1)) # The difference of a simple kernel blur.
ssDD   = ssD.repair(allD,1)                  # Limit the difference to the max of what the denoising removed locally.
ssDD   = ssDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?") # abs(diff) after limiting may not be bigger than before.

# Apply the limited difference. (Sharpening is just inverse blurring.)
(chroma==false) ? NR2.mt_adddiff(ssDD) : NR2.mt_adddiff(ssDD,U=2,V=2)

output = last
return(output)
}

