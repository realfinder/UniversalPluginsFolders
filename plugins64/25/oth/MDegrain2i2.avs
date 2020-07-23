function MDegrain2i2(clip source, int "blksize", int "overlap", int "dct")
{
Vshift=2 # 2 lines per bobbed-field per tape generation (PAL); original=2; copy=4 etc
Hshift=0 # determine experimentally 
overlap=default(overlap,0) # overlap value (0 to 4 for blksize=8)
dct=default(dct,0) # use dct=1 for clip with light flicker

fields=source.SeparateFields() # separate by fields

#This line gets rid of vertical chroma halo
fixed_fields=MergeChroma(fields,crop(fields,Hshift,Vshift,0,0).addborders(0,0,Hshift,Vshift))

super = fixed_fields.MSuper(pel=2, sharp=1)
backward_vec2 = super.MAnalyse(isb = true, delta = 2, blksize=blksize, overlap=overlap, dct=dct)
forward_vec2 = super.MAnalyse(isb = false, delta = 2, blksize=blksize, overlap=overlap, dct=dct)
backward_vec4 = super.MAnalyse(isb = true, delta = 4, blksize=blksize, overlap=overlap, dct=dct)
forward_vec4 = super.MAnalyse(isb = false, delta = 4, blksize=blksize, overlap=overlap, dct=dct)

MDegrain2(fixed_fields,super, backward_vec2,forward_vec2,backward_vec4,forward_vec4,thSAD=320) 
unsharpmask(60,3,0) #not sure whether to put this before or after the weave.

Weave()
}