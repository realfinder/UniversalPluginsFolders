function Deen(clip clip, string "mode", int "rad", int "thrY", int "thrUV", int "tthY", int "tthUV", float "min", float "scd", string "fcf", bool "borderfix")
{
sisnavs26 = VersionNumber() < 2.60
sisnavs26 ? LoadPlugin(AviSynthPluginsDir + "25/Deen.dll") : LoadPlugin(AviSynthPluginsDir + "26/Deen.dll")
        sisnavs26 ? Deen(clip, mode, rad, thrY, thrUV, tthY, tthUV, min, scd, fcf, borderfix) : Deen(clip, mode, rad, thrY, thrUV, tthY, tthUV, min, scd, fcf, borderfix)
}