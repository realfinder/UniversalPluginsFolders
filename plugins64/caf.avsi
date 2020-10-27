# Chromatic Aberration Fixer (original: http://pastebin.com/wEAp3tuM)
# rx/ry adjust how much to resize the red plane; bx/by is the same, but for blue.
# warp adjusts warpsharp strength on red/blue planes.
# clamp sets whether the chroma (after converting back to yv12) should be limited by the original chroma; this prevents introducing chromatic aberration on, for example, hardsubbed text without chromatic aberration.

function caf(clip src,float "rx",float "ry",float "bx",float "by",int "warp",bool "clamp")
{
src
rgb=ConvertToRGB32(matrix="rec709")
w=width()
h=height()
rx=default(rx,-1.5)
ry=default(ry,rx)
bx=default(bx,-rx)
by=default(by,bx)
warp=default(warp,4)
clamp=default(clamp,true)
edge=src.aSobel().aBlur(type=0,blur=4)
r=rgb.ShowRed("yv12").Spline36Resize(w,h,rx,ry,w-rx*2,h-ry*2)
b=rgb.ShowBlue("yv12").Spline36Resize(w,h,bx,by,w-bx*2,h-by*2)
rwarp=r.aWarp(edge,depth=warp,chroma=1)
bwarp=b.aWarp(edge,depth=warp,chroma=1)
warp==0?MergeRGB(r,rgb,b):MergeRGB(rwarp,rgb,bwarp)
ConvertToYV12(matrix="rec709")
clamp?mt_lutxy(src,last,"128 x y min x y max clip",y=2,u=3,v=3):MergeLuma(src)
}