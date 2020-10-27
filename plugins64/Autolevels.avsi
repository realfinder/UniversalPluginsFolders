function Autolevels(clip clip, int "filterRadius", int "sceneChgThresh", string "frameOverrides", float "gamma", bool "autogamma", float "midpoint", float "autolevel", int "input_low", int "input_high", int "output_low", int "output_high", float "coring", float "ignore", float "ignore_low", float "ignore_high", int "border", int "border_l", int "border_r", int "border_t", int "border_b", float "debug", int "sc2th", float "sc2Perc", float "gammax", float "gammin", int "minRng")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/Autolevels.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Autolevels.dll")
        Autolevels(clip, filterRadius, sceneChgThresh, frameOverrides, gamma, autogamma, midpoint, autolevel, input_low, input_high, output_low, output_high, coring, ignore, ignore_low, ignore_high, border, border_l, border_r, border_t, border_b, debug, sc2th, sc2Perc, gammax, gammin, minRng)
}

function Autogamma(clip clip, int "filterRadius", int "sceneChgThresh", string "frameOverrides", float "gamma", bool "autogamma", float "midpoint", float "autolevel", int "input_low", int "input_high", int "output_low", int "output_high", float "coring", float "ignore", float "ignore_low", float "ignore_high", int "border", int "border_l", int "border_r", int "border_t", int "border_b", float "debug", int "sc2th", float "sc2Perc", float "gammax", float "gammin", int "minRng")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/Autolevels.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Autolevels.dll")
        Autogamma(clip, filterRadius, sceneChgThresh, frameOverrides, gamma, autogamma, midpoint, autolevel, input_low, input_high, output_low, output_high, coring, ignore, ignore_low, ignore_high, border, border_l, border_r, border_t, border_b, debug, sc2th, sc2Perc, gammax, gammin, minRng)
}