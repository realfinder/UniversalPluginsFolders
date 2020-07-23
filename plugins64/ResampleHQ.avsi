function ResampleHQ(clip clip, int "width", int "height", string "dstcolorspace", string "srcmatrix", string "dstmatrix", bool "dither", float "src_left", float "src_top", float "src_width", float "src_height", string "kernel", float "karg1", float "karg2", float "kblur_x", float "kblur_y", string "chroma_kernel", float "chroma_karg1", float "chroma_karg2")
{
LoadPlugin(AviSynthPlugins64Dir + "25/ResampleHQ.dll")
        ResampleHQ(clip, width, height, dstcolorspace, srcmatrix, dstmatrix, dither, src_left, src_top, src_width, src_height, kernel, karg1, karg2, kblur_x, kblur_y, chroma_kernel, chroma_karg1, chroma_karg2)
}