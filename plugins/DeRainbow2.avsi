function DeRainbow2(clip org, int "thresh")
{ 

#Based on DeRainbow by Sh0dan

assert(org.isYV12(),"DeRainbow2() requires YV12 input!")
thresh = default(thresh, 10)

org_u = utoy(org)
org_v = vtoy(org)

msharpen(org, threshold = thresh, mask=true)
reduceby2()
greyscale()
uv = blur(1.5).levels(0,2.0,255,0,255, coring=false).levels(50,2.0,255,0,255, coring=false)

filtered_u = org_u.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="strong", scalefactor=0.5) 

filtered_v = org_v.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="strong", scalefactor=0.5)


u_final = mt_merge(org_u, filtered_u, uv)
v_final = mt_merge(org_v, filtered_v, uv)

derainbowed = ytouv(u_final, v_final, org)

edgem = org.mt_edge("cartoon", thy1=6 , thy2=6, thc1=6, thc2=6).mt_expand().blur(1.58)

return mt_merge(org, derainbowed, edgem, Y=1, U=3, V=3)

} 
