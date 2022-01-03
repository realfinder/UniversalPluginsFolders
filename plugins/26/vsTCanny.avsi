function vsTCanny(clip clip, float "sigmaY", float "sigmaU", float "sigmaV", float "sigma_vY", float "sigma_vU", float "sigma_vV", float "t_h", float "t_l", int "mode", int "op", float "scale", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/vsTCanny.dll")
        vsTCanny(clip, sigmaY, sigmaU, sigmaV, sigma_vY, sigma_vU, sigma_vV, t_h, t_l, mode, op, scale, y, u, v, opt)
}