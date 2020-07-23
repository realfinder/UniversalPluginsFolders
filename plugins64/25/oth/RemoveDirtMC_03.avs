function RemoveDirt_03(clip input, int "limit", bool "_grey")
{
  clensed=input.Clense(grey=_grey, cache=4)
  alt=input.RemoveGrain(2)
  return RestoreMotionBlocks(clensed,input,alternative=alt,pthreshold=6,cthreshold=8, gmthreshold=40,dist=3,              dmode=2,debug=false,noise=limit,noisy=4, grey=_grey)

  # Alternative settings
  # return RestoreMotionBlocks(clensed,input,alternative=alt,pthreshold=4,cthreshold=6, gmthreshold=40,dist=1,dmode=2,debug=false,noise=limit,noisy=12,grey=_grey,show=true)
  # return RestoreMotionBlocks(clensed,input,alternative=alt,pthreshold=6,cthreshold=8, gmthreshold=40,dist=3,tolerance= 12,dmode=2,debug=false,noise=limit,noisy=12,grey=_grey,show=false)
}

function RemoveDirtMC_03(clip clip,int "limit", bool "_grey")
{
  _grey=default(_grey, false)
  limit = default(limit,6)
  i=MSuper(clip,pel=2)
  bvec = MAnalyse(i,isb=false, blksize=8, delta=1, truemotion=true)
  fvec = MAnalyse(i,isb=true, blksize=8, delta=1, truemotion=true)
  backw = MFlow(clip,i,bvec)
  forw  = MFlow(clip,i,fvec)
  clp=interleave(backw,clip,forw)
  clp=clp.RemoveDirt_03(limit,_grey)
  clp=clp.SelectEvery(3,1)
  return clp
}