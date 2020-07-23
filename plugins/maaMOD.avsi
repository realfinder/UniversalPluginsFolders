function maaMOD(clip input, int "mask") {
mask = input.mt_edge("sobel",7,7,5,5).mt_inflate()
aa_clip=input.Spline36Resize(width(input)*4,height(input)*4).TurnLeft().SangNom().TurnRight().SangNom().Spline36Resize(width(input),height(input)).MergeChroma(input) 
return mt_merge(input,aa_clip,mask) }