function VagueDenoiser(clip clip, int "threshold", int "method", int "nsteps", float "chromaT", bool "debug", bool "interlaced", int "wavelet", bool "Wiener", float "wratio", int "percent", clip "auxclip")
{
LoadPlugin(AviSynthPluginsDir + "25/VagueDenoiser.dll")
        VagueDenoiser(clip, threshold, method, nsteps, chromaT, debug, interlaced, wavelet, Wiener, wratio, percent, auxclip)
}