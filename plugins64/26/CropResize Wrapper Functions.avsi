# ===============================================================================
# ===============================================================================
#            CropResize Wrapper Functions 2023-10-28
# ===============================================================================
# ===============================================================================

# -------------------------------------------------------------------------------
#            CropResizeX
# -------------------------------------------------------------------------------

function CropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pCropResize
# -------------------------------------------------------------------------------

function pCropResize(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_CPreview = default(CPreview, CR_CPreview())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pCropResizeX
# -------------------------------------------------------------------------------

function pCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_CPreview = default(CPreview, CR_CPreview())
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iCropResize
# -------------------------------------------------------------------------------

function iCropResize(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iCropResizeX
# -------------------------------------------------------------------------------

function iCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piCropResize
# -------------------------------------------------------------------------------

function piCropResize(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_CPreview = default(CPreview, CR_CPreview())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piCropResizeX
# -------------------------------------------------------------------------------

function piCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_CPreview = default(CPreview, CR_CPreview())
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# ===============================================================================
#            CR Wrapper Functions
# ===============================================================================

# -------------------------------------------------------------------------------
#            CR
# -------------------------------------------------------------------------------

function CR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            CRX
# -------------------------------------------------------------------------------

function CRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pCR
# -------------------------------------------------------------------------------

function pCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_CPreview = default(CPreview, CR_CPreview())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pCRX
# -------------------------------------------------------------------------------

function pCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_CPreview = default(CPreview, CR_CPreview())
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iCR
# -------------------------------------------------------------------------------

function iCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iCRX
# -------------------------------------------------------------------------------

function iCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piCR
# -------------------------------------------------------------------------------

function piCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_CPreview = default(CPreview, CR_CPreview())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piCRX
# -------------------------------------------------------------------------------

function piCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_CPreview = default(CPreview, CR_CPreview())
global G_Resizer = default(Resizer, CR_Resizer_X())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

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
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pGCropResize
# -------------------------------------------------------------------------------

function pGCropResize(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

CPreview = default(CPreview, CR_CPreview())

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pGCropResizeX
# -------------------------------------------------------------------------------

function pGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
CPreview = default(CPreview, CR_CPreview())
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iGCropResize
# -------------------------------------------------------------------------------

function iGCropResize(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iGCropResizeX
# -------------------------------------------------------------------------------

function iGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piGCropResize
# -------------------------------------------------------------------------------

function piGCropResize(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

CPreview = default(CPreview, CR_CPreview())
Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piGCropResizeX
# -------------------------------------------------------------------------------

function piGCropResizeX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
CPreview = default(CPreview, CR_CPreview())
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# ===============================================================================
#            GCR Wrapper Functions
# ===============================================================================

# -------------------------------------------------------------------------------
#            GCR
# -------------------------------------------------------------------------------

function GCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            GCRX
# -------------------------------------------------------------------------------

function GCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pGCR
# -------------------------------------------------------------------------------

function pGCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

CPreview = default(CPreview, CR_CPreview())

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            pGCRX
# -------------------------------------------------------------------------------

function pGCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
CPreview = default(CPreview, CR_CPreview())
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iGCR
# -------------------------------------------------------------------------------

function iGCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            iGCRX
# -------------------------------------------------------------------------------

function iGCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piGCR
# -------------------------------------------------------------------------------

function piGCR(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

CPreview = default(CPreview, CR_CPreview())
Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# -------------------------------------------------------------------------------
#            piGCRX
# -------------------------------------------------------------------------------

function piGCRX(clip Source, int "OutWidth", int "OutHeight", \
float "CL", float "CT", float "CR", float "CB", val "CropDAR", float "TCRatio", int "CSplit", \
bool "AutoC", int "CThresh", int "CStart", int "CSample", int "CPreview", int "CLine", \
val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoDAR", int "Mod", int "HMod", \
bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", val "BColor", bool "Frosty", \
string "ColorConvert", string "ColorMode", string "Resizer", string "RStr", val "RingRepair", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
CPreview = default(CPreview, CR_CPreview())
Resizer = default(Resizer, CR_Resizer_X())
RStr = default(RStr, IsResizer ? "" : CR_RStr_X())
Info = default(Info, true)

GCropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, CropDAR, TCRatio, CSplit, \
AutoC, CThresh, CStart, CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoDAR, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorConvert, ColorMode, Resizer, RStr, RingRepair, GMode, RMode, PicDim, Position, Info)  }

# ===============================================================================
# ===============================================================================
