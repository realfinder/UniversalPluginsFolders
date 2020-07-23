#version 0.1, optimizations by Didee

loadPlugin("variableBlur.dll")
loadPlugin("warpSharp.dll")

function halomaskM(clip c, int "hthr", int "hbias", int "agmrad"){

hthr = default(hthr, 256)
hbias = default(hbias, -128)
agmrad = default(agmrad, 1)

s = c
Mblur = (agmrad==1) ? s.removegrain(4,-1) : s.Quantile(radius_y=agmrad,radius_u=-1,radius_v=-1)
gblur = (agmrad<=5) ? s.binomialblur(vary=agmrad, varc=0) : s.gaussianblur(vary=agmrad, varc=0)
maskM = mt_lutxy(Mblur, Gblur, "y x - abs "+string(hthr)+" * "+string(hbias)+" +", U=1, V=1)

return(maskM)}

function halomaskMR(clip c, int "hthr", int "hbias"){

hthr = default(hthr, 256)
hbias = default(hbias, -128)

s = c
Ablur = s.removegrain(4)
gblur = s.gaussianblur(vary=1, varc=0)
mask3 = mt_lutxy(Ablur, Gblur, "y x - abs "+string(hthr)+" * "+string(hbias)+" +", U=1, V=1)

return(mask3)}


function SSW(clip c){
c#.unsharp()
w = width
h = height

spline36resize(w*3, h*3)


awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)

awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)
awarpsharp2(chroma=2, depth=2, blur=1, thresh=1)


spline36resize(w, h)}

function SSSharp(clip c, float "rad", bool "ssw", float "strength", int "iter", bool "ss", int "denoise"){

rad = default(rad, 0.25)
ssw = default(ssw, true)
strength = default(strength, 4)
iter = default(iter, 1)
ss = default(ss, true)
denoise = default(denoise, iter)

c
w = width(c)
h = height(c)


sswc = ssw ? c.ssw() : c
(iter >= 1) ? MT_Merge(unsharp(vary=rad, varc=1, strength=strength), sswc, spline36resize((ss ? w*4 : w), (ss ? h*4 : h)).halomaskM(hbias=-128, hthr=256, agmrad=(ss ? round(rad*4) : round(rad))).spline36resize(w, h)) : last
(denoise >=1) ? degrainmedian(mode=3).dctfun4b(2,2) : last
(iter >= 2) ? MT_Merge(unsharp(vary=rad, varc=1, strength=strength), sswc, spline36resize((ss ? w*4 : w), (ss ? h*4 : h)).halomaskM(hbias=-128, hthr=256, agmrad=(ss ? round(rad*4) : round(rad))).spline36resize(w, h)) : last
(denoise >=2) ? degrainmedian(mode=3).dctfun4b(2,2) : last
(iter >= 3) ? MT_Merge(unsharp(vary=rad, varc=1, strength=strength), sswc, spline36resize((ss ? w*4 : w), (ss ? h*4 : h)).halomaskM(hbias=-128, hthr=256, agmrad=(ss ? round(rad*4) : round(rad))).spline36resize(w, h)) : last
(denoise >=3) ? degrainmedian(mode=3).dctfun4b(2,2) : last
(iter >= 4) ? MT_Merge(unsharp(vary=rad, varc=1, strength=strength), sswc, spline36resize((ss ? w*4 : w), (ss ? h*4 : h)).halomaskM(hbias=-128, hthr=256, agmrad=(ss ? round(rad*4) : round(rad))).spline36resize(w, h)) : last
(denoise >=4) ? degrainmedian(mode=3).dctfun4b(2,2) : last
return(last)
}
