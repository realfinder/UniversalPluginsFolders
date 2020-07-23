##############################################################################
#
#	Spatio-temporal denoising and dithering
#       v1.9.5
#	By Firesledge
#
#	See the documentation for the function description.
#
#	This program is free software. It comes without any warranty, to
#	the extent permitted by applicable law. You can redistribute it
#	and/or modify it under the terms of the Do What The Fuck You Want
#	To Public License, Version 2, as published by Sam Hocevar. See
#	http://sam.zoy.org/wtfpl/COPYING for more details.
#
##############################################################################



Function Dither1Pre (clip m, string "flt", bool "stacked", float "overlap", bool "tvopt")
{
	m.DitherPre_internal (1, flt, stacked, overlap, tvopt)
}

Function Dither2Pre (clip m, string "flt", bool "stacked", float "overlap", bool "tvopt")
{
	m.DitherPre_internal (2, flt, stacked, overlap, tvopt)
}



Function DitherBuildMask (clip cnew, clip "cold", int "edgelvl", int "radius")
{
	cold_flag = Defined (cold)

	edgelvl = Default (edgelvl, 8)
	radius  = Default (radius,  2)
	cold    = Default (cold, cnew)

	cedgo = cold.mt_edge (
\		"prewitt",
\		thY1=edgelvl, thY2=edgelvl,
\		thC1=edgelvl, thC2=edgelvl,
\		y=3, u=3, v=3
\	)
	cedgn = cnew.mt_edge (
\		"prewitt",
\		thY1=edgelvl, thY2=edgelvl,
\		thC1=edgelvl, thC2=edgelvl,
\		y=3, u=3, v=3
\	)

	cdif = mt_lutxy (cold, cnew, expr="x y == 0 255 ?", y=3, u=3, v=3)

	m = cedgn
	m = (cold_flag) ? mt_logic (m, cedgo, mode="or", y=3, u=3, v=3) : m
	m = (cold_flag) ? mt_logic (m, cdif,  mode="or", y=3, u=3, v=3) : m

	m = (radius > 1) ? m.mt_expand_multi (sw=radius-1, sh=radius-1, y=3, u=3, v=3) : m

	return (m)
}

function nuke17(clip input) {
blk =32
ovr = 16
sr = 0
denoised = input.dfttest (sigma=78)
n = mt_lutxy (input, denoised, expr="x y < y 1 - x y > y 1 + y ? ?", y=3, u=3, v=3)

super   = n.MSuper ()
super_a = denoised.MSuper ()

vf1 = super_a.MAnalyse (isb=false, delta=1, overlap=ovr, blksize=blk)
vb1 = super_a.MAnalyse (isb=true,  delta=1, overlap=ovr, blksize=blk)

cf1 = n.MCompensate (super, vf1, thSAD=100)
cb1 = n.MCompensate (super, vb1, thSAD=100)
n = Interleave (cf1, n, cb1)
n = n.dfttest (sigma=8.0, tbsize=3)
n = n.SelectEvery (3, 1)

n
}

function nuke16(clip input) {

denoised = input.dfttest (sigma=8)
n = mt_lutxy (input, denoised, expr="x y < y 1 - x y > y 1 + y ? ?", y=3, u=3, v=3)

super   = n.MSuper ()
super_a = denoised.MSuper ()

vf1 = super_a.MAnalyse (isb=false, delta=1, overlap=4, blksize=16)
vb1 = super_a.MAnalyse (isb=true,  delta=1, overlap=4, blksize=16)

cf1 = n.MCompensate (super, vf1, thSAD=200)
cb1 = n.MCompensate (super, vb1, thSAD=200)
n = Interleave (cf1, n, cb1)
n = n.dfttest (sigma=1.0, tbsize=3, lsb=true)
n = n.SelectEvery (3, 1)

tmp = n
n = n.SmoothGrad (thr=0.10, radius= 8, ref=tmp)
n = n.SmoothGrad (thr=0.15, radius=12, ref=tmp)
n = n.SmoothGrad (thr=0.15, radius=16, ref=tmp)

n#.mt_merge( n, tmp,true )
}
Function grain1001()
{
#your GradFun3 settings
vGF3=GradFun3(0.5,8,2,1,thr_det=3,thr_edg=20,dthr=0.05,debug=0,smode=1)

#build motion mask
blk=8
vMA=msuper(rfilter=1,hpad=blk,vpad=blk).manalyse(blksize=blk)
vSC=MSCDetection(vMA,thscd1=300).mt_invert()
vMotionMask=mmask(vMA,ml=10,kind=0).mt_lut(y=0,w=blk).mt_lut(y=0,h=blk).mt_lut(y=0,offx=width-blk,w=blk).mt_lut(y=0,offy=height-blk)
vMotionMask=vMotionMask.mt_logic(vMotionMask.trim(1,0),"or").mt_logic(vSC,"and").mt_logic(vSC.trim(1,0),"and")
vMotionMask=vMotionMask.bilinearresize(ceil(width/blk/2)*2,ceil(height/blk/2)*2).mt_binarize(16)
vMotionMask=vMotionMask.removegrain(4).mt_expand().removegrain(11).bicubicresize(width,height).binomialblur(200,u=1,v=1)

#create motion-adaptive grain
vGray=mt_lut(y=-128,u=-128,v=-128)
vGrain=vGray.addgrainC(1,0,0,0,-1,true).mt_merge(vGray.addgrainC(1,0,0,0,-1,false),vMotionMask,true)

#grain will be added to dark areas only
vGrainMask=mt_lut("255 x 32 - 2 << 255 / 2 ^ 255 * -")
#contract mask down to areas touched by GF3 only, apply extreme blur to feather edges of the mask
vGrainMask=vGrainMask.mt_logic(mt_lutxy(vGF3,last,"x y - abs 8 << ").mt_expand().binomialblur(200,u=1,v=1),"min")

#apply grain to GF3
vGF3.mt_merge( vGF3.mt_adddiff(vGrain,u=2,v=2), vGrainMask,true )
}


Function GradFun316 (clip src, float "thr", int "radius", float "elast",
\	int "mask", int "mode", float "ampo", float "ampn", int "pat",
\	bool "dyn", float "dthr", int "smode", float "wmin", float "thr_det",
\	float "thr_edg", int "debug", int "subspl")
{
	thr     = Default (thr,    0.35)
	radius  = Default (radius,   12)
	elast   = Default (elast,   3.0)
	mask    = Default (mask,      2)
	smode   = Default (smode,     0)
	wmin    = Default (wmin,    1.0)
	thr_det = Default (thr_det, 2 + Round (Dither_max (thr - 0.35, 0) / 0.3))
	debug   = Default (debug,     0)
	subspl  = Default (subspl,    0)

	# Input range check. The other parameters are checked by the plugins.
	Assert (thr     > 0, "GradFun3: "+chr(34)+"thr"    +chr(34)+" must be strictly positive.")
	Assert (thr_det > 0, "GradFun3: "+chr(34)+"thr_det"+chr(34)+" must be strictly positive.")
	Assert (elast  >= 1, "GradFun3: "+chr(34)+"elast"  +chr(34)+" must be greater or equal to 1.")

	w = src.Width ()
	h = src.Height ()

	src.Dither_convert_8_to_16 ()
	inp = last

	# Main debanding

	  (smode == 0) ? Dither_gf3_smoothgrad_multistage (radius, thr, elast)
\	: (smode == 1) ? Dither_gf3_dfttest (src, radius, thr, elast)
\	: (smode == 2) ? Dither_gf3_bilateral_multistage (radius, thr, elast, wmin, subspl)
\	: (smode == 3) ? Dither_gf3_smoothgrad_multistage_3 (radius, thr, elast)
\	:                Assert (false, "GradFun3: wrong smode value.") 
	flt = last

	# Edge/detail mask

	td_lo  = Dither_max (thr_det * 0.75, 1)
	td_hi  = Dither_max (thr_det,        1)
	mexpr  = Dither_make_expr_gate (td_lo, td_hi)

	dmask  = (mask > 0) ? src.Dither_build_gf3_range_mask (mask) : src
	dmask  = (mask > 0) ? dmask.mt_lut (expr=mexpr)         : dmask
	dmask  = (mask > 0) ? dmask.Dither_removegrain (22, -1) : dmask
	dmask  = (mask > 0) ? dmask.Dither_removegrain (19, -1) : dmask
	dmask  = (mask > 0) ? dmask.Dither_removegrain (19, -1) : dmask

	(mask > 0) ? Dither_merge16_8 (flt, inp, dmask, luma=true) : flt

	# Dithering

	result = last

	(debug == 1) ? dmask.GreyScale () : result
}

Function GradFun3 (clip src, float "thr", int "radius", float "elast",
\	int "mask", int "mode", float "ampo", float "ampn", int "pat",
\	bool "dyn", float "dthr", int "smode", float "wmin", float "thr_det",
\	float "thr_edg", int "debug", int "subspl")
{
	thr     = Default (thr,    0.35)
	radius  = Default (radius,   12)
	elast   = Default (elast,   3.0)
	mask    = Default (mask,      2)
	smode   = Default (smode,     0)
	wmin    = Default (wmin,    1.0)
	thr_det = Default (thr_det, 2 + Round (Dither_max (thr - 0.35, 0) / 0.3))
	debug   = Default (debug,     0)
	subspl  = Default (subspl,    0)

	# Input range check. The other parameters are checked by the plugins.
	Assert (thr     > 0, "GradFun3: "+chr(34)+"thr"    +chr(34)+" must be strictly positive.")
	Assert (thr_det > 0, "GradFun3: "+chr(34)+"thr_det"+chr(34)+" must be strictly positive.")
	Assert (elast  >= 1, "GradFun3: "+chr(34)+"elast"  +chr(34)+" must be greater or equal to 1.")

	w = src.Width ()
	h = src.Height ()

	src.Dither_convert_8_to_16 ()
	inp = last

	# Main debanding

	  (smode == 0) ? Dither_gf3_smoothgrad_multistage (radius, thr, elast)
\	: (smode == 1) ? Dither_gf3_dfttest (src, radius, thr, elast)
\	: (smode == 2) ? Dither_gf3_bilateral_multistage (radius, thr, elast, wmin, subspl)
\	: (smode == 3) ? Dither_gf3_smoothgrad_multistage_3 (radius, thr, elast)
\	:                Assert (false, "GradFun3: wrong smode value.") 
	flt = last

	# Edge/detail mask

	td_lo  = Dither_max (thr_det * 0.75, 1)
	td_hi  = Dither_max (thr_det,        1)
	mexpr  = Dither_make_expr_gate (td_lo, td_hi)

	dmask  = (mask > 0) ? src.Dither_build_gf3_range_mask (mask) : src
	dmask  = (mask > 0) ? dmask.mt_lut (expr=mexpr)         : dmask
	dmask  = (mask > 0) ? dmask.Dither_removegrain (22, -1) : dmask
	dmask  = (mask > 0) ? dmask.Dither_removegrain (19, -1) : dmask
	dmask  = (mask > 0) ? dmask.Dither_removegrain (19, -1) : dmask

	(mask > 0) ? Dither_merge16_8 (flt, inp, dmask, luma=true) : flt

	# Dithering

	result = DitherPost (
\		mode=mode, ampo=ampo, ampn=ampn,
\		pat=pat, dyn=dyn, prot=false, thr=dthr
\	)

	(debug == 1) ? dmask.GreyScale () : result
}



Function Dither_convert_yuv_to_rgb (clip src, string "matrix", bool "interlaced",
\	bool "tv_range", string "cplace", string "chromak", float "fh", float "fv",
\	int "taps", float "a1", float "a2", float "a3",
\	bool "lsb_in", int "mode", float "ampn", string "output")
{
	vers = VersionNumber ()

	tv_range   = Default (tv_range,     true)
	cplace     = Default (cplace,    "MPEG2")
	chromak    = Default (chromak, "bicubic")
	interlaced = Default (interlaced,  false)
	lsb_in     = Default (lsb_in,      false)
	mode       = Default (mode,            6)
	ampn       = Default (ampn,          0.5)
	output     = Default (output,    "rgb32")

	Assert ((! interlaced || src.IsFrameBased ()),
\		"Dither_convert_yuv_to_rgb: cannot process fields, only frames."
\		+ "Use Weave() before.")

	src

	# Conversion to 16 bits

	w = Width ()
	h = (lsb_in) ? Height () / 2 : Height ()
	Assert ((! interlaced || (h % 2) == 0),
\	        "Dither_convert_yuv_to_rgb: interlaced stack16 clips must "
\		+ "have a height multiple of 4.")

	(lsb_in) ? last : Dither_convert_8_to_16 ()

	# Coefficient calculation

	matrix    = Default (matrix, (h >= 600) ? "709" : "601")
	mat_i     = Dither_matrix_to_index (matrix)
	Assert ((mat_i >= 0),
\		"Dither_convert_to_rgb: unexpected matrix " + matrix + ".")

	#                     BT.601   BT.709  SMPTE 240M  FCC
	kr = Select (mat_i,   0.299,   0.2125,   0.212,   0.30)
	kg = Select (mat_i,   0.587,   0.7154,   0.701,   0.59)
	kb = Select (mat_i,   0.114,   0.0721,   0.087,   0.11)

	offset_y = (tv_range) ?          16.0 : 0.0
	scale_y  = (tv_range) ? (255.0 / 219) : 1.0
	scale_uv = (tv_range) ? (255.0 / 112) : 2.0

	# R = Y + V*(1-Kr)
	# G = Y - U*(1-Kb)*Kb/Kg - V*(1-Kr)*Kr/Kg
	# B = Y + U*(1-Kb)

	coef_ry =  scale_y
	coef_ru =  0
	coef_rv =  scale_uv * (1 - kr)
	coef_rc = -coef_ry * offset_y - coef_ru * 128 - coef_rv * 128
	kern_r  = "impulse 0 "+String(coef_rc)+" "+String(coef_rv)
\	                  +" "+String(coef_ru)+" "+String(coef_ry)

	coef_gy =  scale_y
	coef_gu = -scale_uv * (1 - kb) * kb / kg
	coef_gv = -scale_uv * (1 - kr) * kr / kg
	coef_gc = -coef_gy * offset_y - coef_gu * 128 - coef_gv * 128
	kern_g  = "impulse 0 "+String(coef_gc)+" "+String(coef_gv)
\	                  +" "+String(coef_gu)+" "+String(coef_gy)

	coef_by =  scale_y
	coef_bu =  scale_uv * (1 - kb)
	coef_bv =  0
	coef_bc = -coef_by * offset_y - coef_bu * 128 - coef_bv * 128
	kern_b  = "impulse 0 "+String(coef_bc)+" "+String(coef_bv)
\	                  +" "+String(coef_bu)+" "+String(coef_by)

	# Pixel processing

	# Luma: easy
	y = (vers < 2.60) ? last : last.ConvertToY8 ()

	# Chroma: first, find the right chroma shift to apply when resizing
	# the planes. Interlaced contents adds a bit of complexity...
	chr  = (src.GetParity ()) ? AssumeTFF () : AssumeBFF ()
	chr  = (interlaced) ? chr.SeparateFields () : chr
	idiv = (interlaced) ? 2 : 1
	hf   = h / idiv
	u    =   (vers < 2.60)      ? chr.UToY ()
\	       : src.Dither_isy8 () ? chr.mt_lut (y=-128)
\	       :                      chr.UToY8 ()
	v    =   (vers < 2.60)      ? chr.VToY ()
\	       : src.Dither_isy8 () ? chr.mt_lut (y=-128)
\	       :                      chr.VToY8 ()

	subspl_h = src.Dither_get_chroma_subspl_h ()
	subspl_v = src.Dither_get_chroma_subspl_v () * idiv

	Assert (u.Width () % subspl_h == 0 && (u.Height () / 2) % (subspl_v / idiv) == 0,
\		"Dither_convert_yuv_to_rgb: supports only mod4 sizes.")

	cp_src_h     = Dither_get_chroma_placement_h (src, cplace)

	# direction / field / plane
	cp_src_v_t_u = Dither_get_chroma_placement_v (src, cplace, interlaced, true,  true)
	cp_src_v_t_v = Dither_get_chroma_placement_v (src, cplace, interlaced, true,  false)
	cp_src_v_b_u = Dither_get_chroma_placement_v (src, cplace, interlaced, false, true)
	cp_src_v_b_v = Dither_get_chroma_placement_v (src, cplace, interlaced, false, false)

	# Converts the chroma placements to chroma shifts
	cs_h     = (0.0 - cp_src_h    ) / subspl_h
	cs_v_t_u = (0.0 - cp_src_v_t_u) / subspl_v
	cs_v_t_v = (0.0 - cp_src_v_t_v) / subspl_v
	cs_v_b_u = (1.0 - cp_src_v_b_u) / subspl_v
	cs_v_b_v = (1.0 - cp_src_v_b_v) / subspl_v

	u = (interlaced)
\	?	u.Dither_convert_yuv_to_rgb_resize_fields (
\			w, hf, cs_h, cs_v_t_u, cs_v_b_u, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	: (subspl_h > 1 && subspl_v > 1)
\	?	u.Dither_convert_yuv_to_rgb_resize_frames (
\			w, hf, cs_h, cs_v_t_u, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	:	u
	v = (interlaced)
\	?	v.Dither_convert_yuv_to_rgb_resize_fields (
\			w, hf, cs_h, cs_v_t_v, cs_v_b_v, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	: (subspl_h > 1 && subspl_v > 1)
\	?	v.Dither_convert_yuv_to_rgb_resize_frames (
\			w, hf, cs_h, cs_v_t_v, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	:	v

	# Finally, done with the chroma planes!

	# Constant multiplier. Could be optimised with BlankClip...
	c = y.Dither_lut16 ("256", u=1, v=1)

	m0 = Interleave (y,  v ).AssumeFieldBased ().AssumeTFF ().Weave ()
	m1 = Interleave (u,  c ).AssumeFieldBased ().AssumeTFF ().Weave ()
	m  = Interleave (m0, m1).AssumeFieldBased ().AssumeTFF ().Weave ()

	r = m.Dither_resize16 (w, h, src_top=2, fv=4, kernel=kern_r, center=false, cnorm=false, u=1, v=1)
	g = m.Dither_resize16 (w, h, src_top=2, fv=4, kernel=kern_g, center=false, cnorm=false, u=1, v=1)
	b = m.Dither_resize16 (w, h, src_top=2, fv=4, kernel=kern_b, center=false, cnorm=false, u=1, v=1)

	  (output == "rgb32")      ? Dither_convert_yuv_to_rgb_conv_to_rgb32 (
\		r, g, b, interlaced, GetParity (), mode, ampn, interlaced)
\	: (output == "rgb48yv12")  ? Dither_convey_rgb48_on_yv12 (r, g, b)
\	: (output == "rgb48y")     ? Interleave (r, g, b)
\	: Assert (false, "Dither_convert_stack16_to_rgb: unexpected output format.")
}



Function Dither_convert_rgb_to_yuv (clip src, clip "g", clip "b",
\	string "matrix", bool "interlaced", bool "tv_range", string "cplace",
\	string "chromak", float "fh", float "fv", int "taps", float "a1",
\	float "a2", float "a3", bool "lsb", int "mode", float "ampn",
\	string "output")
{
	vers = VersionNumber ()

	tv_range   = Default (tv_range,     true)
	cplace     = Default (cplace,    "MPEG2")
	chromak    = Default (chromak, "bicubic")
	interlaced = Default (interlaced,  false)
	output     = Default (output,     "YV12")

	Assert ((! interlaced || src.IsFrameBased ()),
\		"Dither_convert_yuv_to_rgb: cannot process fields, only frames."
\		+ "Use Weave() before.")

	src

	lsb_in = (Defined (g) && defined (b))
	lsb    = Default (lsb, lsb_in)
	Assert (   (  lsb_in && src.IsPlanar () && g.IsPlanar () && b.IsPlanar ())
\	        || (! lsb_in && src.IsRGB ()),
\	        "Dither_convert_rgb_to_yuv: "
\		+ "Input can only be 1 RGB or 3 planar stack16 clips.")

	w = Width ()
	h = Height ()
	h = (lsb_in) ? h / 2 : h

	# Conversion to 16 bits

	tmp_fmt = (vers < 2.60) ? "YV12" : "Y8"
	r = (lsb_in) ? src : src.ShowRed   (tmp_fmt).Dither_convert_8_to_16 ()
	g = (lsb_in) ?   g : src.ShowGreen (tmp_fmt).Dither_convert_8_to_16 ()
	b = (lsb_in) ?   b : src.ShowBlue  (tmp_fmt).Dither_convert_8_to_16 ()

	# Constant multiplier. Could be optimised with BlankClip...
	c = r.Dither_lut16 ("256", u=1, v=1)

	# Coefficient calculation

	matrix    = Default (matrix, (h >= 600) ? "709" : "601")
	mat_i     = Dither_matrix_to_index (matrix)
	Assert ((mat_i >= 0),
\		"Dither_convert_to_rgb: unexpected matrix" + matrix + ".")

	#                     BT.601   BT.709  SMPTE 240M  FCC
	kr = Select (mat_i,   0.299,   0.2125,   0.212,   0.30)
	kg = Select (mat_i,   0.587,   0.7154,   0.701,   0.59)
	kb = Select (mat_i,   0.114,   0.0721,   0.087,   0.11)

	offset_y = (tv_range) ?          16.0 : 0.0
	scale_y  = (tv_range) ? (219 / 255.0) : 1.0
	scale_uv = (tv_range) ? (112 / 255.0) : 0.5

	# Y =                  R * Kr        + G * Kg        + B * Kb
	# U = (B-Y)/(1-Kb) = - R * Kr/(1-Kb) - G * Kg/(1-Kb) + B
	# V = (R-Y)/(1-Kr) =   R             - G * Kg/(1-Kr) - B * Kb/(1-Kr)

	coef_yr =  scale_y  * kr
	coef_yg =  scale_y  * kg
	coef_yb =  scale_y  * kb
	coef_yc =  offset_y
	kern_y  = "impulse 0 "+String(coef_yc)+" "+String(coef_yb)
\	                  +" "+String(coef_yg)+" "+String(coef_yr)

	coef_ur = -scale_uv * kr / (1 - kb)
	coef_ug = -scale_uv * kg / (1 - kb)
	coef_ub =  scale_uv
	coef_uc =  128
	kern_u  = "impulse 0 "+String(coef_uc)+" "+String(coef_ub)
\	                  +" "+String(coef_ug)+" "+String(coef_ur)

	coef_vr =  scale_uv
	coef_vg = -scale_uv * kg / (1 - kr)
	coef_vb = -scale_uv * kb / (1 - kr)
	coef_vc =  128
	kern_v  = "impulse 0 "+String(coef_vc)+" "+String(coef_vb)
\	                  +" "+String(coef_vg)+" "+String(coef_vr)

	# Pixel processing

	m0 = Interleave (r,  b ).AssumeFieldBased ().AssumeTFF ().Weave ()
	m1 = Interleave (g,  c ).AssumeFieldBased ().AssumeTFF ().Weave ()
	m  = Interleave (m0, m1).AssumeFieldBased ().AssumeTFF ().Weave ()
	m  = (src.GetParity ()) ? m.AssumeTFF () : m.AssumeBFF ()

	y = m.Dither_resize16 (w, h, src_top=2, fv=4, kernel=kern_y, center=false, cnorm=false, u=1, v=1)
	u = m.Dither_resize16 (w, h, src_top=2, fv=4, kernel=kern_u, center=false, cnorm=false, u=1, v=1)
	v = m.Dither_resize16 (w, h, src_top=2, fv=4, kernel=kern_v, center=false, cnorm=false, u=1, v=1)

	# Luma: nothing to do

	# Chroma: first, find the right chroma shift to apply when resizing
	# the planes Interlaced contents adds a bit of complexity...

	# We don't use the pixels of this clip, it just helps us to know
	# the chroma plane size.
	p =   (vers < 2.60)       ? y
\	    : (output == "YV12")  ? y.ConvertToYV12 ()
\	    : (output == "YV16")  ? y.ConvertToYV16 ()
\	    : (output == "YV24")  ? y.ConvertToYV24 ()
\	    : (output == "YV411") ? y.ConvertToYV411 ()
\	    : (output == "Y8")    ? y.ConvertToY8 ()
\	    : Assert ("Dither_convert_rgb_to_yuv: unsupported output colorspace.")

	wc   = p.Dither_isy8 () ? w : p.UToY ().Width ()
	hc   = p.Dither_isy8 () ? h : (p.UToY ().Height () / 2)
	idiv = (interlaced) ? 2 : 1
	hcf  = hc / idiv

	cp_dst_h     = Dither_get_chroma_placement_h (p, cplace)

	# direction / field / plane
	cp_dst_v_t_u = Dither_get_chroma_placement_v (p, cplace, interlaced, true,  true)
	cp_dst_v_t_v = Dither_get_chroma_placement_v (p, cplace, interlaced, true,  false)
	cp_dst_v_b_u = Dither_get_chroma_placement_v (p, cplace, interlaced, false, true)
	cp_dst_v_b_v = Dither_get_chroma_placement_v (p, cplace, interlaced, false, false)

	# Converts the chroma placements to chroma shifts
	cs_h     =  cp_dst_h     - 0.0
	cs_v_t_u = (cp_dst_v_t_u - 0.0) / idiv 
	cs_v_t_v = (cp_dst_v_t_v - 0.0) / idiv 
	cs_v_b_u = (cp_dst_v_b_u - 1.0) / idiv 
	cs_v_b_v = (cp_dst_v_b_v - 1.0) / idiv 

	u = (interlaced)
\	?	u.Dither_convert_rgb_to_yuv_resize_fields (
\			wc, hcf, cs_h, cs_v_t_u, cs_v_b_u, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	: (output != "Y8")
\	?	u.Dither_convert_rgb_to_yuv_resize_frames (
\			wc, hcf, cs_h, cs_v_t_u, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	:	u
	v = (interlaced)
\	?	v.Dither_convert_rgb_to_yuv_resize_fields (
\			wc, hcf, cs_h, cs_v_t_v, cs_v_b_v, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	: (output != "Y8")
\	?	v.Dither_convert_rgb_to_yuv_resize_frames (
\			wc, hcf, cs_h, cs_v_t_v, chromak,
\			fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3)
\	:	v

	# Finally, done with the chroma planes!

	# Merges all the planes

	(output == "Y8") ? y : Dither_y_to_uv (u, v, y)
	(lsb) ? last : DitherPost (mode=mode, ampn=ampn, interlaced=interlaced)
}


Function Dither_convey_yuv4xxp16_on_yvxx (clip src, bool "bigendian")
{
	bigendian = Default (bigendian, false)

	src
	msb = Dither_get_msb ()
	lsb = Dither_get_lsb ()

	(bigendian) ? Interleave (msb, lsb) : Interleave (lsb, msb)
	TurnRight ()
	AssumeFieldBased ().AssumeTFF ()
	Weave ()
	TurnLeft ()
}



Function Dither_convey_rgb48_on_yv12 (clip r, clip g, clip b, bool "bigendian")
{
	bigendian = Default (bigendian, false)

	Assert (r.IsYV12 () && g.IsYV12 () && b.IsYV12 (),
\		"Dither_convey_rgb48_on_yv12: r, g and b must be YV12.")

	w = r.Width ()
	h = r.Height () / 2

	m0 = Interleave (r,  b ).TurnRight ().AssumeFieldBased ().AssumeTFF ().Weave ()
	m1 = Interleave (g,  b ).TurnRight ().AssumeFieldBased ().AssumeTFF ().Weave ()
	m  = Interleave (m0, m1).AssumeFieldBased ().AssumeTFF ().Weave ()
	m.PointResize (h * 2, w * 3)

	lsb = Crop (0, 0, h, 0)
	msb = Crop (h, 0, 0, 0)
	(bigendian) ? Interleave (msb, lsb) : Interleave (lsb, msb)
	AssumeFieldBased ().AssumeTFF ()
	Weave ()

	TurnLeft ()	# Now we have a 6*w x h pic

	a = Crop (w * 0, 0, w * 2, 0)
	b = Crop (w * 2, 0, w * 2, 0)
	c = Crop (w * 4, 0, w * 2, 0)

	m0 = Interleave (a,  c ).AssumeFieldBased ().AssumeTFF ().Weave ()
	m1 = Interleave (b,  c ).AssumeFieldBased ().AssumeTFF ().Weave ()
	m  = Interleave (m0, m1).AssumeFieldBased ().AssumeTFF ().Weave ()
	m.PointResize (w * 2, h * 3)

	y  = Crop (0, 0,     w * 2, h * 2)
	k1 = Crop (0, h * 2, w    , h    )
	k2 = Crop (w, h * 2, w    , h    )
	Interleave (k1, k2).AssumeFieldBased ().AssumeTFF ().Weave ()

	YToUV (Crop (0, 0, 0, h), Crop (0, h, 0, 0), y)
}




Function DitherTestPatterns (int "size", int "mag", int "amp", int "len", int "luma")
{
	size = Default (size, 192)
	mag  = Default (mag,    1)
	amp  = Default (amp,    1)
	len  = Default (len,   24)
	luma = Default (luma, 128)

	sr = (size / (mag * 2)) * 2

	c = BlankClip (length=len, width=sr, height=sr, pixel_type="YV12", fps=24000, fps_denominator=1001)
	c = c.KillAudio ()
	c = mt_lutspa (
\		c,
\		yexpr="  x       2 ^   y       2 ^ + 2    / 0.5 ^ 256 *",
\		uexpr="1 x -     2 ^   y 0.5 * 2 ^ + 1.25 / 0.5 ^ 256 *",
\		vexpr="  x 0.5 * 2 ^ 1 y -     2 ^ + 1.25 * 0.5 ^ 256 *",
\		relative=true, y=3, u=3, v=3
\	)
	lsb = c.mt_lut (expr="x 2 * 256 %", y=3, u=3, v=3)
	msb = c.mt_lut (expr="x 2 * x 2 * 256 % - 256 / 127 +", y=3, u=3, v=3)
	c16 = StackVertical (msb, lsb)

	z00 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=-1)", "None")
	z10 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.9, ampo=0.0, dyn=False)", "0n0.9s")
	z20 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=1.5, ampo=0.0, dyn=False)", "0n1.5s")
	z30 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=2.0, ampo=0.0, dyn=False)", "0n2.0s")
	z01 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.0, ampo=1.0, dyn=False)", "0o1.0s")
	z02 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.0, ampo=1.0, dyn=True )", "0o1.0d")
	z03 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.0, ampo=2.0, dyn=False)", "0o2.0s")
	z11 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.1, ampo=1.0, dyn=False)", "0n0.1o1.0s")
	z22 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.0, ampo=1.0, thr=0.05, dyn=False)", "0o1.0t0.05s")
	z33 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, ampn=0.0, ampo=3.0, thr=0.05, dyn=False)", "0o3.0t0.05s")
	x00 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=1, dyn=False)", "1s")
	x01 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=1, dyn=True )", "1d")
	y10 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=2, dyn=False)", "2p0s")
	y11 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=2, dyn=True )", "2p0d")
	y12 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=1, mode=2, dyn=True )", "2p1d")
	y13 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=2, mode=2, dyn=True )", "2p2d")
	y20 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=3, dyn=False)", "3p0s")
	y21 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=3, dyn=True )", "3p0d")
	y22 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=1, mode=3, dyn=True )", "3p1d")
	y23 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=2, mode=3, dyn=True )", "3p2d")
	y30 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=4, dyn=False)", "4p0s")
	y31 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=4, dyn=True )", "4p0d")
	y32 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=1, mode=4, dyn=True )", "4p1d")
	y33 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=2, mode=4, dyn=True )", "4p2d")
	y40 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=5, dyn=False)", "5p0s")
	y41 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=0, mode=5, dyn=True )", "5p0d")
	y42 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=1, mode=5, dyn=True )", "5p1d")
	y43 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, pat=2, mode=5, dyn=True )", "5p2d")
	e00 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=6, ampo=1.0, ampn=0.0, prot=false, dyn=false)", "FSn0.0")
	e01 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=6, ampo=1.0, ampn=0.8, prot=false, dyn=false)", "FSn0.8")
	e02 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=6, ampo=1.4, ampn=0.0, prot=false, dyn=false)", "FSo1.4")
	e03 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=6, ampo=1.3, ampn=0.2, prot=false, dyn=false)", "FSo1.3n0.2")
	e04 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=7, ampo=1.0, ampn=0.0, prot=false, dyn=false)", "STo0.0")
	e05 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=8, ampo=1.0, ampn=0.0, prot=false, dyn=false)", "ATo0.0")
	e06 = Dither_test_single (c16, mag, amp, luma, "DitherPost (c16, mode=8, ampo=1.6, ampn=0.0, prot=false, dyn=false)", "ATo1.6")

	k0 = StackVertical (z00, z10, z20, z30, e00)
	k1 = StackVertical (x00, z01, z02, z03, e01)
	k2 = StackVertical (x01, z11, z22, z33, e02)
	k3 = StackVertical (y10, y11, y12, y13, e03)
	k4 = StackVertical (y20, y21, y22, y23, e04)
	k5 = StackVertical (y30, y31, y32, y33, e05)
	k6 = StackVertical (y40, y41, y42, y43, e06)

	StackHorizontal (k0, k1, k2, k3, k4, k5, k6)
}



### Tools for 16-bit clips ###################################################



Function Dither_get_msb (clip src)
{
	src
	w = Width ()
	h = Height () / 2
	Crop (0, 0, w, h)
}



Function Dither_get_lsb (clip src)
{
	src
	w = Width ()
	h = Height () / 2
	Crop (0, h, w, h)
}



Function Dither_gen_null_lsb (clip src)
{
	vers = VersionNumber ()
	BlankClip (src, pixel_type="YV12", length=src.FrameCount (), color_yuv=$000000)
	  (src.IsYV12 ())                   ? last
\	: (vers >= 2.60 && src.IsYV16 ())   ? last.ConvertToYV16 ()
\	: (vers >= 2.60 && src.IsYV24 ())   ? last.ConvertToYV24 ()
\	: (vers >= 2.60 && src.IsPlanar ()) ? last.ConvertToY8 ()
\	: Assert (false, "Only planar colorspaces are supported.")
}



Function Dither_convert_8_to_16 (clip src)
{
	StackVertical (src, src.Dither_gen_null_lsb ())
}



Function Dither_crop16 (clip src, int "left", int "top",
\	int "width", int "height", bool "align")
{
	left   = Default (left,   0)
	top    = Default (top,    0)
	width  = Default (width,  0)
	height = Default (height, 0)

	src
	w = Width ()
	h = Height () / 2

	width  = (width  <= 0) ? w - left + width  : width
	height = (height <= 0) ? h - top  + height : height
	Assert (width  > 0)
	Assert (height > 0)

	msb = Crop (left, top,     width, height, align)
	lsb = Crop (left, top + h, width, height, align)

	StackVertical (msb, lsb)
}



Function Dither_merge16_8 (clip src1, clip src2, clip mask, bool "luma")
{
	vers = VersionNumber ()

	luma = Default (luma, false)

	w = mask.Width ()
	h = mask.Height ()
	Assert (src1.Width ()  == w)
	Assert (src2.Width ()  == w)
	Assert (src1.Height () == h * 2)
	Assert (src2.Height () == h * 2)

	mask = (luma && (vers < 2.6 || ! src1.Dither_isy8 ()))
\	? mask.MergeChroma (mask.YToUV (mask).BilinearResize (w, h))
\	: mask

	msb1 = src1.Dither_get_msb ()
	lsb1 = src1.Dither_get_lsb ()
	msb2 = src2.Dither_get_msb ()
	lsb2 = src2.Dither_get_lsb ()

	p1a = Dither_lutxy8 (msb1, mask, expr="256 y - x *      ", y=3, u=3, v=3)
	p1b = Dither_lutxy8 (lsb1, mask, expr="256 y - x * 256 /", y=3, u=3, v=3)

	p2a = Dither_lutxy8 (msb2, mask, expr="    y   x *      ", y=3, u=3, v=3)
	p2b = Dither_lutxy8 (lsb2, mask, expr="    y   x * 256 /", y=3, u=3, v=3)

	p1 = Dither_add16 (p1a, p1b, wrap=True)
	p2 = Dither_add16 (p2a, p2b, wrap=True)

	Dither_add16 (p1, p2, wrap=True)
}



# src is a stacked 16-bit clip
# ?expr is a mt_lut-like expression, using x as variable in range [0 ; 65535]
Function Dither_lut16 (clip src,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	s_msb = Dither_get_msb (src)
	s_lsb = Dither_get_lsb (src)

	d_msb = Dither_lut16_msb (s_msb, s_lsb,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
	d_lsb = Dither_lut16_lsb (s_msb, s_lsb,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)

	StackVertical (d_msb, d_lsb)
}

Function Dither_lut16_msb (clip msb, clip lsb,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	expr  = Dither_lut16_expr (expr,  True)
	yexpr = Dither_lut16_expr (yexpr, True)
	uexpr = Dither_lut16_expr (uexpr, True)
	vexpr = Dither_lut16_expr (vexpr, True)

	mt_lutxy (msb, lsb,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}

Function Dither_lut16_lsb (clip msb, clip lsb,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	expr  = Dither_lut16_expr (expr,  False)
	yexpr = Dither_lut16_expr (yexpr, False)
	uexpr = Dither_lut16_expr (uexpr, False)
	vexpr = Dither_lut16_expr (vexpr, False)

	mt_lutxy (lsb, msb,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}

Function Dither_lut16_expr (string expr, bool gmsb)
{
	# We use spaces to enclose " x " because we don't want operators
	# like "max" or "exp" to have their "x" replaced...
	repstr = (gmsb) ? " x 256 * y + " : " y 256 * x + "
	expr = Dither_replace_string (" " + expr + " ", " x ", repstr)
	part = Dither_expr_part (gmsb)
	expr = expr + part

	return (expr)
}



Function Dither_lut8 (clip src,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	d_msb = Dither_lut8_msb (src,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
	d_lsb = Dither_lut8_lsb (src,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)

	StackVertical (d_msb, d_lsb)
}

Function Dither_lut8_msb (clip src,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	part  = Dither_expr_part (true)
	expr  = expr  + part
	yexpr = yexpr + part
	uexpr = uexpr + part
	vexpr = vexpr + part

	mt_lut (src, expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}

Function Dither_lut8_lsb (clip src,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	part  = Dither_expr_part (false)
	expr  = expr  + part
	yexpr = yexpr + part
	uexpr = uexpr + part
	vexpr = vexpr + part
	y = (Defined (y) && (y==2 || y==4 || y==5)) ? 0 : y
	u = (Defined (u) && (y==2 || y==4 || y==5)) ? 0 : u
	v = (Defined (v) && (y==2 || y==4 || y==5)) ? 0 : v

	mt_lut (src, expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}



Function Dither_lutxy8 (clip src1, clip src2,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	d_msb = Dither_lutxy8_msb (src1, src2,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
	d_lsb = Dither_lutxy8_lsb (src1, src2,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)

	StackVertical (d_msb, d_lsb)
}

Function Dither_lutxy8_msb (clip src1, clip src2,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	part  = Dither_expr_part (true)
	expr  = expr  + part
	yexpr = yexpr + part
	uexpr = uexpr + part
	vexpr = vexpr + part

	mt_lutxy (src1, src2,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}

Function Dither_lutxy8_lsb (clip src1, clip src2,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	part  = Dither_expr_part (false)
	expr  = expr  + part
	yexpr = yexpr + part
	uexpr = uexpr + part
	vexpr = vexpr + part
	y = (Defined (y) && (y==2 || y==4 || y==5)) ? 0 : y
	u = (Defined (u) && (y==2 || y==4 || y==5)) ? 0 : u
	v = (Defined (v) && (y==2 || y==4 || y==5)) ? 0 : v

	mt_lutxy (src1, src2, expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr,
\		y=y, u=u, v=v)
}



Function Dither_lutxyz8 (clip src1, clip src2, clip src3,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	d_msb = Dither_lutxyz8_msb (src1, src2, src3,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
	d_lsb = Dither_lutxyz8_lsb (src1, src2, src3,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)

	StackVertical (d_msb, d_lsb)
}

Function Dither_lutxyz8_msb (clip src1, clip src2, clip src3,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	part  = Dither_expr_part (true)
	expr  = expr  + part
	yexpr = yexpr + part
	uexpr = uexpr + part
	vexpr = vexpr + part

	mt_lutxyz (src1, src2, src3,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}

Function Dither_lutxyz8_lsb (clip src1, clip src2, clip src3,
\	string "expr", string "yexpr", string "uexpr", string "vexpr",
\	int "y", int "u", int "v")
{
	expr  = Default (expr,  "x")
	yexpr = Default (yexpr, expr)
	uexpr = Default (uexpr, expr)
	vexpr = Default (vexpr, expr)
	part  = Dither_expr_part (false)
	expr  = expr  + part
	yexpr = yexpr + part
	uexpr = uexpr + part
	vexpr = vexpr + part
	y = (Defined (y) && (y==2 || y==4 || y==5)) ? 0 : y
	u = (Defined (u) && (y==2 || y==4 || y==5)) ? 0 : u
	v = (Defined (v) && (y==2 || y==4 || y==5)) ? 0 : v

	mt_lutxyz (src1, src2, src3,
\		expr=expr, yexpr=yexpr, uexpr=uexpr, vexpr=vexpr, y=y, u=u, v=v)
}



Function Dither_y_gamma_to_linear (clip src, bool "tv_range_in", bool "tv_range_out")
{
	tv_range_in  = Default (tv_range_in,  true)
	tv_range_out = Default (tv_range_out, true)

	expr   = "x 0.04045 <=   x 12.92 /   x 0.055 + 1.055 / 2.4 ^   ?"
	repstr = (tv_range_in) ? " x 4096 - 56064 / 0 max " : " x 65536 / "
	expr   = Dither_replace_string (" " + expr + " ", " x ", repstr)
	expr   = expr + ((tv_range_out) ? " 56064 * 4096 +" : " 65536 *")
	src.Dither_lut16 (yexpr=expr, y=3, u=2, v=2)
}

Function Dither_y_linear_to_gamma (clip src, bool "tv_range_in", bool "tv_range_out")
{
	tv_range_in  = Default (tv_range_in,  true)
	tv_range_out = Default (tv_range_out, true)

	expr   = "x 0.0031308 <=   x 12.92 *   x 1 2.4 / ^ 1.055 * 0.0555 -   ?"
	repstr = (tv_range_in) ? " x 4096 - 56064 / 0 max " : " x 65536 / "
	expr   = Dither_replace_string (" " + expr + " ", " x ", repstr)
	expr   = expr + ((tv_range_out) ? " 56064 * 4096 +" : " 65536 *")
	src.Dither_lut16 (yexpr=expr, y=3, u=2, v=2)
}



Function Dither_expr_part (bool gmsb)
{
	part = (gmsb) ? "8 >>u "    : "255 &u "
	expr = " 0 65535 clip " + part

	return (expr)
}


### Internal utility functions ###############################################



Function Dither_min (val a, val b)
{
	return ((a < b) ? a : b)
}

Function Dither_max (val a, val b)
{
	return ((b < a) ? a : b)
}



Function DitherPre_internal (clip m, int bitd, string "flt", bool "stacked", float "overlap", bool "tvopt")
{
	flt      = Default (flt, "dfttest (sigma=16.0 * "+String (Pow (4, bitd))+")")
	stacked  = Default (stacked, true)
	tvopt    = Default (tvopt,  false)
	overlap  = Default (overlap, 0.5)

	n_base   = Int (Round (Pow (2, bitd)))

	n_add_mi = (tvopt) ? 0 : 1
	n_add    = Dither_max (Int (Round (n_base * 2 * overlap)) - 1, n_add_mi)
	Assert (n_add < n_base, "DitherXPre: overlap must be <= 0.5")

	n        = n_base + n_add

	DitherPre_internal_rec (m, m, flt, 0, bitd, tvopt, n)

	msb = SelectEven ()
	lsb = SelectOdd ()
	(stacked) ? StackVertical (msb, lsb) : last
}

Function DitherPre_internal_rec (clip msblsbi, clip m, string flt, int k, int bitd, bool tvopt, int n)
{
	msblsbi
	(k == 0) ? DitherPre_internal_first (flt, bitd, tvopt)
\	         : DitherPre_internal_next (m, flt, k, bitd, tvopt, n)

	(k < n - 1) ? DitherPre_internal_rec (m, flt, k + 1, bitd, tvopt, n) : last
}

Function DitherPre_internal_first (clip m, string flt, int bitd, bool tvopt)
{
	p     = Int (Round (Pow (2, bitd)))
	bitds = String (bitd)
	ds    = String (8 - bitd)
	of    = (tvopt) ?  16 :   0
	rbs   = String (of * p)

	m0 = m.mt_lut (expr="x "+bitds+" <<u "+rbs+" -", y=3, u=3, v=3)
	m0 = Eval ("m0." + flt)
	msb = m0.mt_lut (expr="x "+rbs+" + "+bitds+" >>u", y=3, u=3, v=3)
	lsb = m0.mt_lut (expr="x "+rbs+" + "+ds+" <<u 255 &u", y=3, u=3, v=3)
	Interleave (msb, lsb)
}

Function DitherPre_internal_next (clip msblsbi, clip m, string flt, int k, int bitd, bool tvopt, int n)
{
	msb   = msblsbi.SelectEven ()
	lsb   = msblsbi.SelectOdd ()

	p     = Int (Round (Pow (2, bitd)))
	pms   = String (p * 256 - 1)
	of    = (tvopt) ?  16 :   0
	sz    = (tvopt) ? 224 : 256

	bitds = String (bitd)
	ds    = String (8 - bitd)
	rb    = (of * p) + Ceil ((sz * p - 256.0) * k / (n - 1))	# Range begin, in N-bit scale
	rbs   = String (rb)
	ovlap = 256.0 - (sz * p - 256.0) / (n - 1)	# Overlap, in N-bit scale
	thr   = Round (ovlap / 2)			# Relative to rb
	thrs  = String (thr)

	mk = m.mt_lut (expr="x "+bitds+" <<u "+rbs+" -", y=3, u=3, v=3)
	mk = Eval ("mk." + flt)

	msb = mt_lutxy (
\		mk, msb,
\		expr="x "+thrs+" < y x "+rbs+" + "+pms+" min "+bitds+" >>u ?",
\		y=3, u=3, v=3
\	)
	lsb = mt_lutxy (
\		mk, lsb,
\		expr="x "+thrs+" < y x "+rbs+" + "+pms+" min "+ds+" <<u 255 &u ?",
\		y=3, u=3, v=3
\	)

	Interleave (msb, lsb)
}



Function Dither_replace_string (string str, string findstr, string repstr)
{
	strl     = LCase (str)
	findstrl = LCase (findstr)
	lenf     = StrLen (findstr)

	pos = FindStr (strl, findstrl)
	pos2 = (pos <= 0) ? 1 : pos
	rep  = (pos <= 0) ? "" : LeftStr (str, pos-1) + repstr + Dither_replace_string (MidStr (str, pos + lenf), findstr, repstr)

	return ((pos <= 0) ? str : rep)
}



Function Dither_undef () {}



Function Dither_test_single (clip c16, int mag, int amp, int luma, String ditherfunc, String txt)
{
	Eval (ditherfunc)
	mt_lut (expr="x 128 - " + String (amp) + " * 128 +", y=3, u=3, v=3)
	mt_lut (expr="x " + String (luma - 128) + " +", y=3, u=2, v=2)
	PointResize (Width () * mag, Height () * mag)
	Subtitle (txt, align=2)
}



Function Dither_gf3_smoothgrad_multistage (clip src, int radius, float thr, float elast)
{
	ela_2 = Dither_max (elast * 0.83, 1)
	ela_3 = Dither_max (elast * 0.67, 1)

	src

	SmoothGrad (radius=radius*2/3, thr=thr,      elast=elast)
	SmoothGrad (radius=radius*3/3, thr=thr*0.7,  elast=ela_2, ref=src)
	SmoothGrad (radius=radius*4/3, thr=thr*0.46, elast=ela_3, ref=src)
}



Function Dither_gf3_smoothgrad_multistage_3 (clip src, int radius, float thr, float elast)
{
	src

	ref = SmoothGrad (radius=radius/3, thr=thr*0.8, elast=elast)

	Dither_box_filter16 (radius=radius)
	Dither_box_filter16 (radius=radius)

	Dither_limit_dif16 (last, src, thr=thr*0.6, elast=elast, ref=ref)
}



Function Dither_gf3_dfttest (clip src, clip src_8, int radius, float thr, float elast)
{
	hrad = Dither_max (radius * 3 / 4, 1)

	src_8
	dfttest (sigma=hrad*thr*thr*32, tbsize=1, sbsize=hrad*4, sosize=hrad*3, lsb=true)

	Dither_limit_dif16 (last, src, thr=thr, elast=elast)
}



Function Dither_gf3_bilateral_multistage (clip src, int radius, float thr, float elast, float wmin, int subspl)
{
	thr_1    = Dither_max (thr * 4.5, 1.25)
	thr_2    = Dither_max (thr * 9,   5.0)
	subspl_2 = (subspl == 1) ? 1 : subspl / 2

	src
	Dither_bilateral16 (radius=radius*4/3, thr=thr_1, flat=0.75, wmin=wmin, ref=src, subspl=subspl)
	Dither_bilateral16 (radius=radius*2/3, thr=thr_2, flat=0.25, wmin=wmin, ref=src, subspl=subspl_2)
	Dither_bilateral16 (radius=radius*1/3, thr=thr_2, flat=0.50, wmin=wmin, ref=src, subspl=subspl_2)

	Dither_limit_dif16 (last, src, thr=thr, elast=elast)
}



Function Dither_build_gf3_range_mask (clip src, int radius)
{
	src
	ma  = (radius >  1) ? mt_expand_multi (sw=radius, sh=radius, mode="ellipse") : last
	mi  = (radius >  1) ? mt_inpand_multi (sw=radius, sh=radius, mode="ellipse") : last

	(radius >  1) ? mt_lutxy (ma, mi, "x y -")
\	              : mt_edge (mode="min/max", thY1=0, thY2=255)
}



# pass if x >= thr_hi
# cut  if x <= thr_lo
Function Dither_make_expr_gate (float thr_lo, float thr_hi)
{
	Assert (thr_lo <= thr_hi)

	# 255 * (x - tl) / (th - tl)
	tl = String (thr_lo - 0.0001)
	th = String (thr_hi + 0.0001)

	return ("x "+tl+" - "+th+" "+tl+" - / 255 *")
}



Function Dither_convert_yuv_to_rgb_resize_frames (clip src, int w, int h,
\	float cs_h, float cs_v, string chromak, float "fh", float "fv",
\	int "taps", float "a1", float "a2", float "a3")
{
	src
	Dither_resize16 (w, h, src_left=cs_h, src_top=cs_v, kernel=chromak,
\		fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3, center=false,
\		u=1, v=1)
}



Function Dither_convert_yuv_to_rgb_resize_fields (clip src, int w, int h,
\	float cs_h, float cs_v_t, float cs_v_b, string chromak, float "fh",
\	float "fv", int "taps", float "a1", float "a2", float "a3")
{
	src
	p = GetParity ()
	ofs = (p) ? 0 : 1
	t = SelectEvery (2,     ofs)
	b = SelectEvery (2, 1 - ofs)
	t = t.Dither_resize16 (w, h, src_left=cs_h, src_top=cs_v_t, kernel=chromak,
\		fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3, center=false,
\		u=1, v=1)
	b = b.Dither_resize16 (w, h, src_left=cs_h, src_top=cs_v_b, kernel=chromak,
\		fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3, center=false,
\		u=1, v=1)
	(p) ? Interleave (t, b).AssumeFieldBased ().AssumeTFF ()
\	    : Interleave (b, t).AssumeFieldBased ().AssumeBFF ()
	Weave ()
}



Function Dither_convert_yuv_to_rgb_conv_to_rgb32 (clip r, clip g, clip b,
\	bool interlaced, bool parity, int mode, float ampn, bool interlaced)
{
	Interleave (r, g, b)
	DitherPost (mode=mode, ampn=ampn, interlaced=interlaced, u=1, v=1)
	MergeRGB (SelectEvery (3, 0), SelectEvery (3, 1), SelectEvery (3, 2))
	AssumeFrameBased ()
	(! interlaced) ? last : (parity) ? AssumeTFF () : AssumeBFF ()
}



Function Dither_convert_rgb_to_yuv_resize_frames (clip src, int w, int h,
\	float cs_h, float cs_v, string chromak, float "fh", float "fv",
\	int "taps", float "a1", float "a2", float "a3")
{
	src
	Dither_resize16 (w, h, src_left=cs_h, src_top=cs_v, kernel=chromak,
\		fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3, center=false,
\		u=1, v=1)
}



Function Dither_convert_rgb_to_yuv_resize_fields (clip src, int w, int h,
\	float cs_h, float cs_v_t, float cs_v_b, string chromak,
\	float "fh", float "fv", int "taps", float "a1", float "a2", float "a3")
{
	src
	cssh = Dither_get_chroma_subspl_h ()
	cssv = Dither_get_chroma_subspl_v ()
	p    = GetParity ()
	ofs  = (p) ? 0 : 1
	SeparateFields ()
	t    = SelectEvery (2,     ofs)
	b    = SelectEvery (2, 1 - ofs)

	w2   = Int (w + cssh - 1) / cssh * cssh
	h2   = Int (h + cssh - 1) / cssv * cssv
	sz_w = Float (t.Width ()     ) * w2 / w
	sz_h = Float (t.Height () / 2) * h2 / h

	t = t.Dither_resize16 (w2, h2, src_left=cs_h, src_top=cs_v_t,
\		src_width=sz_w, src_height=sz_h, kernel=chromak,
\		fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3, center=false,
\	        u=1, v=1)
	b = b.Dither_resize16 (w2, h2, src_left=cs_h, src_top=cs_v_b,
\		src_width=sz_w, src_height=sz_h, kernel=chromak,
\		fh=fh, fv=fv, taps=taps, a1=a1, a2=a2, a3=a3, center=false,
\		u=1, v=1)
	(p) ? Interleave (t, b).AssumeFieldBased ().AssumeTFF ()
\	    : Interleave (b, t).AssumeFieldBased ().AssumeBFF ()
	Weave ()
}



Function Dither_matrix_to_index (string matrix)
{
	return (
\	  (matrix == "601") ?  0
\	: (matrix == "709") ?  1
\	: (matrix == "240") ?  2
\	: (matrix == "FCC") ?  3
\	:                     -1)
}



# http://www.mir.com/DMG/chroma.html
# Relative to the frame origin in luma scale.
Function Dither_get_chroma_placement_h (clip src, string cplace)
{
	wl = src.Width ()
	wc = src.Dither_isy8 () ? wl : src.UToY ().Width ()
	subspl = wl / wc

	pos = (cplace == "MPEG2" || cplace == "DV") ? 0 : 0.5
	
	return (pos)
}



# When interlaced == true, chroma placement is relative to the frame origin, not the field origin
Function Dither_get_chroma_placement_v (clip src, string cplace, bool interlaced, bool parity, bool u)
{
	hl = src.Height ()
	hc = src.Dither_isy8 () ? hl : src.UToY ().Height ()
	subspl = hl / hc

	# No vertical subsampling
	pos_ss1      = (! interlaced) ? 0.0 : (parity) ? 0.0   : 1.0

	# 2x vertical subsampling
	pos_ss2_mpeg = (! interlaced) ? 0.5 : (parity) ? 0.5 : 2.5
	pos_ss2_dv_u = (! interlaced) ? 1.0 : (parity) ? 2.0 : 3.0
	pos_ss2_dv_v = (! interlaced) ? 0.0 : (parity) ? 0.0 : 1.0
	pos_ss2_dv   = (u) ? pos_ss2_dv_u : pos_ss2_dv_v
	pos_ss2      = (cplace == "DV") ? pos_ss2_dv : pos_ss2_mpeg

	pos          = (subspl == 2) ? pos_ss2 : pos_ss1

	return (pos)
}



Function Dither_isy8 (clip src)
{
	vers = VersionNumber ()

	return (     vers >= 2.6
\	        &&   src.IsPlanar ()
\	        && ! src.IsYV12 ()
\	        && ! src.IsYV16 ()
\	        && ! src.IsYV24 ())
}



Function Dither_get_chroma_subspl_h (src)
{
	Assert (src.IsPlanar () && src.IsYUV ())

	vers = VersionNumber ()
	s =   (vers < 2.6)         ? 2
\	    : (src.IsYV12 ())      ? 2
\	    : (src.IsYV16 ())      ? 2
\	    : (src.IsYV24 ())      ? 1
\	    : (src.Dither_isy8 ()) ? 1
\	    :                        4

	return (s)
}



Function Dither_get_chroma_subspl_v (src)
{
	Assert (src.IsPlanar () && src.IsYUV ())

	vers = VersionNumber ()
	s =   (vers < 2.6)         ? 2
\	    : (src.IsYV12 ())      ? 2
\	    : (src.IsYV16 ())      ? 1
\	    : (src.IsYV24 ())      ? 1
\	    : (src.Dither_isy8 ()) ? 1
\	    :                        1

	return (s)
}



Function Dither_y_to_uv (clip u, clip v, clip y)
{
	w     = y.Width ()
	h     = y.Height ()
	uvw   = u.Width ()
	uvh   = u.Height ()
	cssh  = y.Dither_get_chroma_subspl_h ()
	cssv  = y.Dither_get_chroma_subspl_v ()
	dif_h = uvw * cssh - w
	dif_v = uvh * cssv - h
	fix   = (dif_h > 0 || dif_v > 0)

	y
	(fix) ? AddBorders (0, 0, dif_h, dif_v) : last
	YToUV (u, v, last)
	(fix) ? Crop (0, 0, w, h) : last
}



Function Dither_removegrain (clip src, int ml, int "mc")
{
	mc = Default (mc, ml)

	Assert ((ml == mc || ml <= 0 || mc <= 0))

	y  = (ml < 0) ? 1 : (ml == 0) ? 2 : 3
	uv = (mc < 0) ? 1 : (mc == 0) ? 2 : 3

	# Modes 21 and 22 are actually very different from the original
	# RemoveGrain. But they look ok when smoothing masks.
	mode =
\	  (ml == 19) ? "1 1 1 1 0 1 1 1 1"
\	: (ml == 20) ? "1 1 1 1 1 1 1 1 1"
\	: (ml == 21) ? "1 1 1 1 4 1 1 1 1"
\	: (ml == 22) ? "1 1 1 1 4 1 1 1 1"
\	: Assert (false)

	src

	IsYV12 ()
\	? RemoveGrain (ml, mc)
\	: mt_edge (mode=mode, thY1=0, thY2=255, thC1=0, thC2=255, y=y, u=uv, v=uv)
}

