function RemoveNoiseMC(clip,int "rdlimit", int "rgrain", int "denoise", bool "sharp", float "csharpen", bool "_grey")
{
  rdlimit = default(rdlimit,11)
  rgrain = default(rgrain,2)
  denoise = default(denoise,8)
  sharp = (rgrain<1) ? default(sharp,true) : default(sharp,false)
  csharpen = (rgrain>2) ? default(csharpen,0.17) : (rgrain>1) ? default(csharpen,0.15) : default(csharpen,0.13)
  csharpen = sharp ? csharpen : csharpen+0.08
  _grey = default(_grey,false)
  _dgr = 0.45+rgrain*0.4
  dummy = clip.BlankClip(length=0)
  global idx_c = idx_c+1
  cbs = 8
  cov = (cbs>4) ? cbs/4 : 0
  ccf = cbs*cbs/64
  cpn = (denoise>12) ? 50*ccf : (denoise>8) ? 58*ccf : (denoise>5) ? 66*ccf : 72*ccf
  csh = sharp ? 1 : 0
  bvec2 = clip.MVAnalyse(isb=false, blksize=cbs, delta=2, pel=2, sharp=csh, overlap=cov, truemotion=true, pnew=cpn, idx=idx_c)
  bvec1 = clip.MVAnalyse(isb=false, blksize=cbs, delta=1, pel=2, sharp=csh, overlap=cov, truemotion=true, pnew=cpn, idx=idx_c)
  fvec1 = clip.MVAnalyse(isb=true, blksize=cbs, delta=1, pel=2, sharp=csh, overlap=cov, truemotion=true, pnew=cpn, idx=idx_c)
  fvec2 = clip.MVAnalyse(isb=true, blksize=cbs, delta=2, pel=2, sharp=csh, overlap=cov, truemotion=true, pnew=cpn, idx=idx_c)
  backw1 = rdlimit>13 ? \
    rdlimit>20 ? \
      clip.MVFlow(bvec1, idx=idx_c).Deblock(quant=22, aOffset=6, bOffset=6) : \
      clip.MVFlow(bvec1, idx=idx_c).Deblock(quant=16, aOffset=4, bOffset=4) : \
    clip.MVFlow(bvec1, idx=idx_c)
  forw1  = rdlimit>13 ? \
    rdlimit>20 ? \
      clip.MVFlow(fvec1, idx=idx_c).Deblock(quant=22, aOffset=6, bOffset=6) : \
      clip.MVFlow(fvec1, idx=idx_c).Deblock(quant=16, aOffset=4, bOffset=4) : \
    clip.MVFlow(fvec1, idx=idx_c)
  clp = interleave(backw1,clip,forw1)
  clp = clp.RemoveDirt(_grey,rgrain)
  dnc = denoise==0 ? clp.RemoveTempGrain(rgrain).SelectEvery(3,1) : dummy
  clp = clp.SelectEvery(3,1)
  dnc = denoise==0 ? dnc : \
    clp.MVDenoise(bvec2, bvec1, fvec1, fvec2, thT=denoise, thSAD=190+15*denoise, thmv=40, thSCD1=230+5*denoise)
  vid_mo = dnc.VagueDenoiser(threshold=_dgr, chromaT=_dgr, nsteps=7, percent=75)
  vid_mo = rgrain==1 ? vid_mo.RemoveGrain(1) : vid_mo.RemoveGrain(5)
  dnc = dnc.ConditionalFilter(dnc, vid_mo, "(YDifferenceFromPrevious()+YDifferenceToNext())/AverageLuma()", "<", "0.3")
  clp = clp.SeeSaw(dnc, Sstr=csharpen, Szp=12, SdampHi=20, bias=40)
  return clp
}