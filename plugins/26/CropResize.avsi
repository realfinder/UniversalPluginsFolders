# ===============================================================================
# ===============================================================================
#            CropResize 2025-12-20
# ===============================================================================
# ===============================================================================

function CropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    AvsStr = LCase(VersionString())
    IsAvsPlus = (FindStr(AvsStr, "avisynth+") > 0)
    NumA = IsAvsPlus ? FindStr(AvsStr, "(r") + 2 : 0
    NumB = IsAvsPlus ? FindStr(AvsStr, ",") : 0
    NumC = (NumB > NumA) ? NumB - NumA : undefined()
    AvsBuildNum = (NumA > 2) ? int(value(MidStr(AvsStr, NumA, NumC))) : 0

    A1 = " CropResize " + chr(10) + " "
    A2 = " " + chr(10)
    Assert((AvsBuildNum >= 3593), A1 + "Avisynth+ 3.7.1 or greater is required" + A2)
    Assert(HasVideo(Source) && (width(Source) > 48) && (height(Source) > 48), \
      A1 + "No video found or the source width or height is too small" + A2)

    Source_Audio = !HasAudio(Source) ? Source : Source.KillVideo()
    Source = Source.KillAudio()

# ===============================================================================
#            Globals
# ===============================================================================

    Try{ IsPriorG1 = G1_PriorG1 }Catch(err){ IsPriorG1 = false }
    Try{ IsPriorG2 = G2_PriorG2 }Catch(err){ IsPriorG2 = false }
    Try{ IsPriorCropResize = gPriorCropResize }Catch(err){ IsPriorCropResize = false }
    Try{ IsGCPreview = (G_CPreview > 0) }Catch(err){ IsGCPreview = false }
    Try{ IsGResizer = defined(G_Resizer) }Catch(err){ IsGResizer = false }
    Try{ IsGInfo = G_Info }Catch(err){ IsGInfo = false }
    Try{ IsMX = CR_MeGUI_Support() && !IsPriorCropResize && defined(MeGUI_darx) }Catch(err){ IsMX = false }
    Try{ IsMY = CR_MeGUI_Support() && !IsPriorCropResize && defined(MeGUI_dary) }Catch(err){ IsMY = false }
    Try{ MInDAR = IsMX && IsMY ? float(MeGUI_darx) / float(MeGUI_dary) : 0.0 }Catch(err){ MInDAR = 0.0 }
    Try{ MPassDAR = CR_MeGUI_Support() ? gMPassDAR : 0.0 }Catch(err){ MPassDAR = 0.0 }

    global gPriorCropResize = true
    GMode = default(GMode, 1)

    Assert((0 <= GMode <= 2), A1 + "GMode must be 0, 1 or 2 for CropResize (1 or 2 for GCropResize)" + A2)
    Assert((GMode != 2) || IsPriorG2, A1 + "GMode cannot equal 2 for CropResize unless" + \
      A2 + " GMode=2 for a previous global GCropResize instance" + A2)

    IsGMode0 = (GMode == 0)
    IsGMode1 = (GMode == 1) && IsPriorG1
    IsGMode2 = (GMode == 2) && IsPriorG2
    NoGMode = IsGMode0 || !IsPriorG1
    IsGModeText = IsPriorG1 && (IsPriorG2 || !IsGMode1)
    GModeText = !IsGModeText ? "" : "GMode   " + (IsGMode0 ? "0" : IsGMode1 ? "1" : "2")
    GAutoC = (IsGMode1 && G1_AutoC) || (IsGMode2 && G2_AutoC)
    IsGAutoCPreview = (IsGMode1 && (G1_CPreview == 7)) || (IsGMode2 && (G2_CPreview == 7))

    GInDAR = NoGMode ? 0.0 : IsGMode1 ? G1_InDAR : G2_InDAR
    GInSAR = NoGMode ? 0.0 : IsGMode1 ? G1_InSAR : G2_InSAR
    GOutDAR = !IsPriorG1 ? 0.0 : !IsGMode2 ? G1_OutDAR : G2_OutDAR
    GOutSAR = !IsPriorG1 ? 0.0 : !IsGMode2 ? G1_OutSAR : G2_OutSAR

    Source_Width = \
      IsGMode1 && G1_AutoC ? G1_Source_Width : IsGMode2 && G2_AutoC ? G2_Source_Width : width(Source)
    Source_Height = \
      IsGMode1 && G1_AutoC ? G1_Source_Height : IsGMode2 && G2_AutoC ? G2_Source_Height : height(Source)

    F_Source_Width = float(Source_Width)
    F_Source_Height = float(Source_Height)

# ===============================================================================
#            Defaults
# ===============================================================================

    OutWidth = default(OutWidth, 0)
    OutWidth = !IsPriorG1 || (OutWidth != 0) ? OutWidth : !IsGMode2 ? G1_OutWidth : G2_OutWidth
    OutHeight = default(OutHeight, 0)
    OutHeight = !IsPriorG1 || (OutHeight != 0) ? OutHeight : !IsGMode2 ? G1_OutHeight : G2_OutHeight

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
    CR = (CR == 0) ? 0.0 : (CR < 0) ? -CR : F_Source_Width - CL - CR
    CB = (CB == 0) ? 0.0 : (CB < 0) ? -CB : F_Source_Height - CT - CB
    CRTest = ((CL + CR) < Source_Width)
    CBTest = ((CT + CB) < Source_Height)

    CropDAR = default(CropDAR, NoGMode ? 0.0 : IsGMode1 ? G1_CropDAR : G2_CropDAR)
    TCRatio = default(TCRatio, NoGMode ? 0.5 : IsGMode1 ? G1_TCRatio : G2_TCRatio)
    CSplit = default(CSplit, NoGMode ? 1 : IsGMode1 ? G1_CSplit : G2_CSplit)

    AutoC = default(AutoC, false)
    CThresh = default(CThresh, 30)
    Last_Frame = FrameCount(Source) - 1
    CStart = default(CStart, (Last_Frame > 3000) ? 250 : 0)
    CSample = default(CSample, 5)

    CPreview = default(CPreview, IsGCPreview ? G_CPreview : \
      !IsPriorG1 || IsGAutoCPreview ? 0 : !IsGMode2 ? G1_CPreview : G2_CPreview)
    CLine = default(CLine, !IsPriorG1 ? CR_CLine(Source_Width, Source_Height) : \
      !IsGMode2 && defined(G1_CLine) ? G1_CLine : IsGMode2 && defined(G2_CLine) ? G2_CLine : \
      CR_CLine(Source_Width, Source_Height))

    IsInDAR = defined(InDAR)
    IsInSAR = defined(InSAR)
    IsOutDAR = defined(OutDAR)
    IsOutSAR = defined(OutSAR)
    InDAR = default(InDAR, 0.0)
    InSAR = default(InSAR, 0.0)
    OutDAR = default(OutDAR, 0.0)
    OutSAR = default(OutSAR, 0.0)
    AutoDAR = default(AutoDAR, !IsPriorG1 ? CR_AutoDAR() : !IsGMode2 ? G1_AutoDAR : G2_AutoDAR)

    IsMod = defined(Mod)
    Mod = default(Mod, !IsPriorG1 ? 4 : !IsGMode2 ? G1_Mod : G2_Mod)
    HMod = default(HMod, IsMod || !IsPriorG1 ? Mod : !IsGMode2 ? G1_HMod : G2_HMod)
    F_Mod = float(Mod)
    F_HMod = float(HMod)

    NoResize = default(NoResize, NoGMode ? false : IsGMode1 ? G1_NoResize : G2_NoResize)
    ResizeWO = default(ResizeWO, NoGMode ? false : IsGMode1 ? G1_ResizeWO : G2_ResizeWO)

    Borders = default(Borders, NoGMode ? false : IsGMode1 ? G1_Borders : G2_Borders)
    CleanBorders = default(CleanBorders, NoGMode ? false : IsGMode1 ? G1_CleanBorders : G2_CleanBorders)
    BBlur = default(BBlur, NoGMode ? false : IsGMode1 ? G1_BBlur : G2_BBlur)
    BColor = default(BColor, NoGMode ? $000000 : IsGMode1 ? G1_BColor : G2_BColor)
    Frosty = default(Frosty, NoGMode ? false : IsGMode1 ? G1_Frosty : G2_Frosty)

    CC = default(ColorConvert, NoGMode ? CR_ColorConvert() : IsGMode1 ? G1_ColorConvert : G2_ColorConvert)
    CM = default(ColorMode, NoGMode ? "" : IsGMode1 ? G1_ColorMode : G2_ColorMode)

    IsResizer = defined(Resizer)
      Resizer = default(Resizer, \
      IsGResizer ? G_Resizer : !IsPriorG1 ? CR_Resizer_Default() : !IsGMode2 ? G1_Resizer : G2_Resizer)
    RStr = default(RStr, IsResizer || (Resizer == "") ? "" : \
      IsGResizer ? G_RStr : !IsPriorG1 ? CR_RStr_Default() : !IsGMode2 ? G1_RStr : G2_RStr)

    IsCPlace = defined(CPlace)
    CPlace = default(CPlace, NoGMode ? "" : IsGMode1 ? G1_CPlace : G2_CPlace)
    CPlaceD = default(CPlaceD, IsCPlace || NoGMode ? CPlace : IsGMode1 ? G1_CPlaceD : G2_CPlaceD)

    RingRepair = default(RingRepair, NoGMode ? false : IsGMode1 ? G1_RingRepair : G2_RingRepair)

    RMode = default(RMode, (!IsPriorCropResize && IsPriorG1 && G_RMode))
    IsPicDim = defined(PicDim) ? true : !IsPriorG1 ? false : !IsGMode2 ? G1_IsPicDim : G2_IsPicDim
    PicDim = default(PicDim, !IsPriorG1 ? CR_Info_AutoPicDim() : !IsGMode2 ? G1_PicDim : G2_PicDim)
    Position = default(Position, NoGMode ? false : IsGMode1 ? G1_Position : G2_Position)
    Info = default(Info, IsGInfo ? G_Info : !IsPriorG1 ? false : !IsGMode2 ? G1_Info : G2_Info)

# ===============================================================================
#            Miscellaneous
# ===============================================================================

    Source_Bits = BitsPerComponent(Source)
    Scale = (Source_Bits == 8) ? 1 : (Source_Bits != 32) ? pow(2, Source_Bits - 8) : 1.0 / 256.0
    Color_Format = PixelType(Source)
    IsRGBSource = IsRGB(Source)
    IsGraySource = IsY(Source)
    IsChromaSS = !IsRGBSource && !IsGraySource && !Is444(Source)
    PropRange = propGetAny(Source, "_ColorRange")
    PropRange = defined(PropRange) && IsInt(PropRange) && (0 <= PropRange <= 1) ? PropRange : -1
    IsFullRange = (PropRange == 1) ? false : (PropRange == 0) || IsRGBSource || (Source_Bits == 32)

    WidthMod = (Color_Format == "YV411") ? 4 : \
      Is420(Source) || Is422(Source) || (Color_Format == "YUY2") ? 2 : 1
    F_WidthMod = float(WidthMod)
    HeightMod = Is420(Source) ? 2 : 1
    F_HeightMod = float(HeightMod)

    CSplit1 = (CSplit == 1)
    CSplit2 = (CSplit == 2)
    IsAutoC = AutoC || GAutoC
    IsAutoCPreview = AutoC && (CPreview == 7)
    IsScriptCPreview = (1 <= CPreview <= 6) && !IsAutoCPreview && !IsGAutoCPreview
    Info = Info && !IsAutoCPreview && !IsGAutoCPreview

    CC = (CC == "AVSResize") ? "AVSResize" : (CC == "ColorMatrix") ? "ColorMatrix" : \
      (CC == "DitherTools") ? "Dithertools" : (CC == "FMTConv") ? "FMTConv" : \
      (CC == "HDRMatrix") ? "HDRMatrix" : (CC == "HDRTools") ? "HDRTools" : CC

# ===============================================================================
#            Configure Resizing
# ===============================================================================

    IsResizer = (Resizer != "")
    IsRStr = (RStr != "")
    Loaded_AVSResize = FunctionExists("z_ConvertFormat")
    Loaded_Resize8 = FunctionExists("Resize8")

    Z_Specified = (LeftStr(Resizer, 2) == "z_") && (Resizer != "z_ConvertFormat")
    R_Specified = (Resizer == "Resize8")
    IsDResize = (LeftStr(Resizer, 2) == "d_")
    IsFResize = (LeftStr(Resizer, 2) == "f_")
    IsResizeMTAppended = (RightStr(Resizer, 8) == "ResizeMT") || (RightStr(Resizer, 8) == "MTResize")
    IsMTAppended = (RightStr(Resizer, 2) == "MT")
    IsResizeMT = IsResizeMTAppended || IsMTAppended
    IsResizeAppended = (RightStr(Resizer, 6) == "Resize") && !IsResizeMTAppended

    Kernel = !IsResizer ? (Loaded_AVSResize ? "Spline36" : Loaded_Resize8 ? "Resize8" : "Spline36") : \
      Z_Specified || IsDResize || IsFResize ? ((StrLen(Resizer) == 2) ? "Spline36" : MidStr(Resizer, 3)) : \
      IsResizeMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 8) : \
      IsMTAppended ? LeftStr(Resizer, StrLen(Resizer) - 2) : \
      IsResizeAppended ? LeftStr(Resizer, StrLen(Resizer) - 6) : Resizer

    Orig_Kernel = Kernel

    IsAKernel = (Kernel == "Bicubic") || (Kernel == "Bilinear") || (Kernel == "Blackman") || \
      (Kernel == "Gauss") || (Kernel == "Point") || (Kernel == "Sinc") || \
      (Kernel == "Lanczos") || (Kernel == "Lanczos3") || (Kernel == "Lanczos4") || \
      (Kernel == "Spline16") || (Kernel == "Spline36") || (Kernel == "Spline64")

    IsZKernel = (Kernel == "Bicubic") || (Kernel == "Bilinear") || (Kernel == "Point") || \
      (Kernel == "Lanczos") || (Kernel == "Lanczos3") || (Kernel == "Lanczos4") || \
      (Kernel == "Spline16") || (Kernel == "Spline36") || (Kernel == "Spline64")

    IsDKernel = IsAKernel || (Kernel == "BlackmanMinlobe") || (Kernel == "Box") || (Kernel == "Cubic") || \
      (Kernel == "Gaussian") || (Kernel == "Linear") || (Kernel == "Rect") || (Kernel == "Spline")

    IsFKernel = IsDKernel

    IsAKernel = IsAKernel || (Kernel == "SincLin2") || (Kernel == "SinPower") || (Kernel == "UserDefined2")

# -------------------------------------------------------------------------------

    IsRingRepair = IsFloat(RingRepair) && (RingRepair > 0) || IsBool(RingRepair) && RingRepair

    IsZResize = Z_Specified || (!IsResizer && Loaded_AVSResize) && !IsRingRepair
    IsResize8 = R_Specified || (!IsResizer && !IsZResize && Loaded_Resize8) && !IsRingRepair
    IsAResize = (IsAKernel || IsResizeAppended) && \
      !IsZResize && !IsDResize && !IsFResize && !IsResize8 && !IsResizeMT

    Kernel = (Kernel == "Lanczos3") && \
      (IsZResize || IsDResize || IsFResize || IsResizeMT || IsAResize) ? "Lanczos" : \
      (Kernel == "Lanczos4") && (IsZResize || IsDResize || IsFResize) ? "Lanczos" : Kernel

    Resizer = IsZResize || IsDResize || IsFResize ? Kernel : IsResize8 ? "Resize8" : \
      IsResizeMT ? Kernel + "ResizeMT" : IsAResize ? Kernel + "Resize" : Resizer

    RTaps = (Orig_Kernel == "Lanczos3") && IsZResize ? ", filter_param_a=3" : \
      (Orig_Kernel == "Lanczos3") && (IsDResize || IsFResize || IsResizeMT || IsAResize) ? ", taps=3" : \
      (Orig_Kernel == "Lanczos4") && IsZResize ? ", filter_param_a=4" : \
      (Orig_Kernel == "Lanczos4") && (IsDResize || IsFResize) ? ", taps=4" : ""

    ResStr = !IsRStr ? "" : ", " + RStr

    Try{ MTTest = Spline36ResizeMT(Source, 960,540, placement="left")
    IsResizeMT251 = IsResizeMT }Catch(err){ IsResizeMT251 = false }

    IsZAVSR = IsZResize || (Resizer == "z_ConvertFormat")
    IsFMTC = IsFResize || (Resizer == "FMTC_Resample")
    IsCPlaceResize = (IsAResize && (AvsBuildNum >= 4273)) || IsResizeMT251

    NoResizing = NoResize || CleanBorders
    ResizeWO = ResizeWO && !NoResizing
    FullResizing = !NoResizing && !ResizeWO
    IsAutoDAR = AutoDAR && FullResizing

# ===============================================================================
#            Insist
# ===============================================================================

# -------------------------------------------------------------------------------
#            OutWidth & OutHeight
# -------------------------------------------------------------------------------

    Assert((!UseWidth && !TryWidth) || (!UseHeight && !TryHeight), \
      A1 + "OutWidth & OutHeight cannot be negative at the same time" + A2)
    Assert((!UseWidth && !TryWidth && !UseHeight && !TryHeight) || FullResizing, \
      A1 + "OutWidth & OutHeight can only be negative in full resizing mode" + A2)
    Assert((OutWidth == 0) || (WidthMod != 2) || ((OutWidth % 2) == 0), \
      A1 + Color_Format + " requires a mod2 OutWidth" + A2)
    Assert((OutWidth == 0) || (WidthMod != 4) || ((OutWidth % 4) == 0), \
      A1 + Color_Format + " requires a mod4 OutWidth" + A2)
    Assert((OutHeight == 0) || (HeightMod != 2) || ((OutHeight % 2) == 0), \
      A1 + Color_Format + " requires a mod2 OutHeight" + A2)

# -------------------------------------------------------------------------------
#            Cropping
# -------------------------------------------------------------------------------

    Assert((CL >= 0) && (CT >= 0), A1 + "CL & CT must be greater than, or equal to zero" + A2)
    Assert(CRTest, A1 + "CL + CR must be less than the source width" + A2)
    Assert(CBTest, A1 + "CT + CB must be less than the source height" + A2)
    Assert((0.0 <= TCRatio <= 1.0), A1 + "The valid range for TCRatio is 0.0 to 1.0" + A2)
    Assert((TCRatio == 0.5) || FullResizing, \
      A1 + "TCRatio cannot be used unless CropResize is in full resizing mode" + \
      A2 + " (NoResize, CleanBorders & ResizeWO cannot be true)" + A2)
    Assert(IsFloat(CropDAR) && !IsInt(CropDAR) && (CropDAR >= 0), \
      A1 + "CropDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (4.0/3 or 1.33333 etc)" + A2)
    Assert((1 <= CSplit <= 3), A1 + "CSplit must be 1, 2 or 3" + A2)
    Assert(!GAutoC || !AutoC, A1 + "AutoC cannot be true for CropResize when global" + \
      A2 + " auto-cropping has been enabled via the GCropResize function" + A2)
    Assert(!AutoC || (Color_Format == "YV12") || (Color_Format == "YUY2"), \
      A1 + "The AutoCrop plugin only supports YV12 & YUY2 video" + A2)
    Assert(AutoC || (CPreview != 7), A1 + "AutoC must be true when CPreview=7" + A2)
    Assert(!AutoC || (CStart < Last_Frame), \
      A1 + string(Last_Frame, "When AutoC=true CStart must be less than %.0f (the final frame number)") + A2)
    Assert((1 <= CThresh <= 255), A1 + "CThresh must be 1 thru 255" + A2)
    Assert(IsInt(CR_CPreview()) && (1 <= CR_CPreview() <= 3), \
      A1 + "The CR_CPreview() function must return 1, 2 or 3" + A2)
    Assert((0 <= CPreview <= 7) && (!IsGCPreview || (0 <= G_CPreview <= 7)), \
      A1 + "CPreview must be 0 thru 7" + A2)
    Assert((CLine >= 1), A1 + "CLine must be greater than or equal to 1" + A2)

# -------------------------------------------------------------------------------
#            InDAR / InSAR / OutDAR / OutSAR
# -------------------------------------------------------------------------------

    Assert(IsFloat(InDAR) && !IsInt(InDAR) && (InDAR >= 0), \
      A1 + "InDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (16.0/9 or 1.77778 etc)" + A2)
    Assert(IsFloat(InSAR) && !IsInt(InSAR) && (InSAR >= 0), \
      A1 + "InSAR must be a floating point number greater than or equal to zero" + \
      A2 + " (64.0/45 or 1.42222 etc)" + A2)
    Assert(IsFloat(OutDAR) && !IsInt(OutDAR) && (OutDAR >= 0), \
      A1 + "OutDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (16.0/9 or 1.77778 etc)" + A2)
    Assert(IsFloat(OutSAR) && !IsInt(OutSAR) && (OutSAR >= 0), \
      A1 + "OutSAR must be a floating point number greater than or equal to zero" + \
      A2 + " (64.0/45 or 1.42222 etc)" + A2)
    Assert((InDAR == 0) || (InSAR == 0), A1 + "An InDAR and InSAR cannot be specified together" + \
      A2 + " (both cannot be greater than zero)" + A2)
    Assert((OutDAR == 0) || (OutSAR == 0), A1 + "An OutDAR and OutSAR cannot be specified together" + \
      A2 + " (both cannot be greater than zero)" + A2)

# -------------------------------------------------------------------------------
#            Mod
# -------------------------------------------------------------------------------

    Assert((Mod == 1) || (Mod == 2) || (Mod == 4) || (Mod == 8) || (Mod == 16), \
      A1 + "Mod must be 1, 2, 4, 8 or 16" + A2)
    Assert((HMod == 1) || (HMod == 2) || (HMod == 4) || (HMod == 8) || (HMod == 16), \
      A1 + "HMod must be 1, 2, 4, 8 or 16" + A2)
    Assert((WidthMod != 2) || ((Mod % 2) == 0), A1 + Color_Format + " requires a minimum of Mod=2" + A2)
    Assert((WidthMod != 4) || ((Mod % 4) == 0), A1 + Color_Format + " requires a minimum of Mod=4" + A2)
    Assert((HeightMod != 2) || ((HMod % 2) == 0), A1 + Color_Format + " requires a minimum of HMod=2" + A2)

# -------------------------------------------------------------------------------
#            NoResize / CleanBorders / ResizeWO / Borders
# -------------------------------------------------------------------------------

    Assert(!NoResize || !ResizeWO, A1 + "NoResize & ResizeWO cannot be true at the same time" + A2)
    Assert(!CleanBorders || !ResizeWO, A1 + "CleanBorders & ResizeWO cannot be true at the same time" + A2)
    Assert(!NoResizing || (0 == OutDAR == OutSAR == GOutDAR == GOutSAR), \
      A1 + "An OutDAR/OutSAR cannot be specified when" + A2 + " either NoResize or CleanBorders are true" + A2)
    Assert(!ResizeWO || (CropDAR == 0) || \
    (((OutDAR == 0) || (OutDAR >= CropDAR)) && ((GOutDAR == 0) || (GOutDAR >= CropDAR))), \
      A1 + "When ResizeWO=true and both an OutDAR and a CropDAR are specified" + \
      A2 + " OutDAR must be greater than or equal to CropDAR" + A2)
    Assert(!ResizeWO || (!Borders && !Frosty) || (0 == OutDAR == GOutDAR) || (CropDAR > 0), \
      A1 + "When an OutDAR is specified and ResizeWO=true" + \
      A2 + " borders cannot be enabled unless a CropDAR is also specified" + \
      A2 + " (OutDAR and CropDAR together automatically enable borders)" + A2)
    Assert(!ResizeWO || (!Borders && !Frosty) || (0 == OutDAR == GOutDAR) || (OutHeight == 0), \
      A1 + "When ResizeWO=true and borders are enabled and an OutDAR is specified" + \
      A2 + " OutHeight must be unspecified or equal to zero" + \
      A2 + " (OutHeight can be used with an OutSAR to add top/bottom borders)" + A2)
    Assert(!IsRGBSource || !Frosty, A1 + "RGB is not supported for FrostyBorders" + A2)
    Assert((AvsBuildNum >= 4246) || !BBlur, A1 + "Avisynth+ >= 3.7.4 is required when BBlur is true" + A2)

# -------------------------------------------------------------------------------
#            Resizing
# -------------------------------------------------------------------------------

    A_R = A2 + " but not with a supported resizer" + A2
    Assert(!IsZResize || IsZKernel, A1 + "AVSResize has been specified for resizing (Z_" + Resizer + ")" + A_R)
    Assert(!IsZAVSR || (Color_Format != "YV411"), A1 + "AVSResize doesn't support resizing YV411" + A2)
    Assert(!IsDResize || (!IsRGBSource && (Source_Bits == 8)), \
      A1 + "Resizing or color conversion with DitherTools is only supported for 8 bit YUV" + A2)
    Assert(!IsDResize || IsDKernel, A1 + "DitherTools has been specified for resizing (D_" + Resizer + ")" + A_R)
    Assert(!IsFResize || IsFKernel, A1 + "FMTConv has been specified for resizing (F_" + Resizer + ")" + A_R)
    Assert(!IsFMTC || (Color_Format != "YV411"), A1 + "FMTConv doesn't supported resizing YV411" + A2)

# -------------------------------------------------------------------------------
#            Ringing Repair
# -------------------------------------------------------------------------------

    Assert(IsBool(RingRepair) || IsFloat(RingRepair), A1 + "RingRepair must be bool, integer or float" + A2)
    Assert(IsBool(RingRepair) || (IsFloat(RingRepair) && (0 <= RingRepair <= 1)), \
      A1 + "When RingRepair is an integer or float, the allowed range is 0 to 1" + A2)
    Assert(!IsRingRepair || !NoResizing, \
      A1 + "RingRepair cannot be enabled when either NoResize or CleanBorders are true" + A2)
    Assert(!IsRingRepair || !IsResize8, \
      A1 + "RingRepair cannot be enabled when Resize8 is resizing as it includes it's own ringing repair" + A2)
    Assert(!IsRingRepair || IsAResize || IsDResize || IsFMTC || IsResizeMT, \
      A1 + "RingRepair can only be enabled when resizing with" + \
      A2 + "an Avisynth resizer, DitherTools, FMTConv or the ResampleMT plugin" + A2)

# -------------------------------------------------------------------------------
#            PicDim
# -------------------------------------------------------------------------------

    Assert((0 <= PicDim <= 255), A1 + "PicDim must be 0 thru 255" + A2)

# -------------------------------------------------------------------------------
#            MeGUI
# -------------------------------------------------------------------------------

    Assert(!IsMX || (IsInt(MeGUI_darx) && (MeGUI_darx > 0)), \
      A1 + "MeGUI_darx must be an integer greater than zero" + A2)
    Assert(!IsMY || (IsInt(MeGUI_dary) && (MeGUI_dary > 0)), \
      A1 + "MeGUI_dary must be an integer greater than zero" + A2)
    Assert((IsMX == IsMY), A1 + "MeGUI_darx & MeGUI_dary must be specified together" + A2)

# ===============================================================================
#            Define Source
# ===============================================================================

    if (AutoC && !IsAutoCPreview && !GAutoC && !IsGAutoCPreview) {

        AutoCroppedSource = \
          Source.autocrop(mode=0, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
          threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0) }

    else { AutoCroppedSource = Source }

# ===============================================================================
#            Widths, Heights & Aspect Ratios
# ===============================================================================

    PropNum = propGetAny(Source, "_SARNum")
    PropNum = defined(PropNum) && IsInt(PropNum) ? PropNum : 0
    PropDen = propGetAny(Source, "_SARDen")
    PropDen = defined(PropDen) && IsInt(PropDen) ? PropDen : 0
    PropSAR = (PropNum > 0 < PropDen) ? float(PropNum) / float(PropDen) : 0

    IsCropDAR = (CropDAR > 0)
    IsGInDAR = (GInDAR > 0) && !IsInDAR && !IsInSAR
    IsGInSAR = (GInSAR > 0) && !IsInDAR && !IsInSAR
    IsGOutDAR = (GOutDAR > 0) && !IsOutDAR && !IsOutSAR
    IsGOutSAR = (GOutSAR > 0) && !IsOutDAR && !IsOutSAR
    IsMInDAR = (MInDAR > 0) && !IsInDAR && !IsInSAR && !IsGInDAR && !IsGInSAR
    IsMPassThru = (MPassDAR > 0) && !IsInDAR && !IsInSAR && !IsGInDAR && !IsGInSAR
    IsMPassedThru = IsMPassThru && IsGMode1
    IsPropSAR = (PropSAR > 0) && (PropSAR != 1) && \
    !IsInDAR && !IsInSAR && !IsGInDAR && !IsGInSAR && !IsMInDAR && !IsMPassedThru
    IsPropSAR1 = (PropSAR == 1) && \
    !IsInDAR && !IsInSAR && !IsGInDAR && !IsGInSAR && !IsMInDAR && !IsMPassedThru

    IsInDAR = (InDAR > 0)
    IsInSAR = (InSAR > 0)
    IsOutDAR = (OutDAR > 0)
    IsOutSAR = (OutSAR > 0)

    InputDAR = IsInDAR ? InDAR : IsGInDAR ? GInDAR : IsMInDAR ? MInDAR : IsMPassedThru ? MPassDAR : 0
    InputSAR = IsInSAR ? InSAR : IsGInSAR ? GInSAR : IsPropSAR ? PropSAR : 0
    OutputDAR = IsOutDAR ? OutDAR : IsGOutDAR ? GOutDAR : 0
    OutputSAR = IsOutSAR ? OutSAR : IsGOutSAR ? GOutSAR : 0

    IsInputDAR = (InputDAR > 0)
    IsInputSAR = (InputSAR > 0)
    IsOutputDAR = (OutputDAR > 0)
    IsOutputSAR = (OutputSAR > 0)

    IsBordered = Borders || Frosty || CleanBorders || (IsCropDAR && IsOutputDAR) || \
      (FullResizing && IsCropDAR && (OutWidth > 0 < OutHeight))

    AnamorphicInput = IsInputDAR || IsInputSAR
    AnamorphicOutput = (NoResizing && AnamorphicInput) || IsOutputDAR || IsOutputSAR

    Auto_Cropped_Width = width(AutoCroppedSource)
    F_Auto_Cropped_Width = float(Auto_Cropped_Width)
    Auto_Cropped_Height = height(AutoCroppedSource)
    F_Auto_Cropped_Height = float(Auto_Cropped_Height)

    Auto_Cropped_StorageAR = F_Auto_Cropped_Width / F_Auto_Cropped_Height
    Auto_Cropped_DAR = !AnamorphicInput ? Auto_Cropped_StorageAR : IsInputDAR ? \
      F_Auto_Cropped_Width * F_Source_Height * InputDAR / F_Auto_Cropped_Height / F_Source_Width : \
      F_Auto_Cropped_Width * InputSAR / F_Auto_Cropped_Height

    F_Source_Display_Width = !AnamorphicInput ? F_Source_Width : \
      IsInputDAR ? InputDAR * F_Source_Height : F_Source_Width * InputSAR

    Source_StorageAR = F_Source_Width / F_Source_Height
    Source_DAR = !AnamorphicInput ? Source_StorageAR : \
      IsInputDAR ? InputDAR : F_Source_Width * InputSAR / F_Source_Height
    Source_SAR = !AnamorphicInput ? 1.0 : IsInputDAR ? F_Source_Height * InputDAR / F_Source_Width : InputSAR

    F_Cropped_Source_Width = F_Auto_Cropped_Width - CL - CR
    F_Cropped_Source_Height = F_Auto_Cropped_Height - CT - CB

# ===============================================================================
#            No Resizing
# ===============================================================================

    if (NoResizing) {

        F_NR_CL_Adjust = CSplit1 && (fmod(CL, F_WidthMod) != 0) ? F_WidthMod - fmod(CL, F_WidthMod) : 0.0
        F_NR_CR_Adjust = CSplit1 && (fmod(CR, F_WidthMod) != 0) ? F_WidthMod - fmod(CR, F_WidthMod) : 0.0
        F_NR_CT_Adjust = CSplit1 && (fmod(CT, F_HeightMod) != 0) ? F_HeightMod - fmod(CT, F_HeightMod) : 0.0
        F_NR_CB_Adjust = CSplit1 && (fmod(CB, F_HeightMod) != 0) ? F_HeightMod - fmod(CB, F_HeightMod) : 0.0

        NR_Mod_Cropped_Width = floor((F_Cropped_Source_Width - F_NR_CL_Adjust - F_NR_CR_Adjust) / \
          (!CleanBorders ? F_Mod : F_WidthMod)) * (!CleanBorders ? Mod : WidthMod)
        F_NR_Mod_Cropped_Width = float(NR_Mod_Cropped_Width)

        NR_Mod_Cropped_Height = floor((F_Cropped_Source_Height - F_NR_CT_Adjust - F_NR_CB_Adjust) / \
          (!CleanBorders ? F_HMod : F_HeightMod)) * (!CleanBorders ? HMod : HeightMod)
        F_NR_Mod_Cropped_Height = float(NR_Mod_Cropped_Height)

        NR_Mod_Cropped_StorageAR = F_NR_Mod_Cropped_Width / F_NR_Mod_Cropped_Height
        NR_Mod_Cropped_DAR = !AnamorphicInput ? NR_Mod_Cropped_StorageAR : IsInputDAR ? \
          F_NR_Mod_Cropped_Width * F_Source_Height * InputDAR / F_NR_Mod_Cropped_Height / F_Source_Width : \
          F_NR_Mod_Cropped_Width * InputSAR / F_NR_Mod_Cropped_Height

        NR_Width = NR_Mod_Cropped_Width
        NR_Height = NR_Mod_Cropped_Height
        F_NR_Width = F_NR_Mod_Cropped_Width
        F_NR_Height = F_NR_Mod_Cropped_Height

        if (IsCropDAR && (CropDAR < NR_Mod_Cropped_DAR) && !CR_IsEqual(CropDAR, NR_Mod_Cropped_DAR)) {

            F_NR_Width = F_NR_Height * CropDAR / Source_SAR
            F_NR_Width = min(F_NR_Mod_Cropped_Width, (fmod(F_NR_Width, F_Mod) > (F_Mod / 2.0)) ? \
              F_NR_Width + F_Mod - fmod(F_NR_Width, F_Mod) : F_NR_Width - fmod(F_NR_Width, F_Mod))
            NR_Width = round(F_NR_Width) }

        else if (IsCropDAR && !CR_IsEqual(CropDAR, NR_Mod_Cropped_DAR)) {

            F_NR_Height = F_NR_Width / CropDAR * Source_SAR
            F_NR_Height = min(F_NR_Mod_Cropped_Height, (fmod(F_NR_Height, F_HMod) > (F_HMod / 2.0)) ? \
              F_NR_Height + F_HMod - fmod(F_NR_Height, F_HMod) : F_NR_Height - fmod(F_NR_Height, F_HMod))
            NR_Height = round(F_NR_Height) }

# -------------------------------------------------------------------------------
#            No Resizing - Cropping
# -------------------------------------------------------------------------------

        F_NR_Extra_Width_Crop = \
          max(0.0, F_Cropped_Source_Width - F_NR_Width - F_NR_CL_Adjust - F_NR_CR_Adjust)
        F_NR_Extra_Height_Crop = \
          max(0.0, F_Cropped_Source_Height - F_NR_Height - F_NR_CT_Adjust - F_NR_CB_Adjust)

        F_NR_Extra_Crop_LR = max(0.0, F_NR_Extra_Width_Crop / 2.0)
        F_NR_Extra_Crop_LR = CR_IsEqual(F_NR_Extra_Crop_LR, round(F_NR_Extra_Crop_LR)) ? \
          float(round(F_NR_Extra_Crop_LR)) : F_NR_Extra_Crop_LR

        F_NR_Extra_Crop_TB = max(0.0, F_NR_Extra_Height_Crop / 2.0)
        F_NR_Extra_Crop_TB = CR_IsEqual(F_NR_Extra_Crop_TB, round(F_NR_Extra_Crop_TB)) ? \
          float(round(F_NR_Extra_Crop_TB)) : F_NR_Extra_Crop_TB

        F_NR_Extra_CL = CSplit1 ? F_NR_Extra_Crop_LR - fmod(F_NR_Extra_Crop_LR, F_WidthMod) : 0.0
        F_NR_Extra_CR = CSplit1 ? F_NR_Extra_Width_Crop - F_NR_Extra_CL : 0.0
        F_NR_Extra_CT = CSplit1 ? F_NR_Extra_Crop_TB - fmod(F_NR_Extra_Crop_TB, F_HeightMod) : 0.0
        F_NR_Extra_CB = CSplit1 ? F_NR_Extra_Height_Crop - F_NR_Extra_CT : 0.0

        F_NR_Extra_CL = CSplit1 ? F_NR_Extra_CL + F_NR_CL_Adjust : 0.0
        F_NR_Extra_CR = CSplit1 ? F_NR_Extra_CR + F_NR_CR_Adjust : 0.0
        F_NR_Extra_CT = CSplit1 ? F_NR_Extra_CT + F_NR_CT_Adjust : 0.0
        F_NR_Extra_CB = CSplit1 ? F_NR_Extra_CB + F_NR_CB_Adjust : 0.0

        NR_CL = round(max(0, CSplit1 ? CL + F_NR_Extra_CL : CSplit2 ? CL - fmod(CL, F_WidthMod) : 0))
        NR_CR = round(max(0, CSplit1 ? CR + F_NR_Extra_CR : CSplit2 ? CR - fmod(CR, F_WidthMod) : 0))
        NR_CT = round(max(0, CSplit1 ? CT + F_NR_Extra_CT : CSplit2 ? CT - fmod(CT, F_HeightMod) : 0))
        NR_CB = round(max(0, CSplit1 ? CB + F_NR_Extra_CB : CSplit2 ? CB - fmod(CB, F_HeightMod) : 0))

        NR_RCL = max(0.0, CSplit1 ? 0.0 : CSplit2 ? CL + F_NR_Extra_Crop_LR - NR_CL : CL + F_NR_Extra_Crop_LR)
        NR_RCR = max(0.0, CSplit1 ? 0.0 : CSplit2 ? CR + F_NR_Extra_Crop_LR - NR_CR : CR + F_NR_Extra_Crop_LR)
        NR_RCT = max(0.0, CSplit1 ? 0.0 : CSplit2 ? CT + F_NR_Extra_Crop_TB - NR_CT : CT + F_NR_Extra_Crop_TB)
        NR_RCB = max(0.0, CSplit1 ? 0.0 : CSplit2 ? CB + F_NR_Extra_Crop_TB - NR_CB : CB + F_NR_Extra_Crop_TB)

        F_NR_Cropped_Width = CSplit1 ? F_Cropped_Source_Width - F_NR_Extra_CL - F_NR_Extra_CR : \
          F_Cropped_Source_Width - F_NR_Extra_Width_Crop

        F_NR_Cropped_Height = CSplit1 ? F_Cropped_Source_Height - F_NR_Extra_CT - F_NR_Extra_CB : \
          F_Cropped_Source_Height - F_NR_Extra_Height_Crop

# -------------------------------------------------------------------------------
#            No Resizing - Cropped Aspect Ratios
# -------------------------------------------------------------------------------

        NR_Cropped_StorageAR = F_NR_Cropped_Width / F_NR_Cropped_Height
        NR_Cropped_DAR = !AnamorphicInput ? NR_Cropped_StorageAR : IsInputDAR ? \
          F_NR_Cropped_Width * F_Source_Height * InputDAR / F_NR_Cropped_Height / F_Source_Width : \
          F_NR_Cropped_Width * InputSAR / F_NR_Cropped_Height }

    else if (ResizeWO) {

# ===============================================================================
#            Resize Width Only
# ===============================================================================

        F_RWO_CT_Adjust = CSplit1 && (fmod(CT, F_HeightMod) != 0) ? F_HeightMod - fmod(CT, F_HeightMod) : 0.0
        F_RWO_CB_Adjust = CSplit1 && (fmod(CB, F_HeightMod) != 0) ? F_HeightMod - fmod(CB, F_HeightMod) : 0.0

        F_RWO_Resized_Cropped_Width = !AnamorphicInput ? F_Cropped_Source_Width : \
          IsInputDAR ? F_Cropped_Source_Width * F_Source_Height * InputDAR / F_Source_Width : \
          F_Cropped_Source_Width * InputSAR

        RWO_Mod_Cropped_Resized_Width = ((round(F_RWO_Resized_Cropped_Width) % WidthMod) == 0) && \
          CR_IsEqual(F_RWO_Resized_Cropped_Width, round(F_RWO_Resized_Cropped_Width)) ? \
          round(F_RWO_Resized_Cropped_Width) : floor(F_RWO_Resized_Cropped_Width / F_Mod) * Mod
        F_RWO_Mod_Cropped_Resized_Width = float(RWO_Mod_Cropped_Resized_Width)

        RWO_Mod_Cropped_Height = \
          floor((F_Cropped_Source_Height - F_RWO_CT_Adjust - F_RWO_CB_Adjust) / F_HMod) * HMod
        F_RWO_Mod_Cropped_Height = float(RWO_Mod_Cropped_Height)

        RWO_Resized_Cropped_DAR = F_RWO_Resized_Cropped_Width / F_RWO_Mod_Cropped_Height
        RWO_Resized_Mod_Cropped_DAR = F_RWO_Mod_Cropped_Resized_Width / F_RWO_Mod_Cropped_Height
        RWO_Resizing_DAR = IsCropDAR ? CropDAR : IsOutputDAR ? OutputDAR : RWO_Resized_Mod_Cropped_DAR

        RWO_Width = (OutWidth > 0) && IsOutputDAR ? OutWidth : RWO_Mod_Cropped_Resized_Width
        F_RWO_Width = float(RWO_Width)

        RWO_Height = (RWO_Resizing_DAR <= RWO_Resized_Cropped_DAR) || \
          CR_IsEqual(RWO_Resizing_DAR, RWO_Resized_Cropped_DAR) ? RWO_Mod_Cropped_Height : \
          floor(F_RWO_Resized_Cropped_Width / RWO_Resizing_DAR / F_HMod) * HMod
        F_RWO_Height = float(RWO_Height)

        RWO_Resizing_SAR = !AnamorphicOutput ? 1.0 : \
          IsOutputDAR ? F_RWO_Height * OutputDAR / F_RWO_Width : OutputSAR

        F_RWO_Aspect_Width = F_RWO_Height * RWO_Resizing_DAR / RWO_Resizing_SAR
        F_RWO_Aspect_Width = CR_IsEqual(F_RWO_Aspect_Width, round(F_RWO_Aspect_Width)) && \
          ((round(F_RWO_Aspect_Width) % WidthMod) == 0) ? \
          float(round(F_RWO_Aspect_Width)) : F_RWO_Aspect_Width

        F_RWO_Adjusted_Width = min(F_RWO_Width, (fmod(F_RWO_Aspect_Width, F_Mod) > (F_Mod / 2.0)) ? \
          F_RWO_Aspect_Width + F_Mod - fmod(F_RWO_Aspect_Width, F_Mod) : \
          F_RWO_Aspect_Width - fmod(F_RWO_Aspect_Width, F_Mod))

        F_RWO_Aspect_Width = IsOutputDAR ? \
          (IsCropDAR ? F_RWO_Adjusted_Width : F_RWO_Aspect_Width) : F_RWO_Adjusted_Width

        F_RWO_Resizing_Width = IsOutputDAR ? \
          (IsCropDAR ? F_RWO_Adjusted_Width : F_RWO_Width) : F_RWO_Adjusted_Width
        RWO_Resizing_Width = round(F_RWO_Resizing_Width)

# -------------------------------------------------------------------------------
#            Resize Width Only - Cropping
# -------------------------------------------------------------------------------

        F_RWO_Extra_Width_Crop = max(0.0, \
          !AnamorphicInput ? F_Cropped_Source_Width - (F_RWO_Aspect_Width * RWO_Resizing_SAR) : \
          IsInputDAR ? F_Cropped_Source_Width - \
          (F_RWO_Aspect_Width * RWO_Resizing_SAR * F_Source_Width / InputDAR / F_Source_Height) : \
          F_Cropped_Source_Width - (F_RWO_Aspect_Width * RWO_Resizing_SAR / InputSAR))

        F_RWO_Extra_Crop_LR = max(0.0, F_RWO_Extra_Width_Crop / 2.0)
        F_RWO_Extra_Crop_LR = CR_IsEqual(F_RWO_Extra_Crop_LR, round(F_RWO_Extra_Crop_LR)) ? \
          float(round(F_RWO_Extra_Crop_LR)) : F_RWO_Extra_Crop_LR

        RWO_CL = round(max(0, \
          CSplit1 ? CL + F_RWO_Extra_Crop_LR - fmod(CL + F_RWO_Extra_Crop_LR, F_WidthMod) : \
          CSplit2 ? CL - fmod(CL, F_WidthMod) : 0))
        RWO_CR = round(max(0, \
          CSplit1 ? CR + F_RWO_Extra_Crop_LR - fmod(CR + F_RWO_Extra_Crop_LR, F_WidthMod) : \
          CSplit2 ? CR - fmod(CR, F_WidthMod) : 0))

        RWO_RCL = max(0.0, CSplit1 || CSplit2 ? CL + F_RWO_Extra_Crop_LR - RWO_CL : CL + F_RWO_Extra_Crop_LR)
        RWO_RCR = max(0.0, CSplit1 || CSplit2 ? CR + F_RWO_Extra_Crop_LR - RWO_CR : CR + F_RWO_Extra_Crop_LR)

        F_RWO_Extra_Height_Crop = max(0.0, \
          F_Cropped_Source_Height - F_RWO_Height - F_RWO_CT_Adjust - F_RWO_CB_Adjust)

        F_RWO_Extra_Crop_TB = max(0.0, F_RWO_Extra_Height_Crop / 2.0)
        F_RWO_Extra_Crop_TB = CR_IsEqual(F_RWO_Extra_Crop_TB, round(F_RWO_Extra_Crop_TB)) ? \
          float(round(F_RWO_Extra_Crop_TB)) : F_RWO_Extra_Crop_TB

        F_RWO_Extra_CT = CSplit1 ? F_RWO_Extra_Crop_TB - fmod(F_RWO_Extra_Crop_TB, F_HeightMod) : 0.0
        F_RWO_Extra_CB = CSplit1 ? F_RWO_Extra_Height_Crop - F_RWO_Extra_CT : 0.0
        F_RWO_Extra_CT = CSplit1 ? F_RWO_Extra_CT + F_RWO_CT_Adjust : 0.0
        F_RWO_Extra_CB = CSplit1 ? F_RWO_Extra_CB + F_RWO_CB_Adjust : 0.0

        RWO_CT = round(max(0, CSplit1 ? CT + F_RWO_Extra_CT : CSplit2 ? CT - fmod(CT, F_HeightMod) : 0))
        RWO_CB = round(max(0, CSplit1 ? CB + F_RWO_Extra_CB : CSplit2 ? CB - fmod(CB, F_HeightMod) : 0))

        RWO_RCT = CSplit1 ? 0.0 : \
          max(0.0, CSplit2 ? CT + F_RWO_Extra_Crop_TB - RWO_CT : CT + F_RWO_Extra_Crop_TB)
        RWO_RCB = CSplit1 ? 0.0 : \
          max(0.0, CSplit2 ? CB + F_RWO_Extra_Crop_TB - RWO_CB : CB + F_RWO_Extra_Crop_TB)

        F_RWO_Cropped_Width = F_Cropped_Source_Width - F_RWO_Extra_Width_Crop
        F_RWO_Cropped_Height = (CSplit == 1) ? F_Cropped_Source_Height - F_RWO_Extra_CT - F_RWO_Extra_CB : \
          F_Cropped_Source_Height - F_RWO_Extra_Height_Crop

# -------------------------------------------------------------------------------
#            Resize Width Only - Cropped Aspect Ratios
# -------------------------------------------------------------------------------

        RWO_Cropped_StorageAR = F_RWO_Cropped_Width / F_RWO_Cropped_Height
        RWO_Cropped_DAR = !AnamorphicInput ? RWO_Cropped_StorageAR : IsInputDAR ? \
          F_RWO_Cropped_Width * F_Source_Height * InputDAR / F_RWO_Cropped_Height / F_Source_Width : \
          F_RWO_Cropped_Width * InputSAR / F_RWO_Cropped_Height }

    else {

# ===============================================================================
#            Full Resizing Defaults
# ===============================================================================

        Cropped_Source_DAR = \
          !AnamorphicInput ? F_Cropped_Source_Width / F_Cropped_Source_Height : \
          IsInputDAR ? \
          F_Cropped_Source_Width * F_Source_Height * InputDAR / F_Cropped_Source_Height / F_Source_Width : \
          F_Cropped_Source_Width * InputSAR / F_Cropped_Source_Height

        F_Resized_Cropped_Width = !AnamorphicInput ? F_Cropped_Source_Width : \
          IsInputDAR ? F_Cropped_Source_Width * F_Source_Height * InputDAR / F_Source_Width : \
          F_Cropped_Source_Width * InputSAR

        Mod_Cropped_Resized_Width = ((round(F_Resized_Cropped_Width) % WidthMod) == 0) && \
          CR_IsEqual(F_Resized_Cropped_Width, round(F_Resized_Cropped_Width)) ? \
          round(F_Resized_Cropped_Width) : floor(F_Resized_Cropped_Width / F_Mod) * Mod
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
        Resizing_DAR = IsOutputDAR && IsBordered && !IsCropDAR ? Cropped_Source_DAR : \
          IsCropDAR ? CropDAR : IsOutputDAR ? OutputDAR : Cropped_Source_DAR
        Resizing_SAR = !AnamorphicOutput ? 1.0 : \
          IsOutputDAR ? F_Resizing_Height * OutputDAR / F_Resizing_Width : OutputSAR

# ===============================================================================
#            AutoDAR
# ===============================================================================

        IsAutoDAR = AutoDAR && !IsCropDAR && !IsOutputDAR && \
          !KeepWidth && !KeepHeight && (IsBordered || !(OutWidth > 0 < OutHeight))

        IsAspect169 = IsAutoDAR && ((!IsBordered ? 1.739 : 16.0 / 9.0) < Resizing_DAR < 1.829)
        IsAspect43 = IsAutoDAR && (1.27 < Resizing_DAR < (!IsBordered ? 1.35 : 4.0 / 3.0))
        H169 = !IsAutoDAR ? nop() : F_Resizing_Width * (IsOutputSAR ? OutputSAR : 1.0) * 9.0 / 16.0
        H43 = !IsAutoDAR ? nop() : F_Resizing_Width * (IsOutputSAR ? OutputSAR : 1.0) * 3.0 / 4.0
        W169 = !IsAutoDAR ? nop() : F_Resizing_Height * 16.0 / 9.0 / (IsOutputSAR ? OutputSAR : 1.0)
        W43 = !IsAutoDAR ? nop() : F_Resizing_Height * 4.0 / 3.0 / (IsOutputSAR ? OutputSAR : 1.0)
        IsHeight169 = IsAspect169 && CR_IsEqual(round(H169), H169) && ((round(H169) % HMod) == 0)
        IsHeight43 = IsAspect43 && CR_IsEqual(round(H43), H43) && ((round(H43) % HMod) == 0)
        IsWidth169 = IsAspect169 && CR_IsEqual(round(W169), W169) && ((round(W169) % Mod) == 0)
        IsWidth43 = IsAspect43 && CR_IsEqual(round(W43), W43) && ((round(W43) % Mod) == 0)

# ===============================================================================
#            Full Resizing (A) Height Calculated From Width
# ===============================================================================

        FullResizeA = !IsBordered ? ((OutWidth > 0) ? true : (OutHeight > 0) ? false : \
          IsHeight169 || IsHeight43 ? true : IsWidth169 || IsWidth43 ? false : true) : \
          (Resizing_DAR >= (Resizing_StorageAR * Resizing_SAR))

        if (FullResizeA) {

            F_FRA_Aspect_Height = F_Resizing_Width * Resizing_SAR / Resizing_DAR
            F_FRA_Aspect_Height = CR_IsEqual(F_FRA_Aspect_Height, round(F_FRA_Aspect_Height)) && \
              ((round(F_FRA_Aspect_Height) % HeightMod) == 0) ? \
              float(round(F_FRA_Aspect_Height)) : F_FRA_Aspect_Height

            F_FRA_Height_Up = F_FRA_Aspect_Height + F_HMod - fmod(F_FRA_Aspect_Height, F_HMod)
            F_FRA_Height_Down = F_FRA_Aspect_Height - fmod(F_FRA_Aspect_Height, F_HMod)

            F_FRA_Adjusted_Height1 = KeepWidth ? F_FRA_Height_Down : \
              (fmod(F_FRA_Aspect_Height, F_HMod) > (F_HMod / 2.0)) ? F_FRA_Height_Up : F_FRA_Height_Down
            F_FRA_Adjusted_Height2 = \
              IsHeight169 ? round(H169) : IsHeight43 ? round(H43) : F_FRA_Adjusted_Height1

            F_FRA_Aspect_Height = IsOutputDAR && IsBordered && !IsCropDAR ? \
              ((OutHeight == 0) ? F_Resizing_Height : F_FRA_Adjusted_Height1) : \
              IsOutputDAR ? (IsCropDAR ? F_FRA_Height_Down : F_FRA_Aspect_Height) : \
              IsBordered || (OutHeight == 0) ? F_FRA_Adjusted_Height2 : F_Resizing_Height

            F_FRA_Resizing_Height = IsOutputDAR && IsBordered && !IsCropDAR ? F_FRA_Aspect_Height : \
              IsOutputDAR ? (IsCropDAR ? F_FRA_Height_Down : F_Resizing_Height) : F_FRA_Aspect_Height
            FRA_Resizing_Height = round(F_FRA_Resizing_Height)

            FRA_Cropping_DAR = F_Resizing_Width * Resizing_SAR / F_FRA_Aspect_Height

            F_FRA_Extra_Width_Crop = CR_IsEqual(FRA_Cropping_DAR, Cropped_Source_DAR) || \
              (FRA_Cropping_DAR > Cropped_Source_DAR) ? 0.0 : \
              max(0.0, !AnamorphicInput ? F_Cropped_Source_Width - \
              (F_Cropped_Source_Height * F_Resizing_Width * Resizing_SAR / F_FRA_Aspect_Height) : \
              IsInputDAR ? F_Cropped_Source_Width - \
              (F_Cropped_Source_Height * F_Resizing_Width * \
              F_Source_Width * Resizing_SAR / InputDAR / F_FRA_Aspect_Height / F_Source_Height) : \
              F_Cropped_Source_Width - \
              (F_Cropped_Source_Height * F_Resizing_Width * Resizing_SAR / F_FRA_Aspect_Height / InputSAR))

            F_FRA_Extra_Height_Crop = CR_IsEqual(FRA_Cropping_DAR, Cropped_Source_DAR) || \
              (FRA_Cropping_DAR < Cropped_Source_DAR) ? 0.0 : \
              max(0.0, !AnamorphicInput ? F_Cropped_Source_Height - \
              (F_Cropped_Source_Width * F_FRA_Aspect_Height / F_Resizing_Width / Resizing_SAR) : \
              IsInputDAR ? F_Cropped_Source_Height - \
              (F_Cropped_Source_Width * F_FRA_Aspect_Height * \
              F_Source_Height * InputDAR / F_Resizing_Width / Resizing_SAR / F_Source_Width) : \
              F_Cropped_Source_Height - \
              (F_Cropped_Source_Width * F_FRA_Aspect_Height * InputSAR / F_Resizing_Width / Resizing_SAR))

# -------------------------------------------------------------------------------
#            Full Resizing (A) Cropping
# -------------------------------------------------------------------------------

            TCRatio = (FRA_Cropping_DAR <= Cropped_Source_DAR) ? 0.5 : TCRatio

            F_FRA_Extra_Crop_LR = max(0.0, F_FRA_Extra_Width_Crop / 2.0)
            F_FRA_Extra_Crop_LR = CR_IsEqual(F_FRA_Extra_Crop_LR, round(F_FRA_Extra_Crop_LR)) ? \
              round(F_FRA_Extra_Crop_LR) : F_FRA_Extra_Crop_LR

            F_FRA_Extra_Crop_T = max(0.0, (TCRatio == 0.5) ? F_FRA_Extra_Height_Crop / 2.0 : \
              F_FRA_Extra_Height_Crop * TCRatio)
              F_FRA_Extra_Crop_T = CR_IsEqual(F_FRA_Extra_Crop_T, round(F_FRA_Extra_Crop_T)) ? \
              round(F_FRA_Extra_Crop_T) : F_FRA_Extra_Crop_T

            F_FRA_Extra_Crop_B = max(0.0, (TCRatio == 0.5) ? F_FRA_Extra_Height_Crop / 2.0 : \
              F_FRA_Extra_Height_Crop - F_FRA_Extra_Crop_T)
            F_FRA_Extra_Crop_B = CR_IsEqual(F_FRA_Extra_Crop_B, round(F_FRA_Extra_Crop_B)) ? \
              round(F_FRA_Extra_Crop_B) : F_FRA_Extra_Crop_B

            FRA_CL = round(max(0, \
              CSplit1 ? CL + F_FRA_Extra_Crop_LR - fmod(CL + F_FRA_Extra_Crop_LR, F_WidthMod) : \
              CSplit2 ? CL - fmod(CL, F_WidthMod) : 0))
            FRA_CR = round(max(0, \
              CSplit1 ? CR + F_FRA_Extra_Crop_LR - fmod(CR + F_FRA_Extra_Crop_LR, F_WidthMod) : \
              CSplit2 ? CR - fmod(CR, F_WidthMod) : 0))
            FRA_CT = round(max(0, \
              CSplit1 ? CT + F_FRA_Extra_Crop_T - fmod(CT + F_FRA_Extra_Crop_T, F_HeightMod) : \
              CSplit2 ? CT - fmod(CT, F_HeightMod) : 0))
            FRA_CB = round(max(0, \
              CSplit1 ? CB + F_FRA_Extra_Crop_B - fmod(CB + F_FRA_Extra_Crop_B, F_HeightMod) : \
              CSplit2 ? CB - fmod(CB, F_HeightMod) : 0))

            FRA_RCL = max(0.0, \
              CSplit1 || CSplit2 ? CL + F_FRA_Extra_Crop_LR - FRA_CL : CL + F_FRA_Extra_Crop_LR)
            FRA_RCR = max(0.0, \
              CSplit1 || CSplit2 ? CR + F_FRA_Extra_Crop_LR - FRA_CR : CR + F_FRA_Extra_Crop_LR)
            FRA_RCT = max(0.0, \
              CSplit1 || CSplit2 ? CT + F_FRA_Extra_Crop_T - FRA_CT : CT + F_FRA_Extra_Crop_T)
            FRA_RCB = max(0.0, \
              CSplit1 || CSplit2 ? CB + F_FRA_Extra_Crop_B - FRA_CB : CB + F_FRA_Extra_Crop_B)

            F_FRA_Cropped_Width = F_Cropped_Source_Width - F_FRA_Extra_Width_Crop
            F_FRA_Cropped_Height = F_Cropped_Source_Height - F_FRA_Extra_Height_Crop

# -------------------------------------------------------------------------------
#            Full Resizing (A) Cropped Aspect Ratios
# -------------------------------------------------------------------------------

            FRA_Cropped_StorageAR = F_FRA_Cropped_Width / F_FRA_Cropped_Height
            FRA_Cropped_DAR = !AnamorphicInput ? FRA_Cropped_StorageAR : IsInputDAR ? \
              F_FRA_Cropped_Width * F_Source_Height * InputDAR / F_FRA_Cropped_Height / F_Source_Width : \
              F_FRA_Cropped_Width * InputSAR / F_FRA_Cropped_Height }

        else {

# ===============================================================================
#            Full Resizing (B) Width Calculated From Height
# ===============================================================================

            F_FRB_Aspect_Width = F_Resizing_Height * Resizing_DAR / Resizing_SAR
            F_FRB_Aspect_Width = CR_IsEqual(F_FRB_Aspect_Width, round(F_FRB_Aspect_Width)) && \
              ((round(F_FRB_Aspect_Width) % WidthMod) == 0) ? \
              float(round(F_FRB_Aspect_Width)) : F_FRB_Aspect_Width

            F_FRB_Width_Up = F_FRB_Aspect_Width + F_Mod - fmod(F_FRB_Aspect_Width, F_Mod)
            F_FRB_Width_Down = F_FRB_Aspect_Width - fmod(F_FRB_Aspect_Width, F_Mod)

            F_FRB_Adjusted_Width1 = KeepHeight ? F_FRB_Width_Down : \
              (fmod(F_FRB_Aspect_Width, F_Mod) > (F_Mod / 2.0)) ? F_FRB_Width_Up : F_FRB_Width_Down
              F_FRB_Adjusted_Width2 = \
              IsWidth169 ? round(W169) : IsWidth43 ? round(W43) : F_FRB_Adjusted_Width1

            F_FRB_Aspect_Width = IsOutputDAR && IsBordered && !IsCropDAR ? \
              ((OutWidth == 0) ? F_Resizing_Width : F_FRB_Adjusted_Width1) : \
              IsOutputDAR ? (IsCropDAR ? F_FRB_Width_Down : F_FRB_Aspect_Width) : \
              IsBordered || (OutWidth == 0) ? F_FRB_Adjusted_Width2 : F_Resizing_Width

            F_FRB_Resizing_Width = IsOutputDAR && IsBordered && !IsCropDAR ? F_FRB_Aspect_Width : \
              IsOutputDAR ? (IsCropDAR ? F_FRB_Width_Down : F_Resizing_Width) : F_FRB_Aspect_Width
              FRB_Resizing_Width = round(F_FRB_Resizing_Width)

            FRB_Cropping_DAR = F_FRB_Aspect_Width * Resizing_SAR / F_Resizing_Height

            F_FRB_Extra_Width_Crop = CR_IsEqual(FRB_Cropping_DAR, Cropped_Source_DAR) || \
              (FRB_Cropping_DAR > Cropped_Source_DAR) ? 0.0 : \
              max(0.0, !AnamorphicInput ? F_Cropped_Source_Width - \
              (F_Cropped_Source_Height * F_FRB_Aspect_Width * Resizing_SAR / F_Resizing_Height) : \
              IsInputDAR ? F_Cropped_Source_Width - \
              (F_Cropped_Source_Height * F_FRB_Aspect_Width * \
              Resizing_SAR * F_Source_Width / InputDAR / F_Resizing_Height / F_Source_Height) : \
              F_Cropped_Source_Width - \
              (F_Cropped_Source_Height * F_FRB_Aspect_Width * Resizing_SAR / F_Resizing_Height / InputSAR))

            F_FRB_Extra_Height_Crop = CR_IsEqual(FRB_Cropping_DAR, Cropped_Source_DAR) || \
              (FRB_Cropping_DAR < Cropped_Source_DAR) ? 0.0 : \
              max(0.0, !AnamorphicInput ? F_Cropped_Source_Height - \
              (F_Cropped_Source_Width * F_Resizing_Height / F_FRB_Aspect_Width / Resizing_SAR) : \
              IsInputDAR ? F_Cropped_Source_Height - \
              (F_Cropped_Source_Width * F_Resizing_Height * \
              F_Source_Height * InputDAR / F_FRB_Aspect_Width / Resizing_SAR / F_Source_Width) : \
              F_Cropped_Source_Height - \
              (F_Cropped_Source_Width * F_Resizing_Height * InputSAR / F_FRB_Aspect_Width / Resizing_SAR))

# -------------------------------------------------------------------------------
#            Full Resizing (B) Cropping
# -------------------------------------------------------------------------------

            TCRatio = (FRB_Cropping_DAR <= Cropped_Source_DAR) ? 0.5 : TCRatio

            F_FRB_Extra_Crop_LR = max(0.0, F_FRB_Extra_Width_Crop / 2.0)
            F_FRB_Extra_Crop_LR = CR_IsEqual(F_FRB_Extra_Crop_LR, round(F_FRB_Extra_Crop_LR)) ? \
              round(F_FRB_Extra_Crop_LR) : F_FRB_Extra_Crop_LR

            F_FRB_Extra_Crop_T = max(0.0, (TCRatio == 0.5) ? F_FRB_Extra_Height_Crop / 2.0 : \
              F_FRB_Extra_Height_Crop * TCRatio)
            F_FRB_Extra_Crop_T = CR_IsEqual(F_FRB_Extra_Crop_T, round(F_FRB_Extra_Crop_T)) ? \
              round(F_FRB_Extra_Crop_T) : F_FRB_Extra_Crop_T

            F_FRB_Extra_Crop_B = max(0.0, (TCRatio == 0.5) ? F_FRB_Extra_Height_Crop / 2.0 : \
              F_FRB_Extra_Height_Crop - F_FRB_Extra_Crop_T)
            F_FRB_Extra_Crop_B = CR_IsEqual(F_FRB_Extra_Crop_B, round(F_FRB_Extra_Crop_B)) ? \
              round(F_FRB_Extra_Crop_B) : F_FRB_Extra_Crop_B

            FRB_CL = round(max(0, \
              CSplit1 ? CL + F_FRB_Extra_Crop_LR - fmod(CL + F_FRB_Extra_Crop_LR, F_WidthMod) : \
              CSplit2 ? CL - fmod(CL, F_WidthMod) : 0))
            FRB_CR = round(max(0, \
              CSplit1 ? CR + F_FRB_Extra_Crop_LR - fmod(CR + F_FRB_Extra_Crop_LR, F_WidthMod) : \
              CSplit2 ? CR - fmod(CR, F_WidthMod) : 0))
            FRB_CT = round(max(0, \
              CSplit1 ? CT + F_FRB_Extra_Crop_T - fmod(CT + F_FRB_Extra_Crop_T, F_HeightMod) : \
              CSplit2 ? CT - fmod(CT, F_HeightMod) : 0))
            FRB_CB = round(max(0, \
              CSplit1 ? CB + F_FRB_Extra_Crop_B - fmod(CB + F_FRB_Extra_Crop_B, F_HeightMod) : \
              CSplit2 ? CB - fmod(CB, F_HeightMod) : 0))

            FRB_RCL = max(0.0, \
              CSplit1 || CSplit2 ? CL + F_FRB_Extra_Crop_LR - FRB_CL : CL + F_FRB_Extra_Crop_LR)
            FRB_RCR = max(0.0, \
              CSplit1 || CSplit2 ? CR + F_FRB_Extra_Crop_LR - FRB_CR : CR + F_FRB_Extra_Crop_LR)
            FRB_RCT = max(0.0, \
              CSplit1 || CSplit2 ? CT + F_FRB_Extra_Crop_T - FRB_CT : CT + F_FRB_Extra_Crop_T)
            FRB_RCB = max(0.0, \
              CSplit1 || CSplit2 ? CB + F_FRB_Extra_Crop_B - FRB_CB : CB + F_FRB_Extra_Crop_B)

            F_FRB_Cropped_Width = F_Cropped_Source_Width - F_FRB_Extra_Width_Crop
            F_FRB_Cropped_Height = F_Cropped_Source_Height - F_FRB_Extra_Height_Crop

# -------------------------------------------------------------------------------
#            Full Resizing (B) Cropped Aspect Ratios
# -------------------------------------------------------------------------------

            FRB_Cropped_StorageAR = F_FRB_Cropped_Width / F_FRB_Cropped_Height
            FRB_Cropped_DAR = !AnamorphicInput ? FRB_Cropped_StorageAR : IsInputDAR ? \
              F_FRB_Cropped_Width * F_Source_Height * InputDAR / F_FRB_Cropped_Height / F_Source_Width : \
              F_FRB_Cropped_Width * InputSAR / F_FRB_Cropped_Height } }

# ===============================================================================
#            Output Width, Height & Aspect Ratios
# ===============================================================================

    CRVideo_Width = NoResizing ? NR_Width : ResizeWO ? RWO_Resizing_Width : \
      FullResizeA ? Resizing_Width : FRB_Resizing_Width
    F_CRVideo_Width = float(CRVideo_Width)

    CRVideo_Height = NoResizing ? NR_Height : ResizeWO ? RWO_Height : \
      FullResizeA ? FRA_Resizing_Height : Resizing_Height
    F_CRVideo_Height = float(CRVideo_Height)

    CRVideo_StorageAR = F_CRVideo_Width / F_CRVideo_Height

    CRVideo_DAR = NoResizing ? (!AnamorphicInput ? CRVideo_StorageAR : \
      IsInputDAR ? F_CRVideo_Width * F_Source_Height * InputDAR / F_CRVideo_Height / F_Source_Width : \
      F_CRVideo_Width * Source_SAR / F_CRVideo_Height) : \
      !AnamorphicOutput ? CRVideo_StorageAR : \
      ResizeWO ? F_CRVideo_Width * RWO_Resizing_SAR / F_CRVideo_Height : \
      F_CRVideo_Width * Resizing_SAR / F_CRVideo_Height

    Final_Width = CleanBorders ? Source_Width : \
      !IsBordered ? CRVideo_Width : \
      ResizeWO && IsOutputDAR ? RWO_Width : \
      (NoResizing || ResizeWO) && (OutWidth > CRVideo_Width) ? OutWidth : \
      FullResizing && (Resizing_StorageAR > CRVideo_StorageAR) ? \
      ((OutWidth == 0) ? Resizing_Width : \
      (OutWidth > CRVideo_Width) ? OutWidth : CRVideo_Width) : CRVideo_Width
    F_Final_Width = float(Final_Width)

    Final_Height = CleanBorders ? Source_Height : \
      !IsBordered ? CRVideo_Height : \
      ResizeWO && IsOutputDAR ? CRVideo_Height : \
      (NoResizing || ResizeWO) && (OutHeight > CRVideo_Height) ? OutHeight : \
      FullResizing && (Resizing_StorageAR < CRVideo_StorageAR) ? \
      ((OutHeight == 0) ? Resizing_Height : \
      (OutHeight > CRVideo_Height) ? OutHeight : CRVideo_Height) : CRVideo_Height
    F_Final_Height = float(Final_Height)

    Final_StorageAR = F_Final_Width / F_Final_Height

    Final_DAR = NoResizing ? (!AnamorphicInput ? Final_StorageAR : \
      IsInputDAR ? F_Final_Width * F_Source_Height * InputDAR / F_Final_Height / F_Source_Width : \
      F_Final_Width * Source_SAR / F_Final_Height) : \
      !AnamorphicOutput ? Final_StorageAR : \
      ResizeWO ? F_Final_Width * RWO_Resizing_SAR / F_Final_Height : \
      F_Final_Width * Resizing_SAR / F_Final_Height

    IsAnamorphicInput = AnamorphicInput && !CR_IsEqual(Source_DAR, Source_StorageAR)
    IsAnamorphicOutput = AnamorphicOutput && !CR_IsEqual(Final_DAR, Final_StorageAR)

    F_Final_Display_Width = !IsAnamorphicOutput ? F_Final_Width : \
      NoResizing ? F_Final_Width * Source_SAR : \
      ResizeWO ? F_Final_Width * RWO_Resizing_SAR : F_Final_Width * Resizing_SAR

    Final_SAR = !IsAnamorphicOutput ? 1.0 : \
          NoResizing ? Source_SAR : ResizeWO ? RWO_Resizing_SAR : Resizing_SAR

# ===============================================================================
#            Configure Color Conversion
# ===============================================================================

    if ((CC != "") || (CM != "")) {

        PropMatrix = propGetAny(Source, "_Matrix")
        PropMatrix = defined(PropMatrix) && IsInt(PropMatrix) && (PropMatrix != 2) ? PropMatrix : -1
        PropTrans = propGetAny(Source, "_Transfer")
        PropTrans = defined(PropTrans) && IsInt(PropTrans) && (PropTrans != 2) ? PropTrans : -1
        PropPrim = propGetAny(Source, "_Primaries")
        PropPrim = defined(PropPrim) && IsInt(PropPrim) && (PropPrim != 2) ? PropPrim : -1

        PropMatrixStr = (PropMatrix == -1) ? "none" : (PropMatrix == 1) ? "709" : \
          (5 <= PropMatrix <= 6) ? "601" : (PropMatrix == 9) ? "2020" : ""
        PropPrimStr = (PropPrim == -1) ? "none" : (PropPrim == 1) ? "709" : (PropPrim == 5) ? "470bg" : \
          (PropPrim == 6) ? "170m" : (PropPrim == 7) ? "240m" : (PropPrim == 9) ? "2020" : ""

# -------------------------------------------------------------------------------

        Assert(!IsRGBSource, A1 + "RGB is not supported for color conversion" + A2)
        Assert(!IsGraySource, A1 + "Video without chroma doesn't require color conversion" + A2)
        Assert((CC == "") || (CC == "AVSResize") || (CC == "ColorMatrix") || (CC == "DitherTools") || \
          (CC == "FMTConv") || (CC == "HDRMatrix") || (CC == "HDRTools"), \
          A1 + "ColorConvert=" + chr(34) + CC + chr(34) + " is not a supported type" + A2)
        Assert((CM == "") || (CM == "601-709") || (CM == "709-601") || \
          (CM == "601P-601N") || (CM == "601P-709") || (CM == "601P-2020") || \
          (CM == "601N-601P") || (CM == "601N-709") || (CM == "601N-2020") || \
          (CM == "709-601P") || (CM == "709-601N") || (CM == "709-2020") || (CM == "709-2020M") || \
          (CM == "2020-601P") || (CM == "2020-601N") || (CM == "2020-709") || (CM == "2020-709M"), \
          A1 + "ColorMode=" + chr(34) + CM + chr(34) + " is not a supported color mode" + A2)
        Assert((CC == "") || (CM != "") || (PropMatrixStr != ""), \
          A1 + "The value for color matrix in frame properties (" + string(PropMatrix) + \
          ") is not" + A2 + " supported for automatic color conversion, however a" + \
          A2 + " conversion can be forced with the ColorMode argument" + A2)
          Assert((CC == "") || (CM != "") || (PropPrimStr != ""), \
          A1 + "The value for color primaries in frame properties (" + string(PropPrim) + \
          ") is not" + A2 + " supported for automatic color conversion, however a" + \
          A2 + " conversion can be forced with the ColorMode argument" + A2)
        Assert((CC == "") || (CM != "") || (PropMatrix == -1) || (PropPrim == -1) || \
          (((PropMatrix == 1) || (PropMatrix == 9)) && ((PropPrim == 1) || (PropPrim == 9))) || \
          (((PropMatrix == 1) || (5 <= PropMatrix <= 6)) && ((PropPrim == 1) || (5 <= PropPrim <= 7))), \
          A1 + "The mismatched values in frame properties for color matrix (" + \
          PropMatrixStr + ") and" + A2 + " color primaries (" + PropPrimStr + ") " + \
          "are not supported for automatic color conversion" + \
          A2 + " however a conversion can be forced with the ColorMode argument" + A2)

# -------------------------------------------------------------------------------

        Loaded_ColorMatrix = FunctionExists("ColorMatrix")
        Loaded_DitherTools = FunctionExists("Dither_convert_yuv_to_rgb")
        Loaded_FMTConv = FunctionExists("fmtc_resample")
        Loaded_HDRMatrix = FunctionExists("Matrix")
        Loaded_HDRTools = FunctionExists("ConvertYUVtoXYZ")
        Loaded_ConvStack = FunctionExists("ConvertToDoubleWidth")
        IsPrimPlugin = Loaded_AVSResize || Loaded_FMTConv || Loaded_HDRTools
        Is2020Plugin = IsPrimPlugin || Loaded_DitherTools
        Is709Plugin = IsPrimPlugin || Is2020Plugin || Loaded_HDRMatrix || Loaded_ColorMatrix

        IsSDSource = (F_Source_Display_Width <= 1056) && (Source_Height < 600)
        IsHDSource = ((F_Source_Display_Width > 1056) || (Source_Height >= 600)) && \
          (F_Source_Display_Width <= 1920) && (Source_Height <= 1080)
        IsUHDSource = (F_Source_Display_Width > 1920) || (Source_Height > 1080)

        IsSDOut = (F_Final_Display_Width <= 1056) && (Final_Height < 600)
        IsHDOut = ((F_Final_Display_Width > 1056) || (Final_Height >= 600)) && \
          (F_Final_Display_Width <= 1920) && (Final_Height <= 1080)
        IsUHDOut = (F_Final_Display_Width > 1920) || (Final_Height > 1080)

        CM = (CM != "") ? CM : IsGraySource ? "" : \
          (5 <= PropMatrix <= 6) ? \
          (IsHDOut && (PropMatrix == 6) && (6 <= PropPrim <= 7) && IsPrimPlugin ? "601N-709" : \
          IsHDOut && (PropMatrix == 5) && (PropPrim == 5) && IsPrimPlugin ? "601P-709" : \
          IsHDOut && (PropPrim == -1) && (CC == "HDRTools") ? "601P-709" : \
          IsHDOut && (PropPrim != 9) && Is709Plugin && (CC != "HDRTools") ? "601-709" : \
          IsUHDOut && (PropMatrix == 6) && \
          ((PropPrim == -1) || (6 <= PropPrim <= 7)) && IsPrimPlugin ? "601N-2020" : \
          IsUHDOut && (PropMatrix == 5) && \
          ((PropPrim == -1) || (PropPrim == 5)) && IsPrimPlugin ? "601P-2020" : \
          IsHDOut || IsUHDOut ? "none" : "") : \
          (PropMatrix == 1) ? \
          (IsSDOut && ((PropPrim == -1) || (PropPrim == 1)) && (CC == "HDRTools") ? "709-601P" : \
          IsSDOut && (PropPrim != 9) && Is709Plugin && (CC != "HDRTools") ? "709-601" : \
          IsUHDOut && ((PropPrim == -1) || (PropPrim == 1)) && IsPrimPlugin ? "709-2020" : \
          IsUHDOut && (PropPrim == 9) && Is2020Plugin && (CC != "HDRTools") ? "709-2020M" : \
          IsSDOut || IsUHDOut ? "none" : "") : \
          (PropMatrix == 9) ? \
          (IsSDOut && ((PropPrim == -1) || (PropPrim == 9)) && IsPrimPlugin ? "2020-601P" : \
          IsHDOut && ((PropPrim == -1) || (PropPrim == 9)) && IsPrimPlugin ? "2020-709" : \
          IsHDOut && (PropPrim == 1) && Is2020Plugin && (CC != "HDRTools") ? "2020-709M" : \
          IsSDOut || IsHDOut ? "none" : "") : \
          !FullResizing ? "" : \
          IsSDSource && IsHDOut && (CC == "HDRTools") ? "601P-709" : \
          IsSDSource && IsHDOut ? "601-709" : \
          IsSDSource && IsUHDOut && IsPrimPlugin ? "601P-2020" : \
          IsSDSource && IsUHDOut ? "none" : \
          IsHDSource && IsSDOut && (CC == "HDRTools") ? "709-601P" : \
          IsHDSource && IsSDOut ? "709-601" : \
          IsHDSource && IsUHDOut && IsPrimPlugin ? "709-2020" : \
          IsHDSource && IsUHDOut ? "none" : \
          IsUHDSource && IsSDOut && IsPrimPlugin ? "2020-601P" : \
          IsUHDSource && IsSDOut ? "none" : \
          IsUHDSource && IsHDOut && IsPrimPlugin ? "2020-709" : \
          IsUHDSource && IsHDOut ? "none" : ""

        Assert((CM != "none"), A1 + "Automatic color conversion is enabled" + \
          A2 + " but an appropriate conversion can't be found." + \
          A2 + " Try specifying a conversion with the ColorMode argument." + A2)

        CM = (CM == "none") ? "" : CM
        Is601_709 = (CM == "601-709") || (CM == "709-601")
        Is2020M = (CM == "709-2020M") || (CM == "2020-709M")

        CC = (CC != "") ? CC : (Color_Format == "YV411") ? \
          ((IsDResize || Loaded_DitherTools) && (Is601_709 || Is2020M) ? "DitherTools" : "") : \
          IsZAVSR ? "AVSResize" : \
          IsFMTC ? "FMTConv" : \
          IsDResize && (Is601_709 || Is2020M) ? "DitherTools" : \
          Loaded_AVSResize ? "AVSResize" : \
          Loaded_HDRMatrix && Is601_709 && (Loaded_ConvStack || (Source_Bits == 8)) ? "HDRMatrix" : \
          Loaded_FMTConv ? "FMTConv" : \
          Loaded_DitherTools && (Is601_709 || Is2020M) && (Source_Bits == 8) ? "DitherTools" : \
          Loaded_HDRTools && !Is601_709 && !Is2020M ? "HDRTools" : \
          Loaded_ColorMatrix && \
          Is601_709 && (Source_Bits == 8) && (Color_Format != "YV24") ? "ColorMatrix" : ""

        Assert((CC != ""), \
          A1 + "Unable to find a suitable loaded plugin for " + CM + " color conversion." + \
          A2 + " Try specifying a plugin with the ColorConvert argument." + A2)

# -------------------------------------------------------------------------------

        IsZResize = Z_Specified || (Loaded_AVSResize && !IsResizer && IsZKernel && !IsRingRepair && \
          ((CM == "") || ((CC != "DitherTools") && (CC != "FMTConv"))))

        IsResize8 = R_Specified || (Loaded_Resize8 && !IsResizer && !IsZResize && !IsRingRepair && \
          ((CM == "") || ((CC != "DitherTools") && (CC != "FMTConv"))))

        IsDResize = IsDResize || ((CM != "") && (CC == "DitherTools") && !IsResizer && IsDKernel && \
          !IsZResize && !IsResize8)

        IsFResize = IsFResize || ((CM != "") && (CC == "FMTConv") && !IsResizer && IsFKernel && \
          !IsZResize && !IsResize8 && !IsDResize)

        IsAResize = (IsAKernel || IsResizeAppended) && \
          !IsZResize && !IsResize8 && !IsDResize && !IsFResize && !IsResizeMT

        Kernel = (Orig_Kernel == "Lanczos3") && \
          (IsZResize || IsDResize || IsFResize || IsResizeMT || IsAResize) ? "Lanczos" : \
          (Orig_Kernel == "Lanczos4") && (IsZResize || IsDResize || IsFResize) ? "Lanczos" : Orig_Kernel

        Resizer = IsZResize || IsDResize || IsFResize ? Kernel : IsResize8 ? "Resize8" : \
          IsResizeMT ? Kernel + "ResizeMT" : IsAResize ? Kernel + "Resize" : Resizer

        RTaps = (Orig_Kernel == "Lanczos3") && IsZResize ? ", filter_param_a=3" : \
          (Orig_Kernel == "Lanczos3") && (IsDResize || IsFResize || IsResizeMT || IsAResize) ? ", taps=3" : \
          (Orig_Kernel == "Lanczos4") && IsZResize ? ", filter_param_a=4" : \
          (Orig_Kernel == "Lanczos4") && (IsDResize || IsFResize) ? ", taps=4" : ""

        IsZAVSR = IsZResize || (Resizer == "z_ConvertFormat")
        IsFMTC = IsFResize || (Resizer == "FMTC_Resample")
        IsCPlaceResize = (IsAResize && (AvsBuildNum >= 4273)) || IsResizeMT251 }

    IsColorConversion = (CC != "") && (CM != "")

# ===============================================================================
#            Apply Cropping
# ===============================================================================

    CCL = NoResizing ? NR_CL : ResizeWO ? RWO_CL : FullResizeA ? FRA_CL : FRB_CL
    CCT = NoResizing ? NR_CT : ResizeWO ? RWO_CT : FullResizeA ? FRA_CT : FRB_CT
    CCR = NoResizing ? NR_CR : ResizeWO ? RWO_CR : FullResizeA ? FRA_CR : FRB_CR
    CCB = NoResizing ? NR_CB : ResizeWO ? RWO_CB : FullResizeA ? FRA_CB : FRB_CB

    RCL = NoResizing ? NR_RCL : ResizeWO ? RWO_RCL : FullResizeA ? FRA_RCL : FRB_RCL
    RCT = NoResizing ? NR_RCT : ResizeWO ? RWO_RCT : FullResizeA ? FRA_RCT : FRB_RCT
    RCR = NoResizing ? NR_RCR : ResizeWO ? RWO_RCR : FullResizeA ? FRA_RCR : FRB_RCR
    RCB = NoResizing ? NR_RCB : ResizeWO ? RWO_RCB : FullResizeA ? FRA_RCB : FRB_RCB

    F_Cropped_Width = F_Auto_Cropped_Width - CCL - CCR - RCL - RCR
    F_Cropped_Height = F_Auto_Cropped_Height - CCT - CCB - RCT - RCB

    Cropped = (0 == CCL == CCT == CCR == CCB) ? \
      AutoCroppedSource : AutoCroppedSource.crop(CCL, CCT, -CCR, -CCB)

    NoResizer = NoResizing && \
      (CSplit1 || ((0 == NR_RCL == NR_RCR == NR_RCT == NR_RCB) && (CPlace == "" == CPlaceD)))

    Scaling = F_CRVideo_Width * F_CRVideo_Height / F_Cropped_Width / F_Cropped_Height
    Upscale = (Scaling > 1)

# ===============================================================================
#            Configure RingRepair
# ===============================================================================

    IsRingRepair = IsRingRepair && !IsDResize
    IsDRingRepair = IsRingRepair && IsDResize

    Res_Multi = NoResizing || IsFloat(RingRepair) || !IsRingRepair ? nop() : Upscale ? Scaling : nop()

    Weight = NoResizing || !IsRingRepair ? 0 : IsFloat(RingRepair) ? RingRepair : \
      Upscale ? Spline(min(max(Res_Multi, 1), 2.25), 1, 0, 2.25, 1, 3.5, 0, true) : 0

    Weight = min(max(Weight, 0), 1)

    IsRingRepair = (Weight > 0)

# ===============================================================================
#            Chroma Placement
# ===============================================================================

    PropChroma = propGetAny(Source, "_ChromaLocation")
    PropChroma = defined(PropChroma) && IsInt(PropChroma) ? PropChroma : -1

    Source = (PropChroma == -1) ? Source : \
      (((Color_Format == "YV411") || (Color_Format == "YUY2")) && (PropChroma != 0)) || \
      (!IsChromaSS && (PropChroma != -1)) ? Source.propDelete("_ChromaLocation") : Source

    PropChroma = (PropChroma == -1) ? PropChroma : \
      (((Color_Format == "YV411") || (Color_Format == "YUY2")) && (PropChroma != 0)) || \
      (!IsChromaSS && (PropChroma != -1)) ? -1 : PropChroma

    PChromaLoc = (PropChroma == 0) ? "left" : (PropChroma == 1) ? "center" : \
      (PropChroma == 2) ? "top_left" : (PropChroma == 3) ? "top" : \
      (PropChroma == 4) ? "bottom_left" : (PropChroma == 5) ? "bottom" : ""

    Assert(IsInt(CPlace) || IsString(CPlace), A1 + "CPlace must be an integer or a string" + A2)

    Orig_CPlace = IsInt(CPlace) ? string(CPlace) : CPlace
    Orig_CPlaceD = IsInt(CPlaceD) ? string(CPlaceD) : CPlaceD

    CPlace = (Orig_CPlace == "0") || (Orig_CPlace == "mpeg2") ? "left" : \
      (Orig_CPlace == "1") || (Orig_CPlace == "mpeg1") || (Orig_CPlace == "jpeg") ? "center" : \
      (Orig_CPlace == "2") ? "top_left" : (Orig_CPlace == "3") ? "top" : \
      (Orig_CPlace == "4") ? "bottom_left" : (Orig_CPlace == "5") ? "bottom" : Orig_CPlace

    CPlaceD = (Orig_CPlaceD == "0") || (Orig_CPlaceD == "mpeg2") ? "left" : \
      (Orig_CPlaceD == "1") || (Orig_CPlaceD == "mpeg1") || (Orig_CPlaceD == "jpeg") ? "center" : \
      (Orig_CPlaceD == "2") ? "top_left" : (Orig_CPlaceD == "3") ? "top" : \
      (Orig_CPlaceD == "4") ? "bottom_left" : (Orig_CPlaceD == "5") ? "bottom" : Orig_CPlaceD

    ChromaLocS = !IsChromaSS ? undefined() : \
      (Color_Format == "YV411") || (Color_Format == "YUY2") ? "left" : \
      (CPlace != "") ? CPlace : (PChromaLoc != "") ? PChromaLoc : "left"

    ChromaLocD = !IsChromaSS ? undefined() : \
      (Color_Format == "YV411") || (Color_Format == "YUY2") ? "left" : \
      (CPlaceD != "") ? CPlaceD : ChromaLocS

    ZR_CPlaceStr = !defined(ChromaLocS) ? "" : \
      """, chromaloc_op="""" + ChromaLocS + "=>" + ChromaLocD + """""""

    DT_ChromaLocS = !defined(ChromaLocS) ? undefined() : \
      (ChromaLocS == "left") ? "mpeg2" : (ChromaLocS == "center") ? "mpeg1" : ChromaLocS

    DT_ChromaLocD = !defined(ChromaLocD) ? undefined() : \
      (ChromaLocD == "left") ? "mpeg2" : (ChromaLocD == "center") ? "mpeg1" : ChromaLocD

    ChromaIntD = !defined(ChromaLocD) ? -1 : (ChromaLocD == "left") ? 0 : \
      (ChromaLocD == "center") ? 1 : (ChromaLocD == "top_left") ? 2 : (ChromaLocD == "top") ? 3 : \
      (ChromaLocD == "bottom_left") ? 4 : (ChromaLocD == "bottom") ? 5 : -1

    FProp_ChromaD = (ChromaIntD == -1) ? "" : """.propSet("_ChromaLocation", ChromaIntD)"""

# -------------------------------------------------------------------------------

    Sizer = NoResizer ? "" : IsZAVSR ? "AVSResize" : \
      IsDResize ? "Dithertools" : IsFMTC ? "FMTConv" : IsResize8 ? "Resize8" : ""
    CSizer = Sizer + " (currently resizing)" + A2
    CPlugin = ((CC == "AVSResize") || (CC == "DitherTools") || (CC == "FMTConv") || (CC == "HDRTools")) && \
      (CM != "") ? CC : ""
    CCPlugin = CC + " (currently color converting)" + A2

    CP_0to1 = (CPlace == "") || (CPlace == "left") || (CPlace == "center")
    CP_0to2 = CP_0to1 || (CPlace == "top_left")
    CPD_0to1 = (CPlaceD == "") || (CPlaceD == "left") || (CPlaceD == "center")
    CPD_0to2 = CPD_0to1 || (CPlaceD == "top_left")
    Not_CP = " is not a supported chroma placement" + A2
    CP_Of = A1 + """A CPlace of """" + Orig_CPlace + """""""
    CPD_of = A1 + """A CPlaceD of """" + Orig_CPlaceD + """""""
    FP_CL = A1 + "The chroma location in frame properties (" + string(PropChroma) + ")" + A2
    FP_OR = " however the chroma placement can be over-ridden" + A2 + \
      " with the CPlace argument if necessary" + A2

    Assert((CPlace == "" == CPlaceD) || \
      (!NoResizer && (IsCPlaceResize || IsZAVSR || IsDResize || IsFMTC || IsResize8)) || ((CM != "") && \
      ((CC == "AVSResize") || (CC == "DitherTools") || (CC == "FMTConv") || (CC == "HDRTools"))), \
      A1 + "The CPlace and CPlaceD arguments can only be used when:" + \
      A2 + " Resizing with an Avisynth+ resizer (version >= 3.7.4)" + \
      A2 + " Resizing with ResampleMT (version >= 2.5.1)" + \
      A2 + " Resizing with the Resize8 function" + \
      A2 + " Resizing or color converting with AVSResize, DitherTools or FMTConv" + \
      A2 + " Color converting with HDRTools" + A2)
    Assert(CP_0to2 || (CPlace == "top") || (CPlace == "bottom_left") || (CPlace == "bottom"), \
      CP_Of + Not_CP)
    Assert(CPD_0to2 || (CPlaceD == "top") || (CPlaceD == "bottom_left") || (CPlaceD == "bottom"), \
      CPD_of + Not_CP)
    Assert((CPlace != "") || (-1 <= PropChroma <= 5), FP_CL + Not_CP + FP_OR)
    Assert((Sizer == "") || ((!IsDResize || CP_0to1) && (!IsFMTC || CP_0to2)), \
      CP_Of + " is not supported by " + CSizer)
    Assert((Sizer == "") || ((!IsDResize || CPD_0to1) && (!IsFMTC || CPD_0to2)), \
      CPD_of + " is not supported by " + CSizer)
    Assert((Sizer == "") || (CPlace != "") || ((!IsDResize || (PropChroma <= 1)) && \
      (!IsFMTC || (PropChroma <= 2))), FP_CL + " is not supported by " + CSizer + FP_OR)
    Assert((CPlugin == "") || (((CC != "DitherTools") || CP_0to1) && ((CC != "FMTConv") || CP_0to2)), \
      CP_Of + " is not supported by " + CCPlugin)
    Assert((CPlugin == "") || (((CC != "DitherTools") || CPD_0to1) && ((CC != "FMTConv") || CPD_0to2)), \
      CPD_of + " is not supported by " + CCPlugin)
    Assert((CPlugin == "") || (CPlace != "") || (((CC != "DitherTools") || (PropChroma <= 1)) && \
      ((CC != "FMTConv") || (PropChroma <= 2))), FP_CL + " is not supported by " + CCPlugin + FP_OR)

# ===============================================================================
#            Resize / Color Convert
# ===============================================================================

    Cropped_CPlace = (ChromaIntD == -1) || NoResizer || !IsCPlaceResize ? Cropped : \
      defined(ChromaLocS) && defined(ChromaLocD) && (ChromaLocS == ChromaLocD) ? \
      Eval("Cropped" + FProp_ChromaD) : \
      Is420(Source) ? \
      Cropped.ConvertToYUV420(ChromaInPlacement=ChromaLocS, ChromaOutPlacement=ChromaLocD) : \
      Cropped.ConvertToYUV422(ChromaInPlacement=ChromaLocS, ChromaOutPlacement=ChromaLocD)

# -------------------------------------------------------------------------------

    DoResize = IsCPlaceResize ? \
      "." + Resizer + "(CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, " + \
      "src_width=F_Cropped_Width, src_height=F_Cropped_Height, placement=ChromaLocD" + \
      RTaps + ResStr + ")" : \
      IsZResize ? \
      ".z_ConvertFormat(CRVideo_Width, CRVideo_Height, " + \
      "src_left=RCL, src_top=RCT, src_width=F_Cropped_Width, src_height=F_Cropped_Height, " + \
      "resample_filter=Resizer" + ZR_CPlaceStr + RTaps + ResStr + ")" : \
      IsZAVSR ? \
      "." + Resizer + "(CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, " + \
      "src_width=F_Cropped_Width, src_height=F_Cropped_Height" + ZR_CPlaceStr + ResStr + ")" : \
      IsDResize ? \
      ".Dither_convert_8_to_16().Dither_resize16" + (!IsDRingRepair ? "" : "nr") + \
      "(CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, " + \
      "src_width=F_Cropped_Width, src_height=F_Cropped_Height, kernel=Resizer, cplaces=DT_ChromaLocS, " + \
      "cplaced=DT_ChromaLocD" + RTaps + ResStr + ").DitherPost(mode=6, slice=false)" + FProp_ChromaD : \
      IsFResize ? \
      ".fmtc_resample(CRVideo_Width, CRVideo_Height, sx=RCL, sy=RCT, sw=F_Cropped_Width, " + \
      "sh=F_Cropped_Height, kernel=Resizer, cplaces=ChromaLocS, cplaced=ChromaLocD" + \
      RTaps + ResStr + ")" : \
      IsFMTC ? \
      "." + Resizer + "(CRVideo_Width, CRVideo_Height, sx=RCL, sy=RCT, sw=F_Cropped_Width, " + \
      "sh=F_Cropped_Height, cplaces=ChromaLocS, cplaced=ChromaLocD" + ResStr + ")" : \
      IsResize8 ? \
      ".Resize8(CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, src_width=F_Cropped_Width, " + \
      "src_height=F_Cropped_Height, cplace=ChromaLocS, cplaced=ChromaLocD" + ResStr + ")" : \
      "." + Resizer + "(CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, " + \
      "src_width=F_Cropped_Width, src_height=F_Cropped_Height" + RTaps + ResStr + ")"

# -------------------------------------------------------------------------------
#            Resize Without Color Conversion
# -------------------------------------------------------------------------------

    if (!IsColorConversion) {

        ToHBD = NoResizer || (!IsZAVSR && !IsFMTC) || ((Source_Bits == 32) && IsFullRange) ? "" : \
          (Source_Bits == 32) ? ".ConvertBits(32, fulls=IsFullRange, fulld=true)" : \
          IsFMTC && (Source_Bits < 16) ? ".ConvertBits(16, fulls=IsFullRange, fulld=IsFullRange)" : ""

        FromHBD = NoResizer || (!IsZAVSR && !IsFMTC) || ((Source_Bits == 32) && IsFullRange) ? "" : \
          (Source_Bits == 32) ? ".ConvertBits(32, fulls=true, fulld=IsFullRange)" : \
          IsFMTC && (Source_Bits < 16) ? \
          ".ConvertBits(Source_Bits, fulls=IsFullRange, fulld=IsFullRange, dither=1)" : ""

        Cropped = NoResizer ? Cropped : \
          (Color_Format == "YUY2") && (IsRingRepair || IsZAVSR || IsDResize || IsFMTC) ? \
          Cropped.ConvertToYV16() : \
          IsPackedRGB(Source) && (IsRingRepair || IsZAVSR || IsFMTC) ? \
          (HasAlpha(Source) ? Cropped.ConvertToPlanarRGBA() : Cropped.ConvertToPlanarRGB()) : \
          Cropped_CPlace

        Cropped = NoResizer ? Cropped : Eval("Cropped" + ToHBD)

        CRVideo = NoResizer ? Cropped : !IsRingRepair ? Eval("Cropped" + DoResize + FromHBD) : \
          Eval("Cropped" + DoResize + \
          ".CR_RingRepair(Cropped, CRVideo_Width, CRVideo_Height, RCL, RCT, " + \
          "F_Cropped_Width, F_Cropped_Height, IsCPlaceResize, IsFMTC, IsResizeMT, " + \
          "ChromaLocS, ChromaLocD, Weight)" + FromHBD)

        CRVideo = NoResizer ? CRVideo : \
          (Color_Format == "YUY2") && (IsRingRepair || IsZAVSR || IsDResize || IsFMTC) ? \
          CRVideo.ConvertToYUY2() : \
          IsPackedRGB(Source) && (IsRingRepair || IsZAVSR || IsFMTC) ? \
          (IsRGB64(Source) ? CRVideo.ConvertToRGB64() : IsRGB48(Source) ? CRVideo.ConvertToRGB48() : \
          IsRGB32(Source) ? CRVideo.ConvertToRGB32() : CRVideo.ConvertToRGB24()) : CRVideo }

    else {

# -------------------------------------------------------------------------------
#            Resize & Color Convert
# -------------------------------------------------------------------------------

        CRVideo = CR_ColorConvertResize(Cropped, CRVideo_Width, CRVideo_Height, RCL, RCT, \
          F_Cropped_Width, F_Cropped_Height, A1, A2, Source_Bits, Loaded_ConvStack, CC, CM, \
          Is601_709, Is2020M, Color_Format, PropMatrix, PropTrans, PropPrim, PropRange, PropChroma, \
          IsChromaSS, ChromaLocS, ChromaLocD, ZR_CPlaceStr, DT_ChromaLocS, DT_ChromaLocD, ChromaIntD, \
          FProp_ChromaD, IsFullRange, IsRingRepair, IsDRingRepair, Weight, NoResizer, DoResize, \
          Resizer, ResStr, RTaps, Upscale, Cropped_CPlace, IsCPlaceResize, IsZResize, IsZAVSR, \
          IsDResize, IsFMTC, IsResize8, IsResizeMT) }

# ===============================================================================
#            Add Borders As Required
# ===============================================================================

    if (IsBordered && ((Final_Width > CRVideo_Width) || (Final_Height > CRVideo_Height))) {

        Additional_Width = Final_Width - CRVideo_Width
        F_WidthSplit = float(Additional_Width) / 2.0

        BL = round(max(0, ((Additional_Width % (WidthMod * 2)) == 0) ? Additional_Width / 2 : \
          (CL > CR) ? \
          min(Additional_Width, F_WidthSplit + F_WidthMod - fmod(F_WidthSplit, F_WidthMod)) : \
          F_WidthSplit - fmod(F_WidthSplit, F_WidthMod)))

        BR = Additional_Width - BL

        Additional_Height = Final_Height - CRVideo_Height
        F_HeightSplit = float(Additional_Height) / 2.0

        BT = round(max(0, ((Additional_Height % (HeightMod * 2)) == 0) ? Additional_Height / 2 : \
          (CT > CB) ? \
          min(Additional_Height, F_HeightSplit + F_HeightMod - fmod(F_HeightSplit, F_HeightMod)) : \
          F_HeightSplit - fmod(F_HeightSplit, F_HeightMod)))

        BB = Additional_Height - BT

        Frosty = Frosty && \
          (((BL > WidthMod < BR) && ((BL + BR) >= (BT + BB))) || \
          ((BT > HeightMod < BB) && ((BL + BR) < (BT + BB))))

        FrostyStr = !Frosty ? "" : (BL + BR) >= (BT + BB) ? \
          "CRVideo.CR_FrostyBorders(CRVideo_Width, CRVideo_Height, " + \
          "F_CRVideo_Width, F_CRVideo_Height, BL, 0, BR, 0, WidthMod, HeightMod, " + \
          "F_WidthMod, F_HeightMod, CRVideo_StorageAR, Final_StorageAR, " + \
          "IsResizeMT, Source_Bits, Scale, IsFullRange)" : \
          "CRVideo.CR_FrostyBorders(CRVideo_Width, CRVideo_Height, " + \
          "F_CRVideo_Width, F_CRVideo_Height, 0, BT, 0, BB, WidthMod, HeightMod, " + \
          "F_WidthMod, F_HeightMod, CRVideo_StorageAR, Final_StorageAR, " + \
          "IsResizeMT, Source_Bits, Scale, IsFullRange)"

        All_BordersStr = (AvsBuildNum > 4246) || !BBlur ? \
          ".AddBorders(BL, BT, BR, BB, color=BColor)" : \
          ".AddBorders(BL, BT, BR, BB, color=BColor, r=max(2,max(WidthMod,HeightMod)))"

        TB_BordersStr = (AvsBuildNum > 4246) || !BBlur ? \
          ".AddBorders(0, BT, 0, BB, color=BColor)" : \
          ".AddBorders(0, BT, 0, BB, color=BColor, r=max(2,HeightMod))"

        LR_BordersStr = (AvsBuildNum > 4246) || !BBlur ? \
          ".AddBorders(BL, 0, BR, 0, color=BColor)" : \
          ".AddBorders(BL, 0, BR, 0, color=BColor, r=max(2,WidthMod))"

        CRVideo = (0 == BL == BT == BR == BB) ? CRVideo : \
          !Frosty ? Eval("CRVideo" + All_BordersStr) : \
          (0 == BT == BB) || (0 == BL == BR) ? Eval(FrostyStr) : \
          (BL + BR) >= (BT + BB) ? Eval(FrostyStr + TB_BordersStr) : \
          Eval(FrostyStr + LR_BordersStr) }

    else { BL=0   BT=0   BR=0   BB=0 }

# ===============================================================================
#            MeGUI Global Aspect Ratios
# ===============================================================================

    if (CR_MeGUI_Support()) {

        MInDARX = IsMInDAR ? MeGUI_darx : 0
        MInDARY = IsMInDAR ? MeGUI_dary : 0
        global gMPassDAR = IsMInDAR ? MInDAR : IsMPassThru ? MPassDAR : 0.0
        global gMPassDARX = IsMInDAR ? MeGUI_darx : IsMPassThru ? gMPassDARX : 0
        global gMPassDARY = IsMInDAR ? MeGUI_dary : IsMPassThru ? gMPassDARY : 0

        global MeGUI_darx = !IsAnamorphicOutput ? undefined() : \
          NoResizing && (Source_Width == Final_Width) && (Source_Height == Final_Height) ? \
          (IsMInDAR ? MeGUI_darx : IsMPassThru ? gMPassDARX : \
          ContinuedNumerator(Final_DAR, limit=10000)) : \
          ContinuedNumerator(Final_DAR, limit=10000)

        global MeGUI_dary = !IsAnamorphicOutput ? undefined() : \
          NoResizing && (Source_Width == Final_Width) && (Source_Height == Final_Height) ? \
          (IsMInDAR ? MeGUI_dary : IsMPassThru ? gMPassDARY : \
          ContinuedDenominator(Final_DAR, limit=10000)) : \
          ContinuedDenominator(Final_DAR, limit=10000) }

# ===============================================================================
#            RMode
# ===============================================================================

    Try{ F_gPriorWidth=float(gPriorWidth)  F_gPriorHeight=float(gPriorHeight)  IsPriorWidthHeight=true }
    Catch(err){ IsPriorWidthHeight=false }

    if (RMode) {

        global gPriorWidth = IsAutoCPreview || IsGAutoCPreview ? Source_Width : \
          IsScriptCPreview ? Auto_Cropped_Width : Final_Width
        global gPriorHeight = IsAutoCPreview || IsGAutoCPreview ? Source_Height : \
          IsScriptCPreview ? Auto_Cropped_Height : Final_Height }

    IsCommonResizing = IsPriorWidthHeight && (((IsAutoCPreview || IsGAutoCPreview) && \
      ((Source_Width != gPriorWidth) || (Source_Height != gPriorHeight))) || \
      (IsScriptCPreview && ((Auto_Cropped_Width != gPriorWidth) || \
      (Auto_Cropped_Height != gPriorHeight))) || \
      (!IsScriptCPreview && !IsAutoCPreview && !IsGAutoCPreview && \
      ((Final_Width != gPriorWidth) || (Final_Height != gPriorHeight))))

# ===============================================================================
#            Cropping Previews
# ===============================================================================

# -------------------------------------------------------------------------------
#            AutoC Preview
# -------------------------------------------------------------------------------

    if (IsAutoCPreview) {

        AutoCPreviewVideo = \
          Source.autocrop(mode=1, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
          threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0) }

# -------------------------------------------------------------------------------
#            For Info & Script Cropping Previews
# -------------------------------------------------------------------------------

    if (Info || IsScriptCPreview) {

        Cropped_Resolution_Text = \
          NoResizing ? CR_FS(F_NR_Cropped_Width) + " x " + CR_FS(F_NR_Cropped_Height) : \
          ResizeWO ? CR_FS(F_RWO_Cropped_Width) + " x " + CR_FS(F_RWO_Cropped_Height) : \
          FullResizeA ? CR_FS(F_FRA_Cropped_Width) + " x " + CR_FS(F_FRA_Cropped_Height) : \
          CR_FS(F_FRB_Cropped_Width) + " x " + CR_FS(F_FRB_Cropped_Height)

        Extra_CL = \
          NoResizing ? (CSplit1 ? F_NR_Extra_CL : F_NR_Extra_Crop_LR) : \
          ResizeWO ? F_RWO_Extra_Crop_LR : FullResizeA ? F_FRA_Extra_Crop_LR : F_FRB_Extra_Crop_LR
        Extra_CT = \
          NoResizing ? (CSplit1 ? F_NR_Extra_CT : F_NR_Extra_Crop_TB) : \
          ResizeWO ? (CSplit1 ? F_RWO_Extra_CT : F_RWO_Extra_Crop_TB) : \
          FullResizeA ? F_FRA_Extra_Crop_T : F_FRB_Extra_Crop_T
        Extra_CR = \
          NoResizing ? (CSplit1 ? F_NR_Extra_CR : F_NR_Extra_Crop_LR) : \
          ResizeWO ? F_RWO_Extra_Crop_LR : FullResizeA ? F_FRA_Extra_Crop_LR : F_FRB_Extra_Crop_LR
        Extra_CB = \
          NoResizing ? (CSplit1 ? F_NR_Extra_CB : F_NR_Extra_Crop_TB) : \
          ResizeWO ? (CSplit1 ? F_RWO_Extra_CB : F_RWO_Extra_Crop_TB) : \
          FullResizeA ? F_FRA_Extra_Crop_B : F_FRB_Extra_Crop_B

        InDAR_Text = IsMInDAR ? string(MInDARX, "  (%.0f:") + string(MInDARY, "%.0f)") : \
          IsMPassedThru ? string(gMPassDARX, "  (%.0f:") + string(gMPassDARY, "%.0f)") : \
          CR_FTF(Source_DAR)

        PropSAR_Text = string(PropNum, "  (%.0f:") + string(PropDen, "%.0f)")

        Total_CL = CL + Extra_CL
        Total_CT = CT + Extra_CT
        Total_CR = CR + Extra_CR
        Total_CB = CB + Extra_CB }

# -------------------------------------------------------------------------------
#            For Script Cropping Previews
# -------------------------------------------------------------------------------

    if (IsScriptCPreview && (1 <= CPreview <= 3) && !Info) {

        SCP_Source = \
          "Source\n" + string(Source_Width, "%.0f x ") + string(Source_Height, "%.0f") + \
          CR_PicMod(Source_Width, Source_Height) + \
          "\nDAR  " + CR_FS(Source_DAR, 5, true) + InDAR_Text + "\nSAR  " + \
          CR_FS(Source_SAR, 5, true) + \
          (!IsPropSAR ? CR_FTF(Source_SAR) : PropSAR_Text) + (!IsAutoC ? "" : \
          string(Auto_Cropped_Width, "\n\nAuto Cropped Resolution\n%.0f x ") + \
          string(Auto_Cropped_Height,"%.0f"))

        SCP_SpecifiedC = (!IsAutoC ? "" : "\n\n\n") + \
          "\n\n\n\n\nSpecified Cropping" + (!IsAutoC ? "" : " (After AutoC)") + \
          "\n(" + CR_FS(CL) + ",  " + CR_FS(CT) + ",  " + CR_FS(-CR) + ",  " + CR_FS(-CB) + ")"

        SCP_TotalC = (!IsAutoC ? "" : "\n\n\n") + \
          "\n\n\n\n\n\n\nTotal Cropping" + (!IsAutoC ? "" : " (After AutoC)") + \
          "\n(" + CR_FS(Total_CL) + ",  " + CR_FS(Total_CT) + ",  " + \
          CR_FS(-Total_CR) + ",  " + CR_FS(-Total_CB) + ")"

        SCP_Output = "\n\n\n\n\n\n\nCropped Resolution\n" + Cropped_Resolution_Text + \
          "\n\nOutput" + (!IsBordered ? "\n" : "  (Exc Borders)\n") + \
          string(CRVideo_Width, "%.0f x ") + string(CRVideo_Height, "%.0f") + \
          CR_PicMod(CRVideo_Width, CRVideo_Height) + \
          "\nDAR  " + CR_FS(CRVideo_DAR, 5, true) + (NoResizing && \
          (Final_Width == Source_Width) && (Final_Height == Source_Height) ? InDAR_Text : \
          CR_FTF(CRVideo_DAR)) + "\nSAR  " + CR_FS(Final_SAR, 5, true) + \
          (!NoResizing || !IsPropSAR ? CR_FTF(Final_SAR) : PropSAR_Text) }

# -------------------------------------------------------------------------------
#            Script Cropping Previews
# -------------------------------------------------------------------------------

    if (IsScriptCPreview) {

        SCP_W = !IsCommonResizing ? F_Auto_Cropped_Width : F_gPriorWidth
        SCP_H = !IsCommonResizing ? F_Auto_Cropped_Height : F_gPriorHeight
        SCP_Color1 = FullResizing ? $FFFFE0 : $F0FFFF
        SCP_Color2 = FullResizing ? $F0FFFF : $FFFFE0

        SCP_Mode_Text = !IsGModeText && !IsCommonResizing ? "" : \
          (!IsGModeText ? "" : GModeText) + (!IsCommonResizing ? "" : (!IsGModeText ? "" : "\n") + \
          string(gPriorWidth, "RMode   CPreview resized to %.0f x ") + string(gPriorHeight, "%.0f"))

        SCP_Size = min(SCP_W * 0.0215, SCP_H * ((SCP_H < 300) ? (IsAutoC ? 0.0285 : 0.0345) : \
          (SCP_H < 400) ? (IsAutoC ? 0.03 : 0.036) : (SCP_H < 500) ? (IsAutoC ? 0.0276 : 0.0335) : \
          (SCP_H < 600) ? (IsAutoC ? 0.0286 : 0.0342) : (SCP_H < 1100) ? (IsAutoC ? 0.0277 : 0.0335) : \
          (SCP_H < 1600) ? (IsAutoC ? 0.0277 : 0.033) : (SCP_H < 1800) ? (IsAutoC ? 0.027 : 0.032) : \
          (SCP_H < 2180) ? (IsAutoC ? 0.026 : 0.031) : IsAutoC ? 0.0255 : 0.03))

        SCP_Y1 = SCP_H * ((SCP_H < 400) ? 0.165 : (SCP_H < 500) ? 0.1735 : \
          (SCP_H < 600) ? 0.1745 : (SCP_H < 1100) ? 0.174 : (SCP_H < 1600) ? 0.195 : \
          (SCP_H < 1800) ? 0.21 : (SCP_H < 2180) ? 0.222 : 0.233)

        SCP_Y2 = (Source_Height < 400) ? SCP_Size / 1.5 : SCP_Size
        SCP_LSP = (SCP_H < 400) ? 8 : (SCP_H < 600) ? 16 : 24

        SCP_Chroma = !IsChromaSS || (PChromaLoc == "") ? undefined() : PChromaLoc

        AutoCropped444 = !IsChromaSS ? AutoCroppedSource : ConvertToYUV444(AutoCroppedSource)

        PL = round(CL)
        PT = round(CT)
        PR = round(CR)
        PB = round(CB)

        CLineL = min(PL, CLine)
        CLineT = min(PT, CLine)
        CLineR = min(PR, CLine)
        CLineB = min(PB, CLine)

        ScriptCL = (round(Total_CL) > PL) ? round(Total_CL) : 0
        ScriptCT = (round(Total_CT) > PT) ? round(Total_CT) : 0
        ScriptCR = (round(Total_CR) > PR) ? round(Total_CR) : 0
        ScriptCB = (round(Total_CB) > PB) ? round(Total_CB) : 0

        SLineL = min(ScriptCL, CLine)
        SLineT = min(ScriptCT, CLine)
        SLineR = min(ScriptCR, CLine)
        SLineB = min(ScriptCB, CLine)

        BlankClipA = "BlankClip(AutoCropped444)"
        BlankClipB = "BlankClip(AutoCropped444, color=$FFFFFF)"

        CroppingA = ".Crop(ScriptCL, ScriptCT, -ScriptCR, -ScriptCB)"
        CroppingB = ".Crop(PL, PT, -PR, -PB)"

        BordersA = ".AddBorders(SLineL, SLineT, SLineR, SLineB"
        BordersB = ".AddBorders(ScriptCL-SLineL, ScriptCT-SLineT, ScriptCR-SLineR, ScriptCB-SLineB)"
        BordersC = ".AddBorders(CLineL, CLineT, CLineR, CLineB"
        BordersD = ".AddBorders(PL-CLineL, PT-CLineT, PR-CLineR, PB-CLineB)"
        BordersE = ".AddBorders(ScriptCL, ScriptCT, ScriptCR, ScriptCB"
        BordersF = ".AddBorders(PL, PT, PR, PB"

        OverlayVideo = (CPreview == 1) || (CPreview == 4) ? \
          Eval(BlankClipA + CroppingA + BordersA + ", color=$ADD8E6)" + \
          BordersB + CroppingB + BordersC + ", color=$FFFF00)" + BordersD) : \
          (CPreview == 2) || (CPreview == 5) ? \
          Eval(BlankClipA + CroppingA + BordersE + ", color=$ADD8E6)" + \
          CroppingB + BordersF + ", color=$FFFF00)") : \
          Eval("AutoCropped444" + CroppingA + \
          BordersE + ", color=$FF0000)" + CroppingB + BordersF + ")")

        MaskVideo = (CPreview == 1) || (CPreview == 4) ? \
          Eval(BlankClipA + CroppingA + BordersA + ", color=$FFFFFF)" + \
          BordersB + CroppingB + BordersC + ", color=$E4E4E4)" + BordersD) : \
          (CPreview == 2) || (CPreview == 5) ? \
          Eval(BlankClipA + CroppingA + BordersE + ", color=$7F7F7F)" + \
          CroppingB + BordersF + ", color=$4B4B4B)") : \
          Eval(BlankClipB + CroppingA + \
          BordersE + ", color=$4B4B4B)" + CroppingB + BordersF + ")")

        MaskVideo = IsFullRange ? MaskVideo : !IsRGBSource ? MaskVideo.ColorYUV(Levels="TV->PC") : \
        MaskVideo.Levels(16*Scale, 1.0, 235*Scale, 0, 255*Scale, coring=false)

        ScriptCPreviewVideo = (CPreview != 3) && (CPreview != 6) ? \
          Overlay(AutoCropped444, OverlayVideo, mask=MaskVideo) : \
          Overlay(invert(AutoCropped444), OverlayVideo, mask=MaskVideo)

        ScriptCPreviewVideo = !IsCommonResizing ? ScriptCPreviewVideo : \
          ScriptCPreviewVideo.Spline36Resize(gPriorWidth, gPriorHeight)

        ScriptCPreviewVideo = \
          (CPreview == 1) || (CPreview == 4) || !IsChromaSS ? ScriptCPreviewVideo : \
          (Color_Format == "YUY2") ? ConvertToYUY2(ScriptCPreviewVideo) : \
          (Color_Format == "YV411") ? ConvertToYV411(ScriptCPreviewVideo) : \
          Is420(Source) ? ConvertToYUV420(ScriptCPreviewVideo, ChromaOutPlacement=SCP_Chroma) : \
          Is422(Source) ? ConvertToYUV422(ScriptCPreviewVideo, ChromaOutPlacement=SCP_Chroma) : \
          ScriptCPreviewVideo

        ScriptCPreviewVideo = Info || (4 <= CPreview <= 6) ? ScriptCPreviewVideo : \
          ScriptCPreviewVideo.subtitle(SCP_Source + SCP_Output, \
          y=SCP_Y1, size=SCP_Size, text_color=SCP_Color1, align=8, lsp=SCP_LSP)\
          .subtitle(SCP_SpecifiedC, y=SCP_Y1, size=SCP_Size, text_color=$F0E68C, align=8, lsp=SCP_LSP)\
          .subtitle(SCP_TotalC, y=SCP_Y1, size=SCP_Size, text_color=$B0C4DE, align=8, lsp=SCP_LSP)

        ScriptCPreviewVideo = Info || !Position ? ScriptCPreviewVideo : \
          ScriptCPreviewVideo.CR_Position(Y=SCP_Y2, Size=SCP_Size, Color=SCP_Color2, Align=8, lsp=SCP_LSP)

        ScriptCPreviewVideo = Info || (SCP_Mode_Text == "") ? ScriptCPreviewVideo : \
          ScriptCPreviewVideo.subtitle(SCP_Mode_Text, y=SCP_H-SCP_Y2, size=SCP_Size, \
          text_color=SCP_Color2, align=2, lsp=SCP_LSP) }

# ===============================================================================
#            Display Info
# ===============================================================================

    if (Info) {

        InfoVideo = IsScriptCPreview ? ScriptCPreviewVideo : \
          !IsCommonResizing ? CRVideo : CRVideo.Spline36Resize(gPriorWidth, gPriorHeight)

        I_D = "\nDisplay Aspect Ratio   "
        I_S = "\nSample Aspect Ratio   "
        I_St = "\nStorage Aspect Ratio   "

# -------------------------------------------------------------------------------
#            Left Column
# -------------------------------------------------------------------------------

        I_AvsVersion = !CR_Info_Formatted_AVS_Version() || !IsAvsPlus ? VersionString() : \
          "AviSynth+  " + MidStr(AvsStr, 11, NumA-14) + string(AvsBuildNum, "  (%.0f)") + \
          ((FindStr(AvsStr, "x86_64") > 0) || (FindStr(AvsStr, "x86-64") > 0) || \
          (FindStr(AvsStr, "x64") > 0) || (FindStr(AvsStr, "amd64") > 0) ? "  64 bit" : \
          (FindStr(AvsStr, "i386") > 0) || (FindStr(AvsStr, "x86") > 0) ? "  32 bit" : "")

        I_FRateNum = FrameRateNumerator(Source)
        I_FRateDen = FrameRateDenominator(Source)
        I_FRate = float(I_FRateNum) / float(I_FRateDen)

        I_Source = string(Source_Width, "\nSource Resolution   %.0f x ") + string(Source_Height, "%.0f") + \
          CR_PicMod(Source_Width, Source_Height) + I_St + CR_FS(Source_StorageAR, 5, true) + \
          CR_FTF(Source_StorageAR) + I_D + CR_FS(Source_DAR, 5, true) + InDAR_Text + \
          string(Source_Bits, "\n%.0f bit   ") + Color_Format + "   " + CR_FS(I_FRate, 4) + " fps" + \
          (CR_IsEqual(round(I_FRate), I_FRate) ? CR_FTF(round(I_FRate), 2) : \
          string(I_FRateNum, "  (%.0f / ") + string(I_FRateDen, "%.0f)"))

        I_AutoC = !IsAutoC ? "" : \
          string(Auto_Cropped_Width, "\n\nAuto Cropped Resolution   %.0f x ") + \
          string(Auto_Cropped_Height, "%.0f") + \
          I_St + CR_FS(Auto_Cropped_StorageAR, 5, true) + CR_FTF(Auto_Cropped_StorageAR) + \
          I_D + CR_FS(Auto_Cropped_DAR, 5, true) + (NoResizing && (Auto_Cropped_Width == Source_Width) && \
          (Auto_Cropped_Height == Source_Height) ? InDAR_Text : CR_FTF(Auto_Cropped_DAR))

        I_SpecifiedC = "\n\nSpecified Cropping\n(" + CR_FS(CL) + ",  " + \
          CR_FS(CT) + ",  " + CR_FS(-CR) + ",  " + CR_FS(-CB) + ")"

        I_ExtraC = "\nAdditional Script Cropping\n(" + CR_FS(Extra_CL) + ",  " + \
          CR_FS(Extra_CT) + ",  " + CR_FS(-Extra_CR) + ",  " + CR_FS(-Extra_CB) + ")"

        I_CSplit_Crop = NoResizer ? "" : "\n\nCrop (" + CR_FS(CCL) + ",  " + \
          CR_FS(CCT) + ",  " + CR_FS(-CCR) + ",  " + CR_FS(-CCB) + ")"

        I_CSplit_Resizer = NoResizer ? "" : "\nResizer Cropping\n(" + CR_FS(RCL) + ",  " + \
          CR_FS(RCT) + ",  " + CR_FS(-RCR) + ",  " + CR_FS(-RCB) + ")"

        I_TotalC = "\nTotal Cropping\n(" + CR_FS(Total_CL) + ",  " + CR_FS(Total_CT) + ",  " + \
          CR_FS(-Total_CR) + ",  " + CR_FS(-Total_CB) + (NoResizer ? ")\n\n\n\n" : ")")

        I_Cropped_Resolution = "\n\nCropped Resolution   " + Cropped_Resolution_Text

        I_Cropped_StorageAR = NoResizing ? NR_Cropped_StorageAR : ResizeWO ? RWO_Cropped_StorageAR : \
        FullResizeA ? FRA_Cropped_StorageAR : FRB_Cropped_StorageAR

        I_Cropped_DAR = NoResizing ? NR_Cropped_DAR : ResizeWO ? RWO_Cropped_DAR : \
          FullResizeA ? FRA_Cropped_DAR : FRB_Cropped_DAR
          I_Cropped_DAR = CR_IsEqual(I_Cropped_DAR, CRVideo_DAR) ? I_Cropped_DAR : CRVideo_DAR

        I_Cropped_ARs = I_St + CR_FS(I_Cropped_StorageAR, 5, true) + CR_FTF(I_Cropped_StorageAR) + \
          I_D + CR_FS(I_Cropped_DAR, 5, true) + (NoResizing && (F_Cropped_Source_Width == Source_Width) && \
          (F_Cropped_Source_Height == Source_Height) ? InDAR_Text : CR_FTF(I_Cropped_DAR))

        I_CRVideo_ARs = CR_PicMod(CRVideo_Width, CRVideo_Height) + \
          I_St + CR_FS(CRVideo_StorageAR, 5, true) + CR_FTF(CRVideo_StorageAR) + \
          I_D + CR_FS(CRVideo_DAR, 5, true) + (NoResizing && (CRVideo_Width == Source_Width) && \
          (CRVideo_Height == Source_Height) ? InDAR_Text : CR_FTF(CRVideo_DAR))

        I_Output = !IsBordered ? \
          string(CRVideo_Width, "\n\nOutput Resolution   %.0f x ") + \
          string(CRVideo_Height, "%.0f") + I_CRVideo_ARs : \
          string(CRVideo_Width, "\n\nOutput Exc Borders   %.0f x ") + \
          string(CRVideo_Height, "%.0f") + I_CRVideo_ARs + \
          string(BL, "\n\nAddBorders (%.0f,  ") + string(BT, "%.0f,  ") + \
          string(BR, "%.0f,  ") + string(BB, "%.0f)") + \
          string(Final_Width, "\nOutput Inc Borders   %.0f x ") + string(Final_Height, "%.0f") + \
          (!IsBordered ? CR_PicMod(CRVideo_Width, CRVideo_Height) : CR_PicMod(Final_Width, Final_Height)) + \
          I_St + CR_FS(Final_StorageAR, 5, true) + CR_FTF(Final_StorageAR) + \
          I_D + CR_FS(Final_DAR, 5, true) + (NoResizing && (Final_Width == Source_Width) && \
          (Final_Height == Source_Height) ? InDAR_Text : CR_FTF(Final_DAR))

        I_Left_Column = I_AvsVersion + I_Source + I_AutoC + I_SpecifiedC + I_ExtraC + I_CSplit_Crop + \
          I_CSplit_Resizer + I_TotalC + I_Cropped_Resolution + I_Cropped_ARs + I_Output

# -------------------------------------------------------------------------------
#            Right Column
# -------------------------------------------------------------------------------

        A_In = AnamorphicInput
        IsA_In = IsAnamorphicInput
        A_Out = AnamorphicOutput
        IsA_Out = IsAnamorphicOutput
        IsB_AutoC = IsBordered && IsAutoC

        IsAutoPicDim = (PicDim > 0) && !IsPicDim
        IsPicDimText = IsPicDim || IsAutoPicDim

        I_NoResizerCrop = NoResizer || (ResizeWO && (CSplit1 || (0 == RWO_RCT == RWO_RCB)))

        I_ResizingMode = "\n" + \
          (CleanBorders ? ("Clean Borders" + (I_NoResizerCrop ? "" : "  (Resampling)")) : \
          NoResizing ? ("No Resizing" + (I_NoResizerCrop ? "" : "  (Resampling)")) : \
          ResizeWO ? ("Resize Width Only" + (I_NoResizerCrop ? "" : "  (Resampling Height)")) : \
          "Full Resizing Mode")

        I_Resizer = NoResizer ? "" : "\nResizer   " + \
          (IsZResize ? "Z_" : IsDResize ? "D_" : IsFResize ? "F_" : "") + Resizer + \
          ((RTaps == ", filter_param_a=3") ? "  (filter_param_a=3)" : \
          (RTaps == ", filter_param_a=4") ? "  (filter_param_a=4)" : \
          (RTaps == ", taps=3") ? "  (taps=3)" : (RTaps == ", taps=4") ? "  (taps=4)" : "")

        I_RSL = StrLen(RStr)
        I_RStr = NoResizer || !IsRStr ? "" : "\n" + ((I_RSL > 35) ? "" : "RStr   ") + RStr

        I_RingRepair = NoResizer ? "" : \
          IsRingRepair || (IsBool(RingRepair) && RingRepair && !IsDRingRepair) ? \
          "\n" + "RingRepair Strength   " + CR_FS(Weight, 4, true) : \
          IsDRingRepair ? "\n" + "DitherTools RingRepair" : ""

        I_Input_ARs = "\n\n\n\n\n\nInput Aspect" + \
          (IsInDAR ? "   InDAR" + I_D + CR_FS(InDAR, 5, true) + CR_FTF(InDAR) + \
          I_S + CR_FS(Source_SAR, 5, true) + CR_FTF(Source_SAR) : \
          IsInSAR ? "   InSAR" + I_D + CR_FS(Source_DAR, 5, true) + CR_FTF(Source_DAR) + \
          I_S + CR_FS(InSAR, 5, true) + CR_FTF(InSAR) : \
          IsGInDAR ? "   Global InDAR" + I_D + CR_FS(GInDAR, 5, true) + CR_FTF(GInDAR) + \
          I_S + CR_FS(Source_SAR, 5, true) + CR_FTF(Source_SAR) : \
          IsGInSAR ? "   Global InSAR" + I_D + CR_FS(Source_DAR, 5, true) + CR_FTF(Source_DAR) + \
          I_S + CR_FS(GInSAR, 5, true) + CR_FTF(GInSAR) : \
          IsMInDAR ? "   MeGUI DAR" + I_D + CR_FS(MInDAR, 5, true) + \
          string(MInDARX, "  (%.0f:") + string(MInDARY, "%.0f)") + \
          I_S + CR_FS(Source_SAR, 5, true) + CR_FTF(Source_SAR) : \
          IsMPassedThru ? "   MeGUI DAR" + I_D + CR_FS(MPassDAR, 5, true) + \
          string(gMPassDARX, "  (%.0f:") + string(gMPassDARY, "%.0f)") + \
          I_S + CR_FS(Source_SAR, 5, true) + CR_FTF(Source_SAR) : \
          IsPropSAR ? "   FrameProps SAR" + \
          I_D + CR_FS(Source_DAR, 5, True) + CR_FTF(Source_DAR) + \
          I_S + CR_FS(PropSAR, 5, True) + PropSAR_Text : "") + \
          (A_In && !IsA_In ? "\nNot Anamorphic" : \
          !A_In && IsPropSAR1 ? "   FrameProps SAR" : !A_In ? "   Not Specified" : "") + \
          (!A_In ? I_S + CR_FS(Source_SAR, 5, true) + CR_FTF(Source_SAR) : "") + \
          (!IsA_In ? "" : "\nDisplay Dimensions   " + CR_FS(F_Source_Display_Width, 2) + \
          string(Source_Height, " x %.0f"))

        I_Output_ARs = "\n\nOutput Aspect" + \
          (NoResizing && IsA_Out && (Final_Width == Source_Width) && (Final_Height == Source_Height) ? \
          I_D + CR_FS(Final_DAR, 5, true) + InDAR_Text + \
          I_S + CR_FS(Final_SAR, 5, true) + (!IsPropSAR ? CR_FTF(Final_SAR) : PropSAR_Text) : \
          NoResizing && IsA_Out ? \
          I_D + CR_FS(Final_DAR, 5, true) + CR_FTF(Final_DAR) + \
          I_S + CR_FS(Final_SAR, 5, true) + (!IsPropSAR ? CR_FTF(Final_SAR) : PropSAR_Text) : \
          IsOutDAR ? "   OutDAR" + I_D + CR_FS(OutDAR, 5, true) + CR_FTF(OutDAR) + \
          I_S + CR_FS(Final_SAR, 5, true) + CR_FTF(Final_SAR) : \
          IsOutSAR ? "   OutSAR" + I_D + CR_FS(Final_DAR, 5, true) + CR_FTF(Final_DAR) + \
          I_S + CR_FS(OutSAR, 5, true) + CR_FTF(OutSAR) : \
          IsGOutDAR ? "   Global OutDAR" + I_D + CR_FS(GOutDAR, 5, true) + CR_FTF(GOutDAR) + \
          I_S + CR_FS(Final_SAR, 5, true) + CR_FTF(Final_SAR) : \
          IsGOutSAR ? "   Global OutSAR" + I_D + CR_FS(Final_DAR, 5, true) + CR_FTF(Final_DAR) + \
          I_S + CR_FS(GOutSAR, 5, true) + CR_FTF(GOutSAR) : "") + \
          (A_Out && !IsA_Out ? "\nNot Anamorphic" : !A_Out ? "   Not Specified" : "") + \
          (!A_Out ? I_S + CR_FS(Final_SAR, 5, true) + CR_FTF(Final_SAR) : "") + \
          (!IsA_Out ? "" : "\nDisplay Dimensions   " + CR_FS(F_Final_Display_Width, 2) + \
          string(Final_Height, " x %.0f"))

        I_MeGUI_DAR = !IsA_Out || !CR_MeGUI_Support() ? "" : \
          string(MeGUI_darx, "\n\nMeGUI_darx=%.0f     ") + string(MeGUI_dary, "MeGUI_dary=%.0f")

        I_PropChromaOut = IsChromaSS ? propGetAny(CRVideo, "_ChromaLocation") : undefined()
        I_PropChromaOut = defined(I_PropChromaOut) && IsInt(I_PropChromaOut) ? I_PropChromaOut : -1

        I_PropChromaOutName = (I_PropChromaOut == 0) ? "left" : \
          (I_PropChromaOut == 1) ? "center" : (I_PropChromaOut == 2) ? "top_left" : \
          (I_PropChromaOut == 3) ? "top" : (I_PropChromaOut == 4) ? "bottom_left" : \
          (I_PropChromaOut == 5) ? "bottom" : (I_PropChromaOut == 6) ? "dv" : ""

        I_IsAny = (!NoResizer && (IsCPlaceResize || IsZAVSR || IsDResize || IsFMTC || IsResize8)) || \
          ((CM != "") && \
          ((CC == "AVSResize") || (CC == "DitherTools") || (CC == "FMTConv") || (CC == "HDRTools")))

        I_ChromaLoc = "\n\n" + (!I_IsAny ? "Source chroma location   " : "Chroma Location   ") + \
          (IsGraySource ? "No Chroma" : !IsChromaSS ? "None (Full Chroma)" : \
          (Color_Format == "YV411") || (Color_Format == "YUY2") ? \
          ((PropChroma == 0) ? PChromaLoc : "left (assumed)") : \
          (CPlace != "") ? CPlace : (PChromaLoc != "") ? PChromaLoc : "left (assumed)") + \
          (!I_IsAny || (I_PropChromaOut == -1) ? "" : " -> " + I_PropChromaOutName)

        I_Cond = (AutoDAR ? 1 : 0) + ((CM != "") ? 2 : (CC != "") ? 1 : 0) + \
          (IsPicDimText ? 1 : 0) + (IsGModeText ? 1 : 0) + (IsCommonResizing ? 1 : 0)

        I_NL3="\n\n\n"
        I_NL4="\n\n\n\n"
        I_NL5="\n\n\n\n\n"
        I_NL6="\n\n\n\n\n\n"
        I_NL7="\n\n\n\n\n\n\n"

        I_LineBreak = I_NL7 + I_NL7 + (IsB_AutoC ? I_NL7 + I_NL3 : \
          IsBordered || (IsAutoC && (I_Cond == 6) && A_In && IsA_Out) ? I_NL6 : \
          IsAutoC ? I_NL5 : Position ? \
          (A_In && IsA_Out ? ((I_Cond == 6) ? I_NL6 : (I_Cond == 5) ? I_NL5 : (I_Cond == 4) ? I_NL4 : \
          (I_Cond == 3) ? I_NL3 : (I_Cond == 2) ? "\n\n" : "\n") : \
          A_In && A_Out ? ((I_Cond == 6) ? I_NL4 : (I_Cond == 5) ? I_NL3 : (I_Cond == 4) ? "\n\n" : "\n") : \
          IsA_Out ? ((I_Cond == 6) ? I_NL4 : (I_Cond == 5) ? I_NL3 : (I_Cond == 4) ? "\n\n" : "\n") : \
          A_Out ? ((I_Cond == 6) ? "\n\n" : "\n") : "\n") : \
          A_In && IsA_Out ? ((I_Cond == 6) ? "\n\n" : (I_Cond == 5) ? "\n" : "") : "")

        I_CConvertLB = (CC == "" == CM) ? "\n\n" : (CM == "") ? "\n" : ""
        I_PicDimLB = !IsPicDimText ? "\n" : ""
        I_GModeLB = !IsGModeText ? "\n" : ""
        I_RModeLB = !IsCommonResizing ? "\n" : ""

        I_PosLB = Position ? "" : IsB_AutoC ? I_NL3 : IsBordered ? I_NL3 : \
          IsAutoC && (I_Cond == 6) && A_In && IsA_Out ? "\n\n" : IsAutoC ? I_NL3 : I_NL4

        I_AutoDARLineBreak = !AutoDAR ? "" : \
          I_LineBreak + I_CConvertLB + I_PicDimLB + I_GModeLB + I_RModeLB + I_PosLB
        I_CConvertLineBreak = (CC == "" == CM) ? "" : \
          I_LineBreak + I_CConvertLB + I_PicDimLB + I_GModeLB + I_RModeLB + I_PosLB + "\n"
        I_PicDimLineBreak = !IsPicDimText ? "" : I_LineBreak + I_GModeLB + I_RModeLB + I_PosLB + I_NL3
        I_GModeLineBreak = !IsGModeText ? "" : I_LineBreak + I_RModeLB + I_PosLB + I_NL4
        I_RModeLineBreak = !IsCommonResizing ? "" : I_LineBreak + I_PosLB + I_NL5

        I_PosLineBreak1 = !Position ? "" : I_LineBreak + I_PosLB + (IsB_AutoC ? I_NL7 : \
          IsBordered ? I_NL7 : IsAutoC && (I_Cond == 6) && A_In && IsA_Out ? I_NL6 : IsAutoC ? I_NL7 : \
          A_In && IsA_Out ? ((I_Cond > 1) ? I_NL6 : I_NL7) : A_In && A_Out ? ((I_Cond > 3) ? I_NL6 : I_NL7) : \
          IsA_Out ? ((I_Cond > 3) ? I_NL6 : I_NL7) : A_Out && (I_Cond > 5) ? I_NL6 : I_NL7)

        I_PosLineBreak2 = !Position ? "" : \
          IsBordered || IsAutoC ? "\n" : (A_In && IsA_Out && (I_Cond > 2)) || \
          (A_In && !IsA_Out && A_Out && (I_Cond > 4)) || (!A_In && IsA_Out && (I_Cond > 4)) ? \
          "      " : "\n"

        I_PreAutoDAR = !IsAutoDAR ? 0.0 : FullResizeA ? \
          (!IsOutputSAR ? F_Resizing_Width / F_FRA_Adjusted_Height1 : \
          F_Resizing_Width * OutputSAR / F_FRA_Adjusted_Height1) : \
          !IsOutputSAR ? \
          F_FRB_Adjusted_Width1 / F_Resizing_Height : F_FRB_Adjusted_Width1 * OutputSAR / F_Resizing_Height

        I_AutoDAR = !AutoDAR ? "" : \
          I_AutoDARLineBreak + "AutoDAR   " + (!IsAutoDAR ? "Not Applicable" : FullResizeA ? \
          (IsHeight169 && (F_FRA_Adjusted_Height1 != F_FRA_Adjusted_Height2) ? \
          string(I_PreAutoDAR, "%.6f -> 16:9") : \
          IsHeight43 && (F_FRA_Adjusted_Height1 != F_FRA_Adjusted_Height2) ? \
          string(I_PreAutoDAR, "%.6f -> 4:3") : \
          IsHeight169 || IsHeight43 ? "Not Required" : "Out Of Range") : \
          IsWidth169 && (F_FRB_Adjusted_Width1 != F_FRB_Adjusted_Width2) ? \
          string(I_PreAutoDAR, "%.6f -> 16:9") : \
          IsWidth43 && (F_FRB_Adjusted_Width1 != F_FRB_Adjusted_Width2) ? \
          string(I_PreAutoDAR, "%.6f -> 4:3") : \
          IsWidth169 || IsWidth43 ? "Not Required" : "Out Of Range")

        I_PropMatrixOut = IsColorConversion ? propGetAny(CRVideo, "_Matrix") : undefined()
        I_PropMatrixOut = defined(I_PropMatrixOut) && IsInt(I_PropMatrixOut) && (I_PropMatrixOut != 2) ? \
          I_PropMatrixOut : -1

        I_PropMatrixOutName = (I_PropMatrixOut == 1) ? " Rec.709" : \
          (5 <= I_PropMatrixOut <= 6) ? " Rec.601" : (I_PropMatrixOut == 9) ? " Rec.2020" : ""

        I_PropPrimOut = IsColorConversion ? propGetAny(CRVideo, "_Primaries") : undefined()
        I_PropPrimOut = defined(I_PropPrimOut) && IsInt(I_PropPrimOut) && (I_PropPrimOut != 2) ? \
          I_PropPrimOut : -1
        I_PropPrimOutName = (I_PropPrimOut == 5) ? " (470bg)" : (I_PropPrimOut == 6) ? " (170m)" : ""
        I_PropPrimStr = (I_PropPrimOut == 1) ? "709" : (I_PropPrimOut == 5) ? "470bg" : \
          (I_PropPrimOut == 6) ? "170m" : (I_PropPrimOut == 7) ? "240m" : (I_PropPrimOut == 9) ? "2020" : ""

        I_ColorConvert = (CC == "") ? "" : \
          I_CConvertLineBreak + ((CM == "") ? "Color Conversion   None Required" : \
          (IsScriptCPreview || (!Is601_709 && !Is2020M) ? "Color" : "Matrix Only") + " Conversion   " + \
          CC + ((CM == "") || !IsScriptCPreview ? "" : "\nNot Applied To Cropping Preview")) + \
          ((CM == "") || IsScriptCPreview ? "" : "\n" + \
          ((CM == "601-709") ? "Rec.601 ->" + I_PropMatrixOutName : \
          (CM == "601P-601N") ? "Rec.601 (470bg) ->" + I_PropMatrixOutName + I_PropPrimOutName : \
          (CM == "601P-709") ? "Rec.601 (470bg) ->" + I_PropMatrixOutName : \
          (CM == "601P-2020") ? "Rec.601 (470bg) ->" + I_PropMatrixOutName : \
          (CM == "601N-601P") ? "Rec.601 (170m) ->" + I_PropMatrixOutName + I_PropPrimOutName : \
          (CM == "601N-709") ? "Rec.601 (170m) ->" + I_PropMatrixOutName : \
          (CM == "601N-2020") ? "Rec.601 (170m) ->" + I_PropMatrixOutName : \
          (CM == "709-601") ? "Rec.709 ->" + I_PropMatrixOutName : \
          (CM == "709-601P") ? "Rec.709 ->" + I_PropMatrixOutName + I_PropPrimOutName : \
          (CM == "709-601N") ? "Rec.709 ->" + I_PropMatrixOutName + I_PropPrimOutName : \
          (CM == "709-2020") || (CM == "709-2020M") ? "Rec.709 ->" + I_PropMatrixOutName : \
          (CM == "2020-601P") ? "Rec.2020 ->" + I_PropMatrixOutName + I_PropPrimOutName : \
          (CM == "2020-601N") ? "Rec.2020 ->" + I_PropMatrixOutName + I_PropPrimOutName : \
          (CM == "2020-709") || (CM == "2020-709M") ? "Rec.2020 ->" + I_PropMatrixOutName : "")) + \
          ((CM == "") || IsScriptCPreview || (I_PropPrimOut == -1) || (I_PropPrimOut == I_PropMatrixOut) || \
          ((5 <= I_PropPrimOut <= 6) && (5 <= I_PropMatrixOut <= 6)) ? "" : \
          "   (Prim  " + ((I_PropPrimStr != "") ? "Rec." + I_PropPrimStr : string(I_PropPrimOut)) + ")")

        I_PicDim = !IsPicDimText ? "" : I_PicDimLineBreak + (IsPicDim ? string(PicDim, "PicDim   %.0f") : \
          IsAutoPicDim && (!IsScriptCPreview || CR_Info_AutoPicDim_CPreview()) ? \
          string(PicDim, "Auto PicDim   %.0f") : "Auto PicDim   Disabled (CPreview)")

        I_GMode = !IsGModeText ? "" : I_GModeLineBreak + GModeText

        I_RMode = !IsCommonResizing ? "" : \
          I_RModeLineBreak + "RMode   " + (IsScriptCPreview ? "CPreview" : "Output") + \
          string(gPriorWidth, " resized to %.0f x ") + string(gPriorHeight, "%.0f")

        I_Right_ColumnA = "CropResize  2025-12-20" + I_ResizingMode + I_Resizer + I_RStr + I_RingRepair
        I_Right_ColumnB = I_Input_ARs + I_Output_ARs + I_MeGUI_DAR + I_ChromaLoc

# -------------------------------------------------------------------------------
#            Info Output
# -------------------------------------------------------------------------------

        I_Color1 = FullResizing ? $FFFFE0 : $F0FFFF
        I_Color2 = FullResizing ? $F0FFFF : $FFFFE0
        I_Color3 = IsColorConversion ? $FFA07A : I_Color1
        I_S1 = A_In && IsA_Out && ((Position && (I_Cond > 3)) || (I_Cond > 4))
        I_S2 = A_In && !IsA_Out && A_Out && Position && (I_Cond == 6)

        F_InfoVideo_Width = float(width(InfoVideo))
        F_InfoVideo_Height = float(height(InfoVideo))

        I_Size = min(F_InfoVideo_Width * \
          ((I_RSL > 70) ? 0.016 : (I_RSL > 57) ? 0.019 : (I_RSL > 45) ? 0.02 : 0.0215), \
          F_InfoVideo_Height * ((F_InfoVideo_Height < 300) ? \
          (IsB_AutoC ? 0.024 : \
          IsBordered ? 0.028 : IsAutoC ? 0.029 : I_S1 ? 0.0303 : I_S2 ? 0.033 : 0.0345) : \
          (F_InfoVideo_Height < 400) ? \
          (IsB_AutoC ? 0.026 : \
          IsBordered ? 0.0295 : IsAutoC ? 0.0305 : I_S1 ? 0.0315 :I_S2 ? 0.034 :  0.036) : \
          (F_InfoVideo_Height < 500) ? \
          (IsB_AutoC ? 0.024 : \
          IsBordered ? 0.0275 : IsAutoC ? 0.0285 : I_S1 ? 0.0295 :I_S2 ? 0.0323 :  0.0335) : \
          (F_InfoVideo_Height < 600) ? \
          (IsB_AutoC ? 0.0248 : \
          IsBordered ? 0.0285 : IsAutoC ? 0.0295 : I_S1 ? 0.0305 : I_S2 ? 0.033 : 0.0342) : \
          (F_InfoVideo_Height < 1100) ? \
          (IsB_AutoC ? 0.0237 : \
          IsBordered ? 0.0275 : IsAutoC ? 0.0285 : I_S1 ? 0.0295 : I_S2 ? 0.0325 : 0.0335) : \
          (F_InfoVideo_Height < 1600) ? \
          (IsB_AutoC ? 0.0232 : IsBordered ? 0.027 : IsAutoC ? 0.028 : I_S1 ? 0.029 : 0.033) : \
          (F_InfoVideo_Height < 1800) ? \
          (IsB_AutoC ? 0.0225 : IsBordered ? 0.0265 : IsAutoC ? 0.027 : I_S1 ? 0.0285 : 0.032) : \
          (F_InfoVideo_Height < 2180) ? \
          (IsB_AutoC ? 0.022 : IsBordered ? 0.0255 : IsAutoC ? 0.0265 : I_S1 ? 0.028 : 0.031) : \
          IsB_AutoC ? 0.0215 : IsBordered ? 0.0245 : IsAutoC ? 0.0255 : I_S1 ? 0.0275 : 0.03))

        I_X1 = I_Size * 1.5
        I_X2 = I_Size * 27.0
        I_Y = (F_InfoVideo_Height < 400) ? I_Size / 1.5 : I_Size
        I_LSP = (F_InfoVideo_Height < 400) ? 8 : (F_InfoVideo_Height < 600) ? 16 : 24

# -------------------------------------------------------------------------------

        InfoVideo = (!IsPicDim || (PicDim == 0)) && \
          (!IsAutoPicDim || (IsScriptCPreview && !CR_Info_AutoPicDim_CPreview())) ? InfoVideo : \
          InfoVideo.Levels(0, 1.0, 255*Scale, 0, (255-PicDim)*Scale, coring=false)

        InfoVideo = InfoVideo\
          .subtitle(I_Left_Column, x=I_X1, y=I_Y, size=I_Size, text_color=I_Color1, lsp=I_LSP)\
          .subtitle(I_Right_ColumnA, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=I_LSP)\
          .subtitle(I_Right_ColumnB, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=I_LSP)

        InfoVideo = !AutoDAR ? InfoVideo : \
          subtitle(InfoVideo, I_AutoDAR, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=I_LSP)
        InfoVideo = (CC == "") ? InfoVideo : \
          subtitle(InfoVideo, I_ColorConvert, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color3, lsp=I_LSP)
        InfoVideo = !IsPicDimText ? InfoVideo : \
          subtitle(InfoVideo, I_PicDim, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=I_LSP)
        InfoVideo = !IsGModeText ? InfoVideo : \
          subtitle(InfoVideo, I_GMode, x=I_X2, y=I_Y, size=I_Size, text_color=I_Color1, lsp=I_LSP)
        InfoVideo = (I_RMode == "") ? InfoVideo : \
          subtitle(InfoVideo, I_RMode, x=I_X2, y=I_Y, size=I_Size, text_color=$FFA07A, lsp=I_LSP)
        InfoVideo = !Position ? InfoVideo : \
          CR_Position(InfoVideo, X=I_X2, Y=I_Y, Size=I_Size, Color=I_Color2, \
          LB1=I_PosLineBreak1, LB2=I_PosLineBreak2, lsp=I_LSP, Info=true) }

# ===============================================================================
#            CropResize Output
# ===============================================================================

    Output = IsAutoCPreview ? AutoCPreviewVideo : IsGAutoCPreview ? Source : \
      Info ? InfoVideo : IsScriptCPreview ? ScriptCPreviewVideo : CRVideo

# -------------------------------------------------------------------------------

    IsGModeText = IsGModeText && (IsCommonResizing || Position) && !Info && !IsScriptCPreview
    IsCommonResizing = IsCommonResizing && !Info && !IsScriptCPreview

    if (Position || IsGModeText || IsCommonResizing) {

        ModeText = !IsGModeText && !IsCommonResizing ? "" : \
          (IsGModeText ? GModeText : "") + (!IsCommonResizing ? "" : (!IsGModeText ? "" : "\n") + \
          "RMode   " + (IsAutoCPreview || IsGAutoCPreview ? "Preview" : "Output") + \
          string(gPriorWidth, " resized to %.0f x ") + string(gPriorHeight, "%.0f"))

        W = IsCommonResizing ? F_gPriorWidth : \
          IsAutoCPreview || IsGAutoCPreview ? F_Source_Width : F_Final_Width
        H = IsCommonResizing ? F_gPriorHeight : \
          IsAutoCPreview || IsGAutoCPreview ? F_Source_Height : F_Final_Height

        TextColor = FullResizing ? $F0FFFF : $FFFFE0

        Size = Info ? I_Size : IsScriptCPreview ? SCP_Size : \
          max(14, min(W * 0.0215, H * \
          ((H < 300) ? 0.0345 : (H < 400) ? 0.036 : (H < 500) ? 0.0335 : \
          (H < 600) ? 0.0342 : (H < 1100) ? 0.0335 : (H < 1600) ? 0.033 : \
          (H < 1800) ? 0.032 : (H < 2180) ? 0.031 : 0.03)))

        Y = Info ? I_Y : IsScriptCPreview ? SCP_Y2 : (H < 400) ? Size / 1.5 : Size
        LSP = Info ? I_LSP : IsScriptCPreview ? SCP_LSP : (H < 400) ? 8 : (H < 600) ? 16 : 24

        Output = !IsCommonResizing ? Output : Output.Spline36Resize(gPriorWidth, gPriorHeight)
        Output = !IsAutoCPreview ? Output : \
          Output.subtitle("AutoCrop Preview", \
          y=(H*0.5)+(Size*0.25), size=Size, text_color=$FFA07A, align=5, lsp=LSP)
        Output = (ModeText == "") ? Output : \
          Output.subtitle(ModeText, y=H-Y, size=Size, text_color=TextColor, align=2, lsp=LSP)
        Output = !Position || Info || IsScriptCPreview ? Output : \
          Output.CR_Position(Y=Y, Size=Size, Color=TextColor, Align=8, lsp=LSP) }

# -------------------------------------------------------------------------------
#            Write SAR Frame Property
# -------------------------------------------------------------------------------

    if (!IsScriptCPreview && !IsAutoCPreview && !IsGAutoCPreview) {

        Out_SAR = IsOutSAR ? OutSAR : IsGOutSAR ? GOutSAR : Final_SAR

        SAR_Num = !IsAnamorphicOutput ? 1 : \
          NoResizing && IsPropSAR ? PropNum : ContinuedNumerator(Out_SAR, limit=10000)
        SAR_Den = !IsAnamorphicOutput ? 1 : \
          NoResizing && IsPropSAR ? PropDen : ContinuedDenominator(Out_SAR, limit=10000)

        Output = propSet(Output, "_SARNum", SAR_Num).propSet("_SARDen", SAR_Den) }

# -------------------------------------------------------------------------------

    return !HasAudio(Source_Audio) ? Output : AudioDub(Output, Source_Audio) }

# ===============================================================================
# ===============================================================================
#            Global GCropResize
# ===============================================================================
# ===============================================================================

function GCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

# -------------------------------------------------------------------------------

    Try{ IsPriorG1 = G1_PriorG1 }Catch(err){ IsPriorG1 = false }
    global G1_PriorG1 = true
    global G_RMode = default(RMode, IsPriorG1 ? G_RMode : false)

    OutWidth = default(OutWidth, 0)
    OutHeight = default(OutHeight, 0)
    AutoC = default(AutoC, false)
    CPreview = default(CPreview, 0)
    gCropDAR = default(CropDAR, 0.0)
    CThresh = default(CThresh, 30)
    Last_Frame = FrameCount(Source) - 1
    CStart = default(CStart, (Last_Frame > 3000) ? 250 : 0)
    CSample = default(CSample, 5)
    gInDAR = default(InDAR, 0.0)
    gInSAR = default(InSAR, 0.0)
    gOutDAR = default(OutDAR, 0.0)
    gOutSAR = default(OutSAR, 0.0)
    IsMod = defined(Mod)
    IsResizer = defined(Resizer)
    IsCPlace = defined(CPlace)
    GMode = default(GMode, 1)

# -------------------------------------------------------------------------------

    A1 = " GCropResize " + chr(10) + " "
    A2 = " " + chr(10)
    Assert((0 < GMode <= 2), A1 + "GMode must be 1 or 2 for" + A1 + "(0, 1 or 2 for CropResize)" + A2)
    Assert(AutoC || (CPreview != 7), A1 + "When CPreview=7, AutoC must be true" + A2)
    Assert(!AutoC || IsYV12(Source) || IsYUY2(Source), \
      A1 + "The AutoCrop plugin only supports YV12 & YUY2 video" + A2)
    Assert(!AutoC || (CStart < Last_Frame), \
      A1 + string(Last_Frame, "When AutoC=true CStart must be less than %.0f (the final frame number)") + A2)

    Assert(IsFloat(gCropDAR) && !IsInt(gCropDAR) && (gCropDAR >= 0), \
      A1 + "CropDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (4.0/3 or 1.33333 etc)" + A2)
    Assert(IsFloat(gInDAR) && !IsInt(gInDAR) && (gInDAR >= 0), \
      A1 + "InDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (16.0/9 or 1.77778 etc)" + A2)
    Assert(IsFloat(gInSAR) && !IsInt(gInSAR) && (gInSAR >= 0), \
      A1 + "InSAR must be a floating point number greater than or equal to zero" + \
      A2 + " (64.0/45 or 1.42222 etc)" + A2)
    Assert(IsFloat(gOutDAR) && !IsInt(gOutDAR) && (gOutDAR >= 0), \
      A1 + "OutDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (16.0/9 or 1.77778 etc)" + A2)
    Assert(IsFloat(gOutSAR) && !IsInt(gOutSAR) && (gOutSAR >= 0), \
      A1 + "OutSAR must be a floating point number greater than or equal to zero" + \
      A2 + " (64.0/45 or 1.42222 etc)" + A2)
    Assert((gInDAR == 0) || (gInSAR == 0), A1 + "An InDAR and InSAR cannot be specified together" + \
      A2 + " (both cannot be greater than zero)" + A2)
    Assert((gOutDAR == 0) || (gOutSAR == 0), A1 + "An OutDAR and OutSAR cannot be specified together" + \
      A2 + " (both cannot be greater than zero)" + A2)

# -------------------------------------------------------------------------------
#            Defaults GMode1
# -------------------------------------------------------------------------------

    if (GMode == 1) {

        IsPriorG1AutoC = IsPriorG1 && G1_AutoC
          global G1_Source_Width = AutoC || !IsPriorG1AutoC ? width(Source) : G1_Source_Width
          global G1_Source_Height = AutoC || !IsPriorG1AutoC ? height(Source) : G1_Source_Height

        Assert(!AutoC || !IsPriorG1AutoC, A1 + "AutoC cannot be true for GCropResize(GMode=1)" + \
          A2 + " after being enabled by a previous instance of GCropResize(GMode=1)" + A2)

        global G1_OutWidth = (OutWidth == 0) && IsPriorG1 ? G1_OutWidth : OutWidth
        global G1_OutHeight = (OutHeight == 0) && IsPriorG1 ? G1_OutHeight : OutHeight
        global G1_CL = default(CL, !IsPriorG1 ? 0.0 : G1_CL)
        global G1_CT = default(CT, !IsPriorG1 ? 0.0 : G1_CT)
        global G1_CR = default(CR, !IsPriorG1 ? 0.0 : G1_CR)
        global G1_CB = default(CB, !IsPriorG1 ? 0.0 : G1_CB)
        global G1_CropDAR = default(CropDAR, !IsPriorG1 ? 0.0 : G1_CropDAR)
        global G1_TCRatio = default(TCRatio, !IsPriorG1 ? 0.5 : G1_TCRatio)
        global G1_CSplit = default(CSplit, !IsPriorG1 ? 1 : G1_CSplit)
        global G1_AutoC = IsPriorG1AutoC ? G1_AutoC : AutoC
        global G1_CPreview = default(CPreview, !IsPriorG1 ? 0 : G1_CPreview)
        global G1_CLine = default(CLine, !IsPriorG1 ? undefined() : G1_CLine)
        global G1_InDAR = default(InDAR, (gInSAR > 0) || !IsPriorG1 ? 0.0 : G1_InDAR)
        global G1_InSAR = default(InSAR, (gInDAR > 0) || !IsPriorG1 ? 0.0 : G1_InSAR)
        global G1_OutDAR = default(OutDAR, (gOutSAR > 0) || !IsPriorG1 ? 0.0 : G1_OutDAR)
        global G1_OutSAR = default(OutSAR, (gOutDAR > 0) || !IsPriorG1 ? 0.0 : G1_OutSAR)
        global G1_AutoDAR = default(AutoDAR, !IsPriorG1 ? CR_AutoDAR() : G1_AutoDAR)
        global G1_Mod = default(Mod, !IsPriorG1 ? 4 : G1_Mod)
        global G1_HMod = default(HMod, IsMod || !IsPriorG1 ? G1_Mod : G1_HMod)
        global G1_NoResize = default(NoResize, !IsPriorG1 ? false : G1_NoResize)
        global G1_ResizeWO = default(ResizeWO, !IsPriorG1 ? false : G1_ResizeWO)
        global G1_Borders = default(Borders, !IsPriorG1 ? false : G1_Borders)
        global G1_CleanBorders = default(CleanBorders, !IsPriorG1 ? false : G1_CleanBorders)
        global G1_BBlur = default(BBlur, !IsPriorG1 ? false : G1_BBlur)
        global G1_BColor = default(BColor, !IsPriorG1 ? $000000 : G1_BColor)
        global G1_Frosty = default(Frosty, !IsPriorG1 ? false : G1_Frosty)
        global G1_ColorConvert = default(ColorConvert, !IsPriorG1 ? CR_ColorConvert() : G1_ColorConvert)
        global G1_ColorMode = default(ColorMode, !IsPriorG1 ? "" : G1_ColorMode)
        global G1_Resizer = default(Resizer, !IsPriorG1 ? CR_Resizer_Default() : G1_Resizer)
        global G1_RStr = default(RStr, IsResizer ? "" : !IsPriorG1 ? CR_RStr_Default() : G1_RStr)
        global G1_CPlace = default(CPlace, !IsPriorG1 ? "" : G1_CPlace)
        global G1_CPlaceD = default(CPlaceD, IsCPlace || !IsPriorG1 ? G1_CPlace : G1_CPlaceD)
        global G1_RingRepair = default(RingRepair, !IsPriorG1 ? false : G1_RingRepair)
        global G1_IsPicDim = defined(PicDim) ? true : !IsPriorG1 ? false : G1_IsPicDim
        global G1_PicDim = default(PicDim, !IsPriorG1 ? CR_Info_AutoPicDim() : G1_PicDim)
        global G1_Position = default(Position, !IsPriorG1 ? false : G1_Position)
        global G1_Info = default(Info, !IsPriorG1 ? false : G1_Info) }

    else {

# -------------------------------------------------------------------------------
#            Defaults GMode2
# -------------------------------------------------------------------------------

        Assert(IsPriorG1, A1 + "For the first instance of GCropResize, GMode must equal one" + A2)
        Try{ IsPriorG2 = G2_PriorG2 }Catch(err){ IsPriorG2 = false }
        global G2_PriorG2 = true

        IsPriorG2AutoC = IsPriorG2 && G2_AutoC
          global G2_Source_Width = AutoC || !IsPriorG2AutoC ? width(Source) : G2_Source_Width
          global G2_Source_Height = AutoC || !IsPriorG2AutoC ? height(Source) : G2_Source_Height

        Assert(!AutoC || !IsPriorG2AutoC, A1 + "AutoC cannot be true for GCropResize(GMode=2)" + \
          A2 + " after being enabled by a previous instance of GCropResize(GMode=2)" + A2)

        global G2_OutWidth = (OutWidth == 0) ? (!IsPriorG2 ? G1_OutWidth : G2_OutWidth) : OutWidth
        global G2_OutHeight = (OutHeight == 0) ? (!IsPriorG2 ? G1_OutHeight : G2_OutHeight) : OutHeight
        global G2_CL = default(CL, !IsPriorG2 ? 0.0 : G2_CL)
        global G2_CT = default(CT, !IsPriorG2 ? 0.0 : G2_CT)
        global G2_CR = default(CR, !IsPriorG2 ? 0.0 : G2_CR)
        global G2_CB = default(CB, !IsPriorG2 ? 0.0 : G2_CB)
        global G2_CropDAR = default(CropDAR, !IsPriorG2 ? 0.0 : G2_CropDAR)
        global G2_TCRatio = default(TCRatio, !IsPriorG2 ? 0.5 : G2_TCRatio)
        global G2_CSplit = default(CSplit, !IsPriorG2 ? 1 : G2_CSplit)
        global G2_AutoC = IsPriorG2AutoC ? G2_AutoC : AutoC
        global G2_CPreview = default(CPreview, !IsPriorG2 ? ((G1_CPreview == 7) ? 0 : G1_CPreview) : G2_CPreview)
        global G2_CLine = default(CLine, !IsPriorG2 ? G1_CLine : G2_CLine)
        global G2_InDAR = default(InDAR, (gInSAR > 0) || !IsPriorG2 ? 0.0 : G2_InDAR)
        global G2_InSAR = default(InSAR, (gInDAR > 0) || !IsPriorG2 ? 0.0 : G2_InSAR)
        global G2_OutDAR = default(OutDAR, (gOutSAR > 0) ? 0.0 : !IsPriorG2 ? G1_OutDAR : G2_OutDAR)
        global G2_OutSAR = default(OutSAR, (gOutDAR > 0) ? 0.0 : !IsPriorG2 ? G1_OutSAR : G2_OutSAR)
        global G2_AutoDAR = default(AutoDAR, !IsPriorG2 ? G1_AutoDAR : G2_AutoDAR)
        global G2_Mod = default(Mod, !IsPriorG2 ? G1_Mod : G2_Mod)
        global G2_HMod = default(HMod, IsMod || !IsPriorG2 ? G2_Mod : G2_HMod)
        global G2_NoResize = default(NoResize, !IsPriorG2 ? false : G2_NoResize)
        global G2_ResizeWO = default(ResizeWO, !IsPriorG2 ? false : G2_ResizeWO)
        global G2_Borders = default(Borders, !IsPriorG2 ? false : G2_Borders)
        global G2_CleanBorders = default(CleanBorders, !IsPriorG2 ? false : G2_CleanBorders)
        global G2_BBlur = default(BBlur, !IsPriorG2 ? false : G2_BBlur)
        global G2_BColor = default(BColor, !IsPriorG2 ? $000000 : G2_BColor)
        global G2_Frosty = default(Frosty, !IsPriorG2 ? false : G2_Frosty)
        global G2_ColorConvert = default(ColorConvert, !IsPriorG2 ? CR_ColorConvert() : G2_ColorConvert)
        global G2_ColorMode = default(ColorMode, !IsPriorG2 ? "" : G2_ColorMode)
        global G2_Resizer = default(Resizer, !IsPriorG2 ? G1_Resizer : G2_Resizer)
        global G2_RStr = default(RStr, IsResizer ? "" : !IsPriorG2 ? G1_RStr : G2_RStr)
        global G2_CPlace = default(CPlace, !IsPriorG2 ? "" : G2_CPlace)
        global G2_CPlaceD = default(CPlaceD, IsCPlace || !IsPriorG2 ? G2_CPlace : G2_CPlaceD)
        global G2_RingRepair = default(RingRepair, !IsPriorG2 ? false : G2_RingRepair)
        global G2_IsPicDim = defined(PicDim) ? true : !IsPriorG2 ? G1_IsPicDim : G2_IsPicDim
        global G2_PicDim = default(PicDim, !IsPriorG2 ? G1_PicDim : G2_PicDim)
        global G2_Position = default(Position, !IsPriorG2 ? false : G2_Position)
        global G2_Info = default(Info, !IsPriorG2 ? G1_Info : G2_Info) }

# -------------------------------------------------------------------------------
#            Global Auto Cropping
# -------------------------------------------------------------------------------

    if (AutoC && (CPreview != 7)) {

        AutoCVideo = \
          Source.autocrop(mode=0, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
          threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0) }

    else if (CPreview == 7) {

        H = height(Source)
        Size = min(width(Source) * 0.0215, H * \
          ((H < 300) ? 0.0345 : (H < 400) ? 0.036 : (H < 500) ? 0.0335 : \
          (H < 600) ? 0.0342 : (H < 1100) ? 0.0335 : (H < 1600) ? 0.033 : \
          (H < 1800) ? 0.032 : (H < 2180) ? 0.031 : 0.03))

        AutoCPreviewVideo = \
          Source.autocrop(mode=1, wMultOf=2, hMultOf=2, leftadd=0, topadd=0, rightadd=0, bottomadd=0, \
          threshold=CThresh, samples=CSample, samplestartframe=CStart, sampleendframe=-1, aspect=0)\
          .subtitle("Global AutoCrop Preview", y=(H*0.5)+(Size*0.25), \
          size=Size, text_color=$FFA07A, align=5) }

# -------------------------------------------------------------------------------

    return AutoC && (CPreview != 7) ? AutoCVideo : (CPreview == 7) ? AutoCPreviewVideo : Source }

# ===============================================================================
# ===============================================================================
#            CombineClips
# ===============================================================================
# ===============================================================================

function CombineClips(clip_array Clips, int "OutWidth", int "OutHeight", bool "Max", \
    float "TCRatio", val "InSAR", val "OutDAR", val "OutSAR", int "Mod", int "HMod", \
    bool "Borders", val "BColor", bool "BBlur", bool "Frosty", string "ColorConvert", \
    string "Resizer", string "RStr", val "RingRepair", bool "Position", bool "Info") {

# -------------------------------------------------------------------------------

    OutWidth = default(OutWidth, 0)
    OutHeight = default(OutHeight, 0)
    Max = default(Max, true)
    Mod = default(Mod, 4)
    HMod = default(HMod, Mod)
    Borders = default(Borders, true)

# -------------------------------------------------------------------------------

    A1 = " CombineClips " + chr(10) + " "
    A2 = " " + chr(10)
    Assert((OutWidth >= 0 <= OutHeight), A1 + "OutWidth & OutHeight can't be negative" + A2)
    Assert(!defined(InSAR) || (defined(InSAR) && IsFloat(InSAR) && !IsInt(InSAR) && (InSAR >= 0)), \
      A1 + "InSAR must be a floating point number greater than or equal to zero" + \
      A2 + " (64.0/45 or 1.42222 etc)" + A2)
    Assert(!defined(OutDAR) || (defined(OutDAR) && IsFloat(OutDAR) && !IsInt(OutDAR) && (OutDAR >= 0)), \
      A1 + "OutDAR must be a floating point number greater than or equal to zero" + \
      A2 + " (16.0/9 or 1.77778 etc)" + A2)
    Assert(!defined(OutSAR) || (defined(OutSAR) && IsFloat(OutSAR) && !IsInt(OutSAR) && (OutSAR >= 0)), \
      A1 + "OutSAR must be a floating point number greater than or equal to zero" + \
      A2 + " (64.0/45 or 1.42222 etc)" + A2)
    Assert(!defined(OutDAR) || !defined(OutSAR), A1 + "OutDAR and OutSAR can't be specified together" + A2)

# -------------------------------------------------------------------------------

    PropNum = propGetAny(Clips[0], "_SARNum")
    PropDen = propGetAny(Clips[0], "_SARDen")
    InSAR1 = default(InSAR, defined(PropNum) && defined(PropDen) && (PropNum > 0 < PropDen) ? \
      float(PropNum) / float(PropDen) : 1.0)

    W1 = width(Clips[0])
    H1 = height(Clips[0])
    AR1 = float(W1) * InSAR1 / float(H1)
    MaxW = W1
    MaxH = H1
    MaxAR = AR1
    MinAR = AR1

# -------------------------------------------------------------------------------

    for (i=1, ArraySize(Clips)-1) {

        PropNum = propGetAny(Clips[i], "_SARNum")
        PropDen = propGetAny(Clips[i], "_SARDen")
        InSAR2 = default(InSAR, defined(PropNum) && defined(PropDen) && (PropNum > 0 < PropDen) ? \
          float(PropNum) / float(PropDen) : 1.0)

        W2 = width(Clips[i])
        H2 = height(Clips[i])
        AR2 = float(W2) * InSAR2 / float(H2)

        if (MaxW < W2 > W1) { MaxW = W2 }
        if (MaxH < H2 > H1) { MaxH = H2 }
        if (MaxAR < AR2 > AR1) { MaxAR = AR2 }
        if (MinAR > AR2 < AR1) { MinAR = AR2 } }

# -------------------------------------------------------------------------------

    OutWidth = (OutWidth > 0) ? OutWidth : (OutHeight > 0) ? \
      (Max ? floor(float(OutHeight) * MaxAR / float(Mod)) * Mod : \
      floor(float(OutHeight) * MinAR / float(Mod)) * Mod) : \
      Max ? floor(float(MaxH) * MaxAR / float(Mod)) * Mod : MaxW

    OutHeight = (OutHeight > 0) ? OutHeight : (OutWidth > 0) ? \
      (Max ? floor(float(OutWidth) / MaxAR / float(HMod)) * HMod : \
      floor(float(OutWidth) / MinAR / float(HMod)) * HMod) : \
      Max ? MaxH : floor(float(MaxW) / MinAR / float(HMod)) * HMod

    Output = CropResize(Clips[0], OutWidth=OutWidth, OutHeight=OutHeight, \
      TCRatio=TCRatio, InSAR=InSAR, OutDAR=OutDAR, OutSAR=OutSAR, Mod=Mod, HMod=HMod, \
      Borders=Borders, BColor=BColor, BBlur=BBlur, Frosty=Frosty, ColorConvert=ColorConvert, \
      Resizer=Resizer, RStr=RStr, RingRepair=RingRepair, Position=Position, Info=Info)

# -------------------------------------------------------------------------------

    for (i=1, ArraySize(Clips)-1) {

        Output = Output ++ CropResize(Clips[i], OutWidth=OutWidth, OutHeight=OutHeight, \
          TCRatio=TCRatio, InSAR=InSAR, OutDAR=OutDAR, OutSAR=OutSAR, Mod=Mod, HMod=HMod, \
          Borders=Borders, BColor=BColor, BBlur=BBlur, Frosty=Frosty, ColorConvert=ColorConvert, \
          Resizer=Resizer, RStr=RStr, RingRepair=RingRepair, Position=Position, Info=Info) }

    return Output }

# ===============================================================================
# ===============================================================================
#            Color Convert & Resize
# ===============================================================================
# ===============================================================================

function CR_ColorConvertResize(Cropped, CRVideo_Width, CRVideo_Height, RCL, RCT, \
    F_Cropped_Width, F_Cropped_Height, A1, A2, Source_Bits, Loaded_ConvStack, CC, CM, \
    Is601_709, Is2020M, Color_Format, PropMatrix, PropTrans, PropPrim, PropRange, PropChroma, \
    IsChromaSS, ChromaLocS, ChromaLocD, ZR_CPlaceStr, DT_ChromaLocS, DT_ChromaLocD, ChromaIntD, \
    FProp_ChromaD, IsFullRange, IsRingRepair, IsDRingRepair, Weight, NoResizer, DoResize, \
    Resizer, ResStr, RTaps, Upscale, Cropped_CPlace, IsCPlaceResize, IsZResize, IsZAVSR, \
    IsDResize, IsFMTC, IsResize8, IsResizeMT) {

# -------------------------------------------------------------------------------

    Assert((Color_Format != "YV411") || (CC == "DitherTools"), \
      A1 + "Color conversion of YV411 is only supported by DitherTools" + A2)

    DoRingRepair = ".CR_RingRepair(CConverted, " + \
      "CRVideo_Width, CRVideo_Height, RCL, RCT, F_Cropped_Width, F_Cropped_Height, " + \
      "IsCPlaceResize, IsFMTC, IsResizeMT, ChromaLocS, ChromaLocD, Weight)"

    Cropped = (CC == "ColorMatrix") || (Color_Format != "YUY2") ? Cropped : Cropped.ConvertToYV16()

    Cropped_CPlace = (CC == "ColorMatrix") || (Color_Format != "YUY2") ? \
      Cropped_CPlace : Cropped_CPlace.ConvertToYV16()

# -------------------------------------------------------------------------------

    MatrixOut = (CM == "601-709") || (CM == "601P-709") || \
      (CM == "601N-709") || (CM == "2020-709") || (CM == "2020-709M") ? 1 : \
      (CM == "601N-601P") || (CM == "709-601P") || (CM == "2020-601P") ? 5 : \
      (CM == "601P-601N") || (CM == "709-601") || (CM == "709-601N") || (CM == "2020-601N") ? 6 : \
      (CM == "601N-2020") || (CM == "601P-2020") || (CM == "709-2020") || (CM == "709-2020M") ? 9 : PropMatrix

    PrimOut = (CM == "") ? -1 : (CM == "601P-709") || (CM == "601N-709") || (CM == "2020-709") ? 1 : \
      (CM == "601N-601P") || (CM == "709-601P") || (CM == "2020-601P") ? 5 : \
      (CM == "601P-601N") || (CM == "709-601N") || (CM == "2020-601N") ? 6 : \
      (CM == "601N-2020") || (CM == "601P-2020") || (CM == "709-2020") ? 9 : PropPrim

    ChromaIntS = !defined(ChromaLocS) ? -1 : (ChromaLocS == "left") ? 0 : (ChromaLocS == "center") ? 1 : \
      (ChromaLocS == "top_left") ? 2 : (ChromaLocS == "top") ? 3 : (ChromaLocS == "bottom_left") ? 4 : \
      (ChromaLocS == "bottom") ? 5 : (ChromaLocS == "dv") ? 6 : PropChroma

    FProp_ChromaS = (ChromaIntS == -1) ? "" : """.propSet("_ChromaLocation", ChromaIntS)"""

    FProp_Matrix = (MatrixOut == -1) ? "" : """.propSet("_Matrix", MatrixOut)"""
    FProp_Transfer = (PropTrans == -1) ? "" : """.propSet("_Transfer", PropTrans)"""
    FProp_Primaries = (PrimOut == -1) ? "" : """.propSet("_Primaries", PrimOut)"""
    FProp_ColorRange = (PropRange == -1) ? "" : """.propSet("_ColorRange", PropRange)"""

    FProps = FProp_Matrix + FProp_Primaries + FProp_Transfer + FProp_ColorRange

# -------------------------------------------------------------------------------

    DTypeA = (Source_Bits == 32) ? 1 : -1
    DTypeB = (Source_Bits == 32) ? -1 : 1

    To16Bit = (Source_Bits == 16) && !IsFullRange ? "" : \
      ".ConvertBits(16, fulls=IsFullRange, fulld=false, dither=DTypeA)"

    From16Bit = (Source_Bits == 16) && !IsFullRange ? "" : \
      ".ConvertBits(Source_Bits, fulls=false, fulld=IsFullRange, dither=DTypeB)"

    To32Bit = (Source_Bits == 32) && IsFullRange ? "" : \
      ".ConvertBits(32, fulls=IsFullRange, fulld=true)"

    From32Bit = (Source_Bits == 32) && IsFullRange ? "" : \
      ".ConvertBits(Source_Bits, fulls=true, fulld=IsFullRange, dither=((Source_Bits == 32) ? -1 : 1))"

    To444_S = !IsChromaSS ? "" : ".ConvertToYUV444(ChromaInPlacement=ChromaLocS)"
    To444_D = !IsChromaSS ? "" : ".ConvertToYUV444(ChromaInPlacement=ChromaLocD)"

    From444_S = !IsChromaSS ? "" : \
      Is420(Cropped) ? ".ConvertToYUV420(ChromaOutPlacement=ChromaLocS)" : \
      Is422(Cropped) ? ".ConvertToYUV422(ChromaOutPlacement=ChromaLocS)" : ""

    From444_D = !IsChromaSS ? "" : \
      Is420(Cropped) ? ".ConvertToYUV420(ChromaOutPlacement=ChromaLocD)" : \
      Is422(Cropped) ? ".ConvertToYUV422(ChromaOutPlacement=ChromaLocD)" : ""

# ===============================================================================
#            AVSResize
# ===============================================================================

    if (CC == "AVSResize") {

        Assert(!IsDResize || NoResizer, \
          A1 + "DitherTools cannot be used for resizing when AVSResize is color converting" + A2)

# -------------------------------------------------------------------------------

        CS_OP = \
          (CM == "601-709") ? "470bg:auto:auto=>709:same:same" : \
          (CM == "709-601") ? "709:auto:auto=>470bg:same:same" : \
          (CM == "709-2020M") ? "709:auto:auto=>2020:same:same" : \
          (CM == "2020-709M") ? "2020:auto:auto=>709:same:same" : \
          (CM == "601N-601P") ? "170m:601:170m=>470bg:601:470bg" : \
          (CM == "601N-709") ? "170m:601:170m=>709:709:709" : \
          (CM == "601N-2020") ? "170m:601:170m=>2020:2020:2020" : \
          (CM == "601P-601N") ? "470bg:601:470bg=>170m:601:170m" : \
          (CM == "601P-709") ? "470bg:601:470bg=>709:709:709" : \
          (CM == "601P-2020") ? "470bg:601:470bg=>2020:2020:2020" : \
          (CM == "709-601N") ? "709:709:709=>170m:601:170m" : \
          (CM == "709-601P") ? "709:709:709=>470bg:601:470bg" : \
          (CM == "709-2020") ? "709:709:709=>2020:2020:2020" : \
          (CM == "2020-601N") ? "2020:2020:2020=>170m:601:170m" : \
          (CM == "2020-601P") ? "2020:2020:2020=>470bg:601:470bg" : \
          (CM == "2020-709") ? "2020:2020:2020=>709:709:709" : nop()

        CConvert = ".z_ConvertFormat(colorspace_op=CS_OP, approximate_gamma=false)"
        CConvert_CPlace = \
          ".z_ConvertFormat(colorspace_op=CS_OP, approximate_gamma=false" + ZR_CPlaceStr + ")"

        Cropped = Eval("Cropped" + To32Bit)
        Cropped_CPlace = Eval("Cropped_CPlace" + To32Bit)

        CConverted = NoResizer ? Eval("Cropped" + CConvert_CPlace) : \
          IsRingRepair ? (IsCPlaceResize ? Eval("Cropped_CPlace" + CConvert) : \
          IsFMTC ? Eval("Cropped" + CConvert) : Eval("Cropped" + To444_S + CConvert)) : nop()

        CCVideo = NoResizer ? CConverted : \
          IsRingRepair ? (IsCPlaceResize || IsFMTC ? Eval("CConverted" + DoResize + DoRingRepair) : \
          Eval("CConverted" + DoResize + DoRingRepair + From444_D)) : \
          IsZResize ? \
          Eval("Cropped" + ".z_ConvertFormat(CRVideo_Width, CRVideo_Height, " + \
          "src_left=RCL, src_top=RCT, src_width=F_Cropped_Width, src_height=F_Cropped_Height, " + \
          "resample_filter=Resizer, colorspace_op=CS_OP, " + \
          "approximate_gamma=false" + ZR_CPlaceStr + RTaps + ResStr + ")") : \
          IsZAVSR ? \
          Eval("Cropped" + "." + Resizer + "(CRVideo_Width, CRVideo_Height, " + \
          "src_left=RCL, src_top=RCT, src_width=F_Cropped_Width, src_height=F_Cropped_Height, " + \
          "colorspace_op=CS_OP, approximate_gamma=false" + ZR_CPlaceStr + ResStr + ")") : \
          IsCPlaceResize ? (UpScale ? \
          Eval("Cropped_CPlace" + CConvert + DoResize) : Eval("Cropped_CPlace" + DoResize + CConvert)) : \
          IsFMTC || IsResize8 ? (UpScale ? \
          Eval("Cropped" + CConvert + DoResize) : Eval("Cropped" + DoResize + CConvert)) : \
          Upscale ? \
          Eval("Cropped" + To444_S + CConvert + DoResize + From444_D) : \
          Eval("Cropped" + To444_S + DoResize + CConvert + From444_D)

        CCVideo = Eval("CCVideo" + From32Bit) }

    else if (CC == "ColorMatrix") {

# ===============================================================================
#            ColorMatrix
# ===============================================================================

        Assert((Color_Format == "YV12") || (Color_Format == "YUY2") || (Color_Format == "YV16"), \
          A1 + "Color conversion with ColorMatrix is only supported for YV12, YUY2 & YV16" + A2)
        Assert(Is601_709, A1 + "ColorMatrix can only be used for 'matrix only'" + \
          A2 + " color conversions between Rec.601 and Rec.709" + A2)

        # -------------------------------------------------------------------------------

        To16Bit = NoResizer || !IsFMTC ? "" : To16Bit
        From16Bit = NoResizer || !IsFMTC ? "" : From16Bit
        ToYUY2_S = ".ConvertToYUY2(ChromaInPlacement=ChromaLocS)"
        ToYUY2_D = ".ConvertToYUY2(ChromaInPlacement=ChromaLocD)"
        ToYV16_S = ".ConvertToYV16(ChromaOutPlacement=ChromaLocS)"
        ToYV16_D = ".ConvertToYV16(ChromaOutPlacement=ChromaLocD)"

        CMode = (CM == "601-709") ? "Rec.601->Rec.709" : "Rec.709->Rec.601"
        CConvert = ".ColorMatrix(mode=CMode, clamp=0)"

        CConverted = NoResizer ? \
          ((Color_Format != "YV16") ? Eval("Cropped" + CConvert + FProps + FProp_ChromaS) : \
          Eval("Cropped" + ToYUY2_S + CConvert + ToYV16_S + FProps)) : \
          IsRingRepair ? \
          (IsCPlaceResize ? \
          ((Color_Format == "YV12") ? Eval("Cropped_CPlace" + CConvert + FProps + FProp_ChromaD) : \
          (Color_Format == "YV16") ? Eval("Cropped_CPlace" + ToYUY2_D + CConvert + ToYV16_D + FProps) : \
          Eval("Cropped_CPlace" + CConvert + ToYV16_D + FProps)) : \
          (Color_Format == "YV12") ? Eval("Cropped" + CConvert + FProps + FProp_ChromaS + To16Bit) : \
          (Color_Format == "YV16") ? Eval("Cropped" + ToYUY2_S + CConvert + ToYV16_S + FProps + To16Bit) : \
          Eval("Cropped" + CConvert + ToYV16_S + FProps + To16Bit)) : nop()

        CCVideo = NoResizer ? CConverted : \
          IsRingRepair ? ((Color_Format != "YUY2") ? \
          Eval("CConverted" + DoResize + DoRingRepair + From16Bit) : \
          Eval("CConverted" + DoResize + DoRingRepair + From16Bit + ToYUY2_D)) : \
          !IsZAVSR && !IsDResize && !IsFMTC && !IsResize8 ? \
          ((Color_Format != "YV16") ? \
          Eval("Cropped" + CConvert + FProps + FProp_ChromaS + DoResize) : \
          Eval("Cropped" + ToYUY2_S + CConvert + ToYV16_S + FProps + DoResize)) : \
          IsCPlaceResize ? (Upscale ? \
          ((Color_Format != "YV16") ? \
          Eval("Cropped_CPlace" + CConvert + FProps + FProp_ChromaD + DoResize) : \
          Eval("Cropped_CPlace" + ToYUY2_D + CConvert + ToYV16_D + FProps + DoResize)) : \
          (Color_Format != "YV16") ? \
          Eval("Cropped_CPlace" + DoResize + CConvert + FProps + FProp_ChromaD) : \
          Eval("Cropped_CPlace" + DoResize + ToYUY2_D + CConvert + ToYV16_D + FProps)) : \
          Upscale ? ((Color_Format == "YV12") ? \
          Eval("Cropped" + CConvert + FProps + FProp_ChromaS + To16Bit + DoResize + From16Bit) : \
          (Color_Format == "YV16") ? \
          Eval("Cropped" + ToYUY2_S + CConvert + ToYV16_S + FProps + To16Bit + DoResize + From16Bit) : \
          IsZAVSR || IsDResize || IsFMTC ? \
          Eval("Cropped" + CConvert + ToYV16_S + FProps + To16Bit + DoResize + From16Bit + ToYUY2_D) : \
          Eval("Cropped" + CConvert + FProps + FProp_ChromaS + DoResize)) : \
          (Color_Format == "YV12") ? \
          Eval("Cropped" + To16Bit + DoResize + From16Bit + CConvert + FProps + FProp_ChromaD) : \
          (Color_Format == "YV16") ? \
          Eval("Cropped" + To16Bit + DoResize + From16Bit + ToYUY2_D + CConvert + ToYV16_D + FProps) : \
          IsZAVSR || IsDResize || IsFMTC ? \
          Eval("Cropped" + ToYV16_S + To16Bit + DoResize + From16Bit + ToYUY2_D + CConvert + FProps) : \
          Eval("Cropped" + DoResize + CConvert + FProps) }

    else if (CC == "DitherTools") {

# ===============================================================================
#            DitherTools
# ===============================================================================

        Assert((Source_Bits == 8), A1 + "DitherTools only supports color conversion of 8 bit YUV" + A2)
        Assert(Is601_709 || Is2020M, \
          A1 + "DitherTools can only be used for 'matrix only' color conversions" + A2)
        Assert(NoResizer || IsCPlaceResize || IsZAVSR || IsResize8 || IsDResize || IsFMTC, \
          A1 + "To ensure correct handling of chroma placement, only Avisynth+ (version >= 3.7.4)," + \
          A2 + " ResampleMT (version >= 2.5.1), AVSResize, DitherTools, FMTConv or Resize8" + \
          A2 + " can be used for resizing when color converting with DitherTools" + A2)

# -------------------------------------------------------------------------------

        To16Bit = NoResizer || !IsFMTC ? "" : To16Bit
        From16Bit = NoResizer || !IsFMTC ? "" : From16Bit

        MatrixS = (CM == "601-709") ? "601" : (CM == "709-601") || (CM == "709-2020M") ? "709" : "2020"
        MatrixD = (CM == "709-601") ? "601" : (CM == "601-709") || (CM == "2020-709M") ? "709" : "2020"

        ToRGB_S = ".Dither_convert_yuv_to_rgb(matrix=MatrixS, lsb_in=false, " + \
          "tv_range=!IsFullRange, cplace=DT_ChromaLocS)"
        ToRGB_D = \
          ".Dither_convert_yuv_to_rgb(matrix=MatrixS, lsb_in=false, " + \
          "tv_range=!IsFullRange, cplace=DT_ChromaLocD)"
        ToRGB_D_LSB = \
          ".Dither_convert_yuv_to_rgb(matrix=MatrixS, lsb_in=true, " + \
          "tv_range=!IsFullRange, cplace=DT_ChromaLocD)"

        FromRGB_S = \
          ".Dither_convert_rgb_to_yuv(matrix=MatrixD, " + \
          "output=PixelType(Cropped), lsb=false, slice=false, mode=6, " + \
          "tv_range=!IsFullRange, cplace=DT_ChromaLocS)"
        FromRGB_S_LSB = \
          ".Dither_convert_rgb_to_yuv(matrix=MatrixD, " + \
          "output=PixelType(Cropped), lsb=true, slice=false, mode=6, " + \
          "tv_range=!IsFullRange, cplace=DT_ChromaLocS)"
        FromRGB_D = \
          ".Dither_convert_rgb_to_yuv(matrix=MatrixD, " + \
          "output=PixelType(Cropped), lsb=false, slice=false, mode=6, " + \
          "tv_range=!IsFullRange, cplace=DT_ChromaLocD)"

        DResize16 = ".Dither_resize16" + (!IsDRingRepair ? "" : "nr") + \
          "(CRVideo_Width, CRVideo_Height, " + \
          "src_left=RCL, src_top=RCT, src_width=F_Cropped_Width, src_height=F_Cropped_Height, " + \
          "kernel=Resizer, cplaces=DT_ChromaLocS, cplaced=DT_ChromaLocD" + RTaps + ResStr + ")"

        CConverted = NoResizer ? Eval("Cropped" + ToRGB_S + FromRGB_D + FProp_Matrix + FProp_ChromaD) : \
          IsRingRepair ? \
          (IsCPlaceResize ? Eval("Cropped_CPlace" + ToRGB_D + FromRGB_D + FProp_Matrix + FProp_ChromaD) : \
          Eval("Cropped" + ToRGB_S + FromRGB_S + To16Bit + FProp_Matrix + FProp_ChromaS)) : nop()

        CCVideo = NoResizer ? CConverted : IsRingRepair ? \
          (IsCPlaceResize ? Eval("CConverted" + DoResize + DoRingRepair) : \
          Eval("CConverted" + DoResize + DoRingRepair + From16Bit)) : \
          IsZAVSR || IsFMTC || IsResize8 ? (UpScale ? \
          Eval("Cropped" + ToRGB_S + FromRGB_S + FProp_Matrix + FProp_ChromaS + \
          To16Bit + DoResize + From16Bit) : \
          Eval("Cropped" + To16Bit + DoResize + From16Bit + ToRGB_D + FromRGB_D + \
          FProp_Matrix + FProp_ChromaD)) : \
          IsDResize ? (Upscale ? \
          Eval("Cropped" + ToRGB_S + FromRGB_S_LSB + DResize16 + ".DitherPost(mode=6, slice=false)" + \
          FProp_Matrix + FProp_ChromaD) : \
          Eval("Cropped.Dither_convert_8_to_16()" + DResize16 + \
          ToRGB_D_LSB + FromRGB_D + FProp_Matrix + FProp_ChromaD)) : \
          IsCPlaceResize ? (Upscale ? \
          Eval("Cropped_CPlace" + ToRGB_D + FromRGB_D + FProp_Matrix + FProp_ChromaD + DoResize) : \
          Eval("Cropped_CPlace" + DoResize + ToRGB_D + FromRGB_D + FProp_Matrix + FProp_ChromaD)) : nop() }

    else if (CC == "FMTConv") {

# ===============================================================================
#            FMTConv
# ===============================================================================

        Assert(!IsDResize || NoResizer, \
          A1 + "DitherTools cannot be used for resizing when FMTConv is color converting" + A2)

# -------------------------------------------------------------------------------

        MatrixS = (CM == "601-709") || (CM == "601P-601N") || (CM == "601P-709") || \
          (CM == "601P-2020") || (CM == "601N-601P") || (CM == "601N-709") || (CM == "601N-2020") ? "601" : \
          (CM == "709-601") || (CM == "709-601P") || \
          (CM == "709-601N") || (CM == "709-2020") || (CM == "709-2020M") ? "709" : \
          (CM == "2020-601P") || (CM == "2020-601N") || (CM == "2020-709") || (CM == "2020-709M") ? "2020" : \
          nop()

        MatrixD = (CM == "709-601") || (CM == "601N-601P") || (CM == "709-601P") || \
          (CM == "2020-601P") || (CM == "601P-601N") || (CM == "709-601N") || (CM == "2020-601N") ? "601" : \
          (CM == "601-709") || (CM == "601P-709") || \
          (CM == "601N-709") || (CM == "2020-709") || (CM == "2020-709M") ? "709" : \
          (CM == "601P-2020") || (CM == "601N-2020") || (CM == "709-2020") || (CM == "709-2020M") ? "2020" : \
          nop()

        PrimaryS = Is601_709 || Is2020M ? "" : \
          (CM == "601N-601P") || (CM == "601N-709") || (CM == "601N-2020") ? "601-525" : \
          (CM == "601P-601N") || (CM == "601P-709") || (CM == "601P-2020") ? "601-625" : \
          (CM == "709-601N") || (CM == "709-601P") || (CM == "709-2020") ? "709" : \
          (CM == "2020-601N") || (CM == "2020-601P") || (CM == "2020-709") ? "2020" : \
          nop()

        PrimaryD = Is601_709 || Is2020M ? "" : \
          (CM == "601P-601N") || (CM == "709-601N") || (CM == "2020-601N") ? "601-525" : \
          (CM == "601N-601P") || (CM == "709-601P") || (CM == "2020-601P") ? "601-625" : \
          (CM == "601N-709") || (CM == "601P-709") || (CM == "2020-709") ? "709" : \
          (CM == "601-2020") || (CM == "601N-2020") || (CM == "601P-2020") || (CM == "709-2020") ? "2020" : \
          nop()

        ChromaSubSampling = !IsChromaSS ? "444" : Is422(Cropped) ? "422" : "420"
        FourFour = "444"
        Transfer1886 = "1886"
        TransferLinear = "Linear"
        To444_S = !IsChromaSS ? "" : ".fmtc_resample(css=FourFour, cplaces=ChromaLocS)"
        To444_D = !IsChromaSS ? "" : ".fmtc_resample(css=FourFour, cplaces=ChromaLocD)"
        From444_S = !IsChromaSS ? "" : ".fmtc_resample(css=ChromaSubSampling, cplaced=ChromaLocS)"
        From444_D = !IsChromaSS ? "" : ".fmtc_resample(css=ChromaSubSampling, cplaced=ChromaLocD)"

        CConvert = Is601_709 || Is2020M ? \
          ".fmtc_matrix(mats=MatrixS, matd=MatrixD, bits=32)" : \
          ".fmtc_matrix(mat=MatrixS, bits=32)" + \
          ".fmtc_transfer(transs=Transfer1886, transd=TransferLinear)" + \
          ".fmtc_primaries(prims=PrimaryS, primd=PrimaryD)" + \
          ".fmtc_transfer(transs=TransferLinear, transd=Transfer1886)" + \
          ".fmtc_matrix(mat=MatrixD, bits=32)"

        Cropped = Eval("Cropped" + To32Bit)
        Cropped_CPlace = Eval("Cropped_CPlace" + To32Bit)

        CConverted = NoResizer ? \
          Eval("Cropped" + To444_S + CConvert + From444_D) : \
          IsRingRepair ? (IsCPlaceResize ? \
          Eval("Cropped_CPlace" + To444_D + CConvert + From444_D) : \
          IsFMTC ? Eval("Cropped" + To444_S + CConvert + From444_S) : \
          Eval("Cropped" + To444_S + CConvert)) : nop()

        CCVideo = NoResizer ? CConverted : \
          IsRingRepair ? (IsCPlaceResize || IsFMTC ? \
          Eval("CConverted" + DoResize + DoRingRepair) : \
          Eval("CConverted" + DoResize + DoRingRepair + From444_D)) : \
          IsZAVSR || IsFMTC || IsResize8 ? (UpScale ? \
          Eval("Cropped" + To444_S + CConvert + From444_S + DoResize) : \
          Eval("Cropped" + DoResize + To444_D + CConvert + From444_D)) : \
          IsCPlaceResize ? (Upscale ? \
          Eval("Cropped_CPlace" + To444_D + CConvert + From444_D + DoResize) : \
          Eval("Cropped_CPlace" + DoResize + To444_D + CConvert + From444_D)) : \
          Upscale ? \
          Eval("Cropped" + To444_S + CConvert + DoResize + From444_D) : \
          Eval("Cropped" + To444_S + DoResize + CConvert + From444_D)

        CCVideo = Eval("CCVideo" + From32Bit + FProp_Transfer) }

    else if (CC == "HDRMatrix") {

# ===============================================================================
#            HDRMatrix
# ===============================================================================

        Assert(Loaded_ConvStack || (Source_Bits == 8), A1 + "The ConvertStacked plugin is required for" + \
          A2 + " color conversion of high bit depth video with HDRMatrix" + A2)
        Assert(Loaded_ConvStack || !IsFMTC, A1 + "The ConvertStacked plugin is required for color" + \
          A2 + " conversion with HDRMatrix when resizing with FMTConv" + A2)
        Assert(Is601_709, A1 + "HDRMatrix can only be used for 'matrix only'" + \
          A2 + " color conversions between Rec.601 and Rec.709" + A2)

# -------------------------------------------------------------------------------

        To16Bit = !Loaded_ConvStack ? "" : To16Bit
        From16Bit = !Loaded_ConvStack ? "" : From16Bit
        Loaded_HDRCore = FunctionExists("Bitdepth")
        Bits = Loaded_ConvStack || Loaded_HDRCore ? 16 : 8

        CConvert = (Loaded_ConvStack ? ".ConvertToDoubleWidth()" : \
          Loaded_HDRCore ? ".Bitdepth(From=8, To=16)" : "") + \
          ((CM == "601-709") ? ".Matrix(From=601, To=709, Bitdepth=Bits)" : \
          ".Matrix(From=709, To=601, Bitdepth=Bits)") + \
          (Loaded_ConvStack ? ".ConvertFromDoubleWidth()" : \
          Loaded_HDRCore ? ".Bitdepth(From=16, To=8)" : "") + FProp_Matrix + FProp_Primaries

        CConverted = NoResizer ? (Loaded_ConvStack ? \
          Eval("Cropped" + To16Bit + CConvert + From16Bit) : Eval("Cropped" + CConvert)) : \
          IsRingRepair ? (IsCPlaceResize ? (Loaded_ConvStack ? \
          Eval("Cropped_CPlace" + To16Bit + CConvert + From16Bit) : Eval("Cropped_CPlace" + CConvert)) : \
          !IsFMTC ? (Loaded_ConvStack ? Eval("Cropped" + To16Bit + CConvert + From16Bit) : \
          Eval("Cropped" + CConvert)) : \
          Eval("Cropped" + To16Bit + CConvert)) : nop()

        CCVideo = NoResizer ? CConverted : IsRingRepair ? \
          (!IsFMTC ? Eval("CConverted" + DoResize + DoRingRepair) : \
          Eval("CConverted" + DoResize + DoRingRepair + From16Bit)) : \
          IsCPlaceResize ? (Loaded_ConvStack ? (Upscale ? \
          Eval("Cropped_CPlace" + To16Bit + CConvert + From16Bit + DoResize) : \
          Eval("Cropped_CPlace" + DoResize + To16Bit + CConvert + From16Bit)) : \
          Upscale ? Eval("Cropped_CPlace" + CConvert + DoResize) : \
          Eval("Cropped_CPlace" + DoResize + CConvert)) : \
          !IsFMTC ? (Loaded_ConvStack ? (Upscale ? \
          Eval("Cropped" + To16Bit + CConvert + From16Bit + DoResize) : \
          Eval("Cropped" + DoResize + To16Bit + CConvert + From16Bit)) : \
          Upscale ? Eval("Cropped" + CConvert + DoResize) : \
          Eval("Cropped" + DoResize + CConvert)) : \
          Upscale ? Eval("Cropped" + To16Bit + CConvert + DoResize + From16Bit) : \
          Eval("Cropped" + To16Bit + DoResize + CConvert + From16Bit) }

    else if (CC == "HDRTools") {

# ===============================================================================
#            HDRTools
# ===============================================================================

        Assert(!IsDResize || NoResizer, \
          A1 + "DitherTools cannot be used for resizing when HDRTools is color converting" + A2)
        Assert(!Is601_709 && !Is2020M, \
          A1 + "A 'matrix only' color conversion cannot be specified when HDRTools is color converting" + A2)

# -------------------------------------------------------------------------------

        ColorA = \
          (CM == "2020-601N") || (CM == "2020-601P") || (CM == "2020-709") ? 1 : \
          (CM == "709-601N") || (CM == "709-601P") || (CM == "709-2020") ? 2 : \
          (CM == "601N-601P") || (CM == "601N-709") || (CM == "601N-2020") ? 3 : \
          (CM == "601P-601N") || (CM == "601P-709") || (CM == "601P-2020") ? 4 : nop()

        ColorB = \
          (CM == "601N-2020") || (CM == "601P-2020") || (CM == "709-2020") ? 1 : \
          (CM == "601N-709") || (CM == "601P-709") || (CM == "2020-709") ? 2 : \
          (CM == "601P-601N") || (CM == "709-601N") || (CM == "2020-601N") ? 3 : \
          (CM == "601N-601P") || (CM == "709-601P") || (CM == "2020-601P") ? 4 : nop()

        CConvert = ".ConvertYUVtoXYZ(Color=ColorA, OutputMode=2)" + \
          ".ConvertXYZtoYUV(Color=ColorB, PColor=ColorA, fastmode=false)"

        Cropped = Eval("Cropped" + To16Bit)
        Cropped_CPlace = Eval("Cropped_CPlace" + To16Bit)

        CConverted = NoResizer ? \
          Eval("Cropped" + To444_S + CConvert + From444_D + FProps) : \
          IsRingRepair ? (IsCPlaceResize ? \
          Eval("Cropped_CPlace" + To444_D + CConvert + From444_D + FProps) : \
          IsFMTC ? Eval("Cropped" + To444_S + CConvert + From444_S + FProps) : \
          Eval("Cropped" + To444_S + CConvert)) : nop()

        CCVideo = NoResizer ? CConverted : \
          IsRingRepair ? (IsCPlaceResize || IsFMTC ? \
          Eval("CConverted" + DoResize + DoRingRepair) : \
          Eval("CConverted" + DoResize + DoRingRepair + From444_D + FProps)) : \
          IsZAVSR || IsFMTC || IsResize8 ? (UpScale ? \
          Eval("Cropped" + To444_S + CConvert + From444_S + FProps + DoResize) : \
          Eval("Cropped" + DoResize + To444_D + CConvert + From444_D + FProps)) : \
          IsCPlaceResize ? (UpScale ? \
          Eval("Cropped_CPlace" + To444_D + CConvert + From444_D + FProps + DoResize) : \
          Eval("Cropped_CPlace" + DoResize + To444_D + CConvert + From444_D + FProps)) : \
          UpScale ? \
          Eval("Cropped" + To444_S + CConvert + DoResize + From444_D + FProps) : \
          Eval("Cropped" + To444_S + DoResize + CConvert + From444_D + FProps)

        CCVideo = Eval("CCVideo" + From16Bit) }

# ===============================================================================

        CCVideo = (CC == "ColorMatrix") || (Color_Format != "YUY2") ? CCVideo : CCVideo.ConvertToYUY2()

        Assert((Color_Format == PixelType(CCVideo)), \
          A1 + "Source=" + Color_Format + ", Output=" + PixelType(CCVideo) + \
          A2 + " Failed to convert back to the original format after " + CC + " color conversion" + A2)

    return CCVideo }

# ===============================================================================
# ===============================================================================
#            Global FrostyB
# ===============================================================================
# ===============================================================================

function FrostyB(clip Source, \
    bool "Frosty", bool "Frosty2", int "FrostyStatic", int "Clone", \
    bool "FrostyGradient", bool "FrostyPlain", bool "Plain", \
    val "BColor", int "BDivider", val "BDColor", int "Feather", \
    float "Bright", float "Cont", float "Sat", float "Gamma", float "Blend", \
    float "Blur", float "VBlur", int "Iterations", float "Threads", \
    int "GPlugin", float "Texture", float "TextureC", \
    bool "StaticT", int "TSoft", bool "TSoftx2") {

    global G_CRFB = true
    global CRFB_Frosty = default(Frosty, true)
    global CRFB_Frosty2 = default(Frosty2, false)
    global CRFB_FrostyStatic = FrostyStatic
    global CRFB_Clone = default(Clone, 0)
    global CRFB_FrostyGradient = default(FrostyGradient, false)
    global CRFB_FrostyPlain = default(FrostyPlain, false)
    global CRFB_Plain = default(Plain, false)
    global CRFB_BColor = BColor
    global CRFB_BDivider = default(BDivider, 0)
    global CRFB_BDColor = default(BDColor, $000000)
    global CRFB_Feather = default(Feather, 0)
    global CRFB_Bright = Bright
    global CRFB_Cont = Cont
    global CRFB_Sat = Sat
    global CRFB_Gamma = Gamma
    global CRFB_Blend = Blend
    global CRFB_Blur = Blur
    global CRFB_VBlur = VBlur
    global CRFB_Iterations = default(Iterations, 3)
    global CRFB_Threads = Threads
    global CRFB_GPlugin = default(GPlugin, 1)
    global CRFB_Texture = Texture
    global CRFB_TextureC = TextureC
    global CRFB_StaticT = default(StaticT, true)
    global CRFB_TSoft = TSoft
    global CRFB_TSoftx2 = TSoftx2

    return Source }

# ===============================================================================
# ===============================================================================
#            Frosty Borders
# ===============================================================================
# ===============================================================================

function CR_FrostyBorders(CRVideo, \
    CRVideo_Width, CRVideo_Height, F_CRVideo_Width, F_CRVideo_Height, \
    BL, BT, BR, BB, WidthMod, HeightMod, F_WidthMod, F_HeightMod, \
    CRVideo_StorageAR, Final_StorageAR, IsResizeMT, Source_Bits, Scale, IsFullRange) {

# ===============================================================================
#            Defaults
# ===============================================================================

    Try{ IsCRFB = G_CRFB }Catch(err){ IsCRFB = false }

    IsYUY2Source = IsYUY2(CRVideo)
    CRVideo = IsYUY2Source ? ConvertToYV16(CRVideo) : CRVideo

    A1 = " CropResize " + chr(10) + " "
    A2 = " " + chr(10)
    IsPillarBox = (0 == BT == BB)
    IsLetterBox = (0 == BL == BR)
    Total_Frames = FrameCount(CRVideo)
    Last_Frame = Total_Frames - 1
    F_VidSize = IsPillarBox ? F_CRVideo_Height : F_CRVideo_Width

    Frosty = IsCRFB ? CRFB_Frosty : true
    Frosty2 = IsCRFB ? CRFB_Frosty2 : false
    IsFrostyStatic = IsCRFB && defined(CRFB_FrostyStatic)
    FrostyStatic = IsFrostyStatic ? CRFB_FrostyStatic : 0
    Clone = IsCRFB ? CRFB_Clone : 0
    Clone1 = (Clone == 1)
    Clone2 = (Clone == 2)
    Clone3 = (Clone == 3)
    FrostyGradient = IsCRFB ? CRFB_FrostyGradient : false
    FrostyPlain = IsCRFB ? CRFB_FrostyPlain : false
    Plain = IsCRFB ? CRFB_Plain : false
    BDivider = IsCRFB ? CRFB_BDivider : 0
    BDColor = IsCRFB ? CRFB_BDColor : $000000
    Feather = IsCRFB ? CRFB_Feather : 0
    IsBlur = IsCRFB && defined(CRFB_Blur)
    IsVBlur = IsCRFB && defined(CRFB_VBlur)
    Iterations = IsCRFB ? CRFB_Iterations : 3
    Threads = IsCRFB ? CRFB_Iterations : undefined()
    GPlugin = IsCRFB ? CRFB_GPlugin : 1
    StaticT = IsCRFB ? CRFB_StaticT : true
    DynamicT = !StaticT

    BorderMin = Frosty || (Frosty && Frosty2) || IsFrostyStatic || FrostyGradient ? \
      (IsPillarBox && (WidthMod == 4) ? 32 : 16) : \
      Clone1 || Clone2 || Clone3 ? (IsPillarBox && (WidthMod == 4) ? 8 : 4) : \
      IsPillarBox ? WidthMod : HeightMod

    SizeTest = (IsPillarBox && (BL >= BorderMin <= BR)) || (IsLetterBox && (BT >= BorderMin <= BB))

    IsBDivider = (BDivider > 0) && \
      ((IsPillarBox && (BL > BorderMin < BR)) || (IsLetterBox && (BT > BorderMin < BB)))
    IsFeather = (Feather > 0) && \
      ((IsPillarBox && (BL >= WidthMod <= BR)) || (IsLetterBox && (BT >= HeightMod <= BB)))

    FrostyPlain = FrostyPlain && !Plain
    FrostyGradient = FrostyGradient && !FrostyPlain && !Plain && SizeTest
    Clone1 = Clone1 || (Clone2 && !IsFeather) && !FrostyGradient && !FrostyPlain && !Plain && SizeTest
    Clone2 = Clone2 && IsFeather && !FrostyGradient && !FrostyPlain && !Plain && SizeTest
    Clone3 = Clone3 && !FrostyGradient && !FrostyPlain && !Plain && SizeTest
    IsClone = Clone1 || Clone2 || Clone3
    IsFrosty = (Frosty || Frosty2 || IsFrostyStatic) && \
      !FrostyGradient && !FrostyPlain && !Plain && !IsClone && SizeTest
    Plain = Plain || (!FrostyGradient && !FrostyPlain && !IsClone && !IsFrosty)
    IsPlain = Plain || FrostyPlain

    Feather = !IsFeather ? 0 : IsPillarBox ? \
      min((Feather < WidthMod) ? WidthMod : \
      Feather, floor(F_CRVideo_Width / 6.0 / F_WidthMod) * WidthMod) : \
      min((Feather < HeightMod) ? HeightMod : \
      Feather, floor(F_CRVideo_Height / 6.0 / F_HeightMod) * HeightMod)

    BColor = IsCRFB && defined(CRFB_BColor) ? CRFB_BColor : \
      FrostyGradient || FrostyPlain ? $008080 : $000000

    Bright = IsCRFB && defined(CRFB_Bright) ? CRFB_Bright : \
      IsPillarBox || IsFrosty || FrostyGradient || Plain ? 0.0 : -20.0

    Cont = IsCRFB && defined(CRFB_Cont) ? CRFB_Cont : \
      IsPillarBox || IsFrosty || FrostyGradient || Plain ? 1.0 : 0.66

    Sat = IsCRFB && defined(CRFB_Sat) ? CRFB_Sat : \
      FrostyGradient || Plain ? 1.0 : IsPillarBox ? 0.85 : 0.66

    Gamma = IsCRFB && defined(CRFB_Gamma) ? CRFB_Gamma : IsFrosty && IsLetterBox ? 0.5 : 1.0

    Blend = IsCRFB && defined(CRFB_Blend) ? CRFB_Blend : \
      IsFrostyStatic ? 0.5 : IsFrosty ? (IsPillarBox ? 0.2 : 0.1) : 0.0

    Blur = IsBlur ? ((CRFB_Blur >= 0) ? CRFB_Blur : -CRFB_Blur * F_VidSize / 720.0) : \
      Clone1 || Clone2 ? F_VidSize / 75.0 : Clone3 ? F_VidSize / 25.0 : 0.0

    VBlur = IsVBlur ? ((CRFB_VBlur >= 0) ? CRFB_VBlur : -CRFB_VBlur * F_VidSize / 720.0) : \
     IsBlur || IsClone ? Blur : 0.0

    Texture = IsCRFB && defined(CRFB_Texture) ? CRFB_Texture : IsClone ? 2.5 : !Plain ? 5.0 : 0
    Texture = (Texture == 0) || (GPlugin == 0) ? 0 : (GPlugin == 1) ? Texture : round(Texture * 64.0)
    TextureC = IsCRFB && defined(CRFB_TextureC) ? CRFB_TextureC : 0
    TextureC = (TextureC == 0) || (GPlugin == 0) ? 0 : (GPlugin == 1) ? TextureC : round(TextureC * 64.0)

    TSoft = IsCRFB && defined(CRFB_TSoft) ? CRFB_TSoft : IsFrostyStatic ? 0 : IsFrosty ? 5 : Clone3 ? 1 : 0
    IsTSoft = (TSoft > 0) && (IsFrosty || IsClone)
    TSoftx2 = IsTSoft && IsCRFB && defined(CRFB_TSoftx2) && CRFB_TSoftx2

# ===============================================================================
#            Insist
# ===============================================================================

    Assert((0 <= FrostyStatic <= Last_Frame), \
      A1 + "The valid range for FrostyStatic is from zero to the final frame number " + \
      string(Last_Frame, "(0 to %.0f)") + A2)
    Assert(!IsPillarBox || (BDivider <= 0) || (WidthMod != 2) || ((BDivider % 2) == 0), \
      A1 + PixelType(CRVideo) + " requires a Mod2 BDivider for pillarbox borders" + A2)
    Assert(!IsPillarBox || (BDivider <= 0) || (WidthMod != 4) || ((BDivider % 4) == 0), \
      A1 + PixelType(CRVideo) + " requires a Mod4 BDivider for pillarbox borders" + A2)
    Assert(!IsLetterBox || (BDivider <= 0) || (HeightMod != 2) || ((BDivider % 2) == 0), \
      A1 + PixelType(CRVideo) + " requires a Mod2 BDivider for letterbox borders" + A2)
    Assert((Feather == 0) || (BDivider <= 0), \
      A1 + "Feather and BDivider cannot be used together (one must equal zero)" + A2)
    Assert((Feather == 0) || !FrostyGradient, \
      A1 + "Feather cannot be greater than zero when FrostyGradient=true" + A2)
    Assert((0 <= GPlugin <= 2), A1 + "The valid choices for GPlugin are" + \
      A2 + " 0 (no added grain), 1 (AddGrainC) or 2 (neo_f3kdb)" + A2)
    Assert((0 <= Clone <= 3), A1 + "Clone can only be 0 (disabled), 1, 2 or 3" + A2)
    Assert((-255 <= Bright <= 255), A1 + "The valid range for Bright is -255 thru 255" + A2)
    Assert((0 <= Cont <= 10), A1 + "The valid range for Cont is 0.0 thru 10.0" + A2)
    Assert((0 <= Sat <= 10), A1 + "The valid range for Sat is 0.0 thru 10.0" + A2)
    Assert((0 <= Blend <= 1), A1 + "The valid range for Blend is 0.0 to 1.0" + A2)
    Assert((Texture >= 0 <= TextureC), A1 + "Texture and TextureC cannot be negative" + A2)
    Assert((0 <= TSoft <= 7), A1 + "The valid range for TSoft is 0 to 7" + A2)

# ===============================================================================
#            PillarBox & LetterBox Strings
# ===============================================================================

    FastBlurStr = (IsPlain && !IsFeather) || FrostyGradient || (Iterations <= 0) ? "" : \
      ".FastBlur(Blur, y_blur=VBlur, iterations=Iterations, dither=true, threads=Threads)"

    GammaStr = (Gamma == 1) ? "" : \
      !IsFullRange ? ".Levels(16*Scale, Gamma, 235*Scale, 16*Scale, 235*Scale, coring=false)" : \
      ".Levels(0, Gamma, 255*Scale, 0, 255*Scale, coring=false)"

    GrainStr = (Texture == 0 == TextureC) || (GPlugin == 0) ? "" : \
      (GPlugin == 1) ? ".AddGrainC(var=Texture, uvar=TextureC, constant=StaticT)" : \
      ".neo_f3kdb(grainY=Texture, grainC=TextureC, dither_algo=1, " + \
      "dynamic_grain=DynamicT, output_depth=Source_Bits)"

    LoopStr = ".Trim(1, 1).Loop(Total_Frames)"
    SLoopStr = IsFrostyStatic ? ".Trim(FrostyStatic, end=FrostyStatic).Loop(Total_Frames)" : ""
    TSoftStr = IsTSoft ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" + \
      (TSoftx2 ? ".TemporalSoften(TSoft, 255, 255, 20, 2)" : "") : ""
    TweakStr = (Bright != 0.0) || (Cont != 1.0) || (Sat != 1.0) ? \
      ".Tweak(bright=Bright, cont=Cont, sat=Sat, realcalc=true, dither=true)" : ""

# ===============================================================================
#            PillarBox Borders
# ===============================================================================

    if (IsPillarBox) {

        BL = IsBDivider ? BL - BDivider : BL
        BR = IsBDivider ? BR - BDivider : BR
        FL = IsFeather ? max(BL, floor((BL + (Feather * 3)) / F_WidthMod) * WidthMod) : 0
        FR = IsFeather ? max(BR, floor((BR + (Feather * 3)) / F_WidthMod) * WidthMod) : 0

# -------------------------------------------------------------------------------
#            PillarBox Strings
# -------------------------------------------------------------------------------

        CRVideoStr = !IsBDivider ? ",CRVideo," : \
          ",CRVideo.AddBorders(BDivider, 0, BDivider, 0, color=BDColor),"

        BordStr = ".AddBorders(0, 0, CRVideo_Width-FL+BL-FR+BR, 0),"

        GaussResizeLStr = \
          !IsPlain ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(BL, CRVideo_Height)" : ""
        GaussResizeRStr = \
          !IsPlain ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(BR, CRVideo_Height)" : ""

        FGaussResizeLStr = \
          IsFeather ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(FL, CRVideo_Height)" : ""
        FGaussResizeRStr = \
          IsFeather ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(FR, CRVideo_Height)" : ""

        GaussResize3LStr = Clone3 ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + \
          "(max(BL, floor(WidthCloneBL * RatioL / F_WidthMod) * WidthMod), " + \
          "max(CRVideo_Height, floor(CRVideo_Height * RatioL / F_HeightMod) * HeightMod))" : ""
        GaussResize3RStr = Clone3 ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + \
          "(max(BR, floor(WidthCloneBR * RatioR / F_WidthMod) * WidthMod), " + \
          "max(CRVideo_Height, floor(CRVideo_Height * RatioR / F_HeightMod) * HeightMod))" : ""

# -------------------------------------------------------------------------------
#            PillarBox Frosty Borders
# -------------------------------------------------------------------------------

        if (IsFrosty) {

            MaxFrostyC = IsFeather ? floor(F_CRVideo_Width / 2.0 / F_WidthMod) * WidthMod : nop()
            FrostyCropL = IsFeather ? max(MaxFrostyC, CRVideo_Width - BL) : nop()
            FrostyCropR = IsFeather ? max(MaxFrostyC, CRVideo_Width - BR) : nop()
            FrostyBL = IsFeather ? CRVideo.crop(0, 0, -FrostyCropL, 0) : nop()
            FrostyBR = IsFeather ? CRVideo.crop(FrostyCropR, 0, 0, 0) : nop()
            WidthFrostyBL = IsFeather ? width(FrostyBL) : nop()
            WidthFrostyBR = IsFeather ? width(FrostyBR) : nop()

            FlipFrostyL = IsFeather ? FlipHorizontal((WidthFrostyBL == BL) ? FrostyBL : \
              Eval("FrostyBL" + GaussResizeLStr)) : nop()
            FlipFrostyR = IsFeather ? FlipHorizontal((WidthFrostyBR == BR) ? FrostyBR : \
              Eval("FrostyBR" + GaussResizeRStr)) : nop()

            FrostyCrop = \
              CRVideo_Width - max(BorderMin, floor(F_CRVideo_Width / 4.0 / F_WidthMod) * WidthMod)

            Blur = IsBlur ? Blur : float(FrostyCrop) / (!Frosty2 ? 16.0 : 4.0)
            VBlur = IsVBlur ? VBlur : F_CRVideo_Height / 10.0
            FastBlurStr = (Blur == 0 == VBlur) ? "" : FastBlurStr

            FrostyLR = Eval("StackHorizontal(CRVideo.crop(0, 0, -FrostyCrop, 0), " + \
              "CRVideo.crop(FrostyCrop, 0, 0, 0))" + TSoftStr + FastBlurStr)

            FrostyCrop = \
              width(FrostyLR) - max(BorderMin, floor(width(FrostyLR) / 20.0 / F_WidthMod) * WidthMod)

            FrostyL = FrostyLR.crop(0, 0, -FrostyCrop, 0)
            FrostyR = FrostyLR.crop(FrostyCrop, 0, 0, 0)

            FrostyBlendL = (Blend == 0) ? FrostyL : (Blend == 1) ? FrostyR : \
              Overlay(FrostyL, FlipHorizontal(FrostyR), Opacity=Blend)
            FrostyBlendR = (Blend == 0) ? FrostyR : (Blend == 1) ? FrostyL : \
              Overlay(FrostyR, FlipHorizontal(FrostyL), Opacity=Blend)

            FrostyL = !IsFeather ? \
              Eval("FrostyBlendL" + GaussResizeLStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop()
            FrostyR = !IsFeather ? \
              Eval("FrostyBlendR" + GaussResizeRStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop()

            FFrostyL = IsFeather ? \
              Eval("FrostyBlendL" + FGaussResizeLStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop()
            FFrostyR = IsFeather ? \
              Eval("FrostyBlendR" + FGaussResizeRStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop() }

        else { FastBlurStr = (Blur == 0 == VBlur) ? "" : FastBlurStr }

# -------------------------------------------------------------------------------
#            PillarBox Clone Borders
# -------------------------------------------------------------------------------

        if (IsClone) {

            MaxCloneC = floor(F_CRVideo_Width / 2.0 / F_WidthMod) * WidthMod
            CloneCropL = max(MaxCloneC, CRVideo_Width - BL)
            CloneCropR = max(MaxCloneC, CRVideo_Width - BR)
            CloneBL = CRVideo.crop(0, 0, -CloneCropL, 0)
            CloneBR = CRVideo.crop(CloneCropR, 0, 0, 0)
            WidthCloneBL = width(CloneBL)
            WidthCloneBR = width(CloneBR)

            FlipCloneL = \
              FlipHorizontal((WidthCloneBL == BL) ? CloneBL : Eval("CloneBL" + GaussResizeLStr))
            FlipCloneR = \
              FlipHorizontal((WidthCloneBR == BR) ? CloneBR : Eval("CloneBR" + GaussResizeRStr))

            CloneLR = (Clone1 || Clone3) && IsTSoft ? \
              Eval("StackHorizontal(CloneBL, CloneBR)" + TSoftStr) : nop()

            CloneL = Clone1 || Clone3 ? \
              (IsTSoft ? CloneLR.crop(0, 0, -width(CloneLR)+WidthCloneBL, 0) : CloneBL) : nop()
            CloneR = Clone1 || Clone3 ? \
              (IsTSoft ? CloneLR.crop(width(CloneLR)-WidthCloneBR, 0, 0, 0) : CloneBR) : nop()

            CloneBlendL = Clone1 || Clone3 ? ((Blend == 0) ? CloneL : (Blend == 1) ? CloneR : \
              Overlay(CloneL, FlipHorizontal(CloneR), Opacity=Blend)) : nop()
            CloneBlendR = Clone1 || Clone3 ? ((Blend == 0) ? CloneR : (Blend == 1) ? CloneL : \
              Overlay(CloneR, FlipHorizontal(CloneL), Opacity=Blend)) : nop()

            CloneL = Clone1 && !IsFeather ? Eval("CloneBlendL" + FastBlurStr + \
              ((WidthCloneBL == BL) ? "" : GaussResizeLStr) + GammaStr + TweakStr + GrainStr) : nop()
            CloneR = Clone1 && !IsFeather ? Eval("CloneBlendR" + FastBlurStr + \
              ((WidthCloneBR == BR) ? "" : GaussResizeRStr) + GammaStr + TweakStr + GrainStr) : nop()

            FCloneL = Clone1 && IsFeather ? Eval("CloneBlendL" + \
              ((WidthCloneBL == BL) ? "" : GaussResizeLStr) + GammaStr + TweakStr) : nop()
            FCloneR = Clone1 && IsFeather ? Eval("CloneBlendR" + \
              ((WidthCloneBR == BR) ? "" : GaussResizeRStr) + GammaStr + TweakStr) : nop() }

# -------------------------------------------------------------------------------
#            PillarBox Clone2 Borders
# -------------------------------------------------------------------------------

        if (Clone2) {

            Clone2CropL = max(MaxCloneC, CRVideo_Width - FL)
            Clone2CropR = max(MaxCloneC, CRVideo_Width - FR)
            Clone2BL = CRVideo.crop(0, 0, -Clone2CropL, 0)
            Clone2BR = CRVideo.crop(Clone2CropR, 0, 0, 0)
            WidthClone2BL = width(Clone2BL)
            WidthClone2BR = width(Clone2BR)

            Clone2LR = IsTSoft ? Eval("StackHorizontal(Clone2BL, Clone2BR)" + TSoftStr) : nop()

            Clone2L = IsTSoft ? Clone2LR.crop(0, 0, -width(Clone2LR)+WidthClone2BL, 0) : Clone2BL
            Clone2R = IsTSoft ? Clone2LR.crop(width(Clone2LR)-WidthClone2BR, 0, 0, 0) : Clone2BR

            Clone2BlendL = (Blend == 0) ? Clone2L : (Blend == 1) ? Clone2R : \
              Overlay(Clone2L, FlipHorizontal(Clone2R), Opacity=Blend)
            Clone2BlendR = (Blend == 0) ? Clone2R : (Blend == 1) ? Clone2L : \
              Overlay(Clone2R, FlipHorizontal(Clone2L), Opacity=Blend)

            FClone2L = Eval("Clone2BlendL" + FastBlurStr + \
              ((WidthClone2BL == FL) ? "" : FGaussResizeLStr) + GammaStr + TweakStr + GrainStr)
            FClone2R = Eval("Clone2BlendR" + FastBlurStr + \
              ((WidthClone2BR == FR) ? "" : FGaussResizeLStr) + GammaStr + TweakStr + GrainStr) }

# -------------------------------------------------------------------------------
#            PillarBox Clone3 Borders
# -------------------------------------------------------------------------------

        if (Clone3) {

            RatioL = ((WidthCloneBL - BL) >= 0) ? 1.618 : float(BL) / float(WidthCloneBL)
            RatioR = ((WidthCloneBR - BR) >= 0) ? 1.618 : float(BR) / float(WidthCloneBR)

            Clone3L = Eval("CloneBlendL" + GaussResize3LStr)
            Clone3R = Eval("CloneBlendR" + GaussResize3RStr)
            WidthClone3L = width(Clone3L)
            HeightClone3L = height(Clone3L)
            WidthClone3R = width(Clone3R)
            HeightClone3R = height(Clone3R)

            Clone3L_CL = max(0, floor((WidthClone3L - BL) / F_WidthMod / 2.0) * WidthMod)
            Clone3L_CR = max(0, WidthClone3L - BL - Clone3L_CL)
            Clone3L_CT = max(0, floor((HeightClone3L - CRVideo_Height) / F_HeightMod / 2.0) * HeightMod)
            Clone3L_CB = max(0, HeightClone3L - CRVideo_Height - Clone3L_CT)
            Clone3R_CL = max(0, floor((WidthClone3R - BR) / F_WidthMod / 2.0) * WidthMod)
            Clone3R_CR = max(0, WidthClone3R - BR - Clone3R_CL)
            Clone3R_CT = max(0, floor((HeightClone3R - CRVideo_Height) / F_HeightMod / 2.0) * HeightMod)
            Clone3R_CB = max(0, HeightClone3R - CRVideo_Height - Clone3R_CT)

            FClone3L = \
              Eval("Clone3L.crop(Clone3L_CL, Clone3L_CT, -Clone3L_CR, -Clone3L_CB)" + GammaStr + TweakStr)
            FClone3R = \
              Eval("Clone3R.crop(Clone3R_CL, Clone3R_CT, -Clone3R_CR, -Clone3R_CB)" + GammaStr + TweakStr)

            Clone3L = !IsFeather ? Eval("FClone3L" + FastBlurStr + GrainStr) : nop()
            Clone3R = !IsFeather ? Eval("FClone3R" + FastBlurStr + GrainStr) : nop() }

# -------------------------------------------------------------------------------
#            PillarBox FrostyGradient Borders
# -------------------------------------------------------------------------------

        if (FrostyGradient) {

            GradientLR = Eval("BlankClip(CRVideo, width=72, height=CRVideo_Height)" + \
              ".AddBorders(24, 0, 0, 0, color=BColor)" + \
              ".FastBlur(30, y_blur=0, iterations=3, dither=true, threads=Threads, gamma=false)")

            GradientL = Eval("FlipHorizontal(GradientLR)" + \
              GaussResizeLStr + GammaStr + TweakStr + GrainStr + LoopStr)
            GradientR = Eval("GradientLR" + \
              GaussResizeRStr + GammaStr + TweakStr + GrainStr + LoopStr) }

# -------------------------------------------------------------------------------
#            PillarBox Plain Borders
# -------------------------------------------------------------------------------

        if (IsPlain) {

            TweakPL = (BL >= WidthMod) ? \
              Eval("BlankClip(CRVideo, width=BL, color=BColor)" + GammaStr + TweakStr) : nop()
            TweakPR = (BR >= WidthMod) ? \
              Eval("BlankClip(CRVideo, width=BR, color=BColor)" + GammaStr + TweakStr) : nop()

            PlainL = (BL >= WidthMod) && !IsFeather ? Eval("TweakPL" + GrainStr + LoopStr) : nop()
            PlainR = (BR >= WidthMod) && !IsFeather ? Eval("TweakPR" + GrainStr + LoopStr) : nop()

            FPlainL = (BL >= WidthMod) && IsFeather ? Eval("TweakPL" + LoopStr) : nop()
            FPlainR = (BR >= WidthMod) && IsFeather ? Eval("TweakPR" + LoopStr) : nop() }

# -------------------------------------------------------------------------------
#            PillarBox Frosty Clip
# -------------------------------------------------------------------------------

        FrostyBL = !IsFeather ? (IsFrosty ? FrostyL : Clone1 ? CloneL : Clone3 ? Clone3L : \
          FrostyGradient ? GradientL : IsPlain && (BL >= WidthMod) ? PlainL : nop()) : \
          IsFrosty ? FlipFrostyL : IsClone ? FlipCloneL : IsPlain && (BL >= WidthMod) ? FPlainL : nop()

        FrostyBR = !IsFeather ? (IsFrosty ? FrostyR : Clone1 ? CloneR : Clone3 ? Clone3R : \
          FrostyGradient ? GradientR :IsPlain && (BR >= WidthMod) ? PlainR : nop()) : \
          IsFrosty ? FlipFrostyR : IsClone ? FlipCloneR : IsPlain && (BR >= WidthMod) ? FPlainR : nop()

        FrostyClip = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BL >= WidthMod <= BR)) ? \
          Eval("StackHorizontal(FrostyBL" + CRVideoStr + "FrostyBR)") : \
          IsPlain && (BL >= WidthMod) ? StackHorizontal(FrostyBL, CRVideo) : \
          IsPlain && (BR >= WidthMod) ? StackHorizontal(CRVideo, FrostyBR) : CRVideo

# -------------------------------------------------------------------------------
#            PillarBox Feather Mask
# -------------------------------------------------------------------------------

        if (IsFeather) {

            MBlur = round(max(0, Feather / 2.25))

            MFastBlurStr = (MBlur == 0) ? "" : \
              ".FastBlur(MBlur, y_blur=0, iterations=Iterations, dither=true, threads=Threads, gamma=false)"

            FeatherMask = BlankClip(CRVideo, width=CRVideo_Width-(Feather*2))\
              .AddBorders(BL+Feather, 0, BR+Feather, 0, color=$FFFFFF).ColorYUV(Levels="TV->PC")

            FeatherMask = Eval("FeatherMask" + MFastBlurStr + LoopStr)

# -------------------------------------------------------------------------------
#            PillarBox Feather Clip
# -------------------------------------------------------------------------------

            FeatherClip = IsFrosty ? \
              Eval("StackHorizontal(FFrostyL" + BordStr + "FFrostyR)") : \
              Clone1 ? Eval("StackHorizontal(" + \
              "StackHorizontal(FCloneL, CRVideo.crop(0, 0, -CRVideo_Width+FL-BL, 0))" + \
              FastBlurStr + GrainStr + BordStr + \
              "StackHorizontal(CRVideo.crop(CRVideo_Width-FR+BR, 0, 0, 0), FCloneR)" + \
              FastBlurStr + GrainStr + ")")  : \
              Clone2 ? Eval("StackHorizontal(FClone2L" + BordStr + "FClone2R)") : \
              Clone3 ? Eval("StackHorizontal(" + \
              "StackHorizontal(FClone3L, CRVideo.crop(0, 0, -CRVideo_Width+FL-BL, 0))" + \
              FastBlurStr + GrainStr + BordStr + \
              "StackHorizontal(CRVideo.crop(CRVideo_Width-FR+BR, 0, 0, 0), FClone3R)" + \
              FastBlurStr + GrainStr + ")") : \
              Eval("StackHorizontal(BlankClip(CRVideo, width=FL, color=BColor)" + \
              GammaStr + TweakStr + GrainStr + LoopStr + BordStr + \
              "BlankClip(CRVideo, width=FR, color=BColor)" + \
              GammaStr + TweakStr + GrainStr + LoopStr + ")") }

# -------------------------------------------------------------------------------
#            PillarBox Output
# -------------------------------------------------------------------------------

        FrostyOut = IsFeather ? Overlay(FrostyClip, FeatherClip, mask=FeatherMask) : FrostyClip }

# ===============================================================================
#            LetterBox Borders
# ===============================================================================

    if (IsLetterBox) {

        BT = IsBDivider ? BT - BDivider : BT
        BB = IsBDivider ? BB - BDivider : BB
        FT = IsFeather ? max(BT, floor((BT + (Feather * 3)) / F_HeightMod) * HeightMod) : 0
        FB = IsFeather ? max(BB, floor((BB + (Feather * 3)) / F_HeightMod) * HeightMod) : 0

# -------------------------------------------------------------------------------
#            LetterBox Strings
# -------------------------------------------------------------------------------

        CRVideoStr = !IsBDivider ? ",CRVideo," : \
          ",CRVideo.AddBorders(0, BDivider, 0, BDivider, color=BDColor),"

        BordStr = ".AddBorders(0, 0, 0, CRVideo_Height-FT+BT-FB+BB),"

        GaussResizeTStr = !IsPlain ? \
          ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(CRVideo_Width, BT)" : ""
        GaussResizeBStr = !IsPlain ? \
          ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(CRVideo_Width, BB)" : ""

        FGaussResizeTStr = IsFeather ? \
          ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(CRVideo_Width, FT)" : ""
        FGaussResizeBStr = IsFeather ? \
          ".GaussResize" + (!IsResizeMT ? "" : "MT") + "(CRVideo_Width, FB)" : ""

        GaussResize3TStr = Clone3 ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + \
          "(max(CRVideo_Width, floor(CRVideo_Width * RatioT / F_WidthMod) * WidthMod), " + \
          "max(BT, floor(HeightCloneBT * RatioT / F_HeightMod) * HeightMod))" : ""
        GaussResize3BStr = Clone3 ? ".GaussResize" + (!IsResizeMT ? "" : "MT") + \
          "(max(CRVideo_Width, floor(CRVideo_Width * RatioB / F_WidthMod) * WidthMod), " + \
          "max(BB, floor(HeightCloneBB * RatioB / F_HeightMod) * HeightMod))" : ""

# -------------------------------------------------------------------------------
#            LetterBox Frosty Borders
# -------------------------------------------------------------------------------

        if (IsFrosty) {

            MaxFrostyC = IsFeather ? floor(F_CRVideo_Height / 2.0 / F_HeightMod) * HeightMod : nop()
            FrostyCropT = IsFeather ? max(MaxFrostyC, CRVideo_Height - BT) : nop()
            FrostyCropB = IsFeather ? max(MaxFrostyC, CRVideo_Height - BB) : nop()
            FrostyBT = IsFeather ? CRVideo.crop(0, 0, 0, -FrostyCropT) : nop()
            FrostyBB = IsFeather ? CRVideo.crop(0, FrostyCropB, 0, 0) : nop()
            HeightFrostyBT = IsFeather ? height(FrostyBT) : nop()
            HeightFrostyBB = IsFeather ? height(FrostyBB) : nop()

            FlipFrostyT = IsFeather ? FlipVertical((HeightFrostyBT == BT) ? FrostyBT : \
              Eval("FrostyBT" + GaussResizeTStr)) : nop()
            FlipFrostyB = IsFeather ? FlipVertical((HeightFrostyBB == BB) ? FrostyBB : \
              Eval("FrostyBB" + GaussResizeBStr)) : nop()

            FrostyCrop = \
              CRVideo_Height - max(BorderMin, floor(F_CRVideo_Height / 4.0 / F_HeightMod) * HeightMod)

            Blur = IsBlur ? Blur : F_CRVideo_Width / 10.0
            VBlur = IsVBlur ? VBlur : float(FrostyCrop) / (!Frosty2 ? 16.0 : 4.0)
            FastBlurStr = (Blur == 0 == VBlur) ? "" : FastBlurStr

            FrostyTB = Eval("StackVertical(CRVideo.crop(0, 0, 0, -FrostyCrop), " + \
              "CRVideo.crop(0, FrostyCrop, 0, 0))" + TSoftStr + FastBlurStr)

            FrostyCrop = \
              height(FrostyTB) - max(BorderMin, floor(height(FrostyTB) / 20.0 / F_HeightMod) * HeightMod)

            FrostyT = FrostyTB.crop(0, 0, 0, -FrostyCrop)
            FrostyB = FrostyTB.crop(0, FrostyCrop, 0, 0)

            FrostyBlendT = (Blend == 0) ? FrostyT : (Blend == 1) ? FrostyB : \
              Overlay(FrostyT, FlipVertical(FrostyB), Opacity=Blend)
            FrostyBlendB = (Blend == 0) ? FrostyB : (Blend == 1) ? FrostyT : \
              Overlay(FrostyB, FlipVertical(FrostyT), Opacity=Blend)

            FrostyT = !IsFeather ? \
              Eval("FrostyBlendT" + GaussResizeTStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop()
            FrostyB = !IsFeather ? \
              Eval("FrostyBlendB" + GaussResizeBStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop()

            FFrostyT = IsFeather ? \
              Eval("FrostyBlendT" + FGaussResizeTStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop()
            FFrostyB = IsFeather ? \
              Eval("FrostyBlendB" + FGaussResizeBStr + GammaStr + TweakStr + GrainStr + SLoopStr) : nop() }

        else { FastBlurStr = (Blur == 0 == VBlur) ? "" : FastBlurStr }

# -------------------------------------------------------------------------------
#            LetterBox Clone Borders
# -------------------------------------------------------------------------------

        if (IsClone) {

            MaxCloneC = floor(F_CRVideo_Height / 2.0 / F_HeightMod) * HeightMod
            CloneCropT = max(MaxCloneC, CRVideo_Height - BT)
            CloneCropB = max(MaxCloneC, CRVideo_Height - BB)
            CloneBT = CRVideo.crop(0, 0, 0, -CloneCropT)
            CloneBB = CRVideo.crop(0, CloneCropB, 0, 0)
            HeightCloneBT = height(CloneBT)
            HeightCloneBB = height(CloneBB)

            FlipCloneT = \
              FlipVertical((HeightCloneBT == BT) ? CloneBT : Eval("CloneBT" + GaussResizeTStr))
            FlipCloneB = \
              FlipVertical((HeightCloneBB == BB) ? CloneBB : Eval("CloneBB" + GaussResizeBStr))

            CloneTB = (Clone1 || Clone3) && IsTSoft ? \
              Eval("StackVertical(CloneBT, CloneBB)" + TSoftStr) : nop()

            CloneT = Clone1 || Clone3 ? \
              (IsTSoft ? CloneTB.crop(0, 0, 0, -height(CloneTB)+HeightCloneBT) : CloneBT) : nop()
            CloneB = Clone1 || Clone3 ? \
              (IsTSoft ? CloneTB.crop(0, height(CloneTB)-HeightCloneBB, 0, 0) : CloneBB) : nop()

            CloneBlendT = Clone1 || Clone3 ? ((Blend == 0) ? CloneT : (Blend == 1) ? CloneB : \
              Overlay(CloneT, FlipVertical(CloneB), Opacity=Blend)) : nop()
            CloneBlendB = Clone1 || Clone3 ? ((Blend == 0) ? CloneB : (Blend == 1) ? CloneT : \
              Overlay(CloneB, FlipVertical(CloneT), Opacity=Blend)) : nop()

            CloneT = Clone1 && !IsFeather ? Eval("CloneBlendT" + FastBlurStr + \
              ((HeightCloneBT == BT) ? "" : GaussResizeTStr) + GammaStr + TweakStr + GrainStr) : nop()
            CloneB = Clone1 && !IsFeather ? Eval("CloneBlendB" + FastBlurStr + \
              ((HeightCloneBB == BB) ? "" : GaussResizeBStr) + GammaStr + TweakStr + GrainStr) : nop()

            FCloneT = Clone1 && IsFeather ? Eval("CloneBlendT" + \
              ((HeightCloneBT == BT) ? "" : GaussResizeTStr) + GammaStr + TweakStr) : nop()
            FCloneB = Clone1 && IsFeather ? Eval("CloneBlendB" + \
              ((HeightCloneBB == BB) ? "" : GaussResizeBStr) + GammaStr + TweakStr) : nop() }

# -------------------------------------------------------------------------------
#            LetterBox Clone2 Borders
# -------------------------------------------------------------------------------

        if (Clone2) {

            Clone2CropT = max(MaxCloneC, CRVideo_Height - FT)
            Clone2CropB = max(MaxCloneC, CRVideo_Height - FB)
            Clone2BT = CRVideo.crop(0, 0, 0, -Clone2CropT)
            Clone2BB = CRVideo.crop(0, Clone2CropB, 0, 0)
            HeightClone2BT = height(Clone2BT)
            HeightClone2BB = height(Clone2BB)

            Clone2TB = IsTSoft ? Eval("StackVertical(Clone2BT, Clone2BB)" + TSoftStr) : nop()

            Clone2T = IsTSoft ? Clone2TB.crop(0, 0, 0, -height(Clone2TB)+HeightClone2BT) : Clone2BT
            Clone2B = IsTSoft ? Clone2TB.crop(0, height(Clone2TB)-HeightClone2BB, 0, 0) : Clone2BB

            Clone2BlendT = (Blend == 0) ? Clone2T : (Blend == 1) ? Clone2B : \
              Overlay(Clone2T, FlipVertical(Clone2B), Opacity=Blend)
            Clone2BlendB = (Blend == 0) ? Clone2B : (Blend == 1) ? Clone2T : \
              Overlay(Clone2B, FlipVertical(Clone2T), Opacity=Blend)

            FClone2T = Eval("Clone2BlendT" + FastBlurStr + \
              ((HeightClone2BT == FT) ? "" : FGaussResizeTStr) + GammaStr + TweakStr + GrainStr)
            FClone2B = Eval("Clone2BlendB" + FastBlurStr + \
              ((HeightClone2BB == FB) ? "" : FGaussResizeBStr) + GammaStr + TweakStr + GrainStr) }

# -------------------------------------------------------------------------------
#            LetterBox Clone3 Borders
# -------------------------------------------------------------------------------

        if (Clone3) {

            RatioT = ((HeightCloneBT - BT) >= 0) ? 1.618 : float(BT) / float(HeightCloneBT)
            RatioB = ((HeightCloneBB - BB) >= 0) ? 1.618 : float(BB) / float(HeightCloneBB)

            Clone3T = Eval("CloneBlendT" + GaussResize3TStr)
            Clone3B = Eval("CloneBlendB" + GaussResize3BStr)
            WidthClone3T = width(Clone3T)
            HeightClone3T = height(Clone3T)
            WidthClone3B = width(Clone3B)
            HeightClone3B = height(Clone3B)

            Clone3T_CL = max(0, floor((WidthClone3T - CRVideo_Width) / F_WidthMod / 2.0) * WidthMod)
            Clone3T_CR = max(0, WidthClone3T - CRVideo_Width - Clone3T_CL)
            Clone3T_CT = max(0, floor((HeightClone3T - BT) / F_HeightMod / 2.0) * HeightMod)
            Clone3T_CB = max(0, HeightClone3T - BT - Clone3T_CT)
            Clone3B_CL = max(0, floor((WidthClone3B - CRVideo_Width) / F_WidthMod / 2.0) * WidthMod)
            Clone3B_CR = max(0, WidthClone3B - CRVideo_Width - Clone3B_CL)
            Clone3B_CT = max(0, floor((HeightClone3B - BB) / F_HeightMod / 2.0) * HeightMod)
            Clone3B_CB = max(0, HeightClone3B - BB - Clone3B_CT)

            FClone3T = \
              Eval("Clone3T.crop(Clone3T_CL, Clone3T_CT, -Clone3T_CR, -Clone3T_CB)" + GammaStr + TweakStr)
            FClone3B = \
              Eval("Clone3B.crop(Clone3B_CL, Clone3B_CT, -Clone3B_CR, -Clone3B_CB)" + GammaStr + TweakStr)

            Clone3T = !IsFeather ? Eval("FClone3T" + FastBlurStr + GrainStr) : nop()
            Clone3B = !IsFeather ? Eval("FClone3B" + FastBlurStr + GrainStr) : nop() }

# -------------------------------------------------------------------------------
#            LetterBox FrostyGradient Borders
# -------------------------------------------------------------------------------

        if (FrostyGradient) {

            GradientTB = Eval("BlankClip(CRVideo, width=CRVideo_Width, height=72)" + \
              ".AddBorders(0, 24, 0, 0, color=BColor)" + \
              ".FastBlur(0, y_blur=30, iterations=3, dither=true, threads=Threads, gamma=false)")

            GradientT = Eval("FlipVertical(GradientTB)" + \
              GaussResizeTStr + GammaStr + TweakStr + GrainStr + LoopStr)
            GradientB = Eval("GradientTB" + \
              GaussResizeBStr + GammaStr + TweakStr + GrainStr + LoopStr) }

# -------------------------------------------------------------------------------
#            LetterBox Plain Borders
# -------------------------------------------------------------------------------

        if (IsPlain) {

            TweakPT = (BT >= HeightMod) ? \
              Eval("BlankClip(CRVideo, height=BT, color=BColor)" + GammaStr + TweakStr) : nop()
            TweakPB = (BB >= HeightMod) ? \
              Eval("BlankClip(CRVideo, height=BB, color=BColor)" + GammaStr + TweakStr) : nop()

            PlainT = (BT >= HeightMod) && !IsFeather ? Eval("TweakPT" + GrainStr + LoopStr) : nop()
            PlainB = (BB >= HeightMod) && !IsFeather ? Eval("TweakPB" + GrainStr + LoopStr) : nop()

            FPlainT = (BT >= HeightMod) && IsFeather ? Eval("TweakPT" + LoopStr) : nop()
            FPlainB = (BB >= HeightMod) && IsFeather ? Eval("TweakPB" + LoopStr) : nop() }

# -------------------------------------------------------------------------------
#            LetterBox Frosty Clip
# -------------------------------------------------------------------------------

        FrostyBT = !IsFeather ? (IsFrosty ? FrostyT : Clone1 ? CloneT : Clone3 ? Clone3T : \
          FrostyGradient ? GradientT : IsPlain && (BT >= HeightMod) ? PlainT : nop()) : \
          IsFrosty ? FlipFrostyT : IsClone ? FlipCloneT : IsPlain && (BT >= HeightMod) ? FPlainT : nop()

        FrostyBB = !IsFeather ? (IsFrosty ? FrostyB : Clone1 ? CloneB : Clone3 ? Clone3B : \
          FrostyGradient ? GradientB : IsPlain && (BB >= HeightMod) ? PlainB : nop()) : \
          IsFrosty ? FlipFrostyB : IsClone ? FlipCloneB : IsPlain && (BB >= HeightMod) ? FPlainB : nop()

        FrostyClip = IsFrosty || IsClone || FrostyGradient || (IsPlain && (BT >= HeightMod <= BB)) ? \
          Eval("StackVertical(FrostyBT" + CRVideoStr + "FrostyBB)") : \
          IsPlain && (BT >= HeightMod) ? StackVertical(FrostyBT, CRVideo) : \
          IsPlain && (BB >= HeightMod) ? StackVertical(CRVideo, FrostyBB) : CRVideo

# -------------------------------------------------------------------------------
#            LetterBox Feather Mask
# -------------------------------------------------------------------------------

        if (IsFeather) {

            MVBlur = round(max(0, Feather / 2.25))

            MFastBlurStr = (MVBlur == 0) ? "" : \
              ".FastBlur(0, y_blur=MVBlur, iterations=Iterations, dither=true, threads=Threads, gamma=false)"

            FeatherMask = BlankClip(CRVideo, height=CRVideo_Height-(Feather*2))\
              .AddBorders(0, BT+Feather, 0, BB+Feather, color=$FFFFFF).ColorYUV(Levels="TV->PC")

            FeatherMask = Eval("FeatherMask" + MFastBlurStr + LoopStr)

# -------------------------------------------------------------------------------
#            LetterBox Feather Clip
# -------------------------------------------------------------------------------

            FeatherClip = IsFrosty ? Eval("StackVertical(FFrostyT" + BordStr + "FFrostyB)") : \
              Clone1 ? Eval("StackVertical(" + \
              "StackVertical(FCloneT, CRVideo.crop(0, 0, 0, -CRVideo_Height+FT-BT))" + \
              FastBlurStr + GrainStr + BordStr + \
              "StackVertical(CRVideo.crop(0, CRVideo_Height-FB+BB, 0, 0), FCloneB)" + \
              FastBlurStr + GrainStr + ")")  : \
              Clone2 ? Eval("StackVertical(FClone2T" + BordStr + "FClone2B)") : \
              Clone3 ? Eval("StackVertical(" + \
              "StackVertical(FClone3T, CRVideo.crop(0, 0, 0, -CRVideo_Height+FT-BT))" + \
              FastBlurStr + GrainStr + BordStr + \
              "StackVertical(CRVideo.crop(0, CRVideo_Height-FB+BB, 0, 0), FClone3B)" + \
              FastBlurStr + GrainStr + ")") : \
              Eval("StackVertical(BlankClip(CRVideo, height=FT, color=BColor)" + \
              GammaStr + TweakStr + GrainStr + LoopStr + BordStr + \
              "BlankClip(CRVideo, height=FB, color=BColor)" + \
              GammaStr + TweakStr + GrainStr + LoopStr + ")") }

# -------------------------------------------------------------------------------
#            LetterBox Output
# -------------------------------------------------------------------------------

        FrostyOut = IsFeather ? Overlay(FrostyClip, FeatherClip, mask=FeatherMask) : FrostyClip }

# ===============================================================================
#            Frosty Output
# ===============================================================================

    FrostyOut = IsPillarBox || IsLetterBox ? FrostyOut : CRVideo

    return IsYUY2Source ? ConvertToYUY2(FrostyOut) : FrostyOut }

# ===============================================================================
# ===============================================================================
#            Ringing Repair
# ===============================================================================
# ===============================================================================

function CR_RingRepair(Resized, Original, CRVideo_Width, CRVideo_Height, \
    RCL, RCT, F_Cropped_Width, F_Cropped_Height, IsCPlaceResize, IsFMTC, IsResizeMT, \
    ChromaLocS, ChromaLocD, Weight) {

    GaussVideo = IsCPlaceResize ? Eval("GaussResize" + (!IsResizeMT ? "" : "MT") + \
      "(Original, CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, " + \
      "src_width=F_Cropped_Width, src_height=F_Cropped_Height, p=100, placement=ChromaLocD)") : \
      IsFMTC ? fmtc_resample(Original, CRVideo_Width, CRVideo_Height, sx=RCL, sy=RCT, \
      sw=F_Cropped_Width, sh=F_Cropped_Height, kernel="gauss", a1=100, \
      cplaces=ChromaLocS, cplaced=ChromaLocD) : \
      Eval("GaussResize" + (!IsResizeMT ? "" : "MT") + \
      "(Original, CRVideo_Width, CRVideo_Height, src_left=RCL, src_top=RCT, " + \
      "src_width=F_Cropped_Width, src_height=F_Cropped_Height, p=100)")

    RepairedVideo = Repair(Resized, GaussVideo, 1)

    return (Weight == 1) ? RepairedVideo : Merge(Resized, RepairedVideo, Weight) }

# ===============================================================================
# ===============================================================================
#            Format String
# ===============================================================================
# ===============================================================================

function CR_FS(float F, int "Limit", bool "Keep") {

    Limit = abs(default(Limit, 3))
    Keep = default(Keep, false)
    S = Eval("""string(F, "%.""" + string(Limit) + """f")""")
    S = (Limit == 0) ? S : CR_RemoveTrailingZeros(S)
    SLength = StrLen(S)
    NewStr = (Limit == 0) || (FindStr(S, ".") < SLength) ? S : !Keep ? LeftStr(S, SLength - 1) : S + "0"
    return (value(NewStr) == 0) && (FindStr(NewStr, "-") > 0) ? MidStr(NewStr, 2) : NewStr }

# ---------------------------------------

function CR_RemoveTrailingZeros(string S) {

    ZeroPos = FindStr(S + "x", "0x")
    return (ZeroPos == 0) ? S : CR_RemoveTrailingZeros(LeftStr(S, ZeroPos - 1)) }

# ===============================================================================
# ===============================================================================
#            Float To Fraction
# ===============================================================================
# ===============================================================================

function CR_FTF(float Decimal, int "Out") {

    Out = default(Out, 1)
    Num = (Decimal == 0) ? "0" : string(ContinuedNumerator(Decimal, Limit=10000))
    Den = (Decimal == 0) ? "1" : string(ContinuedDenominator(Decimal, Limit=10000))
    return "  (" + Num + ((Out == 1) ? ":" : " / ") + Den + ")" }

# ===============================================================================
# ===============================================================================
#            Position
# ===============================================================================
# ===============================================================================

function CR_Position(clip Source, float "X", float "Y", float "Size", \
    val "Color", int "Align", int "LSP", string "LB1", string "LB2", bool "Info") {

    Size = default(Size, 20)
    Y = default(Y, Size / 1.5)
    LSP = default(LSP, 20)
    LB1 = default(LB1, "")
    LB2 = default(LB2, "\n")
    Info = default(Info, False)
    FrameText = Info && (LB2 == "\n") ? "Frame   " : ""

    ScriptClip(Source, function[FrameText, X, Y, Size, Color, Align, LSP, LB1, LB2] () {
        Frame = string(current_frame, "%.0f")
        F_Position = float(current_frame) * float(FrameRateDenominator()) / float(FrameRateNumerator())
        Position = floor(F_Position)
        HH = string(Position / 3600, "%02.0f:")
        MM = string((Position / 60) % 60, "%02.0f:")
        SS = string(Position % 60, "%02.0f.")
        MS = string(floor((F_Position - Position) * 1000.0) % 1000, "%03.0f")
        subtitle(LB1 + FrameText + Frame + LB2 + HH + MM + SS + MS, \
        x=X, y=Y, size=Size, text_color=Color, align=Align, lsp=LSP) }, local=true) }

# ===============================================================================
# ===============================================================================
#            Picture Mod
# ===============================================================================
# ===============================================================================

function CR_PicMod(W, H) {

    WMod = ((W % 16) == 0) ? 16 : ((W % 8) == 0) ? 8 : ((W % 4) == 0) ? 4 : ((W % 2) == 0) ? 2 : 1
    HMod = ((H % 16) == 0) ? 16 : ((H % 8) == 0) ? 8 : ((H % 4) == 0) ? 4 : ((H % 2) == 0) ? 2 : 1

    return string(WMod, "  (Mod %.0fx") + string(HMod, "%.0f)") }

# ===============================================================================
# ===============================================================================
#            IsEqual
# ===============================================================================
# ===============================================================================

function CR_IsEqual(Val1, Val2) { return (abs(Val1 - Val2) < 0.00005) }

# ===============================================================================
# ===============================================================================
#            CropResize Defaults
# ===============================================================================
# ===============================================================================
#
#  Setting these defaults incorrectly will probably break something.
#  The functions below are required and cannot be commented out.
#
# -------------------------------------------------------------------------------

function CR_AutoDAR() { return false }
function CR_CLine(int W, int H) { return (W <= 1920) && (H <= 1080) ? 1 : 2 }
function CR_ColorConvert() { return "" }
function CR_CPreview() { return 1 }
function CR_Info_AutoPicDim() { return 0 }
function CR_Info_AutoPicDim_CPreview() { return false }
function CR_Info_Formatted_AVS_Version() { return true }
function CR_MeGUI_Support() { return true }

# ----------------------------------------------------------
#  Default resizer and resizer string functions
# ----------------------------------------------------------

function CR_Resizer_Default() { return "" }
function CR_RStr_Default() { return "" }

# ----------------------------------------------------------
#  Alternative resizer and resizer string functions
# ----------------------------------------------------------

function CR_Resizer_X() { return "" }
function CR_RStr_X() { return "" }

# ===============================================================================
# ===============================================================================
