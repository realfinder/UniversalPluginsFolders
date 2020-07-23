function hedgemask(clip cInput, int the1, int the2, int w, int n){
	cx=cInput.mt_edge(mode = "-2 -1  3 -2 -1  3 -2 -1  3 "+string(n), thY1=0, thY2=255, thC1=255, thC2=255,u=1,v=1)
	cy=cInput.mt_edge(mode = " 3 -1 -2  3 -1 -2  3 -1 -2 "+string(n), thY1=0, thY2=255, thC1=255, thC2=255,u=1,v=1)

	mergeluma(cx,cy,0.5)
	mt_lut(yexpr="x "+string(the1)+" < 0 x ?",u=1,v=1)
	mt_lut(yexpr="x "+string(the2)+" > 255 x ?",u=1,v=1)

	(w > 4) ? mt_expand(mode="horizontal",u=1,v=1) : last
	(w > 3) ? mt_expand(mode="horizontal",u=1,v=1) : last
	(w > 2) ? mt_expand(mode="horizontal",u=1,v=1) : last
	(w > 1) ? mt_expand(mode="horizontal",u=1,v=1) : last
	(w > 0) ? mt_expand(mode="horizontal",u=1,v=1) : last
	return last
}

#show 	shows the edgemask
#th 	threshold for the mask, default 15 for old mask, 100 for new (minimum for edges to be found), strength of mask is edgedependent
#th2 	threshold for full strength mask (new mask only)
#mr 	width of the edge region (we don't look for rainbows, but for strong vertical edges)
#norm 	divisor for edgededection, th=100&&norm=1 equals th=50&&norm=2 but edgemap strength is different
#interlaced process fields seperate?
#r	scalefactor - stength of the blur (only where the mask == 255 visible)
#oldmask msharpen based edgemask or own edgemask
function DeRainbow2(clip org,bool "show", int "th", int "th2", int "mr", int "norm", bool "interlaced", float "r", bool "oldmask")
{
  assert((!org.isRGB()),"DeRainbow() requires YUY2 or YV12 input!")
  show=default(show,false)
  oldmask=default(oldmask,false)
  mr=default(mr,4)
  norm=default(norm,1)
  interlaced=default(interlaced,false)
  r=default(r,0.5)
  thn=default(th,100/norm)
  th2n=default(th2,255/norm)

  org = (interlaced) ? org.separatefields() : org

  org_yv12 = isyv12(org) ? org : org.converttoyv12()
  org_u = isyv12(org) ? utoy(org) : utoy(org).converttoyv12()
  org_v = isyv12(org) ? vtoy(org) : vtoy(org).converttoyv12()

  mask= (oldmask) ? msharpen(org_yv12, threshold = default(th, 15), mask=true).blur(1.5).levels(0,2.0,255,0,255, coring=false).blur(1.5).blur(1.5).levels(50,2.0,255,0,255, coring=false)
\ : hedgemask(org_yv12,thn,th2n,mr,norm) #edge detection

  uv = isyv12(org) ? mask.reduceby2() : mask.HorizontalReduceBy2()

  filtered_u = org_u.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="superstrong", scalefactor=r)
  filtered_v = org_v.mipsmooth(spatial=255, temporal=255, scenechange=3, show=false, method="superstrong", scalefactor=r)

  u_final = isyv12(org) ? mt_Merge(org_u, filtered_u, uv, u=1, v=1) : mt_Merge(org_u, filtered_u, uv, u=1, v=1).converttoyuy2()
  v_final = isyv12(org) ? mt_Merge(org_v, filtered_v, uv, u=1, v=1) : mt_Merge(org_v, filtered_v, uv, u=1, v=1).converttoyuy2()

  show ? (isyuy2(org) ? mask.converttoyuy2() : mask).greyscale().merge(org,0.5) : ytouv(u_final, v_final, org)
  return (interlaced) ? last.weave() : last
}
filterpath="filter\"
loadplugin(filterpath+"mt_masktools.dll")
loadplugin(filterpath+"MipSmooth.dll")
loadplugin(filterpath+"MSharpen.dll")