# v1.0 : - first release
# v1.1 : - added PreFilter, Mask and Denoiser
# v1.2 : - added Pre_Clip function for better search of motion vectors

# Needed Plugins: MaskTools2, MvTools2, MedianBlur2, RemoveDirt, RgTools, DeSpot

Function SpotRemover(clip c, int "Spot", bool "DeGrain", int "RadT", int "ThSAD", int "ThSAD2", int "Pel", bool "Chroma",
                    \ int "BlkSz", Int "Olap", bool "Tm", bool "Glob", bool "PreFilter", bool "Mask", string "Denoiser") {
Spot      = Default(Spot, 32)       # Spot size
DeGrain   = Default(DeGrain, false) # MDeGrain in MvTools
RadT      = Default(RadT, 1)        # Temporal radius. (MCompensate arg)
ThSAD     = Default(ThSAD, 1000)    # SAD threshold at radius 1 (Default Nearly OFF).
ThSAD2    = Default(ThSAD2, 130)    # SAD threshold at radius RadT.
Pel       = Default(pel, 1)         # Default 2. 1, 2, or 4. Maybe set 1 for HD+. (1=precision to pixel, 2=precision to half pixel, 4=quarter pixel)
Chroma    = Default(chroma, true)   # MAnalyse chroma arg. If set to true, use chroma in block matching.
BlkSz     = Default(BlkSz, 8)       # Default 8. MAnalyse BlkSize. Bigger blksz quicker and perhaps  better, esp for HD clips. Maybe also better where BIG noise.
OLap      = Default(OLap, 2)        # Default half of BlkSz.
Tm        = Default(tm, true)       # TrueMotion, Some folk swear MAnalyse(truemotion=false) is better.
Glob      = Default(glob, true)     # Default True, Allow set MAnalyse(global) independently of TrueMotion.
PreFilter = Default(PreFilter, true)
Mask      = Default(Mask, false)
Denoiser  = Default(Denoiser, Undefined)

pad = Max(BlkSz, 8)

sup      = c.Pre_ClipSpotRemover(blur=1.0, contrast=0, brightness=0).RemoveGrain(mode=17).MSuper(hpad=pad, vpad=pad, pel=pel, sharp=2, chroma=Chroma)
sup_rend = MSuper(c, hpad=pad, vpad=pad, pel=pel, sharp=2, levels=1, chroma=Chroma) # Only 1 Level required where not MAnalyse-ing.

c1 = PreFilter ? Eval("""
    MultiVec = MAnalyse(sup, multi=true, delta=RadT, blksize=BlkSz*2, overlap=OLap*2, search=5, dct=0, chroma=Chroma, truemotion=Tm, global=Glob)
    # MultiVec = Mrecalculate(sup, MultiVec, tr=RadT, blksize=4, overlap=2, search=5, dct=7, thSAD=150, chroma=Chroma)  # bed vectors recalculate
    c0 = MCompensate(c, sup_rend, MultiVec, tr=RadT, thSad=ThSAD, thSad2=ThSAD2)
    c0 = RadT == 1 ? Clense(c0) : MedianBlurTemporal(c0, radiusY=0, radiusU=0, radiusV=0, temporalradius=RadT)
    c0 = SelectEvery(c0, RadT*2+1, RadT) # Return middle frame
    return Repair(c0, c.RemoveDustSpotRemover().Sharpen(0.1), mode=17)
""") : c

bvec1  = MAnalyse(sup, isb=true,  blksize=BlkSz, overlap=OLap, divide=0, delta=1, search=5, dct=7, plevel=0,
                \ chroma=Chroma, truemotion=Tm, global=Glob) # backward vectors
fvec1  = MAnalyse(sup, isb=false, blksize=BlkSz, overlap=OLap, divide=0, delta=1, search=5, dct=7, plevel=0,
                \ chroma=Chroma, truemotion=Tm, global=Glob) # forward vectors
# bed vectors recalculate
# bvec1 = Mrecalculate(sup, bvec1, blksize=4, overlap=2, search=5, dct=7, thSAD=150, chroma=Chroma)
# fvec1 = Mrecalculate(sup, fvec1, blksize=4, overlap=2, search=5, dct=7, thSAD=150, chroma=Chroma)
backw1 = MFlow(c1, sup_rend, bvec1)
forw1  = MFlow(c1, sup_rend, fvec1)

c2 = Defined(Denoiser) ? Interleave(backw1, c1, forw1).Eval(Denoiser) : Interleave(backw1, c1, forw1)

msk = Mask ? Eval("""
    sadb = MMask(c, bvec1, ml=50, kind=1, gamma=1, thscd1=ThSAD)#.mt_binarize(15, upper=true) # mask SAD backward
    sadf = MMask(c, fvec1, ml=50, kind=1, gamma=1, thscd1=ThSAD)#.mt_binarize(15, upper=true) # mask SAD forward
    msad = mt_logic(sadf, sadb, "and", chroma="-128")#.mt_expand() # combined mask SAD
    return Interleave(msad, msad, msad)
""") : Undefined

filtered = c2.DeSpot(p1=6, p2=6, pwidth=Spot, pheight=Spot, mthres=16, mwidth=Spot/2, mheight=Spot/2,
                   \ blur=1, motpn=true, seg=2, color=true, ranked=true, show=0, extmask=msk)

restore = c2.RemoveDustSpotRemover().Sharpen(0.1)

c3 = RestoreMotionBlocks(filtered, restore, alternative=restore, pthreshold=10, cthreshold=10, gmthreshold=160,
                       \ dist=3, dmode=2, noise=3, noisy=9, grey=false, debug=false, show=false)

SelectEvery(c3, 3, 1)

DeGrain ? MDeGrain1(last, sup_rend, bvec1, fvec1, plane=4, limit=255.0, thSad=400) : last
}



function RemoveDustSpotRemover(clip input, int "mode") {
mode = Default(mode, 17)

clensed = Clense(input)
rep = Repair(clensed, input, mode=mode)

RemoveGrain(rep, mode=10)
}

function Pre_ClipSpotRemover(clip clp, float "blur", float "contrast", float "brightness"){
blur       = Default(blur, 1.0)
contrast   = Default(contrast, 1.2)
brightness = Default(brightness, 10.0)

v = clp.mt_lut(expr="x 20 1 x 127.5 / - 21 ^ pi x * 255 / cos 21 ^ - * 1.05 * -", Y=3, U=2, V=2, scale_inputs="allf", use_expr=2)

mask_1 = clp.Tweak(sat=0).Blur(blur).mt_edge(mode="min/max", thY1=0, thY2=255, Y=3, U=2, V=2)

pre_1 = v.Tweak(cont=contrast, bright=brightness)
pre_2 = mt_merge(v, pre_1, mask_1, Y=3, U=2, V=2)
pre_3 = pre_2.Tweak(sat=0).mt_invert().Blur(1.58).Blur(1.58).Blur(1.58)
pre_4 = mt_lutxy(pre_2, pre_3, expr="x 127.5 > y 255 x - 127.5 / * x 255 x - - + y x 127.5 / * ? ", Y=3, U=2, V=2, scale_inputs="allf", use_expr=2)

# s = clp.vsTCanny().mt_binarize(threshold=0, chroma="-128")
# Overlay(pre_4, s, mask=s, opacity=0.5)

return pre_4
}