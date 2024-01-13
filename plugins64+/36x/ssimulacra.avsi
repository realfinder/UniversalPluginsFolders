Function ssimulacra(clip reference, clip distorted, bool "simple", int "feature")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/ssimulacra.dll")
        ssimulacra(reference, distorted, simple, feature)
}