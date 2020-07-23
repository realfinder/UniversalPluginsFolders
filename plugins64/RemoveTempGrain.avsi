function RemoveTempGrain(clip input, int _mode)
{
  rg = RemoveGrain(input, mode=_mode)
  return TemporalRepair(rg, input)
}

function RemoveDirt_HQ(clip input, int tlimit, int rgrain, bool "_grey")
{
  _dgr = 0.4+rgrain*0.25
  clensed = input.RemoveTempGrain(1).FluxSmoothST(tlimit,rgrain)
  restore = input.VagueDenoiser(threshold=_dgr, nsteps=6, chromaT=_dgr, percent=100).RemoveGrain(1)
  alt = restore
  return RestoreMotionBlocks(clensed, restore, neighbour=input, alternative=alt, pthreshold=3+2*rgrain, cthreshold=3+2*rgrain, gmthreshold=40, dist=1, dmode=1, debug=false, noise=tlimit+1, noisy=12, grey=false)
}

global idx_c = 4

function RemoveNoiseMC_HQ(clip,int "tlimit", int "rgrain", float "csharp")
{
  tlimit = default(tlimit,4)
  rgrain = default(rgrain,1)
  csharp = rgrain>1 ? default(csharp,0.14) : default(csharp,0.13)
  global idx_c = idx_c + 1
  cbs = 4
  ccf = cbs*cbs/64
  cpn = tlimit>6 ? 70*ccf : 75*ccf
  bvec1 = clip.MVAnalyse(isb=false, blksize=cbs, delta=1, pel=2, sharp=1, overlap=0, truemotion=true, pnew=cpn, idx=idx_c)
  fvec1 = clip.MVAnalyse(isb=true, blksize=cbs, delta=1, pel=2, sharp=1, overlap=0, truemotion=true, pnew=cpn, idx=idx_c)
  backw1 = clip.MVFlow(bvec1, idx=idx_c)
  forw1  = clip.MVFlow(fvec1, idx=idx_c)
  dnc = interleave(backw1,clip,forw1)
  dnc = dnc.RemoveDirt_HQ(tlimit,rgrain)
  dnc = dnc.SelectEvery(3,1)
  return csharp==0 ? dnc : \
    clip.SeeSaw(dnc, Sstr=csharp, Szp=12, SdampHi=20, bias=40)
}



function hqfilter(clip c)
{
  c=c.RemoveNoiseMC_HQ(tlimit=4,rgrain=1)
  c=c.LimitedSharpenFaster(Smode=4,strength=15,overshoot=1,wide=false,ss_x=1.3,ss_y=1.3)
  return c
}