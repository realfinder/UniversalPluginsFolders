############################
## Cdeblend  by MOmonster ##
############################


## Cdeblend is a simple blend replacing function like unblend or removeblend
##
## Use import("Cdeblend.avs") in your script and load the necessary filters to be able using this function
##
## required filters:
##		- mt_masktools
##		- for fnr=true: removegrain
## version:
##		- v1.1b  - 19.12.2006


## sample1:	progressive (bobbed) source
##		Cdeblend()
##
## sample2:	tdeint(mode=1)
##		c = last.crop(8,16,-8,-8)
##		Cdeblend(omode=1,dlip=c)


## parameter description:
##	omode
##		Stands for the output mode. There are five different omodes:
##		omode 0 ->	The previous frame will be duplicated to avoid a blend. ->default
##		omode 1 ->	The next frame is used instead of a blend.
##		omode 2 ->	Like omode 0 but with some doubleblenddetection (only without missing fields)
##		omode 3 ->	It´s a special mode for 12fps sources.
##		omode 4 ->	Does nothing with the source. It just subtitle the blendfactor.
##	bthresh
##		For omode 0 and 1 bthresh will be just compared with the calculated blendfactor. If the blendfactor is higher 
##		a blend is detected. Omode 3 use this threshold to detect clears. If blendfactor<-bthresh the frame will be outputed
##		also if there is another frame with a smaller blendfactor. This can give a better motion.	[0...2.0  ->0.1]
##	mthresh
##		It´s used for (m)otion (thresh)olding. It regulates the blenddetection of frames with small pixelvaluedifferences.
##		A better quality of the source allows lower values and a more accurate detection.		[0.3...1.6  ->0.6]
##	xr,yr,fnr
##		The scaled detection radius (xr & yr) blurrs the internal detection clip and can speed up the function a little bit.
##		With fnr=true you enables a (f)ast (n)oise (r)eduction. It´s sometimes very useful for noisy sources and typical
##		area motion (anime). Don´t use a too big radius	if you enables this feature and don´t use it on very clean sources
##		(speed decreasing is not the only negative effect).					[1.0...4.0  ->1.5,2.0,false]
##	dclip
##		The (d)etection(clip) you can set to improve the blenddetection (cleaning the clip before).
##		This clip is only used for the blenddetection and not for output.



Function Cdeblend(clip input, int "omode", float "bthresh", "mthresh", "xr", "yr", bool "fnr", clip "dclip") 
{
###### parameters ######
global thresh 	= default(bthresh,0.1)
global mthr	= default(mthresh,0.6)
global omode 	= default(omode,0)

mode	= default(omode,0)

xr	= 0.125 / default(xr, 1.5)										#x detection reduction
yr	= 0.125 / default(yr, 2.0)										#y detection reduction
fnr	= default(fnr, false)											#fast noise reduction

###### preparation ######
global output	= input
btemp 	= default(dclip,input)
global blendclip= (fnr==false ? btemp : clense(btemp)).bilinearresize(int(width(btemp)*xr)*8,int(height(btemp)*yr)*8)

rate = framerate(input)

###### masking ######
diff = mt_makediff(blendclip, blendclip.trim(1,0))
global mask	= mt_lutxy(diff, diff.trim(1,0), yexpr="x 128 - abs y 128 - abs < x 128 - abs x y + 256 - abs < & x 128 - abs x 128 - abs 0.5 ^ - 2 ^ y 128 - abs x y + 256 - abs < y 128 - abs y 128 - abs 0.5 ^ - 2 ^ x y + 256 - abs x y + 256 - abs 0.5 ^ - 2 ^ ? ? x 128 - y 128 - * 0 > -1 1 ? * 128 +", uexpr="x", vexpr="x")

###### initialising ######
global Cbp3	= thresh>0 ? 128.0 : 2.0
global Cbp2	= thresh>0 ? 128.0 : 2.0
global Cbp1	= thresh>0 ? 128.0 : 2.0
global Cbc0	= thresh>0 ? 128.0 : 2.0
global Cbn1	= thresh>0 ? 128.0 : 2.0
global Cbn2	= thresh>0 ? 128.0 : 2.0

global Cdp3	= mthr*0.5
global Cdp2	= mthr*0.5
global Cdp1	= mthr*0.5
global Cdc0	= mthr*0.5
global Cdn1	= mthr*0.5

global current	= 0

###### helper function ######
function min(a,b)
{
a = a<b ? a : b
return a
}

###### evaluation ######
function evaluate(float Cdiff, Cbval)
{
global Cdp3	= Cdp2
global Cdp2	= Cdp1
global Cdp1	= Cdc0
global Cdc0	= omode>1 ? Cdn1 : Cdiff
global Cdn1	= Cdiff

global Cbp3	= Cbp2
global Cbp2	= Cbp1
global Cbp1	= Cbc0
global Cbc0	= omode>1 ? Cbn1 : Cdp1<mthr || Cdc0<mthr ? 0.0 : (Cbval-Cbn2)/pow((Cdc0>Cdp1 ? Cdc0 : Cdp1)+mthr, 0.8)
global Cbn1	= Cdc0<mthr || Cdn1<mthr ? 0.0 : (Cbval-Cbn2)/pow((Cdn1>Cdc0 ? Cdn1 : Cdc0)+mthr, 0.8)
global Cbn2	= Cbval


global current	= Cbn1<-thresh && Cbc0>thresh || Cbn1<0 && Cbc0>0 && Cbc0+Cbp1>0 && Cbc0+Cbp1+Cbp2>0 ? 1 :
		\	Cbc0<-thresh && Cbp1>thresh || Cbc0<0 && Cbc0+Cbn1<0 && Cbp1>0 && Cbp1+Cbp2>0 ? 0 : 
		\	current==-2 ? (Cbn1>0 ? 2 : 1) : current-1
global current	= omode!=2 ? current : min(-Cbp1,Cbc0+Cbn1)>thresh && abs(Cbn1)>abs(Cbc0) ? -1 :
		\	min(-Cbp2-Cbp1,Cbc0)>thresh && abs(Cbp2)>abs(Cbp1) ? 1 : min(-Cbp1,Cbc0)>thresh ? -1 : 0 
global current	= omode>1 ? current : min(-Cbp1,Cbc0)<thresh ? 0 : omode==0 ? -1 : 1

omode==4 ? output.subtitle(string( Cbc0>0 && Cbp1<0 ? min(-Cbp1,Cbc0) : Cbc0<0 && Cbp1>0 ? -min(Cbp1,-Cbc0) : 0.0 ) + (min(-Cbp1,Cbc0)>=thresh ? " -> BLEND!! " : " ")) :
\	output.trim(0,1) ++ output.trim(2+current,0)

return last
}

###### final evaluating ######
mode > 1 ? scriptclip(output, "evaluate(LumaDifference(blendclip.trim(1,0),blendclip.trim(3,0)), AverageLuma(mask.trim(1,0)))") :
	\	scriptclip(output, "evaluate(LumaDifference(blendclip,blendclip.trim(2,0)), AverageLuma(mask))")

recl = last.changefps(rate*2).changefps(rate,linear=true)
return(recl.addborders(0,0,8,0).crop(0,0,-8,-0)) 
}
