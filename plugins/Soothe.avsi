function Soothe(clip sharp, clip orig, int "keep")
{
Assert(sharp.width == orig.width && sharp.height == orig.height,
 \  "Soothe: clip dimensions must match!")
keep  = default(keep, 24)
keep  = (keep>100) ? 100 : (keep<0) ? 0 : keep
KP    = string(keep)
diff  = mt_makediff(orig,sharp)
diff2 = diff.temporalsoften(1,255,0,32,2)
diff3 = mt_lutxy(diff,diff2,  "x 128 - y 128 - * 0 < x 128 - 100 / "  + KP 
 \                           + " * 128 + x 128 - abs y 128 - abs > x " + KP 
 \                           + " * y 100 " + KP + " - * + 100 / x ? ?")
return( mt_makediff(orig,diff3,chroma="copy first") )
}

function Soothe_Didee(clip sharp, clip orig, int "keep")
{
keep  = default(keep, 24)
keep  = (keep>100) ? 100 : (keep<0) ? 0 : keep
KP    = string(keep)
diff  = yv12lutxy(orig,sharp,"x y - 128 +", U=1,V=1)
diff2 = diff.temporalsoften(1,255,255,32,2)
diff3 = yv12lutxy(diff,diff2,  "x 128 - y 128 - * 0 < x 128 - 100 / "  + KP 
 \                           + " * 128 + x 128 - abs y 128 - abs > x " + KP 
 \                           + " * y 100 " + KP + " - * + 100 / x ? ?",  U=1,V=1)
return( yv12lutxy(orig,diff3,"x y 128 - -",U=2,V=2) )
}