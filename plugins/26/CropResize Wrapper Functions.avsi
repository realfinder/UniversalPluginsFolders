# ===============================================================================
# ===============================================================================
#            CropResize Wrapper Functions 2025-12-20
# ===============================================================================
# ===============================================================================

# -------------------------------------------------------------------------------
#            CropResizeX
# -------------------------------------------------------------------------------

function CropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pCropResize
# -------------------------------------------------------------------------------

function pCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qCropResize
# -------------------------------------------------------------------------------

function qCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview()) + 3

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pCropResizeX
# -------------------------------------------------------------------------------

function pCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview())
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qCropResizeX
# -------------------------------------------------------------------------------

function qCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview()) + 3
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iCropResize
# -------------------------------------------------------------------------------

function iCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iCropResizeX
# -------------------------------------------------------------------------------

function iCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piCropResize
# -------------------------------------------------------------------------------

function piCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiCropResize
# -------------------------------------------------------------------------------

function qiCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview()) + 3
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piCropResizeX
# -------------------------------------------------------------------------------

function piCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview())
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiCropResizeX
# -------------------------------------------------------------------------------

function qiCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview()) + 3
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# ===============================================================================
#            CR Wrapper Functions
# ===============================================================================

# -------------------------------------------------------------------------------
#            CR
# -------------------------------------------------------------------------------

function CR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            CRX
# -------------------------------------------------------------------------------

function CRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pCR
# -------------------------------------------------------------------------------

function pCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qCR
# -------------------------------------------------------------------------------

function qCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview()) + 3

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pCRX
# -------------------------------------------------------------------------------

function pCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview())
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qCRX
# -------------------------------------------------------------------------------

function qCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview()) + 3
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iCR
# -------------------------------------------------------------------------------

function iCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iCRX
# -------------------------------------------------------------------------------

function iCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piCR
# -------------------------------------------------------------------------------

function piCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiCR
# -------------------------------------------------------------------------------

function qpiCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    global G_CPreview = default(CPreview, CR_CPreview()) + 3
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piCRX
# -------------------------------------------------------------------------------

function piCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview())
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiCRX
# -------------------------------------------------------------------------------

function qiCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    global G_CPreview = default(CPreview, CR_CPreview()) + 3
    global G_Resizer = default(Resizer, CR_Resizer_X())
    global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    global G_Info = default(Info, true)

    return CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# ===============================================================================
# ===============================================================================
#            GCropResize Wrapper Functions
# ===============================================================================
# ===============================================================================

# -------------------------------------------------------------------------------
#            GCropResizeX
# -------------------------------------------------------------------------------

function GCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pGCropResize
# -------------------------------------------------------------------------------

function pGCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview())
    global G_CPreviewText = true

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qGCropResize
# -------------------------------------------------------------------------------

function qGCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview()) + 3

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pGCropResizeX
# -------------------------------------------------------------------------------

function pGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview())
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qGCropResizeX
# -------------------------------------------------------------------------------

function qGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview()) + 3
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iGCropResize
# -------------------------------------------------------------------------------

function iGCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iGCropResizeX
# -------------------------------------------------------------------------------

function iGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piGCropResize
# -------------------------------------------------------------------------------

function piGCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiGCropResize
# -------------------------------------------------------------------------------

function qiGCropResize(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview()) + 3
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piGCropResizeX
# -------------------------------------------------------------------------------

function piGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview())
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiGCropResizeX
# -------------------------------------------------------------------------------

function qiGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview()) + 3
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# ===============================================================================
#            GCR Wrapper Functions
# ===============================================================================

# -------------------------------------------------------------------------------
#            GCR
# -------------------------------------------------------------------------------

function GCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            GCRX
# -------------------------------------------------------------------------------

function GCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pGCR
# -------------------------------------------------------------------------------

function pGCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qGCR
# -------------------------------------------------------------------------------

function qGCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview()) + 3

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            pGCRX
# -------------------------------------------------------------------------------

function pGCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview())
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qGCRX
# -------------------------------------------------------------------------------

function qGCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview()) + 3
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iGCR
# -------------------------------------------------------------------------------

function iGCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            iGCRX
# -------------------------------------------------------------------------------

function iGCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piGCR
# -------------------------------------------------------------------------------

function piGCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiGCR
# -------------------------------------------------------------------------------

function qiGCR(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    CPreview = default(CPreview, CR_CPreview()) + 3
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            piGCRX
# -------------------------------------------------------------------------------

function piGCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview())
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# -------------------------------------------------------------------------------
#            qiGCRX
# -------------------------------------------------------------------------------

function qiGCRX(clip Source, int "OutWidth", int "OutHeight", \
    float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
    bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
    val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", \
    int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", \
    bool "Borders", bool "CleanBorders", bool "BBlur", val "BColor", bool "Frosty", \
    string "ColorConvert", string "ColorMode", \
    string "Resizer", string "RStr", val "CPlace", val "CPlaceD", val "RingRepair", \
    int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info") {

    IsResizer = defined(Resizer)
    CPreview = default(CPreview, CR_CPreview()) + 3
    Resizer = default(Resizer, CR_Resizer_X())
    RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
    Info = default(Info, true)

    return GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
      AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
      Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BBlur, BColor, Frosty, ColorConvert, \
      ColorMode, Resizer, RStr, CPlace, CPlaceD, RingRepair, GMode, RMode, PicDim, Position, Info) }

# ===============================================================================
#            CombineClips Wrapper Function
# ===============================================================================

function iCombineClips(clip_array Clips, int "OutWidth", int "OutHeight", bool "Max", \
    float "TCRatio", val "InSAR", val "OutDAR", val "OutSAR", int "Mod", int "HMod", \
    bool "Borders", val "BColor", bool "BBlur", bool "Frosty", string "ColorConvert", \
    string "Resizer", string "RStr", val "RingRepair", bool "Position", bool "Info") {

    Info = default(Info, true)

    return CombineClips(Clips, OutWidth, OutHeight, Max, TCRatio, InSAR, OutDAR, OutSAR, Mod, HMod, \
      Borders, BColor, BBlur, Frosty, ColorConvert, Resizer, RStr, RingRepair, Position, Info) }

# ===============================================================================
# ===============================================================================
