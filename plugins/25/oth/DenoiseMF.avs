function DenoiseMF1(clip c, float "s1", float "s2", float "s3", float "s4", \
		int "overlap", int "thcomp", float "str", bool "gpu") {
	# Fast, accurate 8-bit denoise by Andrew Revvo, 2011
	# http://forum.doom9.org/showthread.php?t=162603
	# Requires: mvtools, mt_masktools2, FFT3DFilter or FFT3DGPU
	s1 = default(s1, 2.0)
	s2 = default(s2, 2.5)
	s3 = default(s3, 3.0)
	s4 = default(s4, 2.0)
	overlap = default(overlap, 4)
	thcomp = default(thcomp, 80)
	str = default(str, 0.8)
	blendv = mt_lut(c, Y=Round(str*255), U=-128,V=-128)
	gpu = default(gpu, true)
	super = MSuper(c, pel=1) # 2 is slow
	b1 = super.MAnalyse(isb=true,  delta=1, blksize=8, overlap=overlap, chroma=false)
	f1 = super.MAnalyse(isb=false, delta=1, blksize=8, overlap=overlap, chroma=false)
	bc1 = c.MCompensate(super, b1, thSAD=thcomp)
	fc1 = c.MCompensate(super, f1, thSAD=thcomp)
	comp = Interleave(bc1, c, fc1)
	gpu ? SetMTMode(5) : nop
	gpu ? comp.FFT3DGPU(sigma=s1, sigma2=s2, sigma3=s3, sigma4=s4,\
			plane=4, wintype=1, bt=3, bw=36, bh=36, ow=8, oh=8, mode=1, precision=2) :\
		comp.FFT3DFilter(sigma=s1, sigma2=s2, sigma3=s3, sigma4=s4,\
			plane=4, wintype=1, bt=3, bw=36, bh=36, ow=8, oh=8, ncpu=3)
	gpu ? SetMTMode(2) : nop
	SelectEvery(3, 1)
	mt_merge(last, c, blendv, luma=true)
}

function DenoiseMF2(clip c, float "s1", float "s2", float "s3", float "s4", \
		int "overlap", int "thcomp", float "str", bool "gpu") {
	# Fast, accurate 8-bit denoise by Andrew Revvo, 2011
	# http://forum.doom9.org/showthread.php?t=162603
	# Requires: mvtools, mt_masktools2, FFT3DFilter or FFT3DGPU
	s1 = default(s1, 2.0)
	s2 = default(s2, 2.5)
	s3 = default(s3, 3.0)
	s4 = default(s4, 2.0)
	overlap = default(overlap, 4)
	thcomp = default(thcomp, 80)
	str = default(str, 0.8)
	blendv = mt_lut(c, Y=Round(str*255), U=-128,V=-128)
	gpu = default(gpu, true)
	super = MSuper(c, pel=1) # 2 is slow
	b2 = super.MAnalyse(isb=true,  delta=2, blksize=8, overlap=overlap, chroma=false)
	b1 = super.MAnalyse(isb=true,  delta=1, blksize=8, overlap=overlap, chroma=false)
	f1 = super.MAnalyse(isb=false, delta=1, blksize=8, overlap=overlap, chroma=false)
	bc2 = c.MCompensate(super, b2, thSAD=thcomp)
	bc1 = c.MCompensate(super, b1, thSAD=thcomp)
	fc1 = c.MCompensate(super, f1, thSAD=thcomp)
	comp = Interleave(bc2, bc1, c, fc1)
	gpu ? SetMTMode(5) : nop
	gpu ? comp.FFT3DGPU(sigma=s1, sigma2=s2, sigma3=s3, sigma4=s4,\
			plane=4, wintype=1, bt=4, bw=36, bh=36, ow=8, oh=8, mode=1, precision=2) :\
		comp.FFT3DFilter(sigma=s1, sigma2=s2, sigma3=s3, sigma4=s4,\
			plane=4, wintype=1, bt=4, bw=36, bh=36, ow=8, oh=8, ncpu=3)
	gpu ? SetMTMode(2) : nop
	SelectEvery(4, 2)
	mt_merge(last, c, blendv, luma=true)
}