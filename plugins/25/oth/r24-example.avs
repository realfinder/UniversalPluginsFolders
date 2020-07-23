###	Set this value to 2/3 of your Systems RAM (I have 768MB), 
# 	if your machine ceeps crashing using this script
#setmemorymax(512) 


####	ensure modifying the paths to your *.AVS and *.DLL files

#	load the needed functions
import("restore24.avs")

#	load the needed plugins
loadplugin("masktools.dll")
loadplugin("tdeint.dll")
loadplugin("leakkerneldeint.dll")
#loadplugin("dgdecode.dll") #or mpeg2dec3.dll

loadplugin("avisynth_c.dll")
loadcplugin("smartdecimate.dll")
loadCplugin("ibob.dll")



#	load the Video, use postprocessing for better blend-recognition on MPEG Video
#mpeg2source("video.d2v",cpu=4,iPP=true)
AVISource("video.avi")

#	setup the correct Fieldorder, when using sources other than MPEG2.
#AssumeTFF()
#AssumeBFF()

###	create the clip that is used for blend detection
a2=r24kernelbob(0)		#  best blend detection, slow
a0=ibob()			#  fastest method, maybe unprecise for detecting blends

###	create the clip to be shown after the blends had been killed

b2=TDeint(mode=1,tryweave=false)#  best resolution as possible gets restored, slow
b1=r24kernelbob(7)		#  much faster than TDeint(), but not the best resolution
b0=a0				#  ultrafast, but only for speedfreaks


###	call restore24 using both clips

# recommened, best, slow		(a2, b2)
# standard, medium, medium:		(a2, b1)
# not recommened, medium, fast:		(a0, b1)
# never recommened, worst, fastest:	(a0, b0)

restore24(a2, b2)

###	eventually downscale it to NTSC-resolution (hides some artifacts)

# lanczosresize(width,480)