function vsTBilateral(clip clip, clip "ppclip", int "diameterY", int "diameterU", int "diameterV", float "sdevY", float "sdevU", float "sdevV", float "idevY", float "idevU", float "idevV", float "csY", float "csU", float "csV", bool "d2", int "kerns", int "kerni", int "restype", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vsTBilateral.dll")
        vsTBilateral(clip, ppclip, diameterY, diameterU, diameterV, sdevY, sdevU, sdevV, idevY, idevU, idevV, csY, csU, csV, d2, kerns, kerni, restype, y, u, v)
}