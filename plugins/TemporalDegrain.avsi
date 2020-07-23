#############################################################################
# Temporal Degrain V1.23 (Mar 17, 2009)                                     #
# Changes in 1.23: Cosmetics, updated to MVTools 2                          #
#                                                                           #
# Function by Sagekilla, idea + original script created by Didee            #
#                                                                           #
# Works as a simple temporal degraining function that'll remove MOST grain  #
# from video sources, including dancing grain, like the grain found on 300. #
# Is currently capable of utilizing MVDegrain 1, 2, or 3 for degraining     #
# Also note, the parameters don't need to be tweaked much.                  #
#                                                                           #
# Required plugins: FFT3DFilter.dll / FFT3DGPU / mt_masktools.dll           #
#                   MVtools.dll / HQdn3D.dll / RemoveGrain.dll / Repair.dll #
#                                                                           #
# FFT3DFilter: http://bag.hotmail.ru/fft3dfilter/fft3dfilter.dhtml          #
# FFT3DGPU: http://avisynth.org/tsp/                                        #
# mt_masktools: http://manao4.free.fr/mt_masktools.html                     #
# MVtools2: http://avisynth.org.ru/mvtools/mvtools2.html                    #
# RemoveGrain: http://www.removegrain.de.tf/                                #
# Repair: Included with RemoveGrain                                         #
# HQdn3D: http://akuvian.org/src/avisynth/hqdn3d/                           #
#############################################################################

########################################################
# Syntax Description                                   #
# denoise = Denoised clip for motion vectors search    #
# GPU = Enables GPU based prefiltering                 #
# sigma = FFT3D filtering strength                     #
# bw = FFT3D block width                               #
# bh = FFT3D block height                              #
# pel = MVAnalyse Subpixel accuracy                    #
# blksize = MVAnalyse block size                       #
# ov = MVAnalyse block overlap                         #
# SAD1 = MVDegrain thSAD                               #
# SAD2 = MVDegrain thSAD                               #
# degrain = MVDegrain with 1, 2, or 3 vectors          #
# HQ = Enables prepass for motion vector search        #
# threads = Number of threads for FFT3DFilter          #
########################################################

# TO DO:
#
# Currently, Temporal Degrain works by creating a "clean" clip that has no noise.
# This clean clip is used for MV search, and will generally give more accurate vectors
# than an unfiltered clip would. However, our current implementation uses heavy filtering
# from FFT3DFilter. The prefiltered clip looks like mush, and our first stage of denoising
# cannot exhibit denoising greater than this. Because of this, the limit on denoising
# is essentially nothing! In some cases, the denoising is much more severe because our
# "clean" sometimes replaces the results from vanilla MDegrain, giving a very flat and
# undetailed look the image. We can alleviate this by creating a secondary "limit" clip
# that isn't as severely filtered as our search clip is. But, this would cost even more time.

function TemporalDegrain ( clip input, clip "denoise", bool "GPU", int "sigma", int "bw", int "bh", int "pel", 
 \                         int "blksize", int "ov", int "degrain", int "limit", int "SAD1", int "SAD2", int "HQ" )
{
o       = input
GPU     = default( GPU,   false ) # Use FFT3DGPU -- helpful if you have a fast GPU
sigma   = default( sigma,    16 ) # Default seems to work fine -- Higher values don't help much
bw      = default( bw,       16 ) # FFT3D block width
bh      = default( bh,       16 ) # FFT3D block height
pel     = default( pel,       2 ) # Higher values increase motion vector quality at the cost of speed
blksize = default( blksize,   8 ) # use 16 for more speed, or for HD resolutions like 1080p
ov      = default( ov, blksize/2) # Increase for better motion vectors but slower speed. Max is blksize/2
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

# "srch" is a prefiltered clip on which the motion serach is done.
# Here, we simply use FFT3DFilter. You can also use your own. Basically, you shouldn't use
# a clip with "a tiny bit of filtering". The search clip should ideally be "dead calm."
filter = defined(denoise) ? denoise : (GPU==true) ?
 \ o.FFT3DGPU(sigma=sigma, sigma2=s2 , sigma3=s3, sigma4=s4, bt=4, bw=bw, bh=bh, ow=ow, oh=oh) : 
 \ o.FFT3DFilter(sigma=sigma, sigma2=s2, sigma3=s3, sigma4=s4, bt=4, bw=bw, bh=bh, ow=ow, oh=oh)
filter = (HQ>=1) ? filter.HQdn3D(4,3,6,3) : filter


# "spat" is a prefiltered clip which is used to limit the effect of the 1st MV-denoise stage.
# For simplicity, we just use the same FFT3DFilter. There's lots of other possibilities.
spat   = filter
spatD  = mt_makediff(o,spat)


# Motion vector search (With very basic parameters. Add your own parameters as needed.)
srch = filter
srch_super = filter.MSuper(pel=pel)

bvec3  = (degrain==3) ? 
 \       srch_super.MAnalyse(isb=true, delta=3, blksize=blksize, overlap=ov) : BlankClip
bvec2  = (degrain>=2) ? 
 \       srch_super.MAnalyse(isb=true,  delta=2, blksize=blksize, overlap=ov) : BlankClip
bvec1  = srch_super.MAnalyse(isb=true,  delta=1, blksize=blksize, overlap=ov)
fvec1  = srch_super.MAnalyse(isb=false, delta=1, blksize=blksize, overlap=ov)
fvec2  = (degrain>=2) ? 
 \       srch_super.MAnalyse(isb=false, delta=2, blksize=blksize, overlap=ov) : BlankClip
fvec3  = (degrain==3) ? 
 \       srch_super.MAnalyse(isb=false, delta=3, blksize=blksize, overlap=ov) : BlankClip

 
# First MV-denoising stage. Usually here's some temporal-medianfiltering going on.
# For simplicity, we just use MVDegrain.
o_super = o.MSuper(pel=2, levels=1)

NR1    = (degrain==3) ? o.MDegrain3(o_super, bvec1, fvec1, bvec2, fvec2, bvec3, fvec3, thSAD=SAD1, limit=limit) : 
 \       (degrain==2) ? o.MDegrain2(o_super, bvec1, fvec1, bvec2, fvec2, thSAD=SAD1, limit=limit) :
 \                      o.MDegrain1(o_super, bvec1, fvec1, thSAD=SAD1, limit=limit)
NR1D   = mt_makediff(o,NR1)


# Limit NR1 to not do more than what "spat" would do.
DD     = mt_lutxy(spatD,NR1D,"x 128 - abs y 128 - abs < x y ?")
NR1x   = o.mt_makediff(DD,U=2,V=2)


# Second MV-denoising stage. We use MVDegrain2.
NR1x_super = NR1x.MSuper(pel=2, levels=1)

NR2    = (degrain==3) ? NR1x.MDegrain3(NR1x_super, bvec1, fvec1, bvec2, fvec2, bvec3, fvec3, thSAD=SAD2, limit=limit) : 
 \       (degrain==2) ? NR1x.MDegrain2(NR1x_super, bvec1, fvec1, bvec2, fvec2, thSAD=SAD2, limit=limit) :
 \                      NR1x.MDegrain1(NR1x_super, bvec1, fvec1, thSAD=SAD2, limit=limit)

NR2 = (HQ>=2) ? NR2.HQDn3D(0,0,4,1) : NR2 # Temporal filter to remove last bits of dancing pixels, YMMV.

# Contra-sharpening: sharpen the denoised clip, but don't add more than what was removed previously.
# Here: A simple area-based version with relaxed restriction. The full version is more complicated.
s      = NR2.minblur(1,1)                    # Damp down remaining spots of the denoised clip.
allD   = mt_makediff(o,NR2)                  # The difference achieved by the denoising.
ssD    = mt_makediff(s,s.removegrain(11,-1)) # The difference of a simple kernel blur.
ssDD   = ssD.repair(allD,1)                  # Limit the difference to the max of what the denoising removed locally.
ssDD   = ssDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?") # abs(diff) after limiting may not be bigger than before.

NR2.mt_adddiff(ssDD,U=2,V=2) # Apply the limited difference. (Sharpening is just inverse blurring.)

output = last
return(output)
}