loadplugin("../autolevels.dll")

# reduce to quarter size
function fit(clip c) {
  return c.Lanczos4Resize(320,240)
  # return c.crop(0,0,320,240)
}

# --- display the different formats side by side ---
function fourup(clip c) {
   yv12  = c.convertToYV12.autolevels.convertToRGB32.fit
   yuy2  = c.convertToYUY2.autolevels.convertToRGB32.fit
   rgb24 = c.convertToRGB24.autolevels.convertToRGB32.fit
   rgb32 = c.convertToRGB32.autolevels.convertToRGB32.fit

   return stackvertical( stackhorizontal( yv12,  yuy2), \
                         stackhorizontal(rgb24, rgb32)  )
}

# --- check for differences in the color formats ---
function diffem(clip c) {
   yv12  = c.convertToYV12.autolevels.convertToRGB32.fit
   yuy2  = c.convertToYUY2.autolevels.convertToRGB32.fit
   rgb24 = c.convertToRGB24.autolevels.convertToRGB32.fit
   rgb32 = c.convertToRGB32.autolevels.convertToRGB32.fit

   return stackvertical( \
       stackhorizontal( yv12,                 subtract(yv12,yuy2)), \
       stackhorizontal( subtract(yv12,rgb24), subtract(yv12,rgb32)) \
   )
}

# --- compare hack vs converting to yuv before converting in place ---
function compare_inplace_vs_manual(clip c) {
    rgb32 = c.convertToRGB32.autolevels.convertToRGB32
    ideal = c.convertToRGB32.convertToYV12.autolevels.convertToRGB32

    return subtract(rgb32, ideal)
}

# --- compare 24b vs 32b; they should be identical ---
function compare_rgb24_vs_rgb32(clip c) {
    rgb24 = c.convertToRGB24.autolevels.convertToRGB32
    rgb32 = c.convertToRGB32.autolevels.convertToRGB32
    return subtract(rgb24, rgb32)
}

# --- test the effect of the rgb->luma conversion matrix ---
function show4_rgb_matrix(clip c) {
    reference = c.convertToYV12.autolevels().fit.convertToRGB32
    rgb_601   = c.convertToRGB32.autolevels(matrix="Rec601").fit.convertToRGB32
    rgb_709   = c.convertToRGB32.autolevels(matrix="Rec709").fit.convertToRGB32
    rgb_avg   = c.convertToRGB32.autolevels(matrix="average").fit.convertToRGB32
    return stackvertical( stackhorizontal(reference, rgb_avg), \
	                  stackhorizontal(rgb_601,   rgb_709)  )
}

function diff4_rgb_matrix(clip c) {
    reference = c.convertToYV12.autolevels().fit.convertToRGB32
    rgb_601   = c.convertToRGB32.autolevels(matrix="Rec601").fit.convertToRGB32
    rgb_709   = c.convertToRGB32.autolevels(matrix="Rec709").fit.convertToRGB32
    rgb_avg   = c.convertToRGB32.autolevels(matrix="average").fit.convertToRGB32
    return stackvertical( \
	stackhorizontal(reference,                    subtract(reference, rgb_avg)), \
	stackhorizontal(subtract(reference, rgb_601), subtract(reference, rgb_709))  \
    )
}

function diff2_rgb_matrix(clip c) {
    rgb_601 = c.convertToRGB32.autolevels(matrix="Rec601")
    rgb_709 = c.convertToRGB32.autolevels(matrix="Rec709")
    return subtract(rgb_601, rgb_709)
}

# pick a test source to test:
# [ crop the borders on a raw 8mm capture, otherwise the frame intrudes and
#   messes up the luma bounds ]
src = AVISource("../../8mm/cinepost/original/01.avi") \
    . crop(32,32,720-64,480-32).Lanczos4Resize(640,480)

# --- run a test; last one uncommented gets run ---
src.autolevels(debug=true)
#src.fourup
#src.diffem
#src.compare_inplace_vs_manual
#src.compare_rgb24_vs_rgb32
#src.show4_rgb_matrix
#src.diff4_rgb_matrix
#src.diff2_rgb_matrix
