function ReBlend_Vin(clip clip, int "start", int "end", int "order", int "mode", int "ythresh", int "cthresh", float "sstr", int "amnt", int "uv"){

     ###############################################################################
     #                                                                             #
     #       ReBlend                                                               #
     #                                                                             #
     #    Requires MPEG2DEC, mSharpen, ChromaShift, MaskTools and                  #
     #      vd_warpsharp which you can find below *slaps head - changes order*     #
     #                                                                             #
     #    Uses MPEG2DEC's BlendFields() to kill hardest interlacing, like in       #
     #    interlaced fades. But BlendFields is very blurry and comes with evil     #
     #    chroma artifacts. So I use it only for fades with movement and sometimes #
     #    for pattern-blends. ReFadeIn/Out should be weapon of choice if possible. #
     #                                                                             #
     #    To workaround the chroma artifacts the top/bottom-field of the           #
     #    original chroma gets doubled in height and then merged with the          #
     #    luma blended by BlendFields.                                             #
     #    mSharpen and vd_warpsharp somewhat help with the blurryness. If you      #
     #    don't like vdub's warpsharp for some odd reason feel free to change it   #
     #    with some other warpsharp in the script below. (mode1)                   #
     #                                                                             #
     #    Mode2 uses simple doubled fields on planar surfaces                      #
     #    merged with "mode1'd" edges using MaskTools' MaskedMerge.                #
     #    Can produce a weird look especially on extremely blocky scenes,          #
     #    so mode1 is still an option.                                             #
     #                                                                             #
     #    Mode3 is a dumb-mode and is just using resized fields. Looks best        #
     #    in some very rare cases when there are scenes with no edges at all.      #
     #                                                                             #
     #    Mode4(default) uses blur(0,1) and is fast and produces way less blocks   #
     #                                                                             #
     #    "order" parameter was chosen according to decomb.                        #
     #    Just means "1" uses top-field and "0" uses bottom-field.                 #
     #    ythresh and cthresh are thresholds for EdgeMask's edge-detection.        #
     #                                                                             #
     #       History                                                               #
     #    v0.1-0.4  too lazy to list                                               #
     #    v0.5      mode2+3 added                                                  #
     #    v0.6      mode4                                                          #
     #                                                                             #
     #                                                                             #
     ###############################################################################

     
     #LoadPlugin("C:\Program Files\AviSynth 2.5\plugins\reblend_files\ChromaShift.dll")
     #LoadPlugin("C:\Program Files\AviSynth 2.5\plugins\reblend_files\MaskTools.dll")
     #LoadPlugin("C:\Program Files\AviSynth 2.5\plugins\reblend_files\MPEG2DEC.dll")

     start   = default(start,0)
     end     = default(end,framecount(clip))
     order   = default(order,1)
     mode    = default(mode,4)
     ythresh = default(ythresh,3)
     cthresh = default(cthresh,5)
     sstr    = default(sstr,2.7) #strength for vinverse
     amnt    = default(amnt,255) 
     uv      = default(uv,3)

     new = clip.Vinverse(sstr, amnt, uv).trim(start,end)

     new = clip.isYV12() ? new.converttoyv12()    : clip.isYUY2() ? new.converttoyuy2() : new.converttorgb32()

     final = (start == 0)               ? new + clip.trim(end+1,0) :
           \ (start == 1)               ? clip.trim(0,1).deleteframe(1) + new + clip.trim(end+1,0) :
           \ (end == clip.framecount)   ? clip.trim(0,start-1) + new :
           \ (end == clip.framecount-1) ? clip.trim(0,start-1) + new.deleteframe(0) + clip.trim(c.framecount,c.framecount)
           \                            : clip.trim(0,start-1) + new + clip.trim(end+1,0)

     assert(clip.framecount == final.framecount, "ReBlend(): warning! wrong framecount! beat the author for writing buggy scripts >_>")

  return final }