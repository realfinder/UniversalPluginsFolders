
#MAA2 v0.4
#=========

#Updated version of the MAA antialising script from AnimeIVTC. 
#MAA2 uses tp7's SangNom2 and FTurn, which provide a nice speedup for SangNom-based antialiasing,
#especially when only processing the luma plane.
#The defaults of MAA2 match up with MAA, so you'll get identical output (save for the more accurate border region processing of SangNom2)
#when using this script as a drop-in replacement.

#MAA2 supports Y8, YV12 and YV24 input.

#Requirements:

#   * AviSynth 2.5 or 2.6
#   * SangNom2 0.3+
#   * FTurn
#   * Masktools 2.0a48
    
       


function maa2(clip input, int "mask") {
mask = input.mt_edge("sobel",7,7,5,5).mt_inflate()
aa_clip=input.Spline36Resize(width(input)*4,height(input)*4).fTurnLeft().SangNom2().fTurnRight().SangNom2().Spline36Resize(width(input),height(input)).MergeChroma(input) 
return mt_merge(input,aa_clip,mask) }