# ===============================================================================
# ===============================================================================
#	     FrostyBorders 2021-12-09
# ===============================================================================
# ===============================================================================

function FrostyBorders(clip Source, \
int "OutWidth", int "OutHeight", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", int "TSoft", bool "Faster", \
string "Resizer", string "RStr", bool "Info")  {

# ===============================================================================
#	     Source
# ===============================================================================

SourceWidth = width(Source)
F_SourceWidth = float(SourceWidth)
SourceHeight = height(Source)
F_SourceHeight = float(SourceHeight)

FB = " FrostyBorders " + chr(10)
assert(HasVideo(Source) && (SourceWidth > 48) && (SourceHeight > 48), FB + \
" No video found or the source width or height is too small " + chr(10))
TotalFrames = FrameCount(source) - 1
SourceAudio = !HasAudio(Source) ? Source : Source.KillVideo()
Source = Source.KillAudio()

AvsVerStrLC = LCase(VersionString())
IsAvsPlus = (FindStr(AvsVerStrLC, "avisynth+") > 0)
IsAvsNeo = (FindStr(AvsVerStrLC, "avisynth neo") > 0)
AvsStrNum = IsAvsPlus || IsAvsNeo ? FindStr(AvsVerStrLC, "(r") + 2 : 0
AvsBuildNum = (AvsStrNum > 2) ? int(value(MidStr(AvsVerStrLC, AvsStrNum))) : 0
IsAvsHBD = (AvsBuildNum > 2294)

Color_Format = PixelType(Source)
ModTwoHeight = IsYV12(Source) || (IsAvsHBD && Is420(Source))
ModTwoWidth = ModTwoHeight || IsYV16(Source) || IsYUY2(Source) || (IsAvsHBD && Is422(Source))
ModFourWidth = IsYV411(Source)

PWMod = default(Mod, ModTwoWidth ? 4 : ModFourWidth ? 8 : 2)
PHMod = default(Mod, ModTwoHeight ? 4 : 2)
F_PWMod = float(PWMod)
F_PHMod = float(PHMod)
BWMod = ModTwoWidth ? 2 : ModFourWidth ? 4 : 1
BHMod = ModTwoHeight ? 2 : 1
F_BWMod = float(BWMod)
F_BHMod = float(BHMod)

# ===============================================================================
#	     Aspect & Dimensions
# ===============================================================================

InDAR = default(InDAR, 0.0)
InSAR = default(InSAR, 0.0)
IsInDAR = (InDAR > 0)
IsInSAR = (InSAR > 0)

SourceDAR = \
IsInDAR ? InDAR : IsInSAR ? F_SourceWidth * InSAR / F_SourceHeight : F_SourceWidth / F_SourceHeight
SourceSAR = IsInDAR ? F_SourceHeight * InDAR / F_SourceWidth : IsInSAR ? InSAR : 1.0

ModSourceWidth = !IsInDAR && !IsInSAR ? floor(F_SourceWidth / F_PWMod) * PWMod : IsInDAR ? \
floor(F_SourceHeight * InDAR / F_PWMod) * PWMod : floor(F_SourceWidth * InSAR / F_PWMod) * PWMod
ModSourceStorageAR = float(ModSourceWidth) / F_SourceHeight

OutWidth = (default(OutWidth, 0) == 0) ? ModSourceWidth : default(OutWidth, 0)
OutHeight = (default(OutHeight, 0) == 0) ? SourceHeight : default(OutHeight, 0)
F_OutWidth = float(OutWidth)
F_OutHeight = float(OutHeight)
OutStorageAR = F_OutWidth / F_OutHeight

IsBorders = (abs(OutStorageAR - SourceDAR) >= 0.000005)
IsPillarBox = IsBorders && (OutStorageAR >= ModSourceStorageAR)
IsLetterBox = IsBorders && (OutStorageAR < ModSourceStorageAR)

# ===============================================================================
#	     Configure Resizing
# ===============================================================================

IsAvsHBD ? Eval("""  IsResampleMT = FunctionExists("Spline36ResizeMT")  """) : \
Eval("""  Try{  Test = Source.Spline36ResizeMT(640,480)   IsResampleMT = true  }
catch(err){  IsResampleMT = false  }  """)

IsResizer = defined(Resizer)
Resizer = default(Resizer, FB_Default_Resizer())
Resizer = (Resizer != "") ? Resizer : IsResampleMT ? "Spline36ResizeMT" : "Spline36Resize"
RStr = default(RStr, !IsResizer ? FB_Default_RStr() : "")
ResStr = (RStr == "") ? RStr : ", " + RStr

IsResizeMTAppended = (RightStr(Resizer, 8) == "ResizeMT") || (RightStr(Resizer, 8) == "MTResize")
IsMTAppended = (RightStr(Resizer, 2) == "MT")
IsResizeAppended = (RightStr(Resizer, 6) == "Resize")

Resizer = IsResizeMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 8) : \
IsMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 2) : \
IsResizeAppended ? LeftStr(Resizer, StrLen(Resizer) - 6) : Resizer

IsAvsResizer = (Resizer == "Bilinear") || (Resizer == "Bicubic") || (Resizer == "Blackman") || \
(Resizer == "Gauss") || (Resizer == "Lanczos") || (Resizer == "Lanczos4") || (Resizer == "Point") || \
(Resizer == "Spline16") || (Resizer == "Spline36") || (Resizer == "Spline64") || (Resizer == "Sinc")

Resizer = IsResizeMTAppended || IsMTAppended ? Resizer + "ResizeMT" : \
IsAvsResizer || IsResizeAppended ? Resizer + "Resize"  : Resizer

!IsBorders ? Eval("""

# ===============================================================================
#	     No Borders Resizing
# ===============================================================================

Resized = (OutWidth == SourceWidth) && (OutHeight == SourceHeight) ? Source : Eval("Source." + \
Resizer + "(OutWidth, OutHeight, src_left=0, src_top=0, src_width=0, src_height=0" + ResStr + ")")

""", "No Borders Eval") : IsPillarBox ? Eval("""

# ===============================================================================
#	     PillarBox Resizing
# ===============================================================================

F_NewWidth = IsInDAR ? (F_OutHeight * InDAR) : \
IsInSAR ? (F_OutHeight * F_SourceWidth * InSAR / F_SourceHeight) : \
(F_OutHeight * F_SourceWidth / F_SourceHeight)

ResizingWidth = floor(F_NewWidth / F_PWMod) * PWMod
F_ResizingWidth = float(ResizingWidth)

LRCrop = max(0, (SourceWidth - (F_SourceHeight * F_ResizingWidth / F_OutHeight / SourceSAR)) / 2.0)
ResizerCropLR = max(0, LRCrop - (floor(LRCrop / F_PWMod) * PWMod))
CropLR = max(0, round(LRCrop - ResizerCropLR))

Resized = Eval("Source.Crop(CropLR, 0, -CropLR, 0)." + Resizer + "(ResizingWidth, OutHeight, \
src_left=ResizerCropLR, src_top=0, src_width=-ResizerCropLR, src_height=0" + ResStr + ")")

AdditionalWidth = OutWidth - ResizingWidth
BL = min(AdditionalWidth, floor(float(AdditionalWidth) / 2.0 / F_BWMod) * BWMod)
BR = AdditionalWidth - BL

""", "PillarBox Resizing Eval") : Eval("""

# ===============================================================================
#	     LetterBox Resizing
# ===============================================================================

F_NewHeight = IsInDAR ? (F_OutWidth / InDAR) : \
IsInSAR ? (F_OutWidth * F_SourceHeight / F_SourceWidth / InSAR) : \
(F_OutWidth * F_SourceHeight / F_SourceWidth)

ResizingHeight = floor(F_NewHeight / F_PHMod) * PHMod
F_ResizingHeight = float(ResizingHeight)

TBCrop = max(0, (SourceHeight - (F_SourceWidth * F_ResizingHeight * SourceSAR / F_OutWidth)) / 2.0)
ResizerCropTB = max(0, TBCrop - (floor(TBCrop / F_PHMod) * PHMod))
CropTB = max(0, round(TBCrop - ResizerCropTB))

Resized = Eval("Source.Crop(0, CropTB, 0, -CropTB)." + Resizer + "(OutWidth, ResizingHeight, \
src_left=0, src_top=ResizerCropTB, src_width=0, src_height=-ResizerCropTB" + ResStr + ")")

AdditionalHeight = OutHeight - ResizingHeight
BT = min(AdditionalHeight, floor(float(AdditionalHeight) / 2.0 / F_BHMod) * BHMod)
BB = AdditionalHeight - BT

""", "LetterBox Resizing Eval")

# ===============================================================================

RatioW = IsPillarBox ? F_ResizingWidth / F_SourceWidth : \
IsLetterBox ? F_OutWidth / F_SourceWidth : F_OutWidth / F_SourceWidth
RatioH  = IsPillarBox ? F_OutHeight / F_SourceHeight : \
IsLetterBox ? F_ResizingHeight / F_SourceHeight : F_OutHeight / F_SourceHeight

# ===============================================================================

Frosty = default(Frosty, true)
IsFrostyStatic = defined(FrostyStatic)
FrostyStatic = default(FrostyStatic, 0)
Clone = default(Clone, 0)
Clone1 = (Clone == 1)
Clone2 = (Clone == 2)
Clone3 = (Clone == 3)
FrostyGradient = default(FrostyGradient, false)
FrostyPlain = default(FrostyPlain, false)
Plain = default(Plain, false)
BDivider = default(BDivider, 0)
BDColor = default(BDColor, $000000)
Feather = default(Feather, 0)
IsBright = defined(Bright)
IsCont = defined(Cont)
IsSat = defined(Sat)
IsBlur = defined(Blur)
IsVBlur = defined(VBlur)
IsBlend = defined(Blend)
Iterations = default(Iterations, 3)
GPlugin = default(GPlugin, 1)
IsTSoft = defined(TSoft)
Faster = default(Faster, false)
Info = default(Info, false)

# ===============================================================================
#	     Insist
# ===============================================================================

FBM = FB + " " + Color_Format + " requires a" + (IsPillarBox && ModFourWidth ? " Mod4 " : " Mod2 ")
assert(!IsRGB(Source), FB + " The FrostyBorders function doesn't support RGB " + chr(10))

assert(!IsFrostyStatic || (0 <= FrostyStatic < TotalFrames), FB + \
string(TotalFrames, " FrostyStatic must be from zero to final frame number (0 - %.0f) ") + chr(10))
assert((0 <= Clone <= 3), FB + " The value for Clone can only be 0, 1, 2 or 3 " + chr(10))

assert(((BDivider == 0) || !IsPillarBox) || \
(((BWMod != 2) || (BDivider % 2 == 0)) && ((BWMod != 4) || (BDivider % 4 == 0))), \
FBM + "BDivider for pillarbox borders " + chr(10))
assert(((BDivider == 0) || IsPillarBox) || ((BHMod != 2) || (BDivider % 2 == 0)), \
FBM + "BDivider for letterbox borders " + chr(10))
assert((Feather == 0) || !FrostyGradient, \
FB + " Feather can't be greater than zero when FrostyGradient=true " + chr(10))
assert((Feather == 0) || (BDivider == 0), FB + \
" Feather and BDivider can't be used together (one must equal zero) " + chr(10))

assert(!IsBright || (-255 <= Bright <= 255), FB + " The valid range for Bright is -255 thru 255 " + chr(10))
assert(!IsCont || (0 <= Cont <= 10), FB + " The valid range for Cont is 0.0 thru 10.0 " + chr(10))
assert(!IsSat || (0 <= Sat <= 10), FB + " The valid range for Sat is 0.0 thru 10.0 " + chr(10))
assert(!IsBlend || (0 <= Blend <= 1), FB + " The valid range for Blend is 0.0 to 1.0 " + chr(10))
assert((0 <= GPlugin <= 2), FB + \
" The valid choices for GPlugin are " + chr(10) + " 0 (no added grain), 1 (AddGrainC) or 2 (neo_f3kdb) " + chr(10))
assert(!IsTSoft || (0 <= TSoft <= 7), FB + " The valid range for TSoft is 0 to 7 " + chr(10))

assert((InDAR == 0) || (InSAR == 0), FB + " InDAR & InSAR can't be specified together " + chr(10))
assert(((IsFloat(InDAR) && (InDAR == 0)) || (IsFloat(InDAR) && !IsInt(InDAR) && (InDAR > 0))) && \
((IsFloat(InSAR) && (InSAR == 0)) || (IsFloat(InSAR) && !IsInt(InSAR) && (InSAR > 0))), \
FB + " InDAR & InSAR must be zero or a positive floating point number " + chr(10) + \
" 16.0/9.0 or 1.7778 etc " + chr(10))

assert((PWMod == 1) || (PWMod == 2) || (PWMod == 4) || (PWMod == 8) || (PWMod == 16), \
FB + " Mod must be 1, 2, 4, 8 or 16 " + chr(10))
assert(!IsPillarBox || (((BWMod != 2) || (PWMod % 2 == 0)) && ((BWMod != 4) || (PWMod % 4 == 0))), \
FBM + "picture width " + chr(10))
assert(!IsLetterBox || ((BHMod != 2) || (PHMod % 2 == 0)), FBM + "picture height " + chr(10))
assert((OutWidth == 0) || \
(((BWMod != 2) || (OutWidth % 2 == 0)) && ((BWMod != 4) || (OutWidth % 4 == 0))), \
FBM + "OutWidth " + chr(10))
assert((OutHeight == 0) || ((BHMod != 2) || (OutHeight % 2 == 0)), FBM + "OutHeight " + chr(10))

!IsBorders ? Eval("""

# ===============================================================================
#	     No Borders
# ===============================================================================

FrostyOut = Resized

# ===============================================================================
#	     PillarBox Borders
# ===============================================================================

""") : IsPillarBox ? Eval("""

# -------------------------------------------------------------------------------
#	     PillarBox Defaults
# -------------------------------------------------------------------------------

BWMin = Frosty || IsFrostyStatic || FrostyGradient ? ((BWMod == 4) ? 32 : 16) : \
Clone1 || Clone2 || Clone3 ? ((BWMod == 4) ? 8 : 4) : BWMod
WidthTest = (BL >= BWMin <= BR)
IsBDivider = (BDivider > 0) && (BL > BWMin < BR)
IsFeather = (Feather > 0) && (BL >= BWMod <= BR)

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

BClip = IsClone ? Resized : ((RatioW * RatioH) >= 1) ? Source : Resized
BClipWidth = width(BClip)
F_BClipWidth = float(BClipWidth)
BClipHeight = height(BClip)
F_BClipHeight = float(BClipHeight)

BColor = default(BColor, FrostyGradient || FrostyPlain ? $008080 : $000000)
Feather = IsFeather ? \
min((Feather < BWMod) ? BWMod : Feather, floor(F_ResizingWidth / 6.0 / F_BWMod) * BWMod) : nop()
Bright = IsBright ? Bright : 0.0
Cont = IsCont ? Cont : 1.0
Sat = IsSat ? Sat : !Plain ? 0.85 : 1.0
Blend = IsBlend ? Blend : IsFrostyStatic ? 0.5 : IsFrosty ? 0.2 : 0.0
Blur = IsBlur ? ((Blur >= 0) ? Blur : -Blur * F_BClipHeight / 720.0) : \
Clone1 || Clone2 ? F_BClipHeight / 75.0 : Clone3 ? F_BClipHeight / 25.0 : 0.0
VBlur = IsVBlur ? ((VBlur >= 0) ? VBlur : -VBlur * F_BClipHeight / 720.0) : IsBlur || IsClone ? Blur : 0.0
Texture = defined(Texture) ? ((Texture >= 0) ? Texture : -Texture * F_OutHeight / 720.0) : \
IsClone ? F_OutHeight / 200 : !Plain ? F_OutHeight / 100.0 : 0.0
TextureC = defined(TextureC) ? ((TextureC >= 0) ? TextureC : -TextureC * F_OutHeight / 720.0) : 0.0
TSoft = IsTSoft ? TSoft : IsFrosty ? 5 : Clone3 ? 1 : 0

BL = !IsBDivider ? BL : BL - BDivider
BR = !IsBDivider ? BR : BR - BDivider
FL = IsFeather ? max(BL, floor((BL + (Feather * 3)) / F_BWMod) * BWMod) : nop()
FR = IsFeather ? max(BR, floor((BR + (Feather * 3)) / F_BWMod) * BWMod) : nop()
Texture = (GPlugin == 0) ? 0 : (GPlugin == 1) ? Texture : floor(Texture * 6.0) * 8
TextureC = (GPlugin == 0) ? 0 : (GPlugin == 1) ? TextureC : floor(TextureC * 6.0) * 8

# -------------------------------------------------------------------------------
#	     PillarBox Strings
# -------------------------------------------------------------------------------

FastBlurS = (IsPlain && !IsFeather) || FrostyGradient ? "" : \
".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true)"
FBordS = ".AddBorders(0, 0, ResizingWidth-FL+BL-FR+BR, 0),"

GaussLS = !IsPlain ? \
(IsResampleMT ? ".GaussResizeMT(BL, OutHeight)" : ".GaussResize(BL, OutHeight)") : nop()
GaussRS = !IsPlain ? \
(IsResampleMT ? ".GaussResizeMT(BR, OutHeight)" : ".GaussResize(BR, OutHeight)") : nop()
FGaussLS = IsFeather ? \
(IsResampleMT ? ".GaussResizeMT(FL, OutHeight)" : ".GaussResize(FL, OutHeight)") : nop()
FGaussRS = IsFeather ? \
(IsResampleMT ? ".GaussResizeMT(FR, OutHeight)" : ".GaussResize(FR, OutHeight)") : nop()

Gauss3LS = Clone3 ? (IsResampleMT ? \
".GaussResizeMT(max(BL, floor(WidthCloneBorderL * RatioL / F_BWMod) * BWMod), \
max(OutHeight, floor(OutHeight * RatioL / F_BHMod) * BHMod))" : \
".GaussResize(max(BL, floor(WidthCloneBorderL * RatioL / F_BWMod) * BWMod), \
max(OutHeight, floor(OutHeight * RatioL / F_BHMod) * BHMod))") : nop()
Gauss3RS = Clone3 ? (IsResampleMT ? \
".GaussResizeMT(max(BR, floor(WidthCloneBorderR * RatioR / F_BWMod) * BWMod), \
max(OutHeight, floor(OutHeight * RatioR / F_BHMod) * BHMod))" : \
".GaussResize(max(BR, floor(WidthCloneBorderR * RatioR / F_BWMod) * BWMod), \
max(OutHeight, floor(OutHeight * RatioR / F_BHMod) * BHMod))") : nop()

GPlugS = (GPlugin == 1) ? ".AddGrain(var=Texture, uvar=TextureC, constant=true)" : \
(GPlugin == 2) ? ".neo_f3kdb(range=0, grainY=Texture, grainC=TextureC, dither_algo=1)" : ""

LoopS = ".Trim(1, 1).Loop(TotalFrames)"
ResizedS = !IsBDivider ? ",Resized," : ",Resized.AddBorders(BDivider, 0, BDivider, 0, color=BDColor),"
StaticLS = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(TotalFrames)" : ""
TSoftS = (TSoft > 0) && (IsFrosty || IsClone) ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : ""
TweakS = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? ".Tweak(bright=Bright, cont=Cont, sat=Sat)" : ""

TwkBlrGrS = TweakS + FastBlurS + GPlugS
TweakBlurS = TweakS + FastBlurS

# -------------------------------------------------------------------------------
#	     PillarBox Frosty Borders
# -------------------------------------------------------------------------------

FrostyCrop = IsFrosty && (TSoft > 0) ? \
BClipWidth - max(BWMin, round(F_BClipWidth / (!Faster ? 5.0 : 10.0) / F_BWMod) * BWMod) : nop()
FrostyLR = IsFrosty && (TSoft > 0) ? \
Eval("StackHorizontal(BClip.crop(0, 0, -FrostyCrop, 0), BClip.crop(FrostyCrop, 0, 0, 0))" + TSoftS) : nop()
WidthFrostyLR = IsFrosty && (TSoft > 0) ? width(FrostyLR) : nop()

FrostyCrop = IsFrosty && (TSoft > 0) ? \
WidthFrostyLR - max(BWMin, round(float(WidthFrostyLR) / (!Faster ? 16.0 : 8.0) / F_BWMod) * BWMod) : \
IsFrosty ? BClipWidth - max(BWMin, round(F_BClipWidth / 80.0 / F_BWMod) * BWMod) : nop()

FrostyL = IsFrosty ? ((TSoft > 0) ? \
FrostyLR.crop(0, 0, -FrostyCrop, 0) : BClip.crop(0, 0, -FrostyCrop, 0)) : nop()
FrostyR = IsFrosty ? ((TSoft > 0) ? \
FrostyLR.crop(FrostyCrop, 0, 0, 0) : BClip.crop(FrostyCrop, 0, 0, 0)) : nop()
WidthFrostyL = IsFrosty ? width(FrostyL) : nop()
WidthFrostyR = IsFrosty ? width(FrostyR) : nop()

FrostyBlendL = IsFrosty ? ((Blend == 0) ? FrostyL : (Blend == 1) ? FrostyR : \
Overlay(FrostyL, FlipHorizontal(FrostyR), Opacity=Blend)) : nop()
FrostyBlendR = IsFrosty ? ((Blend == 0) ? FrostyR : (Blend == 1) ? FrostyL : \
Overlay(FrostyR, FlipHorizontal(FrostyL), Opacity=Blend)) : nop()

Blur = IsBlur ? Blur : IsFrosty ? max(WidthFrostyL, WidthFrostyR) + (!IsFeather ? 0 : Feather) : Blur
VBlur = IsVBlur ? VBlur : IsFrosty ? F_BClipHeight / 10.0 : VBlur

FrostyL = Frosty ? Eval("FrostyBlendL" + TweakBlurS + GaussLS + GPlugS + StaticLS) : nop()
FrostyR = Frosty ? Eval("FrostyBlendR" + TweakBlurS + GaussRS + GPlugS + StaticLS) : nop()

FFrostyL = IsFeather && Frosty ? Eval("FrostyBlendL" + TweakBlurS + FGaussLS + GPlugS + StaticLS) : nop()
FFrostyR = IsFeather && Frosty ? Eval("FrostyBlendR" + TweakBlurS + FGaussRS + GPlugS + StaticLS) : nop()

# -------------------------------------------------------------------------------
#	     PillarBox Clone Borders
# -------------------------------------------------------------------------------

MaxCloneC = (IsFrosty && IsFeather) || IsClone ? floor(F_BClipWidth / 2.0 / F_BWMod) * BWMod : nop()
CloneCropL = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, BClipWidth - BL) : nop()
CloneCropR = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, BClipWidth - BR) : nop()
CloneBorderL = (IsFrosty && IsFeather) || IsClone ? Resized.crop(0, 0, -CloneCropL, 0) : nop()
CloneBorderR = (IsFrosty && IsFeather) || IsClone ? Resized.crop(CloneCropR, 0, 0, 0) : nop()
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

# -------------------------------------------------------------------------------
#	     PillarBox Clone2 Borders
# -------------------------------------------------------------------------------

Clone2CropL = Clone2 ? max(MaxCloneC, BClipWidth - FL) : nop()
Clone2CropR = Clone2 ? max(MaxCloneC, BClipWidth - FR) : nop()
Clone2BL = Clone2 ? BClip.crop(0, 0, -Clone2CropL, 0) : nop()
Clone2BR = Clone2 ? BClip.crop(Clone2CropR, 0, 0, 0) : nop()
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

# -------------------------------------------------------------------------------
#	     PillarBox Clone3 Borders
# -------------------------------------------------------------------------------

RatioL = Clone3 ? (WidthCloneBorderL - BL >= 0) ? 1.618 : float(BL) / float(WidthCloneBorderL) : nop()
RatioR = Clone3 ? (WidthCloneBorderR - BR >= 0) ? 1.618 : float(BR) / float(WidthCloneBorderR) : nop()

Clone3L = Clone3 ? Eval("CloneBlendL" + Gauss3LS) : nop()
Clone3R = Clone3 ? Eval("CloneBlendR" + Gauss3RS) : nop()
WidthClone3L = Clone3 ? width(Clone3L) : nop()
HeightClone3L = Clone3 ? height(Clone3L) : nop()
WidthClone3R = Clone3 ? width(Clone3R) : nop()
HeightClone3R = Clone3 ? height(Clone3R) : nop()

Clone3L_CL = Clone3 ? max(0, floor((WidthClone3L - BL) / F_BWMod / 2.0) * BWMod) : nop()
Clone3L_CR = Clone3 ? max(0, WidthClone3L - BL - Clone3L_CL) : nop()
Clone3L_CT = Clone3 ? max(0, floor((HeightClone3L - BClipHeight) / F_BHMod / 2.0) * BHMod) : nop()
Clone3L_CB = Clone3 ? max(0, HeightClone3L - BClipHeight - Clone3L_CT) : nop()
Clone3R_CL = Clone3 ? max(0, floor((WidthClone3R - BR) / F_BWMod / 2.0) * BWMod) : nop()
Clone3R_CR = Clone3 ? max(0, WidthClone3R - BR - Clone3R_CL) : nop()
Clone3R_CT = Clone3 ? max(0, floor((HeightClone3R - BClipHeight) / F_BHMod / 2.0) * BHMod) : nop()
Clone3R_CB = Clone3 ? max(0, HeightClone3R - BClipHeight - Clone3L_CT) : nop()

Clone3L = Clone3 ? Clone3L.crop(Clone3L_CL, Clone3L_CT, -Clone3L_CR, -Clone3L_CB) : nop()
Clone3R = Clone3 ? Clone3R.crop(Clone3R_CL, Clone3R_CT, -Clone3R_CR, -Clone3R_CB) : nop()

FClone3L = IsFeather && Clone3 ? Clone3L : nop()
FClone3R = IsFeather && Clone3 ? Clone3R : nop()

Clone3L = !IsFeather && Clone3 ? Eval("Clone3L" + TwkBlrGrS) : nop()
Clone3R = !IsFeather && Clone3 ? Eval("Clone3R" + TwkBlrGrS) : nop()

# -------------------------------------------------------------------------------
#	     PillarBox FrostyGradient Borders
# -------------------------------------------------------------------------------

GradientLR = \
FrostyGradient ? BlankClip(BClip, width=88, height=OutHeight).AddBorders(8, 0, 0, 0, color=BColor)\
.Tweak(bright=Bright, cont=Cont, sat=Sat).FastBlur(50, y_blur=0, iterations=3, dither=true) : nop()
GradientL = FrostyGradient ? Eval("FlipHorizontal(GradientLR)" + GaussLS + GPlugS + LoopS) : nop()
GradientR = FrostyGradient ? Eval("GradientLR" + GaussRS + GPlugS + LoopS) : nop()

# -------------------------------------------------------------------------------
#	     PillarBox Plain Borders
# -------------------------------------------------------------------------------

PlainL = IsPlain && (BL >= BWMod) ? \
Eval("BlankClip(Resized, width=BL, color=BColor)" + TweakS + GPlugS + LoopS) : nop()
PlainR = IsPlain && (BR >= BWMod) ? \
Eval("BlankClip(Resized, width=BR, color=BColor)" + TweakS + GPlugS + LoopS) : nop()

PlainL2 = IsFeather && IsPlain ? Eval("BlankClip(Resized, width=BL, color=BColor)" + TweakS + LoopS) : nop()
PlainR2 = IsFeather && IsPlain ? Eval("BlankClip(Resized, width=BR, color=BColor)" + TweakS + LoopS) : nop()

# -------------------------------------------------------------------------------
#	     PillarBox Frosty Video
# -------------------------------------------------------------------------------

FrostyBL = !IsFeather ? (IsFrosty ? FrostyL : Clone1 ? CloneL : Clone3 ? Clone3L : \
FrostyGradient ? GradientL : IsPlain && (BL >= BWMod) ? PlainL : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneL : IsPlain && (BL >= BWMod) ? PlainL2 : nop()

FrostyBR = !IsFeather ? (IsFrosty ? FrostyR : Clone1 ? CloneR : Clone3 ? Clone3R : \
FrostyGradient ? GradientR :IsPlain && (BR >= BWMod) ? PlainR : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneR : IsPlain && (BR >= BWMod) ? PlainR2 : nop()

FrostyOut = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BL >= BWMod <= BR)) ? \
Eval("StackHorizontal(FrostyBL" + ResizedS + "FrostyBR)") : \
IsPlain && (BL >= BWMod) ? StackHorizontal(FrostyBL, Resized) : \
IsPlain && (BR >= BWMod) ? StackHorizontal(Resized, FrostyBR) : Resized

# -------------------------------------------------------------------------------
#	     PillarBox Feather Mask
# -------------------------------------------------------------------------------

FeatherMask = IsFeather ? BlankClip(Resized, width=ResizingWidth-(Feather*2))\
.AddBorders(BL+Feather, 0, BR+Feather, 0, color=$FFFFFF).ColorYUV(Levels="TV->PC")\
.FastBlur(Feather/2.25, y_blur=0, iterations=3, dither=true) : nop()

FeatherMask = IsFeather ? Eval("FeatherMask" + LoopS) : nop()

# -------------------------------------------------------------------------------
#	     PillarBox Feather Clip
# -------------------------------------------------------------------------------

FeatherClip = IsFeather ? \
(IsFrosty ? StackHorizontal(FFrostyL.AddBorders(0, 0, ResizingWidth-FL+BL-FR+BR, 0), FFrostyR) : \
Clone1 ? Eval("StackHorizontal(StackHorizontal(FCloneL, Resized.crop(0, 0, -ResizingWidth+FL-BL, 0))" + \
TwkBlrGrS + FBordS + \
"StackHorizontal(Resized.crop(ResizingWidth-FR+BR, 0, 0, 0), FCloneR)" + TwkBlrGrS + ")")  : \
Clone2 ? StackHorizontal(Clone2L.AddBorders(0, 0, ResizingWidth-FL+BL-FR+BR, 0), Clone2R) : \
Clone3 ? Eval("StackHorizontal(StackHorizontal(FClone3L, Resized.crop(0, 0, -ResizingWidth+FL-BL, 0))" + \
TwkBlrGrS + FBordS + \
"StackHorizontal(Resized.crop(ResizingWidth-FR+BR, 0, 0, 0), FClone3R)" + TwkBlrGrS + ")") : \
Eval("StackHorizontal(BlankClip(Resized, width=FL, color=BColor)" + TweakS + GPlugS + LoopS + \
FBordS + "BlankClip(Resized, width=FR, color=BColor)" + TweakS + GPlugS + LoopS + ")")) : nop()

# -------------------------------------------------------------------------------
#	     PillarBox Output
# -------------------------------------------------------------------------------

FrostyOut = !IsFeather ? FrostyOut : Overlay(FrostyOut, FeatherClip, mask=FeatherMask)

# ===============================================================================
#	     LetterBox Borders
# ===============================================================================

""", "Frosty PillarBox Eval") : Eval("""

# -------------------------------------------------------------------------------
#	     LetterBox Defaults
# -------------------------------------------------------------------------------

BHMin = Frosty || IsFrostyStatic || FrostyGradient ? 16 : Clone1 || Clone2 || Clone3 ? 4 : BHMod
HeightTest = (BT >= BHMin <= BB)
IsBDivider = (BDivider > 0) && (BL > BWMin < BR)
IsFeather = (Feather > 0) && (BT >= BHMod <= BB)

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

BClip = IsClone ? Resized : ((RatioW * RatioH) >= 1) ? Source : Resized
BClipWidth = width(BClip)
F_BClipWidth = float(BClipWidth)
BClipHeight = height(BClip)
F_BClipHeight = float(BClipHeight)

BColor = default(BColor, FrostyGradient || FrostyPlain ? $008080 : $000000)
Feather = IsFeather ? \
min((Feather < BHMod) ? BHMod : Feather, floor(F_ResizingHeight / 6.0 / F_BHMod) * BHMod) : nop()
Bright = IsBright ? Bright : !Plain ? -25.0 : 0.0
Cont = IsCont ? Cont : !Plain ? 0.66 : 1.0
Sat = IsSat ? Sat : !Plain ? 0.66 : 1.0
Blend = IsBlend ? Blend : IsFrostyStatic ? 0.5 : IsFrosty ? 0.2 : 0.0
Blur = IsBlur ? ((Blur >= 0) ? Blur : -Blur * F_BClipWidth / 720.0) : \
Clone1 || Clone2 ? F_BClipWidth / 75.0 : Clone3 ? F_BClipWidth / 25.0 : 0.0
VBlur = IsVBlur ? ((VBlur >= 0) ? VBlur : -VBlur * F_BClipWidth / 720.0) : IsBlur || IsClone ? Blur : 0.0
Texture = defined(Texture) ? ((Texture >= 0) ? Texture : -Texture * F_OutWidth / 720.0) : \
IsClone ? F_OutWidth / 200 : !Plain ? F_OutWidth / 100.0 : 0.0
TextureC = defined(TextureC) ? ((TextureC >= 0) ? TextureC : -TextureC * F_OutWidth / 720.0) : 0.0
TSoft = IsTSoft ? TSoft : IsFrosty ? 5 : Clone3 ? 1 : 0

BT = !IsBDivider ? BT : BT - BDivider
BB = !IsBDivider ? BB : BB - BDivider
FT = IsFeather ? max(BT, floor((BT + (Feather * 3)) / F_BHMod) * BHMod) : nop()
FB = IsFeather ? max(BB, floor((BB + (Feather * 3)) / F_BHMod) * BHMod) : nop()
Texture = (GPlugin == 0) ? 0 : (GPlugin == 1) ? Texture : floor(Texture * 6.0) * 8
TextureC = (GPlugin == 0) ? 0 : (GPlugin == 1) ? TextureC : floor(TextureC * 6.0) * 8

# -------------------------------------------------------------------------------
#	     LetterBox Strings
# -------------------------------------------------------------------------------

FastBlurS = (IsPlain && !IsFeather) || FrostyGradient ? "" : \
".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true)"
FBordS = ".AddBorders(0, 0, 0, ResizingHeight-FT+BT-FB+BB),"

GaussTS = !IsPlain ? \
(IsResampleMT ? ".GaussResizeMT(OutWidth, BT)" : ".GaussResize(OutWidth, BT)") : nop()
GaussBS = !IsPlain ? \
(IsResampleMT ? ".GaussResizeMT(OutWidth, BB)" : ".GaussResize(OutWidth, BB)") : nop()
FGaussTS = IsFeather ? \
(IsResampleMT ? ".GaussResizeMT(OutWidth, FT)" : ".GaussResize(OutWidth, FT)") : nop()
FGaussBS = IsFeather ? \
(IsResampleMT ? ".GaussResizeMT(OutWidth, FB)" : ".GaussResize(OutWidth, FB)") : nop()

Gauss3TS = Clone3 ? (IsResampleMT ? \
".GaussResizeMT(max(OutWidth, floor(OutWidth * RatioT / F_BWMod) * BWMod), \
max(BT, floor(HeightCloneBorderT * RatioT / F_BHMod) * BHMod))" : \
".GaussResize(max(OutWidth, floor(OutWidth * RatioT / F_BWMod) * BWMod), \
max(BT, floor(HeightCloneBorderT * RatioT / F_BHMod) * BHMod))") : nop()
Gauss3BS = Clone3 ? (IsResampleMT ? \
".GaussResizeMT(max(OutWidth, floor(OutWidth * RatioB / F_BWMod) * BWMod), \
max(BB, floor(HeightCloneBorderB * RatioB / F_BHMod) * BHMod))" : \
".GaussResize(max(OutWidth, floor(OutWidth * RatioB / F_BWMod) * BWMod), \
max(BB, floor(HeightCloneBorderB * RatioB / F_BHMod) * BHMod))") : nop()

GPlugS = (GPlugin == 1) ? ".AddGrain(var=Texture, uvar=TextureC, constant=true)" : \
(GPlugin == 2) ? ".neo_f3kdb(range=0, grainY=Texture, grainC=TextureC, dither_algo=1)" : ""

LoopS = ".Trim(1, 1).Loop(TotalFrames)"
ResizedS = !IsBDivider ? ",Resized," : ",Resized.AddBorders(0, BDivider, 0, BDivider, color=BDColor),"
StaticLS = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(TotalFrames)" : ""
TSoftS = (TSoft > 0) && (IsFrosty || IsClone) ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : ""
TweakS = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? ".Tweak(bright=Bright, cont=Cont, sat=Sat)" : ""

TwkBlrGrS = TweakS + FastBlurS + GPlugS
TweakBlurS = TweakS + FastBlurS

# -------------------------------------------------------------------------------
#	     LetterBox Frosty Borders
# -------------------------------------------------------------------------------

FrostyCrop = IsFrosty && (TSoft > 0) ? \
BClipHeight - max(BHMin, round(F_BClipHeight / (!Faster ? 5.0 : 10.0) / F_BHMod) * BHMod) : nop()
FrostyTB = IsFrosty && (TSoft > 0) ? \
Eval("StackVertical(BClip.crop(0, 0, 0, -FrostyCrop), BClip.crop(0, FrostyCrop, 0, 0))" + TSoftS) : nop()
HeightFrostyTB = IsFrosty && (TSoft > 0) ? height(FrostyTB) : nop()

FrostyCrop = IsFrosty && (TSoft > 0) ? \
HeightFrostyTB - max(BHMin, round(float(HeightFrostyTB) / (!Faster ? 16.0 : 8.0) / F_BHMod) * BHMod) : \
IsFrosty ? BClipHeight - max(BHMin, round(F_BClipHeight / 80.0 / F_BHMod) * BHMod) : nop()

FrostyT = IsFrosty ? ((TSoft > 0) ? \
FrostyTB.crop(0, 0, 0, -FrostyCrop) : BClip.crop(0, 0, 0, -FrostyCrop)) : nop()
FrostyB = IsFrosty ? ((TSoft > 0) ? \
FrostyTB.crop(0, FrostyCrop, 0, 0) : BClip.crop(0, FrostyCrop, 0, 0)) : nop()
HeightFrostyT = IsFrosty ? height(FrostyT) : nop()
HeightFrostyB = IsFrosty ? height(FrostyB) : nop()

FrostyBlendT = IsFrosty ? ((Blend == 0) ? FrostyT : (Blend == 1) ? FrostyB : \
Overlay(FrostyT, FlipVertical(FrostyB), Opacity=Blend)) : nop()
FrostyBlendB = IsFrosty ? ((Blend == 0) ? FrostyB : (Blend == 1) ? FrostyT : \
Overlay(FrostyB, FlipVertical(FrostyT), Opacity=Blend)) : nop()

Blur = IsBlur ? Blur : IsFrosty ? F_BClipWidth / 10.0 : Blur
VBlur = IsVBlur ? VBlur : IsFrosty ? max(HeightFrostyT, HeightFrostyB) + (!IsFeather ? 0 : Feather) : VBlur

FrostyT = Frosty ? Eval("FrostyBlendT" + TweakBlurS + GaussTS + GPlugS + StaticLS) : nop()
FrostyB = Frosty ? Eval("FrostyBlendB" + TweakBlurS + GaussBS + GPlugS + StaticLS) : nop()

FFrostyT = IsFeather && Frosty ? Eval("FrostyBlendT" + TweakBlurS + FGaussTS + GPlugS + StaticLS) : nop()
FFrostyB = IsFeather && Frosty ? Eval("FrostyBlendB" + TweakBlurS + FGaussBS + GPlugS + StaticLS) : nop()

# -------------------------------------------------------------------------------
#	     LetterBox Clone Borders
# -------------------------------------------------------------------------------

MaxCloneC = (IsFrosty && IsFeather) || IsClone ? floor(F_BClipHeight / 2.0 / F_BHMod) * BHMod : nop()
CloneCropT = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, BClipHeight - BT) : nop()
CloneCropB = (IsFrosty && IsFeather) || IsClone ? max(MaxCloneC, BClipHeight - BB) : nop()
CloneBorderT = (IsFrosty && IsFeather) || IsClone ? Resized.crop(0, 0, 0, -CloneCropT) : nop()
CloneBorderB = (IsFrosty && IsFeather) || IsClone ? Resized.crop(0, CloneCropB, 0, 0) : nop()
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

# -------------------------------------------------------------------------------
#	     LetterBox Clone2 Borders
# -------------------------------------------------------------------------------

Clone2CropT = Clone2 ? max(MaxCloneC, BClipHeight - FT) : nop()
Clone2CropB = Clone2 ? max(MaxCloneC, BClipHeight - FB) : nop()
Clone2BT = Clone2 ? BClip.crop(0, 0, 0, -Clone2CropT) : nop()
Clone2BB = Clone2 ? BClip.crop(0, Clone2CropB, 0, 0) : nop()
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

# -------------------------------------------------------------------------------
#	     LetterBox Clone3 Borders
# -------------------------------------------------------------------------------

RatioT = Clone3 ? (HeightCloneBorderT - BT >= 0) ? 1.618 : float(BT) / float(HeightCloneBorderT) : nop()
RatioB = Clone3 ? (HeightCloneBorderB - BB >= 0) ? 1.618 : float(BB) / float(HeightCloneBorderB) : nop()

Clone3T = Clone3 ? Eval("CloneBlendT" + Gauss3TS) : nop()
Clone3B = Clone3 ? Eval("CloneBlendB" + Gauss3BS) : nop()
WidthClone3T = Clone3 ? width(Clone3T) : nop()
HeightClone3T = Clone3 ? height(Clone3T) : nop()
WidthClone3B = Clone3 ? width(Clone3B) : nop()
HeightClone3B = Clone3 ? height(Clone3B) : nop()

Clone3T_CL = Clone3 ? max(0, floor((WidthClone3T - BClipWidth) / F_BWMod / 2.0) * BWMod) : nop()
Clone3T_CR = Clone3 ? max(0, WidthClone3T - BClipWidth - Clone3T_CL) : nop()
Clone3T_CT = Clone3 ? max(0, floor((HeightClone3T - BT) / F_BHMod / 2.0) * BHMod) : nop()
Clone3T_CB = Clone3 ? max(0, HeightClone3T - BT - Clone3T_CT) : nop()
Clone3B_CL = Clone3 ? max(0, floor((WidthClone3B - BClipWidth) / F_BWMod / 2.0) * BWMod) : nop()
Clone3B_CR = Clone3 ? max(0, WidthClone3B - BClipWidth - Clone3B_CL) : nop()
Clone3B_CT = Clone3 ? max(0, floor((HeightClone3B - BB) / F_BHMod / 2.0) * BHMod) : nop()
Clone3B_CB = Clone3 ? max(0, HeightClone3B - BB - Clone3B_CT) : nop()

Clone3T = Clone3 ? Clone3T.crop(Clone3T_CL, Clone3T_CT, -Clone3T_CR, -Clone3T_CB) : nop()
Clone3B = Clone3 ? Clone3B.crop(Clone3B_CL, Clone3B_CT, -Clone3B_CR, -Clone3B_CB) : nop()

FClone3T = IsFeather && Clone3 ? Clone3T : nop()
FClone3B = IsFeather && Clone3 ? Clone3B : nop()

Clone3T = !IsFeather && Clone3 ? Eval("Clone3T" + TwkBlrGrS) : nop()
Clone3B = !IsFeather && Clone3 ? Eval("Clone3B" + TwkBlrGrS) : nop()

# -------------------------------------------------------------------------------
#	     LetterBox FrostyGradient Borders
# -------------------------------------------------------------------------------

GradientTB = \
FrostyGradient ? BlankClip(BClip, width=OutWidth, height=88).AddBorders(0, 8, 0, 0, color=BColor)\
.Tweak(bright=Bright, cont=Cont, sat=Sat).FastBlur(0, y_blur=50, iterations=3, dither=true) : nop()
GradientT = FrostyGradient ? Eval("FlipVertical(GradientTB)" + GaussTS + GPlugS + LoopS) : nop()
GradientB = FrostyGradient ? Eval("GradientTB" + GaussBS + GPlugS + LoopS) : nop()

# -------------------------------------------------------------------------------
#	     LetterBox Plain Borders
# -------------------------------------------------------------------------------

PlainT = IsPlain && (BT >= BHMod) ? \
Eval("BlankClip(Resized, height=BT, color=BColor)" + TweakS + GPlugS + LoopS) : nop()
PlainB = IsPlain && (BB >= BHMod) ? \
Eval("BlankClip(Resized, height=BB, color=BColor)" + TweakS + GPlugS + LoopS) : nop()

PlainT2 = IsFeather && IsPlain ? Eval("BlankClip(Resized, height=BT, color=BColor)" + TweakS + LoopS) : nop()
PlainB2 = IsFeather && IsPlain ? Eval("BlankClip(Resized, height=BB, color=BColor)" + TweakS + LoopS) : nop()

# -------------------------------------------------------------------------------
#	     LetterBox Frosty Video
# -------------------------------------------------------------------------------

FrostyBT = !IsFeather ? (IsFrosty ? FrostyT : Clone1 ? CloneT : Clone3 ? Clone3T : \
FrostyGradient ? GradientT : IsPlain && (BT >= BHMod) ? PlainT : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneT : IsPlain && (BT >= BHMod) ? PlainT2 : nop()

FrostyBB = !IsFeather ? (IsFrosty ? FrostyB : Clone1 ? CloneB : Clone3 ? Clone3B : \
FrostyGradient ? GradientB : IsPlain && (BB >= BHMod) ? PlainB : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneB : IsPlain && (BB >= BHMod) ? PlainB2 : nop()

FrostyOut = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BT >= BHMod <= BB)) ? \
Eval("StackVertical(FrostyBT" + ResizedS + "FrostyBB)") : \
IsPlain && (BT >= BHMod) ? StackVertical(FrostyBT, Resized) : \
IsPlain && (BB >= BHMod) ? StackVertical(Resized, FrostyBB) : Resized

# -------------------------------------------------------------------------------
#	     LetterBox Feather Mask
# -------------------------------------------------------------------------------

FeatherMask = IsFeather ? BlankClip(Resized, height=ResizingHeight-(Feather*2))\
.AddBorders(0, BT+Feather, 0, BB+Feather, color=$FFFFFF).ColorYUV(Levels="TV->PC")\
.FastBlur(0, y_blur=Feather/2.25, iterations=3, dither=true) : nop()

FeatherMask = IsFeather ? Eval("FeatherMask" + LoopS) : nop()

# -------------------------------------------------------------------------------
#	     LetterBox Feather Clip
# -------------------------------------------------------------------------------

FeatherClip = IsFeather ? \
(IsFrosty ? StackVertical(FFrostyT.AddBorders(0, 0, 0, ResizingHeight-FT+BT-FB+BB),  FFrostyB) : \
Clone1 ? Eval("StackVertical(StackVertical(FCloneT, Resized.crop(0, 0, 0, -ResizingHeight+FT-BT))" + \
TwkBlrGrS + FBordS + "StackVertical(Resized.crop(0, ResizingHeight-FB+BB, 0, 0), FCloneB)" + TwkBlrGrS + ")")  : \
Clone2 ? StackVertical(Clone2T.AddBorders(0, 0, 0, ResizingHeight-FT+BT-FB+BB), Clone2B) : \
Clone3 ? Eval("StackVertical(StackVertical(FClone3T, Resized.crop(0, 0, 0, -ResizingHeight+FT-BT))" + \
TwkBlrGrS + FBordS + "StackVertical(Resized.crop(0, BClipHeight-FB+BB, 0, 0), FClone3B)" + TwkBlrGrS + ")") : \
Eval("StackVertical(BlankClip(Resized, height=FT, color=BColor)" + TweakS + GPlugS + LoopS + \
FBordS + "BlankClip(Resized, height=FB, color=BColor)" + TweakS + GPlugS + LoopS + ")")) : nop()

# -------------------------------------------------------------------------------
#	     LetterBox Output
# -------------------------------------------------------------------------------

FrostyOut = !IsFeather ? FrostyOut : Overlay(FrostyOut, FeatherClip, mask=FeatherMask)

# ===============================================================================
#	     Info
# ===============================================================================

""", "Frosty LetterBox Eval")

Info ? Eval("""

CL = !IsPillarBox ? "" : FB_FS(((LRCrop / 2.0) <= 0.005) ? 0 : LRCrop / 2.0)
CR = !IsPillarBox ? "" : FB_FS(((LRCrop / 2.0) <= 0.005) ? 0 : -LRCrop / 2.0)
CT = !IsLetterBox ? "" : FB_FS(((TBCrop / 2.0) <= 0.005) ? 0 : TBCrop / 2.0)
CB = !IsLetterBox ? "" : FB_FS(((TBCrop / 2.0) <= 0.005) ? 0 : -TBCrop / 2.0)
BL = !IsPillarBox ? 0 : !IsBDivider ? BL : BL + BDivider
BR = !IsPillarBox ? 0 : !IsBDivider ? BR : BR + BDivider
BT = !IsLetterBox ? 0 : !IsBDivider ? BT : BT + BDivider
BB = !IsLetterBox ? 0 : !IsBDivider ? BB : BB + BDivider
SSize = F_OutHeight * 0.035
SY = (F_OutHeight * 0.5) - (SSize * 6.5)

Cropping = !IsBorders ? "" : "Cropping\n" + \
(IsPillarBox ? "Left " + CL + "   Right " + CR : "Top " + CT + "   Bottom " + CB) + "\n\n"
PicW = !IsBorders ? OutWidth : IsPillarBox ? ResizingWidth : OutWidth
PicH = !IsBorders ? OutHeight : IsPillarBox ? OutHeight : ResizingHeight
PicWH = !IsBorders ? "" : \
string(PicW, "Picture Dimensions\n%.0f x ") + string(PicH, "%.0f") + FB_LCD(PicW, PicH) + "\n\n"
Borders = (!IsBorders ? "No Borders" : \
"Borders\n" + (IsPillarBox ? string(BL, "Left %.0f") + string(BR, "   Right %.0f") : \
string(BT, "Top %.0f") + string(BB, "   Bottom %.0f"))) + "\n\n"

InfoText = Cropping + PicWH + Borders + \
string(OutWidth, "Output Dimensions\n%.0f x ") + string(OutHeight, "%.0f") + \
FB_LCD(OutWidth, OutHeight) + "\n\n" + Resizer + "\n" + ((RStr == "") ? "" : RStr)

FrostyOut = FrostyOut.subtitle(InfoText, y=SY, size=SSize, text_color=$FFFFE0, align=5, lsp=0)

""", "Frosty Info Eval") : nop()

# ===============================================================================
#	     FrostyBorders Output
# ===============================================================================

return !HasAudio(SourceAudio) ? FrostyOut : AudioDub(FrostyOut, SourceAudio)  }

# ===============================================================================
# ===============================================================================
#	     Lowest Common Denominator Function
# ===============================================================================
# ===============================================================================

function FB_LCD(int N, int D)  {
return string(ContinuedNumerator(N, D), "  (%.0f:") + string(ContinuedDenominator(N, D), "%.0f)")  }

# ===============================================================================
# ===============================================================================
#	     Format String Function (Remove Zeros)
# ===============================================================================
# ===============================================================================

function FB_FS(float F, int "Limit", bool "Keep")  {

Limit = default(Limit, 3)
Keep = default(Keep, false)

Dec = abs(round(F) - F)

IsDec = (Limit == 0) ? (Dec > 0.5) : (Limit == 1) ? (Dec > 0.05) : \
(Limit == 2) ? (Dec > 0.005) : (Limit == 3) ? (Dec > 0.0005) : \
(Limit == 4) ? (Dec > 0.00005) : (Limit == 5) ? (Dec > 0.000005) : (Dec > 0.0000005)

S = !IsDec ? string(F,"%.0f") : (Limit == 1) ? string(F,"%.1f") : (Limit == 2) ? string(F,"%.2f") : \
(Limit == 3) ? string(F,"%.3f") : (Limit == 4) ? string(F,"%.4f") : (Limit == 5) ? string(F,"%.5f") : string(F,"%.6f")

SLength = StrLen(S)
DecPos = FindStr(S, ".")
LeftS = IsDec ? LeftStr(S, DecPos) : S
RightS = IsDec ? RightStr(S, SLength - DecPos) : ""
RightSLength = StrLen(RightS)
RightSx = RightS + "x"

Delx = (FindStr(RightSx, "000000x") > 0) ? 6 : (FindStr(RightSx, "00000x") > 0) ? 5 : \
(FindStr(RightSx, "0000x") > 0) ? 4 : (FindStr(RightSx, "000x") > 0) ? 3 : \
(FindStr(RightSx, "00x") > 0) ? 2 : (FindStr(RightSx, "0x") > 0) ? 1 : 0

Keep = keep && (abs(value(LeftS)) > 0)

return LeftS + MidStr(RightS, 1, RightSLength - Delx) + (!IsDec && Keep ? ".0" : "")  }

# ===============================================================================
# ===============================================================================
#	     Wrapper Functions
# ===============================================================================
# ===============================================================================

function iFrostyBorders(clip Source, int "OutWidth", int "OutHeight", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", int "TSoft", bool "Faster", \
string "Resizer", string "RStr", bool "Info")  {

Info = default(Info, true)

return FrostyBorders(Source, OutWidth, OutHeight, InDAR, InSAR, Mod, \
Frosty, FrostyStatic, Clone, FrostyGradient, FrostyPlain, Plain, BColor, BDivider, BDColor, Feather, \
Bright, Cont, Sat, Blend, Blur, VBlur, Iterations, GPlugin, Texture, TextureC, TSoft, Faster, Resizer, RStr, Info)  }

# -------------------------------------------------------------------------------

function Borders(clip Source, int "OutWidth", int "OutHeight", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", int "TSoft", bool "Faster", \
string "Resizer", string "RStr", bool "Info")  {

Plain = default(Plain, true)

return FrostyBorders(Source, OutWidth, OutHeight, InDAR, InSAR, Mod, \
Frosty, FrostyStatic, Clone, FrostyGradient, FrostyPlain, Plain, BColor, BDivider, BDColor, Feather, \
Bright, Cont, Sat, Blend, Blur, VBlur, Iterations, GPlugin, Texture, TextureC, TSoft, Faster, Resizer, RStr, Info)  }

# -------------------------------------------------------------------------------

function iBorders(clip Source, int "OutWidth", int "OutHeight", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", int "TSoft", bool "Faster", \
string "Resizer", string "RStr", bool "Info")  {

Plain = default(Plain, true)
Info = default(Info, true)

return FrostyBorders(Source, OutWidth, OutHeight, InDAR, InSAR, Mod, \
Frosty, FrostyStatic, Clone, FrostyGradient, FrostyPlain, Plain, BColor, BDivider, BDColor, Feather, \
Bright, Cont, Sat, Blend, Blur, VBlur, Iterations, GPlugin, Texture, TextureC, TSoft, Faster, Resizer, RStr, Info)  }

# ===============================================================================
# ===============================================================================
#	     Resizing Defaults
# ===============================================================================
# ===============================================================================

# When a resizing method is specified via the Resizer argument, the functions below are ignored.
# When the RStr argument is used, the RStr function is ignored.

function FB_Default_Resizer() { return "" }
function FB_Default_RStr() { return "" }

# ===============================================================================
# ===============================================================================