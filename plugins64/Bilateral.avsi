function Bilateral(clip clip, clip "ref", float "sigmaSY", float "sigmaSU", float "sigmaSV", float "sigmaRY", float "sigmaRU", float "sigmaRV", int "algorithmY", int "algorithmU", int "algorithmV", int "PBFICnumY", int "PBFICnumU", int "PBFICnumV", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Bilateral.dll")
        Bilateral(clip, ref, sigmaSY, sigmaSU, sigmaSV, sigmaRY, sigmaRU, sigmaRV, algorithmY, algorithmU, algorithmV, PBFICnumY, PBFICnumU, PBFICnumV, y, u, v)
}