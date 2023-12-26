# ===============================================================================
# ===============================================================================
#            FrostyBorders 2023-10-28
# ===============================================================================
# ===============================================================================

function FrostyBorders(clip Source, \
int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", \
val "CropDAR", float "TCRatio", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", \
bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", \
float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", bool "StaticT", \
int "TSoft", bool "Faster", string "Resizer", string "RStr", bool "Info")  {

# ===============================================================================

AvsVerStrLC = LCase(VersionString())
IsAvsPlus = (FindStr(AvsVerStrLC, "avisynth+") > 0) || (FindStr(AvsVerStrLC, "avisynth neo") > 0)
AvsStrNum = IsAvsPlus ? FindStr(AvsVerStrLC, "(r") + 2 : 0
AvsBuildNum = (AvsStrNum > 2) ? int(value(MidStr(AvsVerStrLC, AvsStrNum))) : 0
IsAvsHBD = (AvsBuildNum > 2294)

Source_Width = width(Source)
F_Source_Width = float(Source_Width)
Source_Height = height(Source)
F_Source_Height = float(Source_Height)

FB = " FrostyBorders " + chr(10)
Assert(HasVideo(Source) && (Source_Width > 48) && (Source_Height > 48), \
FB + " No video found or the source width or height is too small " + chr(10))
Assert(!IsRGB(Source), FB + " RGB video is not supported " + chr(10))

TotalFrames = FrameCount(Source)
LastFrame = TotalFrames - 1
Source_Bits = IsAvsHBD ? BitsPerComponent(Source) : 8
SourceAudio = !HasAudio(Source) ? Source : Source.KillVideo()
Source = Source.KillAudio()
Color_Format = PixelType(Source)
WidthMod = IsYV411(Source) ? 4 : \
(IsAvsHBD && (Is420(Source) || Is422(Source))) || IsYV12(Source) || IsYV16(Source) || IsYUY2(Source) ? 2 : 1
HeightMod = (IsAvsHBD && Is420(Source)) || IsYV12(Source) ? 2 : 1
F_WidthMod = float(WidthMod)
F_HeightMod = float(HeightMod)

OutWidth = default(OutWidth, 0)
OutHeight = default(OutHeight, 0)
F_OutWidth = float(OutWidth)
F_OutHeight = float(OutHeight)
CL = default(CL, 0)
CT = default(CT, 0)
CR = default(CR, 0)
CB = default(CB, 0)
CR = (CR == 0) ? 0 : (CR < 0) ? -CR : Source_Width - CL - CR
CB = (CB == 0) ? 0 : (CB < 0) ? -CB : Source_Height - CT - CB
CRTest = ((CL + CR) < Source_Width)
CBTest = ((CT + CB) < Source_Height)
CropDAR = default(CropDAR, 0.0)
TCRatio = default(TCRatio, 0.5)
IsInDAR = defined(InDAR)
IsInSAR = defined(InSAR)
InDAR = default(InDAR, 0.0)
InSAR = default(InSAR, 0.0)
IsMod = defined(Mod)
Mod = default(Mod, 2 * WidthMod)
HMod = IsMod ? Mod : 2 * HeightMod
F_Mod = float(Mod)
F_HMod = float(HMod)
Info = default(Info, false)

# ===============================================================================
#            Insist
# ===============================================================================

Assert((OutWidth == 0) || (WidthMod != 2) || (OutWidth % 2 == 0), \
FB + " " + Color_Format + " requires a Mod2 OutWidth " + chr(10))
Assert((OutWidth == 0) || (WidthMod != 4) || (OutWidth % 4 == 0), \
FB + " " + Color_Format + " requires a Mod4 OutWidth " + chr(10))
Assert((OutHeight == 0) || (HeightMod != 2) || (OutHeight % 2 == 0), \
FB + " " + Color_Format + " requires a Mod4 OutHeight " + chr(10))

Assert(CRTest, FB + " Left plus right cropping must be less than the source width " + chr(10))
Assert(CBTest, FB + " Top plus bottom cropping must be less than the source height " + chr(10))
Assert((CL >= 0) && (CT >= 0), FB + " CL & CT must be greater than, or equal to zero " + chr(10))
Assert(IsFloat(CropDAR) && ((CropDAR == 0) || (!IsInt(CropDAR) && (CropDAR > 0))), \
FB + " CropDAR must be zero or a positive floating point number " + chr(10) + \
" (16.0/9.0 or 1.7778 etc)" + chr(10))
Assert((0.0 <= TCRatio <= 1.0), FB + " The valid range for TCRatio is 0 to 1.0 " + chr(10))

Assert(IsFloat(InDAR) && ((InDAR == 0) || (!IsInt(InDAR) && (InDAR > 0))), \
FB + " InDAR must be zero or a positive floating point number " + chr(10) + \
" (16.0/9.0 or 1.7778 etc)" + chr(10))
Assert(IsFloat(InSAR) && ((InSAR == 0) || (!IsInt(InSAR) && (InSAR > 0))), \
FB + " InSAR must be zero or a positive floating point number " + chr(10) + \
" (64.0/45.0 or 1.4222 etc)" + chr(10))
Assert((InDAR == 0) || (InSAR == 0), FB + " InDAR & InSAR can't be specified together " + chr(10))

Assert((Mod == 1) || (Mod == 2) || (Mod == 4) || (Mod == 8) || (Mod == 16), \
FB + " Mod must be 1, 2, 4, 8 or 16 " + chr(10))
Assert((Mod % 2 == 0) || (WidthMod != 2), \
FB + " " + Color_Format + " requires a minimum width Mod of 2 " + chr(10))
Assert((Mod % 4 == 0) || (WidthMod != 4), FB + \
FB + " " + Color_Format + " requires a minimum width Mod of 4 " + chr(10))
Assert((HMod % 2 == 0) || (HeightMod != 2), FB + \
FB + " " + Color_Format + " requires a minimum height Mod of 2 " + chr(10))

# ===============================================================================
#            Configure Resizer
# ===============================================================================

IsResampleMT = IsAvsHBD ? FunctionExists("Spline36ResizeMT") : Eval("""  Try{  Spline36ResizeMT(xx=0)  }
Catch(err){  (FindStr(LCase(err), "there is no function named") == 0)  }  """)

IsResizer = defined(Resizer)
Resizer = default(Resizer, FB_Default_Resizer())
Resizer = (Resizer != "") ? Resizer : "Spline36"

IsResizeMTAppended = (RightStr(Resizer, 8) == "ResizeMT") || (RightStr(Resizer, 8) == "MTResize")
IsMTAppended = (RightStr(Resizer, 2) == "MT")
IsResizeMT = IsResizeMTAppended || IsMTAppended
IsResizeAppended = (RightStr(Resizer, 6) == "Resize")

Kernel = IsResizeMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 8) : \
IsMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 2) : \
IsResizeAppended ? LeftStr(Resizer, StrLen(Resizer) - 6) : Resizer

IsAVSKernel = \
(Kernel == "Bicubic") || (Kernel == "Bilinear") || (Kernel == "Blackman") || (Kernel == "Gauss") || \
(Kernel == "Lanczos") || (Kernel == "Lanczos3") || (Kernel == "Lanczos4") || (Kernel == "Point") || \
(Kernel == "Spline16") || (Kernel == "Spline36") || (Kernel == "Spline64") || (Kernel == "Sinc")

Resizer = !IsAVSKernel ? Resizer : (Kernel == "Lanczos3") ? "Lanczos" : Kernel
Resizer = !IsAVSKernel ? Resizer : Resizer + (IsResizeMT || IsResampleMT ? "ResizeMT" : "Resize")

RStr = default(RStr, IsResizer ? "" : FB_Default_RStr())
ResStr = (RStr == "") ? "" : ", " + RStr

# ===============================================================================
#            Aspect & Dimensions
# ===============================================================================

PropsNum = (AvsBuildNum >= 3593) ? Source.propGetAny("_SARNum") : undefined()
PropsDen = (AvsBuildNum >= 3593) ? Source.propGetAny("_SARDen") : undefined()
PropsNum = defined(PropsNum) && IsInt(PropsNum) ? PropsNum : 0
PropsDen = defined(PropsDen) && IsInt(PropsDen) ? PropsDen : 0
PropsSAR = (PropsNum > 0 < PropsDen) && !IsInDAR && !IsInSAR ? float(PropsNum) / float(PropsDen) : 0
InSAR = (InSAR > 0) ? InSAR : (PropsSAR > 0) && (PropsSAR != 1) ? PropsSAR : 0
IsAnamorphicInput = (InDAR > 0) || (InSAR > 0)
IsBorders = (OutWidth > 0) && (OutHeight > 0)

Cropped_Source_Width = Source_Width - CL - CR
Cropped_Source_Height = Source_Height - CT - CB
F_Cropped_Source_Width = float(Cropped_Source_Width)
F_Cropped_Source_Height = float(Cropped_Source_Height)

Cropped_Source_DAR = !IsAnamorphicInput ? F_Cropped_Source_Width / F_Cropped_Source_Height : \
(InDAR > 0) ? F_Cropped_Source_Width * F_Source_Height * InDAR / F_Cropped_Source_Height / F_Source_Width : \
F_Cropped_Source_Width * InSAR / F_Cropped_Source_Height

Mod_Cropped_Resized_Width = !IsAnamorphicInput ? floor(F_Cropped_Source_Width / F_Mod) * Mod : \
(InDAR > 0) ? floor(F_Cropped_Source_Width * F_Source_Height * InDAR / F_Source_Width / F_Mod) * Mod : \
floor(F_Cropped_Source_Width * InSAR / F_Mod) * Mod

Mod_Cropped_Height = floor(F_Cropped_Source_Height / F_HMod) * HMod

Resizing_Width = (OutWidth > 0) ? OutWidth : Mod_Cropped_Resized_Width
Resizing_Height = (OutHeight > 0) ? OutHeight : Mod_Cropped_Height
F_Resizing_Width = float(Resizing_Width)
F_Resizing_Height = float(Resizing_Height)

Resizing_DAR = (CropDAR > 0) ? CropDAR : Cropped_Source_DAR

Height_From_Width = IsBorders ? (Resizing_DAR >= (F_Resizing_Width / F_Resizing_Height)) : \
(OutWidth > 0) ? true : (OutHeight > 0) ? false : true

Height_From_Width ? Eval("""

# ===============================================================================
#            Height Calculated From Width
# ===============================================================================

F_Aspect_Height = F_Resizing_Width / Resizing_DAR
F_Aspect_Height = FB_IsEqual(F_Aspect_Height, round(F_Aspect_Height)) && \
(round(F_Aspect_Height) % HeightMod == 0) ? float(round(F_Aspect_Height)) : F_Aspect_Height

F_Height_Adjust = F_Aspect_Height - (floor(F_Aspect_Height / F_HMod) * HMod)
F_Height_Up = F_Aspect_Height + F_HMod - F_Height_Adjust
F_Height_Down = F_Aspect_Height - F_Height_Adjust

F_Resizing_Height = \
((F_Height_Up - F_Aspect_Height) < (F_HMod / 2.0)) ? F_Height_Up : F_Height_Down
Resizing_Height = round(F_Resizing_Height)

""", "Height From Width Resizing Eval") : Eval("""

# ===============================================================================
#            Width Calculated From Height
# ===============================================================================

F_Aspect_Width = F_Resizing_Height * Resizing_DAR
F_Aspect_Width = FB_IsEqual(F_Aspect_Width, round(F_Aspect_Width)) && \
(round(F_Aspect_Width) % WidthMod == 0) ? float(round(F_Aspect_Width)) : F_Aspect_Width

F_Width_Adjust = F_Aspect_Width - (floor(F_Aspect_Width / F_Mod) * Mod)
F_Width_Up = F_Aspect_Width + F_Mod - F_Width_Adjust
F_Width_Down = F_Aspect_Width - F_Width_Adjust

F_Resizing_Width = \
((F_Width_Up - F_Aspect_Width) < (F_Mod / 2.0)) ? F_Width_Up : F_Width_Down
Resizing_Width = round(F_Resizing_Width)

""", "Width From Height Resizing Eval")

# ===============================================================================
#            Cropping & Resizing
# ===============================================================================

TCRatio = (CropDAR == 0) || (CropDAR <= Cropped_Source_DAR) ? 0.5 : TCRatio
Cropping_DAR = F_Resizing_Width / F_Resizing_Height

F_Extra_Width_Crop = FB_IsEqual(Cropping_DAR, Cropped_Source_DAR) || \
(Cropping_DAR > Cropped_Source_DAR) ? 0.0 : \
max(0.0, !IsAnamorphicInput ? F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_Resizing_Width / F_Resizing_Height) : \
(InDAR > 0) ? F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_Resizing_Width * \
F_Source_Width / InDAR / F_Resizing_Height / F_Source_Height) : \
F_Cropped_Source_Width - \
(F_Cropped_Source_Height * F_Resizing_Width / F_Resizing_Height / InSAR))

F_Extra_Height_Crop = FB_IsEqual(Cropping_DAR, Cropped_Source_DAR) || \
(Cropping_DAR < Cropped_Source_DAR) ? 0.0 : \
max(0.0, !IsAnamorphicInput ? F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_Resizing_Height / F_Resizing_Width) : \
(InDAR > 0) ? F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_Resizing_Height * \
F_Source_Height * InDAR / F_Resizing_Width / F_Source_Width) : \
F_Cropped_Source_Height - \
(F_Cropped_Source_Width * F_Resizing_Height * InSAR / F_Resizing_Width))

F_Extra_Crop_LR = max(0.0, F_Extra_Width_Crop / 2.0)
F_Extra_Crop_LR = FB_IsEqual(F_Extra_Crop_LR, round(F_Extra_Crop_LR)) ? \
round(F_Extra_Crop_LR) : F_Extra_Crop_LR

F_Extra_Crop_T = max(0.0, (TCRatio == 0.5) ? F_Extra_Height_Crop / 2.0 : \
F_Extra_Height_Crop * TCRatio)
F_Extra_Crop_T = FB_IsEqual(F_Extra_Crop_T, round(F_Extra_Crop_T)) ? \
round(F_Extra_Crop_T) : F_Extra_Crop_T

F_Extra_Crop_B = max(0.0, (TCRatio == 0.5) ? F_Extra_Height_Crop / 2.0 : \
F_Extra_Height_Crop - F_Extra_Crop_T)
F_Extra_Crop_B = FB_IsEqual(F_Extra_Crop_B, round(F_Extra_Crop_B)) ? \
round(F_Extra_Crop_B) : F_Extra_Crop_B

CCL = round(max(0, float(CL) + F_Extra_Crop_LR - fmod(float(CL) + F_Extra_Crop_LR, WidthMod)))
CCR = round(max(0, float(CR) + F_Extra_Crop_LR - fmod(float(CR) + F_Extra_Crop_LR, WidthMod)))
CCT = round(max(0, float(CT) + F_Extra_Crop_T - fmod(float(CT) + F_Extra_Crop_T, HeightMod)))
CCB = round(max(0, float(CB) + F_Extra_Crop_B - fmod(float(CB) + F_Extra_Crop_B, HeightMod)))
RCL = max(0.0, float(CL) + F_Extra_Crop_LR - CCL)
RCR = max(0.0, float(CR) + F_Extra_Crop_LR - CCR)
RCT = max(0.0, float(CT) + F_Extra_Crop_T - CCT)
RCB = max(0.0, float(CB) + F_Extra_Crop_B - CCB)

F_Cropped_Width = F_Source_Width - CCL - CCR - RCL - RCR
F_Cropped_Height = F_Source_Height - CCT - CCB - RCT - RCB

Cropped = (0 == CCL == CCT == CCR == CCB) ? Source : Source.crop(CCL, CCT, -CCR, -CCB)

Resized = Cropped.Eval(Resizer + "(Resizing_Width, Resizing_Height, \
src_left=RCL, src_top=RCT, src_width=F_Cropped_Width, src_height=F_Cropped_Height" + ResStr + ")")

# ===============================================================================
#            Border Size
# ===============================================================================

IsBorders ? Eval("""

CroppedMoreLeft = (CL > CR)
Additional_Width = OutWidth - Resizing_Width
EvenWidthSplit = ((Additional_Width % (WidthMod * 2)) == 0)
F_WidthSplit = float(Additional_Width) / 2.0
BL_Adjust = F_WidthSplit - (floor(F_WidthSplit / F_WidthMod) * WidthMod)
BL_Adjust_Up = min(Additional_Width, round(F_WidthSplit + WidthMod - BL_Adjust))
BL_Adjust_Down = F_WidthSplit - BL_Adjust
BL = round(EvenWidthSplit ? Additional_Width / 2 : CroppedMoreLeft ? BL_Adjust_Up : BL_Adjust_Down)
BR = Additional_Width - BL

CroppedMoreTop = (CT > CB)
Additional_Height = OutHeight - Resizing_Height
EvenHeightSplit = ((Additional_Height % (HeightMod * 2)) == 0)
F_HeightSplit = float(Additional_Height) / 2.0
BT_Adjust = F_HeightSplit - (floor(F_HeightSplit / F_HeightMod) * HeightMod)
BT_Adjust_Up = min(Additional_Height, round(F_HeightSplit + HeightMod - BT_Adjust))
BT_Adjust_Down = F_HeightSplit - BT_Adjust
BT = round(EvenHeightSplit ? Additional_Height / 2 : CroppedMoreTop ? BT_Adjust_Up : BT_Adjust_Down)
BB = Additional_Height - BT

# ===============================================================================
#            Frosty Defaults
# ===============================================================================

IsPillarBox = (BL > 0) || (BR > 0)
IsLetterBox = (BT > 0) || (BB > 0)
IsBorders = IsPillarBox || IsLetterBox

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
IsBlur = defined(Blur)
IsVBlur = defined(VBlur)
Iterations = default(Iterations, 3)
GPlugin = default(GPlugin, 1)
StaticT = default(StaticT, true)
DynamicT = StaticT ? false : true
Faster = default(Faster, false)

BorderMin = Frosty || IsFrostyStatic || FrostyGradient ? (IsPillarBox && (WidthMod == 4) ? 32 : 16) : \
Clone1 || Clone2 || Clone3 ? (IsPillarBox && (WidthMod == 4) ? 8 : 4) : IsPillarBox ? WidthMod : HeightMod

SizeTest = \
(IsPillarBox && (BL >= BorderMin <= BR)) || (IsLetterBox && (BT >= BorderMin <= BB))
IsBDivider = \
(BDivider > 0) && ((IsPillarBox && (BL > BorderMin < BR)) || (IsLetterBox && (BT > BorderMin < BB)))
IsFeather = \
(Feather > 0) && ((IsPillarBox && (BL >= WidthMod <= BR)) || (IsLetterBox && (BT >= HeightMod <= BB)))

FrostyPlain = FrostyPlain && !Plain
FrostyGradient = FrostyGradient && !FrostyPlain && !Plain && SizeTest
Clone1 = Clone1 || (Clone2 && !IsFeather) && !FrostyGradient && !FrostyPlain && !Plain && SizeTest
Clone2 = Clone2 && IsFeather && !FrostyGradient && !FrostyPlain && !Plain && SizeTest
Clone3 = Clone3 && !FrostyGradient && !FrostyPlain && !Plain && SizeTest
IsClone = Clone1 || Clone2 || Clone3
IsFrostyStatic = IsFrostyStatic && !FrostyGradient && !FrostyPlain && !Plain && !IsClone && SizeTest
Frosty = Frosty && !FrostyGradient && !FrostyPlain && !Plain && !IsClone && SizeTest
IsFrosty = Frosty || IsFrostyStatic
Plain = Plain || (!FrostyGradient && !FrostyPlain && !IsClone && !IsFrosty)
IsPlain = Plain || FrostyPlain

Ratio = (IsPillarBox ? F_Resizing_Width : F_OutWidth) * \
(IsPillarBox ? F_OutHeight : F_Resizing_Height) / F_Source_Width / F_Source_Height

BClip = IsClone || (InDAR > 0) || ((InSAR > 0) && (InSAR != 1)) || (Ratio < 1) ? Resized : Cropped
BClipWidth = width(BClip)
F_BClipWidth = float(BClipWidth)
BClipHeight = height(BClip)
F_BClipHeight = float(BClipHeight)
F_VidSize = IsPillarBox ? F_BClipHeight : F_BClipWidth

Feather = !IsFeather ? 0 : IsPillarBox ? \
min((Feather < WidthMod) ? WidthMod : Feather, floor(F_Resizing_Width / 6.0 / F_WidthMod) * WidthMod) : \
min((Feather < HeightMod) ? HeightMod : Feather, floor(F_Resizing_Height / 6.0 / F_HeightMod) * HeightMod)

BColor = default(BColor, FrostyGradient || FrostyPlain ? $008080 : $000000)
Bright = default(Bright, IsPillarBox || Plain ? 0.0 : -25.0)
Cont = default(Cont, IsPillarBox || Plain ? 1.0 : 0.66)
Sat = default(Sat, Plain ? 1.0 : IsPillarBox ? 0.85 : 0.66)
Blend = default(Blend, IsFrostyStatic ? 0.5 : IsFrosty ? 0.2 : 0.0)

Blur = \
IsBlur ? ((Blur >= 0) ? Blur : -Blur * F_VidSize / 720.0) : \
Clone1 || Clone2 ? F_VidSize / 75.0 : Clone3 ? F_VidSize / 25.0 : 0
VBlur = \
IsVBlur ? ((VBlur >= 0) ? VBlur : -VBlur * F_VidSize / 720.0) : IsBlur || IsClone ? Blur : 0

Texture = default(Texture, IsClone ? 2.5 : !Plain ? 5.0 : 0.0)
Texture = (Texture == 0) || (GPlugin == 0) ? 0 : (GPlugin == 1) ? Texture : round(Texture * 64.0)
TextureC = default(TextureC, 0.0)
TextureC = (TextureC == 0) || (GPlugin == 0) ? 0 : (GPlugin == 1) ? TextureC : round(TextureC * 64.0)
TSoft = default(TSoft, Frosty ? 5 : Clone3 ? 1 : 0)
IsTSoft = (TSoft > 0) && (Frosty || IsClone)

# ===============================================================================
#            Insist
# ===============================================================================

Assert((0 <= FrostyStatic <= LastFrame), \
FB + " The valid range for FrostyStatic is from zero to the final frame number " + \
string(LastFrame, "(0 to %.0f) ") + chr(10))

Assert(!IsPillarBox || (BDivider <= 0) || (WidthMod != 2) || (BDivider % 2 == 0), \
FB + " " + Color_Format + " requires a Mod2 BDivider for pillarbox borders " + chr(10))
Assert(!IsPillarBox || (BDivider <= 0) || (WidthMod != 4) || (BDivider % 4 == 0), \
FB + " " + Color_Format + " requires a Mod4 BDivider for pillarbox borders " + chr(10))
Assert(!IsLetterBox || (BDivider <= 0) || (HeightMod != 2) || (BDivider % 2 == 0), \
FB + " " + Color_Format + " requires a Mod2 BDivider for letterbox borders " + chr(10))

Assert((Feather == 0) || (BDivider == 0), \
FB + " Feather and BDivider can't be used together (one must equal zero) " + chr(10))
Assert((Feather == 0) || !FrostyGradient, \
FB + " Feather can't be greater than zero when FrostyGradient=true " + chr(10))

Assert((0 <= GPlugin <= 2), FB + " The valid choices for GPlugin are " + chr(10) + \
" 0 (no added grain), 1 (AddGrainC) or 2 (neo_f3kdb) " + chr(10))

Assert((0 <= Clone <= 3), FB + " Clone can only be 0 (disabled), 1, 2 or 3 " + chr(10))
Assert((-255 <= Bright <= 255), FB + " The valid range for Bright is -255 thru 255 " + chr(10))
Assert((0 <= Cont <= 10), FB + " The valid range for Cont is 0.0 thru 10.0 " + chr(10))
Assert((0 <= Sat <= 10), FB + " The valid range for Sat is 0.0 thru 10.0 " + chr(10))
Assert((0 <= Blend <= 1), FB + " The valid range for Blend is 0.0 to 1.0 " + chr(10))
Assert((0 <= Texture) && (0 <= TextureC), FB + " Texture and TextureC cannot be negative " + chr(10))
Assert((0 <= TSoft <= 7), FB + " The valid range for TSoft is 0 to 7 " + chr(10))

""", "Borders & Frosty Defaults Eval") : nop()

# ===============================================================================
#            PillarBox Borders
# ===============================================================================

IsBorders && IsPillarBox ? Eval("""

BL = IsBDivider ? BL - BDivider : BL
BR = IsBDivider ? BR - BDivider : BR
FL = IsFeather ? max(BL, floor((BL + (Feather * 3)) / F_WidthMod) * WidthMod) : nop()
FR = IsFeather ? max(BR, floor((BR + (Feather * 3)) / F_WidthMod) * WidthMod) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Strings
# -------------------------------------------------------------------------------

ResizedStr = !IsBDivider ? ",Resized," : ",Resized.AddBorders(BDivider, 0, BDivider, 0, color=BDColor),"

FastBlurStr = ".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true)"

FBordStr = ".AddBorders(0, 0, Resizing_Width-FL+BL-FR+BR, 0),"
GaussMTStr = ".GaussResize" + (!IsResampleMT ? "" : "MT")

GaussLStr = !IsPlain ? GaussMTStr + "(BL, OutHeight)" : nop()
GaussRStr = !IsPlain ? GaussMTStr + "(BR, OutHeight)" : nop()
FGaussLStr = IsFeather ? GaussMTStr + "(FL, OutHeight)" : nop()
FGaussRStr = IsFeather ? GaussMTStr + "(FR, OutHeight)" : nop()

Gauss3LStr = Clone3 ? GaussMTStr + "(max(BL, floor(WidthCloneBorderL * RatioL / F_WidthMod) * WidthMod), \
max(OutHeight, floor(OutHeight * RatioL / F_HeightMod) * HeightMod))" : nop()
Gauss3RStr = Clone3 ? GaussMTStr + "(max(BR, floor(WidthCloneBorderR * RatioR / F_WidthMod) * WidthMod), \
max(OutHeight, floor(OutHeight * RatioR / F_HeightMod) * HeightMod))" : nop()

GrainStr = ((Texture == 0) && (TextureC == 0)) || (GPlugin == 0) ? "" : \
(GPlugin == 1) ? ".AddGrain(var=Texture, uvar=TextureC, constant=StaticT)" : \
".neo_f3kdb(grainY=Texture, grainC=TextureC, dither_algo=1, " + \
"dynamic_grain=DynamicT, output_depth=Source_Bits)"

LoopStr = ".Trim(1, 1).Loop(TotalFrames)"
SLoopStr = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(TotalFrames)" : ""
TSoftStr = IsTSoft ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : ""
TweakStr = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? ".Tweak(bright=Bright, cont=Cont, sat=Sat)" : ""

TBStr = TweakStr + FastBlurStr
TBGStr = TweakStr + FastBlurStr + GrainStr

# -------------------------------------------------------------------------------
#            PillarBox Frosty Borders
# -------------------------------------------------------------------------------

FrostyCrop = IsFrosty && IsTSoft ? \
BClipWidth - max(BorderMin, round(F_BClipWidth / (!Faster ? 5.0 : 10.0) / F_WidthMod) * WidthMod) : nop()

FrostyLR = IsFrosty && IsTSoft ? \
Eval("StackHorizontal(BClip.crop(0, 0, -FrostyCrop, 0), BClip.crop(FrostyCrop, 0, 0, 0))" + TSoftStr) : nop()
WidthFrostyLR = IsFrosty && IsTSoft ? width(FrostyLR) : nop()

FrostyCrop = IsFrosty ? (IsTSoft ? WidthFrostyLR - \
max(BorderMin, round(float(WidthFrostyLR) / (!Faster ? 16.0 : 8.0) / F_WidthMod) * WidthMod) : \
BClipWidth - max(BorderMin, round(F_BClipWidth / 80.0 / F_WidthMod) * WidthMod)) : nop()

FrostyL = IsFrosty ? (IsTSoft ? FrostyLR : BClip).crop(0, 0, -FrostyCrop, 0) : nop()
FrostyR = IsFrosty ? (IsTSoft ? FrostyLR : BClip).crop(FrostyCrop, 0, 0, 0) : nop()

WidthFrostyL = IsFrosty ? width(FrostyL) : nop()
WidthFrostyR = IsFrosty ? width(FrostyR) : nop()

FrostyBlendL = IsFrosty ? ((Blend == 0) ? FrostyL : (Blend == 1) ? FrostyR : \
Overlay(FrostyL, FlipHorizontal(FrostyR), Opacity=Blend)) : nop()
FrostyBlendR = IsFrosty ? ((Blend == 0) ? FrostyR : (Blend == 1) ? FrostyL : \
Overlay(FrostyR, FlipHorizontal(FrostyL), Opacity=Blend)) : nop()

Blur = IsBlur ? Blur : IsFrosty ? max(WidthFrostyL, WidthFrostyR) + (!IsFeather ? 0 : Feather) : Blur
VBlur = IsVBlur ? VBlur : IsFrosty ? F_BClipHeight / 10.0 : VBlur

FastBlurStr = (Blur == 0 == VBlur) || FrostyGradient || (IsPlain && !IsFeather) ? "" : FastBlurStr

FrostyL = Frosty ? Eval("FrostyBlendL" + TBStr + GaussLStr + GrainStr + SLoopStr) : nop()
FrostyR = Frosty ? Eval("FrostyBlendR" + TBStr + GaussRStr + GrainStr + SLoopStr) : nop()

FFrostyL = Frosty && IsFeather ? Eval("FrostyBlendL" + TBStr + FGaussLStr + GrainStr + SLoopStr) : nop()
FFrostyR = Frosty && IsFeather ? Eval("FrostyBlendR" + TBStr + FGaussRStr + GrainStr + SLoopStr) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Clone Borders
# -------------------------------------------------------------------------------

MaxCloneC = IsClone || (IsFrosty && IsFeather) ? floor(F_BClipWidth / 2.0 / F_WidthMod) * WidthMod : nop()
CloneCropL = IsClone || (IsFrosty && IsFeather) ? max(MaxCloneC, BClipWidth - BL) : nop()
CloneCropR = IsClone || (IsFrosty && IsFeather) ? max(MaxCloneC, BClipWidth - BR) : nop()
CloneBorderL = IsClone || (IsFrosty && IsFeather) ? Resized.crop(0, 0, -CloneCropL, 0) : nop()
CloneBorderR = IsClone || (IsFrosty && IsFeather) ? Resized.crop(CloneCropR, 0, 0, 0) : nop()
WidthCloneBorderL = IsClone || (IsFrosty && IsFeather) ? width(CloneBorderL) : nop()
WidthCloneBorderR = IsClone || (IsFrosty && IsFeather) ? width(CloneBorderR) : nop()

FlipCloneL = IsClone || (IsFrosty && IsFeather) ? \
FlipHorizontal(((WidthCloneBorderL == BL) ? CloneBorderL : Eval("CloneBorderL" + GaussLStr))) : nop()
FlipCloneR = IsClone || (IsFrosty && IsFeather) ? \
FlipHorizontal(((WidthCloneBorderR == BR) ? CloneBorderR : Eval("CloneBorderR" + GaussRStr))) : nop()

CloneLR = (Clone1 || Clone3) && IsTSoft ? Eval("StackHorizontal(CloneBorderL, CloneBorderR)" + TSoftStr) : nop()
WidthCloneLR = (Clone1 || Clone3) && IsTSoft ? width(CloneLR) : nop()

CloneL = \
Clone1 || Clone3 ? (IsTSoft ? CloneLR.crop(0, 0, -WidthCloneLR+WidthCloneBorderL, 0) : CloneBorderL) : nop()
CloneR = \
Clone1 || Clone3 ? (IsTSoft ? CloneLR.crop(WidthCloneLR-WidthCloneBorderR, 0, 0, 0) : CloneBorderR) : nop()

CloneBlendL = Clone1 || Clone3 ? ((Blend == 0) ? CloneL : (Blend == 1) ? CloneR : \
Overlay(CloneL, FlipHorizontal(CloneR), Opacity=Blend)) : nop()
CloneBlendR = Clone1 || Clone3 ? ((Blend == 0) ? CloneR : (Blend == 1) ? CloneL : \
Overlay(CloneR, FlipHorizontal(CloneL), Opacity=Blend)) : nop()

FCloneL = \
Clone1 && IsFeather ? ((WidthCloneBorderL == BL) ? CloneBlendL : Eval("CloneBlendL" + GaussLStr)) : nop()
FCloneR = \
Clone1 && IsFeather ? ((WidthCloneBorderR == BR) ? CloneBlendR : Eval("CloneBlendR" + GaussRStr)) : nop()

CloneL = Clone1 && !IsFeather ? ((WidthCloneBorderL == BL) ? \
Eval("CloneBlendL" + TBGStr) : Eval("CloneBlendL" + TBStr + GaussLStr + GrainStr)) : nop()
CloneR = Clone1 && !IsFeather ? ((WidthCloneBorderR == BR) ? \
Eval("CloneBlendR" + TBGStr) : Eval("CloneBlendR" + TBStr + GaussRStr + GrainStr)) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Clone2 Borders
# -------------------------------------------------------------------------------

Clone2CropL = Clone2 ? max(MaxCloneC, BClipWidth - FL) : nop()
Clone2CropR = Clone2 ? max(MaxCloneC, BClipWidth - FR) : nop()
Clone2BL = Clone2 ? BClip.crop(0, 0, -Clone2CropL, 0) : nop()
Clone2BR = Clone2 ? BClip.crop(Clone2CropR, 0, 0, 0) : nop()
WidthClone2BL = Clone2 ? width(Clone2BL) : nop()
WidthClone2BR = Clone2 ? width(Clone2BR) : nop()

FlipClone2L = Clone2 ? FlipHorizontal(((WidthClone2BL == FL) ? Clone2BL : Eval("Clone2BL" + FGaussLStr))) : nop()
FlipClone2R = Clone2 ? FlipHorizontal(((WidthClone2BR == FR) ? Clone2BR : Eval("Clone2BR" + FGaussRStr))) : nop()

Clone2LR = Clone2 && IsTSoft ? Eval("StackHorizontal(Clone2BL, Clone2BR)" + TSoftStr) : nop()
WidthClone2LR = Clone2 && IsTSoft ? width(Clone2LR) : nop()

Clone2L = Clone2 ? (IsTSoft ? Clone2LR.crop(0, 0, -WidthClone2LR+WidthClone2BL, 0) : Clone2BL) : nop()
Clone2R = Clone2 ? (IsTSoft ? Clone2LR.crop(WidthClone2LR-WidthClone2BR, 0, 0, 0) : Clone2BR) : nop()

Clone2BlendL = Clone2 ? ((Blend == 0) ? Clone2L : (Blend == 1) ? Clone2R : \
Overlay(Clone2L, FlipHorizontal(Clone2R), Opacity=Blend)) : nop()
Clone2BlendR = Clone2 ? ((Blend == 0) ? Clone2R : (Blend == 1) ? Clone2L : \
Overlay(Clone2R, FlipHorizontal(Clone2L), Opacity=Blend)) : nop()

Clone2L = Clone2 ? ((WidthClone2BL == FL) ? Eval("Clone2BlendL" + TBGStr) : \
Eval("Clone2BlendL" + TBStr + FGaussLStr + GrainStr)) : nop()
Clone2R = Clone2 ? ((WidthClone2BR == FR) ? Eval("Clone2BlendR" + TBGStr) : \
Eval("Clone2BlendR" + TBStr + FGaussRStr + GrainStr)) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Clone3 Borders
# -------------------------------------------------------------------------------

RatioL = Clone3 ? (((WidthCloneBorderL - BL) >= 0) ? 1.618 : float(BL) / float(WidthCloneBorderL)) : nop()
RatioR = Clone3 ? (((WidthCloneBorderR - BR) >= 0) ? 1.618 : float(BR) / float(WidthCloneBorderR)) : nop()

Clone3L = Clone3 ? Eval("CloneBlendL" + Gauss3LStr) : nop()
Clone3R = Clone3 ? Eval("CloneBlendR" + Gauss3RStr) : nop()
WidthClone3L = Clone3 ? width(Clone3L) : nop()
HeightClone3L = Clone3 ? height(Clone3L) : nop()
WidthClone3R = Clone3 ? width(Clone3R) : nop()
HeightClone3R = Clone3 ? height(Clone3R) : nop()

Clone3L_CL = Clone3 ? max(0, floor((WidthClone3L - BL) / F_WidthMod / 2.0) * WidthMod) : nop()
Clone3L_CR = Clone3 ? max(0, WidthClone3L - BL - Clone3L_CL) : nop()
Clone3L_CT = Clone3 ? max(0, floor((HeightClone3L - BClipHeight) / F_HeightMod / 2.0) * HeightMod) : nop()
Clone3L_CB = Clone3 ? max(0, HeightClone3L - BClipHeight - Clone3L_CT) : nop()
Clone3R_CL = Clone3 ? max(0, floor((WidthClone3R - BR) / F_WidthMod / 2.0) * WidthMod) : nop()
Clone3R_CR = Clone3 ? max(0, WidthClone3R - BR - Clone3R_CL) : nop()
Clone3R_CT = Clone3 ? max(0, floor((HeightClone3R - BClipHeight) / F_HeightMod / 2.0) * HeightMod) : nop()
Clone3R_CB = Clone3 ? max(0, HeightClone3R - BClipHeight - Clone3R_CT) : nop()

Clone3L = Clone3 ? Clone3L.crop(Clone3L_CL, Clone3L_CT, -Clone3L_CR, -Clone3L_CB) : nop()
Clone3R = Clone3 ? Clone3R.crop(Clone3R_CL, Clone3R_CT, -Clone3R_CR, -Clone3R_CB) : nop()

FClone3L = Clone3 && IsFeather ? Clone3L : nop()
FClone3R = Clone3 && IsFeather ? Clone3R : nop()

Clone3L = Clone3 && !IsFeather ? Eval("Clone3L" + TBGStr) : nop()
Clone3R = Clone3 && !IsFeather ? Eval("Clone3R" + TBGStr) : nop()

# -------------------------------------------------------------------------------
#            PillarBox FrostyGradient Borders
# -------------------------------------------------------------------------------

GradientLR = \
FrostyGradient ? BlankClip(BClip, width=88, height=OutHeight).AddBorders(8, 0, 0, 0, color=BColor)\
.Tweak(bright=Bright, cont=Cont, sat=Sat).FastBlur(50, y_blur=0, iterations=3, dither=true) : nop()
GradientL = FrostyGradient ? Eval("FlipHorizontal(GradientLR)" + GaussLStr + GrainStr + LoopStr) : nop()
GradientR = FrostyGradient ? Eval("GradientLR" + GaussRStr + GrainStr + LoopStr) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Plain Borders
# -------------------------------------------------------------------------------

PlainL = IsPlain && (BL >= WidthMod) ? \
Eval("BlankClip(Resized, width=BL, color=BColor)" + TweakStr + GrainStr + LoopStr) : nop()
PlainR = IsPlain && (BR >= WidthMod) ? \
Eval("BlankClip(Resized, width=BR, color=BColor)" + TweakStr + GrainStr + LoopStr) : nop()

PlainL2 = IsPlain && IsFeather ? Eval("BlankClip(Resized, width=BL, color=BColor)" + TweakStr + LoopStr) : nop()
PlainR2 = IsPlain && IsFeather ? Eval("BlankClip(Resized, width=BR, color=BColor)" + TweakStr + LoopStr) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Frosty Clip
# -------------------------------------------------------------------------------

FrostyBL = !IsFeather ? (IsFrosty ? FrostyL : Clone1 ? CloneL : Clone3 ? Clone3L : \
FrostyGradient ? GradientL : IsPlain && (BL >= WidthMod) ? PlainL : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneL : IsPlain && (BL >= WidthMod) ? PlainL2 : nop()

FrostyBR = !IsFeather ? (IsFrosty ? FrostyR : Clone1 ? CloneR : Clone3 ? Clone3R : \
FrostyGradient ? GradientR :IsPlain && (BR >= WidthMod) ? PlainR : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneR : IsPlain && (BR >= WidthMod) ? PlainR2 : nop()

FrostyClip = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BL >= WidthMod <= BR)) ? \
Eval("StackHorizontal(FrostyBL" + ResizedStr + "FrostyBR)") : \
IsPlain && (BL >= WidthMod) ? StackHorizontal(FrostyBL, Resized) : \
IsPlain && (BR >= WidthMod) ? StackHorizontal(Resized, FrostyBR) : Resized

# -------------------------------------------------------------------------------
#            PillarBox Feather Mask
# -------------------------------------------------------------------------------

FeatherMask = IsFeather ? BlankClip(Resized, width=Resizing_Width-(Feather*2))\
.AddBorders(BL+Feather, 0, BR+Feather, 0, color=$FFFFFF).ColorYUV(Levels="TV->PC")\
.FastBlur(Feather/2.25, y_blur=0, iterations=3, dither=true) : nop()

FeatherMask = IsFeather ? Eval("FeatherMask" + LoopStr) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Feather Clip
# -------------------------------------------------------------------------------

FeatherClip = IsFeather ? \
(IsFrosty ? StackHorizontal(FFrostyL.AddBorders(0, 0, Resizing_Width-FL+BL-FR+BR, 0), FFrostyR) : \
Clone1 ? Eval("StackHorizontal(StackHorizontal(FCloneL, Resized.crop(0, 0, -Resizing_Width+FL-BL, 0))" + \
TBGStr + FBordStr + "StackHorizontal(Resized.crop(Resizing_Width-FR+BR, 0, 0, 0), FCloneR)" + TBGStr + ")")  : \
Clone2 ? StackHorizontal(Clone2L.AddBorders(0, 0, Resizing_Width-FL+BL-FR+BR, 0), Clone2R) : \
Clone3 ? Eval("StackHorizontal(StackHorizontal(FClone3L, Resized.crop(0, 0, -Resizing_Width+FL-BL, 0))" + \
TBGStr + FBordStr + "StackHorizontal(Resized.crop(Resizing_Width-FR+BR, 0, 0, 0), FClone3R)" + TBGStr + ")") : \
Eval("StackHorizontal(BlankClip(Resized, width=FL, color=BColor)" + TweakStr + GrainStr + LoopStr + \
FBordStr + "BlankClip(Resized, width=FR, color=BColor)" + TweakStr + GrainStr + LoopStr + ")")) : nop()

# -------------------------------------------------------------------------------
#            PillarBox Output
# -------------------------------------------------------------------------------

FrostyOut = IsFeather ? Overlay(FrostyClip, FeatherClip, mask=FeatherMask) : FrostyClip

""", "Frosty PillarBox Eval") : IsBorders && IsLetterBox ? Eval("""

# ===============================================================================
#            LetterBox Borders
# ===============================================================================

BT = IsBDivider ? BT - BDivider : BT
BB = IsBDivider ? BB - BDivider : BB
FT = IsFeather ? max(BT, floor((BT + (Feather * 3)) / F_HeightMod) * HeightMod) : nop()
FB = IsFeather ? max(BB, floor((BB + (Feather * 3)) / F_HeightMod) * HeightMod) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Strings
# -------------------------------------------------------------------------------

ResizedStr = !IsBDivider ? ",Resized," : ",Resized.AddBorders(0, BDivider, 0, BDivider, color=BDColor),"

FastBlurStr = ".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true)"

FBordStr = ".AddBorders(0, 0, 0, Resizing_Height-FT+BT-FB+BB),"
GaussMTStr = ".GaussResize" + (!IsResizeMT ? "" : "MT")

GaussTStr = !IsPlain ? GaussMTStr + "(OutWidth, BT)" : nop()
GaussBStr = !IsPlain ? GaussMTStr + "(OutWidth, BB)" : nop()
FGaussTStr = IsFeather ? GaussMTStr + "(OutWidth, FT)" : nop()
FGaussBStr = IsFeather ? GaussMTStr + "(OutWidth, FB)" : nop()

Gauss3TStr = Clone3 ? GaussMTStr + "(max(OutWidth, floor(OutWidth * RatioT / F_WidthMod) * WidthMod), \
max(BT, floor(HeightCloneBorderT * RatioT / F_HeightMod) * HeightMod))" : nop()
Gauss3BStr = Clone3 ? GaussMTStr + "(max(OutWidth, floor(OutWidth * RatioB / F_WidthMod) * WidthMod), \
max(BB, floor(HeightCloneBorderB * RatioB / F_HeightMod) * HeightMod))" : nop()

GrainStr = ((Texture == 0) && (TextureC == 0)) || (GPlugin == 0) ? "" : \
(GPlugin == 1) ? ".AddGrain(var=Texture, uvar=TextureC, constant=StaticT)" : \
".neo_f3kdb(grainY=Texture, grainC=TextureC, dither_algo=1, " + \
"dynamic_grain=DynamicT, output_depth=Source_Bits)"

LoopStr = ".Trim(1, 1).Loop(TotalFrames)"
SLoopStr = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(TotalFrames)" : ""
TSoftStr = IsTSoft ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : ""
TweakStr = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? ".Tweak(bright=Bright, cont=Cont, sat=Sat)" : ""

TBStr = TweakStr + FastBlurStr
TBGStr = TweakStr + FastBlurStr + GrainStr

# -------------------------------------------------------------------------------
#            LetterBox Frosty Borders
# -------------------------------------------------------------------------------

FrostyCrop = IsFrosty && IsTSoft ? \
BClipHeight - max(BorderMin, round(F_BClipHeight / (!Faster ? 5.0 : 10.0) / F_HeightMod) * HeightMod) : nop()

FrostyTB = IsFrosty && IsTSoft ? \
Eval("StackVertical(BClip.crop(0, 0, 0, -FrostyCrop), BClip.crop(0, FrostyCrop, 0, 0))" + TSoftStr) : nop()
HeightFrostyTB = IsFrosty && IsTSoft ? height(FrostyTB) : nop()

FrostyCrop = IsFrosty ? (IsTSoft ? HeightFrostyTB - \
max(BorderMin, round(float(HeightFrostyTB) / (!Faster ? 16.0 : 8.0) / F_HeightMod) * HeightMod) : \
BClipHeight - max(BorderMin, round(F_BClipHeight / 80.0 / F_HeightMod) * HeightMod)) : nop()

FrostyT = IsFrosty ? (IsTSoft ? FrostyTB : BClip).crop(0, 0, 0, -FrostyCrop) : nop()
FrostyB = IsFrosty ? (IsTSoft ? FrostyTB : BClip).crop(0, FrostyCrop, 0, 0) : nop()

HeightFrostyT = IsFrosty ? height(FrostyT) : nop()
HeightFrostyB = IsFrosty ? height(FrostyB) : nop()

FrostyBlendT = IsFrosty ? ((Blend == 0) ? FrostyT : (Blend == 1) ? FrostyB : \
Overlay(FrostyT, FlipVertical(FrostyB), Opacity=Blend)) : nop()
FrostyBlendB = IsFrosty ? ((Blend == 0) ? FrostyB : (Blend == 1) ? FrostyT : \
Overlay(FrostyB, FlipVertical(FrostyT), Opacity=Blend)) : nop()

Blur = IsBlur ? Blur : IsFrosty ? F_BClipWidth / 10.0 : Blur
VBlur = IsVBlur ? VBlur : IsFrosty ? max(HeightFrostyT, HeightFrostyB) + (!IsFeather ? 0 : Feather) : VBlur

FastBlurStr = (Blur == 0 == VBlur) || FrostyGradient || (IsPlain && !IsFeather) ? "" : FastBlurStr

FrostyT = Frosty ? Eval("FrostyBlendT" + TBStr + GaussTStr + GrainStr + SLoopStr) : nop()
FrostyB = Frosty ? Eval("FrostyBlendB" + TBStr + GaussBStr + GrainStr + SLoopStr) : nop()

FFrostyT = Frosty && IsFeather ? Eval("FrostyBlendT" + TBStr + FGaussTStr + GrainStr + SLoopStr) : nop()
FFrostyB = Frosty && IsFeather ? Eval("FrostyBlendB" + TBStr + FGaussBStr + GrainStr + SLoopStr) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Clone Borders
# -------------------------------------------------------------------------------

MaxCloneC = IsClone || (IsFrosty && IsFeather) ? floor(F_BClipHeight / 2.0 / F_HeightMod) * HeightMod : nop()
CloneCropT = IsClone || (IsFrosty && IsFeather) ? max(MaxCloneC, BClipHeight - BT) : nop()
CloneCropB = IsClone || (IsFrosty && IsFeather) ? max(MaxCloneC, BClipHeight - BB) : nop()
CloneBorderT = IsClone || (IsFrosty && IsFeather) ? Resized.crop(0, 0, 0, -CloneCropT) : nop()
CloneBorderB = IsClone || (IsFrosty && IsFeather) ? Resized.crop(0, CloneCropB, 0, 0) : nop()
HeightCloneBorderT = IsClone || (IsFrosty && IsFeather) ? height(CloneBorderT) : nop()
HeightCloneBorderB = IsClone || (IsFrosty && IsFeather) ? height(CloneBorderB) : nop()

FlipCloneT = IsClone || (IsFrosty && IsFeather) ? \
FlipVertical(((HeightCloneBorderT == BT) ? CloneBorderT : Eval("CloneBorderT" + GaussTStr))) : nop()
FlipCloneB = IsClone || (IsFrosty && IsFeather) ? \
FlipVertical(((HeightCloneBorderB == BB) ? CloneBorderB : Eval("CloneBorderB" + GaussBStr))) : nop()

CloneTB = (Clone1 || Clone3) && IsTSoft ? Eval("StackVertical(CloneBorderT, CloneBorderB)" + TSoftStr) : nop()
HeightCloneTB = (Clone1 || Clone3) && IsTSoft ? height(CloneTB) : nop()

CloneT = \
Clone1 || Clone3 ? (IsTSoft ? CloneTB.crop(0, 0, 0, -HeightCloneTB+HeightCloneBorderT) : CloneBorderT) : nop()
CloneB = \
Clone1 || Clone3 ? (IsTSoft ? CloneTB.crop(0, HeightCloneTB-HeightCloneBorderB, 0, 0) : CloneBorderB) : nop()

CloneBlendT = Clone1 || Clone3 ? ((Blend == 0) ? CloneT : (Blend == 1) ? CloneB : \
Overlay(CloneT, FlipVertical(CloneB), Opacity=Blend)) : nop()
CloneBlendB = Clone1 || Clone3 ? ((Blend == 0) ? CloneB : (Blend == 1) ? CloneT : \
Overlay(CloneB, FlipVertical(CloneT), Opacity=Blend)) : nop()

FCloneT = \
Clone1 && IsFeather ? ((HeightCloneBorderT == BT) ? CloneBlendT : Eval("CloneBlendT" + GaussTStr)) : nop()
FCloneB = \
Clone1 && IsFeather ? ((HeightCloneBorderB == BB) ? CloneBlendB : Eval("CloneBlendB" + GaussBStr)) : nop()

CloneT = Clone1 && !IsFeather ? ((HeightCloneBorderT == BT) ? \
Eval("CloneBlendT" + TBGStr) : Eval("CloneBlendT" + TBStr + GaussTStr + GrainStr)) : nop()
CloneB = Clone1 && !IsFeather ? ((HeightCloneBorderB == BB) ? \
Eval("CloneBlendB" + TBGStr) : Eval("CloneBlendB" + TBStr + GaussBStr + GrainStr)) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Clone2 Borders
# -------------------------------------------------------------------------------

Clone2CropT = Clone2 ? max(MaxCloneC, BClipHeight - FT) : nop()
Clone2CropB = Clone2 ? max(MaxCloneC, BClipHeight - FB) : nop()
Clone2BT = Clone2 ? BClip.crop(0, 0, 0, -Clone2CropT) : nop()
Clone2BB = Clone2 ? BClip.crop(0, Clone2CropB, 0, 0) : nop()
HeightClone2BT = Clone2 ? height(Clone2BT) : nop()
HeightClone2BB = Clone2 ? height(Clone2BB) : nop()

FlipClone2T = Clone2 ? FlipVertical(((HeightClone2BT == FT) ? Clone2BT : Eval("Clone2BT" + FGaussTStr))) : nop()
FlipClone2B = Clone2 ? FlipVertical(((HeightClone2BB == FB) ? Clone2BB : Eval("Clone2BB" + FGaussBStr))) : nop()

Clone2TB = Clone2 && IsTSoft ? Eval("StackVertical(Clone2BT, Clone2BB)" + TSoftStr) : nop()
HeightClone2TB = Clone2 && IsTSoft ? height(Clone2TB) : nop()

Clone2T = Clone2 ? (IsTSoft ? Clone2TB.crop(0, 0, 0, -HeightClone2TB+HeightClone2BT) : Clone2BT) : nop()
Clone2B = Clone2 ? (IsTSoft ? Clone2TB.crop(0, HeightClone2TB-HeightClone2BB, 0, 0) : Clone2BB) : nop()

Clone2BlendT = Clone2 ? ((Blend == 0) ? Clone2T : (Blend == 1) ? Clone2B : \
Overlay(Clone2T, FlipVertical(Clone2B), Opacity=Blend)) : nop()
Clone2BlendB = Clone2 ? ((Blend == 0) ? Clone2B : (Blend == 1) ? Clone2T : \
Overlay(Clone2B, FlipVertical(Clone2T), Opacity=Blend)) : nop()

Clone2T = Clone2 ? ((HeightClone2BT == FT) ? Eval("Clone2BlendT" + TBGStr) : \
Eval("Clone2BlendT" + TBStr + FGaussTStr + GrainStr)) : nop()
Clone2B = Clone2 ? ((HeightClone2BB == FB) ? Eval("Clone2BlendB" + TBGStr) : \
Eval("Clone2BlendB" + TBStr + FGaussBStr + GrainStr)) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Clone3 Borders
# -------------------------------------------------------------------------------

RatioT = Clone3 ? (((HeightCloneBorderT - BT) >= 0) ? 1.618 : float(BT) / float(HeightCloneBorderT)) : nop()
RatioB = Clone3 ? (((HeightCloneBorderB - BB) >= 0) ? 1.618 : float(BB) / float(HeightCloneBorderB)) : nop()

Clone3T = Clone3 ? Eval("CloneBlendT" + Gauss3TStr) : nop()
Clone3B = Clone3 ? Eval("CloneBlendB" + Gauss3BStr) : nop()
WidthClone3T = Clone3 ? width(Clone3T) : nop()
HeightClone3T = Clone3 ? height(Clone3T) : nop()
WidthClone3B = Clone3 ? width(Clone3B) : nop()
HeightClone3B = Clone3 ? height(Clone3B) : nop()

Clone3T_CL = Clone3 ? max(0, floor((WidthClone3T - BClipWidth) / F_WidthMod / 2.0) * WidthMod) : nop()
Clone3T_CR = Clone3 ? max(0, WidthClone3T - BClipWidth - Clone3T_CL) : nop()
Clone3T_CT = Clone3 ? max(0, floor((HeightClone3T - BT) / F_HeightMod / 2.0) * HeightMod) : nop()
Clone3T_CB = Clone3 ? max(0, HeightClone3T - BT - Clone3T_CT) : nop()
Clone3B_CL = Clone3 ? max(0, floor((WidthClone3B - BClipWidth) / F_WidthMod / 2.0) * WidthMod) : nop()
Clone3B_CR = Clone3 ? max(0, WidthClone3B - BClipWidth - Clone3B_CL) : nop()
Clone3B_CT = Clone3 ? max(0, floor((HeightClone3B - BB) / F_HeightMod / 2.0) * HeightMod) : nop()
Clone3B_CB = Clone3 ? max(0, HeightClone3B - BB - Clone3B_CT) : nop()

Clone3T = Clone3 ? Clone3T.crop(Clone3T_CL, Clone3T_CT, -Clone3T_CR, -Clone3T_CB) : nop()
Clone3B = Clone3 ? Clone3B.crop(Clone3B_CL, Clone3B_CT, -Clone3B_CR, -Clone3B_CB) : nop()

FClone3T = Clone3 && IsFeather ? Clone3T : nop()
FClone3B = Clone3 && IsFeather ? Clone3B : nop()

Clone3T = Clone3 && !IsFeather ? Eval("Clone3T" + TBGStr) : nop()
Clone3B = Clone3 && !IsFeather ? Eval("Clone3B" + TBGStr) : nop()

# -------------------------------------------------------------------------------
#            LetterBox FrostyGradient Borders
# -------------------------------------------------------------------------------

GradientTB = \
FrostyGradient ? BlankClip(BClip, width=OutWidth, height=88).AddBorders(0, 8, 0, 0, color=BColor)\
.Tweak(bright=Bright, cont=Cont, sat=Sat).FastBlur(0, y_blur=50, iterations=3, dither=true) : nop()
GradientT = FrostyGradient ? Eval("FlipVertical(GradientTB)" + GaussTStr + GrainStr + LoopStr) : nop()
GradientB = FrostyGradient ? Eval("GradientTB" + GaussBStr + GrainStr + LoopStr) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Plain Borders
# -------------------------------------------------------------------------------

PlainT = IsPlain && (BT >= HeightMod) ? \
Eval("BlankClip(Resized, height=BT, color=BColor)" + TweakStr + GrainStr + LoopStr) : nop()
PlainB = IsPlain && (BB >= HeightMod) ? \
Eval("BlankClip(Resized, height=BB, color=BColor)" + TweakStr + GrainStr + LoopStr) : nop()

PlainT2 = IsPlain && IsFeather ? Eval("BlankClip(Resized, height=BT, color=BColor)" + TweakStr + LoopStr) : nop()
PlainB2 = IsPlain && IsFeather ? Eval("BlankClip(Resized, height=BB, color=BColor)" + TweakStr + LoopStr) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Frosty Clip
# -------------------------------------------------------------------------------

FrostyBT = !IsFeather ? (IsFrosty ? FrostyT : Clone1 ? CloneT : Clone3 ? Clone3T : \
FrostyGradient ? GradientT : IsPlain && (BT >= HeightMod) ? PlainT : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneT : IsPlain && (BT >= HeightMod) ? PlainT2 : nop()

FrostyBB = !IsFeather ? (IsFrosty ? FrostyB : Clone1 ? CloneB : Clone3 ? Clone3B : \
FrostyGradient ? GradientB : IsPlain && (BB >= HeightMod) ? PlainB : nop()) : \
IsFrosty || Clone1 || Clone2 || Clone3 ? FlipCloneB : IsPlain && (BB >= HeightMod) ? PlainB2 : nop()

FrostyClip = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BT >= HeightMod <= BB)) ? \
Eval("StackVertical(FrostyBT" + ResizedStr + "FrostyBB)") : \
IsPlain && (BT >= HeightMod) ? StackVertical(FrostyBT, Resized) : \
IsPlain && (BB >= HeightMod) ? StackVertical(Resized, FrostyBB) : Resized

# -------------------------------------------------------------------------------
#            LetterBox Feather Mask
# -------------------------------------------------------------------------------

FeatherMask = IsFeather ? BlankClip(Resized, height=Resizing_Height-(Feather*2))\
.AddBorders(0, BT+Feather, 0, BB+Feather, color=$FFFFFF).ColorYUV(Levels="TV->PC")\
.FastBlur(0, y_blur=Feather/2.25, iterations=3, dither=true) : nop()

FeatherMask = IsFeather ? Eval("FeatherMask" + LoopStr) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Feather Clip
# -------------------------------------------------------------------------------

FeatherClip = IsFeather ? \
(IsFrosty ? StackVertical(FFrostyT.AddBorders(0, 0, 0, Resizing_Height-FT+BT-FB+BB),  FFrostyB) : \
Clone1 ? Eval("StackVertical(StackVertical(FCloneT, Resized.crop(0, 0, 0, -Resizing_Height+FT-BT))" + \
TBGStr + FBordStr + "StackVertical(Resized.crop(0, Resizing_Height-FB+BB, 0, 0), FCloneB)" + TBGStr + ")")  : \
Clone2 ? StackVertical(Clone2T.AddBorders(0, 0, 0, Resizing_Height-FT+BT-FB+BB), Clone2B) : \
Clone3 ? Eval("StackVertical(StackVertical(FClone3T, Resized.crop(0, 0, 0, -Resizing_Height+FT-BT))" + \
TBGStr + FBordStr + "StackVertical(Resized.crop(0, Resizing_Height-FB+BB, 0, 0), FClone3B)" + TBGStr + ")") : \
Eval("StackVertical(BlankClip(Resized, height=FT, color=BColor)" + TweakStr + GrainStr + LoopStr + \
FBordStr + "BlankClip(Resized, height=FB, color=BColor)" + TweakStr + GrainStr + LoopStr + ")")) : nop()

# -------------------------------------------------------------------------------
#            LetterBox Output
# -------------------------------------------------------------------------------

FrostyOut = IsFeather ? Overlay(FrostyClip, FeatherClip, mask=FeatherMask) : FrostyClip

# ===============================================================================
#            No Borders
# ===============================================================================

""", "Frosty LetterBox Eval") : Eval("   FrostyOut = Resized   ")

# ===============================================================================
#            Info
# ===============================================================================

Info ? Eval("""

InfoCL = CCL + RCL
InfoCT = CCT + RCT
InfoCR = CCR + RCR
InfoCB = CCB + RCB

InAspect = (InDAR > 0) ? "Input DAR   " + FB_FS(InDAR, 6, True) + FB_FTF(InDAR) : \
IsInSAR && (InSAR > 0) ? "Input SAR   " + FB_FS(InSAR, 6, True) + FB_FTF(InSAR) : \
(PropsSAR > 0) || (!IsInDAR && !IsInSAR && (PropsNum == 1 == PropsDen)) ? \
"Frame Props SAR   " + \
FB_FS(PropsSAR, 6, True) + string(PropsNum, "  (%.0f:") + string(PropsDen, "%.0f)") : ""

Cropping = ((InAspect == "") ? "" : "\n\n") + "Total Cropping\n(" + FB_FS(InfoCL) + \
",  " + FB_FS(InfoCT) + ",  " + FB_FS(-InfoCR) + ",  " + FB_FS(-InfoCB) + ")"

PicW = !IsBorders || IsLetterBox ? OutWidth : Resizing_Width
PicH = !IsBorders || IsPillarBox ? OutHeight : Resizing_Height
F_PicW = !IsBorders || IsLetterBox ? F_OutWidth : F_Resizing_Width
F_PicH = !IsBorders || IsPillarBox ? F_OutHeight : F_Resizing_Height

PicDAR = F_PicW / F_PicH

PicWH = !IsBorders ? "" : \
string(PicW, "\n\nPicture   %.0f x ") + string(PicH, "%.0f") + \
"\nDAR   " + FB_FS(PicDAR, 6, True) + FB_FTF(PicDAR) + FB_PicMod(PicW, PicH)

InfoBL = IsBorders ? (!IsPillarBox || !IsBDivider ? BL : BL + BDivider) : 0
InfoBT = IsBorders ? (!IsLetterBox || !IsBDivider ? BT : BT + BDivider) : 0
InfoBR = IsBorders ? (!IsPillarBox || !IsBDivider ? BR : BR + BDivider) : 0
InfoBB = IsBorders ? (!IsLetterBox || !IsBDivider ? BB : BB + BDivider) : 0

BType = !IsBorders ? "" : "\n\nBorders   (" + \
(FrostyPlain ? "FrostyPlain" : FrostyGradient ? "FrostyGradient" : \
Clone3 ? "Clone=3" : (Clone == 2) && (Clone2 || Clone1) ? "Clone=2" : \
Clone1 ? "Clone=1": IsFrostyStatic ? "FrostyStatic" : \
Frosty ? "Frosty" : "Plain") + ")"

Borders = !IsBorders ? "\n\nNo Borders" : \
BType + string(InfoBL, "\n(%.0f") + string(InfoBT, ",  %.0f") + \
string(InfoBR, ",  %.0f") + string(InfoBB, ",  %.0f)")

OutDAR = F_OutWidth / F_OutHeight

OutWH = string(OutWidth, "\n\nOutput   %.0f x ") + string(OutHeight, "%.0f") + \
"\nDAR   " + FB_FS(OutDAR, 6, True) + FB_FTF(OutDAR) + FB_PicMod(OutWidth, OutHeight)

InfoResizer = "\n\nResizer    " + Resizer + ((RStr == "") ? "" : "\nRStr    " + RStr)

SSize = min(F_OutWidth * 0.04, F_OutHeight * \
((OutHeight < 300) ? 0.041 : (OutHeight < 400) ? 0.039 : \
(OutHeight < 500) ? 0.033 : (OutHeight < 600) ? 0.03 : \
(OutHeight < 1100) ? 0.026 : 0.023))

SY = (F_OutHeight * 0.5) - (SSize * 7.0) - \
((RStr == "") || !IsBorders ? 0 : SSize * 0.5) + ((InAspect == "") ? SSize : 0)

InfoText = InAspect + Cropping + PicWH + Borders + OutWH + InfoResizer

FrostyOut = FrostyOut.subtitle(InfoText, y=SY, size=SSize, text_color=$FFFFE0, align=2, lsp=10)

""", "Frosty Info Eval") : nop()

# ===============================================================================
#            FrostyBorders Output
# ===============================================================================

FrostyOut = (AvsBuildNum >= 3593) ? FrostyOut.propSet("_SARNum", 1).propSet("_SARDen", 1) : FrostyOut

return !HasAudio(SourceAudio) ? FrostyOut : AudioDub(FrostyOut, SourceAudio)  }

# ===============================================================================
# ===============================================================================
#            Helper Functions
# ===============================================================================
# ===============================================================================

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
#            Float To Fraction
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

function FB_FTF(float Decimal, int "Out")  {
Out = default(Out, 1)
Num = (Decimal == 0) ? "0" : string(ContinuedNumerator(Decimal, Limit=10000))
Den = (Decimal == 0) ? "1" : string(ContinuedDenominator(Decimal, Limit=10000))
return "  (" + Num + ((Out == 1) ? ":" : " / ") + Den + ")"  }

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
#            Format Strings
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

function FB_FS(float F, int "Limit", bool "Keep")  {
Limit = abs(default(Limit, 3))
Keep = default(Keep, false)
S = Eval("""string(F, "%.""" + string(Limit) + """f")""")
S = (Limit == 0) ? S : FB_RemoveTrailingZeros(S)
SLength = StrLen(S)
NewStr = (Limit == 0) || (FindStr(S, ".") < SLength) ? S : !Keep ? LeftStr(S, SLength - 1) : S + "0"
return (value(NewStr) == 0) && (FindStr(NewStr, "-") > 0) ? MidStr(NewStr, 2) : NewStr  }

# ---------------------------------------

function FB_RemoveTrailingZeros(string S)  {
ZeroPos = FindStr(S + "x", "0x")
return (ZeroPos == 0) ? S : FB_RemoveTrailingZeros(LeftStr(S, ZeroPos - 1))  }

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
#            Picture Mod
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

function FB_PicMod(Video_Width, Video_Height)  {

Width_Mod = \
(Video_Width % 16 == 0) ? 16 : (Video_Width % 8 == 0) ? 8 : \
(Video_Width % 4 == 0) ? 4 : (Video_Width % 2 == 0) ? 2 : 1
Height_Mod = \
(Video_Height % 16 == 0) ? 16 : (Video_Height % 8 == 0) ? 8 : \
(Video_Height % 4 == 0) ? 4 : (Video_Height % 2 == 0) ? 2 : 1

return string(Width_Mod, "   (Mod %.0fx") + string(Height_Mod, "%.0f)")  }

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
#            IsEqual
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

function FB_IsEqual(Val1, Val2)  {  return (abs(Val1 - Val2) < 0.00005)  }

# ===============================================================================
# ===============================================================================
#            Wrapper Functions
# ===============================================================================
# ===============================================================================

function Borders(clip Source, \
int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", \
val "CropDAR", float "TCRatio", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", \
bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", \
float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", bool "StaticT", \
int "TSoft", bool "Faster", string "Resizer", string "RStr", bool "Info")  {

Plain = default(Plain, true)

FrostyBorders(Source, OutWidth, OutHeight, \
CL, CT, CR, CB, CropDAR, TCRatio, InDAR, InSAR, Mod, \
Frosty, FrostyStatic, Clone, FrostyGradient, FrostyPlain, Plain, \
BColor, BDivider, BDColor, Feather, Bright, Cont, Sat, Blend, Blur, VBlur, Iterations, \
GPlugin, Texture, TextureC, StaticT, TSoft, Faster, Resizer, RStr, Info)  }

# -------------------------------------------------------------------------------

function iFrostyBorders(clip Source, \
int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", \
val "CropDAR", float "TCRatio", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", \
bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", \
float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", bool "StaticT", \
int "TSoft", bool "Faster", string "Resizer", string "RStr", bool "Info")  {

Info = default(Info, true)

FrostyBorders(Source, OutWidth, OutHeight, \
CL, CT, CR, CB, CropDAR, TCRatio, InDAR, InSAR, Mod, \
Frosty, FrostyStatic, Clone, FrostyGradient, FrostyPlain, Plain, \
BColor, BDivider, BDColor, Feather, Bright, Cont, Sat, Blend, Blur, VBlur, Iterations, \
GPlugin, Texture, TextureC, StaticT, TSoft, Faster, Resizer, RStr, Info)  }

# -------------------------------------------------------------------------------

function iBorders(clip Source, \
int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", \
val "CropDAR", float "TCRatio", val "InDAR", val "InSAR", int "Mod", \
bool "Frosty", int "FrostyStatic", int "Clone", \
bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
val "BColor", int "BDivider", val "BDColor", int "Feather", \
float "Bright", float "Cont", float "Sat", \
float "Blend", float "Blur", float "VBlur", int "Iterations", \
int "GPlugin", float "Texture", float "TextureC", bool "StaticT", \
int "TSoft", bool "Faster", string "Resizer", string "RStr", bool "Info")  {

Plain = default(Plain, true)
Info = default(Info, true)

FrostyBorders(Source, OutWidth, OutHeight, \
CL, CT, CR, CB, CropDAR, TCRatio, InDAR, InSAR, Mod, \
Frosty, FrostyStatic, Clone, FrostyGradient, FrostyPlain, Plain, \
BColor, BDivider, BDColor, Feather, Bright, Cont, Sat, Blend, Blur, VBlur, Iterations, \
GPlugin, Texture, TextureC, StaticT, TSoft, Faster, Resizer, RStr, Info)  }

# ===============================================================================
# ===============================================================================
#            Resizing Defaults
# ===============================================================================
# ===============================================================================

# When a resizing method is specified via the Resizer argument, both functions below are ignored.
# When the RStr argument is used, the RStr function below is ignored.

function FB_Default_Resizer() { "" }
function FB_Default_RStr() { "" }

# ===============================================================================
# ===============================================================================
