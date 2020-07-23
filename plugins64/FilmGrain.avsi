function FilmGrain1(clip c, float "amp", float "r", float "sh", float "ldiff", int "seed", int "bitdepth") {
	# FilmGrain1 by Andrew Revvo
	# HDRNoise is required
	amp = default(amp, 2.0)*0.01
	r = default(r, 1.8)
	sh = default(sh, 0.9)
	ldiff = default(ldiff, 1.5)
	seed = default(seed, 0)
	cy = VersionNumber() < 2.60 ?  c : c.ConvertToY8()
	n = cy.NoisedGrayY8(amp=100, seed=seed, uv=false, bitdepth=bitdepth)
	w = n.width()
	h = n.height()
	n = n.BicubicResize(int(w/r),int(h/r))
	n = n.Sharpen(sh).BicubicResize(w,h)
	NoiseMix1Y(c, n, amp=amp, ldiff=ldiff, mode=0, bitdepth=bitdepth)
}

function FilmGrain2(clip c, float "amp1", float "amp2", float "r1", float "r2",\
		float "sh1", float "sh2", float "ldiff", int "seed", int "bitdepth") {
	# FilmGrain2 by Andrew Revvo
	# HDRNoise is required
	amp1 = default(amp1, 2.0)*0.01
	amp2 = default(amp2, 1.0)*0.01
	r1 = default(r1, 1.8)
	r2 = default(r2, 1.2)
	sh1 = default(sh1, 0.9)
	sh2 = default(sh2, 0.3)
	ldiff = default(ldiff, 1.5)
	seed = default(seed, 0)
	cy = VersionNumber() < 2.60 ? c : c.ConvertToY8()
	n1 = cy.NoisedGrayY8(amp=100, seed=seed, uv=false, bitdepth=bitdepth)
	w = n1.width()
	h = n1.height()
	n1 = n1.BicubicResize(int(w/r1),int(h/r1))
	n1 = n1.Sharpen(sh1).BicubicResize(w,h)
	n2 = cy.NoisedGrayY8(amp=100, seed=seed+1, uv=false, bitdepth=bitdepth)
	n2 = n2.BicubicResize(int(w/r2),int(h/r2))
	n2 = n2.Sharpen(sh2).BicubicResize(w,h)
	NoiseMix2Y(c, n1, n2, amp1=amp1, amp2=amp2, ldiff=ldiff, mode=0, bitdepth=bitdepth)
}
