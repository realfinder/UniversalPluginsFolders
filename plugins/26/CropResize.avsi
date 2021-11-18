# ===============================================================================
# ===============================================================================
# ========== CropResize 2021-10-22 ==============================================
# ===============================================================================
# ===============================================================================

function CropResize(clip Source, \
int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", int "CSplit", bool "CAlign", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", \
bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

C_R = " CropResize " + chr(10)
assert(HasVideo(Source) && (width(Source) > 48) && (height(Source) > 48), \
C_R + " No video found or the source width or height is too small " + chr(10))
SourceAudio = !HasAudio(Source) ? Source : Source.KillVideo()
Source = Source.KillAudio()

# ===============================================================================
# ========== Globals ============================================================
# ===============================================================================

Try{  IsG1Function = G1_GFunction  }catch(err){  IsG1Function = false  }
Try{  IsG2Function = G2_GFunction  }catch(err){  IsG2Function = false  }
Try{  IsPriorScript = gPriorScript  }catch(err){  IsPriorScript = false  }
Try{  IsGCPreview = (0 <= G_CPreview < 4)  }catch(err){  IsGCPreview = false  }
Try{  IsGInfo = G_Info  }catch(err){  IsGInfo = false  }
Try{  IsGResizer = defined(G_Resizer)  }catch(err){  IsGResizer = false  }
Try{  IsMX = CR_MeGUI_DAR() && !IsPriorScript && defined(MeGUI_darx)  }catch(err){  IsMX = false  }
Try{  IsMY = CR_MeGUI_DAR() && !IsPriorScript && defined(MeGUI_dary)  }catch(err){  IsMY = false  }
Try{  MInDAR = IsMX && IsMY ? float(MeGUI_darx) / float(MeGUI_dary) : 0.0  }catch(err){  MInDAR = 0.0  }
Try{  MPassDAR = CR_MeGUI_DAR() ? gMPassDAR : 0.0  }catch(err){  MPassDAR = 0.0  }

GMode = default(GMode, 1)

assert((0 <= GMode <= 2), C_R + " GMode must be 0, 1 or 2 (1 or 2 for GCropResize) " + chr(10))
assert((GMode != 2) || IsG2Function, C_R + " GMode can't equal 2 for CropResize unless " + \
chr(10) + " GMode=2 for a previous global GCropResize instance " + chr(10))

IsGMode0 = (GMode == 0)
IsGMode1 = (GMode == 1) && IsG1Function
IsGMode2 = (GMode == 2) && IsG2Function
NoGMode = IsGMode0 || !IsG1Function

GInDAR = NoGMode ? 0.0 : IsGMode1 ? G1_InDAR : G2_InDAR
GInSAR = NoGMode ? 0.0 : IsGMode1 ? G1_InSAR : G2_InSAR
GOutDAR = !IsG1Function ? 0.0 : !IsGMode2 ? G1_OutDAR : G2_OutDAR
GOutSAR = !IsG1Function ? 0.0 : !IsGMode2 ? G1_OutSAR : G2_OutSAR

Source_Width = \
IsGMode1 && G1_AutoC ? G1_Source_Width : IsGMode2 && G2_AutoC ? G2_Source_Width : width(Source)
F_Source_Width = float(Source_Width)
Source_Height = \
IsGMode1 && G1_AutoC ? G1_Source_Height : IsGMode2 && G2_AutoC ? G2_Source_Height : height(Source)
F_Source_Height = float(Source_Height)

# ===============================================================================
# ========== Defaults ===========================================================
# ===============================================================================

OutWidth = default(OutWidth, 0)
OutWidth = !IsG1Function || (OutWidth != 0) ? OutWidth : !IsGMode2 ? G1_OutWidth : G2_OutWidth
OutHeight = default(OutHeight, 0)
OutHeight = !IsG1Function || (OutHeight != 0) ? OutHeight : !IsGMode2 ? G1_OutHeight : G2_OutHeight

UseWidth = (OutWidth == -1)
TryWidth = (OutWidth < -1)
OutWidth = !UseWidth && !TryWidth ? OutWidth : UseWidth ? 0 : -OutWidth

UseHeight = (OutHeight == -1)
TryHeight = (OutHeight < -1)
OutHeight = !UseHeight && !TryHeight ? OutHeight : UseHeight ? 0 : -OutHeight

CL = default(CL, NoGMode ? 0.0 : IsGMode1 ? G1_CL : G2_CL)
CT = default(CT, NoGMode ? 0.0 : IsGMode1 ? G1_CT : G2_CT)
CR = default(CR, NoGMode ? 0.0 : IsGMode1 ? G1_CR : G2_CR)
CB = default(CB, NoGMode ? 0.0 : IsGMode1 ? G1_CB : G2_CB)

CR_Test = (CR <= 0) || ((CR > 0) && ((Source_Width - CL - CR) >= 0))
CB_Test = (CB <= 0) || ((CB > 0) && ((Source_Height - CT - CB) >= 0))
CR = (CR == 0) ? 0.0 : (CR < 0) ? -CR : Source_Width - CL - CR
CB = (CB == 0) ? 0.0 : (CB < 0) ? -CB : Source_Height - CT - CB

CropDAR = default(CropDAR, NoGMode ? 0.0 : IsGMode1 ? G1_CropDAR : G2_CropDAR)
CSplit = default(CSplit, NoGMode ? 1 : IsGMode1 ? G1_CSplit : G2_CSplit)
CAlign = default(CAlign, NoGMode ? false : IsGMode1 ? G1_CAlign : G2_CAlign)
AutoC = default(AutoC, false)
CThresh = default(CThresh, 30)
LastFrame = FrameCount(Source) - 1
ACStart = (LastFrame > 3000) ? 250 : 0
CStart = default(CStart, ACStart)
CSample = default(CSample, 5)

CPreview = default(CPreview, IsGCPreview ? G_CPreview : NoGMode ? 0 : \
IsGMode1 && (G1_CPreview != 4) ? G1_CPreview : IsGMode2 && (G2_CPreview != 4) ? G2_CPreview : 0)
CLine = default(CLine, !IsG1Function ? CR_CLine() : !IsGMode2 ? G1_CLine : G2_CLine)

IsInDAR = defined(InDAR)
IsInSAR = defined(InSAR)
IsOutDAR = defined(OutDAR)
IsOutSAR = defined(OutSAR)

InDAR = default(InDAR, 0.0)
InSAR = default(InSAR, 0.0)
OutDAR = default(OutDAR, 0.0)
OutSAR = default(OutSAR, 0.0)

AutoAspect = \
default(AutoAspect, !IsG1Function ? CR_AutoAspect() : !IsGMode2 ? G1_AutoAspect : G2_AutoAspect)

IsMod = defined(Mod)
Mod = default(Mod, !IsG1Function ? 4 : !IsGMode2 ? G1_Mod : G2_Mod)
F_Mod = float(Mod)
HMod = default(HMod, IsMod ? Mod : !IsG1Function ? Mod : !IsGMode2 ? G1_HMod : G2_HMod)
F_HMod = float(HMod)

NoResize = default(NoResize, NoGMode ? false : IsGMode1 ? G1_NoResize : G2_NoResize)
ResizeWO = default(ResizeWO, NoGMode ? false : IsGMode1 ? G1_ResizeWO : G2_ResizeWO)
Borders = default(Borders, NoGMode ? false : IsGMode1 ? G1_Borders : G2_Borders)
CleanBorders = default(CleanBorders, NoGMode ? false : IsGMode1 ? G1_CleanBorders : G2_CleanBorders)
BColor = default(BColor, NoGMode ? $000000 : IsGMode1 ? G1_BColor : G2_BColor)
Frosty = default(Frosty, NoGMode ? false : IsGMode1 ? G1_Frosty : G2_Frosty)

ColorCorrect = \
default(ColorCorrect, NoGMode ? CR_ColorCorrect() : IsGMode1 ? G1_ColorCorrect : G2_ColorCorrect)
ColorMode = default(ColorMode, NoGMode ? "" : IsGMode1 ? G1_ColorMode : G2_ColorMode)

IsResizer = defined(Resizer)
Resizer = default(Resizer, IsGResizer ? G_Resizer : \
!IsG1Function ? CR_ResizerDefault() : !IsGMode2 ? G1_Resizer : G2_Resizer)
RStr = default(RStr, IsResizer ? "" : IsGResizer ? \
G_RStr : !IsG1Function ? CR_RStrDefault() : !IsGMode2 ? G1_RStr : G2_RStr)

RMode = default(RMode, false)
PicDim = default(PicDim, !IsG1Function ? CR_InfoAutoPicDim() : !IsGMode2 ? G1_PicDim : G2_PicDim)
Position = default(Position, NoGMode ? false : IsGMode1 ? G1_Position : G2_Position)
Info = default(Info, IsGInfo ? G_Info : !IsG1Function ? false : !IsGMode2 ? G1_Info : G2_Info)

# ===============================================================================
# ========== Input & Output Aspect Ratios =======================================
# ===============================================================================

IsCropDAR = (CropDAR > 0)
IsGInDAR = (GInDAR > 0) && !IsInDAR && !IsInSAR
IsGInSAR = (GInSAR > 0) && !IsInDAR && !IsInSAR && !IsGInDAR
IsGOutDAR = (GOutDAR > 0) && !IsOutDAR && !IsOutSAR
IsGOutSAR = (GOutSAR > 0) && !IsOutDAR && !IsOutSAR && !IsGOutDAR
IsMInDAR = (MInDAR > 0) && !IsInDAR && !IsInSAR && !IsGInDAR && !IsGInSAR
IsMPassThru = (MPassDAR > 0) && !IsInDAR && !IsInSAR && !IsGInDAR && !IsGInSAR
IsMPassedThru = IsMPassThru && IsGMode1
IsInDAR = (InDAR > 0)
IsInSAR = (InSAR > 0) && !IsInDAR
IsOutDAR = (OutDAR > 0)
IsOutSAR = (OutSAR > 0) && !IsOutDAR

InputDAR = IsInDAR ? InDAR : IsGInDAR ? GInDAR : IsMInDAR ? MInDAR : IsMPassedThru ? MPassDAR : 0
InputSAR = IsInSAR ? InSAR : IsGInSAR ? GInSAR : 0
OutputDAR = IsOutDAR ? OutDAR : IsGOutDAR ? GOutDAR : 0
OutputSAR = IsOutSAR ? OutSAR : IsGOutSAR ? GOutSAR : 0

IsInputDAR = (InputDAR > 0)
IsInputSAR = (InputSAR > 0)
IsOutputDAR = (OutputDAR > 0)
IsOutputSAR = (OutputSAR > 0)

# ===============================================================================
# ========== Miscellaneous ======================================================
# ===============================================================================

AvsVerStrLC = LCase(VersionString())
IsAvsPlus = (FindStr(AvsVerStrLC, "avisynth+") > 0)
IsAvsNeo = (FindStr(AvsVerStrLC, "avisynth neo") > 0)
AvsStrNumA = IsAvsPlus || IsAvsNeo ? FindStr(AvsVerStrLC, "(r") + 2 : 0
AvsStrNumB = IsAvsPlus || IsAvsNeo ? FindStr(AvsVerStrLC, ",") : 0
AvsStrNumC = (AvsStrNumB > AvsStrNumA) ? AvsStrNumB - AvsStrNumA : undefined()
AvsBuildNum = (AvsStrNumA > 2) ? int(value(MidStr(AvsVerStrLC, AvsStrNumA, AvsStrNumC))) : 0
IsAvsHBD = (AvsBuildNum > 2294)
Source_Bits = IsAvsHBD ? BitsPerComponent(Source) : 8

IsRGBSource = IsRGB(Source)
Color_Format = PixelType(Source)
Chroma420 = IsAvsHBD ? Is420(Source) : IsYV12(Source)
Chroma422 = IsAvsHBD ? Is422(Source) : IsYV16(Source)
ModFourWidth = IsYV411(Source)
ModTwoWidth = Chroma420 || Chroma422 || IsYUY2(Source)
ModTwoHeight = Chroma420

CWMod = ModFourWidth ? 4 : ModTwoWidth ? 2 : 1
CHMod = ModTwoHeight ? 2 : 1
F_CWMod = float(CWMod)
F_CHMod = float(CHMod)

IsAutoCPreview = AutoC && (CPreview == 4)
IsCurrentGAutoC = (IsGMode1 && G1_AutoC) || (IsGMode2 && G2_AutoC)
IsCurrentGAutoCPreview = (IsGMode1 && (G1_CPreview == 4)) || (IsGMode2 && (G2_CPreview == 4))
IsScriptCPreview = (0 < CPreview < 4) && !IsCurrentGAutoCPreview

IsCMode = \
(ColorMode == "709-601") || (ColorMode == "601-709") || \
(ColorMode == "2020-709") || (ColorMode == "709-2020") || \
(ColorMode == "2020-601") || (ColorMode == "601-2020")
IsCMode_NTSC_PAL = \
(ColorMode == "709-601N") || (ColorMode == "601N-709") || \
(ColorMode == "2020-601N") || (ColorMode == "601N-2020") || \
(ColorMode == "709-601P") || (ColorMode == "601P-709") || \
(ColorMode == "2020-601P") || (ColorMode == "601P-2020") || \
(ColorMode == "601N-601P") || (ColorMode == "601P-601N")

IsAvsHBD ? Eval("""  IsMTResize=FunctionExists("Spline36ResizeMT" )  """) : \
Eval("""  try{ Test=Source.Spline36ResizeMT(640,480)  IsMTResize=true }catch(err){ IsMTResize=false }  """)

IsZ = (LeftStr(Resizer, 2) == "z_")

Resizer = IsZ ? ((Resizer == "") || (StrLen(Resizer) == 2) ? "Spline36" : RightStr(Resizer, StrLen(Resizer) - 2)) : \
(Resizer == "") ? \
((0 < ColorCorrect <= 2) ? "Spline36" : IsMTResize ? "Spline36ResizeMT" : "Spline36Resize") : Resizer

IsResizeMTAppended = (RightStr(Resizer, 8) == "ResizeMT") || (RightStr(Resizer, 8) == "MTResize")
IsMTAppended = (RightStr(Resizer, 2) == "MT")
IsResizeAppended = (RightStr(Resizer, 6) == "Resize")

Kernel = !IsZ && IsResizeMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 8) : \
!IsZ && IsMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 2) : \
IsResizeAppended ? LeftStr(Resizer, StrLen(Resizer) - 6) : Resizer

IsZ_Resizer = (Kernel == "Bicubic") || (Kernel == "Bilinear") || (Kernel == "Lanczos4") || (Kernel == "Lanczos") || \
(Kernel == "Point") || (Kernel == "Spline16") || (Kernel == "Spline36") || (Kernel == "Spline64")
IsAvsResizer = IsZ_Resizer || (Kernel == "Blackman") || (Kernel == "Gauss") || (Kernel == "Sinc")

IsZ = IsZ || ((0 < ColorCorrect <= 2) && IsZ_Resizer && !IsResizeMTAppended && !IsMTAppended)
Z_Taps = IsZ && (Kernel == "Lanczos4") ? 4 : undefined()

Resizer = IsZ ? ((Kernel == "Lanczos4") ? "Lanczos" : Kernel) : \
IsResizeMTAppended || IsMTAppended ? Kernel + "ResizeMT" : \
IsAvsResizer || IsResizeAppended ? Kernel + "Resize"  : Kernel

NoResizing = NoResize || CleanBorders
ResizeWO = ResizeWO && !NoResizing
FullResizing = !NoResizing && !ResizeWO
Bordered = Borders || CleanBorders || Frosty || ((ResizeWO || FullResizing) && (IsCropDAR && IsOutputDAR))

# ===============================================================================
# ========== Insist =============================================================
# ===============================================================================

# ---------- OutWidth & OutHeight -----------------------------------------------

assert((!UseWidth && !TryWidth) || (!UseHeight && !TryHeight), C_R + \
" OutWidth & OutHeight can't be negative at the same time " + chr(10))
assert((!UseWidth && !TryWidth && !UseHeight && !TryHeight) || FullResizing, C_R + \
" OutWidth & OutHeight can only be negative in full resizing mode " + chr(10))
assert((OutWidth == 0) || !ModTwoWidth || (OutWidth % 2 == 0), C_R + \
" " + Color_Format + " requires a mod2 OutWidth " + chr(10))
assert((OutWidth == 0) || !ModFourWidth || (OutWidth % 4 == 0), C_R + \
" " + Color_Format + " requires a mod4 OutWidth " + chr(10))
assert((OutHeight == 0) || !ModTwoHeight || (OutHeight % 2 == 0), C_R + \
" " + Color_Format + " requires a mod2 OutHeight " + chr(10))

# ---------- Crop ---------------------------------------------------------------

assert((CL >= 0) && (CT >= 0), C_R + " CL & CT must be greater than, or equal to zero " + chr(10))
assert(CR_Test, C_R + " When right cropping is positive " + chr(10) + \
" left plus right cropping can't exceed the source width " + chr(10))
assert(CB_Test, C_R + " When bottom cropping is positive " + chr(10) + \
" top plus bottom cropping can't exceed the source height " + chr(10))
assert((1 <= CSplit <= 3), C_R + " CSplit must be 1, 2 or 3 " + chr(10))

# ---------- AutoC --------------------------------------------------------------

assert(!AutoC || !IsCurrentGAutoC, C_R + " AutoC can't be true for CropResize when global " + chr(10) + \
" auto-cropping has been enabled via the GCropResize function " + chr(10))
assert(AutoC || (CPreview != 4), C_R + " AutoC must be true when CPreview=4 " + chr(10))
assert(!IsCurrentGAutoC || (((CThresh == 30) || \
((!IsGMode1 || (CThresh == G1_CThresh)) && (!IsGMode2 || (CThresh == G2_CThresh)))) && \
((CStart == ACStart) || ((!IsGMode1 || (CStart == G1_CStart)) && (!IsGMode2 || (CStart == G2_CStart)))) && \
((CSample == 5) || ((!IsGMode1 || (CSample == G1_CSample)) && (!IsGMode2 || (CSample == G2_CSample))))), \
C_R + " New auto-cropping options can't be specified for CropResize " + chr(10) + \
" when global auto-cropping is enabled " + chr(10))
assert(!AutoC || (CStart < LastFrame), C_R + \
" The first frame for AutoCrop to check is beyond the final frame " + chr(10) + \
string(CStart, " CStart = %.0f  ") + string(LastFrame, " The final frame number is %.0f ")+ chr(10))

# ---------- CThresh ------------------------------------------------------------

assert((1 <= CThresh <= 255), C_R + " CThresh must be 1 thru 255 " + chr(10))

# ---------- CPreview -----------------------------------------------------------

assert((0 <= CPreview <= 4) && (!IsGCPreview || (0 <= G_CPreview <= 4)), \
C_R + " CPreview must be 0 thru 4 " + chr(10))
assert((1 <= CR_CPreview() <= 3), C_R + " CR_CPreview() must be 1, 2 or 3 " + chr(10))
assert((CLine >= 1), C_R + " CLine must be greater than, or equal to 1 " + chr(10))

# ---------- CropDAR / InDAR / InSAR / OutDAR / OutSAR --------------------------

assert(((IsFloat(InDAR) && (InDAR == 0)) || (IsFloat(InDAR) && !IsInt(InDAR) && (InDAR > 0))) && \
((IsFloat(InSAR) && (InSAR == 0)) || (IsFloat(InSAR) && !IsInt(InSAR) && (InSAR > 0))) && \
((IsFloat(OutDAR) && (OutDAR == 0)) || (IsFloat(OutDAR) && !IsInt(OutDAR) && (OutDAR > 0))) && \
((IsFloat(OutSAR) && (OutSAR == 0)) || (IsFloat(OutSAR) && !IsInt(OutSAR) && (OutSAR > 0))) && \
((IsFloat(CropDAR) && (CropDAR == 0)) || (IsFloat(CropDAR) && !IsInt(CropDAR) && (CropDAR > 0))), \
C_R + " CropDAR, InDAR, InSAR, OutDAR & OutSAR " + chr(10) + \
" must be zero or a positive floating point number " + chr(10) + " (4.0/3.0 or 1.7778 etc) " + chr(10))
assert((InDAR == 0) || (InSAR == 0), C_R + " InDAR & InSAR can't be specified together " + chr(10))
assert((OutDAR == 0) || (OutSAR == 0), C_R + " OutDAR & OutSAR can't be specified together " + chr(10))

# ---------- Mod ----------------------------------------------------------------

assert((Mod == 1) || (Mod == 2) || (Mod == 4) || (Mod == 8) || (Mod == 16), \
C_R + " Mod must be 1, 2, 4, 8 or 16 " + chr(10))
assert((HMod == 1) || (HMod == 2) || (HMod == 4) || (HMod == 8) || (HMod == 16), \
C_R + " HMod must be 1, 2, 4, 8 or 16 " + chr(10))
assert(!ModTwoWidth || (Mod % 2 == 0), C_R + " " + Color_Format + " requires a minimum of Mod=2 " + chr(10))
assert(!ModFourWidth || (Mod % 4 == 0), C_R + " " + Color_Format + " requires a minimum of Mod=4 " + chr(10))
assert(!ModTwoHeight || (HMod % 2 == 0), C_R + \
" " + Color_Format + " requires a minimum of HMod=2 " + chr(10))

# ---------- NoResize / CleanBorders / ResizeWO ---------------------------------

assert(!NoResize || !ResizeWO, C_R + " NoResize & ResizeWO can't be true at the same time " + chr(10))
assert(!CleanBorders || !ResizeWO, C_R + " CleanBorders & ResizeWO can't be true at the same time " + chr(10))
assert((!NoResize && !CleanBorders) || \
((OutDAR == 0) && (OutSAR == 0) && (GOutDAR == 0) && (GOutSAR == 0)), C_R + \
" OutDAR/OutSAR can't be specified when " + chr(10) + " either NoResize or CleanBorders are true " + chr(10))
assert(!ResizeWO || (CropDAR == 0) || (((OutDAR == 0) || (OutDAR >= CropDAR)) && ((GOutDAR == 0) || \
(GOutDAR >= CropDAR))), C_R + " When ResizeWO=true & both OutDAR & CropDAR are specified " + \
chr(10) + " OutDAR must be greater than or equal to CropDAR " + chr(10))
assert(!ResizeWO || ((OutDAR == 0) && (GOutDAR == 0)) || (!Borders && !Frosty) || (CropDAR > 0), \
C_R + " When an OutDAR is specified & ResizeWO=true, " + chr(10) + \
" borders cannot be enabled unless a CropDAR is also specified " + chr(10))
assert(!ResizeWO || (!Borders && !Frosty) || (OutHeight == 0) || ((OutDAR == 0) && (GOutDAR == 0)), \
C_R + " When an OutDAR is specified, & both ResizeWO & Borders are true " + chr(10) + \
" OutHeight must be unspecified or equal to zero " + chr(10) + \
" (OutHeight can be specified with an OutSAR to add top/bottom borders) " + chr(10))

# ---------- ColorCorrect / ColorMode -------------------------------------------

assert((0 <= ColorCorrect <= 5), C_R + " ColorCorrect can only be 0 thru 5 " + chr(10))
assert((ColorMode == "") || IsCMode || IsCMode_NTSC_PAL, \
C_R + " ColorMode is not an allowed type or the format is incorrect " + chr(10))
assert(!IsCMode_NTSC_PAL || (ColorCorrect != 5), \
C_R + " When either 601N or 601P are specified as part of a " + chr(10) + \
" ColorMode color conversion, ColorCorrect cannot equal 5 " + chr(10))

# ---------- Resizer ------------------------------------------------------------

assert(!IsZ || IsZ_Resizer, C_R + " AVSResize has been specified for resizing (z_" + Resizer + ") " + \
chr(10) + " but not with a compatible resizer " + chr(10))

# ---------- PicDim -------------------------------------------------------------

assert((0 <= PicDim <= 255), C_R + " PicDim must be 0 thru 255 " + chr(10))

# ---------- MeGUI --------------------------------------------------------------

assert(!IsMX || (IsInt(MeGUI_darx) && (MeGUI_darx > 0)), \
C_R + " MeGUI_darx must be an integer greater than zero " + chr(10))
assert(!IsMY || (IsInt(MeGUI_dary) && (MeGUI_dary > 0)), \
C_R + " MeGUI_dary must be an integer greater than zero " + chr(10))
assert((IsMX == IsMY), C_R + " MeGUI_darx & MeGUI_dary must be specified together " + chr(10))

# ===============================================================================
# ========== Define Source ======================================================
# ===============================================================================

AutoC && !IsAutoCPreview && !IsCurrentGAutoC && !IsCurrentGAutoCPreview ? Eval("""

AutoCroppedSource = \
Source.autocrop(mode=0, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0)

""", "Define Source Eval") : Eval("  AutoCroppedSource = Source  ")

# ===============================================================================
# ========== General Widths, Heights & Aspect Ratios ============================
# ===============================================================================

AnamorphicInput = IsInputDAR || IsInputSAR
AnamorphicOutput = (NoResizing && AnamorphicInput) || (!NoResizing && (IsOutputDAR || IsOutputSAR))
IsAutoAspect = AutoAspect && FullResizing && !IsCropDAR && !IsOutputDAR && \
((Borders || Frosty) || !(OutWidth > 0 < OutHeight))

Auto_Cropped_Width = width(AutoCroppedSource)
F_Auto_Cropped_Width = float(Auto_Cropped_Width)
Auto_Cropped_Height = height(AutoCroppedSource)
F_Auto_Cropped_Height = float(Auto_Cropped_Height)

Auto_Cropped_StorageAR = F_Auto_Cropped_Width / F_Auto_Cropped_Height
Auto_Cropped_DAR = !AnamorphicInput ? Auto_Cropped_StorageAR : IsInputDAR ? \
F_Auto_Cropped_Width * F_Source_Height * InputDAR / F_Auto_Cropped_Height / F_Source_Width : \
F_Auto_Cropped_Width * InputSAR / F_Auto_Cropped_Height

Source_StorageAR = F_Source_Width / F_Source_Height
F_Source_Display_Width = \
!AnamorphicInput ? F_Source_Width : IsInputDAR ? InputDAR * F_Source_Height : F_Source_Width * InputSAR
Source_DAR = \
!AnamorphicInput ? Source_StorageAR : IsInputDAR ? InputDAR : F_Source_Width * InputSAR / F_Source_Height
Source_SAR = !AnamorphicInput ? 1.0 : IsInputDAR ? F_Source_Height * InputDAR / F_Source_Width : InputSAR

F_Cropped_Source_Width = F_Auto_Cropped_Width - CL - CR
F_Cropped_Source_Height = F_Auto_Cropped_Height - CT - CB

# ===============================================================================
# ========== No Resizing ========================================================
# ===============================================================================

NoResizing ? Eval("""

CM_WMod = !CleanBorders ? Mod : CWMod
CM_HMod = !CleanBorders ? HMod : CHMod
F_CM_WMod = !CleanBorders ? F_Mod : F_CWMod
F_CM_HMod = !CleanBorders ? F_HMod : F_CHMod
F_Half_CM_WMod = F_CM_WMod / 2.0
F_Half_CM_HMod = F_CM_HMod / 2.0

CM_Mod_Cropped_Width = floor(F_Cropped_Source_Width / F_CM_WMod) * CM_WMod
F_CM_Mod_Cropped_Width = float(CM_Mod_Cropped_Width)
CM_Mod_Cropped_Height = floor(F_Cropped_Source_Height / F_CM_HMod) * CM_HMod
F_CM_Mod_Cropped_Height = float(CM_Mod_Cropped_Height)

CM_Mod_Cropped_StorageAR = F_CM_Mod_Cropped_Width / F_CM_Mod_Cropped_Height
CM_Mod_Cropped_DAR = !AnamorphicInput ? CM_Mod_Cropped_StorageAR : IsInputDAR ? \
F_CM_Mod_Cropped_Width * F_Source_Height * InputDAR / F_CM_Mod_Cropped_Height / F_Source_Width : \
F_CM_Mod_Cropped_Width * InputSAR / F_CM_Mod_Cropped_Height

CM_Width = CM_Mod_Cropped_Width
F_CM_Width = F_CM_Mod_Cropped_Width
CM_Height = CM_Mod_Cropped_Height
F_CM_Height = F_CM_Mod_Cropped_Height

!IsCropDAR || (abs(CropDAR - CM_Mod_Cropped_DAR) < 0.000005) ? nop() : \
(CropDAR < CM_Mod_Cropped_DAR) ? Eval("

F_CM_Width = F_CM_Height * CropDAR / Source_SAR
F_CM_Width_Adjust = F_CM_Width - (floor(F_CM_Width / F_CM_WMod) * CM_WMod)
F_CM_Width_Adjust_Up = F_CM_Width + F_CM_WMod - F_CM_Width_Adjust
F_CM_Width_Adjust_Down = F_CM_Width - F_CM_Width_Adjust
F_CM_Width = (F_CM_Width_Adjust_Up > F_CM_Mod_Cropped_Width) ? F_CM_Width_Adjust_Down : \
(F_CM_Width_Adjust >= F_Half_CM_WMod) ? F_CM_Width_Adjust_Up : F_CM_Width_Adjust_Down
CM_Width = round(F_CM_Width)

") : Eval("

F_CM_Height = F_CM_Width / CropDAR * Source_SAR
F_CM_Height_Adjust = F_CM_Height - (floor(F_CM_Height / F_CM_HMod) * CM_HMod)
F_CM_Height_Adjust_Up = F_CM_Height + F_CM_HMod - F_CM_Height_Adjust
F_CM_Height_Adjust_Down = F_CM_Height - F_CM_Height_Adjust
F_CM_Height = (F_CM_Height_Adjust_Up > F_CM_Mod_Cropped_Height) ? F_CM_Height_Adjust_Down : \
(F_CM_Height_Adjust > F_Half_CM_HMod) ? F_CM_Height_Adjust_Up : F_CM_Height_Adjust_Down
CM_Height = round(F_CM_Height)

")

# ========== No Resizing - Cropping =============================================

F_CM_Extra_Width_Crop = \
F_CM_Mod_Cropped_Width - F_CM_Width + fmod(F_Cropped_Source_Width, CM_WMod)
F_CM_Extra_Height_Crop = \
F_CM_Mod_Cropped_Height - F_CM_Height + fmod(F_Cropped_Source_Height, CM_HMod)

CM_Extra_Crop_LR = max(0, F_CM_Extra_Width_Crop / 2.0)
CM_Extra_Crop_TB = max(0, (F_CM_Extra_Height_Crop) / 2.0)

CM_CSplit1_CL = round(CL + CM_Extra_Crop_LR - fmod(CL + CM_Extra_Crop_LR, CWMod))
CM_CSplit1_CR = round(CR + CM_Extra_Crop_LR - fmod(CR + CM_Extra_Crop_LR, CWMod))
CM_CSplit1_CT = round(CT + CM_Extra_Crop_TB - fmod(CT + CM_Extra_Crop_TB, CHMod))
CM_CSplit1_CB = round(CB + CM_Extra_Crop_TB - fmod(CB + CM_Extra_Crop_TB, CHMod))

CM_CSplit1_RCL = CL + CM_Extra_Crop_LR - CM_CSplit1_CL
CM_CSplit1_RCR = CR + CM_Extra_Crop_LR - CM_CSplit1_CR
CM_CSplit1_RCT = CT + CM_Extra_Crop_TB - CM_CSplit1_CT
CM_CSplit1_RCB = CB + CM_Extra_Crop_TB - CM_CSplit1_CB

CM_CSplit2_CL = round(CL - fmod(CL, CWMod))
CM_CSplit2_CR = round(CR - fmod(CR, CWMod))
CM_CSplit2_CT = round(CT - fmod(CT, CHMod))
CM_CSplit2_CB = round(CB - fmod(CB, CHMod))

CM_CSplit2_RCL = CL + CM_Extra_Crop_LR - CM_CSplit2_CL
CM_CSplit2_RCR = CR + CM_Extra_Crop_LR - CM_CSplit2_CR
CM_CSplit2_RCT = CT + CM_Extra_Crop_TB - CM_CSplit2_CT
CM_CSplit2_RCB = CB + CM_Extra_Crop_TB - CM_CSplit2_CB

CM_CSplit3_RCL = CL + CM_Extra_Crop_LR
CM_CSplit3_RCR = CR + CM_Extra_Crop_LR
CM_CSplit3_RCT = CT + CM_Extra_Crop_TB
CM_CSplit3_RCB = CB + CM_Extra_Crop_TB

CM_CL = max(0, (CSplit == 1) ? CM_CSplit1_CL : (CSplit == 2) ? CM_CSplit2_CL : 0)
CM_CR = max(0, (CSplit == 1) ? CM_CSplit1_CR : (CSplit == 2) ? CM_CSplit2_CR : 0)
CM_CT = max(0, (CSplit == 1) ? CM_CSplit1_CT : (CSplit == 2) ? CM_CSplit2_CT : 0)
CM_CB = max(0, (CSplit == 1) ? CM_CSplit1_CB : (CSplit == 2) ? CM_CSplit2_CB : 0)

CM_RCL = max(0, (CSplit == 1) ? CM_CSplit1_RCL : (CSplit == 2) ? CM_CSplit2_RCL : CM_CSplit3_RCL)
CM_RCR = max(0, (CSplit == 1) ? CM_CSplit1_RCR : (CSplit == 2) ? CM_CSplit2_RCR : CM_CSplit3_RCR)
CM_RCT = max(0, (CSplit == 1) ? CM_CSplit1_RCT : (CSplit == 2) ? CM_CSplit2_RCT : CM_CSplit3_RCT)
CM_RCB = max(0, (CSplit == 1) ? CM_CSplit1_RCB : (CSplit == 2) ? CM_CSplit2_RCB : CM_CSplit3_RCB)

CM_NoResizerCrop = (0 == CM_RCL == CM_RCR == CM_RCT == CM_RCB)

F_CM_Cropped_Width = F_Cropped_Source_Width - F_CM_Extra_Width_Crop
F_CM_Cropped_Height = F_Cropped_Source_Height - F_CM_Extra_Height_Crop

# ========== No Resizing - Cropped Aspect Ratios ================================

CM_Cropped_StorageAR = F_CM_Cropped_Width / F_CM_Cropped_Height
CM_Cropped_DAR = !AnamorphicInput ? CM_Mod_Cropped_StorageAR : IsInputDAR ? \
F_CM_Cropped_Width * F_Source_Height * InputDAR / F_CM_Cropped_Height / F_Source_Width : \
F_CM_Cropped_Width * InputSAR / F_CM_Cropped_Height

""", "No Resizing Eval") : ResizeWO ? Eval("""

# ===============================================================================
# ========== Resize Width Only ==================================================
# ===============================================================================

RW_Mod_Cropped_Width = floor(F_Cropped_Source_Width / F_Mod) * Mod
F_RW_Mod_Cropped_Width = float(RW_Mod_Cropped_Width)
RW_Mod_Cropped_Height = floor(F_Cropped_Source_Height / F_HMod) * HMod
F_RW_Mod_Cropped_Height = float(RW_Mod_Cropped_Height)

F_RW_Resized_Cropped_Width = !AnamorphicInput ? F_Cropped_Source_Width : \
IsInputDAR ? F_Cropped_Source_Width * F_Source_Height * InputDAR / F_Source_Width : \
F_Cropped_Source_Width * InputSAR

RW_Mod_Cropped_Resized_Width = floor(F_RW_Resized_Cropped_Width / F_Mod) * Mod
F_RW_Mod_Cropped_Resized_Width = float(RW_Mod_Cropped_Resized_Width)

RW_Resized_Cropped_DAR = F_RW_Resized_Cropped_Width / F_RW_Mod_Cropped_Height
RW_Resized_Mod_Cropped_DAR = F_RW_Mod_Cropped_Resized_Width / F_RW_Mod_Cropped_Height

RW_Resized_Width = (OutWidth == 0) ? RW_Mod_Cropped_Resized_Width : OutWidth
F_RW_Resized_Width = float(RW_Resized_Width)
RW_Resizing_DAR = IsCropDAR ? CropDAR : IsOutputDAR ? OutputDAR : RW_Resized_Mod_Cropped_DAR

RW_Height = (RW_Resizing_DAR <= RW_Resized_Cropped_DAR) || \
(abs(RW_Resizing_DAR - RW_Resized_Cropped_DAR) < 0.000005) ? RW_Mod_Cropped_Height : \
floor(F_RW_Resized_Cropped_Width / RW_Resizing_DAR / F_HMod) * HMod
F_RW_Height = float(RW_Height)

RW_Resizing_SAR = \
IsOutputDAR ? F_RW_Height * OutputDAR / F_RW_Resized_Width : IsOutputSAR ? OutputSAR : 1.0

F_RW_Aspect_Width = F_RW_Height * RW_Resizing_DAR / RW_Resizing_SAR
F_RW_Aspect_Width = (abs(F_RW_Aspect_Width - round(F_RW_Aspect_Width)) < 0.000005) && \
(round(F_RW_Aspect_Width) % CWMod == 0) ? float(round(F_RW_Aspect_Width)) : F_RW_Aspect_Width

F_RW_Width_Adjust = F_RW_Aspect_Width - (floor(F_RW_Aspect_Width / F_Mod) * Mod)
F_RW_Width_Up = F_RW_Aspect_Width + F_Mod - F_RW_Width_Adjust
F_RW_Width_Down = F_RW_Aspect_Width - F_RW_Width_Adjust
F_RW_Adjusted_Width = \
(F_RW_Width_Up > RW_Mod_Cropped_Resized_Width) ? F_RW_Width_Down : \
((F_RW_Width_Up - F_RW_Aspect_Width) < (F_Mod / 2.0)) ? F_RW_Width_Up : F_RW_Width_Down
RW_Adjusted_Width = round(F_RW_Adjusted_Width)

F_RW_Aspect_Width = \
IsOutputDAR ? (IsCropDAR ? F_RW_Adjusted_Width : F_RW_Aspect_Width) : F_RW_Adjusted_Width
RW_Resizing_Width = \
IsOutputDAR ? (IsCropDAR ? F_RW_Adjusted_Width : F_RW_Resized_Width) : F_RW_Aspect_Width
RW_Resizing_Width = round(RW_Resizing_Width)

# ========== Resize Width Only - Cropping =======================================

F_RW_Extra_Width_Crop = \
!AnamorphicInput ? F_Cropped_Source_Width - (F_RW_Aspect_Width * RW_Resizing_SAR) : \
IsInputDAR ? F_Cropped_Source_Width - \
(F_RW_Aspect_Width * RW_Resizing_SAR * F_Source_Width / InputDAR / F_Source_Height) : \
F_Cropped_Source_Width - (F_RW_Aspect_Width * RW_Resizing_SAR / InputSAR)

F_RW_Extra_Height_Crop = F_RW_Mod_Cropped_Height - F_RW_Height + fmod(F_Cropped_Source_Height, HMod)

RW_Extra_Crop_LR = max(0, F_RW_Extra_Width_Crop / 2.0)
RW_Extra_Crop_TB = max(0, (F_RW_Extra_Height_Crop) / 2.0)

RW_CSplit1_CL = round(CL + RW_Extra_Crop_LR - fmod(CL + RW_Extra_Crop_LR, CWMod))
RW_CSplit1_CR = round(CR + RW_Extra_Crop_LR - fmod(CR + RW_Extra_Crop_LR, CWMod))
RW_CSplit1_CT = round(CT + RW_Extra_Crop_TB - fmod(CT + RW_Extra_Crop_TB, CHMod))
RW_CSplit1_CB = round(CB + RW_Extra_Crop_TB - fmod(CB + RW_Extra_Crop_TB, CHMod))

RW_CSplit1_RCL = CL + RW_Extra_Crop_LR - RW_CSplit1_CL
RW_CSplit1_RCR = CR + RW_Extra_Crop_LR - RW_CSplit1_CR
RW_CSplit1_RCT = CT + RW_Extra_Crop_TB - RW_CSplit1_CT
RW_CSplit1_RCB = CB + RW_Extra_Crop_TB - RW_CSplit1_CB

RW_CSplit2_CL = round(CL - fmod(CL, CWMod))
RW_CSplit2_CR = round(CR - fmod(CR, CWMod))
RW_CSplit2_CT = round(CT - fmod(CT, CHMod))
RW_CSplit2_CB = round(CB - fmod(CB, CHMod))

RW_CSplit2_RCL = CL + RW_Extra_Crop_LR - RW_CSplit2_CL
RW_CSplit2_RCR = CR + RW_Extra_Crop_LR - RW_CSplit2_CR
RW_CSplit2_RCT = CT + RW_Extra_Crop_TB - RW_CSplit2_CT
RW_CSplit2_RCB = CB + RW_Extra_Crop_TB - RW_CSplit2_CB

RW_CSplit3_RCL = CL + RW_Extra_Crop_LR
RW_CSplit3_RCR = CR + RW_Extra_Crop_LR
RW_CSplit3_RCT = CT + RW_Extra_Crop_TB
RW_CSplit3_RCB = CB + RW_Extra_Crop_TB

RW_CL = max(0, (CSplit == 1) ? RW_CSplit1_CL : (CSplit == 2) ? RW_CSplit2_CL : 0)
RW_CR = max(0, (CSplit == 1) ? RW_CSplit1_CR : (CSplit == 2) ? RW_CSplit2_CR : 0)
RW_CT = max(0, (CSplit == 1) ? RW_CSplit1_CT : (CSplit == 2) ? RW_CSplit2_CT : 0)
RW_CB = max(0, (CSplit == 1) ? RW_CSplit1_CB : (CSplit == 2) ? RW_CSplit2_CB : 0)

RW_RCL = max(0, (CSplit == 1) ? RW_CSplit1_RCL : (CSplit == 2) ? RW_CSplit2_RCL : RW_CSplit3_RCL)
RW_RCR = max(0, (CSplit == 1) ? RW_CSplit1_RCR : (CSplit == 2) ? RW_CSplit2_RCR : RW_CSplit3_RCR)
RW_RCT = max(0, (CSplit == 1) ? RW_CSplit1_RCT : (CSplit == 2) ? RW_CSplit2_RCT : RW_CSplit3_RCT)
RW_RCB = max(0, (CSplit == 1) ? RW_CSplit1_RCB : (CSplit == 2) ? RW_CSplit2_RCB : RW_CSplit3_RCB)

F_RW_Cropped_Width = F_Cropped_Source_Width - F_RW_Extra_Width_Crop
F_RW_Cropped_Height = F_Cropped_Source_Height - F_RW_Extra_Height_Crop

# ========== Resize Width Only - Cropped Aspect Ratios ==========================

RW_Cropped_StorageAR = F_RW_Cropped_Width / F_RW_Cropped_Height
RW_Cropped_DAR = !AnamorphicInput ? RW_Cropped_StorageAR : \
IsInputDAR ? F_RW_Cropped_Width * F_Source_Height * InputDAR / F_RW_Cropped_Height / F_Source_Width : \
F_RW_Cropped_Width * InputSAR / F_RW_Cropped_Height

""", "Resize Width Only Eval") : FullResizing ? Eval("""

# ===============================================================================
# ========== Full Resizing Defaults =============================================
# ===============================================================================

Cropped_Source_StorageAR = F_Cropped_Source_Width / F_Cropped_Source_Height
Cropped_Source_DAR = !AnamorphicInput ? Cropped_Source_StorageAR : IsInputDAR ? \
F_Cropped_Source_Width * F_Source_Height * InputDAR / F_Cropped_Source_Height / F_Source_Width : \
F_Cropped_Source_Width * InputSAR / F_Cropped_Source_Height

F_Resized_Cropped_Width = !AnamorphicInput ? F_Cropped_Source_Width : \
IsInputDAR ? F_Cropped_Source_Width * F_Source_Height * InputDAR / F_Source_Width : \
F_Cropped_Source_Width * InputSAR
Mod_Cropped_Resized_Width = floor(F_Resized_Cropped_Width / F_Mod) * Mod
F_Mod_Cropped_Resized_Width = float(Mod_Cropped_Resized_Width)

Mod_Cropped_Width = floor(F_Cropped_Source_Width / F_Mod) * Mod
F_Mod_Cropped_Width = float(Mod_Cropped_Width)
Mod_Cropped_Height = floor(F_Cropped_Source_Height / F_HMod) * HMod
F_Mod_Cropped_Height = float(Mod_Cropped_Height)

UseWidth = UseWidth && ((Mod_Cropped_Width - F_Cropped_Source_Width) == 0)
UseHeight = UseHeight && ((Mod_Cropped_Height - F_Cropped_Source_Height) == 0)
TryWidth = TryWidth && ((Outwidth - F_Cropped_Source_Width) == 0)
TryHeight = TryHeight && ((OutHeight - F_Cropped_Source_Height) == 0)
KeepWidth = UseWidth || TryWidth
KeepHeight = UseHeight || TryHeight

OutWidth = UseWidth ? Mod_Cropped_Width : OutWidth
OutHeight = UseHeight ? Mod_Cropped_Height : OutHeight

Resizing_Width = (OutWidth > 0) ? OutWidth : Mod_Cropped_Resized_Width
F_Resizing_Width = (OutWidth > 0) ? float(OutWidth) : F_Mod_Cropped_Resized_Width
Resizing_Height = (OutHeight > 0) ? OutHeight : Mod_Cropped_Height
F_Resizing_Height = (OutHeight > 0) ? float(OutHeight) : F_Mod_Cropped_Height

Resizing_StorageAR = F_Resizing_Width / F_Resizing_Height
Resizing_DAR = IsOutputDAR && (Borders || Frosty) && !IsCropDAR ? Cropped_Source_DAR : \
IsCropDAR ? CropDAR : IsOutputDAR ? OutputDAR : Cropped_Source_DAR
Resizing_SAR = !AnamorphicOutput ? 1.0 : \
IsOutputDAR ? F_Resizing_Height * OutputDAR / F_Resizing_Width : OutputSAR

# ===============================================================================
# ========== AutoAspect =========================================================
# ===============================================================================

IsAutoAspect ? Eval("

IsAspect169 = (!Borders && !Frosty) ? (1.739 < Resizing_DAR < 1.829) : (1.777778 < Resizing_DAR < 1.829)
IsAspect43 = (!Borders && !Frosty) ? (1.27 < Resizing_DAR < 1.35) : (1.27 < Resizing_DAR < 1.333333)

H169 = !IsOutputSAR ? F_Resizing_Width * 9.0 / 16.0 : F_Resizing_Width * OutputSAR * 9.0 / 16.0
H43 = !IsOutputSAR ? F_Resizing_Width * 3.0 / 4.0 : F_Resizing_Width * OutputSAR * 3.0 / 4.0
W169 = !IsOutputSAR ? F_Resizing_Height * 16.0 / 9.0 : F_Resizing_Height * 16.0 / 9.0 / OutputSAR
W43 = !IsOutputSAR ? F_Resizing_Height * 4.0 / 3.0 : F_Resizing_Height * 4.0 / 3.0 / OutputSAR

IsHeight169Mod = (abs(round(H169) - H169) < 0.000005) && (round(H169) % CHMod == 0)
IsHeight43Mod = (abs(round(H43) - H43) < 0.000005) && (round(H43) % CHMod == 0)
IsWidth169Mod = (abs(round(W169) - W169) < 0.000005) && (round(W169) % CWMod == 0)
IsWidth43Mod = (abs(round(W43) - W43) < 0.000005) && (round(W43) % CWMod == 0)

Height169 = IsHeight169Mod ? round(H169) : H169
Height43 = IsHeight43Mod ? round(H43) : H43
Width169 = IsWidth169Mod ? round(W169) : W169
Width43 = IsWidth43Mod ? round(W43) : W43

IsHeight169 = IsAspect169 && IsHeight169Mod
IsHeight43 = IsAspect43 && IsHeight43Mod
IsWidth169 = IsAspect169 && IsWidth169Mod
IsWidth43 = IsAspect43 && IsWidth43Mod

") : Eval("  IsHeight169=false   IsHeight43=false   IsWidth169=false   IsWidth43=false  ")

# ===============================================================================
# ========== Full Resizing (A) Height Calculated From Width =====================
# ===============================================================================

F_CRA_Aspect_Height = F_Resizing_Width * Resizing_SAR / Resizing_DAR
F_CRA_Aspect_Height = (abs(F_CRA_Aspect_Height - round(F_CRA_Aspect_Height)) < 0.000005) && \
(round(F_CRA_Aspect_Height) % CHMod == 0) ? float(round(F_CRA_Aspect_Height)) : F_CRA_Aspect_Height

F_CRA_Height_Adjust = F_CRA_Aspect_Height - (floor(F_CRA_Aspect_Height / F_HMod) * HMod)
F_CRA_Height_Up = F_CRA_Aspect_Height + F_HMod - F_CRA_Height_Adjust
F_CRA_Height_Down = F_CRA_Aspect_Height - F_CRA_Height_Adjust
F_CRA_Adjusted_Height1 = KeepWidth ? F_CRA_Height_Down : \
((F_CRA_Height_Up - F_CRA_Aspect_Height) < (F_HMod / 2.0)) ? F_CRA_Height_Up : F_CRA_Height_Down
F_CRA_Adjusted_Height2 = IsHeight169 ? Height169 : IsHeight43 ? Height43 : F_CRA_Adjusted_Height1

F_CRA_Aspect_Height = IsOutputDAR && (Borders || Frosty) && !IsCropDAR ? \
((OutHeight == 0) ? F_Resizing_Height : F_CRA_Adjusted_Height1) : \
IsOutputDAR ? (IsCropDAR ? F_CRA_Adjusted_Height1 : F_CRA_Aspect_Height) : \
Borders || Frosty || (OutHeight == 0) ? F_CRA_Adjusted_Height2 : F_Resizing_Height

F_CRA_Resizing_Height = IsOutputDAR && (Borders || Frosty) && !IsCropDAR ? F_CRA_Aspect_Height : \
IsOutputDAR ? (IsCropDAR ? F_CRA_Adjusted_Height1 : F_Resizing_Height) : F_CRA_Aspect_Height
CRA_Resizing_Height = round(F_CRA_Resizing_Height)

CRA_Cropping_DAR = F_Resizing_Width * Resizing_SAR / F_CRA_Aspect_Height

F_CRA_Extra_Width_Crop = (abs(CRA_Cropping_DAR - Cropped_Source_DAR) < 0.000005) || \
(CRA_Cropping_DAR > Cropped_Source_DAR) ? 0.0 : \
!AnamorphicInput ? F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_Resizing_Width * Resizing_SAR / F_CRA_Aspect_Height) : \
IsInputDAR ? F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_Resizing_Width * \
F_Source_Width * Resizing_SAR / InputDAR / F_CRA_Aspect_Height / F_Source_Height) : \
F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_Resizing_Width * Resizing_SAR / F_CRA_Aspect_Height / InputSAR)

F_CRA_Extra_Height_Crop = (abs(CRA_Cropping_DAR - Cropped_Source_DAR) < 0.000005) || \
(CRA_Cropping_DAR < Cropped_Source_DAR) ? 0.0 : \
!AnamorphicInput ? F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_CRA_Aspect_Height / F_Resizing_Width / Resizing_SAR) : \
IsInputDAR ? F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_CRA_Aspect_Height * \
F_Source_Height * InputDAR / F_Resizing_Width / Resizing_SAR / F_Source_Width) : \
F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_CRA_Aspect_Height * InputSAR / F_Resizing_Width / Resizing_SAR)

# ========== Full Resizing (A) Cropping =========================================

CRA_Extra_Crop_LR = max(0, F_CRA_Extra_Width_Crop / 2.0)
CRA_Extra_Crop_TB = max(0, F_CRA_Extra_Height_Crop / 2.0)

CRA_CSplit1_Mod_CL = round(CL + CRA_Extra_Crop_LR - fmod(CL + CRA_Extra_Crop_LR, CWMod))
CRA_CSplit1_Mod_CR = round(CR + CRA_Extra_Crop_LR - fmod(CR + CRA_Extra_Crop_LR, CWMod))
CRA_CSplit1_Mod_CT = round(CT + CRA_Extra_Crop_TB - fmod(CT + CRA_Extra_Crop_TB, CHMod))
CRA_CSplit1_Mod_CB = round(CB + CRA_Extra_Crop_TB - fmod(CB + CRA_Extra_Crop_TB, CHMod))

CRA_CSplit1_Non_Mod_CL = CL + CRA_Extra_Crop_LR - CRA_CSplit1_Mod_CL
CRA_CSplit1_Non_Mod_CR = CR + CRA_Extra_Crop_LR - CRA_CSplit1_Mod_CR
CRA_CSplit1_Non_Mod_CT = CT + CRA_Extra_Crop_TB - CRA_CSplit1_Mod_CT
CRA_CSplit1_Non_Mod_CB = CB + CRA_Extra_Crop_TB - CRA_CSplit1_Mod_CB

CRA_CSplit2_Mod_CL = round(CL - fmod(CL, CWMod))
CRA_CSplit2_Mod_CR = round(CR - fmod(CR, CWMod))
CRA_CSplit2_Mod_CT = round(CT - fmod(CT, CHMod))
CRA_CSplit2_Mod_CB = round(CB - fmod(CB, CHMod))

CRA_CSplit2_Non_Mod_CL = CL + CRA_Extra_Crop_LR - CRA_CSplit2_Mod_CL
CRA_CSplit2_Non_Mod_CR = CR + CRA_Extra_Crop_LR - CRA_CSplit2_Mod_CR
CRA_CSplit2_Non_Mod_CT = CT + CRA_Extra_Crop_TB - CRA_CSplit2_Mod_CT
CRA_CSplit2_Non_Mod_CB = CB + CRA_Extra_Crop_TB - CRA_CSplit2_Mod_CB

CRA_CSplit3_CL = CL + CRA_Extra_Crop_LR
CRA_CSplit3_CR = CR + CRA_Extra_Crop_LR
CRA_CSplit3_CT = CT + CRA_Extra_Crop_TB
CRA_CSplit3_CB = CB + CRA_Extra_Crop_TB

CRA_CL = max(0, (CSplit == 1) ? CRA_CSplit1_Mod_CL : (CSplit == 2) ? CRA_CSplit2_Mod_CL : 0)
CRA_CR = max(0, (CSplit == 1) ? CRA_CSplit1_Mod_CR : (CSplit == 2) ? CRA_CSplit2_Mod_CR : 0)
CRA_CT = max(0, (CSplit == 1) ? CRA_CSplit1_Mod_CT : (CSplit == 2) ? CRA_CSplit2_Mod_CT : 0)
CRA_CB = max(0, (CSplit == 1) ? CRA_CSplit1_Mod_CB : (CSplit == 2) ? CRA_CSplit2_Mod_CB : 0)

CRA_RCL = \
max(0, (CSplit == 1) ? CRA_CSplit1_Non_Mod_CL : (CSplit == 2) ? CRA_CSplit2_Non_Mod_CL : CRA_CSplit3_CL)
CRA_RCR = \
max(0, (CSplit == 1) ? CRA_CSplit1_Non_Mod_CR : (CSplit == 2) ? CRA_CSplit2_Non_Mod_CR : CRA_CSplit3_CR)
CRA_RCT = \
max(0, (CSplit == 1) ? CRA_CSplit1_Non_Mod_CT : (CSplit == 2) ? CRA_CSplit2_Non_Mod_CT : CRA_CSplit3_CT)
CRA_RCB = \
max(0, (CSplit == 1) ? CRA_CSplit1_Non_Mod_CB : (CSplit == 2) ? CRA_CSplit2_Non_Mod_CB : CRA_CSplit3_CB)

F_CRA_Cropped_Width = F_Cropped_Source_Width - F_CRA_Extra_Width_Crop
F_CRA_Cropped_Height = F_Cropped_Source_Height - F_CRA_Extra_Height_Crop

# ========== Full Resizing (A) Cropped Aspect Ratios ============================

CRA_Cropped_StorageAR = F_CRA_Cropped_Width / F_CRA_Cropped_Height
CRA_Cropped_DAR = !AnamorphicInput ? CRA_Cropped_StorageAR : IsInputDAR ? \
F_CRA_Cropped_Width * F_Source_Height * InputDAR / F_CRA_Cropped_Height / F_Source_Width : \
F_CRA_Cropped_Width * InputSAR / F_CRA_Cropped_Height

# ===============================================================================
# ========== Full Resizing (B) Width Calculated From Height =====================
# ===============================================================================

F_CRB_Aspect_Width = F_Resizing_Height * Resizing_DAR / Resizing_SAR
F_CRB_Aspect_Width = (abs(F_CRB_Aspect_Width - round(F_CRB_Aspect_Width)) < 0.000005) && \
(round(F_CRB_Aspect_Width) % CWMod == 0) ? float(round(F_CRB_Aspect_Width)) : F_CRB_Aspect_Width

F_CRB_Width_Adjust = F_CRB_Aspect_Width - (floor(F_CRB_Aspect_Width / F_Mod) * Mod)
F_CRB_Width_Up = F_CRB_Aspect_Width + Mod - F_CRB_Width_Adjust
F_CRB_Width_Down = F_CRB_Aspect_Width - F_CRB_Width_Adjust
F_CRB_Adjusted_Width1 = KeepHeight ? F_CRB_Width_Down : \
((F_CRB_Width_Up - F_CRB_Aspect_Width) < (F_Mod / 2.0)) ? F_CRB_Width_Up : F_CRB_Width_Down
F_CRB_Adjusted_Width2 = IsWidth169 ? Width169 : IsWidth43 ? Width43 : F_CRB_Adjusted_Width1

F_CRB_Aspect_Width = IsOutputDAR && (Borders || Frosty) && !IsCropDAR ? \
((OutWidth == 0) ? F_Resizing_Width : F_CRB_Adjusted_Width1) : \
IsOutputDAR ? (IsCropDAR ? F_CRB_Adjusted_Width1 : F_CRB_Aspect_Width) : \
Borders || Frosty || (OutWidth == 0) ? F_CRB_Adjusted_Width2 : F_Resizing_Width

F_CRB_Resizing_Width = IsOutputDAR && (Borders || Frosty) && !IsCropDAR ? F_CRB_Aspect_Width : \
IsOutputDAR ? (IsCropDAR ? F_CRB_Adjusted_Width1 : F_Resizing_Width) : F_CRB_Aspect_Width
CRB_Resizing_Width = round(F_CRB_Resizing_Width)

CRB_Cropping_DAR = F_CRB_Aspect_Width * Resizing_SAR / F_Resizing_Height

F_CRB_Extra_Width_Crop = (abs(CRB_Cropping_DAR - Cropped_Source_DAR) < 0.000005) || \
(CRB_Cropping_DAR > Cropped_Source_DAR) ? 0.0 : \
!AnamorphicInput ? F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_CRB_Aspect_Width * Resizing_SAR / F_Resizing_Height) : \
IsInputDAR ? F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_CRB_Aspect_Width * \
Resizing_SAR * F_Source_Width / InputDAR / F_Resizing_Height / F_Source_Height) : \
F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_CRB_Aspect_Width * Resizing_SAR / F_Resizing_Height / InputSAR)

F_CRB_Extra_Height_Crop = (abs(CRB_Cropping_DAR - Cropped_Source_DAR) < 0.000005) || \
(CRB_Cropping_DAR < Cropped_Source_DAR) ? 0.0 : \
!AnamorphicInput ? F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_Resizing_Height / F_CRB_Aspect_Width / Resizing_SAR) : \
IsInputDAR ? F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_Resizing_Height * \
F_Source_Height * InputDAR / F_CRB_Aspect_Width / Resizing_SAR / F_Source_Width) : \
F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_Resizing_Height * InputSAR / F_CRB_Aspect_Width / Resizing_SAR)

# ========== Full Resizing (B) Cropping =========================================

CRB_Extra_Crop_LR = max(0, F_CRB_Extra_Width_Crop / 2.0)
CRB_Extra_Crop_TB = max(0, F_CRB_Extra_Height_Crop / 2.0)

CRB_CSplit1_Mod_CL = round(CL + CRB_Extra_Crop_LR - fmod(CL + CRB_Extra_Crop_LR, CWMod))
CRB_CSplit1_Mod_CR = round(CR + CRB_Extra_Crop_LR - fmod(CR + CRB_Extra_Crop_LR, CWMod))
CRB_CSplit1_Mod_CT = round(CT + CRB_Extra_Crop_TB - fmod(CT + CRB_Extra_Crop_TB, CHMod))
CRB_CSplit1_Mod_CB = round(CB + CRB_Extra_Crop_TB - fmod(CB + CRB_Extra_Crop_TB, CHMod))

CRB_CSplit1_Non_Mod_CL = CL + CRB_Extra_Crop_LR - CRB_CSplit1_Mod_CL
CRB_CSplit1_Non_Mod_CR = CR + CRB_Extra_Crop_LR - CRB_CSplit1_Mod_CR
CRB_CSplit1_Non_Mod_CT = CT + CRB_Extra_Crop_TB - CRB_CSplit1_Mod_CT
CRB_CSplit1_Non_Mod_CB = CB + CRB_Extra_Crop_TB - CRB_CSplit1_Mod_CB

CRB_CSplit2_Mod_CL = round(CL - fmod(CL, CWMod))
CRB_CSplit2_Mod_CR = round(CR - fmod(CR, CWMod))
CRB_CSplit2_Mod_CT = round(CT - fmod(CT, CHMod))
CRB_CSplit2_Mod_CB = round(CB - fmod(CB, CHMod))

CRB_CSplit2_Non_Mod_CL = CL + CRB_Extra_Crop_LR - CRB_CSplit2_Mod_CL
CRB_CSplit2_Non_Mod_CR = CR + CRB_Extra_Crop_LR - CRB_CSplit2_Mod_CR
CRB_CSplit2_Non_Mod_CT = CT + CRB_Extra_Crop_TB - CRB_CSplit2_Mod_CT
CRB_CSplit2_Non_Mod_CB = CB + CRB_Extra_Crop_TB - CRB_CSplit2_Mod_CB

CRB_CSplit3_CL = CL + CRB_Extra_Crop_LR
CRB_CSplit3_CR = CR + CRB_Extra_Crop_LR
CRB_CSplit3_CT = CT + CRB_Extra_Crop_TB
CRB_CSplit3_CB = CB + CRB_Extra_Crop_TB

CRB_CL = max(0, (CSplit == 1) ? CRB_CSplit1_Mod_CL : (CSplit == 2) ? CRB_CSplit2_Mod_CL : 0)
CRB_CR = max(0, (CSplit == 1) ? CRB_CSplit1_Mod_CR : (CSplit == 2) ? CRB_CSplit2_Mod_CR : 0)
CRB_CT = max(0, (CSplit == 1) ? CRB_CSplit1_Mod_CT : (CSplit == 2) ? CRB_CSplit2_Mod_CT : 0)
CRB_CB = max(0, (CSplit == 1) ? CRB_CSplit1_Mod_CB : (CSplit == 2) ? CRB_CSplit2_Mod_CB : 0)

CRB_RCL = \
max(0, (CSplit == 1) ? CRB_CSplit1_Non_Mod_CL : (CSplit == 2) ? CRB_CSplit2_Non_Mod_CL : CRB_CSplit3_CL)
CRB_RCR = \
max(0, (CSplit == 1) ? CRB_CSplit1_Non_Mod_CR : (CSplit == 2) ? CRB_CSplit2_Non_Mod_CR : CRB_CSplit3_CR)
CRB_RCT = \
max(0, (CSplit == 1) ? CRB_CSplit1_Non_Mod_CT : (CSplit == 2) ? CRB_CSplit2_Non_Mod_CT : CRB_CSplit3_CT)
CRB_RCB = \
max(0, (CSplit == 1) ? CRB_CSplit1_Non_Mod_CB : (CSplit == 2) ? CRB_CSplit2_Non_Mod_CB : CRB_CSplit3_CB)

F_CRB_Cropped_Width = F_Cropped_Source_Width - F_CRB_Extra_Width_Crop
F_CRB_Cropped_Height = F_Cropped_Source_Height - F_CRB_Extra_Height_Crop

# ========== Full Resizing (B) Cropped Aspect Ratios ============================

CRB_Cropped_StorageAR = F_CRB_Cropped_Width / F_CRB_Cropped_Height
CRB_Cropped_DAR = !AnamorphicInput ? CRB_Cropped_StorageAR : IsInputDAR ? \
F_CRB_Cropped_Width * F_Source_Height * InputDAR / F_CRB_Cropped_Height / F_Source_Width : \
F_CRB_Cropped_Width * InputSAR / F_CRB_Cropped_Height

""", "Full Resizing Eval") : nop()

# ===============================================================================
# ========== Choose The Resizing Mode ===========================================
# ===============================================================================

CRType = NoResizing || ResizeWO ? "" : \
Bordered && (OutWidth > 0 < OutHeight) ? \
((Resizing_DAR > (Resizing_StorageAR * Resizing_SAR)) ? "CRA" : "CRB") : \
(OutWidth > 0 == OutHeight) ? "CRA" : "CRB"

# ===============================================================================
# ========== Output Width, Height & Aspect Ratios ===============================
# ===============================================================================

CRVideo_Width = NoResizing ? CM_Width : ResizeWO ? RW_Resizing_Width : \
(CRType == "CRA") ? Resizing_Width : CRB_Resizing_Width
F_CRVideo_Width = float(CRVideo_Width)
CRVideo_Height = NoResizing ? CM_Height : ResizeWO ? RW_Height : \
(CRType == "CRA") ? CRA_Resizing_Height : Resizing_Height
F_CRVideo_Height = float(CRVideo_Height)

CRVideo_StorageAR = F_CRVideo_Width / F_CRVideo_Height
CRVideo_DAR = NoResizing && !AnamorphicInput ? CRVideo_StorageAR : \
NoResizing && AnamorphicInput ? \
(IsInputDAR ? F_CRVideo_Width * F_Source_Height * InputDAR / F_CRVideo_Height / F_Source_Width : \
F_CRVideo_Width * Source_SAR / F_CRVideo_Height) : \
!AnamorphicOutput ? CRVideo_StorageAR : \
ResizeWO ? F_CRVideo_Width * RW_Resizing_SAR / F_CRVideo_Height : \
F_CRVideo_Width * Resizing_SAR / F_CRVideo_Height

Final_Width = CleanBorders ? Source_Width : \
Bordered && (OutWidth > CRVideo_Width) && (NoResizing || ResizeWO) ? OutWidth : \
Bordered && FullResizing && (OutWidth > CRVideo_Width) && (Resizing_StorageAR > CRVideo_StorageAR) ? \
OutWidth : CRVideo_Width
F_Final_Width = float(Final_Width)
Final_Height = CleanBorders ? Source_Height : \
Bordered && (OutHeight > CRVideo_Height) && (NoResizing || (ResizeWO && !IsOutputDAR)) ? OutHeight : \
Bordered && FullResizing && (OutHeight > CRVideo_Height) && (Resizing_StorageAR < CRVideo_StorageAR) ? \
OutHeight : CRVideo_Height
F_Final_Height = float(Final_Height)

Final_StorageAR = F_Final_Width / F_Final_Height
Final_DAR = NoResizing && !AnamorphicInput ? Final_StorageAR : \
NoResizing && AnamorphicInput ? \
(IsInputDAR ? F_Final_Width * F_Source_Height * InputDAR / F_Final_Height / F_Source_Width : \
F_Final_Width * Source_SAR / F_Final_Height) : \
!AnamorphicOutput ? Final_StorageAR : \
ResizeWO ? F_Final_Width * RW_Resizing_SAR / F_Final_Height : \
F_Final_Width * Resizing_SAR / F_Final_Height

IsAnamorphicInput = AnamorphicInput && (abs(Source_DAR - Source_StorageAR) > 0.000005)
IsAnamorphicOutput = AnamorphicOutput && (abs(Final_DAR - Final_StorageAR) > 0.000005)

F_Final_Display_Width = !IsAnamorphicOutput ? F_Final_Width : NoResizing ? F_Final_Width * Source_SAR : \
ResizeWO ? F_Final_Width * RW_Resizing_SAR : F_Final_Width * Resizing_SAR
Final_SAR = !IsAnamorphicOutput ? 1.0 : NoResizing ? Source_SAR : ResizeWO ? RW_Resizing_SAR : Resizing_SAR

# ===============================================================================
# ========== Color Conversion ===================================================
# ===============================================================================

(ColorCorrect != 0) || (ColorMode != "") ? Eval("""

IsSDSource = (F_Source_Display_Width <= 1056) && (Source_Height < 600)
IsHDSource = ((F_Source_Display_Width > 1056) || (Source_Height >= 600)) && \
((F_Source_Display_Width <= 1920) && (Source_Height <= 1080))
IsUHDSource = (F_Source_Display_Width > 1920) || (Source_Height > 1080)

IsSDOut = (F_Final_Display_Width <= 1056) && (Final_Height < 600)
IsHDOut = ((F_Final_Display_Width > 1056) || (Final_Height >= 600)) && \
((F_Final_Display_Width <= 1920) && (Final_Height <= 1080))
IsUHDOut = (F_Final_Display_Width > 1920) || (Final_Height > 1080)

CCorrect = (ColorCorrect != 0) ? ColorCorrect : IsZ ? 2 : \
((ColorMode == "709-601") || (ColorMode == "601-709")) && !IsRGBSource ? 5 : \
(ColorMode != "") ? 4 : 0

CMode = IsY8(Source) || (IsAvsHBD && IsY(Source)) ? "" : \
(ColorMode != "") ? ColorMode : \
!FullResizing || IsRGBSource ? "" : \
IsHDSource && IsSDOut ? "709-601" : \
IsUHDSource && IsHDOut ? "2020-709" : \
IsUHDSource && IsSDOut ? "2020-601" : \
IsSDSource && IsHDOut ? "601-709" : \
IsHDSource && IsUHDOut ? "709-2020" : \
IsSDSource && IsUHDOut ? "601-2020" : ""

IsCConversion = (CCorrect != 0) && (CMode != "")

""", "Color Conversion Eval") : Eval("  CCorrect=ColorCorrect   CMode=ColorMode   IsCConversion=false  ")

# ===============================================================================
# ========== Crop & Resize ======================================================
# ===============================================================================

ResStr = (RStr == "") ? RStr : ", " + RStr

ResizeW = NoResizing ? CM_Width : ResizeWO ? RW_Resizing_Width : \
(CRType == "CRA") ? Resizing_Width : CRB_Resizing_Width
ResizeH = NoResizing ? CM_Height : ResizeWO ? RW_Height : \
(CRType == "CRA") ? CRA_Resizing_Height : Resizing_Height

Upscale = ((float(ResizeW) * float(ResizeH) / F_Source_Width / F_Source_Height) > 1)
NoResizing_NoResizer = NoResizing && CM_NoResizerCrop

CCL = NoResizing ? CM_CL : ResizeWO ? RW_CL : (CRType == "CRA") ? CRA_CL : CRB_CL
CCT = NoResizing ? CM_CT : ResizeWO ? RW_CT : (CRType == "CRA") ? CRA_CT : CRB_CT
CCR = NoResizing ? CM_CR : ResizeWO ? RW_CR : (CRType == "CRA") ? CRA_CR : CRB_CR
CCB = NoResizing ? CM_CB : ResizeWO ? RW_CB : (CRType == "CRA") ? CRA_CB : CRB_CB
RCL = NoResizing ? CM_RCL : ResizeWO ? RW_RCL : (CRType == "CRA") ? CRA_RCL : CRB_RCL
RCT = NoResizing ? CM_RCT : ResizeWO ? RW_RCT : (CRType == "CRA") ? CRA_RCT : CRB_RCT
RCR = NoResizing ? CM_RCR : ResizeWO ? RW_RCR : (CRType == "CRA") ? CRA_RCR : CRB_RCR
RCB = NoResizing ? CM_RCB : ResizeWO ? RW_RCB : (CRType == "CRA") ? CRA_RCB : CRB_RCB

Cropped = (0 == CCL == CCT == CCR == CCB) ? AutoCroppedSource : \
IsAvsHBD ? AutoCroppedSource.crop(CCL, CCT, -CCR, -CCB) : \
AutoCroppedSource.crop(CCL, CCT, -CCR, -CCB, align=CAlign)

CRVideo = NoResizing_NoResizer && !IsCConversion ? Cropped : \
!IsZ && !IsCConversion ? Eval("Cropped." + Resizer + \
"(ResizeW, ResizeH, src_left=RCL, src_top=RCT, src_width=-RCR, src_height=-RCB" + ResStr +")") : \
!IsCConversion ? Eval("Cropped.z_ConvertFormat(ResizeW, ResizeH, src_left=RCL, src_top=RCT, \
src_width=-RCR, src_height=-RCB, resample_filter=Resizer, filter_param_a=Z_Taps" + ResStr +")") : \
Cropped.CR_ColorConvertResize(ResizeW, ResizeH, RCL, RCT, -RCR, -RCB, CCorrect, CMode, \
IsRGBSource, IsAvsHBD, Source_Bits, NoResizing_NoResizer, Upscale, Resizer, ResStr, IsZ, Z_Taps)

# ===============================================================================
# ========== Add Borders As Required ============================================
# ===============================================================================

IsBordered = Bordered && ((Final_Width > CRVideo_Width) || (Final_Height > CRVideo_Height))
ShowBorderInfo = Borders || CleanBorders || IsBordered

IsBordered ? Eval("""

WidthBorders = Final_Width - CRVideo_Width
EvenWidthSplit = WidthBorders % (CWMod * 2) == 0
F_WidthSplit = float(WidthBorders) / 2.0
BL_Adjust = F_WidthSplit - (floor(F_WidthSplit / F_CWMod) * CWMod)
BL_Adjust_Up = min(WidthBorders, round(F_WidthSplit + CWMod - BL_Adjust))
BL_Adjust_Down = round(F_WidthSplit - BL_Adjust)
BL = EvenWidthSplit ? WidthBorders / 2 : CroppedMoreLeft ? BL_Adjust_Up : BL_Adjust_Down
BR = WidthBorders - BL

HeightBorders = Final_Height - CRVideo_Height
EvenHeightSplit = HeightBorders % (CHMod * 2) == 0
F_HeightSplit = float(HeightBorders) / 2.0
BT_Adjust = F_HeightSplit - (floor(F_HeightSplit / F_CHMod) * CHMod)
BT_Adjust_Up = min(HeightBorders, round(F_HeightSplit + CHMod - BT_Adjust))
BT_Adjust_Down = round(F_HeightSplit - BT_Adjust)
BT = EvenHeightSplit ? HeightBorders / 2 : CroppedMoreTop ? BT_Adjust_Up : BT_Adjust_Down
BB = HeightBorders - BT

Greater = (Final_StorageAR >= CRVideo_StorageAR)
FBL = Greater ? BL : 0
FBT = Greater ? 0 : BT
FBR = Greater ? BR : 0
FBB = Greater ? 0 : BB
Frosty = Frosty && ((Greater && (BL > CWMod < BR)) || (!Greater && (BT > CHMod < BB)))

FrostyStr = !Frosty ? "" : \
"CRVideo.CR_FrostyBorders(CRVideo_Width, CRVideo_Height, F_CRVideo_Width, F_CRVideo_Height, \
FBL, FBT, FBR, FBB, CWMod, CHMod, F_CWMod, F_CHMod, CRVideo_StorageAR, Final_StorageAR, IsMTResize)"

BorderedVideo = !Frosty ? CRVideo.AddBorders(BL, BT, BR, BB, color=BColor) : \
(Greater && (BT == 0 == BB)) || (!Greater && (BL == 0 == BR)) ? Eval(FrostyStr) : \
Greater ? Eval(FrostyStr + ".AddBorders(0, BT, 0, BB, color=BColor)") : \
Eval(FrostyStr + ".AddBorders(BL, 0, BR, 0, color=BColor)")

""", "Bordered Eval") : Eval("  BL=0   BT=0   BR=0   BB=0  ")

CROutput = !IsBordered ? CRVideo : BorderedVideo

# ===============================================================================
# ========== Global Aspect Ratios & Resolutions =================================
# ===============================================================================

CR_MeGUI_DAR() ? Eval("""

MInDARX = IsMInDAR ? MeGUI_darx : 0
MInDARY = IsMInDAR ? MeGUI_dary : 0
global gMPassDAR = IsMInDAR ? MInDAR : IsMPassThru ? MPassDAR : 0.0
global gMPassDARX = IsMInDAR ? MeGUI_darx : IsMPassThru ? gMPassDARX : 0
global gMPassDARY = IsMInDAR ? MeGUI_dary : IsMPassThru ? gMPassDARY : 0

global MeGUI_darx = !IsAnamorphicOutput ? Undefined() : \
NoResizing && (Source_Width == Final_Width) && (Source_Height == Final_Height) ? \
(IsMInDAR ? MeGUI_darx : IsMPassThru ? gMPassDARX : ContinuedNumerator(Final_DAR, limit=10000)) : \
ContinuedNumerator(Final_DAR, limit=10000)

global MeGUI_dary = !IsAnamorphicOutput ? Undefined() : \
NoResizing && (Source_Width == Final_Width) && (Source_Height == Final_Height) ? \
(IsMInDAR ? MeGUI_dary : IsMPassThru ? gMPassDARY : ContinuedDenominator(Final_DAR, limit=10000)) : \
ContinuedDenominator(Final_DAR, limit=10000)

""", "Global Aspect Ratios 1 Eval") : nop()

RMode ? Eval("""

global gPriorWidth = IsCurrentGAutoCPreview || IsAutoCPreview ? Source_Width : \
IsScriptCPreview ? Auto_Cropped_Width : Final_Width
global gPriorHeight = IsCurrentGAutoCPreview || IsAutoCPreview ? Source_Height : \
IsScriptCPreview ? Auto_Cropped_Height : Final_Height

""", "Global Aspect Ratios 2 Eval") : nop()

global gPriorScript = true

# ===============================================================================
# ========== Cropping Previews ==================================================
# ===============================================================================

Try{  F_gPriorWidth=float(gPriorWidth)   F_gPriorHeight=float(gPriorHeight)   IsPriorWidthHeight=true  }
catch(err){  IsPriorWidthHeight = false  }

IsPreviewResizing = IsPriorWidthHeight && (((IsCurrentGAutoCPreview || IsAutoCPreview) && \
((Source_Width != gPriorWidth) || (Source_Height != gPriorHeight))) || \
(IsScriptCPreview && ((Auto_Cropped_Width != gPriorWidth) || (Auto_Cropped_Height != gPriorHeight))) || \
(!IsScriptCPreview && !IsAutoCPreview && !IsCurrentGAutoCPreview && \
((Final_Width != gPriorWidth) || (Final_Height != gPriorHeight))))

# ========== Global Auto Cropping Preview =======================================

IsCurrentGAutoCPreview ? Eval("""

GAutoCroppingPreview = !IsPreviewResizing ? Source : Source.Spline36Resize(gPriorWidth, gPriorHeight)

GACP_Text = !IsPreviewResizing ? "Global AutoCrop Preview" : \
string(gPriorWidth, "RMode\nGlobal AutoCrop Preview\nResized To %.0f x ") + string(gPriorHeight, "%.0f") + \
(!IsG1Function || (!IsG2Function && IsGMode1) ? "" : \
"\n\n" + (IsGMode0 ? "GMode = 0" : IsGMode1 ? "GMode = 1" : "GMode = 2"))
GACP_Y = height(GAutoCroppingPreview) * 0.5
GACP_Size = min(width(GAutoCroppingPreview) * 0.034, height(GAutoCroppingPreview) * 0.036)

GAutoCroppingPreview = \
GAutoCroppingPreview.subtitle(GACP_Text, y=GACP_Y, size=GACP_Size, text_color=$ADD8E6, align=2, lsp=20)

""", "Global Auto Cropping Preview Eval") : nop()

# ========== Auto Cropping Preview ==============================================

IsAutoCPreview ? Eval("""

AutoCroppingPreview = \
Source.autocrop(mode=1, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0)
AutoCroppingPreview = \
!IsPreviewResizing ? AutoCroppingPreview : AutoCroppingPreview.Spline36Resize(gPriorWidth, gPriorHeight)

ACP_Text = !IsPreviewResizing ? "AutoCrop Preview" : \
string(gPriorWidth, "RMode\nAutoCrop Preview\nResized To %.0f x ") + string(gPriorHeight, "%.0f") + \
(!IsG1Function || (!IsG2Function && IsGMode1) ? "" : \
"\n\n" + (IsGMode0 ? "GMode = 0" : IsGMode1 ? "GMode = 1" : "GMode = 2"))
ACP_Y = height(AutoCroppingPreview) * 0.5
ACP_Size = min(width(AutoCroppingPreview) * 0.034, height(AutoCroppingPreview) * 0.036)

AutoCroppingPreview = \
AutoCroppingPreview.subtitle(ACP_Text, y=ACP_Y, size=ACP_Size, text_color=$ADD8E6, align=2, lsp=20)

""", "Auto Cropping Preview Eval") : nop()

# ===============================================================================

(Info || IsScriptCPreview) ? Eval("""

IsAnyAutoCrop = AutoC || IsCurrentGAutoC

CRVideo_WMod = (CRVideo_Width % 16 == 0) ? 16 : (CRVideo_Width % 8 == 0) ? 8 : \
(CRVideo_Width % 4 == 0) ? 4 : (CRVideo_Width % 2 == 0) ? 2 : 1
CRVideo_HMod = (CRVideo_Height % 16 == 0) ? 16 : (CRVideo_Height % 8 == 0) ? 8 : \
(CRVideo_Height % 4 == 0) ? 4 : (CRVideo_Height % 2 == 0) ? 2 : 1

CRVideo_Mod_Text = string(CRVideo_WMod, "   (Mod %.0fx") + string(CRVideo_HMod, "%.0f)")

Extra_CL = NoResizing ? CM_Extra_Crop_LR : ResizeWO ? RW_Extra_Crop_LR : \
(CRType == "CRA") ? CRA_Extra_Crop_LR : CRB_Extra_Crop_LR
Extra_CT = NoResizing ? CM_Extra_Crop_TB : ResizeWO ? RW_Extra_Crop_TB : \
(CRType == "CRA") ? CRA_Extra_Crop_TB : CRB_Extra_Crop_TB
Extra_CR = NoResizing ? CM_Extra_Crop_LR : ResizeWO ? RW_Extra_Crop_LR : \
(CRType == "CRA") ? CRA_Extra_Crop_LR : CRB_Extra_Crop_LR
Extra_CB = NoResizing ? CM_Extra_Crop_TB : ResizeWO ? RW_Extra_Crop_TB : \
(CRType == "CRA") ? CRA_Extra_Crop_TB : CRB_Extra_Crop_TB

Total_CL = Extra_CL + CL
Total_CT = Extra_CT + CT
Total_CR = Extra_CR + CR
Total_CB = Extra_CB + CB

Final_WMod = !ShowBorderInfo ? CRVideo_WMod : (Final_Width % 16 == 0) ? 16 : \
(Final_Width % 8 == 0) ? 8 : (Final_Width % 4 == 0) ? 4 : (Final_Width % 2 == 0) ? 2 : 1
Final_HMod = !ShowBorderInfo ? CRVideo_HMod : (Final_Height % 16 == 0) ? 16 : \
(Final_Height % 8 == 0) ? 8 : (Final_Height % 4 == 0) ? 4 : (Final_Height % 2 == 0) ? 2 : 1
Final_Mod_Text = string(Final_WMod, "   (Mod %.0fx") + string(Final_HMod, "%.0f)")

Source_WMod = (Source_Width % 16 == 0) ? 16 : (Source_Width % 8 == 0) ? 8 : \
(Source_Width % 4 == 0) ? 4 : (Source_Width % 2 == 0) ? 2 : 1
Source_HMod = (Source_Height % 16 == 0) ? 16 : (Source_Height % 8 == 0) ? 8 : \
(Source_Height % 4 == 0) ? 4 : (Source_Height % 2 == 0) ? 2 : 1
Source_Mod_Text = string(Source_WMod, "   (Mod %.0fx") + string(Source_HMod, "%.0f)")

CR = (CR <= 0.0005) ? 0 : CR
CB = (CB <= 0.0005) ? 0 : CB
CCR = (CCR <= 0.0005) ? 0 : CCR
CCB = (CCB <= 0.0005) ? 0 : CCB
RCR = (RCR <= 0.0005) ? 0 : RCR
RCB = (RCB <= 0.0005) ? 0 : RCB
Extra_CR = (Extra_CR <= 0.0005) ? 0 : Extra_CR
Extra_CB = (Extra_CB <= 0.0005) ? 0 : Extra_CB
Total_CR = (Total_CR <= 0.0005) ? 0 : Total_CR
Total_CB = (Total_CB <= 0.0005) ? 0 : Total_CB

""", "Info & Script Cropping Preview Eval") : nop()

# ========== Script Cropping Preview ============================================

IsScriptCPreview && !Info ? Eval("""

SCP_InDAR = IsMInDAR ? string(MInDARX, "   (DAR  %.0f:") + string(MInDARY, "%.0f)") : \
IsMPassedThru ? string(gMPassDARX, "   (DAR  %.0f:") + string(gMPassDARY, "%.0f)") : CR_FTF(Source_DAR, 4)

SCP_Source_Info = \
string(Source_Width, "Source Resolution\n%.0f x ") + string(Source_Height, "%.0f") + Source_Mod_Text + \
(!IsAnamorphicInput ? "\nNot Anamorphic" : "\nAnamorphic") + SCP_InDAR + (!IsAnyAutoCrop ? "" : \
string(Auto_Cropped_Width, "\nAuto Cropped Resolution\n%.0f x ") + string(Auto_Cropped_Height,"%.0f") + \
CR_FTF(Auto_Cropped_DAR, 4))

SCP_SpecifiedC = (!IsAnyAutoCrop ? "" : "\n\n") + "\n\n\n\n" + \
(!IsAnyAutoCrop ? "Specified Cropping\n" : "Specified Cropping (After AutoC)\n(") + \
CR_FS(CL) + ", " + CR_FS(CT) + ", " + CR_FS(-CR) + ", " + CR_FS(-CB) + ")"

SCP_TotalC = (!IsAnyAutoCrop ? "" : "\n\n") + "\n\n\n\n\n\n\n" + \
(!IsAnyAutoCrop ? "Total Cropping\n" : "Total Cropping (After AutoC)\n(") + \
CR_FS(Total_CL) + ", " + CR_FS(Total_CT) + ", " + CR_FS(-Total_CR) + ", " + CR_FS(-Total_CB) + ")"

SCP_Output_Info = "\n\n\n\n\n\n\n\n" + ((!ShowBorderInfo ? \
string(CRVideo_Width, "Output Resolution\n%.0f x ") + string(CRVideo_Height, "%.0f") + CRVideo_Mod_Text : \
string(CRVideo_Width, "Output Resolution\nExc Borders   %.0f x ") + \
string(CRVideo_Height, "%.0f") + CRVideo_Mod_Text + \
string(Final_Width, "\nInc Borders   %.0f x ") + string(Final_Height, "%.0f") + Final_Mod_Text) + \
(!IsAnamorphicOutput ? "\nNot Anamorphic" : "\nAnamorphic") + (!AnamorphicOutput ? CR_FTF(Final_DAR, 4) : \
NoResizing && (Final_Width == Source_Width) && (Final_Height == Source_Height) ? \
SCP_InDAR : CR_FTF(Final_DAR, 4))) + CR_FTF(Final_SAR, 5)

SCP_Common_Resize = !IsPreviewResizing ? "" : \
string(gPriorWidth, "\n\nRMode\nCropping Preview Resized To %.0f x ") + string(gPriorHeight, "%.0f")
SCP_GMode = !IsG1Function || (!IsG2Function && IsGMode1) ? "" : \
(IsPreviewResizing ? "\n" : "\n\n") + (IsGMode0 ? "GMode = 0" : IsGMode1 ? "GMode = 1" : "GMode = 2")

SCP_Size = !IsPreviewResizing ? min(F_Auto_Cropped_Width * 0.03, F_Auto_Cropped_Height * 0.032) : \
min(F_gPriorWidth * 0.03, F_gPriorHeight * 0.032)
SCP_Y = (!IsPreviewResizing ? F_Source_Height * 0.27 : F_gPriorHeight * 0.2) * \
(!IsAnyAutoCrop ? 1.0 : 0.9) * (!ShowBorderInfo ? 1.0 : 0.95) * (!Position ? 1.0 : 1.2)

SCP_RGMode = "\n\n\n\n\n\n\n\n\n\n\n\n\n" + (!IsAnyAutoCrop ? "" : "\n\n") + SCP_Common_Resize + SCP_GMode

""", "Script Cropping Preview 1 Eval") : nop()

# ===============================================================================

IsScriptCPreview ? Eval("""

YUV444Clip = IsAvsHBD ? AutoCroppedSource.ConvertToYUV444() : AutoCroppedSource.ConvertToYV24()

PCL = round(CL)
PCT = round(CT)
PCR = round(CR)
PCB = round(CB)
CLine_L = (PCL == 0) ? 0 : (PCL >= CLine) ? CLine : PCL
CLine_T = (PCT == 0) ? 0 : (PCT >= CLine) ? CLine : PCT
CLine_R = (PCR == 0) ? 0 : (PCR >= CLine) ? CLine : PCR
CLine_B = (PCB == 0) ? 0 : (PCB >= CLine) ? CLine : PCB
Script_CL = (round(Total_CL) > PCL) ? round(Total_CL) : 0
Script_CT = (round(Total_CT) > PCT) ? round(Total_CT) : 0
Script_CR = (round(Total_CR) > PCR) ? round(Total_CR) : 0
Script_CB = (round(Total_CB) > PCB) ? round(Total_CB) : 0
SLine_L = (Script_CL == 0) ? 0 : (Script_CL >= CLine) ? CLine : Script_CL
SLine_T = (Script_CT == 0) ? 0 : (Script_CT >= CLine) ? CLine : Script_CT
SLine_R = (Script_CR == 0) ? 0 : (Script_CR >= CLine) ? CLine : Script_CR
SLine_B = (Script_CB == 0) ? 0 : (Script_CB >= CLine) ? CLine : Script_CB

OverlayClip = (CPreview == 1) ? \
BlankClip(YUV444Clip).crop(Script_CL, Script_CT, -Script_CR, -Script_CB)\
.AddBorders(SLine_L, SLine_T, SLine_R, SLine_B, color=$ADD8E6)\
.AddBorders(Script_CL - SLine_L, Script_CT - SLine_T, Script_CR - SLine_R, Script_CB - SLine_B)\
.crop(PCL, PCT, -PCR, -PCB).AddBorders(CLine_L, CLine_T, CLine_R, CLine_B, color=$FFFF00)\
.AddBorders(PCL - CLine_L, PCT - CLine_T, PCR - CLine_R, PCB - CLine_B) : \
(CPreview == 2) ? \
BlankClip(YUV444Clip).crop(Script_CL, Script_CT, -Script_CR, -Script_CB)\
.AddBorders(Script_CL, Script_CT, Script_CR, Script_CB, color=$ADD8E6)\
.crop(PCL, PCT, -PCR, -PCB).AddBorders(PCL, PCT, PCR, PCB, color=$FFFF00) : \
YUV444Clip.crop(Script_CL, Script_CT, -Script_CR, -Script_CB)\
.AddBorders(Script_CL, Script_CT, Script_CR, Script_CB, color=$FF0000)\
.crop(PCL, PCT, -PCR, -PCB).AddBorders(PCL, PCT, PCR, PCB)

MaskClip = ((CPreview == 1) ? \
BlankClip(YUV444Clip).crop(Script_CL, Script_CT, -Script_CR, -Script_CB)\
.AddBorders(SLine_L, SLine_T, SLine_R, SLine_B, color=$FFFFFF)\
.AddBorders(Script_CL - SLine_L, Script_CT - SLine_T, Script_CR - SLine_R, Script_CB - SLine_B)\
.crop(PCL, PCT, -PCR, -PCB).AddBorders(CLine_L, CLine_T, CLine_R, CLine_B, color=$e4e4e4)\
.AddBorders(PCL - CLine_L, PCT - CLine_T, PCR - CLine_R, PCB - CLine_B) : \
(CPreview == 2) ? \
BlankClip(YUV444Clip).crop(Script_CL, Script_CT, -Script_CR, -Script_CB)\
.AddBorders(Script_CL, Script_CT, Script_CR, Script_CB, color=$7f7f7f)\
.crop(PCL, PCT, -PCR, -PCB).AddBorders(PCL, PCT, PCR, PCB, color=$4b4b4b) : \
BlankClip(YUV444Clip, color=$FFFFFF).crop(Script_CL, Script_CT, -Script_CR, -Script_CB)\
.AddBorders(Script_CL, Script_CT, Script_CR, Script_CB, color=$4b4b4b)\
.crop(PCL, PCT, -PCR, -PCB).AddBorders(PCL, PCT, PCR, PCB))\
.ColorYUV(Levels="TV->PC")

PreviewClip = (CPreview == 1) || (CPreview == 2) ? Overlay(AutoCroppedSource, OverlayClip, mask=MaskClip) : \
Overlay(invert(AutoCroppedSource), OverlayClip, mask=MaskClip)
PreviewClip = !IsPreviewResizing ? PreviewClip : PreviewClip.Spline36Resize(gPriorWidth, gPriorHeight)

ScriptCroppingPreview = Info ? PreviewClip : PreviewClip\
.subtitle(SCP_Source_Info + SCP_Output_Info, y=SCP_Y, size=SCP_Size, text_color=$FFFFE0, align=2, lsp=20)\
.subtitle(SCP_SpecifiedC, y=SCP_Y, size=SCP_Size, text_color=$F0E68C, align=2, lsp=20)\
.subtitle(SCP_TotalC, y=SCP_Y, size=SCP_Size, text_color=$B0C4DE, align=2, lsp=20)\
.subtitle(SCP_RGMode, y=SCP_Y, size=SCP_Size, text_color=$ADD8E6, align=2, lsp=20)

""", "Script Cropping Preview 2 Eval") : nop()

# ===============================================================================
# ========== Display Info =======================================================
# ===============================================================================

Info && !IsAutoCPreview && !IsCurrentGAutoCPreview ? Eval("""

I_InDAR = IsMInDAR ? string(MInDARX, "   (%.0f:") + string(MInDARY, "%.0f)") : \
IsMPassedThru ? string(gMPassDARX, "   (%.0f:") + string(gMPassDARY, "%.0f)") : CR_FTF(Source_DAR, 1)

InfoVideo = IsScriptCPreview ? ScriptCroppingPreview : \
!IsPreviewResizing ? CROutput : CROutput.Spline36Resize(gPriorWidth, gPriorHeight)
F_InfoVideo_Width = float(width(InfoVideo))
F_InfoVideo_Height = float(height(InfoVideo))
InfoVideo_StorageAR = F_InfoVideo_Width / F_InfoVideo_Height

PicDimScale = (Source_Bits == 10) ? 4.0 : (Source_Bits == 12) ? 16.0 : \
(Source_Bits == 14) ? 64.0 : (Source_Bits == 16) ? 256.0 : 1.0 / 256.0
RGBWhite = (Source_Bits == 8) ? 255.0 : (Source_Bits == 10) ? 1020.0 : \
(Source_Bits == 12) ? 4080.0 : (Source_Bits == 14) ? 16320.0 : \
(Source_Bits == 16) ? 65280.0 : 255.0 / 256.0

IsPicDim = (PicDim > 0)
InfoPicDim = \
(IsCConversion || IsScriptCPreview) && !CR_InfoAutoPicDimWhenCPreviewOrColorCorrect() ? 0 : PicDim
InfoPicDim = (InfoPicDim == 0) ? 0 : (Source_Bits == 8) ? InfoPicDim : float(InfoPicDim) * PicDimScale
InfoPicDim = (InfoPicDim == 0) ? 0 : max(0, min(RGBWhite, RGBWhite - InfoPicDim))

NotAnamorphicOut = AnamorphicOutput && !IsAnamorphicOutput

LineCondition = \
!AnamorphicInput || !IsAnamorphicOutput || ShowBorderInfo || IsAnyAutoCrop ? 0 : (!AutoAspect ? 0 : 1) + \
((CMode != "") ? 2 : (CCorrect > 0) && (CMode == "") ? 1 : 0) + (!IsPicDim ? 0 : 1) + (!IsPreviewResizing ? 0 : 1)
Pos = !Position ? 1 : (LineCondition < 3) ? 2 : 3
LineCondition = LineCondition + (!Position ? 0 : (Pos == 2) ? 2 : (Pos == 3) ? 1 : 0)

TopLine = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" + (!ShowBorderInfo && !IsAnyAutoCrop ? "" : \
ShowBorderInfo && IsAnyAutoCrop ? "\n\n\n\n\n\n\n\n\n" : ShowBorderInfo ? "\n\n\n\n\n" : "\n\n\n\n")

AspectLine1 = !AutoAspect ? "\n" : ""
CCLine1 = (CMode != "") ? "" : (CCorrect > 0) && (CMode == "") ? "\n" : "\n\n"
PicDimLine1 = !IsPicDim ? "\n" : ""
RModeLine1 = !IsPreviewResizing ? "\n" : ""
PositionLine1 = ((Pos == 2) ? "" : (Pos == 3) ? "\n" : "\n\n")
AspectLine2 = !AutoAspect ? "" : TopLine + CCLine1 + PicDimLine1 + RModeLine1 + PositionLine1
CCLine2 = (CCorrect == 0) ? "" : TopLine + "\n" + CCLine1 + PicDimLine1 + RModeLine1 + PositionLine1
PicDimLine2 = !IsPicDim ? "" : TopLine + "\n\n\n" + RModeLine1 + PositionLine1
RModeLine2 = !IsPreviewResizing ? "" : TopLine + "\n\n\n\n" + PositionLine1
PosLine = !Position ? "" : TopLine + "\n\n\n\n\n" + PositionLine1

I_Color1 = FullResizing ? $FFFFE0 : $F0FFFF
I_Color2 = (((CRType == "CRA") && (IsHeight169 || IsHeight43)) && \
(F_CRA_Adjusted_Height1 != F_CRA_Adjusted_Height2)) || \
(((CRType == "CRB") && (IsWidth169 || IsWidth43)) && \
(F_CRB_Adjusted_Width1 != F_CRB_Adjusted_Width2)) ? $ADD8E6 : I_Color1
I_Color3 = !IsCConversion ? I_Color1 : $FFA07A
I_Color4 = !IsPreviewResizing ? I_Color1 : $ADD8E6
I_Color5 = FullResizing ? $F0FFFF : $FFFFE0

I_Size = min(F_InfoVideo_Width * 0.021, F_InfoVideo_Height * \
((F_InfoVideo_Height <= 300) ? \
(IsAnyAutoCrop && ShowBorderInfo ? 0.019 : ShowBorderInfo ? 0.0242 : IsAnyAutoCrop ? 0.0252 : 0.031) : \
(F_InfoVideo_Height <= 400) ? \
(IsAnyAutoCrop && ShowBorderInfo ? 0.0216 : ShowBorderInfo ? 0.025 : IsAnyAutoCrop ? 0.0269 : 0.0328) : \
(F_InfoVideo_Height <= 500) ? \
(IsAnyAutoCrop && ShowBorderInfo ? 0.0232 : ShowBorderInfo ? 0.027 : IsAnyAutoCrop ? 0.0285 : 0.033) : \
(F_InfoVideo_Height <= 600) ? \
(IsAnyAutoCrop && ShowBorderInfo ? 0.024 : ShowBorderInfo ? 0.0275 : IsAnyAutoCrop ? 0.029 : 0.035) : \
(IsAnyAutoCrop && ShowBorderInfo ? 0.0245 : ShowBorderInfo ? 0.028 : IsAnyAutoCrop ? 0.0295 : 0.035)))

I_X1 = I_Size * 2.0
I_X2 = I_Size * 27.25
I_Y = I_Size * 1.25

# ========== Left Column ========================================================

I_Num = FrameRateNumerator(Source)
I_Den = FrameRateDenominator(Source)
I_FRate = float(I_Num) / float(I_Den)

I_Source_Info = \
string(Source_Width, "Source Resolution   %.0f x ") + string(Source_Height, "%.0f") + Source_Mod_Text + \
string(Source_StorageAR, "\nStorage Aspect Ratio   %.6f") + CR_FTF(Source_StorageAR, 1) + \
string(Source_DAR, "\nDisplay Aspect Ratio   %.6f") + I_InDAR + \
string(Source_Bits, "\n%.0f bit   ") + Color_Format + "   " + CR_FS(I_FRate, 0, 4) + " fps" + \
((abs(round(I_FRate) - I_FRate) <= 0.00005) ? CR_FTF(I_FRate, 2) : \
string(I_Num, "  (%.0f / ") + string(I_Den, "%.0f)"))

I_AutoC = !IsAnyAutoCrop ? "" : \
string(Auto_Cropped_Width, "\n\nAuto Cropped Resolution   %.0f x ") + string(Auto_Cropped_Height, "%.0f") + \
string(Auto_Cropped_StorageAR, "\nStorage Aspect Ratio   %.6f") + CR_FTF(Auto_Cropped_StorageAR, 1) + \
string(Auto_Cropped_DAR, "\nDisplay Aspect Ratio   %.6f") + \
(NoResizing && (Auto_Cropped_Width == Source_Width) && (Auto_Cropped_Height == Source_Height) ? \
I_InDAR : CR_FTF(Auto_Cropped_DAR, 1))

I_SpecifiedC = \
"\n\nSpecified Cropping\n(" + CR_FS(CL) + ", " + CR_FS(CT) + ", " + CR_FS(-CR) + ", " + CR_FS(-CB) + ")"

I_ExtraC = "\nAdditional Script Cropping\n(" + \
CR_FS(Extra_CL) + ", " + CR_FS(Extra_CT) + ", " + CR_FS(-Extra_CR) + ", " + CR_FS(-Extra_CB) + ")"

I_CSplit_Crop = NoResizing_NoResizer ? "" : "\n\nCrop " + \
string(CCL, "(%.0f, ") + string(CCT, "%.0f, ") + string(-CCR, "%.0f, ") + string(-CCB, "%.0f)")

I_CSplit_Resizer = NoResizing_NoResizer ? "" : "\nResizer Cropping\n(" + \
CR_FS(RCL) + ", " + CR_FS(RCT) + ", " + CR_FS(-RCR) + ", " + CR_FS(-RCB) + ")"

I_TotalC = "\nTotal Cropping\n(" + \
CR_FS(Total_CL) + ", " + CR_FS(Total_CT) + ", " + CR_FS(-Total_CR) + ", " + CR_FS(-Total_CB) + ")" + \
(NoResizing ? "\n\n\n\n" : "")

I_Cropped_Resolution = "\n\nCropped Resolution   " + \
(NoResizing ? CR_FS(F_CM_Cropped_Width) + " x " + CR_FS(F_CM_Cropped_Height) : \
ResizeWO ? CR_FS(F_RW_Cropped_Width) + " x " + CR_FS(F_RW_Cropped_Height) : \
(CRType == "CRA") ? CR_FS(F_CRA_Cropped_Width) + " x " + CR_FS(F_CRA_Cropped_Height) : \
CR_FS(F_CRB_Cropped_Width) + " x " + CR_FS(F_CRB_Cropped_Height))

I_CSAR = NoResizing ? CM_Cropped_StorageAR : ResizeWO ? RW_Cropped_StorageAR : \
(CRType == "CRA") ? CRA_Cropped_StorageAR : CRB_Cropped_StorageAR
I_CDAR = NoResizing ? CM_Cropped_DAR : ResizeWO ? RW_Cropped_DAR : \
(CRType == "CRA") ? CRA_Cropped_DAR : CRB_Cropped_DAR

I_Cropped_AR = string(I_CSAR, "\nStorage Aspect Ratio   %.6f") + CR_FTF(I_CSAR, 1) + \
string(I_CDAR, "\nDisplay Aspect Ratio   %.6f") + \
(NoResizing && (F_Cropped_Source_Width == Source_Width) && (F_Cropped_Source_Height == Source_Height) ? \
I_InDAR : CR_FTF(I_CDAR, 1))

I_CVARs = CRVideo_Mod_Text + \
string(CRVideo_StorageAR, "\nStorage Aspect Ratio   %.6f") + CR_FTF(CRVideo_StorageAR, 1) + \
string(CRVideo_DAR, "\nDisplay Aspect Ratio   %.6f") + \
(NoResizing && (CRVideo_Width == Source_Width) && (CRVideo_Height == Source_Height) ? \
I_InDAR : CR_FTF(CRVideo_DAR, 1))

I_Output_Info = !ShowBorderInfo ? \
string(CRVideo_Width, "\n\nOutput Resolution   %.0f x ") + string(CRVideo_Height, "%.0f") + I_CVARs : \
string(CRVideo_Width, "\n\nOutput Exc Borders   %.0f x ") + string(CRVideo_Height, "%.0f") + I_CVARs + \
string(BL, "\n\nAddBorders (%.0f, ") + string(BT, "%.0f, ") + string(BR, "%.0f, ") + string(BB, "%.0f)") + \
string(Final_Width, "\nOutput Inc Borders   %.0f x ") + string(Final_Height, "%.0f") + \
Final_Mod_Text + string(Final_StorageAR, "\nStorage Aspect Ratio   %.6f") + CR_FTF(Final_StorageAR, 1) + \
string(Final_DAR, "\nDisplay Aspect Ratio   %.6f") + \
(NoResizing && (Final_Width == Source_Width) && (Final_Height == Source_Height) ? \
I_InDAR : CR_FTF(Final_DAR, 1))

I_Left_Column = I_Source_Info + I_AutoC + I_SpecifiedC + I_ExtraC + I_CSplit_Crop + \
I_CSplit_Resizer + I_TotalC + I_Cropped_Resolution + I_Cropped_AR + I_Output_Info

# ========== Right Column =======================================================

I_AvsVer = !CR_InfoDisplayFormattedAvisynthVersion() ? VersionString() : \
(IsAvsPlus ? "AviSynth+  " + MidStr(AvsVerStrLC, 11, AvsStrNumA - 14) + string(AvsBuildNum, "  (%.0f)") : \
(FindStr(AvsVerStrLC, "2.60") > 0) ? "AviSynth  2.60" : \
(FindStr(AvsVerStrLC, "2.61") > 0) ? "AviSynth  2.61" : VersionString()) + \
((FindStr(AvsVerStrLC, "i386") > 0) || (FindStr(AvsVerStrLC, "ix86") > 0) ? "  32 bit" : \
(FindStr(AvsVerStrLC, "x86_64") > 0) || (FindStr(AvsVerStrLC, "x64") > 0) ? "  64 bit" : "")

I_Mode = "\n" + (CleanBorders ? "Clean Borders   " : NoResizing ? "No Resizing   " : \
ResizeWO ? "Resize Width Only   " : "Full Resizing Mode   ") + \
(!IsG1Function || (!IsG2Function && IsGMode1) ? "" : \
(IsGMode0 ? "(GMode = 0)" : IsGMode1 ? "(GMode = 1)" : "(GMode = 2)"))

I_Resizer = "\n" + (NoResizing_NoResizer ? "" : \
IsZ ? "z_" + Resizer + (!defined(Z_Taps) ? "" : string(Z_Taps, "(%.0f)")) : \
IsResizeMTAppended || IsMTAppended ? ((RStr == "") ? Resizer : Kernel + "MT") : Resizer) + \
((RStr == "") ? "" : "   " + RStr)

I_InAspect = "\n\nInput Aspect" + \
(IsInDAR ? string(InDAR, "   InDAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(InDAR, 1) + \
string(Source_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Source_SAR, 1) : \
IsInSAR ? string(Source_DAR, "   InSAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(Source_DAR, 1) + \
string(InSAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(InSAR, 1) : \
IsGInDAR ? string(GInDAR, "   Global InDAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(GInDAR, 1) + \
string(Source_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Source_SAR, 1) : \
IsGInSAR ? string(Source_DAR, "   Global InSAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(Source_DAR, 1) + \
string(GInSAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(GInSAR, 1) : \
IsMInDAR ? string(MInDAR, "   MeGUI DAR\nDisplay Aspect Ratio   %.6f") + \
string(MInDARX, "   (%.0f:") + string(MInDARY, "%.0f)") + \
string(Source_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Source_SAR, 1) : \
IsMPassedThru ? string(MPassDAR, "   MeGUI DAR\nDisplay Aspect Ratio   %.6f") + \
string(gMPassDARX, "   (%.0f:") + string(gMPassDARY, "%.0f)") + \
string(Source_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Source_SAR, 1) : "") + \
(AnamorphicInput && !IsAnamorphicInput ? "\nNot Anamorphic" : !AnamorphicInput ? "   Not Specified" : \
IsAnamorphicInput ? \
string(F_Source_Display_Width, "\nDisplay Dimensions   %.0f x ") + string(Source_Height, "%.0f") : "")

I_OutAspect = "\n\nOutput Aspect" + \
(NoResizing && IsAnamorphicOutput && (Final_Width == Source_Width) && (Final_Height == Source_Height) ? \
string(Final_DAR, "\nDisplay Aspect Ratio   %.6f") + I_InDAR + \
string(Final_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Final_SAR, 1) : \
NoResizing && IsAnamorphicOutput ? \
string(Final_DAR, "\nDisplay Aspect Ratio   %.6f") + CR_FTF(Final_DAR, 1) + \
string(Final_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Final_SAR, 1) : \
IsOutDAR ? string(OutDAR, "   OutDAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(OutDAR, 1) + \
string(Final_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Final_SAR, 1) : \
IsOutSAR ? string(Final_DAR, "   OutSAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(Final_DAR, 1) + \
string(OutSAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(OutSAR, 1) : \
IsGOutDAR ? string(GOutDAR, "   Global OutDAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(GOutDAR, 1) + \
string(Final_SAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(Final_SAR, 1) : \
IsGOutSAR ? string(Final_DAR, "   Global OutSAR\nDisplay Aspect Ratio   %.6f") + CR_FTF(Final_DAR, 1) + \
string(GOutSAR, "\nSample Aspect Ratio   %.6f") + CR_FTF(GOutSAR, 1) : "") + \
(NotAnamorphicOut ? "\nNot Anamorphic" : !AnamorphicOutput ? "   Not Specified" : "") + \
(!AnamorphicOutput ? "\nSample Aspect Ratio" + CR_FTF(Final_SAR, 1) : "") + (!IsAnamorphicOutput ? "" : \
string(F_Final_Display_Width, "\nDisplay Dimensions   %.0f x ") + string(Final_Height, "%.0f"))

I_MeGUI = "\n\n" + ((LineCondition > 4) ? "" : "MeGUI Output DAR\n") + \
(!IsAnamorphicOutput ? "Not Anamorphic" : string(MeGUI_darx, "MeGUI_darx = %.0f") + \
((LineCondition > 5) ? "   " : "\n") + string(MeGUI_dary, "MeGUI_dary = %.0f"))

CRA_PreAutoAspect = (CRType == "CRA") ? (!IsOutputSAR ? \
F_Resizing_Width / F_CRA_Adjusted_Height1 : F_Resizing_Width * OutputSAR / F_CRA_Adjusted_Height1) : 0.0
CRB_PreAutoAspect = (CRType == "CRB") ? (!IsOutputSAR ? \
F_CRB_Adjusted_Width1 / F_Resizing_Height : F_CRB_Adjusted_Width1 * OutputSAR / F_Resizing_Height) : 0.0

I_AutoAspect = !AutoAspect ? "" + AspectLine1 + RModeLine1 + CCLine1 + PicDimLine1 : \
AspectLine2 + "AutoAspect   " + (!IsAutoAspect ? "Not Applicable" : \
(CRType == "CRA") && IsHeight169 && (F_CRA_Adjusted_Height1 != F_CRA_Adjusted_Height2) ? \
string(CRA_PreAutoAspect, "%.6f -> 16:9") : \
(CRType == "CRA") && IsHeight43 && (F_CRA_Adjusted_Height1 != F_CRA_Adjusted_Height2) ? \
string(CRA_PreAutoAspect, "%.6f -> 4:3") : \
(CRType == "CRB") && IsWidth169 && (F_CRB_Adjusted_Width1 != F_CRB_Adjusted_Width2) ? \
string(CRB_PreAutoAspect, "%.6f -> 16:9") : \
(CRType == "CRB") && IsWidth43 && (F_CRB_Adjusted_Width1 != F_CRB_Adjusted_Width2) ? \
string(CRB_PreAutoAspect, "%.6f -> 4:3") : "Out Of Range")

I_Common_Resize = !IsPreviewResizing ? "" + RModeLine1 + CCLine1 + PicDimLine1 : \
RModeLine2 + ("RMode   " + (IsScriptCPreview ? "CPreview Resized To " : "Output Resized To ") + \
string(gPriorWidth, "%.0f x ") + string(gPriorHeight, "%.0f"))

I_CCorrect = (CCorrect == 0) ? "" + CCLine1 : CCLine2 + "Color Correction" + \
(!IsCConversion || !IsScriptCPreview ? "" : "   " + \
((CMode == "709-601") ? "Rec.709 -> Rec.601" : (CMode == "709-601N") ? "Rec.709 -> 170m" : \
(CMode == "709-601P") ? "Rec.709 -> 470bg" : (CMode == "2020-601") ? "Rec.2020 -> Rec.601" : \
(CMode == "2020-601N") ? "Rec.2020 -> 170m" : (CMode == "2020-601P") ? "Rec.2020 -> 470bg" : \
(CMode == "601-709") ? "Rec.601 -> Rec.709" : (CMode == "601N-709") ? "170m -> Rec.709" : \
(CMode == "601P-709") ? "470bg -> Rec.709" : (CMode == "601-2020") ? "Rec.601 -> Rec.2020" : \
(CMode == "601N-2020") ? "170m -> Rec.2020" : (CMode == "601P-2020") ? "470bg -> Rec.2020" : \
(CMode == "709-2020") ? "Rec.709 -> Rec.2020" : (CMode == "2020-709") ? "Rec.2020 -> Rec.709" : \
(CMode == "601N-601P") ? "170m -> 470bg" : (CMode == "601P-601N") ? "470bg -> 170m" : "") + \
"\nNot Applied To The Cropping Preview") + \
(IsCConversion && IsScriptCPreview ? "" : "   " + ((CMode == "") ? "None Required" : \
(CCorrect == 1) || (CCorrect == 2) ? "AVSResize" : \
(CCorrect == 3) || (CCorrect == 4) ? "HDRTools" : "HDRMatrix")) + \
(IsCConversion && IsScriptCPreview ? "" : "\n" + \
((CMode == "709-601") ? \
((CCorrect == 1) || (CCorrect == 3) ? "Rec.709 -> Rec.601 (170m)" : \
(CCorrect == 2) || (CCorrect == 4) ? "Rec.709 -> Rec.601 (470bg)" : "Rec.709 -> Rec.601") : \
(CMode == "709-601N") ? "Rec.709 -> Rec.601 (170m)" : \
(CMode == "709-601P") ? "Rec.709 -> Rec.601 (470bg)" : \
(CMode == "2020-601") ? \
((CCorrect == 1) || (CCorrect == 3) ? "Rec.2020 -> Rec.601 (170m)" : "Rec.2020 -> Rec.601 (470bg)") : \
(CMode == "2020-601N") ? "Rec.2020 -> Rec.601 (170m)" : \
(CMode == "2020-601P") ? "Rec.2020 -> Rec.601 (470bg)" : \
(CMode == "601-709") ? \
((CCorrect == 1) || (CCorrect == 3) ? "Rec.601 (170m) -> Rec.709" : \
(CCorrect == 2) || (CCorrect == 4) ? "Rec.601 (470bg) -> Rec.709" : "Rec.601 -> Rec.709") : \
(CMode == "601N-709") ? "Rec.601 (170m) -> Rec.709" : \
(CMode == "601P-709") ? "Rec.601 (470bg) -> Rec.709" : \
(CMode == "601-2020") ? \
((CCorrect == 1) || (CCorrect == 3) ? "Rec.601 (170m) -> Rec.2020" : "Rec.601 (470bg) -> Rec.2020") : \
(CMode == "601N-2020") ? "Rec.601 (170m) -> Rec.2020" : \
(CMode == "601P-2020") ? "Rec.601 (470bg) -> Rec.2020" : \
(CMode == "709-2020") ? "Rec.709 -> Rec.2020" : \
(CMode == "2020-709") ? "Rec.2020 -> Rec.709" : \
(CMode == "601N-601P") ? "Rec.601 (170m) -> Rec.601 (470bg)" : \
(CMode == "601P-601N") ? "Rec.601 (470bg) -> Rec.601 (170m)" : ""))

I_PicDim = !IsPicDim ? "" + CCLine1 + PicDimLine1 : PicDimLine2 + "PicDim   " + \
((InfoPicDim == 0) ? "Disabled " + (IsCConversion ? "(Color Correction)" : "(CropPreview)") : string(PicDim, "%.0f"))

I_Right_Column = I_AvsVer + "\nCropResize  2021-10-22" + \
I_Mode + I_Resizer + I_InAspect + I_OutAspect + I_MeGUI

# ===============================================================================

InfoVideo = ((InfoPicDim == 0) ? InfoVideo : \
InfoVideo.Levels(0, 1.0, RGBWhite, 0, InfoPicDim, coring=false))\
.subtitle(I_Left_Column, x=I_X1, y=I_Y, size=I_Size, text_color=I_Color1, lsp=20)\
.subtitle(I_Right_Column, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=20)\
.subtitle(I_AutoAspect, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color2, lsp=20)\
.subtitle(I_CCorrect, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color3, lsp=20)\
.subtitle(I_PicDim, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=20)\
.subtitle(I_Common_Resize, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color4, lsp=20)

""", "Info Eval") : nop()

# ===============================================================================
# ========== Final Output =======================================================
# ===============================================================================

IsPreviewResizing && !Info && !IsScriptCPreview && !IsAutoCPreview && !IsCurrentGAutoCPreview ? Eval("""

Out_ResizeText = \
string(gPriorWidth, "RMode\nOutput Video\nResized To %.0f x ") + string(gPriorHeight, "%.0f") + \
(!IsG1Function || (!IsG2Function && IsGMode1) ? "" : \
"\n\n" + (IsGMode0 ? "GMode = 0" : IsGMode1 ? "GMode = 1" : "GMode = 2"))
Out_ResizeSize = min(F_gPriorWidth * 0.034, F_gPriorHeight * 0.036)
CROutput = CROutput.Spline36Resize(gPriorWidth, gPriorHeight)\
.subtitle(Out_ResizeText, y=F_gPriorHeight*0.5, size=Out_ResizeSize, text_color=$ADD8E6, align=2, lsp=20)

""", "Final Output Preview Resize Eval") : nop()

Out_Size = !Position ? nop() : \
Info || IsScriptCPreview || IsAutoCPreview || IsCurrentGAutoCPreview ? nop() : !IsPreviewResizing ? \
min(width(CROutput)*0.04, height(CROutput)*0.042) : min(F_gPriorWidth * 0.034, F_gPriorHeight * 0.036)
Out_Y = !Position ? nop() : Info || IsScriptCPreview || IsAutoCPreview || IsCurrentGAutoCPreview ? nop() : \
!IsPreviewResizing ? (height(CROutput) * 0.5) + (Out_Size * 3.5) : Out_Size * 2.0

FinalOutput = !Position ? \
(IsCurrentGAutoCPreview ? GAutoCroppingPreview : IsAutoCPreview ? AutoCroppingPreview : \
Info ? InfoVideo : IsScriptCPreview ? ScriptCroppingPreview : CROutput) : \
IsCurrentGAutoCPreview ? GAutoCroppingPreview.CR_Position(Sy=GACP_Y, SSize=GACP_Size, Pos=1) : \
IsAutoCPreview ? AutoCroppingPreview.CR_Position(Sy=ACP_Y, SSize=ACP_Size, Pos=1) : \
Info ? InfoVideo.CR_Position(Sx=I_X2, Sy=I_Y, SSize=I_Size, SColor=I_Color5, Pos=Pos, PosLine=PosLine) : \
IsScriptCPreview ? ScriptCroppingPreview.CR_Position(Sy=SCP_Y, SSize=SCP_Size, Pos=1) : \
CROutput.CR_Position(Sy=Out_Y, SSize=Out_Size, Pos=1)

return !HasAudio(SourceAudio) ? FinalOutput : AudioDub(FinalOutput, SourceAudio)  }

# ===============================================================================
# ===============================================================================
# ========== Global GCropResize Function ========================================
# ===============================================================================
# ===============================================================================

function GCropResize(clip Source, \
int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", int "CSplit", bool "CAlign", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", \
bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

# ===============================================================================

OutWidth = default(OutWidth, 0)
OutHeight = default(OutHeight, 0)
AutoC = default(AutoC, false)
CThresh = default(CThresh, 30)
LastFrame = FrameCount(Source) - 1
ACStart = (LastFrame > 3000) ? 250 : 0
CStart = default(CStart, ACStart)
CSample = default(CSample, 5)
gCropDAR = default(CropDAR, 0.0)
gInDAR = default(InDAR, 0.0)
gInSAR = default(InSAR, 0.0)
gOutDAR = default(OutDAR, 0.0)
gOutSAR = default(OutSAR, 0.0)
IsResizer = defined(Resizer)
GMode = default(GMode, 1)
IsGMode1 = (GMode == 1)
IsGMode2 = (GMode == 2)
GC_R = " GCropResize " + chr(10)

assert((0 < GMode < 3), GC_R + " GMode must be 1 or 2 for" + GC_R + " (0, 1 or 2 for CropResize) " + chr(10))
assert(!defined(RMode), GC_R + " RMode can't be used with the global GCropResize function " + chr(10))

Try{  IsG1Function = G1_GFunction  }catch(err){  IsG1Function = false  }

# ========== GMode1 =============================================================

IsGMode1 ? Eval("""

G1PriorGAutoC = IsG1Function && G1_AutoC
G1PriorGAutoCPreview = IsG1Function && (G1_CPreview == 4)
global G1_GFunction = true

global G1_Source_Width = AutoC || !G1PriorGAutoC ? width(Source) : G1_Source_Width
global G1_Source_Height = AutoC || !G1PriorGAutoC ? height(Source) : G1_Source_Height

global G1_OutWidth = (OutWidth == 0) && IsG1Function ? G1_OutWidth : OutWidth
global G1_OutHeight = (OutHeight == 0) && IsG1Function ? G1_OutHeight : OutHeight
global G1_CL = default(CL, !IsG1Function ? 0.0 : G1_CL)
global G1_CT = default(CT, !IsG1Function ? 0.0 : G1_CT)
global G1_CR = default(CR, !IsG1Function ? 0.0 : G1_CR)
global G1_CB = default(CB, !IsG1Function ? 0.0 : G1_CB)
global G1_CropDAR = default(CropDAR, !IsG1Function ? 0.0 : G1_CropDAR)
global G1_CSplit = default(CSplit, !IsG1Function ? 1 : G1_CSplit)
global G1_CAlign = default(CAlign, !IsG1Function ? false : G1_CAlign)
global G1_AutoC = AutoC || G1PriorGAutoC
global G1_CThresh = CThresh
global G1_CStart = CStart
global G1_CSample = CSample
global G1_CPreview = default(CPreview, !IsG1Function ? 0 : G1_CPreview)
global G1_CLine = default(CLine, !IsG1Function ? CR_CLine() : G1_CLine)
global G1_InDAR = default(InDAR, (gInSAR > 0) || !IsG1Function ? 0.0 : G1_InDAR)
global G1_InSAR = default(InSAR, (gInDAR > 0) || !IsG1Function ? 0.0 : G1_InSAR)
global G1_OutDAR = default(OutDAR, (gOutSAR > 0) || !IsG1Function ? 0.0 : G1_OutDAR)
global G1_OutSAR = default(OutSAR, (gOutDAR > 0) || !IsG1Function ? 0.0 : G1_OutSAR)
global G1_AutoAspect = default(AutoAspect, !IsG1Function ? CR_AutoAspect() : G1_AutoAspect)
global G1_Mod = default(Mod, !IsG1Function ? 4 : G1_Mod)
global G1_HMod = default(HMod, !IsG1Function ? G1_Mod : G1_HMod)
global G1_NoResize = default(NoResize, !IsG1Function ? false : G1_NoResize)
global G1_ResizeWO = default(ResizeWO, !IsG1Function ? false : G1_ResizeWO)
global G1_Borders = default(Borders, !IsG1Function ? false : G1_Borders)
global G1_CleanBorders = default(CleanBorders, !IsG1Function ? false : G1_CleanBorders)
global G1_BColor = default(BColor, !IsG1Function ? $000000 : G1_BColor)
global G1_Frosty = default(Frosty, !IsG1Function ? false : G1_Frosty)
global G1_ColorCorrect = default(ColorCorrect, !IsG1Function ? CR_ColorCorrect() : G1_ColorCorrect)
global G1_ColorMode = default(ColorMode, !IsG1Function ? "" : G1_ColorMode)
global G1_Resizer = default(Resizer, !IsG1Function ? CR_ResizerDefault() : G1_Resizer)
global G1_RStr = default(RStr, IsResizer ? "" : !IsG1Function ? CR_RStrDefault() : G1_RStr)
global G1_GMode = GMode
global G1_PicDim = default(PicDim, !IsG1Function ? CR_InfoAutoPicDim() : G1_PicDim)
global G1_Position = default(Position, !IsG1Function ? false : G1_Position)
global G1_Info = default(Info, !IsG1Function ? false : G1_Info)

""", "GCropResize Defaults - GMode 1 Eval") : Eval("""

# ========== GMode2 =============================================================

assert(IsG1Function, GC_R + " For the first instance of GCropResize, GMode must equal one " + chr(10))

Try{  IsG2Function = G2_GFunction  }catch(err){  IsG2Function = false  }

G2PriorGAutoC = IsG2Function && G2_AutoC
G2PriorGAutoCPreview = IsG2Function && (G2_CPreview == 4)
global G2_GFunction = true

IsMod = defined(Mod)
global G2_Source_Width = AutoC || !G2PriorGAutoC ? width(Source) : G2_Source_Width
global G2_Source_Height = AutoC || !G2PriorGAutoC ? height(Source) : G2_Source_Height

global G2_OutWidth = (OutWidth == 0) ? (!IsG2Function ? G1_OutWidth : G2_OutWidth) : OutWidth
global G2_OutHeight = (OutHeight == 0) ? (!IsG2Function ? G1_OutHeight : G2_OutHeight) : OutHeight
global G2_CL = default(CL, !IsG2Function ? 0.0 : G2_CL)
global G2_CT = default(CT, !IsG2Function ? 0.0 : G2_CT)
global G2_CR = default(CR, !IsG2Function ? 0.0 : G2_CR)
global G2_CB = default(CB, !IsG2Function ? 0.0 : G2_CB)
global G2_CropDAR = default(CropDAR, !IsG2Function ? 0.0 : G2_CropDAR)
global G2_CSplit = default(CSplit, !IsG2Function ? 1 : G2_CSplit)
global G2_CAlign = default(CAlign, !IsG2Function ? false : G2_CAlign)
global G2_AutoC = AutoC || G2PriorGAutoC
global G2_CThresh = CThresh
global G2_CStart = CStart
global G2_CSample = CSample
global G2_CPreview = default(CPreview, !IsG2Function && (G1_CPreview == 4) && AutoC ? G1_CPreview : \
!IsG2Function && (G1_CPreview == 4) ? 0 : !IsG2Function ? G1_CPreview : G2_CPreview)
global G2_CLine = default(CLine, !IsG2Function ? G1_CLine : G2_CLine)
global G2_InDAR = default(InDAR, (gInSAR > 0) || !IsG2Function ? 0.0 : G2_InDAR)
global G2_InSAR = default(InSAR, (gInDAR > 0) || !IsG2Function ? 0.0 : G2_InSAR)
global G2_OutDAR = default(OutDAR, (gOutSAR > 0) ? 0.0 : !IsG2Function ? G1_OutDAR : G2_OutDAR)
global G2_OutSAR = default(OutSAR, (gOutDAR > 0) ? 0.0 : !IsG2Function ? G1_OutSAR : G2_OutSAR)
global G2_AutoAspect = default(AutoAspect, !IsG2Function ? G1_AutoAspect : G2_AutoAspect)
global G2_Mod = default(Mod, !IsG2Function ? G1_Mod : G2_Mod)
global G2_HMod = default(HMod, IsMod ? Mod : !IsG2Function ? G1_HMod : G2_HMod)
global G2_NoResize = default(NoResize, !IsG2Function ? false : G2_NoResize)
global G2_ResizeWO = default(ResizeWO, !IsG2Function ? false : G2_ResizeWO)
global G2_Borders = default(Borders, !IsG2Function ? false : G2_Borders)
global G2_CleanBorders = default(CleanBorders, !IsG2Function ? false : G2_CleanBorders)
global G2_BColor = default(BColor, !IsG2Function ? $000000 : G2_BColor)
global G2_Frosty = default(Frosty, !IsG2Function ? false : G2_Frosty)
global G2_ColorCorrect = default(ColorCorrect, !IsG2Function ? CR_ColorCorrect() : G2_ColorCorrect)
global G2_ColorMode = default(ColorMode, !IsG2Function ? "" : G2_ColorMode)
global G2_Resizer = default(Resizer, !IsG2Function ? G1_Resizer : G2_Resizer)
global G2_RStr = default(RStr, IsResizer ? "" : !IsG2Function ? G1_RStr : G2_RStr)
global G2_GMode = GMode
global G2_PicDim = default(PicDim, !IsG2Function ? G1_PicDim : G2_PicDim)
global G2_Position = default(Position, !IsG2Function ? false : G2_Position)
global G2_Info = default(Info, !IsG2Function ? G1_Info : G2_Info)

""", "GCropResize Defaults - GMode 2 Eval")

# ========== Insist =============================================================

assert(((IsFloat(gInDAR) && (gInDAR == 0)) || (IsFloat(gInDAR) && !IsInt(gInDAR) && (gInDAR > 0))) && \
((IsFloat(gInSAR) && (gInSAR == 0)) || (IsFloat(gInSAR) && !IsInt(gInSAR) && (gInSAR > 0))) && \
((IsFloat(gOutDAR) && (gOutDAR == 0)) || (IsFloat(gOutDAR) && !IsInt(gOutDAR) && (gOutDAR > 0))) && \
((IsFloat(gOutSAR) && (gOutSAR == 0)) || (IsFloat(gOutSAR) && !IsInt(gOutSAR) && (gOutSAR > 0))) && \
((IsFloat(gCropDAR) && (gCropDAR == 0)) || (IsFloat(gCropDAR) && !IsInt(gCropDAR) && (gCropDAR > 0))), \
GC_R + " CropDAR, InDAR, InSAR, OutDAR & OutSAR " + chr(10) + \
" must be zero or a positive floating point number " + chr(10) + " (4.0/3.0 or 1.7778 etc) " + chr(10))
assert((gInDAR == 0) || (gInSAR == 0), GC_R + " InDAR & InSAR can't be specified together " + chr(10))
assert((gOutDAR == 0) || (gOutSAR == 0), GC_R + " OutDAR & OutSAR can't be specified together " + chr(10))

assert((!IsGMode1 || (1 <= G1_CThresh <= 255)) && (!IsGMode2 || (1 <= G2_CThresh <= 255)), \
GC_R + " CThresh must be 1 thru 255 " + chr(10))
assert((!IsGMode1 || (0 <= G1_CPreview <= 4)) && (!IsGMode2 || (0 <= G2_CPreview <= 4)), \
GC_R + " CPreview must be 0 thru 4 " + chr(10))
assert((!IsGMode1 || (AutoC || (G1_CPreview != 4))) && (!IsGMode2 || (AutoC || (G2_CPreview != 4))), \
GC_R + " When CPreview=4, AutoC must be true " + chr(10))
assert(!AutoC || (CStart < LastFrame), GC_R + \
" The first frame for AutoCrop to check is beyond the final frame " + chr(10) + \
string(CStart, " CStart = %.0f  ") + string(LastFrame, " The final frame number is %.0f ")+ chr(10))

assert((!IsGMode1 || (!AutoC || !G1PriorGAutoC)) && (!IsGMode2 || (!AutoC || !G2PriorGAutoC)), \
GC_R + " AutoC can't be true for GCropResize when global auto-cropping " + chr(10) + \
" has previously been enabled via the GCropResize function " + chr(10) + \
" This applies only to more than one instance of GCropResize(GMode=1) " + chr(10) + \
" and only to more than one instance of GCropResize(GMode=2) " + chr(10))

assert(((!IsGMode1 || !G1PriorGAutoC) || (((CThresh == 30) || (CThresh == G1_CThresh)) && \
((CStart == ACStart) || (CStart == G1_CStart)) && ((CSample == 5) || (CSample == G1_CSample)))) && \
((!IsGMode2 || !G2PriorGAutoC) || (((CThresh == 30) || (CThresh == G2_CThresh)) && \
((CStart == ACStart) || (CStart == G2_CStart)) && ((CSample == 5) || (CSample == G2_CSample)))), \
GC_R + " New auto-cropping options can't be specified by GCropResize when global " + chr(10) + \
" auto-cropping has previously been enabled via the GCropResize function " + chr(10) + \
" This applies only to more than one instance of GCropResize(GMode=1) " + chr(10) + \
" and only to more than one instance of GCropResize(GMode=2) " + chr(10))

# ========== Auto Cropping ======================================================

IsAutoCVideo = (IsGMode1 && AutoC && (G1_CPreview != 4)) || (IsGMode2 && AutoC && (G2_CPreview != 4))
IsAutoCPreviewVideo = \
(IsGMode1 && AutoC && (G1_CPreview == 4)) || (IsGMode2 && AutoC && (G2_CPreview == 4))

IsAutoCVideo ? Eval("""

AutoCVideo = \
Source.autocrop(mode=0, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0)

""", "GCropResize - Auto Cropped Video Eval") : nop()

# -------------------------------------------------------------------------------

IsAutoCPreviewVideo ? Eval("""

AutoCroppingPreview = \
Source.autocrop(mode=1, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0)

""", "GCropResize - Auto Cropping Preview Eval") : nop()

# ========== Output =============================================================

return IsAutoCVideo ? AutoCVideo : IsAutoCPreviewVideo ? AutoCroppingPreview : Source  }

# ===============================================================================
# ===============================================================================
# ========== Color Convert & Resize Function ====================================
# ===============================================================================
# ===============================================================================

function CR_ColorConvertResize(clip Source, int ResizeW, int ResizeH, \
float RCL, float RCT, float RCR, float RCB, int CCorrect, string CMode, bool IsRGBSource, bool IsAvsHBD, \
int Source_Bits, bool NoResizing_NoResizer, bool Upscale, string Resizer, string ResStr, bool IsZ, int "Z_Taps")  {

# ===============================================================================

C_R = " CropResize " + chr(10)

DoResize = !IsZ ? \
Resizer + "(ResizeW, ResizeH, src_left=RCL, src_top=RCT, src_width=RCR, src_height=RCB" + ResStr + ")" : \
"z_ConvertFormat(ResizeW, ResizeH, src_left=RCL, src_top=RCT, src_width=RCR, src_height=RCB, \
resample_filter=Resizer, filter_param_a=Z_Taps" + ResStr + ")"

(CCorrect == 1) || (CCorrect == 2) ? Eval("""

# ========== AVSResize ==========================================================

assert(IsAvsHBD || !IsRGBSource, C_R + \
" Avisynth+ is required for color converting " + chr(10) + " or resizing RGB sources with AVSResize " + chr(10))

Color = ((CMode == "2020-601") && (CCorrect == 1)) || (CMode == "2020-601N") ? \
"2020:2020:2020=>470bg:601:170m" : \
((CMode == "2020-601") && (CCorrect == 2)) || (CMode == "2020-601P") ? \
"2020:2020:2020=>470bg:601:470bg" : \
(CMode == "2020-709") ? "2020:2020:2020=>709:709:709" : \
((CMode == "709-601") && (CCorrect == 1)) || (CMode == "709-601N") ? \
"709:709:709=>470bg:601:170m" : \
((CMode == "709-601") && (CCorrect == 2)) || (CMode == "709-601P") ? \
"709:709:709=>470bg:601:470bg" : \
(CMode == "709-2020") ? "709:709:709=>2020:2020:2020" : \
((CMode == "601-709") && (CCorrect == 1)) || (CMode == "601N-709") ? \
"470bg:601:170m=>709:709:709" : \
((CMode == "601-709") && (CCorrect == 2)) || (CMode == "601P-709") ? \
"470bg:601:470bg=>709:709:709" : \
((CMode == "601-2020") && (CCorrect == 1)) || (CMode == "601N-2020") ? \
"470bg:601:170m=>2020:2020:2020" : \
((CMode == "601-2020") && (CCorrect == 2)) || (CMode == "601P-2020") ? \
"470bg:601:470bg=>2020:2020:2020" : \
(CMode == "601N-601P") ? "470bg:601:170m=>470bg:601:470bg" : \
(CMode == "601P-601N") ? "470bg:601:470bg=>470bg:601:170m" : undefined()

Input = IsRGB24(Source) || IsRGB48(Source) ? Source.ConvertToPlanarRGB() : \
IsRGB32(Source) || IsRGB64(Source) ? Source.ConvertToPlanarRGBA() : \
IsYUY2(Source) ? Source.ConvertToYV16() : Source

Output = NoResizing_NoResizer ? Input.z_ConvertFormat(colorspace_op=Color) : \
!IsZ ? (UpScale ? Input.z_ConvertFormat(colorspace_op=Color).Eval(DoResize) : \
Input.Eval(DoResize).z_ConvertFormat(colorspace_op=Color)) : \
Eval("Input.z_ConvertFormat(ResizeW, ResizeH, src_left=RCL, src_top=RCT, src_width=RCR, src_height=RCB, \
resample_filter=Resizer, filter_param_a=Z_Taps, colorspace_op=Color" + ResStr + ")")

Output = IsRGB64(Source) ? Output.ConvertToRGB64() : IsRGB48(Source) ? Output.ConvertToRGB48() : \
IsRGB32(Source) ? Output.ConvertToRGB32() : IsRGB24(Source) ? Output.ConvertToRGB24() : \
IsYUY2(Source) ? Output.ConvertToYUY2() : Output

""", "Color Correct - AVSResize Eval") : (CCorrect == 3) || (CCorrect == 4) ? Eval("""

# ========== HDRTools ===========================================================

assert(IsAvsHBD, C_R + " Avisynth+ is required for color correction with HDRTools " + chr(10))

Color_A = \
(CMode == "2020-601") || (CMode == "2020-601N") || \
(CMode == "2020-601P") || (CMode == "2020-709") ? 1 : \
(CMode == "709-601") || (CMode == "709-601N") || \
(CMode == "709-601P") || (CMode == "709-2020") ? 2 : \
(CMode == "601-709") || (CMode == "601-2020") ? ((CCorrect == 3) ? 3 : 4) : \
(CMode == "601N-601P") || (CMode == "601N-709") || (CMode == "601N-2020") ? 3 : \
(CMode == "601P-601N") || (CMode == "601P-709") || (CMode == "601P-2020") ? 4 : nop()
Color_B = \
(CMode == "601-2020") || (CMode == "601N-2020") || \
(CMode == "601P-2020") || (CMode == "709-2020") ? 1 : \
(CMode == "601-709") || (CMode == "601N-709") || \
(CMode == "601P-709") || (CMode == "2020-709") ? 2 : \
(CMode == "709-601") || (CMode == "2020-601") ? ((CCorrect == 3) ? 3 : 4) : \
(CMode == "601P-601N") || (CMode == "709-601N") || (CMode == "2020-601N") ? 3 : \
(CMode == "601N-601P") || (CMode == "709-601P") || (CMode == "2020-601P") ? 4 : nop()

ColorConvert = !IsRGBSource ? \
"ConvertYUVtoXYZ(Color=Color_A).ConvertXYZtoYUV(Color=Color_B, PColor=Color_A)" : \
"ConvertRGBtoXYZ(Color=Color_A).ConvertXYZtoRGB(Color=Color_B)"

Dither = (Source_Bits == 16) || (Source_Bits == 32) ? undefined() : !IsRGBSource ? 1 : 0

Input = !IsRGBSource ? \
(IsYV411(Source) ? Source.ConvertToYUV444().ConvertBits(16) : \
IsYUY2(Source) ? Source.ConvertToYV16().ConvertBits(16).ConvertToYUV444() : \
Is444(Source) && (Source_Bits == 16) ? Source : \
Is444(Source) ? Source.ConvertBits(16) : \
(Source_Bits == 16) ? Source.ConvertToYUV444() : \
Source.ConvertBits(16).ConvertToYUV444()) : \
IsRGB64(Source) ? Source : \
IsInterleaved(Source) || (Source_Bits == 16) ? Source.ConvertToRGB64() : \
Source.ConvertBits(16).ConvertToRGB64()

Output = NoResizing_NoResizer ? Input.Eval(ColorConvert) : \
UpScale ? Input.Eval(ColorConvert).Eval(DoResize) : Input.Eval(DoResize).Eval(ColorConvert)

Output = !IsRGBSource ? \
(IsYV411(Source) ? Output.ConvertBits(Source_Bits, dither=Dither).ConvertToYV411() : \
IsYUY2(Source) ? Output.ConvertToYUV422().ConvertBits(Source_Bits, dither=Dither).ConvertToYUY2() : \
Is444(Source) && (Source_Bits == 16) ? Output : \
Is444(Source) ? Output.ConvertBits(Source_Bits, dither=Dither) : \
Is422(Source) && (Source_Bits == 16) ? Output.ConvertToYUV422() : \
Is422(Source) ? Output.ConvertToYUV422().ConvertBits(Source_Bits, dither=Dither) : \
Is420(Source) && (Source_Bits == 16) ? Output.ConvertToYUV420() : \
Output.ConvertToYUV420().ConvertBits(Source_Bits, dither=Dither)) : \
IsRGB64(Source) ? Output : \
IsRGB48(Source) ? Output.ConvertToRGB48() : \
IsRGB32(Source) ? Output.ConvertBits(Source_Bits, dither=Dither).ConvertToRGB32() : \
IsRGB24(Source) ? Output.ConvertBits(Source_Bits, dither=Dither).ConvertToRGB24() : \
HasAlpha(Source) && (Source_Bits == 16) ? Output.ConvertToPlanarRGBA() : \
HasAlpha(Source) ? Output.ConvertToPlanarRGBA().ConvertBits(Source_Bits, dither=Dither) : \
(Source_Bits == 16) ? Output.ConvertToPlanarRGB() : \
Output.ConvertToPlanarRGB().ConvertBits(Source_Bits, dither=Dither)

""", "Color Correct - HDRTools Eval") : (CCorrect == 5) ? Eval("""

# ========== HDRMatrix ==========================================================

assert(!IsRGBSource, C_R + " HDRMatrix doesn't support RGB color conversion " + chr(10))
assert((CMode == "709-601") || (CMode == "601-709"), C_R + \
" HDRMatrix doesn't support " + chr(10) + " UHD color conversions (to/from Rec.2020) " + chr(10))

ColorConvert = (CMode == "709-601") ? \
"Matrix(From=709, To=601, Bitdepth=(Source_Bits == 8) ? 8 : 16)" : \
"Matrix(From=601, To=709, Bitdepth=(Source_Bits == 8) ? 8 : 16)"

Input = IsYUY2(Source) || IsYV411(Source) ? Source.ConvertToYV16() : \
(Source_Bits == 8) || (Source_Bits == 16) ? Source : Source.ConvertBits(16)

Output = NoResizing_NoResizer ? Input.Eval(ColorConvert) : \
UpScale ? Input.Eval(ColorConvert).Eval(DoResize) : Input.Eval(DoResize).Eval(ColorConvert)
Output = IsYUY2(Source) ? Output.ConvertToYUY2() : IsYV411(Source) ? Output.ConvertToYV411() : Output
Output = (Source_Bits == 32) ? Output.ConvertBits(Source_Bits) : \
(Source_Bits == 8) || (Source_Bits == 16) ? Output : Output.ConvertBits(Source_Bits, dither=1)

""", "Color Correct - HDRMatrix Eval") : nop()

# ===============================================================================

assert((PixelType(Source) == PixelType(Output)), C_R + \
" Original=" + PixelType(Source) + "  Output=" + PixelType(Output) + " " + chr(10) + \
" Failed to convert back to the original format " + chr(10) + " after " + \
((CCorrect == 1) || (CCorrect == 2) ? "AVSResize" : \
(CCorrect == 3) || (CCorrect == 4) ? "HDRTools" : "HDRMatrix") + " color correction " + chr(10))

return Output  }

# ===============================================================================
# ===============================================================================
# ========== Global FCropResize Function ========================================
# ===============================================================================
# ===============================================================================

function FCropResize(clip Source, \
bool "Frosty", int "FrostyStatic", int "Clone", bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", int "TSoft", bool "Faster")  {

global G_IsFCR = true
global FCR_Frosty = default(Frosty, true)
global FCR_FrostyStatic = default(FrostyStatic, undefined())
global FCR_Clone = default(Clone, 0)
global FCR_FrostyGradient = default(FrostyGradient, false)
global FCR_FrostyPlain = default(FrostyPlain, false)
global FCR_Plain = default(Plain, false)
global FCR_BColor = default(BColor, undefined())
global FCR_BDivider = default(BDivider, 0)
global FCR_BDColor = default(BDColor, $000000)
global FCR_Feather = default(Feather, 0)
global FCR_Bright = default(Bright, undefined())
global FCR_Cont = default(Cont, undefined())
global FCR_Sat = default(Sat, undefined())
global FCR_Blend = default(Blend, undefined())
global FCR_Blur = default(Blur, undefined())
global FCR_VBlur = default(VBlur, undefined())
global FCR_Iterations = default(Iterations, 3)
global FCR_GPlugin = default(GPlugin, 1)
global FCR_Texture = default(Texture, undefined())
global FCR_TextureC = default(TextureC, undefined())
global FCR_TSoft = default(TSoft, undefined())
global FCR_Faster = default(Faster, false)

return Source  }

# ===============================================================================
# ===============================================================================
# ========== Frosty Borders Function ============================================
# ===============================================================================
# ===============================================================================

function CR_FrostyBorders(clip CRVideo, \
int CRVWidth, int CRVHeight, float F_CRVWidth, float F_CRVHeight, \
int BL, int BT, int BR, int BB, int CWMod, int CHMod, float F_CWMod, float F_CHMod, \
float CRVideo_StorageAR, float Final_StorageAR, bool IsMTResize)  {

# ===============================================================================

Try{  IsFCR = G_IsFCR  }catch(err){  IsFCR = false  }
IsPillarBox = (Final_StorageAR >= CRVideo_StorageAR)
TotalFrames = FrameCount(CRVideo) - 1
CR_FB = " CropResize FrostyBorders " + chr(10)

Frosty = IsFCR ? FCR_Frosty : true
IsFrostyStatic = IsFCR && defined(FCR_FrostyStatic)
FrostyStatic = IsFrostyStatic ? FCR_FrostyStatic : 0
Clone = IsFCR ? FCR_Clone : 0
Clone1 = (Clone == 1)
Clone2 = (Clone == 2)
Clone3 = (Clone == 3)
FrostyGradient = IsFCR ? FCR_FrostyGradient : false
FrostyPlain = IsFCR ? FCR_FrostyPlain : false
Plain = IsFCR ? FCR_Plain : false
BDivider = IsFCR ? FCR_BDivider : 0
BDColor = IsFCR ? FCR_BDColor : $000000
Feather = IsFCR ? FCR_Feather : 0
IsBright = IsFCR && defined(FCR_Bright)
IsCont = IsFCR && defined(FCR_Cont)
IsSat = IsFCR && defined(FCR_Sat)
IsBlend = IsFCR && defined(FCR_Blend)
IsBlur = IsFCR && defined(FCR_Blur)
IsVBlur = IsFCR && defined(FCR_VBlur)
Iterations = IsFCR ? FCR_Iterations : 3
GPlugin = IsFCR ? FCR_GPlugin : 1
IsTSoft = IsFCR && defined(FCR_TSoft)
Faster = IsFCR ? FCR_Faster : false

# ===============================================================================
# ========== Insist =============================================================
# ===============================================================================

assert(!IsRGB(CRVideo), CR_FB + " Frosty=true doesn't support RGB " + chr(10))
assert(!IsFrostyStatic || (0 <= FrostyStatic < TotalFrames), \
CR_FB + string(TotalFrames, " FrostyStatic must be from zero to final frame number (0 - %.0f) ") + chr(10))
assert((0 <= Clone <= 3), CR_FB + " The value for Clone can only be 0, 1, 2 or 3 " + chr(10))
assert(((BDivider == 0) || !IsPillarBox) || \
(((CWMod != 2) || (BDivider % 2 == 0)) && ((CWMod != 4) || (BDivider % 4 == 0))), \
CR_FB + " " + PixelType(CRVideo) + " requires a" + (IsPillarBox && (CWMod == 4) ? " Mod4 " : " Mod2 ") + \
"BDivider for pillarbox borders " + chr(10))
assert(((BDivider == 0) || IsPillarBox) || ((CHMod != 2) || (BDivider % 2 == 0)), \
CR_FB + " " + PixelType(CRVideo) + " requires a Mod2 BDivider for letterbox borders " + chr(10))
assert((Feather == 0) || !FrostyGradient, \
CR_FB + " Feather can't be greater than zero when FrostyGradient=true " + chr(10))
assert((Feather == 0) || (BDivider == 0), \
CR_FB + " Feather and BDivider can't be used together (one must equal zero) " + chr(10))
assert(!IsBright || (-255 <= FCR_Bright <= 255), CR_FB + " The valid range for Bright is -255 thru 255 " + chr(10))
assert(!IsCont || (0 <= FCR_Cont <= 10), CR_FB + " The valid range for Cont is 0.0 thru 10.0 " + chr(10))
assert(!IsSat || (0 <= FCR_Sat <= 10), CR_FB + " The valid range for Sat is 0.0 thru 10.0 " + chr(10))
assert(!IsBlend || (0 <= FCR_Blend <= 1), CR_FB + " The valid range for Blend is 0.0 to 1.0 " + chr(10))
assert((0 <= GPlugin <= 2), CR_FB + \
" The valid choices for GPlugin are " + chr(10) + " 0 (no added grain), 1 (AddGrainC) or 2 (neo_f3kdb) " + chr(10))
assert(!IsTSoft || (0 <= FCR_TSoft <= 7), CR_FB + " The valid range for TSoft is 0 to 7 " + chr(10))

# ===============================================================================
# ========== PillarBox Borders ==================================================
# ===============================================================================

IsPillarBox ? Eval("""

# ========== PillarBox Defaults =================================================

BWMin = Frosty || IsFrostyStatic || FrostyGradient ? ((CWMod == 4) ? 32 : 16) : \
Clone1 || Clone2 || Clone3 ? ((CWMod == 4) ? 8 : 4) : CWMod
WidthTest = (BL >= BWMin <= BR)
IsBDivider = (BDivider > 0) && (BL > BWMin < BR)
IsFeather = (Feather > 0) && (BL >= CWMod <= BR)

FrostyPlain = FrostyPlain && !Plain
FrostyGradient = FrostyGradient && !FrostyPlain && !Plain && WidthTest
Clone1 = Clone1 || (Clone2 && !IsFeather) && !FrostyGradient && !FrostyPlain && !Plain && WidthTest
Clone2 = Clone2 && !FrostyGradient && !FrostyPlain && !Plain && WidthTest && IsFeather
Clone3 = Clone3 && !FrostyGradient && !FrostyPlain && !Plain && WidthTest
IsClone = Clone1 || Clone2 || Clone3
IsFrostyStatic = IsFrostyStatic && !FrostyGradient && !FrostyPlain && !Plain && !IsClone && WidthTest
Frosty = Frosty && !FrostyGradient && !FrostyPlain && !Plain && !IsClone && WidthTest
IsFrosty = Frosty || IsFrostyStatic
Plain = Plain || (!FrostyPlain && !FrostyGradient && !IsClone && !IsFrosty)
IsPlain = FrostyPlain || Plain

BColor = IsFCR && defined(FCR_BColor) ? FCR_BColor : FrostyGradient || FrostyPlain ? $008080 : $000000
Feather = IsFeather ? \
min((Feather < CWMod) ? CWMod : Feather, floor(F_CRVWidth / 6.0 / F_CWMod) * CWMod) : nop()
Bright = IsBright ? FCR_Bright : 0.0
Cont = IsCont ? FCR_Cont : 1.0
Sat = IsSat ? FCR_Sat : !Plain ? 0.85 : 1.0
Blend = IsBlend ? FCR_Blend : IsFrostyStatic ? 0.5 : IsFrosty ? 0.2 : 0.0
Blur = IsBlur ? ((FCR_Blur >= 0) ? FCR_Blur : -FCR_Blur * F_CRVHeight / 720.0) : \
Clone1 || Clone2 ? F_CRVHeight / 75.0 : Clone3 ? F_CRVHeight / 25.0 : 0.0
VBlur = \
IsVBlur ? ((FCR_VBlur >= 0) ? FCR_VBlur : -FCR_VBlur * F_CRVHeight / 720.0) : IsBlur || IsClone ? Blur : 0.0
Texture = IsFCR && defined(FCR_Texture) ? \
((FCR_Texture >= 0) ? FCR_Texture : -FCR_Texture * F_CRVHeight / 720.0) : \
IsClone ? F_CRVHeight / 200 : !Plain ? F_CRVHeight / 100.0 : 0.0
TextureC = IsFCR && defined(FCR_TextureC) ? \
((FCR_TextureC >= 0) ? FCR_TextureC : -FCR_TextureC * F_CRVHeight / 720.0) : 0.0
TSoft = IsTSoft ? FCR_TSoft : IsFrosty ? 5 : Clone3 ? 1 : 0

BL = !IsBDivider ? BL : BL - BDivider
BR = !IsBDivider ? BR : BR - BDivider
FL = IsFeather ? max(BL, floor((BL + (Feather * 3)) / F_CWMod) * CWMod) : nop()
FR = IsFeather ? max(BR, floor((BR + (Feather * 3)) / F_CWMod) * CWMod) : nop()
Texture = (GPlugin == 0) ? 0 : (GPlugin == 1) ? Texture : floor(Texture * 6.0) * 8
TextureC = (GPlugin == 0) ? 0 : (GPlugin == 1) ? TextureC : floor(TextureC * 6.0) * 8

# ========== PillarBox Strings ==================================================

CRVideoS = !IsBDivider ? ",CRVideo," : ",CRVideo.AddBorders(BDivider, 0, BDivider, 0, color=BDColor),"
FastBlurS = (IsPlain && !IsFeather) || FrostyGradient ? "" : \
".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true)"
FBordS = ".AddBorders(0, 0, CRVWidth-FL+BL-FR+BR, 0),"

GaussLS = !IsPlain ? (IsMTResize ? ".GaussResizeMT(BL, CRVHeight)" : ".GaussResize(BL, CRVHeight)") : nop()
GaussRS = !IsPlain ? (IsMTResize ? ".GaussResizeMT(BR, CRVHeight)" : ".GaussResize(BR, CRVHeight)") : nop()
FGaussLS = IsFeather ? (IsMTResize ? ".GaussResizeMT(FL, CRVHeight)" : ".GaussResize(FL, CRVHeight)") : nop()
FGaussRS = IsFeather ? (IsMTResize ? ".GaussResizeMT(FR, CRVHeight)" : ".GaussResize(FR, CRVHeight)") : nop()

Gauss3LS = Clone3 ? (IsMTResize ? \
".GaussResizeMT(max(BL, floor(WidthCloneBorderL * RatioL / F_CWMod) * CWMod), \
max(CRVHeight, floor(CRVHeight * RatioL / F_CHMod) * CHMod))" : \
".GaussResize(max(BL, floor(WidthCloneBorderL * RatioL / F_CWMod) * CWMod), \
max(CRVHeight, floor(CRVHeight * RatioL / F_CHMod) * CHMod))") : nop()
Gauss3RS = Clone3 ? (IsMTResize ? \
".GaussResizeMT(max(BR, floor(WidthCloneBorderR * RatioR / F_CWMod) * CWMod), \
max(CRVHeight, floor(CRVHeight * RatioR / F_CHMod) * CHMod))" : \
".GaussResize(max(BR, floor(WidthCloneBorderR * RatioR / F_CWMod) * CWMod), \
max(CRVHeight, floor(CRVHeight * RatioR / F_CHMod) * CHMod))") : nop()

GPlugS = (GPlugin == 1) ? ".AddGrain(var=Texture, uvar=TextureC, constant=true)" : \
(GPlugin == 2) ? ".neo_f3kdb(range=0, grainY=Texture, grainC=TextureC, dither_algo=1)" : ""

LoopS = ".Trim(1, 1).Loop(TotalFrames)"
StaticLS = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(TotalFrames)" : ""
TSoftS = (TSoft > 0) && (IsFrosty || IsClone) ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : ""
TweakS = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? ".Tweak(bright=Bright, cont=Cont, sat=Sat)" : ""

TwkBlrGrS = TweakS + FastBlurS + GPlugS
TweakBlurS = TweakS + FastBlurS

# ========== PillarBox Frosty Borders ===========================================

FrostyCrop = IsFrosty && (TSoft > 0) ? \
CRVWidth - max(BWMin, round(F_CRVWidth / (!Faster ? 5.0 : 10.0) / F_CWMod) * CWMod) : nop()
FrostyLR = IsFrosty && (TSoft > 0) ? \
Eval("StackHorizontal(CRVideo.crop(0, 0, -FrostyCrop, 0), CRVideo.crop(FrostyCrop, 0, 0, 0))" + TSoftS) : nop()
WidthFrostyLR = IsFrosty && (TSoft > 0) ? width(FrostyLR) : nop()

FrostyCrop = IsFrosty && (TSoft > 0) ? \
WidthFrostyLR - max(BWMin, round(float(WidthFrostyLR) / (!Faster ? 16.0 : 8.0) / F_CWMod) * CWMod) : \
IsFrosty ? CRVWidth - max(BWMin, round(F_CRVWidth / 80.0 / F_CWMod) * CWMod) : nop()

FrostyL = IsFrosty ? ((TSoft > 0) ? \
FrostyLR.crop(0, 0, -FrostyCrop, 0) : CRVideo.crop(0, 0, -FrostyCrop, 0)) : nop()
FrostyR = IsFrosty ? ((TSoft > 0) ? \
FrostyLR.crop(FrostyCrop, 0, 0, 0) : CRVideo.crop(FrostyCrop, 0, 0, 0)) : nop()
WidthFrostyL = IsFrosty ? width(FrostyL) : nop()
WidthFrostyR = IsFrosty ? width(FrostyR) : nop()

FrostyBlendL = IsFrosty ? ((Blend == 0) ? FrostyL : (Blend == 1) ? FrostyR : \
Overlay(FrostyL, FlipHorizontal(FrostyR), Opacity=Blend)) : nop()
FrostyBlendR = IsFrosty ? ((Blend == 0) ? FrostyR : (Blend == 1) ? FrostyL : \
Overlay(FrostyR, FlipHorizontal(FrostyL), Opacity=Blend)) : nop()

Blur = IsBlur ? Blur : IsFrosty ? max(WidthFrostyL, WidthFrostyR) + (!IsFeather ? 0 : Feather) : Blur
VBlur = IsVBlur ? VBlur : IsFrosty ? F_CRVHeight / 10.0 : VBlur

FrostyL = Frosty ? Eval("FrostyBlendL" + TweakBlurS + GaussLS + GPlugS + StaticLS) : nop()
FrostyR = Frosty ? Eval("FrostyBlendR" + TweakBlurS + GaussRS + GPlugS + StaticLS) : nop()

FFrostyL = IsFeather && Frosty ? Eval("FrostyBlendL" + TweakBlurS + FGaussLS + GPlugS + StaticLS) : nop()
FFrostyR = IsFeather && Frosty ? Eval("FrostyBlendR" + TweakBlurS + FGaussRS + GPlugS + StaticLS) : nop()

# ========== PillarBox Clone Borders ============================================

MaxCloneC = (IsFrosty && IsFeather) || IsClone ? floor(F_CRVWidth / 2.0 / F_CWMod) * CWMod : nop()
CloneCropL = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, CRVWidth - BL) : nop()
CloneCropR = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, CRVWidth - BR) : nop()
CloneBorderL = (IsFrosty && IsFeather) || IsClone ? CRVideo.crop(0, 0, -CloneCropL, 0) : nop()
CloneBorderR = (IsFrosty && IsFeather) || IsClone ? CRVideo.crop(CloneCropR, 0, 0, 0) : nop()
WidthCloneBorderL = (IsFrosty && IsFeather) || IsClone ? width(CloneBorderL) : nop()
WidthCloneBorderR = (IsFrosty && IsFeather) || IsClone ? width(CloneBorderR) : nop()

FlipCloneL = (IsFrosty && IsFeather) || IsClone ? \
FlipHorizontal(((WidthCloneBorderL == BL) ? CloneBorderL : Eval("CloneBorderL" + GaussLS))) : nop()
FlipCloneR = (IsFrosty && IsFeather) || IsClone ? \
FlipHorizontal(((WidthCloneBorderR == BR) ? CloneBorderR : Eval("CloneBorderR" + GaussRS))) : nop()

CloneLR = \
(TSoft > 0) && (Clone1 || Clone3) ? Eval("StackHorizontal(CloneBorderL, CloneBorderR)" + TSoftS) : nop()
WidthCloneLR = (TSoft > 0) && (Clone1 || Clone3) ? width(CloneLR) : nop()

CloneL = (TSoft > 0) && (Clone1 || Clone3) ? \
CloneLR.crop(0, 0, -WidthCloneLR+WidthCloneBorderL, 0) : (Clone1 || Clone3) ? CloneBorderL : nop()
CloneR = (TSoft > 0) && (Clone1 || Clone3) ? \
CloneLR.crop(WidthCloneLR-WidthCloneBorderR, 0, 0, 0) : (Clone1 || Clone3) ? CloneBorderR : nop()

CloneBlendL = Clone1 || Clone3 ? ((Blend == 0) ? CloneL : (Blend == 1) ? CloneR : \
Overlay(CloneL, FlipHorizontal(CloneR), Opacity=Blend)) : nop()
CloneBlendR = Clone1 || Clone3 ? ((Blend == 0) ? CloneR : (Blend == 1) ? CloneL : \
Overlay(CloneR, FlipHorizontal(CloneL), Opacity=Blend)) : nop()

FCloneL = \
IsFeather && Clone1 ? ((WidthCloneBorderL == BL) ? CloneBlendL : Eval("CloneBlendL" + GaussLS)) : nop()
FCloneR = \
IsFeather && Clone1 ? ((WidthCloneBorderR == BR) ? CloneBlendR : Eval("CloneBlendR" + GaussRS)) : nop()

CloneL = !IsFeather && Clone1 ? ((WidthCloneBorderL == BL) ? \
Eval("CloneBlendL" + TwkBlrGrS) : Eval("CloneBlendL" + TweakBlurS + GaussLS + GPlugS)) : nop()
CloneR = !IsFeather && Clone1 ? ((WidthCloneBorderR == BR) ? \
Eval("CloneBlendR" + TwkBlrGrS) : Eval("CloneBlendR" + TweakBlurS + GaussRS + GPlugS)) : nop()

# ========== PillarBox Clone2 Borders ===========================================

Clone2CropL = Clone2 ? max(MaxCloneC, CRVWidth - FL) : nop()
Clone2CropR = Clone2 ? max(MaxCloneC, CRVWidth - FR) : nop()
Clone2BL = Clone2 ? CRVideo.crop(0, 0, -Clone2CropL, 0) : nop()
Clone2BR = Clone2 ? CRVideo.crop(Clone2CropR, 0, 0, 0) : nop()
WidthClone2BL = Clone2 ? width(Clone2BL) : nop()
WidthClone2BR = Clone2 ? width(Clone2BR) : nop()

FlipClone2L = Clone2 ? FlipHorizontal(((WidthClone2BL == FL) ? Clone2BL : Eval("Clone2BL" + FGaussLS))) : nop()
FlipClone2R = Clone2 ? FlipHorizontal(((WidthClone2BR == FR) ? Clone2BR : Eval("Clone2BR" + FGaussRS))) : nop()

Clone2LR = (TSoft > 0) && Clone2 ? Eval("StackHorizontal(Clone2BL, Clone2BR)" + TSoftS) : nop()
WidthClone2LR = (TSoft > 0) && Clone2 ? width(Clone2LR) : nop()

Clone2L = (TSoft > 0) && Clone2 ? \
Clone2LR.crop(0, 0, -WidthClone2LR+WidthClone2BL, 0) : Clone2 ? Clone2BL : nop()
Clone2R = (TSoft > 0) && Clone2 ? \
Clone2LR.crop(WidthClone2LR-WidthClone2BR, 0, 0, 0) : Clone2 ? Clone2BR : nop()

Clone2BlendL = Clone2 ? ((Blend == 0) ? Clone2L : (Blend == 1) ? Clone2R : \
Overlay(Clone2L, FlipHorizontal(Clone2R), Opacity=Blend)) : nop()
Clone2BlendR = Clone2 ? ((Blend == 0) ? Clone2R : (Blend == 1) ? Clone2L : \
Overlay(Clone2R, FlipHorizontal(Clone2L), Opacity=Blend)) : nop()

Clone2L = Clone2 ? ((WidthClone2BL == FL) ? Eval("Clone2BlendL" + TwkBlrGrS) : \
Eval("Clone2BlendL" + TweakBlurS + FGaussLS + GPlugS)) : nop()
Clone2R = Clone2 ? ((WidthClone2BR == FR) ? Eval("Clone2BlendR" + TwkBlrGrS) : \
Eval("Clone2BlendR" + TweakBlurS + FGaussRS + GPlugS)) : nop()

# ========== PillarBox Clone3 Borders ===========================================

RatioL = Clone3 ? (WidthCloneBorderL - BL >= 0) ? 1.618 : float(BL) / float(WidthCloneBorderL) : nop()
RatioR = Clone3 ? (WidthCloneBorderR - BR >= 0) ? 1.618 : float(BR) / float(WidthCloneBorderR) : nop()

Clone3L = Clone3 ? Eval("CloneBlendL" + Gauss3LS) : nop()
Clone3R = Clone3 ? Eval("CloneBlendR" + Gauss3RS) : nop()
WidthClone3L = Clone3 ? width(Clone3L) : nop()
HeightClone3L = Clone3 ? height(Clone3L) : nop()
WidthClone3R = Clone3 ? width(Clone3R) : nop()
HeightClone3R = Clone3 ? height(Clone3R) : nop()

Clone3L_CL = Clone3 ? max(0, floor((WidthClone3L - BL) / F_CWMod / 2.0) * CWMod) : nop()
Clone3L_CR = Clone3 ? max(0, WidthClone3L - BL - Clone3L_CL) : nop()
Clone3L_CT = Clone3 ? max(0, floor((HeightClone3L - CRVHeight) / F_CHMod / 2.0) * CHMod) : nop()
Clone3L_CB = Clone3 ? max(0, HeightClone3L - CRVHeight - Clone3L_CT) : nop()
Clone3R_CL = Clone3 ? max(0, floor((WidthClone3R - BR) / F_CWMod / 2.0) * CWMod) : nop()
Clone3R_CR = Clone3 ? max(0, WidthClone3R - BR - Clone3R_CL) : nop()
Clone3R_CT = Clone3 ? max(0, floor((HeightClone3R - CRVHeight) / F_CHMod / 2.0) * CHMod) : nop()
Clone3R_CB = Clone3 ? max(0, HeightClone3R - CRVHeight - Clone3L_CT) : nop()

Clone3L = Clone3 ? Clone3L.crop(Clone3L_CL, Clone3L_CT, -Clone3L_CR, -Clone3L_CB) : nop()
Clone3R = Clone3 ? Clone3R.crop(Clone3R_CL, Clone3R_CT, -Clone3R_CR, -Clone3R_CB) : nop()

FClone3L = IsFeather && Clone3 ? Clone3L : nop()
FClone3R = IsFeather && Clone3 ? Clone3R : nop()

Clone3L = !IsFeather && Clone3 ? Eval("Clone3L" + TwkBlrGrS) : nop()
Clone3R = !IsFeather && Clone3 ? Eval("Clone3R" + TwkBlrGrS) : nop()

# ========== PillarBox FrostyGradient Borders ===================================

GradientLR = \
FrostyGradient ? BlankClip(CRVideo, width=88, height=CRVHeight).AddBorders(8, 0, 0, 0, color=BColor)\
.Tweak(bright=Bright, cont=Cont, sat=Sat).FastBlur(50, y_blur=0, iterations=3, dither=true) : nop()
GradientL = FrostyGradient ? Eval("FlipHorizontal(GradientLR)" + GaussLS + GPlugS + LoopS) : nop()
GradientR = FrostyGradient ? Eval("GradientLR" + GaussRS + GPlugS + LoopS) : nop()

# ========== PillarBox Plain Borders ============================================

PlainL = IsPlain && (BL >= CWMod) ? \
Eval("BlankClip(CRVideo, width=BL, color=BColor)" + TweakS + GPlugS + LoopS) : nop()
PlainR = IsPlain && (BR >= CWMod) ? \
Eval("BlankClip(CRVideo, width=BR, color=BColor)" + TweakS + GPlugS + LoopS) : nop()

PlainL2 = IsFeather && IsPlain ? Eval("BlankClip(CRVideo, width=BL, color=BColor)" + TweakS + LoopS) : nop()
PlainR2 = IsFeather && IsPlain ? Eval("BlankClip(CRVideo, width=BR, color=BColor)" + TweakS + LoopS) : nop()

# ========== PillarBox Frosty Video =============================================

FrostyBL = !IsFeather ? (IsFrosty ? FrostyL : Clone1 ? CloneL : Clone3 ? Clone3L : \
FrostyGradient ? GradientL : IsPlain && (BL >= CWMod) ? PlainL : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneL : IsPlain && (BL >= CWMod) ? PlainL2 : nop()

FrostyBR = !IsFeather ? (IsFrosty ? FrostyR : Clone1 ? CloneR : Clone3 ? Clone3R : \
FrostyGradient ? GradientR :IsPlain && (BR >= CWMod) ? PlainR : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneR : IsPlain && (BR >= CWMod) ? PlainR2 : nop()

FrostyOut = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BL >= CWMod <= BR)) ? \
Eval("StackHorizontal(FrostyBL" + CRVideoS + "FrostyBR)") : \
IsPlain && (BL >= CWMod) ? StackHorizontal(FrostyBL, CRVideo) : \
IsPlain && (BR >= CWMod) ? StackHorizontal(CRVideo, FrostyBR) : CRVideo

# ========== PillarBox Feather Mask =============================================

FeatherMask = IsFeather ? BlankClip(CRVideo, width=CRVWidth-(Feather*2))\
.AddBorders(BL+Feather, 0, BR+Feather, 0, color=$FFFFFF).ColorYUV(Levels="TV->PC")\
.FastBlur(Feather/2.25, y_blur=0, iterations=3, dither=true) : nop()

FeatherMask = IsFeather ? Eval("FeatherMask" + LoopS) : nop()

# ========== PillarBox Feather Clip =============================================

FeatherClip = IsFeather ? \
(IsFrosty ? StackHorizontal(FFrostyL.AddBorders(0, 0, CRVWidth-FL+BL-FR+BR, 0), FFrostyR) : \
Clone1 ? Eval("StackHorizontal(StackHorizontal(FCloneL, CRVideo.crop(0, 0, -CRVWidth+FL-BL, 0))" + \
TwkBlrGrS + FBordS + "StackHorizontal(CRVideo.crop(CRVWidth-FR+BR, 0, 0, 0), FCloneR)" + TwkBlrGrS + ")")  : \
Clone2 ? StackHorizontal(Clone2L.AddBorders(0, 0, CRVWidth-FL+BL-FR+BR, 0), Clone2R) : \
Clone3 ? Eval("StackHorizontal(StackHorizontal(FClone3L, CRVideo.crop(0, 0, -CRVWidth+FL-BL, 0))" + \
TwkBlrGrS + FBordS + "StackHorizontal(CRVideo.crop(CRVWidth-FR+BR, 0, 0, 0), FClone3R)" + TwkBlrGrS + ")") : \
Eval("StackHorizontal(BlankClip(CRVideo, width=FL, color=BColor)" + TweakS + GPlugS + LoopS + \
FBordS + "BlankClip(CRVideo, width=FR, color=BColor)" + TweakS + GPlugS + LoopS + ")")) : nop()

# ========== PillarBox Output ===================================================

FrostyOut = !IsFeather ? FrostyOut : Overlay(FrostyOut, FeatherClip, mask=FeatherMask)

# ===============================================================================
# ========== LetterBox Borders ==================================================
# ===============================================================================

""", "CropResize FrostyBorders PillarBox Eval") : Eval("""

# ========== LetterBox Defaults =================================================

BHMin = Frosty || IsFrostyStatic || FrostyGradient ? 16 : Clone1 || Clone2 || Clone3 ? 4 : CHMod
HeightTest = (BT >= BHMin <= BB)
IsBDivider = (BDivider > 0) && (BT > BHMin < BB)
IsFeather = (Feather > 0) && (BT >= CHMod <= BB)

FrostyPlain = FrostyPlain && !Plain
FrostyGradient = FrostyGradient && !FrostyPlain && !Plain && HeightTest
Clone1 = Clone1 || (Clone2 && !IsFeather) && !FrostyGradient && !FrostyPlain && !Plain && HeightTest
Clone2 = Clone2 && !FrostyGradient && !FrostyPlain && !Plain && HeightTest && IsFeather
Clone3 = Clone3 && !FrostyGradient && !FrostyPlain && !Plain && HeightTest
IsClone = Clone1 || Clone2 || Clone3
IsFrostyStatic = IsFrostyStatic && !FrostyGradient && !FrostyPlain && !Plain && !IsClone && HeightTest
Frosty = Frosty && !FrostyGradient && !FrostyPlain && !Plain && !IsClone && HeightTest
IsFrosty = Frosty || IsFrostyStatic
Plain = Plain || (!FrostyPlain && !FrostyGradient && !IsClone && !IsFrosty)
IsPlain = FrostyPlain || Plain

BColor = IsFCR && defined(FCR_BColor) ? FCR_BColor : FrostyGradient || FrostyPlain ? $008080 : $000000
Feather = IsFeather ? \
min((Feather < CHMod) ? CHMod : Feather, floor(F_CRVHeight / 6.0 / F_CHMod) * CHMod) : nop()
Bright = IsBright ? FCR_Bright : !Plain ? -25.0 : 0.0
Cont = IsCont ? FCR_Cont : !Plain ? 0.66 : 1.0
Sat = IsSat ? FCR_Sat : !Plain ? 0.66 : 1.0
Blend = IsBlend ? FCR_Blend : IsFrostyStatic ? 0.5 : IsFrosty ? 0.2 : 0.0
Blur = IsBlur ? ((FCR_Blur >= 0) ? FCR_Blur : -FCR_Blur * F_CRVWidth / 720.0) : \
Clone1 || Clone2 ? F_CRVWidth / 75.0 : Clone3 ? F_CRVWidth / 25.0 : 0.0
VBlur = \
IsVBlur ? ((FCR_VBlur >= 0) ? FCR_VBlur : -FCR_VBlur * F_CRVWidth / 720.0) : IsBlur || IsClone ? Blur : 0.0
Texture = IsFCR && defined(FCR_Texture) ? \
((FCR_Texture >= 0) ? FCR_Texture : -FCR_Texture * F_CRVWidth / 720.0) : \
IsClone ? F_CRVWidth / 200 : !Plain ? F_CRVWidth / 100.0 : 0.0
TextureC = IsFCR && defined(FCR_TextureC) ? \
((FCR_TextureC >= 0) ? FCR_TextureC : -FCR_TextureC * F_CRVWidth / 720.0) : 0.0
TSoft = IsTSoft ? FCR_TSoft : IsFrosty ? 5 : Clone3 ? 1 : 0

BT = !IsBDivider ? BT : BT - BDivider
BB = !IsBDivider ? BB : BB - BDivider
FT = IsFeather ? max(BT, floor((BT + (Feather * 3)) / F_CHMod) * CHMod) : nop()
FB = IsFeather ? max(BB, floor((BB + (Feather * 3)) / F_CHMod) * CHMod) : nop()
Texture = (GPlugin == 0) ? 0 : (GPlugin == 1) ? Texture : floor(Texture * 6.0) * 8
TextureC = (GPlugin == 0) ? 0 : (GPlugin == 1) ? TextureC : floor(TextureC * 6.0) * 8

# ========== LetterBox Strings ==================================================

CRVideoS = !IsBDivider ? ",CRVideo," : ",CRVideo.AddBorders(0, BDivider, 0, BDivider, color=BDColor),"
FastBlurS = (IsPlain && !IsFeather) || FrostyGradient ? "" : \
".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true)"
FBordS = ".AddBorders(0, 0, 0, CRVHeight-FT+BT-FB+BB),"

GaussTS = !IsPlain ? (IsMTResize ? ".GaussResizeMT(CRVWidth, BT)" : ".GaussResize(CRVWidth, BT)") : nop()
GaussBS = !IsPlain ? (IsMTResize ? ".GaussResizeMT(CRVWidth, BB)" : ".GaussResize(CRVWidth, BB)") : nop()
FGaussTS = IsFeather ? (IsMTResize ? ".GaussResizeMT(CRVWidth, FT)" : ".GaussResize(CRVWidth, FT)") : nop()
FGaussBS = IsFeather ? (IsMTResize ? ".GaussResizeMT(CRVWidth, FB)" : ".GaussResize(CRVWidth, FB)") : nop()

Gauss3TS = Clone3 ? (IsMTResize ? \
".GaussResizeMT(max(CRVWidth, floor(CRVWidth * RatioT / F_CWMod) * CWMod), \
max(BT, floor(HeightCloneBorderT * RatioT / F_CHMod) * CHMod))" : \
".GaussResize(max(CRVWidth, floor(CRVWidth * RatioT / F_CWMod) * CWMod), \
max(BT, floor(HeightCloneBorderT * RatioT / F_CHMod) * CHMod))") : nop()
Gauss3BS = Clone3 ? (IsMTResize ? \
".GaussResizeMT(max(CRVWidth, floor(CRVWidth * RatioB / F_CWMod) * CWMod), \
max(BB, floor(HeightCloneBorderB * RatioB / F_CHMod) * CHMod))" : \
".GaussResize(max(CRVWidth, floor(CRVWidth * RatioB / F_CWMod) * CWMod), \
max(BB, floor(HeightCloneBorderB * RatioB / F_CHMod) * CHMod))") : nop()

GPlugS = (GPlugin == 1) ? ".AddGrain(var=Texture, uvar=TextureC, constant=true)" : \
(GPlugin == 2) ? ".neo_f3kdb(range=0, grainY=Texture, grainC=TextureC, dither_algo=1)" : ""

LoopS = ".Trim(1, 1).Loop(TotalFrames)"
StaticLS = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(TotalFrames)" : ""
TSoftS = (TSoft > 0) && (IsFrosty || IsClone) ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : ""
TweakS = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? ".Tweak(bright=Bright, cont=Cont, sat=Sat)" : ""

TwkBlrGrS = TweakS + FastBlurS + GPlugS
TweakBlurS = TweakS + FastBlurS

# ========== LetterBox Frosty Borders ===========================================

FrostyCrop = IsFrosty && (TSoft > 0) ? \
CRVHeight - max(BHMin, round(F_CRVHeight / (!Faster ? 5.0 : 10.0) / F_CHMod) * CHMod) : nop()
FrostyTB = IsFrosty && (TSoft > 0) ? \
Eval("StackVertical(CRVideo.crop(0, 0, 0, -FrostyCrop), CRVideo.crop(0, FrostyCrop, 0, 0))" + TSoftS) : nop()
HeightFrostyTB = IsFrosty && (TSoft > 0) ? height(FrostyTB) : nop()

FrostyCrop = IsFrosty && (TSoft > 0) ? \
HeightFrostyTB - max(BHMin, round(float(HeightFrostyTB) / (!Faster ? 16.0 : 8.0) / F_CHMod) * CHMod) : \
IsFrosty ? CRVHeight - max(BHMin, round(F_CRVHeight / 80.0 / F_CHMod) * CHMod) : nop()

FrostyT = IsFrosty ? ((TSoft > 0) ? \
FrostyTB.crop(0, 0, 0, -FrostyCrop) : CRVideo.crop(0, 0, 0, -FrostyCrop)) : nop()
FrostyB = IsFrosty ? ((TSoft > 0) ? \
FrostyTB.crop(0, FrostyCrop, 0, 0) : CRVideo.crop(0, FrostyCrop, 0, 0)) : nop()
HeightFrostyT = IsFrosty ? height(FrostyT) : nop()
HeightFrostyB = IsFrosty ? height(FrostyB) : nop()

FrostyBlendT = IsFrosty ? ((Blend == 0) ? FrostyT : (Blend == 1) ? FrostyB : \
Overlay(FrostyT, FlipVertical(FrostyB), Opacity=Blend)) : nop()
FrostyBlendB = IsFrosty ? ((Blend == 0) ? FrostyB : (Blend == 1) ? FrostyT : \
Overlay(FrostyB, FlipVertical(FrostyT), Opacity=Blend)) : nop()

Blur = IsBlur ? Blur : IsFrosty ? F_CRVWidth / 10.0 : Blur
VBlur = IsVBlur ? VBlur : IsFrosty ? max(HeightFrostyT, HeightFrostyB) + (!IsFeather ? 0 : Feather) : VBlur

FrostyT = Frosty ? Eval("FrostyBlendT" + TweakBlurS + GaussTS + GPlugS + StaticLS) : nop()
FrostyB = Frosty ? Eval("FrostyBlendB" + TweakBlurS + GaussBS + GPlugS + StaticLS) : nop()

FFrostyT = IsFeather && Frosty ? Eval("FrostyBlendT" + TweakBlurS + FGaussTS + GPlugS + StaticLS) : nop()
FFrostyB = IsFeather && Frosty ? Eval("FrostyBlendB" + TweakBlurS + FGaussBS + GPlugS + StaticLS) : nop()

# ========== LetterBox Clone Borders ============================================

MaxCloneC = (IsFrosty && IsFeather) || IsClone ? floor(F_CRVHeight / 2.0 / F_CHMod) * CHMod : nop()
CloneCropT = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, CRVHeight - BT) : nop()
CloneCropB = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, CRVHeight - BB) : nop()
CloneBorderT = (IsFrosty && IsFeather) || IsClone ? CRVideo.crop(0, 0, 0, -CloneCropT) : nop()
CloneBorderB = (IsFrosty && IsFeather) || IsClone ? CRVideo.crop(0, CloneCropB, 0, 0) : nop()
HeightCloneBorderT = (IsFrosty && IsFeather) || IsClone ? height(CloneBorderT) : nop()
HeightCloneBorderB = (IsFrosty && IsFeather) || IsClone ? height(CloneBorderB) : nop()

FlipCloneT = (IsFrosty && IsFeather) || IsClone ? \
FlipVertical(((HeightCloneBorderT == BT) ? CloneBorderT : Eval("CloneBorderT" + GaussTS))) : nop()
FlipCloneB = (IsFrosty && IsFeather) || IsClone ? \
FlipVertical(((HeightCloneBorderB == BB) ? CloneBorderB : Eval("CloneBorderB" + GaussBS))) : nop()

CloneTB = \
(TSoft > 0) && (Clone1 || Clone3) ? Eval("StackVertical(CloneBorderT, CloneBorderB)" + TSoftS) : nop()
HeightCloneTB = (TSoft > 0) && (Clone1 || Clone3) ? height(CloneTB) : nop()

CloneT = (TSoft > 0) && (Clone1 || Clone3) ? \
CloneTB.crop(0, 0, 0, -HeightCloneTB+HeightCloneBorderT) : (Clone1 || Clone3) ? CloneBorderT : nop()
CloneB = (TSoft > 0) && (Clone1 || Clone3) ? \
CloneTB.crop(0, HeightCloneTB-HeightCloneBorderB, 0, 0) : (Clone1 || Clone3) ? CloneBorderB : nop()

CloneBlendT = Clone1 || Clone3 ? ((Blend == 0) ? CloneT : (Blend == 1) ? CloneB : \
Overlay(CloneT, FlipVertical(CloneB), Opacity=Blend)) : nop()
CloneBlendB = Clone1 || Clone3 ? ((Blend == 0) ? CloneB : (Blend == 1) ? CloneT : \
Overlay(CloneB, FlipVertical(CloneT), Opacity=Blend)) : nop()

FCloneT = \
IsFeather && Clone1 ? ((HeightCloneBorderT == BT) ? CloneBlendT : Eval("CloneBlendT" + GaussTS)) : nop()
FCloneB = \
IsFeather && Clone1 ? ((HeightCloneBorderB == BB) ? CloneBlendB : Eval("CloneBlendB" + GaussBS)) : nop()

CloneT = !IsFeather && Clone1 ? ((HeightCloneBorderT == BT) ? \
Eval("CloneBlendT" + TwkBlrGrS) : Eval("CloneBlendT" + TweakBlurS + GaussTS + GPlugS)) : nop()
CloneB = !IsFeather && Clone1 ? ((HeightCloneBorderB == BB) ? \
Eval("CloneBlendB" + TwkBlrGrS) : Eval("CloneBlendB" + TweakBlurS + GaussBS + GPlugS)) : nop()

# ========== LetterBox Clone2 Borders ===========================================

Clone2CropT = Clone2 ? max(MaxCloneC, CRVHeight - FT) : nop()
Clone2CropB = Clone2 ? max(MaxCloneC, CRVHeight - FB) : nop()
Clone2BT = Clone2 ? CRVideo.crop(0, 0, 0, -Clone2CropT) : nop()
Clone2BB = Clone2 ? CRVideo.crop(0, Clone2CropB, 0, 0) : nop()
HeightClone2BT = Clone2 ? height(Clone2BT) : nop()
HeightClone2BB = Clone2 ? height(Clone2BB) : nop()

FlipClone2T = Clone2 ? FlipVertical(((HeightClone2BT == FT) ? Clone2BT : Eval("Clone2BT" + FGaussTS))) : nop()
FlipClone2B = Clone2 ? FlipVertical(((HeightClone2BB == FB) ? Clone2BB : Eval("Clone2BB" + FGaussBS))) : nop()

Clone2TB = (TSoft > 0) && Clone2 ? Eval("StackVertical(Clone2BT, Clone2BB)" + TSoftS) : nop()
HeightClone2TB = (TSoft > 0) && Clone2 ? height(Clone2TB) : nop()

Clone2T = (TSoft > 0) && Clone2 ? \
Clone2TB.crop(0, 0, 0, -HeightClone2TB+HeightClone2BT) : Clone2 ? Clone2BT : nop()
Clone2B = (TSoft > 0) && Clone2 ? \
Clone2TB.crop(0, HeightClone2TB-HeightClone2BB, 0, 0) : Clone2 ? Clone2BB : nop()

Clone2BlendT = Clone2 ? ((Blend == 0) ? Clone2T : (Blend == 1) ? Clone2B : \
Overlay(Clone2T, FlipVertical(Clone2B), Opacity=Blend)) : nop()
Clone2BlendB = Clone2 ? ((Blend == 0) ? Clone2B : (Blend == 1) ? Clone2T : \
Overlay(Clone2B, FlipVertical(Clone2T), Opacity=Blend)) : nop()

Clone2T = Clone2 ? ((HeightClone2BT == FT) ? Eval("Clone2BlendT" + TwkBlrGrS) : \
Eval("Clone2BlendT" + TweakBlurS + FGaussTS + GPlugS)) : nop()
Clone2B = Clone2 ? ((HeightClone2BB == FB) ? Eval("Clone2BlendB" + TwkBlrGrS) : \
Eval("Clone2BlendB" + TweakBlurS + FGaussBS + GPlugS)) : nop()

# ========== LetterBox Clone3 Borders ===========================================

RatioT = Clone3 ? (HeightCloneBorderT - BT >= 0) ? 1.618 : float(BT) / float(HeightCloneBorderT) : nop()
RatioB = Clone3 ? (HeightCloneBorderB - BB >= 0) ? 1.618 : float(BB) / float(HeightCloneBorderB) : nop()

Clone3T = Clone3 ? Eval("CloneBlendT" + Gauss3TS) : nop()
Clone3B = Clone3 ? Eval("CloneBlendB" + Gauss3BS) : nop()
WidthClone3T = Clone3 ? width(Clone3T) : nop()
HeightClone3T = Clone3 ? height(Clone3T) : nop()
WidthClone3B = Clone3 ? width(Clone3B) : nop()
HeightClone3B = Clone3 ? height(Clone3B) : nop()

Clone3T_CL = Clone3 ? max(0, floor((WidthClone3T - CRVWidth) / F_CWMod / 2.0) * CWMod) : nop()
Clone3T_CR = Clone3 ? max(0, WidthClone3T - CRVWidth - Clone3T_CL) : nop()
Clone3T_CT = Clone3 ? max(0, floor((HeightClone3T - BT) / F_CHMod / 2.0) * CHMod) : nop()
Clone3T_CB = Clone3 ? max(0, HeightClone3T - BT - Clone3T_CT) : nop()
Clone3B_CL = Clone3 ? max(0, floor((WidthClone3B - CRVWidth) / F_CWMod / 2.0) * CWMod) : nop()
Clone3B_CR = Clone3 ? max(0, WidthClone3B - CRVWidth - Clone3B_CL) : nop()
Clone3B_CT = Clone3 ? max(0, floor((HeightClone3B - BB) / F_CHMod / 2.0) * CHMod) : nop()
Clone3B_CB = Clone3 ? max(0, HeightClone3B - BB - Clone3B_CT) : nop()

Clone3T = Clone3 ? Clone3T.crop(Clone3T_CL, Clone3T_CT, -Clone3T_CR, -Clone3T_CB) : nop()
Clone3B = Clone3 ? Clone3B.crop(Clone3B_CL, Clone3B_CT, -Clone3B_CR, -Clone3B_CB) : nop()

FClone3T = IsFeather && Clone3 ? Clone3T : nop()
FClone3B = IsFeather && Clone3 ? Clone3B : nop()

Clone3T = !IsFeather && Clone3 ? Eval("Clone3T" + TwkBlrGrS) : nop()
Clone3B = !IsFeather && Clone3 ? Eval("Clone3B" + TwkBlrGrS) : nop()

# ========== LetterBox FrostyGradient Borders ===================================

GradientTB = \
FrostyGradient ? BlankClip(CRVideo, width=CRVWidth, height=88).AddBorders(0, 8, 0, 0, color=BColor)\
.Tweak(bright=Bright, cont=Cont, sat=Sat).FastBlur(0, y_blur=50, iterations=3, dither=true) : nop()
GradientT = FrostyGradient ? Eval("FlipVertical(GradientTB)" + GaussTS + GPlugS + LoopS) : nop()
GradientB = FrostyGradient ? Eval("GradientTB" + GaussBS + GPlugS + LoopS) : nop()

# ========== LetterBox Plain Borders ============================================

PlainT = IsPlain && (BT >= CHMod) ? \
Eval("BlankClip(CRVideo, height=BT, color=BColor)" + TweakS + GPlugS + LoopS) : nop()
PlainB = IsPlain && (BB >= CHMod) ? \
Eval("BlankClip(CRVideo, height=BB, color=BColor)" + TweakS + GPlugS + LoopS) : nop()

PlainT2 = IsFeather && IsPlain ? Eval("BlankClip(CRVideo, height=BT, color=BColor)" + TweakS + LoopS) : nop()
PlainB2 = IsFeather && IsPlain ? Eval("BlankClip(CRVideo, height=BB, color=BColor)" + TweakS + LoopS) : nop()

# ========== LetterBox Frosty Video =============================================

FrostyBT = !IsFeather ? (IsFrosty ? FrostyT : Clone1 ? CloneT : Clone3 ? Clone3T : \
FrostyGradient ? GradientT : IsPlain && (BT >= CHMod) ? PlainT : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneT : IsPlain && (BT >= CHMod) ? PlainT2 : nop()

FrostyBB = !IsFeather ? (IsFrosty ? FrostyB : Clone1 ? CloneB : Clone3 ? Clone3B : \
FrostyGradient ? GradientB : IsPlain && (BB >= CHMod) ? PlainB : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneB : IsPlain && (BB >= CHMod) ? PlainB2 : nop()

FrostyOut = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BT >= CHMod <= BB)) ? \
Eval("StackVertical(FrostyBT" + CRVideoS + "FrostyBB)") : \
IsPlain && (BT >= CHMod) ? StackVertical(FrostyBT, CRVideo) : \
IsPlain && (BB >= CHMod) ? StackVertical(CRVideo, FrostyBB) : CRVideo

# ========== LetterBox Feather Mask =============================================

FeatherMask = IsFeather ? BlankClip(CRVideo, height=CRVHeight-(Feather*2))\
.AddBorders(0, BT+Feather, 0, BB+Feather, color=$FFFFFF).ColorYUV(Levels="TV->PC")\
.FastBlur(0, y_blur=Feather/2.25, iterations=3, dither=true) : nop()

FeatherMask = IsFeather ? Eval("FeatherMask" + LoopS) : nop()

# ========== LetterBox Feather Clip =============================================

FeatherClip = IsFeather ? \
(IsFrosty ? StackVertical(FFrostyT.AddBorders(0, 0, 0, CRVHeight-FT+BT-FB+BB),  FFrostyB) : \
Clone1 ? Eval("StackVertical(StackVertical(FCloneT, CRVideo.crop(0, 0, 0, -CRVHeight+FT-BT))" + \
TwkBlrGrS + FBordS + "StackVertical(CRVideo.crop(0, CRVHeight-FB+BB, 0, 0), FCloneB)" + TwkBlrGrS + ")")  : \
Clone2 ? StackVertical(Clone2T.AddBorders(0, 0, 0, CRVHeight-FT+BT-FB+BB), Clone2B) : \
Clone3 ? Eval("StackVertical(StackVertical(FClone3T, CRVideo.crop(0, 0, 0, -CRVHeight+FT-BT))" + \
TwkBlrGrS + FBordS + "StackVertical(CRVideo.crop(0, CRVHeight-FB+BB, 0, 0), FClone3B)" + TwkBlrGrS + ")") : \
Eval("StackVertical(BlankClip(CRVideo, height=FT, color=BColor)" + TweakS + GPlugS + LoopS + \
FBordS + "BlankClip(CRVideo, height=FB, color=BColor)" + TweakS + GPlugS + LoopS + ")")) : nop()

# ========== LetterBox Output =================================================

FrostyOut = !IsFeather ? FrostyOut : Overlay(FrostyOut, FeatherClip, mask=FeatherMask)

""", "CropResize FrostyBorders LetterBox Eval")

# ========== FrostyBorders Output ===============================================

return FrostyOut  }

# ===============================================================================
# ===============================================================================
# ========== Format String Function (Remove Zeros) ==============================
# ===============================================================================
# ===============================================================================

function CR_FS(float F, int "Keep1", int "Limit")  {

Keep = (default(Keep1, 0) > 0)
Lim = default(Limit, 3)
IsDec = (abs(round(F) - F) > 0.000005)
S = !IsDec ? string(F,"%.0f") : (Lim == 2) ? string(F,"%.2f") : (Lim == 3) ? string(F,"%.3f") : \
(Lim == 4) ? string(F,"%.4f") : (Lim == 5) ? string(F,"%.5f") : string(F,"%.6f")
SLength = StrLen(S)
DecPos = FindStr(S, ".")
LeftS = IsDec ? LeftStr(S, DecPos) : S
RightS = IsDec ? RightStr(S, SLength - DecPos) : ""
RightSLength = StrLen(RightS)
RightSx = RightS + "x"

Delx = (FindStr(RightSx, "000000x") > 0) ? 6 : (FindStr(RightSx, "00000x") > 0) ? 5 : \
(FindStr(RightSx, "0000x") > 0) ? 4 : (FindStr(RightSx, "000x") > 0) ? 3 : \
(FindStr(RightSx, "00x") > 0) ? 2 : (FindStr(RightSx, "0x") > 0) ? 1 : 0

return LeftS + MidStr(RightS, 1, RightSLength - Delx) + (!IsDec && Keep ? ".0" : "")  }

# ===============================================================================
# ===============================================================================
# ========== Float To Fraction Function =========================================
# ===============================================================================
# ===============================================================================

function CR_FTF(float Decimal, int "Out")  {

Out = default(Out, 0)
Numerator = (Decimal == 0) ? "0" : string(ContinuedNumerator(Decimal, Limit=10000))
Denominator = (Decimal == 0) ? "1" : string(ContinuedDenominator(Decimal, Limit=10000))
ND = (Out != 2) ? Numerator + ":" + Denominator : Numerator + " / " + Denominator

return (Out == 1) || (Out == 2) ? "   (" + ND + ")" : (Out == 3) ? " (" + ND + ") " : \
(Out == 4) ? "   (DAR  " + ND + ")" : (Out == 5) ? "\nSample Aspect Ratio   " + ND : ""  }

# ===============================================================================
# ===============================================================================
# ========== Position Function ==================================================
# ===============================================================================
# ===============================================================================

function CR_Position(clip Source, float "Sx", float "Sy", float "SSize", val "SColor", int "Pos", string "PosLine")  {

ScriptClip(Source, """

PosLine = (Pos == 1) ? "" : PosLine
Sy = (Pos == 1) ? Sy-(SSize*3.5) : Sy
SColor = (Pos == 1) ? $F0FFFF : SColor
Aligned = (Pos == 1) ? 2 : undefined()
Frame = (Pos < 3) ? string(current_frame, "%.0f\n") : string(current_frame, "%.0f    ")
Position = float(current_frame) * float(FrameRateDenominator) / float(FrameRateNumerator)
Decimal = Position - floor(Position)
RoundDown = (round(Decimal * 1000.0) == 1000)
Down = floor(Decimal * 1000.0)
Either = round(Decimal * 1000.0)
HH = string(floor(Position / 3600), "%02.0f")
MM = string(floor(Position / 60) % 60, ":%02.0f")
SS = string(floor(Position) % 60, ":%02.0f")
MS = string(RoundDown ? Down : Either, ".%03.0f")

subtitle(PosLine + Frame + HH + MM + SS + MS, x=Sx, y=Sy, size=SSize, text_color=SColor, align=Aligned, lsp=20)

""", args="Sx, Sy, SSize, SColor, Pos, PosLine")  }

# ===============================================================================
# ===============================================================================
# ========== CropResize Defaults ================================================
# ===============================================================================
# ===============================================================================

# Setting these options incorrectly will possibly break something, so take care when changing them.
# The functions below cannot be commented out.

function CR_AutoAspect() { return false }
function CR_CLine() { return 1 }
function CR_ColorCorrect() { return 0 }
function CR_CPreview() { return 1 }
function CR_InfoAutoPicDim() { return 0 }
function CR_InfoAutoPicDimWhenCPreviewOrColorCorrect() { return false }
function CR_InfoDisplayFormattedAvisynthVersion() { return true }
function CR_MeGUI_DAR() { return true }

# Default resizer functions
function CR_ResizerDefault() { return "" }
function CR_RStrDefault() { return "" }

# Alternative resizer functions
function CR_ResizerX() { return "Resize8" }
function CR_RStrX() { return """ Kernel="Spline36" """ }

# ===============================================================================
# ===============================================================================
# ===============================================================================