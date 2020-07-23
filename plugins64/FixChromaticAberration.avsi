 ###################################################################################
 #
 # This AviSynth function stretches the red, green and/or blue channel according to
 # a given factor symmetrically around the center of the frame and crops it afterwards.
 #
 # Parameters: clip, red, green, blue. 
 # red, green and blue are stretching (resizing) factors against the original clip size.
 # The function returns the clip in RGB24 colorspace.
 #
 # Factors of e.g. red=1.015, green=1.01 allow to compensate the colored edges near the
 # corners of the image which appear from lenses with 'chromatic aberration'.
 #
 # If a factor is below 1.0, a that color will be fitted with black corners into the frame. 
 #
 # x and y allow to set the center of the aberration circle. It defaults to the center
 # of the image.
 #
 # Note that chromatic aberration also smears the image a bit, which is not compensated
 # by this function.
 #
 # Martin Wagener at gmx.de, 04/09/2007
 #
 ###################################################################################
 
 function FixChromaticAberration(clip "clip", val "red", val "green", val "blue", val "x", val "y")
 {
     r= default(red,1)
     g= default(green,1)
     b= default(blue,1)
     c= (IsRGB(clip)) ? clip : ConvertToRGB(clip)
     w= c.Width()
     w2= round(w*0.5)
     h= c.Height()
     h2= round(h*0.5)
     xi= default(x,w*0.5)
     xi= (xi<0)?0:xi
     xi= (xi>=w)?w-1:xi
     yi= default(y,h*0.5)
     yi= (yi<0)?0:yi
     yi= (yi>=h)?h-1:yi
     rw= round(r*w)
     rh= round(r*h)
     rl= round((r-1)*xi)
     rt= round((r-1)*yi)
     gw= round(g*w)
     gh= round(g*h)
     gl= round((g-1)*xi)
     gt= round((g-1)*yi)
     bw= round(b*w)
     bh= round(b*h)
     bl= round((b-1)*xi)
     bt= round((b-1)*yi)
     rc= (r>1) ? LanczosResize(c,rw,rh).Crop(rl,rt,w,h) : c
     gc= (g>1) ? LanczosResize(c,gw,gh).Crop(gl,gt,w,h) : c
     bc= (b>1) ? LanczosResize(c,bw,bh).Crop(bl,bt,w,h) : c
     rcs= (r<1) ? LanczosResize(c.AddBorders(-rl,-rt,w-rw+rl,h-rh+rt),w,h) : rc
     gcs= (g<1) ? LanczosResize(c.AddBorders(-gl,-gt,w-gw+gl,h-gh+gt),w,h) : gc
     bcs= (b<1) ? LanczosResize(c.AddBorders(-bl,-bt,w-bw+bl,h-bh+bt),w,h) : bc
     MergeRGB(rcs, gcs, bcs)
 }
