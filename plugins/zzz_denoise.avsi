
Function zzz_denoise (clip src, float "sigma", int "thr", bool "mask", int "sad")
{
	sigma = Default (sigma,    16)
	thr   = Default (thr,       5)
	mask  = Default (mask,  False)
	sad   = Default (sad,     200)

	w = src.Width ()
	h = src.Height ()

	# Motion analysis
	super   = MSuper (src)
	super_a = MSuper (src.TTempSmooth ().RemoveGrain (12))

	fwd_vect_3 = super_a.MAnalyse (isb=false, delta=3, overlap=4)
	fwd_vect_2 = super_a.MAnalyse (isb=false, delta=2, overlap=4)
	fwd_vect_1 = super_a.MAnalyse (isb=false, delta=1, overlap=4)
	bck_vect_1 = super_a.MAnalyse (isb=true,  delta=1, overlap=4)
	bck_vect_2 = super_a.MAnalyse (isb=true,  delta=2, overlap=4)
	bck_vect_3 = super_a.MAnalyse (isb=true,  delta=3, overlap=4)

	fwd_comp_2 = src.MCompensate (super, fwd_vect_2, thSAD=sad)
	fwd_comp_1 = src.MCompensate (super, fwd_vect_1, thSAD=sad)
	bck_comp_1 = src.MCompensate (super, bck_vect_1, thSAD=sad)
	bck_comp_2 = src.MCompensate (super, bck_vect_2, thSAD=sad)

	# Spatio-temporal denoising using modified dfttest
	c_dft = Interleave (fwd_comp_2, fwd_comp_1, src, bck_comp_1, bck_comp_2)
	c_dft = c_dft.dfttest (sigma=sigma, lsb=true)	# Double height
	c_dft = c_dft.SelectEvery (5, 2)

	# Temporal-only denoising using modified MDegrain
	c_deg = src.MDegrain3 (super, bck_vect_1, fwd_vect_1, bck_vect_2, fwd_vect_2, bck_vect_3, fwd_vect_3, thSAD=sad, lsb=true)	# Double height

	# Spatio-temporal denoising smoothes too much the details,
	# therefore we use pure temporal denoising on edges or detailed areas.
	edge_src = c_deg.Crop (0, 0, w, h)
	edge_mask = edge_src.mt_edge (mode="prewitt", thY1=thr, thY2=thr)
	edge_mask = edge_mask.mt_expand ()
	edge_mask = StackVertical (edge_mask, edge_mask)	# Double height
	c_hyb = mt_merge (c_dft, c_deg, edge_mask, luma=true, y=3, u=3, v=3)

	return (mask ? edge_mask.GreyScale () : c_hyb)
}