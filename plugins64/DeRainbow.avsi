function DeRainbow(clip org, int "thresh")
{ 
  assert(org.isYV12(),"DeRainbow() requires YV12 input!")
  thresh = default(thresh, 10)

  org_u = utoy(org)
  org_v = vtoy(org)

  msharpen(org, threshold = thresh, mask=true)
  reduceby2()
  greyscale()
  uv = blur(1.5).levels(0,2.0,255,0,255, coring=false).blur(1.5).blur(1.5).levels(50,2.0,255,0,255, coring=false)

  filtered_u = org_u.blur(1.5).blur(1.5).blur(1.5).temporalsoften(2,255,0,3,2)
  filtered_v = org_v.blur(1.5).blur(1.5).blur(1.5).temporalsoften(2,255,0,3,2)

  u_final = mt_merge(org_u, filtered_u, uv)
  v_final = mt_merge(org_v, filtered_v, uv)

  return ytouv(u_final, v_final, org)
}