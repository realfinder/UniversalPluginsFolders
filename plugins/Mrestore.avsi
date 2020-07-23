function mrestore(clip clp, int "numr", int "denm", int "mode", float "bf", bool "chroma", int "dup", int "cache", float "rx", float "ry", int "mthr", clip "dclip")
{
###### parameters ######
	rx	= 0.0625 / (isfloat(rx) ? (rx<0.5 ? 0.01 : rx) : 3.0)									#x detection reduction
	ry	= 0.0416 / (isfloat(ry) ? (ry<0.5 ? 0.01 : ry) : 3.0)									#y detection reduction
	
	cache	= default(cache,5)																	#caching for non-linear request
	
global	num	= isint(numr) ? float(numr) : round(framerate(clp)*100)%2997==0 ? 1001.0 : 480.0						#numerator
global	deno	= isint(denm) ? float(denm) : round(framerate(clp)*100)%2997==0 ? 2400.0 : 1001.0					#denominator
global	rf	= isint(mode) ? round(pow(2,abs(mode))) : 8											#reduction factor
global	bf	= default(bf,0.6)																	#blend factor
global	mmin	= isint(mthr) ? abs(mthr)<9 ? 7+mthr/2 : 7 : 7
global	mmax	= isint(mthr) ? abs(mthr)<9 ? 26+mthr : 26 : 26
global	dup	= default(dup,0)


###### further preparation ######
global	det	= default(dclip,clp).KillAudio().ConvertToYV12()									#detection clip
global	dwidth	= rx>2 ? 256 : round(width(det)*rx)*16											#detection clip width
global	dheight	= ry>2 ? 160 : round(height(det)*ry)*16											#detection clip height


###### source preparation ######
global	det	= det.bilinearresize(dwidth,dheight) 
global	det	= default(chroma,false)==false ? det : stackvertical(stackhorizontal(det.UtoY(),det.VtoY()),det)			#detection clip

global	out 	= clp																			#output clip


###### lut & more ######
        code	= "x 128 - abs y 128 - abs < x 128 - abs x y + 256 - abs < & x 128 - abs x 128 - abs 0.3 ^ - 2 ^ y 128 - abs x y + 256 - abs < " +
		\ "y 128 - abs y 128 - abs 0.3 ^ - 2 ^ x y + 256 - abs x y + 256 - abs 0.3 ^ - 2 ^ ? ? x 128 - y 128 - * 0 > -3 3 ? * 128 +"
		diff 	= mt_makediff(det, det.trim(1,0), y=3, u=1, v=1)
global	bclp	= rf>24 ? nop() : mt_lutxy(diff, diff.trim(1,0), expr=code)						#blend clip
global	bclpr	= rf!=8 ? nop() : bclp.bilinearresize(dwidth/8>16 ? dwidth/32*4 : 16, dheight/8>8 ? dheight/32*4 : 8)					#blend clip reduced
global	dclp	= diff.trim(2,0).mt_lut("x 128 - abs 1.15 ^ 1.5 -")								#differencing clip
global	mclp	= mt_makediff(det.trim(2,0),det.trim(4,0)).mt_lut("x 128 - abs 0.8 ^ 1.6 - 8 *").bilinearresize(dwidth/4, dheight/4)	#motion clip


###### initialise variables ######
global	lfo	= 0-deno/num														#last frame output
global	gfo	= 0

global	bp2	= 0																	#blend value
global	bp2h	= 0																#blend value high
global	bp1	= bp2
global	bp1h	= bp2h
global	bn0	= bp2
global	bn0h	= bp2h
global	bn1	= bp2
global	bn1h	= bp2h
global	bn2	= bp2
global	bn2h	= bp2h

global	c32	= 0.001															#comb difference
global	c21	= c32
global	c10	= c32
global	c01	= c32
global	c12	= c32
global	c23	= c32

global	m31	= mmax															#motion difference
global	m20	= m31
global	m11	= m31
global	m02	= m31
global	m13	= m31
global	m24	= m31

global	dupp2	= 2*mmax														#duplicate value
global	dupp1	= dupp2
global	dupn0	= dupp2
global	dupn1	= dupp2
global	dupn2	= dupp2
global	dupn3	= dupn2


###### function for output calculation ######
function ocalc()
{
## preparation ##
rp1	= (c21/(c21+c10)-0.5) * 0.8
rn0	= (c10/(c10+c01)-0.5) * 0.8
rn1	= (c01/(c01+c12)-0.5) * 0.8
rn2	= (c12/(c12+c23)-0.5) * 0.8

## frame output - decimation calculation ##
rfo	= lfo+deno/num

cfo	= rfo<-0.5 ? (rp1<-rn0 && abs(rfo+1+rn0)<abs(rfo+1-rp1) ? -rn0 : rp1) - 1 :
	\ rfo>=1.5 ? (-rn1<rn2 && abs(rfo-2+rn1)<abs(rfo-2-rn2) ? -rn1 : rn2) + 2 :
	\ round(rfo)==0 ? ( rfo>-0.12 && rfo<0.08 && rfo*rn0<=0 ? (rfo+rn0)*0.5 :
	\   (rfo+(rfo<0 ? rp1 : rn1))*(rn0-rfo)>=0 ? rfo : abs(rfo+(rfo<0 ? rp1 : rn1))<abs(rfo-rn0) ? (rfo<0 ? -rp1 : -rn1) : rn0 ) :
	\ round(rfo)==1 ? ( rfo>0.92 && rfo<1.12 && (rfo-1)*rn1<=0 ? ((rfo-1)+rn1)*0.5 : (rfo-1+(rfo>1 ? rn2 : rn0))*(rn1-rfo+1)>=0 ?
	\   rfo-1 : abs(rfo-1+(rfo>1 ? rn2 : rn0))<abs(rfo-1-rn1) ? (rfo>1 ? -rn2 : -rn0) : rn1 ) + 1 : rfo

wro	= float( cfo<-0.5 ? (m20<mmin ? 0 : m20>mmax ? mmax-mmin : m20-mmin) : cfo>=1.5 ? (m13<mmin ? 0 : m13>mmax ? mmax-mmin : m13-mmin) :
	\ round(cfo)==0 ? (m11<mmin ? 0 : m11>mmax ? mmax-mmin : m11-mmin) : (m02<mmin ? 0 : m02>mmax ? mmax-mmin : m02-mmin) ) / float(mmax-mmin) *
	\ (0.5+pow(abs(cfo-round(cfo)),0.5)/1.42)

cfo	= cfo * wro + rfo * (1-wro)
cfo	= cfo<=-1 ? -0.99 : cfo>=2 ? 1.99 : lfo>=0.5 && cfo<rfo ? rfo : cfo<1.05 && lfo>=-0.5 ? (rfo<1 ? rfo : 1.05) : cfo<0.05 && lfo>=-1.5 ? (rfo<0 ? rfo : 0.05) : cfo
cfo = cfo<=-0.99 ? -0.99 : cfo>=1.99 ? 1.99 : cfo

bcalc	= dup>=0 && select(round(cfo+1),dupp1,dupn0,dupn1,dupn2)<mmax*0.7 ? 10 : abs(deno/num-2.01)>0.21 ? cfo :
	\ select(int(cfo*2.+2),m20+m02,m31+m11,m11+m13,m20+m02,m02+m24,m11+m13) >= select(round(cfo+1),m31+m11,m20+m02,m11+m13,m02+m24) + mmin &&
	\ abs(select(int(cfo*2.+2),m20/m02,m31/m11,m11/m13,m20/m02,m02/m24,m11/m13)-1.04) < 0.29  ? 2*int(cfo)-cfo+1 : cfo

## blend calculation ##
bcalc	= bcalc==10 ? round(cfo) : rf>24 ? round(bcalc) :
	\ rf>6 ? ( lfo<0.5 && bcalc>1 ? ((bn1-bn0)*(bn1-bn2)>0 || (bn1-bn2)*(bn1h-bn2h)>0 || bcalc>1.4 && bn2h-bn1h==0 ? (bcalc+bn2-bn1<1.5 ? 1 : 2) :
	\     (bn1h-bn0h)*(bn1h-bn2h)>0 ? (bcalc+bn2h-bn1h<1.5 ? 1 : 2) : round(bcalc)) :
	\   lfo<-0.5 && abs(0.5-bcalc)<=0.5 ? ((bn0-bp1)*(bn0-bn1)>0 || (bn1-bn0)*(bn1-bn2)>0 || (bn1-bn0)*(bn1h-bn0h)>0 ? (bcalc+bn1-bn0<0.5 ? 0 : 1) :
	\     (bn0h-bp1h)*(bn0h-bn1h)>0 || (bn1h-bn0h)*(bn1h-bn2h)>0 ? (bcalc+bn1h-bn0h<0.5 ? 0 : 1) : round(bcalc)) :
	\   lfo<-1.5 && bcalc<0 ? ((bp1-bp2)*(bp1-bn0)>0 || (bn0-bp1)*(bn0-bn1)>0 || (bn0-bp1)*(bn0h-bp1h)>0 ? (bcalc+bn0-bp1<-0.5 ? -1 : 0) :
	\     (bp1h-bp2h)*(bp1h-bn0h)>0 || (bn0h-bp1h)*(bn0h-bn1h)>0 ? (bcalc+bn0h-bp1h<-0.5 ? -1 : 0) : round(bcalc)) : round(bcalc) ) :
	\ lfo<-0.5 && abs(0.5-bcalc)<=0.5 && ((bn0h-bn1)*(bn0-bp1h)>=0 || (bn1-bn0h)*(bn1h-bn2)>=0 || abs(0.5-bcalc)<0.15 || bn0h*bn1>0.1) ? (bcalc+bn1-bn0h<0.5 ? 0 : 1) :
	\   lfo<-1.5 && bcalc<0 && ((bn0h-bn1)*(bn0-bp1h)>=0 || (bp1h-bn0)*(bp1-bp2h)>=0 || abs(bcalc+0.525)<0.15 || bp1h*bn0>0.1) ? (bcalc+bn0-bp1h<-0.5 ? -1 : 0) :
	\   lfo<0.5 && bcalc>1 && ((bn1-bn0h)*(bn1h-bn2)>=0 || bcalc>1.35 || bn2*bn1h>0.1) ? (bcalc+bn2-bn1h<1.5 ? 1 : 2) : round(bcalc)

## final output calculation - resync - frame weight ##
bcalc	= bcalc==1 && cfo>1.5 && lfo>=-0.5 && rn0>0.25 && rn1<-0.25 && (dup<0 || m11>mmax && m02>mmax && dupp1>mmax) ? 2 : dup<0 ? bcalc :
	\ bcalc>=0 && bcalc>=round(cfo) && (m31<mmax || m24<mmax) && m20<mmax && m11<mmax && m02<mmax && m13<mmax &&
	\ select(bcalc,m20<mmax*0.7 && m20<m11, m11<mmax*0.7 && m11<m02, m02<mmax*0.7 && m02<m13) ? bcalc-1 :
	\ deno/num>2 && deno/num<2.3 && bcalc<=0 ? (m31>2*mmax && m20>2*mmax && m11<mmax && m02<mmax && m20/mmax-1>m11/mmin && m20/mmax-1>m02/mmin ? 0 :
	\ bcalc==0 && cfo>=-0.5 && m20>2*mmax && m11>2*mmax && m02<mmax && m13<mmax && m20/mmax-1>m31/mmin && m11/mmax-1>m02*mmax && m11/mmax-1>m13/mmin ? 1 : bcalc) :
	\ deno/num<2 && deno/num>1.7 ? (bcalc==2 && m13>2*mmax && m02<mmax && m11<mmax && m13/mmax-1>m02/mmin && m13/mmax-1>m11/mmin ? 1 :
	\ bcalc==1 && cfo<1.5 && m13>2*mmax && m02>2*mmax && m11<mmax && m20<mmax && m01/mmax-1>m11/mmin && m01/mmax-1>m20/mmin ? 0 : bcalc) : bcalc

cfo	= bcalc==round(cfo) ? cfo : ( bcalc==2 && cfo<1.5 && (rn1>0 || rn2<0) ? (rn2<-rn1 ? rn2 : -rn1) :
	\ bcalc==-1 && cfo>=-0.5 && (rp1>0 || rn0<0) ? (rp1>-rn0 || rp1>0.2 ? rp1 : (rn0>-0.2 ? -rn0 : 0.2)) :
	\ bcalc==0 && cfo<-0.5 && (rp1>0 || rn0<0) ? (rn0<0 ? rn0 : (rp1<0.2 ? -rp1 : -0.2)) :
	\ bcalc==0 && cfo>=0.5 && (rn0>0 || rn1<0) ? (rn0>0 ? rn0 : (rn1>-0.2 ? -rn1 : 0.2)) :
	\ bcalc==1 && cfo<0.5 && (rn0>0 || rn1<0) ? (rn1<0 ? rn1 : (rn0<0.2 ? -rn0 : -0.2)) :
	\ bcalc==1 && cfo>=1.5 && (rn1>0 || rn2<0) ? (rn1>0 ? rn1 : (rn2>-0.2 ? -rn2 : 0.2)) : 0 ) + bcalc
	
return cfo
}


###### final evaluation ######
ScriptClip(clp, " gfo<=-2 ? out.duplicateframe(0).duplicateframe(0) : gfo==-1 ? out.duplicateframe(0) : out.trim(gfo,0) ")

FrameEvaluate(last, "

  ## preparation ##
		cifr	= current_frame % round(deno)
		bfo		= cifr==round(round(cifr*num/deno)*deno/num) ? 1 : 0

  ## blend calculation ##
  	bpos		= rf>6 ? 0 : int(bclp.CFrameDiff(prevf=false, nt=0, blockx=16/rf, blocky=16/rf, rpos=true))
  
 	global	bp2		= bp1
	global	bp2h	= bp1h
	global	bp1		= bn0
	global	bp1h	= bn0h
	global	bn0		= bn1
	global	bn0h	= bn1h
	global	bn1		= bn2
	global	bn1h	= rf>6 ? bn2h : (AverageLuma(bclp.crop(bpos%dwidth/2*2+16/rf<dwidth ? bpos%dwidth/2*2 : dwidth-16/rf ,bpos/dwidth/2*2+16/rf<dheight ? bpos/dwidth/2*2 : dheight-16/rf,16/rf,16/rf).addborders(0,0,16-16/rf,0))*rf-128)*0.25*bf
	global	bn2		= rf>24 ? 0 : ( rf>6 ? (AverageLuma(bclp.trim(1,0))-128) :
					\ (AverageLuma(bclp.crop(bpos%dwidth/2*2+16/rf<dwidth ? bpos%dwidth/2*2 : dwidth-16/rf ,bpos/dwidth/2*2+16/rf<dheight ? bpos/dwidth/2*2 : dheight-16/rf,16/rf,16/rf).trim(1,0).addborders(0,0,16-16/rf,0))*rf-128)*0.25 ) * bf
	global	bn2h	= rf==8 ? (YPlaneMin(bclpr.trim(1,0))-128)*0.16*bf : 0

  ## value calculating & shifting ##
 	global	c32	= c21
	global	c21	= c10
	global	c10	= c01
	global	c01	= c12
	global	c12	= c23
	global	c23	= AverageLuma(dclp) + 0.001

	global	m31	= m20
	global	m20	= m11
	global	m11	= m02
	global	m02	= m13
	global	m13	= m24
	global	m24	= YPlaneMax(mclp) + 0.001
	
  ## duplicate detection ##
	global	dupp2	= dupp1
	global	dupp1	= dupn0>mmax && m20<mmax && m20/mmin+1.0<m24/mmax ? m20 : dupn0
	global	dupn0	= dupn1>mmax && m11<mmax && m11/mmin+0.8<m24/mmax ? m11 : dupn1
	global	dupn1	= dupn2>mmax && m02<mmax && m02/mmin+0.6<m24/mmax ? m02 : dupn2
	global	dupn2	= dupn3>mmax && m13<mmax && m13/mmin+0.5<m24/mmax ? m13 : dupn3
	global	dupn3	= m24<mmax && (m24<mmin || m24/mmin+0.5<m13/mmax || m24/mmin+0.6<m02/mmax || m24/mmin+0.8<m11/mmax || m24/mmin+1<m20/mmax) ? m24 : 2*mmax

  ## output calculation ##
     	global	lfo	= lfo-1
        global	lfo	= bfo==0 ? lfo : ocalc()
        
        global	gfo	= dup<=0 || bfo==0 ? round(lfo) : dupn3<mmax && lfo>=1.5 && dupn3<dupn2 && dupn3<dupn1 ? 3 :
			\ dupn2<mmax && round(lfo)==1 && dupn2<dupn1 && dupn2<=dupn0 ? 2 :
			\ dupn1<mmax && (lfo>=1.5 && dupn1<dupn2 || round(lfo)==0 && dupn1<dupn0 && dupn1<=dupp1) ? 1 :
        		\ dupn0<mmax && (lfo<-0.5 && dupn0<dupp1 && dupn0<=dupp2 || round(lfo)==1 && dupn0<dupn1) ? 0 :
	  		\ dupp1<mmax && round(lfo)==0 && dupp1<dupn0 ? -1 :
	  		\ dupp2<mmax && lfo<-0.5 && dupp2<dupp1 ? -2 : round(lfo)

		")
		
cache<0 ? last : last.RequestLinear(8, cache, 5, false, false)

return last.changefps(round(frameratenumerator(last)*num),round(frameratedenominator(last)*deno),linear=true)
}