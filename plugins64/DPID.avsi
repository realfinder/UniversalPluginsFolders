function DPID(clip input, int target_width, int target_height, float "lambdaY", float "lambdaU", float "lambdaV", float "src_leftY", float "src_leftU", float "src_leftV", float "src_topY", float "src_topU", float "src_topV", int "cloc")  {
LoadPlugin(AviSynthPlugins64Dir + "26/DPID.dll")
    DPID(input, target_width, target_height, lambdaY, lambdaU, lambdaV, src_leftY, src_leftU, src_leftV, src_topY, src_topU, src_topV, cloc)
}


function DPIDraw(clip input, clip input2, float "lambdaY", float "lambdaU", float "lambdaV", float "src_leftY", float "src_leftU", float "src_leftV", float "src_topY", float "src_topU", float "src_topV", int "cloc", int "y", int "u", int "v")  {
LoadPlugin(AviSynthPlugins64Dir + "26/DPID.dll")
    DPIDraw(input, input2, lambdaY, lambdaU, lambdaV, src_leftY, src_leftU, src_leftV, src_topY, src_topU, src_topV, cloc, y, u, v)
}