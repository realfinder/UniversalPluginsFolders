#smoothnnedi2bob v0.02 by shoopdabloop
#Used to attain smoother edges and eliminate most bob flicker when using nnedi3 for bobbing.
#Meant for live-action sources.
#Prerequisites: nnedi3, mvtools2, masktools2

function smoothnnedi3bob(clip clp)
{
	edi = clp.nnedi3(field=-2)
	even = edi.selecteven().flowfps(edi.framerate)
	odd = edi.selectodd().flowfps(edi.framerate)
	smooth = merge(odd, even).selectevery(1,-1)
	a = edi.blur(0,0.25)
	b = smooth
	c = edi.blur(1.58).temporalsoften(4,4,8,15,2).mt_edge("sobel",0,4,0,5,U=3,V=3).mt_inflate(U=3,V=3)
        return mt_merge(a,b,c,U=3,V=3)
}

function flowfps(clip clp,float "fps")
{
	fpsnum = 2*clp.frameRateNumerator
        fpsden = clp.frameRateDenominator
	super = clp.msuper()
	filtsuper = clp.blur(1.58).temporalsoften(4,4,8,15,2).msuper()
	bw = manalyse(filtsuper,isb=true)
	fw = manalyse(filtsuper,isb=false)
	return clp.mflowfps(super,bw,fw,num=fpsnum,den=fpsden)
}
