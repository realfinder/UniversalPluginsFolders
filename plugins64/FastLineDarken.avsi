######################
# FastLineDarken 1.3 #
######################
#
# Written by Vectrangle, last update 12 Sept 04
#
#  * requires masktools 1.5.1 -- http://jourdan.madism.org/~manao/
#  * requires yv12 input
#
# Usage is FastLineDarken(strength, luma_cap, threshold, thinning),
#   named parameters are supported eg FastLineDarken(thinning=0)
# 
# Note that you must import this avs into your script using import("...\FastLineDarken 1.3.avs")
#
# Parameters are:
#  strength (integer)  - Line darkening amount, 0-256. Default 48. Represents the _maximum_ amount
#                        that the luma will be reduced by, weaker lines will be reduced by
#                        proportionately less.
#  luma_cap (integer)  - value from 0 (black) to 255 (white), used to stop the darkening
#                        determination from being 'blinded' by bright pixels, and to stop grey
#                        lines on white backgrounds being darkened. Any pixels brighter than
#                        luma_cap are treated as only being as bright as luma_cap. Lowering
#                        luma_cap tends to reduce line darkening. 255 disables capping. Default 191.
#  threshold (integer) - any pixels that were going to be darkened by an amount less than
#                        threshold will not be touched. setting this to 0 will disable it, setting
#                        it to 4 (default) is recommended, since often a lot of random pixels are
#                        marked for very slight darkening and a threshold of about 4 should fix
#                        them. Note if you set threshold too high, some lines will not be darkened
#  thinning (integer)  - optional line thinning amount, 0-256. Setting this to 0 will disable it,
#                        which is gives a _big_ speed increase. Note that thinning the lines will
#                        inherently darken the remaining pixels in each line a little. Default 24.
#
# Changelog:
#  1.3  - added ability to thin lines, now runs much slower unless thinning=0. Changed the defaults (again)
#  1.2  - huge speed increase using yv12lutxy =)
#       - weird darkening issues gone (they were caused by yv12layer)
#       - show option no longer available due to optimizations. Use subtract() instead
#  1.1  - added luma_cap option
#  1.0  - initial release
#


function FastLineDarken( clip c, int "strength", int "luma_cap", int "threshold", int "thinning") {
	str = string(default(strength, 48) /128.)
	lum = string(default(luma_cap, 191))
	thr = string(default(threshold, 4))
	thinning = default(thinning,24)
	thn = string(thinning /16.)
	exin=c.expand().inpand()
	diff = yv12lutxy(c,exin,yexpr="y "+lum+" < y "+lum+" ? x "+thr+" + > x y "\
		+lum+" < y "+lum+" ? - 0 ? 127 +",uexpr="x",vexpr="x",u=2, v=2)
	linemask = yv12lut(diff.inpand(),"x 127 - "+thn+" * 255 +")\
		.yv12convolution("1 1 1","1 1 1",y=3,u=0,v=0)
	thick = yv12lutxy(c, exin, yexpr="y "+lum+" < y "+lum+" ? x "+thr+" + > x y "\
		+lum+" < y "+lum+" ? - 0 ? "+str+" * x +",uexpr="x",vexpr="x",u=2, v=2)
	thin = yv12lutxy(c.expand(),diff,yexpr="x y 127 - "+str+" 1 + * +",u=2, v=2)
	return (thinning == 0) ? thick : maskedmerge(thin,thick,linemask,y=3,u=2,v=2)
}