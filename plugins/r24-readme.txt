

Restore24(clip worki,clip outi, int "numr", int "deno" )

worki		Input clip for analysis. use any stupid bobbed clip. 
		preferrable r24kernelbob(0)

outi		Input clip, that is meant for display. 
		There is no analysis on this clip at all, 
		so feel free to feed it with any source you like. 
		Ensure, worki and outi are running syncronous framewise.

numr/deno	are used to set up the framerate decimation.
		this makes restore24 becoming an universal deblender 
		for a wide spectrum of blended sources.

		The following ratios are practicable:

		23.976fps telecined FILM blended into PAL
		2997, 6250 (default, if no ratio is given)

		25fps blended into NTSC:
		1250, 2997
		this is similar to rePAL, exept that it has better blend recognition
		and matches the 25fps perfect (rePAL puts out 24.975 fps)

		sometimes, 24 fps Film gets badly transferred to NTSC, so it became blended:
		24fps blended into NTSC ->
		24, 60 
		as you may know it from smartdecimate

		Known issue:
		with a decimattion ratio of 2997:6250 as it is being used for
		restoring PAL-Videos to NTSC-Film framerates, you cannot process
		Videos longer than about 50 minutes.
		to do so, either
		divide the video in parts of 40 minutes with some frames overlap,
		restore them separately and rejoin them afterwards.
		
		or process your video with a decimation ratio of 24:50.
		this will output 24.000 fps. If you intend to speedup the
		video to PAL this issue does not matter, but if you intend
		to encode it is NTSC-MPEG2, you should go the separating way.




TDeint(clip x, parameters)
		for a detailed description of TDeints paramters, see
		TDeint.txt in the plugins Directory.
		preferrable usage of TDeint with Restore24 is:
		TDeint(mode=1,tryweave=false)



r24kernelbob(clip a, int "th")

a		input clip (YV12 & YUY2)

th		deinterlacing threshold
		default = 0 (for creating the analysis clip)