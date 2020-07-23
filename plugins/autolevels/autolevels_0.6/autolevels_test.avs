loadplugin("..\autolevels_0.6_20110109.dll")

# reduce to quarter size
function fit(clip c) {
  return c.Lanczos4Resize(320,240)
  # return c.crop(0,0,320,240)
}

# --- display the different formats side by side ---
function fourup(clip c) {
   yv12  = c.convertToYV12.autolevels().convertToRGB32.fit
   yuy2  = c.convertToYUY2.autolevels().convertToRGB32.fit
   rgb24 = c.convertToRGB24.autolevels().convertToRGB32.fit
   rgb32 = c.convertToRGB32.autolevels().convertToRGB32.fit

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

# --- compare levels vs autolevels for identical parameters ---

function compare_to_levels(clip c, in_low, gamma, in_high, out_low, out_high, coring) {
    tmp1 = c.levels(              in_low,       gamma,            in_high,            out_low,             out_high, coring=coring)
    tmp2 = c.autolevels(input_low=in_low, gamma=gamma, input_high=in_high, output_low=out_low, output_high=out_high, coring=coring)
    # FIXME: make differences more obvious; use masktools or tweak
    return subtract(tmp1, tmp2)
}

function compare_to_levels_allformats(clip c, in_low, gamma, in_high, out_low, out_high, coring) {
   yv12  = c.convertToYV12.compare_to_levels(in_low, gamma, in_high, out_low, out_high, coring).convertToRGB32.fit
   yuy2  = c.convertToYUY2.compare_to_levels(in_low, gamma, in_high, out_low, out_high, coring).convertToRGB32.fit
   rgb24 = c.convertToRGB24.compare_to_levels(in_low, gamma, in_high, out_low, out_high, coring).convertToRGB32.fit
   rgb32 = c.convertToRGB32.compare_to_levels(in_low, gamma, in_high, out_low, out_high, coring).convertToRGB32.fit
   return stackvertical( stackhorizontal( yv12,  yuy2), \
                         stackhorizontal(rgb24, rgb32)  )
}

# full range mapping
function compare_to_levels_test1(clip c) {
    return compare_to_levels_allformats(c, 0, 1.0, 255, 0, 255, true)
}
function compare_to_levels_test2(clip c) {
    return compare_to_levels_allformats(c, 0, 1.0, 255, 0, 255, false)
}
# range compression
function compare_to_levels_test3(clip c) {
    return compare_to_levels_allformats(c, 30, 1.0, 200, 50, 150, true)
}
function compare_to_levels_test4(clip c) {
    return compare_to_levels_allformats(c, 30, 1.0, 200, 50, 150, false)
}
# range expansion
function compare_to_levels_test5(clip c) {
    return compare_to_levels_allformats(c, 50, 1.0, 150, 30, 200, true)
}
function compare_to_levels_test6(clip c) {
    return compare_to_levels_allformats(c, 50, 1.0, 150, 30, 200, false)
}
# range expansion with gamma
function compare_to_levels_test7(clip c) {
    return compare_to_levels_allformats(c, 50, 1.4, 150, 30, 200, true)
}
function compare_to_levels_test8(clip c) {
    return compare_to_levels_allformats(c, 50, 1.4, 150, 30, 200, false)
}
# inverted mapping
function compare_to_levels_test9(clip c) {
    return compare_to_levels_allformats(c, 0, 1.0, 255, 200, 30, true)
}
function compare_to_levels_test10(clip c) {
    return compare_to_levels_allformats(c, 0, 1.0, 255, 200, 30, false)
}

# pick a test source to test
# [ crop the borders on a raw 8mm capture, otherwise the frame intrudes and
#   messes up the luma bounds ]
src = DirectShowSource("../../../8mm/cinepost/original-yv12/01.avi") \
    . crop(32,32,720-64,480-32).Lanczos4Resize(640,480)

# alternate source
#src = colorbars

# --- run a test; last one uncommented gets run ---

src.fourup

#src.diffem

# should be somewhat close to gray, but there will be differences:
#src.compare_inplace_vs_manual

# should produce a solid grey screen:
#src.compare_rgb24_vs_rgb32

# any of these should produce a solid grey screen:
#src.compare_to_levels_test1
#src.compare_to_levels_test2
#src.compare_to_levels_test3
#src.compare_to_levels_test4
#src.compare_to_levels_test5
#src.compare_to_levels_test6
#src.compare_to_levels_test7
#src.compare_to_levels_test8
#src.compare_to_levels_test9
#src.compare_to_levels_test10

# --- speed test ---
# on my machine, I get these speeds
#   255 fps: dss.yv12
#   120 fps: dss.yv12.autolevels  <-- why so slow comapred to yuy2?
#   220 fps: dss.yuy2
#   170 fps: dss.yuy2.autolevels  <-- why so fast?
#   180 fps: dss.rgb32
#   105 fps: dss.rgb32.autolevels
#src = DirectShowSource("../../../8mm/cinepost/original-yv12/01.avi").assumefps(999)
#src.converttoyv12
#src.converttoyv12.autolevels()
#src.converttoyuy2
#src.converttoyuy2.autolevels()
#src.converttorgb32
#src.converttorgb32.autolevels()
