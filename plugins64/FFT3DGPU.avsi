function FFT3DGPU(clip clip, float "sigma", float "beta", int "bw", int "bh", int "bt", float "sharpen", int "plane", int "mode", int "bordersize", int "precision", bool "NVPerf", float "degrid", float "scutoff", float "svr", float "smin", float "smax", float "kratio", int "ow", int "oh", int "wintype" , int "interlaced", float "sigma2", float "sigma3", float "sigma4", bool "oldfft")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/FFT3DGPU.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/FFT3DGPU.dll")
        FFT3DGPU(clip, sigma, beta, bw, bh, bt, sharpen, plane, mode, bordersize, precision, NVPerf, degrid, scutoff, svr, smin, smax, kratio, ow, oh, wintype, interlaced, sigma2, sigma3, sigma4, oldfft)
}