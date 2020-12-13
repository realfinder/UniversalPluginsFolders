(VersionNumber() < 2.60) ? avs25x_A_SONY() : NOP()

function avs25x_A_SONY() {
LoadPlugin(AviSynthPlugins64Dir + "25/DGDecode.dll")
Import(AviSynthPlugins64Dir + "25/MaskTools.avsi")
Import(AviSynthPlugins64Dir + "25/MT.avsi")
Import(AviSynthPlugins64Dir + "25/nnedi3.avsi")
Import(AviSynthPlugins64Dir + "25/ffms2_p25.avsi")
Import(AviSynthPlugins64Dir + "25/ffms2.avsi")
}

(VersionNumber() < 2.58) ? NOP() : avs25b64_A_SONY()

function avs25b64_A_SONY() {
s26 = VersionNumber() < 2.60 ? false : true
spl = IsAvsPlus
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
spl ? nop() : Import(AviSynthPlugins64Dir + "25/DirectshowSource.avsi")
s26 ? LoadPlugin(AviSynthPlugins64Dir + "26/masktools2.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/mt_masktools-25.dll")
Import(AviSynthPlugins64Dir + "25/25b/dither.avsi")
Import(AviSynthPlugins64Dir + "25/25b/MCTDmod.avsi")
Import(AviSynthPlugins64Dir + "25/25b/O16.avsi")
#Import(AviSynthPlugins64Dir + "25/25b/StackedNto16.avs")
}

!IsAvsPlus ? (VersionNumber() < 2.60) ? NOP() : AVS_2_6_64_A4_A_SONY() : AVS_p_64_A_SONY()

function AVS_2_6_64_A4_A_SONY() {
LoadPlugin(AviSynthPlugins64Dir + "26/Average.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/MedianBlur2.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/mvtools2.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/SangNom2.dll")
Import(AviSynthPlugins64Dir + "26/aWarpSharp4xx.avsi")
Import(AviSynthPlugins64Dir + "26/DebilinearM.avsi")
Import(AviSynthPlugins64Dir + "26/deblock.avsi")
Import(AviSynthPlugins64Dir + "26/edi_rpow2.avsi")
Import(AviSynthPlugins64Dir + "26/eedi3_resize16.avsi")
Import(AviSynthPlugins64Dir + "26/ffms2.avsi")
Import(AviSynthPlugins64Dir + "26/HaloBuster.avsi")
Import(AviSynthPlugins64Dir + "26/InpaintDelogo.avsi")
Import(AviSynthPlugins64Dir + "26/JincResizeNR.avsi")
#Import(AviSynthPlugins64Dir + "26/neo-f3kdb.avsi") #bug
#Import(AviSynthPlugins64Dir + "26/neo-fft3d.avsi")
Import(AviSynthPlugins64Dir + "26/neo-vague-denoiser.avsi")
Import(AviSynthPlugins64Dir + "26/nnchromaupsubsampling.avsi")
#Import(AviSynthPlugins64Dir + "26/nnedi3.avsi")
Import(AviSynthPlugins64Dir + "26/nnedi3_resize16.avsi")
Import(AviSynthPlugins64Dir + "26/maa2.avsi")
Import(AviSynthPlugins64Dir + "26/MedianBlur2.avsi")
Import(AviSynthPlugins64Dir + "26/MiniDeen.avsi")
Import(AviSynthPlugins64Dir + "26/MTCombMask.avsi")
LoadPlugin(AviSynthPlugins64Dir + "26/plugins_JPSDR.dll")
Import(AviSynthPlugins64Dir + "26/QTGMC.avsi")
Import(AviSynthPlugins64Dir + "26/TEMmod.avsi")
Import(AviSynthPlugins64Dir + "26/TMM2.avsi")
#Import(AviSynthPlugins64Dir + "26/ResampleMT.avsi")
Import(AviSynthPlugins64Dir + "26/Resize8.avsi")
Import(AviSynthPlugins64Dir + "26/ResizeX.avsi")
Import(AviSynthPlugins64Dir + "26/Shader.avsi")
Import(AviSynthPlugins64Dir + "26/scaled444tonative.avsi")
Import(AviSynthPlugins64Dir + "26/SpotLess.avsi")
Import(AviSynthPlugins64Dir + "26/ssubsampling_convert.avsi")
Import(AviSynthPlugins64Dir + "26/SmoothUV2.avsi")
Import(AviSynthPlugins64Dir + "26/vsMSharpen.avsi")
Import(AviSynthPlugins64Dir + "26/vsMSmooth.avsi")
Import(AviSynthPlugins64Dir + "26/vsTBilateral.avsi")
Import(AviSynthPlugins64Dir + "26/vsTMM.avsi")
Import(AviSynthPlugins64Dir + "26/vsTCanny.avsi")
Import(AviSynthPlugins64Dir + "26/vsTTempSmooth.avsi")
Import(AviSynthPlugins64Dir + "26/yadifmod2.avsi")
Import(AviSynthPlugins64Dir + "26/YUY2toYV12i and YV12toYUY2i.avsi")
}

function AVS_p_64_A_SONY() {
AVS_2_6_64_A4_A_SONY()
LoadPlugin(AviSynthPlugins64Dir + "26/GamMac.dll")
AvsPlusVersionNumber > 2958 ? LoadPlugin(AviSynthPlugins64Dir + "26/GrunT.dll") : nop()
#LoadPlugin(AviSynthPlugins64Dir + "26/neo-dfttest.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/TUnsharp.dll")
}

function AVS_2_6_64_NB_A_SONY() {
LoadPlugin(AviSynthPlugins64Dir + "26/avss.dll")
#LoadPlugin(AviSynthPlugins64Dir + "26/CLExpr.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/deflicker.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/delogo.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/MaskCrop.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/MatchHistogram.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/Median.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/Nirmalam.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/PlanarTools.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/PointSize.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/RemapFrames.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/RoboCrop.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/SCXvidMask.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/svpflow1.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/svpflow2.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/TCannyMod.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/tcolormask.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/tmaskcleaner.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/Watershed.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/waveform.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/xNLMeans.dll")
LoadPlugin(AviSynthPlugins64Dir + "26/YV12To422.dll")
#Import(AviSynthPlugins64Dir + "26/MaskCrop.avsi")
}

function AVSTP_A_SONY() {
LoadPlugin(AviSynthPlugins64Dir + "25/25b/avstp/avstp.dll")
}