# ===============================================================================
# ===============================================================================
#            ImageBorders 2021-12-09
# ===============================================================================
# ===============================================================================

function ImageBorders(clip Video, int "OutWidth", int "OutHeight", \
clip "Image1", clip "Image2", string "Matrix1", string "Matrix2", \
val "InDAR", val "InSAR", int "Mod", \
bool "Flip", bool "Stretch", bool "BlankFrame", float "Offset", \
string "Resizer", string "IResizer", bool "Info")  {

# ===============================================================================
#            Defaults
# ===============================================================================

Video_Width = width(Video)
F_Video_Width = float(Video_Width)
Video_Height = height(Video)
F_Video_Height = float(Video_Height)

IB = " ImageBorders " + chr(10)
assert(HasVideo(Video) && (Video_Width > 48), IB + " No video found " + chr(10))

AvsVerStrLC = LCase(VersionString())
IsAvsPlus = (FindStr(AvsVerStrLC, "avisynth+") > 0) || (FindStr(AvsVerStrLC, "avisynth neo") > 0)
AvsStrNum = IsAvsPlus ? FindStr(AvsVerStrLC, "(r") + 2 : 0
AvsBuildNum = (AvsStrNum > 2) ? int(value(MidStr(AvsVerStrLC, AvsStrNum))) : 0
IsAvsHBD = (AvsBuildNum > 2294)

Color_Format = PixelType(Video)
ModTwoHeight = IsYV12(Video) || (IsAvsHBD && Is420(Video))
ModTwoWidth = ModTwoHeight || IsYV16(Video) || IsYUY2(Video) || (IsAvsHBD && Is422(Video))
ModFourWidth = IsYV411(Video)

Crop_WMod = ModFourWidth ? 4 : ModTwoWidth ? 2 : 1
Crop_HMod = ModTwoHeight ? 2 : 1

Video_Num = FrameRateNumerator(Video)
Video_Den = FrameRateDenominator(Video)
End_Frame = FrameCount(Video) - 1
IsImage1 = defined(Image1)
IsImage2 = defined(Image2)

Image1 = default(Image1, BlankClip(Video)).KillAudio().Trim(0, end=0)
Image2 = default(Image2, Image1).KillAudio().Trim(0, end=0)
Matrix1 = default(Matrix1, "rec601")
Matrix2 = default(Matrix2, Matrix1)
InDAR = default(InDAR, 0.0)
InSAR = default(InSAR, 0.0)
Offset = default(Offset, 1.0)
Flip = default(Flip, (Offset == 0) ? false : !IsImage2 ? true : false)
Stretch = default(Stretch, true)
BlankFrame = default(BlankFrame, false)
Resizer = default(Resizer, "Spline36")
IResizer = default(IResizer, Resizer)
Info = default(Info, false)

IsInDAR = IsFloat(InDAR) && (InDAR > 0)
IsInSAR = IsFloat(InSAR) && (InSAR > 0)

WMod = default(Mod, (Offset == 1) ? (ModTwoWidth ? 4 : ModFourWidth ? 8 : 2) : \
ModTwoWidth ? 2 : ModFourWidth ? 4 : 1)
HMod = default(Mod, (Offset == 1) ? (ModTwoHeight ? 4 : 2) : ModTwoHeight ? 2 : 1)
F_WMod = float(WMod)
F_HMod = float(HMod)

IsResizeAppended = (RightStr(Resizer, 6) == "Resize")
Resizer = !IsResizeAppended ? Resizer : LeftStr(Resizer, StrLen(Resizer) - 6)
IsAvisynthResizer = (Resizer == "Bilinear") || (Resizer == "Bicubic") || (Resizer == "Blackman") || \
(Resizer == "Gauss") || (Resizer == "Lanczos") || (Resizer == "Lanczos4") || (Resizer == "Point") || \
(Resizer == "Spline16") || (Resizer == "Spline36") || (Resizer == "Spline64") || (Resizer == "Sinc")
Resizer = IsAvisynthResizer || (!IsAvisynthResizer && IsResizeAppended) ? Resizer + "Resize" : Resizer

IsIResizeAppended = (RightStr(IResizer, 6) == "Resize")
IResizer = !IsIResizeAppended ? IResizer : LeftStr(IResizer, StrLen(IResizer) - 6)
IsAvisynthResizer = (IResizer == "Bilinear") || (IResizer == "Bicubic") || (IResizer == "Blackman") || \
(IResizer == "Gauss") || (IResizer == "Lanczos") || (IResizer == "Lanczos4") || (IResizer == "Point") || \
(IResizer == "Spline16") || (IResizer == "Spline36") || (IResizer == "Spline64") || (IResizer == "Sinc")
IResizer = IsAvisynthResizer || (!IsAvisynthResizer && IsIResizeAppended) ? IResizer + "Resize" : IResizer

# ===============================================================================
#            Aspect & Dimensions
# ===============================================================================

Video_SAR = IsInSAR ? InSAR : IsInDAR ? (F_Video_Height * InDAR / F_Video_Width) : 1.0
Video_DAR = (Video_SAR == 1.0) ? F_Video_Width / F_Video_Height : \
IsInDAR ? InDAR : (F_Video_Width * Video_SAR / F_Video_Height)

Mod_Video_Width = (Video_SAR == 1.0) ? floor(F_Video_Width / F_WMod) * WMod : \
IsInDAR ? floor(F_Video_Height * InDAR / F_WMod) * WMod : \
floor(F_Video_Width * Video_SAR / F_WMod) * WMod

Mod_InStorageAR = float(Mod_Video_Width) / F_Video_Height

OutWidth = default(OutWidth, 0)
OutWidth = (OutWidth == 0) ? Mod_Video_Width : OutWidth
OutHeight = default(OutHeight, 0)
OutHeight = (OutHeight == 0) ? Video_Height : OutHeight
F_OutWidth = float(OutWidth)
F_OutHeight = float(OutHeight)

OutStorageAR = (F_OutWidth / F_OutHeight)

IsBorders = (abs(OutStorageAR - Video_DAR) >= 0.000033)
IsPillarBox = IsBorders && (OutStorageAR >= Mod_InStorageAR)
IsLetterBox = IsBorders && (OutStorageAR < Mod_InStorageAR)

# ===============================================================================
#            Insist
# ===============================================================================

assert((0 <= Offset <= 2.0), IB + " Offset must be between 0 and 2.0 " + chr(10))
assert(((IsFloat(InDAR) && (InDAR == 0)) || (!IsInt(InDAR) && IsInDAR)) && \
((IsFloat(InSAR) && (InSAR == 0)) || (!IsInt(InSAR) && IsInSAR)), \
IB + " InDAR & InSAR must be zero or a positive floating point number " + chr(10) + \
" 16.0/9.0 or 1.7778 etc " + chr(10))
assert((InDAR == 0) || (InSAR == 0), IB + " InDAR & InSAR can't be specified at the same time " + chr(10))
assert((WMod == 1) || (WMod == 2) || (WMod == 4) || (WMod == 8) || (WMod == 16), \
IB + " Mod must be 1, 2, 4, 8 or 16 " + chr(10))
assert(!IsBorders || IsLetterBox || !ModTwoWidth || (WMod % 2 == 0), \
IB + " " + Color_Format + " requires a mod2 width " + chr(10))
assert(!IsBorders || IsLetterBox || !ModFourWidth || (WMod % 4 == 0), \
IB + " " + Color_Format + " requires a mod4 width " + chr(10))
assert(!IsBorders || IsPillarBox || !ModTwoHeight || (HMod % 2 == 0), \
IB + " " + Color_Format + " requires a mod2 height " + chr(10))

# ===============================================================================
#            Mod Check
# ===============================================================================

IsImage1 ? Eval("""

Image1_Width = width(Image1)
Image1_Height = height(Image1)

Crop1L = (Crop_WMod == 2) && ((Image1_Width % 2) == 1) ? 1 : \
(Crop_WMod == 4) ? (((Image1_Width % 4) == 3) || ((Image1_Width % 4) == 1) ? 1 : \
((Image1_Width % 4) == 2) ? 2 : 0) : 0
Crop1R = (Crop_WMod == 4) && ((Image1_Width % 4) == 3) ? -2 : 0
Crop1B = (Crop_HMod == 2) && ((Image1_Height % 2) == 1) ? -1 : 0

Image1 = (0 == Crop1L == Crop1R == Crop1B) ? Image1.IB_MCF(Video, matrix=Matrix1, IsAvsHBD=IsAvsHBD) : \
Image1.Crop(Crop1L, 0, Crop1R, Crop1B).IB_MCF(Video, matrix=Matrix1, IsAvsHBD=IsAvsHBD)

""", "Image1 Mod Eval") : nop()

IsImage2 ? Eval("""

Image2_Width = width(Image2)
Image2_Height = height(Image2)

Crop2L = (Crop_WMod == 2) && ((Image2_Width % 2) == 1) ? 1 : \
(Crop_WMod == 4) ? (((Image2_Width % 4) == 3) || ((Image2_Width % 4) == 1) ? 1 : \
((Image2_Width % 4) == 2) ? 2 : 0) : 0
Crop2R = (Crop_WMod == 4) && ((Image2_Width % 4) == 3) ? -2 : 0
Crop2B = (Crop_HMod == 2) && ((Image2_Height % 2) == 1) ? -1 : 0

Image2 = (0 == Crop1L == Crop1R == Crop1B) ? Image2.IB_MCF(Video, matrix=Matrix2, IsAvsHBD=IsAvsHBD) : \
Image2.Crop(Crop1L, 0, Crop1R, Crop1B).IB_MCF(Video, matrix=Matrix2, IsAvsHBD=IsAvsHBD)

""", "Image2 Mod Eval") : nop()

Image2 = IsImage2 ? Image2 : Image1
Image1_Width = width(Image1)
Image1_Height = height(Image1)
Image2_Width = width(Image2)
Image2_Height = height(Image2)

# ===============================================================================
#            Resizing
# ===============================================================================

!IsBorders ? Eval("""

Resized_Picture = (OutWidth == Video_Width) && (OutHeight == Video_Height) ? Video : \
Eval("Video." + Resizer + "(OutWidth, OutHeight)")

""", "Resizing 1 Eval") : IsPillarBox ? Eval("""

# -------------------------------------------------------------------------------

F_New_Width = (Video_SAR == 1.0) ? (F_OutHeight * F_Video_Width / F_Video_Height) : \
IsInDAR ? (F_OutHeight * InDAR) : (F_OutHeight * F_Video_Width * Video_SAR / F_Video_Height)

Resizing_Width = floor(F_New_Width / F_WMod) * WMod
F_Resizing_Width = float(Resizing_Width)

F_Width_Cropping = \
max(0, (Video_Width - (F_Video_Height * F_Resizing_Width / F_OutHeight / Video_SAR)) / 2.0)
Resizer_Crop_LR = \
max(0, F_Width_Cropping - (floor(F_Width_Cropping / F_WMod) * WMod))
Crop_LR = max(0, round(F_Width_Cropping - Resizer_Crop_LR))

Resized_Picture = Eval("Video.Crop(Crop_LR, 0, -Crop_LR, 0)." + Resizer + "(Resizing_Width, OutHeight, \
src_left=Resizer_Crop_LR, src_top=0, src_width=-Resizer_Crop_LR, src_height=0)")

Additional_Width = OutWidth - Resizing_Width
Left_Border_Width = (Offset == 0) ? 0 : (Offset == 2.0) ? Additional_Width : \
min(Additional_Width, floor(float(Additional_Width) * Offset / 2.0 / float(Crop_WMod)) * Crop_WMod)
Right_Border_Width = Additional_Width - Left_Border_Width

IsLeftMinimum = (Left_Border_Width >= 16 <= Image1_Width) || \
((Left_Border_Width >= 10 <= Image1_Width) && \
((IResizer == "BlackmanResize") || (IResizer == "GaussResize") || \
(IResizer == "LanczosResize") || (IResizer == "Lanczos4Resize") || (IResizer == "Spline64Resize"))) || \
((Left_Border_Width >= 8 <= Image1_Width) && (IResizer == "Spline36Resize")) || \
((Left_Border_Width >= 6 <= Image1_Width) && \
((IResizer == "BicubicResize") || (IResizer == "Spline16Resize"))) || \
((Left_Border_Width >= 4 <= Image1_Width) && (IResizer == "BilinearResize")) || \
((Left_Border_Width >= 2 <= Image1_Width) && (IResizer == "PointResize"))

IsRightMinimum = (Right_Border_Width >= 16 <= Image2_Width) || \
((Right_Border_Width >= 10 <= Image2_Width) && \
((IResizer == "BlackmanResize") || (IResizer == "GaussResize") || \
(IResizer == "LanczosResize") || (IResizer == "Lanczos4Resize") || (IResizer == "Spline64Resize"))) || \
((Right_Border_Width >= 8 <= Image2_Width) && (IResizer == "Spline36Resize")) || \
((Right_Border_Width >= 6 <= Image2_Width) && \
((IResizer == "BicubicResize") || (IResizer == "Spline16Resize"))) || \
((Right_Border_Width >= 4 <= Image2_Width) && (IResizer == "BilinearResize")) || \
((Right_Border_Width >= 2 <= Image2_Width) && (IResizer == "PointResize"))

""", "PillarBox Resizing Eval") : Eval("""

# -------------------------------------------------------------------------------

F_New_Height = (Video_SAR == 1.0) ? (F_OutWidth * F_Video_Height / F_Video_Width) : \
IsInDAR ? (F_OutWidth / InDAR) : (F_OutWidth * F_Video_Height / F_Video_Width / Video_SAR)

Resizing_Height = floor(F_New_Height / F_HMod) * HMod
F_Resizing_Height = float(Resizing_Height)

F_Height_Cropping = \
max(0, (Video_Height - (F_Video_Width * F_Resizing_Height * Video_SAR / F_OutWidth)) / 2.0)
Resizer_Crop_TB = \
max(0, F_Height_Cropping - (floor(F_Height_Cropping / F_HMod) * HMod))
Crop_TB = max(0, round(F_Height_Cropping - Resizer_Crop_TB))

Resized_Picture = Eval("Video.Crop(0, Crop_TB, 0, -Crop_TB)." + Resizer + "(OutWidth, Resizing_Height, \
src_left=0, src_top=Resizer_Crop_TB, src_width=0, src_height=-Resizer_Crop_TB)")

Additional_Height = OutHeight - Resizing_Height
Top_Border_Height = (Offset == 0) ? 0 : (Offset == 2.0) ? Additional_Height : \
min(Additional_Height, floor(float(Additional_Height) * Offset / 2.0 / float(Crop_HMod)) * Crop_HMod)
Bottom_Border_Height = Additional_Height - Top_Border_Height

IsTopMinimum = (Top_Border_Height >= 16 <= Image1_Height) || \
((Top_Border_Height >= 10 <= Image1_Height) && \
((IResizer == "BlackmanResize") || (IResizer == "GaussResize") || \
(IResizer == "LanczosResize") || (IResizer == "Lanczos4Resize") || (IResizer == "Spline64Resize"))) || \
((Top_Border_Height >= 8 <= Image1_Height) && (IResizer == "Spline36Resize")) || \
((Top_Border_Height >= 6 <= Image1_Height) && \
((IResizer == "BicubicResize") || (IResizer == "Spline16Resize"))) || \
((Top_Border_Height >= 4 <= Image1_Height) && (IResizer == "BilinearResize")) || \
((Top_Border_Height >= 2 <= Image1_Height) && (IResizer == "PointResize"))

IsBottomMinimum = (Bottom_Border_Height >= 16 <= Image2_Height) || \
((Bottom_Border_Height >= 10 <= Image2_Height) && \
((IResizer == "BlackmanResize") || (IResizer == "GaussResize") || \
(IResizer == "LanczosResize") || (IResizer == "Lanczos4Resize") || (IResizer == "Spline64Resize"))) || \
((Bottom_Border_Height >= 8 <= Image2_Height) && (IResizer == "Spline36Resize")) || \
((Bottom_Border_Height >= 6 <= Image2_Height) && \
((IResizer == "BicubicResize") || (IResizer == "Spline16Resize"))) || \
((Bottom_Border_Height >= 4 <= Image2_Height) && (IResizer == "BilinearResize")) || \
((Bottom_Border_Height >= 2 <= Image2_Height) && (IResizer == "PointResize"))

""", "LetterBox Resizing Eval")

# ===============================================================================
#            Add Borders
# ===============================================================================

!IsBorders ? Eval("  Output = Resized_Picture   ") : IsPillarBox ? Eval("""

# -------------------------------------------------------------------------------

NoResizeLeft = \
IsImage1 && (Image1_Width == Left_Border_Width) && (Image1_Height == OutHeight)
NoResizeRight = \
(IsImage1 || IsImage2) && (Image2_Width == Right_Border_Width) && (Image2_Height == OutHeight)

Left_Border = \
NoResizeLeft ? Image1 : !IsLeftMinimum || !IsImage1 ? nop() : \
!Stretch ? Image1.CropResize(Left_Border_Width, OutHeight, Resizer=IResizer) : \
Eval("Image1." + IResizer + "(Left_Border_Width, OutHeight)")
Left_Border = \
(!IsLeftMinimum && !NoResizeLeft) || !IsImage1 ? nop() : \
Left_Border.Loop().AssumeFPS(Video_Num, Video_Den).Trim(0, End_Frame)

Right_Border = \
NoResizeRight ? Image2 : !IsRightMinimum || (!IsImage1 && !IsImage2) ? nop() : \
!Stretch ? Image2.CropResize(Right_Border_Width, OutHeight, Resizer=IResizer) : \
Eval("Image2." + IResizer + "(Right_Border_Width, OutHeight)")
Right_Border = \
(!IsRightMinimum && !NoResizeRight) || (!IsImage1 && !IsImage2) ? nop() : \
!Flip ? Right_Border : Right_Border.FlipHorizontal()
Right_Border = \
(!IsRightMinimum && !NoResizeRight) || (!IsImage1 && !IsImage2) ? nop() : \
Right_Border.Loop().AssumeFPS(Video_Num, Video_Den).Trim(0, End_Frame)

Output = \
(!IsLeftMinimum && !NoResizeLeft && !IsRightMinimum && !NoResizeRight) || (!IsImage1 && !IsImage2) ? \
Resized_Picture.AddBorders(Left_Border_Width, 0, Right_Border_Width, 0) : \
IsImage1 ? \
((IsLeftMinimum || NoResizeLeft) && (IsRightMinimum || NoResizeRight) ? \
StackHorizontal(Left_Border, Resized_Picture, Right_Border) : \
!IsLeftMinimum && !NoResizeLeft ? \
StackHorizontal(Resized_Picture, Right_Border).AddBorders(Left_Border_Width, 0, 0, 0) : \
StackHorizontal(Left_Border, Resized_Picture).AddBorders(0, 0, Right_Border_Width, 0)) : \
IsImage2 && (IsRightMinimum || NoResizeRight) ? \
StackHorizontal(Resized_Picture, Right_Border).AddBorders(Left_Border_Width, 0, 0, 0) : \
Resized_Picture.AddBorders(Left_Border_Width, 0, Right_Border_Width, 0)
Output = \
!HasAudio(Video) ? Output : AudioDub(Output, Video)

""", "PillarBox Borders Eval") : Eval("""

# -------------------------------------------------------------------------------

NoResizeTop = \
IsImage1 && (Image1_Height == Top_Border_Height) && (Image1_Width == OutWidth)
NoResizeBottom = \
(IsImage1 || IsImage2) && (Image2_Height == Bottom_Border_Height) && (Image2_Width == OutWidth)

TopBorder = \
NoResizeTop ? Image1 : !IsTopMinimum || !IsImage1 ? nop() : \
!Stretch ? Image1.CropResize(OutWidth, Top_Border_Height, Resizer=IResizer) : \
Eval("Image1." + IResizer + "(OutWidth, Top_Border_Height)")
TopBorder = \
(!IsTopMinimum && !NoResizeTop) || !IsImage1 ? nop() : \
TopBorder.Loop().AssumeFPS(Video_Num, Video_Den).Trim(0, End_Frame)

BottomBorder = \
NoResizeBottom ? Image2 : !IsBottomMinimum || (!IsImage1 && !IsImage2) ? nop() : \
!Stretch ? Image2.CropResize(OutWidth, Bottom_Border_Height, Resizer=IResizer) : \
Eval("Image2." + IResizer + "(OutWidth, Bottom_Border_Height)")
BottomBorder = \
(!IsBottomMinimum && !NoResizeBottom) || (!IsImage1 && !IsImage2) ? nop() : \
!Flip ? BottomBorder : BottomBorder.FlipVertical()
BottomBorder = \
(!IsBottomMinimum && !NoResizeBottom) || (!IsImage1 && !IsImage2) ? nop() : \
BottomBorder.Loop().AssumeFPS(Video_Num, Video_Den).Trim(0, End_Frame)

Output = \
(!IsTopMinimum && !NoResizeTop && !IsBottomMinimum && !NoResizeBottom) || (!IsImage1 && !IsImage2) ? \
Resized_Picture.AddBorders(0, Top_Border_Height, 0, Bottom_Border_Height) : \
IsImage1 ? \
((IsTopMinimum || NoResizeTop) && (IsBottomMinimum || NoResizeBottom) ? \
StackVertical(TopBorder, Resized_Picture, BottomBorder) : \
!IsTopMinimum && !NoResizeTop ? \
StackVertical(Resized_Picture, BottomBorder).AddBorders(0, Top_Border_Height, 0, 0) : \
StackVertical(TopBorder, Resized_Picture).AddBorders(0, 0, 0, Bottom_Border_Height)) : \
IsImage2 && (IsBottomMinimum || NoResizeBottom) ? \
StackVertical(Resized_Picture, BottomBorder).AddBorders(0, Top_Border_Height, 0, 0) : \
Resized_Picture.AddBorders(0, Top_Border_Height, 0, Bottom_Border_Height)
Output = \
!HasAudio(Video) ? Output : AudioDub(Output, Video)

""", "LetterBox Borders Eval")

# ===============================================================================
#            Info
# ===============================================================================

Info ? Eval("""

Info_Text = \
(!IsBorders ? string(OutWidth, "Output Dimensions\n%.0f x ") + string(OutHeight, "%.0f\n\nNo Borders") : \
IsPillarBox ? string(Resizing_Width, "Picture Dimensions\n%.0f x ") + string(OutHeight, "%.0f") + \
string(Left_Border_Width, "\n\nLeft Border   %.0f") + string(Right_Border_Width, "\nRight Border   %.0f") + \
string(OutWidth, "\n\nOutput Dimensions\n%.0f x ") + string(OutHeight, "%.0f") : \
string(OutWidth, "Picture Dimensions\n%.0f x ") + string(Resizing_Height, "%.0f") + \
string(Top_Border_Height, "\n\nTop Border   %.0f") + string(Bottom_Border_Height, "\nBottom Border   %.0f") + \
string(OutWidth, "\n\nOutput Dimensions\n%.0f x ") + string(OutHeight, "%.0f")) + \
"\n\nResizer   " + Resizer + "\nIResizer   " + IResizer

Sub_Size = min(OutWidth * 0.03, OutHeight * 0.032)
Sub_Y = (OutHeight * 0.5) - (Sub_Size * 5.15)

Output = Output.subtitle(Info_Text, y=Sub_Y, size=Sub_Size, text_color=$F0FFFF, align=5, lsp=20)

""", "Info Eval") : nop()

# ===============================================================================

return !BlankFrame ? Output : Output ++ BlankClip(Output).Trim(0, end=0)  }

# ===============================================================================
# ===============================================================================
#            ImageBorders Wrapper Function
# ===============================================================================
# ===============================================================================

function iImageBorders(clip Video, int "OutWidth", int "OutHeight", \
clip "Image1", clip "Image2", string "Matrix1", string "Matrix2", \
val "InDAR", val "InSAR", int "Mod", \
bool "Flip", bool "Stretch", bool "BlankFrame", float "Offset", \
string "Resizer", string "IResizer", bool "Info")  {

Info = default(Info, true)

ImageBorders(Video, OutWidth, OutHeight, Image1, Image2, Matrix1, Matrix2, \
InDAR, InSAR, Mod, Flip, Stretch, BlankFrame, Offset, Resizer, IResizer, Info)  }

# ===============================================================================
# ===============================================================================
#            Match Color Format Function
# ===============================================================================
# ===============================================================================

# Match Color Format converts the source clip to the same color format as the template clip
# Courtesy of Raffriff42 http://avisynth.nl/index.php/User:Raffriff42/Utils-r41_Quick_Reference
# This version is modified to work with Avisynth 2.6 as well as Avisynth+

# -------------------------------------------------------------------------------

function IB_MCF(clip Source, clip Template, string "Matrix", bool "KeepBits", bool "Dither", bool "IsAvsHBD")  {

IsRGBSource = IsRGB(Source)
IsRGBTemplate = IsRGB(Template)
Error_Text = " Failed to convert Image1 or Image2 to the main video color format "

assert(defined(Matrix) || ((!IsRGBTemplate && !IsRGBSource) || (IsRGBTemplate && IsRGBSource)), \
" ImageBorders - Match Color Format " + chr(10) + " Matrix must be specified when " + chr(10) + \
" Source is RGB & Template is YUV " + chr(10) + " or " + chr(10) + " Source is YUV & Template is RGB " \
+ chr(10) + " See the description of Avisynth's Convert function for Matrix options " + chr(10))

# -------------------------------------------------------------------------------

IsAvsHBD ? Eval("""

KeepBits = default(KeepBits, false)
BitsIn = BitsPerComponent(Source)
BitsOut = (KeepBits) ? BitsPerComponent(Source) : BitsPerComponent(Template)
Dither = default(Dither, true)
DitherType = Dither && (BitsIn > 8) && (BitsIn < 32) && (BitsOut < BitsIn) ? 1 : -1

A = HasAlpha(Source) ? Source.ExtractA().ConvertBits(BitsOut) : nop()
Source = \
IsPlanar(Source) ? Source : IsRGBSource ? Source.ConvertToPlanarRGB() : Source.ConvertToYUV444()

# Upconvert (if applicable) before YUV<>RGB 
Source = (BitsIn < BitsOut) ? Source.ConvertBits(BitsOut) : Source

Output = \
IsRGBTemplate ? (IsRGBSource ? Source : Source.ConvertToPlanarRGB(matrix=Matrix)) : \
Is444(Template) ? (IsRGBSource ? Source.ConvertToYUV444(matrix=Matrix) : Source.ConvertToYUV444()) : \
Is422(Template) ? (IsRGBSource ? Source.ConvertToYUV422(matrix=Matrix) : Source.ConvertToYUV422()) : \
Is420(Template) ? (IsRGBSource ? Source.ConvertToYUV420(matrix=Matrix) : Source.ConvertToYUV420()) : \
IsYUY2(Template) ? (IsRGBSource ? \
Source.ConvertToYUV422(matrix=Matrix).ConvertBits(8, dither=DitherType).ConvertToYUY2() : \
Source.ConvertToYUV422().ConvertBits(8, dither=DitherType).ConvertToYUY2()) : \
IsYV411(Template) ? (IsRGBSource ? \
Source.ConvertToYUV411(matrix=Matrix).ConvertBits(8, dither=DitherType).ConvertToYV411() : \
Source.ConvertToYUV411().ConvertBits(8, dither=DitherType).ConvertToYV411()) : \
IsY(Template) ? (IsRGBSource ? \
Source.ConvertToYUV420(matrix=Matrix).ConvertToY() : Source.ConvertToYUV420().ConvertToY()) : \
assert(false, " ImageBorders - Match Color Format " + chr(10) + \
" Unrecognized template format " + chr(10) + Error_Text + chr(10))

BitsOutput = BitsPerComponent(Output)
DitherType = Dither && (BitsOutput > 8) && (BitsOutput < 32) && (BitsOut < BitsOutput) ? 0 : -1
Output = Output.ConvertBits(BitsOut, dither=DitherType)

assert((BitsPerComponent(Template) == BitsPerComponent(Output)) && (IsY(Template) == IsY(Output)) && \
(IsRGBTemplate == IsRGB(Output)) && (Is444(Template) == Is444(Output)) && \
(Is422(Template) == Is422(Output)) && (Is420(Template) == Is420(Output)) && \
(IsYUY2(Template) == IsYUY2(Output)) && (IsYV411(Template) == IsYV411(Output)), \
" ImageBorders - Match Color Format " + chr(10) + " Can't keep original bitdepth " + chr(10) + \
" Template=" + PixelType(Template) + "  Output=" + PixelType(Output) + " " + chr(10) + Error_Text + chr(10))

Output = \
IsRGB32(Template) ? (IsRGB32(Output) ? Output : Output.ConvertToRGB32()) : \
IsRGB24(Template) ? (IsRGB24(Output) ? Output : Output.ConvertToRGB24()) : \
IsRGB64(Template) ? (IsRGB64(Output) ? Output : Output.ConvertToRGB64()) : \
IsRGB48(Template) ? (IsRGB48(Output) ? Output : Output.ConvertToRGB48()) : \
IsYV24(Template) ? (IsYV24(Output) ? Output : Output.ConvertToYV24()) : \
IsYUY2(Template) ? (IsYUY2(Output) ? Output : Output.ConvertToYUY2()) : \
IsYV16(Template) ? (IsYV16(Output) ? Output : Output.ConvertToYV16()) : \
IsYV12(Template) ? (IsYV12(Output) ? Output : Output.ConvertToYV12()) : \
IsYV411(Template) ? (IsYV411(Output) ? Output : Output.ConvertToYV411()) : \
IsY8(Template) ? (IsY8(Output) ? Output : Output.ConvertToY8()) : \
(IsRGBTemplate || Is444(Template) || Is422(Template) || Is420(Template) || IsY(Template)) ? Output : \
assert(false, " ImageBorders - Match Color Format " + chr(10) + \
" Unrecognized source format " + chr(10) + Error_Text + chr(10))

Output = HasAlpha(Template) && HasAlpha(Source) ? Output.AddAlphaPlane(A) : Output
Output = HasAlpha(Template) ? (HasAlpha(Output) ? Output : Output.AddAlphaPlane()) : \
!HasAlpha(Output) ? Output : Output.RemoveAlphaPlane()

""", "Match Color Format Avisynth+ Eval") : Eval("""

# -------------------------------------------------------------------------------

Output = \
!IsRGBTemplate && !IsRGBSource ? \
(IsYV24(Template) ? (IsYV24(Source) ? Source : Source.ConvertToYV24()) : \
IsYV16(Template) ? (IsYV16(Source) ? Source : Source.ConvertToYV16()) : \
IsYUY2(Template) ? (IsYUY2(Source) ? Source : Source.ConvertToYUY2()) : \
IsYV12(Template) ? (IsYV12(Source) ? Source : Source.ConvertToYV12()) : \
IsYV411(Template) ? (IsYV411(Source) ? Source : Source.ConvertToYV411()) : \
IsY8(Template) ? (IsY8(Source) ? Source : Source.ConvertToY8()) : nop()) : \
IsRGBTemplate && IsRGBSource ? \
(IsRGB32(Template) ? (IsRGB32(Source) ? Source : Source.ConvertToRGB32()) : \
IsRGB24(Template) ? (IsRGB24(Source) ? Source : Source.ConvertToRGB24()) : nop()) : \
!IsRGBTemplate && IsRGBSource ? \
(IsYV24(Template) ? Source.ConvertToYV24(matrix=Matrix) : \
IsYV16(Template) ? Source.ConvertToYV16(matrix=Matrix) : \
IsYUY2(Template) ? Source.ConvertToYUY2(matrix=Matrix) : \
IsYV12(Template) ? Source.ConvertToYV12(matrix=Matrix) : \
IsYV411(Template) ? Source.ConvertToYV411(matrix=Matrix) : \
IsY8(Template) ? Source.ConvertToY8(matrix=Matrix) : nop()) : \
IsRGBTemplate && !IsRGBSource ? \
(IsRGB32(Template) ? Source.ConvertToRGB32(matrix=Matrix) : \
IsRGB24(Template) ? Source.ConvertToRGB24(matrix=Matrix) : nop()) : nop()

""", "Match Color Format Avisynth Classic Eval")

# -------------------------------------------------------------------------------

assert((PixelType(Template) == PixelType(Output)), " ImageBorders - Match Color Format " + chr(10) + \
" Template=" + PixelType(Template) + "  Output=" + PixelType(Output) + " " + chr(10) + Error_Text + chr(10))

return Output  }

# ===============================================================================
# ===============================================================================