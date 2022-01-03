function BlockTerminator(clip c, int "ss", float "noise", int "dest_x", int "dest_y", int "cx", int "cy", int "cw", int "ch", bool "gpu", bool "deblock", bool "edi", bool "sharp", bool "npp", bool "fast") {
  dest_x=default(dest_x,c.width)  # final size
  dest_y=default(dest_y,c.height)
  ss=sqrt(default(ss,1.5))  # supersampling
  noise=default(noise,2)  # extra noise
  cx=default(cx,0)  # cropping params
  cy=default(cy,0)
  cw=default(cw,0)
  ch=default(ch,0)
	fast=default(fast,false)
  gpu=default(gpu,false)
  deblock=default(deblock,true)
  edi=default(edi,fast ? false : true)
  npp=default(npp,false)
  sharp=default(sharp,true)
  c
  deblock ? DeBlock(quant=45) : last
  crop(cx,cy,cw,ch,align=true)
  Spline16Resize(m(16,width*ss),m(16,height*ss))
  edi ? EEDI2().TurnRight().EEDI2().TurnLeft() : last
  fast ? removegrain(mode=1) : frfun7(lambda=2,t=8,tuv=10) # gpu ? FFT3DGPU(sigma=2,bt=3,sharpen=0.7,precision=2) : FFT3DFilter(sigma=2,bt=3,sharpen=0.7)
  sharp ? (fast ? sharpen(.7) : LimitedSharpenFaster(SMode=3,LMode=3,Strength=400,undershoot=2,wide=true,soft=5,ss_y=1,ss_x=1)) : last
  LanczosResize(dest_x,dest_y)
  noise > 0.0 ? AddGrain(noise,0,0) : last
  npp ? removegrain(mode=5) : last
}

function m(int r, float x) {return(x<16?16:int(round(x/float(r))*r))}