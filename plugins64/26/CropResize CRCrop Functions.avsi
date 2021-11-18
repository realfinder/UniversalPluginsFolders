# ===============================================================================
# ===============================================================================
# ========== CropResize CRCrop Functions 2021-10-22 =============================
# ===============================================================================
# ===============================================================================
#
#  CRCrop is a CropResize wrapper function.
#  The purpose of CRCrop is to make it easier to apply standard cropping in a script,
#  while still using CropResize for cropping and resizing.
#
#  All CropResize arguments can be used with CRCrop.
#
# -------------------------------------------------------------------------------
#
#  Useage:
#   
#  Add cropping to a script.
#  Crop(6,0,-8,0)
#
#  Add "CR" to the Crop function's name and the CRCrop wrapper function takes over.
#  CRCrop(6,0,-8,0)
#
#  After changing the function's name to CRCrop, CropResize arguments can also be added.
#  CRCrop(6,0,-8,0, InSAR=8.0/9.0, Info=true)
#
#  In order to use the function as intended, to add resizing to CRCrop, the OutWidth & OutHeight
#  must be specified after the cropping, not before.
#  CRCrop(6,0,-8,0, 640,480, InSAR=8.0/9.0, Borders=true)
#
# ===============================================================================

function CRCrop(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ===============================================================================
# ===============================================================================
# ===============================================================================

# ========== CRCropX ============================================================

function CRCropX(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_Resizer = default(Resizer, CR_ResizerX())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStrX())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ========== pCRCrop ============================================================

function pCRCrop(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_CPreview = default(CPreview, CR_CPreview())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ========== pCRCropX ===========================================================

function pCRCropX(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_CPreview = default(CPreview, CR_CPreview())
global G_Resizer = default(Resizer, CR_ResizerX())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStrX())

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ========== iCRCrop ============================================================

function iCRCrop(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ========== iCRCropX ===========================================================

function iCRCropX(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_Resizer = default(Resizer, CR_ResizerX())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStrX())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ========== piCRCrop ===========================================================

function piCRCrop(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

global G_CPreview = default(CPreview, CR_CPreview())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ========== piCRCropX ==========================================================

function piCRCropX(clip Source, float "CL", float "CT", float "CR", float "CB", int "OutWidth", int "OutHeight", \
val "CropDAR", int "CSplit", bool "CAlign", bool "AutoC", int "CThresh", int "CStart", int "CSample", \
int "CPreview", int "CLine", val "InDAR", val "InSAR", val "OutDAR", val "OutSAR", bool "AutoAspect", \
int "Mod", int "HMod", bool "NoResize", bool "ResizeWO", bool "Borders", bool "CleanBorders", \
val "BColor", bool "Frosty", int "ColorCorrect", string "ColorMode", string "Resizer", string "RStr", \
int "GMode", bool "RMode", int "PicDim", bool "Position", bool "Info")  {

IsResizer = defined(Resizer)
global G_CPreview = default(CPreview, CR_CPreview())
global G_Resizer = default(Resizer, CR_ResizerX())
global G_RStr = default(RStr, IsResizer ? "" : CR_RStrX())
global G_Info = default(Info, true)

CropResize(Source, OutWidth, OutHeight, CL, CT, CR, CB, \
CropDAR, CSplit, CAlign, AutoC, CThresh, CStart, \
CSample, CPreview, CLine, InDAR, InSAR, OutDAR, OutSAR, AutoAspect, \
Mod, HMod, NoResize, ResizeWO, Borders, CleanBorders, BColor, Frosty, \
ColorCorrect, ColorMode, Resizer, RStr, GMode, RMode, PicDim, Position, Info)  }

# ==================================================================================
# ==================================================================================
# ==================================================================================