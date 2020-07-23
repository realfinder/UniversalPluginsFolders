# RemoveDirtMC by heini011 on 26 February 2006
# Suggested by johnmeyer on 09 June 2010
# Incorporated into Filmrestoration script by videoFred on 08 July 2010
# Fixed (vector direction) by nephilis on 01 August 2010
# Fixed (swapped parameters) by Emulgator to work with recent MVTools 2.5.10.1 on 20 September 2010
#
function RemoveDirtMC(clip clp, bool "_grey", int "limit")
{
  _grey = default(_grey, false)
  limit = default(limit, 6)
  i     = MSuper(clp, pel=2)
  bvec  = MAnalyse(i, isb=true,  blksize=8, delta=1, truemotion=true) # for a backward search isb should be "true" not "false"
  fvec  = MAnalyse(i, isb=false, blksize=8, delta=1, truemotion=true) # for a forward search isb should be "false" not "true"
  backw = MFlow(clp, i, bvec)
  forw  = MFlow(clp, i, fvec)
  clipa = interleave(backw, clp, forw)
  clipb = RemoveDirt_fix4mc(clipa, _grey, limit)
  clipc = SelectEvery(clipb, 3, 1)
  return clipc
}

function RemoveDirt_fix4mc(clip input, bool "_grey", int "repmode") 
{
  _grey     = default(_grey, false)
  repmode   = default(repmode, 16)
  clmode    = 17
  clensed   = Clense(input, grey=_grey, cache=4)
  sbegin    = ForwardClense(input, grey=_grey, cache=-1)
  send      = BackwardClense(input, grey=_grey, cache=-1)
  alt       = Repair(SCSelect(input, sbegin, send, clensed, debug=true), input, mode=repmode, modeU = _grey ? -1 : repmode) 
  restore   = Repair(clensed, input, mode=repmode, modeU = _grey ? -1 : repmode)
  corrected = RestoreMotionBlocks(clensed, restore, neighbour=input, alternative=alt, gmthreshold=70, dist=1, \
                                  dmode=2, debug=false, noise=10, noisy=12, grey=_grey)
  return RemoveGrain(corrected, mode=clmode, modeU = _grey ? -1 : clmode)
}	