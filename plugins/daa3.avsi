    #Anti-aliasing with contra-sharpening by Didée
    FUNCTION daa3(clip c) {
    nn      = c.nnedi3(field=-2)
    dbl     = mt_average(selecteven(nn),selectodd(nn),U=3,V=3)
    dblD    = mt_makediff(c,dbl,U=3,V=3)
    shrpD   = mt_makediff(dbl,dbl.removegrain((width(c)>1100) ? 20 : 11),U=3,V=3)
    DD      = shrpD.repair(dblD,13)
    return dbl.mt_adddiff(DD,U=3,V=3) }
