function neo_vd(clip clip, float "threshold", int "method", int "nsteps", float "percent", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/neo-vague-denoiser.dll")
        neo_vd(clip, threshold, method, nsteps, percent, y, u, v, opt)
}