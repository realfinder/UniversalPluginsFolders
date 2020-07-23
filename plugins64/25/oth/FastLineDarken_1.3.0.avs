#FastLineDarken(strength=48, luma_cap=191, threshold=4, thinning=24)


function FastLineDarken( clip c, int "strength", int "luma_cap", int "threshold", int "thinning") {
	str = string(default(strength, 48) /128.)
	lum = string(default(luma_cap, 191))
	thr = string(default(threshold, 4))
	thinning = default(thinning,24)
	thn = string(thinning /16.)
	exin=c.expand().inpand()
	diff = yv12lutxy(c,exin,yexpr="y "+lum+" < y "+lum+" ? x "+thr+" + > x y "\
		+lum+" < y "+lum+" ? - 0 ? 127 +",uexpr="x",vexpr="x")
	linemask = yv12lut(diff.inpand(),"x 127 - "+thn+" * 255 +")\
		.yv12convolution("1 1 1","1 1 1",y=3,u=0,v=0)
	thick = yv12lutxy(c, exin, yexpr="y "+lum+" < y "+lum+" ? x "+thr+" + > x y "\
		+lum+" < y "+lum+" ? - 0 ? "+str+" * x +",uexpr="x",vexpr="x")
	thin = yv12lutxy(c.expand(),diff,yexpr="x y 127 - "+str+" 1 + * +")
	return (thinning == 0) ? thick : maskedmerge(thin,thick,linemask,y=3,u=2,v=2)
}