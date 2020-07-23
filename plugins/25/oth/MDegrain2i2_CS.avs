function MDegrain2i2_CS(clip clp, int "overlap", int "dct")
{
overlap=default(overlap,0) # overlap value (0 to 4 for blksize=8)
dct=default(dct,0) # use dct=1 for clip with light flicker
fields=clp.SeparateFields() # separate by fields
super = fields.MSuper()
backward_vec2 = super.MAnalyse(isb = true, delta = 2, overlap=overlap, dct=dct)
forward_vec2 = super.MAnalyse(isb = false, delta = 2, overlap=overlap, dct=dct)
backward_vec4 = super.MAnalyse(isb = true, delta = 4, overlap=overlap, dct=dct)
forward_vec4 = super.MAnalyse(isb = false, delta = 4, overlap=overlap, dct=dct)
NR = fields.MDegrain2(super, backward_vec2,forward_vec2,backward_vec4,forward_vec4,thSAD=400)
s = NR.minblur(1,1)
allD = mt_makediff(fields,NR)
ssD = mt_makediff(s,s.removegrain(11,-1))
ssDD = ssD.repair(allD,1)
ssDD = ssDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?")
NR.mt_adddiff(ssDD,U=2,V=2)
Weave()
}
