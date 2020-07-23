Function FixChromaBleeding (clip input) {

  # prepare to work on the V channel and reduce to speed up and filter noise
  area = input.tweak(sat=4.0).VtoY.ReduceBy2

  # select and normalize both extremes of the scale
  red = area.Levels(255,1.0,255,255,0)
  blue = area.Levels(0,1.0,0,0,255)

  # merge both masks
  mask = MergeLuma(red, blue, 0.5).Levels(250,1.0,250,255,0)

  # expand to cover beyond the bleeding areas and shift to compensate the resizing
  mask = mask.ConvertToRGB32.GeneralConvolution(0,"0 0 0 0 0 1 1 1 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0").ConvertToYV12

  # back to full size and binarize (also a trick to expand)
  mask = mask.BilinearResize(Width(input),Height(input)).Levels(10,1.0,10,0,255)

  # prepare a version of the image that has its chroma shifted and less saturated
  input_c = input.ChromaShift(C=-4).tweak(sat=0.8)

  # combine both images using the mask
  return input.overlay(input_c,mask=mask,mode="blend",opacity=1)
}