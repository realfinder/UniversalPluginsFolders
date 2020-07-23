function unboxB(clip c, int "taps", int "strong", int "calcwidth", int "calcheight")
{

	calcwidth = default(calcwidth, c.width)
	calcheight = default(calcheight, c.height)
		calcwidth2 = c.width
		calcheight2 = c.height

	taps = default(taps, 7)
	strong = default(strong, 0)
	
	
	c = c#.addborders(704 - calcwidth2, 480 - calcheight2, 0, 0)
		t2 = c
		t1 = c.Trim(0, -1)+c.Trim(0, c.framecount-1)
		t3 = c.Trim(1, 0)+c.Trim(c.framecount, 0)


	t2s0 = t2
	t2s1 = lanczosresize(t2, c.width, c.height, 0, calcheight/480, c.width, c.height, taps=taps)
	t2s2 = lanczosresize(t2, c.width, c.height, (calcwidth + (188 * calcwidth / 720 )) / 376, 0, c.width, c.height, taps=taps)
	t2s3 = lanczosresize(t2, c.width, c.height, -(calcwidth + (188 * calcwidth / 720 )) / 376, 0, c.width, c.height, taps=taps)
	t2s4 = lanczosresize(t2, c.width, c.height, 0, -calcheight/480, c.width, c.height, taps=taps)
		BasicSpatial = strong >= 1 ? average(t2s0, 0.5, t2s1, 0.125, t2s2, 0.125, t2s3, 0.125, t2s4, 0.125) : t2s0

	t1s0 = t1
	t1s1 = lanczosresize(t1, c.width, c.height, 0, calcheight/480, c.width, c.height, taps=taps)
	t1s2 = lanczosresize(t1, c.width, c.height, (calcwidth + (188 * calcwidth / 720 )) / 376, 0, c.width, c.height, taps=taps)
	t1s3 = lanczosresize(t1, c.width, c.height, -(calcwidth + (188 * calcwidth / 720 )) / 376, 0, c.width, c.height, taps=taps)
	t1s4 = lanczosresize(t1, c.width, c.height, 0, -calcheight/480, c.width, c.height, taps=taps)

	t3s0 = t3
	t3s1 = lanczosresize(t3, c.width, c.height, 0, calcheight/480, c.width, c.height, taps=taps)
	t3s2 = lanczosresize(t3, c.width, c.height, (calcwidth + (188 * calcwidth / 720 )) / 376, 0, c.width, c.height, taps=taps)
	t3s3 = lanczosresize(t3, c.width, c.height, -(calcwidth + (188 * calcwidth / 720 )) / 376, 0, c.width, c.height, taps=taps)
	t3s4 = lanczosresize(t3, c.width, c.height, 0, -calcheight/480, c.width, c.height, taps=taps)


	str=0.5
	smix1 = average(t2s0, 1-str, t2s1, str)
	smix2 = average(t2s0, 1-str, t2s2, str)
	smix3 = average(t2s0, 1-str, t2s3, str)
	smix4 = average(t2s0, 1-str, t2s4, str)

	tmix1 = average(t2s0, 1-str, t1s0, str)
	tmix2 = average(t2s0, 1-str, t3s0, str)


	Interleaved = interleave(smix1, smix2, smix3, smix4, tmix1, tmix2, BasicSpatial)
	Interleaved = blankclip(Interleaved).merge(Interleaved,0.999)
		Median = Interleaved.medianblurt(radiusy=0, radiusu=0, radiusv=0, temporalradius=3, mc=false, calcborder=true, markscenechange=false)
			Out = Median.selectevery(7, 3)
			
	Out#.crop(704 - calcwidth2, 480 - calcheight2, 0, 0)

return(last)}