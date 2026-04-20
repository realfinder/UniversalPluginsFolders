function FilmGrain(clip c, int "quality", float "grainsize")
{
LoadPlugin(AviSynthPlugins64Dir + "26/FilmGrain.dll")
        FilmGrain(c, quality, grainsize)
}


function FilmGrainFast(clip c, float "strength", int "quality", float "grainsize")
{
LoadPlugin(AviSynthPlugins64Dir + "26/FilmGrain.dll")
        FilmGrainFast(c, strength, quality, grainsize)
}