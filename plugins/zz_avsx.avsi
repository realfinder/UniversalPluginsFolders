(VersionNumber() < 2.60) ? avs25x_A_SONY() : NOP()

function avs25x_A_SONY() {
LoadPlugin(AviSynthPluginsDir + "25/DGDecode.dll")
LoadPlugin(AviSynthPluginsDir + "25/mt_masktools-25.dll")
Import(AviSynthPluginsDir + "25/MT.avsi")
Import(AviSynthPluginsDir + "25/nnedi3.avsi")
Import(AviSynthPluginsDir + "25/ffms2_p25.avsi")
Import(AviSynthPluginsDir + "25/ffms2.avsi")
Import(AviSynthPluginsDir + "25/MedianBlur.avsi")
Import(AviSynthPluginsDir + "25/SmoothUV.avsi")
}

(VersionNumber() < 2.58) ? NOP() : avs258_A_SONY()

function avs258_A_SONY() {
Import(AviSynthPluginsDir + "25/258/auto_merge_order.avsi")
Import(AviSynthPluginsDir + "25/258/ContraSharpen_mod.avsi")
Import(AviSynthPluginsDir + "25/258/ContraSharpen_mod_16.avsi")
Import(AviSynthPluginsDir + "25/258/DecombUCF.avsi")
Import(AviSynthPluginsDir + "25/258/MCTDmod.avsi")
Import(AviSynthPluginsDir + "25/258/FlexibleMerge.avsi")
Import(AviSynthPluginsDir + "25/258/O16.avsi")
Import(AviSynthPluginsDir + "25/258/PulldownMerge.avsi")
#Import(AviSynthPluginsDir + "25/258/StackedNto16.avs")
}

!IsAvsPlus ? (VersionNumber() < 2.60) ? NOP() : AVS_2_6_A4_A_SONY() : AVS_p_A_SONY()

function AVS_2_6_A4_A_SONY() {
sisnonavsp = !IsAvsPlus
LoadPlugin(AviSynthPluginsDir + "26/Average.dll")
LoadPlugin(AviSynthPluginsDir + "26/aWarpSharpMT.dll")
sisnonavsp ? Import(AviSynthPluginsDir + "26/DirectShowSource.avsi") : Import(AviSynthPluginsDir + "avsplus/DirectShowSource.avsi")
LoadPlugin(AviSynthPluginsDir + "26/masktools2.dll")
LoadPlugin(AviSynthPluginsDir + "26/mvtools2.dll")
#!sisnonavsp ? LoadPlugin(AviSynthPluginsDir + "26/neo-DFTTest.dll") : nop()
LoadPlugin(AviSynthPluginsDir + "26/RT_Stats.dll")
LoadPlugin(AviSynthPluginsDir + "26/SangNom2.dll")
Import(AviSynthPluginsDir + "26/aWarpSharp4xx.avsi")
Import(AviSynthPluginsDir + "26/DebilinearM.avsi")
Import(AviSynthPluginsDir + "26/deblock.avsi")
!SI_IsWinXP ? Import(AviSynthPluginsDir + "26/ffms2.avsi") : nop()
SI_IsWinXP ? Import(AviSynthPluginsDir + "cplugin/ffms2_pc.avsi") : nop()
SI_IsWinXP ? Import(AviSynthPluginsDir + "cplugin/ffms2.avsi") : nop()
!SI_IsWinXP ? Import(AviSynthPluginsDir + "26/D2VSource.avsi") : nop()
Import(AviSynthPluginsDir + "26/edi_rpow2.avsi")
Import(AviSynthPluginsDir + "26/eedi3_resize16.avsi")
Import(AviSynthPluginsDir + "26/ffms2.avsi")
Import(AviSynthPluginsDir + "26/HaloBuster.avsi")
Import(AviSynthPluginsDir + "26/InpaintDelogo.avsi")
Import(AviSynthPluginsDir + "26/JincResizeNR.avsi")
#Import(AviSynthPluginsDir + "26/neo-f3kdb.avsi") #bug
#Import(AviSynthPluginsDir + "26/neo-fft3d.avsi")
Import(AviSynthPluginsDir + "26/nnchromaupsubsampling.avsi")
Import(AviSynthPluginsDir + "26/nnedi3.avsi")
Import(AviSynthPluginsDir + "26/nnedi3_resize16.avsi")
Import(AviSynthPluginsDir + "26/maa2.avsi")
Import(AviSynthPluginsDir + "26/MedianBlur2.avsi")
Import(AviSynthPluginsDir + "26/MiniDeen.avsi")
Import(AviSynthPluginsDir + "26/neo-vague-denoiser.avsi")
Import(AviSynthPluginsDir + "26/ResampleMT.avsi")
Import(AviSynthPluginsDir + "26/Resize8.avsi")
Import(AviSynthPluginsDir + "26/ResizeX.avsi")
Import(AviSynthPluginsDir + "26/Shader.avsi")
Import(AviSynthPluginsDir + "26/scaled444tonative.avsi")
Import(AviSynthPluginsDir + "26/SmoothUV.avsi")
Import(AviSynthPluginsDir + "26/SpotLess.avsi")
Import(AviSynthPluginsDir + "26/ssubsampling_convert.avsi")
Import(AviSynthPluginsDir + "26/TEMmod.avsi")
Import(AviSynthPluginsDir + "26/TMM2.avsi")
Import(AviSynthPluginsDir + "26/vsCnr2.avsi")
Import(AviSynthPluginsDir + "26/vsDeblockPP7.avsi")
Import(AviSynthPluginsDir + "26/vsDeGrainMedian.avsi")
Import(AviSynthPluginsDir + "26/vsMSharpen.avsi")
Import(AviSynthPluginsDir + "26/vsMSmooth.avsi")
Import(AviSynthPluginsDir + "26/vsTBilateral.avsi")
Import(AviSynthPluginsDir + "26/vsTEdgeMask.avsi")
Import(AviSynthPluginsDir + "26/vsTCanny.avsi")
Import(AviSynthPluginsDir + "26/vsTMM.avsi")
Import(AviSynthPluginsDir + "26/vsTTempSmooth.avsi")
Import(AviSynthPluginsDir + "26/yadifmod2.avsi")
Import(AviSynthPluginsDir + "26/Rainbow_smooth2.avsi")
Import(AviSynthPluginsDir + "26/YUY2toYV12i and YV12toYUY2i.avsi")
}

function AVS_p_A_SONY() {
LoadPlugin(AviSynthPluginsDir + "avsplus/ConvertStacked.dll")
LoadPlugin(AviSynthPluginsDir + "avsplus/ImageSeq.dll")
LoadPlugin(AviSynthPluginsDir + "avsplus/manyPlus.dll")
LoadPlugin(AviSynthPluginsDir + "avsplus/Shibatch.dll")
LoadPlugin(AviSynthPluginsDir + "avsplus/TimeStretch.dll")
LoadPlugin(AviSynthPluginsDir + "avsplus/VDubFilter.dll")
Import(AviSynthPluginsDir + "avsplus/eedi3_resize.avsi")
Import(AviSynthPluginsDir + "avsplus/HiAA.avsi")
Import(AviSynthPluginsDir + "avsplus/LUtils.avsi")
#Import(AviSynthPluginsDir + "avsplus/maa2+.avsi")
AVS_2_6_A4_A_SONY()
AvsPlusVersionNumber > 1576 ? AVS_P_MT_A_SONY() : nop()
}

function AVS_2_6_NB_A_SONY() {
LoadPlugin(AviSynthPluginsDir + "26/AutoLevels_0.9.dll")
LoadPlugin(AviSynthPluginsDir + "26/CombMask.dll")
LoadPlugin(AviSynthPluginsDir + "26/FFTQuiver.dll")
LoadPlugin(AviSynthPluginsDir + "26/JpegSource.dll") #make 2012.03.31 and 2012.04.03 and 2012.05.16 crash so load it manually if you need it
LoadPlugin(AviSynthPluginsDir + "26/DeJitter.dll")
LoadPlugin(AviSynthPluginsDir + "26/PlanarTools.dll")
LoadPlugin(AviSynthPluginsDir + "26/TCannyMod.dll")
LoadPlugin(AviSynthPluginsDir + "26/tcolormask.dll")
LoadPlugin(AviSynthPluginsDir + "26/tmaskcleaner.dll")
LoadPlugin(AviSynthPluginsDir + "26/xNLMeans.dll")
LoadPlugin(AviSynthPluginsDir + "26/YV12To422.dll")
}

function AVS_P_MT_A_SONY() {
!SI_IsWinXP ? Import(AviSynthPluginsDir + "avsplus/avsresize.avsi") : nop()
LoadPlugin(AviSynthPluginsDir + "avsplus/RawSourcePlus.dll")
AvsPlusVersionNumber > 2958 ? LoadPlugin(AviSynthPluginsDir + "26/GRunT_26.dll") : nop()
AvsPlusVersionNumber < 3276 ? nop() : import(AviSynthPluginsDir + "avsplus/vsLGhost.avsi")
Import(AviSynthPluginsDir + "avsplus/MtModes.avsi")
}

AvsPlusVersionNumber < 3382 ? nop() : Import(AviSynthPluginsDir + "avsplus/Utils-r41.avsi")
VersionNumber() < 2.60 ? Import(AviSynthPluginsDir + "25/QTGMC.avsi") : Import(AviSynthPluginsDir + "26/QTGMC.avsi")
AvsPlusVersionNumber < 3382 ? Import(AviSynthPluginsDir + "25/MasksPack.avsi") : Import(AviSynthPluginsDir + "avsplus/MasksPack.avsi")
AvsPlusVersionNumber < 3382 ? Import(AviSynthPluginsDir + "25/StabilizationToolsPack.avsi") : Import(AviSynthPluginsDir + "avsplus/Stabilization Tools Pack.avsi")
AvsPlusVersionNumber < 3382 ? Import(AviSynthPluginsDir + "25/GrainFactory3mod.avsi") : Import(AviSynthPluginsDir + "avsplus/GrainFactory3mod.avsi")
AvsPlusVersionNumber < 3382 ? Import(AviSynthPluginsDir + "25/LSFmod.avsi") : Import(AviSynthPluginsDir + "avsplus/LSFmod.avsi")
AvsPlusVersionNumber < 3382 ? Import(AviSynthPluginsDir + "25/stab.avsi") : nop()
AvsPlusVersionNumber < 3382 ? Import(AviSynthPluginsDir + "26/SmoothUV2.avsi") : Import(AviSynthPluginsDir + "avsplus/SmoothUV2.avsi")

function AVSTP_A_SONY() {
LoadPlugin(AviSynthPluginsDir + "25/258/avstp/avstp.dll")
}