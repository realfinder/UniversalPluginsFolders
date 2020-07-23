function Blockbuster(clip clip, string "method", int "block_size", int "detail_min", int "detail_max", int "luma_offset", int "luma_threshold", float "mean", float "variance", int "cache", int "seed", int "strength")
{
LoadPlugin(AviSynthPluginsDir + "25/Blockbuster.dll")
    Blockbuster(clip, method, block_size, detail_min, detail_max, luma_offset, luma_threshold, mean, variance, cache, seed, strength)
}