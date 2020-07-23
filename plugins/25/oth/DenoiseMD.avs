function DenoiseMD1(clip c, float "sigma", int "overlap", int "thcomp", float "str", bool "lsb") {
	# Fast, accurate 8/16-bit denoise by Andrew Revvo, 2011 v.1.1
	# http://forum.doom9.org/showthread.php?t=162342
	# Requires: mvtools, dfttest from Dither, BlendClips
	sigma = default(sigma,4)
	overlap = default(overlap, 4)
	thcomp = default(thcomp, 80)
	str = default(str, 0.8)
	lsb = default(lsb, true)
	super = MSuper(c, pel=1) # 2 is slow
	b1 = super.MAnalyse(isb=true,  delta=1, blksize=8, overlap=overlap, chroma=false)
	f1 = super.MAnalyse(isb=false, delta=1, blksize=8, overlap=overlap, chroma=false)
	bc1 = c.MCompensate(super, b1, thSAD=thcomp)
	fc1 = c.MCompensate(super, f1, thSAD=thcomp)
	comp = Interleave(bc1, c, fc1)
	comp.dfttest(sigma=sigma, sbsize=12, sosize=8, tbsize=3, threads=3, lsb=lsb)
	SelectEvery(3, 1)
	BlendClips(lsb?c.Range8to16():c, str, lsb)
}

function DenoiseMD2(clip c, float "sigma", int "overlap", int "thcomp", float "str", bool "lsb") {
	# Fast, accurate 8/16-bit denoise by Andrew Revvo, 2011 v.1.1
	# http://forum.doom9.org/showthread.php?t=162342
	# Requires: mvtools, dfttest from Dither, BlendClips
	sigma = default(sigma, 4)
	overlap = default(overlap, 4)
	thcomp = default(thcomp, 80)
	str = default(str, 0.8)
	lsb = default(lsb, true)
	super = MSuper(c, pel=1) # 2 is slow
	b2 = super.MAnalyse(isb=true,  delta=2, blksize=8, overlap=overlap, chroma=false)
	b1 = super.MAnalyse(isb=true,  delta=1, blksize=8, overlap=overlap, chroma=false)
	f1 = super.MAnalyse(isb=false, delta=1, blksize=8, overlap=overlap, chroma=false)
	f2 = super.MAnalyse(isb=false, delta=2, blksize=8, overlap=overlap, chroma=false)
	bc2 = c.MCompensate(super, b2, thSAD=thcomp)
	bc1 = c.MCompensate(super, b1, thSAD=thcomp)
	fc1 = c.MCompensate(super, f1, thSAD=thcomp)
	fc2 = c.MCompensate(super, f2, thSAD=thcomp)
	comp = Interleave(bc2, bc1, c, fc1, fc2)
	comp.dfttest(sigma=sigma, sbsize=12, sosize=8, tbsize=5, threads=3, lsb=lsb)
	SelectEvery(5, 2)
	BlendClips(lsb?c.Range8to16():c, str, lsb)
}

function BlendClips(clip c1, clip c2, float "str", bool "lsb") {
	# Requires: Dither, mt_masktools2
	str = Round(default(str, 0.5)*255)
	lsb = default(lsb, true)
	m = c1.mt_lut(Y=str,U=0,V=0)
	lsb ? Dither_merge16(c1, c2, m) : mt_merge(c1, c2, m, luma=true)
}

function Range8to16(clip c) {
	# Requires: mt_masktools2
	StackVertical(c, c.mt_lut(Y=0,U=0,V=0))
}