function lq_filter(clip c) {
  c=c.RemoveNoiseMC(rdlimit=18,rgrain=3,denoise=14)
  c=c.VagueDenoiser(threshold=0.6, nsteps=6, chromaT=0.6, percent=75)
  c=c.deen("a3d",rad=3,thrY=3,thrUV=5,min=0.25,tthY=2,tthUV=3,scd=6)
  c=c.LimitedSharpenFaster(Smode=4,strength=24,overshoot=1,wide=false,ss_x=1.3,ss_y=1.3)
  return c
}