#################################################################################
#
# TemporalDegrain_MT v1.2 (7/1/2009) by onesloth
#
# Simple Front-end for MT()'ing TemporalDegrain V1.23 (by Didee and Sagekilla)
# but using *single-threaded* prefilter clip.
#
# Required plugins:
# http://avisynth.org/mediawiki/Temporal_Degrain
# http://avisynth.org/mediawiki/MT
#
# Required for use of chroma parameter:
# TemporalDegrain_ChromaMod: http://forum.doom9.org/showthread.php?t=147548
# 
# Syntax is same as TemporalDegrain except for addition of threads,
# overlap, and splitvertical parameters from MT() and the chroma and flatsigma parameters.
# See above links for syntax explanation.
#
##################################################################################

##################################################################################
#
# changelog:
#
# v1.1 (6/4/2009) 	+Added chroma parameter for faster processing
# 			of greyscale sources with TemporalDegrain_ChromaMod.
#
# v1.1.1 (6/4/2009) 	-Changed prefilter block width and height default
#			to 32 when GPU=true. Runs at same speed as 16 on my system.
#
# v1.2 (7/1/2009) 	+Added flatsigma parameter. Makes FFT3D prefilter use only
#			a single sigma parameter equal to flatsigma value if flatsigma > 0.
#			+Added switching of FFT3D plane parameter when chroma processing is disabled
#			-Removed parameters from TemporalDegrain calls that aren't used when fed a prefilter clip
#
##################################################################################


function TemporalDegrain_MT ( clip input, clip "denoise", bool "GPU", int "sigma", int "bw", int "bh", int "pel", 
 \                         int "blksize", int "ov", int "degrain", int "limit", int "SAD1", int "SAD2", int "HQ",
 \			   int "threads", int "overlap", bool "splitvertical", bool "chroma", float "flatsigma" )
{
o       = input
GPU     = default( GPU,   false ) # Use FFT3DGPU -- helpful if you have a fast GPU
sigma   = default( sigma,    16 ) # Default seems to work fine -- Higher values don't help much
bw 	= default( bw, ((GPU==false) ? 16 : 32) ) # FFT3D block width
bh 	= default( bh, ((GPU==false) ? 16 : 32) ) # FFT3D block height
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
threads = default( threads,   4 ) # Number of threads to run. Set this to the number of threads
				  # your computer is able to run concurrently.
overlap = default( overlap,   8 ) # Number of pixels to add at the top and bottom border or left and right border.
				  # Increase this if you see artifacts where the frame is split.
splitvertical = default( splitvertical, false ) # if true the frame is cut vertical else it is cut horizontal.
chroma	= default( chroma, true ) # When false uses TemporalDegrain_ChromaMod for faster greyscale source processing
plane	= (chroma) ? 4 : 0	  # Sets FFT3D prefilter to only process luma when chroma==false
flatsigma = default( flatsigma, 0 )


# Same as TemporalDegrain prefilter code except for bt=3 in FFT3DGPU.
# bt=4 appears to be broken. bt=3 gives much stronger denoising.
prefiltered = defined(denoise)
\		? denoise
\		: (flatsigma > 0)
\			? (GPU)
\				? o.FFT3DGPU(sigma=flatsigma, bt=3, bw=bw, bh=bh, ow=ow, oh=oh, plane=plane)
\				: o.FFT3DFilter(sigma=flatsigma, bt=4, bw=bw, bh=bh, ow=ow, oh=oh, plane=plane)
\			: (GPU)
\				? o.FFT3DGPU(sigma=sigma, sigma2=s2 , sigma3=s3, sigma4=s4, bt=3, bw=bw, bh=bh, ow=ow, oh=oh, plane=plane)
\				: o.FFT3DFilter(sigma=sigma, sigma2=s2, sigma3=s3, sigma4=s4, bt=4, bw=bw, bh=bh, ow=ow, oh=oh, plane=plane)

interleave(o, prefiltered)

(chroma==false)
\	? MT("""
		orig_extract = selecteven()
		prefilt_extract = selectodd()
		TemporalDegrain_ChromaMod(orig_extract, denoise=prefilt_extract, pel=pel,
		 \	blksize=blksize, ov=ov, degrain=degrain, limit=limit, SAD1=SAD1, SAD2=SAD2, HQ=HQ, chroma=chroma)
	""", threads=threads, overlap=overlap, splitvertical=splitvertical)
\
\	: MT("""
		orig_extract = selecteven()
		prefilt_extract = selectodd()
		TemporalDegrain(orig_extract, denoise=prefilt_extract, pel=pel,
		 \	blksize=blksize, ov=ov, degrain=degrain, limit=limit, SAD1=SAD1, SAD2=SAD2, HQ=HQ)
	""", threads=threads, overlap=overlap, splitvertical=splitvertical)

return(last)
}
