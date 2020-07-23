function DeRainbowYUY2(clip org, int "thresh")
{
assert(org.isyuy2(),"DeRainbowYUY2() requires YUY2 input!")
thresh = default(thresh, 10)

org_yv12 = org.converttoyv12()
org_u = utoy(org).converttoyv12()
org_v = vtoy(org).converttoyv12()

msharpen(org_yv12, threshold = thresh, mask=true)
bilinearresize(last.width/2, last.height)
greyscale()
uv = blur(1.5).levels(0,2.0,255,0,255, coring=false).blur(1.5).blur(1.5).levels(50,2.0,255,0,255, coring=false)

filtered_u = org_u.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="superstrong", scalefactor=0.5)
filtered_v = org_v.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="superstrong", scalefactor=0.5)

u_final = mt_Merge(org_u, filtered_u, uv).converttoyuy2()
v_final = mt_Merge(org_v, filtered_v, uv).converttoyuy2()

return ytouv(u_final, v_final, org)
}