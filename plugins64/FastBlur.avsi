function FastBlur(clip clip, float radius, float "y_blur", int "iterations", bool "dither", bool "gamma", float "threads")
{
LoadPlugin(AviSynthPlugins64Dir + "26/FastBlur.dll")
        FastBlur(clip, radius, y_blur, iterations, dither, gamma, threads)
}