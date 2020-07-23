function MDegrain2(clip clp, int "overlap", int "dct")
{
overlap=default(overlap,0) # overlap value (0 to 4 for blksize=8)
dct=default(dct,0) # use dct=1 for clip with light flicker

super = clp.MSuper()
backward_vec1 = super.MAnalyse(isb = true, delta = 1, overlap=overlap, dct=dct)
forward_vec1 = super.MAnalyse(isb = false, delta = 1, overlap=overlap, dct=dct)
backward_vec1 = super.MAnalyse(isb = true, delta = 2, overlap=overlap, dct=dct)
forward_vec1 = super.MAnalyse(isb = false, delta = 2, overlap=overlap, dct=dct)
NR = clp.MDegrain2(super, backward_vec1,forward_vec1,backward_vec2,forward_vec2,thSAD=400)
NR
return(last)
}
