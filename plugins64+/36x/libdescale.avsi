function Debilinear(clip src, int width, int height, float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Debilinear(src, width, height, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Debicubic(clip src, int width, int height, float "b", float "c", float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Debicubic(src, width, height, b, c, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Delanczos(clip src, int width, int height, int "taps", float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Delanczos(src, width, height, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Despline16(clip src, int width, int height, float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Despline16(src, width, height, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Despline36(clip src, int width, int height, float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Despline36(src, width, height, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Despline64(clip src, int width, int height, float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Despline64(src, width, height, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Depoint(clip src, int width, int height, float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Depoint(src, width, height, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}

function Descale(clip src, int width, int height, string "kernel", int "taps", float "b", float "c", float "blur", float_array "post_conv", float "src_left", float "src_top", float "src_width", float "src_height", int "border_handling", clip "ignore_mask", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Descale(src, width, height, kernel, taps, b, c, blur, post_conv=post_conv, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, border_handling=border_handling, ignore_mask=ignore_mask, opt=opt)
}