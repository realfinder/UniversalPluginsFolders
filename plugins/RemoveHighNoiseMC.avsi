function RemoveHighNoiseMC(clip clip,int "rdlimit", int "rgrain", int "denoise", float "csharp", bool "_grey")
{
  rdlimit = default(rdlimit,24)
  rgrain = default(rgrain,3)
  denoise = default(denoise,15)
  csharp = (rgrain>2) ? default(csharp,0.32) : default(csharp,0.28)
  _grey = default(_grey, false)
  _dgr = 0.7+rgrain*0.5
  global idx_c = idx_c + 1
  cbs = 8
  ccf = cbs*cbs/64
  cpn = (denoise>12) ? 50*ccf : 57*ccf
  bvec3 = clip.MVAnalyse(isb=false, blksize=cbs, delta=3, pel=2, sharp=0, truemotion=true, pnew=cpn, idx=idx_c)
  bvec2 = clip.MVAnalyse(isb=false, blksize=cbs, delta=2, pel=2, sharp=0, truemotion=true, pnew=cpn, idx=idx_c)
  bvec1 = clip.MVAnalyse(isb=false, blksize=cbs, delta=1, pel=2, sharp=0, truemotion=true, pnew=cpn, idx=idx_c)
  fvec1 = clip.MVAnalyse(isb=true, blksize=cbs, delta=1, pel=2, sharp=0, truemotion=true, pnew=cpn, idx=idx_c)
  fvec2 = clip.MVAnalyse(isb=true, blksize=cbs, delta=2, pel=2, sharp=0, truemotion=true, pnew=cpn, idx=idx_c)
  fvec3 = clip.MVAnalyse(isb=true, blksize=cbs, delta=3, pel=2, sharp=0, truemotion=true, pnew=cpn, idx=idx_c)
  backw1 = rdlimit>20 ? \
      clip.MVFlow(bvec1).Deblock(quant=22, aOffset=6, bOffset=6) : \
    clip.MVFlow(bvec1).Deblock(quant=16, aOffset=4, bOffset=4)
  forw1  = rdlimit>20 ? \
      clip.MVFlow(fvec1).Deblock(quant=22, aOffset=6, bOffset=6) : \
    clip.MVFlow(fvec1).Deblock(quant=16, aOffset=4, bOffset=4)
  clp = interleave(backw1, clip, forw1)
  clp = clp.RemoveDirt(rdlimit,rgrain,_grey)
  clp = clp.SelectEvery(3,1)
  dnc = clp.MVDenoise(bvec3, bvec2, bvec1, fvec1, fvec2, fvec3, thT=denoise, thSAD=160+12*denoise, thmv=40, thSCD1=255+4*denoise)
  vid_mo = dnc.VagueDenoiser(threshold=_dgr, chromaT=_dgr, nsteps=6, percent=75)
  vid_mo = rgrain==1 ? vid_mo.RemoveGrain(1) : vid_mo.RemoveGrain(5)
  dnc = dnc.ConditionalFilter(dnc, vid_mo, "(YDifferenceFromPrevious()+YDifferenceToNext())/AverageLuma()", "<", "0.3")
  return csharp==0 ? dnc : clp.SeeSaw(dnc, Sstr=csharp, Szp=12, SdampHi=20, bias=40)
}