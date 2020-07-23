function NoisedGrayY8(clip clip, float "amp", int "seed", int "uv", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRNoise.dll")
        NoisedGrayY8(clip, amp, seed, uv, bitdepth)
}

function NoiseMix1Y(clip noise1, clip noise2, float "amp", float "ldiff", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRNoise.dll")
        NoiseMix1Y(noise1, noise2, amp, ldiff, mode, bitdepth)
}

function NoiseMix2Y(clip noise1, clip noise2, float "amp1", float "amp2", float "ldiff", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRNoise.dll")
        NoiseMix2Y(noise1, noise2, amp1, amp2, ldiff, mode, bitdepth)
}

function NoiseUV(clip clip, float "ampu", float "ampv", int "seed", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRNoise.dll")
        NoiseUV(clip, ampu, ampv, seed, mode, bitdepth)
}

function NoiseY(clip clip, float "amp", int "seed", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRNoise.dll")
        NoiseY(clip, amp, seed, mode, bitdepth)
}

function NoiseYM(clip clip, clip "m", float "offset", float "scale", float "amp", int "seed", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRNoise.dll")
        NoiseYM(clip, m, offset, scale, amp, seed, mode, bitdepth)
}