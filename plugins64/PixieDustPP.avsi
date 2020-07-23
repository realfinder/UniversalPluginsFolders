#  ================================
#  PixieDustPP  v0.1  (21 Oct 2005)
#  ================================
#
#  A wrapper & postprocessing function for PixieDust. The aim is to reduce the blocking artefacts that PixieDust may produce
#  on image areas it can't motion-compensate correctly.
#  Moreover, PixieDust has a tendency to make the overall output a tad too soft, caused by its spatial processing [SpaceDust].
#  Then, the additional Deblocking doesn't exactly help on that matter ... so there is also the possibility to apply some very 
#  slight sharpening, in order to compensate for this softening.
#
#  It's not the ultimate solution. But it helps very noticeably.
#
#  Required Plugins:  
#  - MaskTools   (at least v1.5.6,  v1.5.8 recommended)
#  - DGDecode    (a recent version containing the "Deblock()" h.264 deblocking routine)
#  - RemoveGrain (the pre-1.0 version!)
#
#
#  Fiddled together by Didée, for your pleasure.
#

function PixieDustPP(clip clp, int "limit", int "q", int "s", int "smode", int "smode2", int "fullDB", bool "reduce")
{
limit  = default( limit,  3 )   # limiter value for PixieDust
q      = default( q,     24 )   # quant to use for Deblocking (h.264 deblocking routine provided by recent DGDecode)
s      = default( s,      1 )   # subliminal sharpening to combat dulling due to PixieDust and Deblocking:
                                # 0->no sharpening  1-> before PixieDust  2-> after Deblocking  3->both
smode  = default( smode,  4 )   # RemoveGrain blurring mode to use for sharpening before PixieDust
smode2 = default( smode2,20 )   # same for 2nd sharpening
fullDB = default( fullDB,51 )   # 0 -> reduce only PixieDust's blocking  100 -> reduce Source & PixieDust blocking
reduce = default( reduce,false) # when true: at the very end, for every pixel reduce the achieved effect by 1
rg1str = (s==3) ? 0.333 : 0.5

SHRP1 = "x y - abs 2 "+string(limit/3.0)+" - < x y - abs 24 > ° x x y - abs 4 < x y - abs 11 > ° x 1 x y - x y - abs / * + x 2 x y - x y - abs / * + ? ?"
SHRP2 = "x y - abs 2 < x y - abs 24 > ° x x y - abs 4 < x y - abs 7 > ° x 1 x y - x y - abs / * + x 2 x y - x y - abs / * + ? ?"
REDUC = "x y - abs 2 < x x x y - abs 1 - x y - x y - abs / * - ?"
DBALT = "x 128 - y 128 - * 0 < x x 128 - "+string(fullDB)+" * 100 / 128 + ?"

clp2 = isyv12(clp) ? clp : clp.converttoyv12()
clp2

(s==1 || s==3) ? yv12lutxy(last,last.removegrain(smode,-1), yexpr=SHRP1,U=2,V=2) : last
(s==1 || s==3) ? mergeluma(removegrain(1,-1), rg1str) : last

converttoyuy2()

dusted         = pixiedust(limit).converttoyv12()
dustdiff       = yv12lutxy(clp2,dusted,"x y - 128 +","x y - 128 +","x y - 128 +",U=3,V=3)

deblocked      = dusted.deblock(q)
deblockdiff    = yv12lutxy(dusted,deblocked, "x y - 128 +", "x y - 128 +", "x y - 128 +", U=3,V=3)
deblockdiffnew = yv12lutxy(deblockdiff,dustdiff, DBALT, U=2,V=2)

yv12lutxy(dusted,deblockdiffnew, "x y 128 - -", "x y 128 - -", "x y 128 - -",U=3,V=3)

(s==2 || s==3)  ?  yv12lutxy(last, last.removegrain(smode2,-1), yexpr=SHRP2, U=2,V=2) : last
(s==2 || s==3)  ?  mergeluma(removegrain(1,-1), rg1str) : last

reduce ? yv12lutxy(clp,last, REDUC,"y","y", U=3,V=3) : last

isyv12(clp) ? last : isRGB(clp) ? last.converttoRGB() : last.converttoyuy2()

return( last )
}
