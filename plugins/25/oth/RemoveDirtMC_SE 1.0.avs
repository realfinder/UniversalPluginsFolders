######################################################
##						                          	##
## Requirements     : - MVTools      (v2.5.11.1)	##
## -----------------  - Masktools    (v2.0a48)	   	##
##		      - RemoveGrainT (v1.0) package 	    ##
##		      - RemoveDirt   (v0.9) package	        ##
##		      - AvsRecursion (v0.2) 		        ##
##		      - FluxSmooth   (v1.1) 	            ##
##		    					                    ##
######################################################

##############################################################################################
#													   	                                     #
# Usage     : RemoveDirtMC_SE_1(clip input, int"radius", int"repmode", int"clmode",\           #
# ----------                bool"chroma", bool"TwoPassDeNoise", int"thSAD", int"thSADC")     #
# 		                           			                                                 #
#													   	                                     #
##############################################################################################

#################	
# ------------- #
# PARAMETERS  	#
# ------------- #
#################

#######################################################################################################################
#
# ----------
# Radius    : -- Temporal Radius for MDeGrain at second stage DeNoising.
# ----------
#
# ----------
# repmode   : -- RemoveDirt's "repmode" parameter.
# ----------     
#
# ----------
# clmode    : -- RemoveGrain's "mode" parameter in RemoveDirt function.
# ----------
#
# ----------
# Twopass
# Denoise   : -- To make a Temporal Denoising (MDeGrain) after Spatial Denoising.   
# ----------   
# 
# ----------
# thSAD, 
# thSADC    : -- MDeGrain's thSAD and thSADC parameters.
# ---------- 
#
#######################################################################################################################


Function RemoveDirtMC_SE_1(clip input, int"radius", int"repmode", int"clmode", bool"TwoPassDeNoise", bool"chroma", int"thSAD", int"thSADC")

{
    
 radius = default(radius,    2)
 repmode = default(repmode,  16)
 clmode = default(clmode,    5)
 TwoPassDeNoise = default(TwoPassDeNoise, false)
 chroma = default(chroma, true)
     
     ox = input.width()
     oy = input.height()
     HD = (ox== 1920 || oy>= 800) ? true : false
 blksize = (HD==true) ? 16:8
 search = (HD==true) ?  4:5
 overlap = blksize/2
 thSAD = (HD==true) ?  160:320
 thSADC = default(thSADC, thSAD)
 
      src = input
      PreNR = input.RemoveDirt().TemporalDeGrain_1(5,8)
 PreNR_super = MSuper(PreNR,hpad=4,vpad=4,pel=2,sharp=2)
 src_super = MSuper(input,hpad=4,vpad=4,pel=2,sharp=2,levels=1)

 bwv1 = MAnalyse(PreNR_super, blksize=blksize, search=search, isb=true,  delta=1, overlap=overlap, truemotion=true, chroma=chroma) 
 bwv2 = (TwoPassDeNoise==true && radius>=2) ? \
	MAnalyse(PreNR_super, blksize=blksize, search=search, isb=true,  delta=2, overlap=overlap, truemotion=true, chroma=chroma) : BlankClip()
 bwv3 = (TwoPassDeNoise==true && radius==3) ? \
	MAnalyse(PreNR_super, blksize=blksize, search=search, isb=true,  delta=3, overlap=overlap, truemotion=true, chroma=chroma) : BlankClip()
 fwv1 = MAnalyse(PreNR_super, blksize=blksize, search=search, isb=false, delta=1, overlap=overlap, truemotion=true, chroma=chroma) 
 fwv2 = (TwoPassDeNoise==true && radius>=2) ? \
	MAnalyse(PreNR_super, blksize=blksize, search=search, isb=false, delta=2, overlap=overlap, truemotion=true, chroma=chroma) : BlankClip()
 fwv3 = (TwoPassDeNoise==true && radius==3) ? \
	MAnalyse(PreNR_super, blksize=blksize, search=search, isb=false, delta=3, overlap=overlap, truemotion=true, chroma=chroma) : BlankClip()

 b1comp = MCompensate(input,src_super,bwv1) 
 f1comp = MCompensate(input,src_super,fwv1)
 NR = RemoveDirtX(input, f1comp, b1comp, repmode=repmode, clmode=clmode)

 NR_super = ( TwoPassDeNoise==true  ) ? MSuper(NR,hpad=4,vpad=4,pel=2,sharp=2,levels=1) : BlankClip()
       sum = ( TwoPassDeNoise==false ) ? NR 
	\   : (  radius==1  ) ? MDeGrain1(NR, NR_super, bwv1, fwv1, thSAD=thSAD, thSADC=thSADC)
	\   : (  radius==2  ) ? MDeGrain2(NR, NR_super, bwv1, bwv2, fwv1, fwv2, thSAD=thSAD, thSADC=thSADC)
 	\   : 			MDeGrain3(NR, NR_super, bwv1, bwv2, bwv3, fwv1, fwv2, fwv3, thSAD=thSAD, thSADC=thSADC)
 Return (sum)

 }


 function TemporalDeGrain_1(clip input, int "mode", int "thr")

 {
	rg = RemoveGrain(input, mode=mode)
	tr = TemporalRepair(rg, input)
             FluxSmoothT(tr,thr)
	 
 }


function RemoveDirtX(clip input, clip fcomp, clip bcomp, int "repmode", int "clmode") 
{ 
repmode = default(repmode, 16) 
clmode = default(clmode, 5) 
clensed = interleave(fcomp,input,bcomp).Clense(cache=-1).selectevery(3,1) 
sbegin = ForwardClense(input, cache=-1) 
send = BackwardClense(input, cache=-1) 
alt = Repair(SCSelect(input, sbegin, send, clensed, debug=false), input, mode=repmode) 
restore = Repair(clensed, input, mode=repmode) 
corrected = RestoreMotionBlocks(clensed, restore, neighbour=input, alternative=alt, gmthreshold=50, dist=1,\ 
                                dmode=2, debug=false, noise=8, noisy=12) 
RemoveGrain(corrected, mode=clmode)
}