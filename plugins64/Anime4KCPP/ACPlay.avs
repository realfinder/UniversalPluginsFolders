# MT Mode 1,2,3 are all supported, set it to 1(MT_NICE_FILTER) for saving memory
SetFilterMTMode("Anime4KCPP", MT_NICE_FILTER)
SetFilterMTMode("FFAudioSource", 3)
SetFilterMTMode("FFVideoSource", 3)

LoadPlugin("D:\Temp\anime4k\AvsPmod\Anime4KCPP_AviSynthPlus.dll")

path = "D:\Temp\anime4k\p1.mkv" #Your video path here

A = FFAudioSource(path)
V = FFVideoSource(path).Anime4KCPP(GPUMode=true, zoomFactor=2, ACNet=true, HDN =true).Prefetch(12) #Set your thread number here

AudioDub(V, A)
