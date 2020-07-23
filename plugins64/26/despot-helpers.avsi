Function DeSpot_analyse_mc (clip c, string "outfile", int "pel", int "blksize", string "addparam")
{
	pel      = Default (pel,              4)
	blksize  = Default (blksize,         32)
	addparam = Default (addparam,        "")

	c
	s     = MSuper (pel=pel)
	bvec  = MAnalyse (s, isb=false, blksize=blksize, overlap=8, delta=1)
	fvec  = MAnalyse (s, isb=true, blksize=blksize, overlap=8, delta=1)
	backw = MCompensate (s, bvec)
	forw  = MCompensate (s, fvec)
	Interleave (backw, last, forw)
	Eval ("DeSpot (outfile=outfile, mc=true" + addparam + ")")
	SelectEvery (3, 1)
}
