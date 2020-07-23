function DeRainbowMod(clip org, int "thresh")
{
assert(org.isYV12(),"DeRainbowMod() requires YV12 input!")
thresh = default(thresh, 10)

org_u = utoy(org)
org_v = vtoy(org)

msharpen(org, threshold = thresh, mask=true)
reduceby2()
greyscale()
uv = blur(1.5).levels(0,2.0,255,0,255, coring=false).blur(1.5).blur(1.5).levels(50,2.0,255,0,255, coring=false)

filtered_u = org_u.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="strong", scalefactor=0.5)
filtered_v = org_v.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="strong", scalefactor=0.5)

u_final = MaskedMerge(org_u, filtered_u, uv)
v_final = MaskedMerge(org_v, filtered_v, uv)

return ytouv(u_final, v_final, org)
} 