# FixChromaBleedingMod v1.35

Function FixChromaBleedingMod (clip input, int "cxShift", int "cyShift", float "thr", float "strength", bool "f", float "opacity", bool "n", bool "xysh", bool "Bic") {

  xShift = default ( cxShift,       -4 )
  yShift = default ( cyShift,       -4 )
  thr	 = default ( thr,         4.0 )
  stre = default ( strength,      0.8 )
  f =  default ( f,       true )
  n =  default ( n,       false )
  sh =  default ( xysh,       false )
  Bic = default ( Bic,       false )
  opacity = default ( opacity,       1 )

  # prepare to work on the V channel and reduce to speed up and filter noise
  vch  = VersionNumber() < 2.60 ? input.tweak(sat=thr).VtoY : input.tweak(sat=thr).VtoY8
  area = f ? VersionNumber() < 2.60 ? vch.ConvertToyv12.ReduceBy2 : vch.ReduceBy2 : n ? VersionNumber() < 2.60 ? vch.ConvertToyv12.Blur(1) : vch.Blur(1) : VersionNumber() < 2.60 ? vch.ConvertToyv12 : vch

  # select and normalize both extremes of the scale
  red = area.Levels(255,1.0,255,255,0)
  blue = area.Levels(0,1.0,0,0,255)

  # merge both masks
  maskc = n ? MergeLuma(red, blue, 0.5).Levels(250,1.0,250,255,0) : f ?  MergeLuma(red, blue, 0.5).Levels(250,1.0,250,255,0) : MergeLuma(red, blue, 0.5).Blur(1).Levels(250,1.0,250,255,0)

  # expand to cover beyond the bleeding areas and shift to compensate the resizing
   maskc = maskc.mt_edge("0 0 0 1 0 0 0 0 0", 0,255,0,255).mt_edge("1 1 1 1 1 1 0 0 0", 0,255,0,255)

  # back to full size and binarize (also a trick to expand)
  maskc = f ? Bic ? maskc.BicubicResize(Width(vch),Height(vch)).Levels(10,1.0,10,0,255) : maskc.BilinearResize(Width(vch),Height(vch)).Levels(10,1.0,10,0,255).mt_inflate() : maskc.Levels(10,1.0,10,0,255).mt_inflate()

  # prepare a version of the image that has its chroma shifted and less saturated
  input_c = sh ? input.ChromaShiftSP(x=xShift,y=yShift).tweak(sat=stre) : input.ChromaShift(C=xShift).tweak(sat=stre)

  # combine both images using the mask
  fu = VersionNumber() < 2.60 ? input.utoy.overlay(input_c.utoy,mask=maskc,mode="blend",opacity=opacity) : input.utoy8.overlay(input_c.utoy8,mask=maskc,mode="blend",opacity=opacity)
  fv = VersionNumber() < 2.60 ? input.vtoy.overlay(input_c.vtoy,mask=maskc,mode="blend",opacity=opacity) : input.vtoy8.overlay(input_c.vtoy8,mask=maskc,mode="blend",opacity=opacity)
  return YToUV(fU, fV, VersionNumber() < 2.60 ? input : input.ConvertToy8)
}