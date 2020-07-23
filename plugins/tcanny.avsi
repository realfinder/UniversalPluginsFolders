function tcanny(clip clip, float "sigma", float "t_h", float "t_l", int "nms", int "mode", int "plane", float "gmmax")
{
LoadPlugin(AviSynthPluginsDir + "25/tcanny.dll")
        tcanny(clip, sigma, t_h, t_l, nms, mode, plane, gmmax)
}


function tdtrans(clip clip, int "mode", int "plane")
{
LoadPlugin(AviSynthPluginsDir + "25/tcanny.dll")
        tdtrans(clip, mode, plane)
}