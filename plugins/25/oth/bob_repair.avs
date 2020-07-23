##############################
## bob_repair  by MOmonster ##
##############################


## bob_repair can be used to undo bad bobbing of telecined sources (3:2 Pulldown, field-shifting).
##
## Use import("bob_repair.avs") in your script and load the necessary filters if you want to use this function
##
## required filters:
##		- mt_masktools
##		- TIVTC
## version:
##		- v0.4  - 30.05.2008
##



## sample1:	source				#progressive
##		bob_repair(480,pp=2)
##
## sample2:	source
##		bob_repair()
##		tdecimate(rate=23.976,mode=7)


## bob_repair(clip clp, int "height", int "cropt", int "cropb", int "bthr", int "pp", int "width", int "cache")
##
## parameter description:
##	height, cropt, cropb
##		If the source was resized after bobbing it is most important to find out the original height and the added borders.
##		It´s not easy but if you found the right values you can set them here.
##	bthr
##		The bob-threshold can be used to make the fielddetection less aggressive if there are some wrong detections.
##														[1...30  ->10]
##	pp
##		If some frames of the output are interlaced, you can use tfm´s postprocessing to deinterlace them. [0...7  ->0]
##	width
##		Not so important but used for the blocksize is the parameter width. For upsized hd sources you can use for example 704.
##		If you don´t set the width the inputwidth is used.
##	cache
##		For a better compatibility bob_repair use Trtical´s requestlinear function if cache is setted >=0. [...0...30  ->-1]



function bob_repair(clip clp, int "height", int "cropt", int "cropb", int "bthr", int "pp", int "width", int "cache")
{
###### parameters ######
        iheight	= abs(default(height, height(clp)))
        icropt	= abs(default(cropt, 0))
        icropb	= abs(default(cropb, 0)) * (-1)
        iwidth	= abs(default(width, width(clp)))
 	
		cache	= default(cache,-1)													#caching for non-linear request
	
global	bth		= abs(default(bthr, 10))
		post	= default(pp, 0)

		win	= width(clp)


###### further preparation ######
global	oclp	= clp.lanczosresize(win,iheight,0,icropt,0,icropb)

global	mclp	= oclp.bicubicresize(width(oclp)/4*2,height(oclp)/4*2)
global	mclp	= mt_makediff(mclp,mclp.trim(1,0)).mt_lut("x 128 - abs 0.8 ^ 1.6 - 8 *").bilinearresize(width(mclp)/16*4, height(mclp)/16*4)

global	bffo	= oclp.assumebff().doubleweave().selectodd()
global	tffo	= oclp.assumetff().doubleweave().selectodd()

global	dbff	= bffo.bicubicresize(win,height(bffo)/2).bicubicresize(win,height(bffo))
global	dbff	= mt_makediff(bffo,dbff).mt_lut("x 128 - abs x 128 - abs 0.4 ^ - 8 *").bilinearresize(iwidth/24*4,iheight/24*4)
global	dtff	= tffo.bicubicresize(win,height(tffo)/2).bicubicresize(win,height(tffo))
global	dtff	= mt_makediff(tffo,dtff).mt_lut("x 128 - abs x 128 - abs 0.4 ^ - 8 *").bilinearresize(iwidth/24*4,iheight/24*4)


###### initialise variables ######
global	cov	= 2
global	mn	= 1
global	tvaln	= 0
global	bvaln	= 0


###### final evaluation ######
ScriptClip(oclp, " cov==0 ? tffo.duplicateframe(0) : cov==1 ? bffo.duplicateframe(0) : cov==2 ? tffo : bffo ")

FrameEvaluate(last, "

  ## value calculating & shifting ##
	global	mp		= mn
	global	mn		= YPlaneMax(mclp)
	global	tvalp	= tvaln
	global	bvalp	= bvaln
	global	tvaln	= YPlaneMax(dtff,0.1)
	global	bvaln	= YplaneMax(dbff,0.1)
	
  ## output calculation ##
   	global	cov	= mp < mn ? (tvalp > bvalp + bth ? 0 : bvalp > tvalp + bth ? 1 : cov==1 || cov==2 ? 0 : 1) :
	   			\ (tvaln > bvaln + bth ? 2 : bvaln > tvaln + bth ? 3 : cov==0 || cov==3 ? 2 : 3)


		")
		
cache<0 ? last : last.RequestLinear(4, cache, 2, false, false)

return last.tfm(slow=2,mode=2,mmsco=false,micmatching=3,pp=post,Mi=40,cthresh=7)
}