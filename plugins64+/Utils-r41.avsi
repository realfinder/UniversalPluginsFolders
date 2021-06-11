### basic utility functions for AVS+
##
## wiki page (incomplete at this time):
##   http://avisynth.nl/index.php/User:Raffriff42/Utils-r41_Quick_Reference
## download latest:
##   http://avisynth.nl/images/Utils-r41.avsi
##   https://raw.githubusercontent.com/raffriff42/AvisynthPlusUtilities/master/Utils-r41.avsi
##
## Version history:
## v0.41    (2017-05-13) raffriff42
## v0.41.06 add remove_gamma, restore_gamma; fix sc8f bug; new EvalShow args.
## v0.41.08 remove unused scnf(), add ColorbarsHD2(clip T, ...)
## v0.41.09 SplitLines: preserve existing line breaks
## v0.41.10 ToVdub2, MatchColorFormat
## v0.41.11 misc. improvements
## v0.41.12 (2017-05-29) "bugfix 12" ScaleSize gamma optional; improved gamma filters
## v0.41.13 CropAspectPanTilt
## v0.41.14 _ssrc_ok, IsAvsPlus
## v0.41.15 LayerAligned
## v0.41.16 CropMatch, SGradation2C
## v0.41.17 VersionBuildNumber, _Bias (temp bugfix)
## v0.41.18 To422, To420; requires MaskTools 2.2.x
## v0.41.19 ColorRampR; ScopeR, HistogramTurn options
## v0.41.20 (2017-10-22) BlurBorders requires flash3kyuu_deband
## v0.41.21 remove _Bias, rewrite ToRGB, ToYUVxxx
## v2017-10-15 QGaussBlur; switch to AddGrainC
## v2017-11-20 ScopeY, ColorRampR etc; MatchColorFormat bugfix
## v2017-11-24 SGradation2D bugfix
## v2017-11-25 CountLines; LevelsPlus@chroma; ConvertBits42 (WIP); bugfixes
## v2017-11-25 bugfixes; Vector2@nodither
## v2017-11-26 CropEx@align
## v2017-11-27 bugfixes; docs
## v2017-12-05 bugfixes; add FormatTime, InfoString, AnalyzeY/UV; remove less-used filters 
## v2017-12-26 To601, To709
## v2018-01-11 ColorRampY
## v2018-01-26 bugfix; AnalyzeFmt
## v2018-02-06 CropLTRB, CropLTWH
## v2018-02-12 _getFullscale and BitsToPixelType bugfixes
## v2018-02-20 Levelsc; To601, To709, MatrixRed, MatrixGreen
## v2018-02-22 MakeRGBColor, YUV2GBR, GBR2YUV bugfixes; remove AddGrain
## v2018-02-23 (float support needs more testing)
## v2018-02-24 enhance CropLTRB, CropLTWH, AnalyzeFmt; refine ToPC, ToTV; Subtitle42
## v2018-02-25 To444/To422/To420 - don't return YUVA by default (it confuses clients)
## v2018-02-26 use Expr to replace MaskTools
## v2018-02-27 ShowSnippet; ColorRamp replaces ColorRampR/ColorRampY
## v2018-03-01 bugixes; removed obsolete workarounds (AVS+ r2632); 
##              ToRGB/ToYUV 'alpha' defaults; move filters in MISC to DIAGNOSTIC
## v2018-03-09 rename Levelsc -> Levelss; drop LevelsPlus
## v2018-03-13 minor bugfixes
## v2018-03-29 SoftLimiter2, improved Vector2, vector_marks@style
## v2018-04-12 CropToAspect, ExpandToAspect 
## v2018-04-14 (moved from -r42) CropPanTilt, CropShift, MergeLH, GammaCurves, SoftWipe
## v2018-04-14 (moved from -r42) Shift, ShiftUV, ShiftRedBlue
## v2018-04-15 (moved from -r42) _GammaCurve, _AntigammaCurve, MergeLMH
## v2018-04-16 (return to -r42) SoftWipe, ChangeSpeed, ChangeAudioSpeed
## v2018-04-20 To400; bugfix
## v2019-05-27 LevelssRGB: support RGBA
## v2019-05-29 (moved from -r42) CheapColorTemp, ColorYUVx3
## v2019-05-30 (removed to -r42) CropToAspect, ExpandToAspect 
## v2019-06-09 SplitScreen, SplitScreenVert
## v2019-07-05 (return from -r42) ChangeSpeed, ChangeAudioSpeed;
##             (move from -r42) CutToSync, DissolveMode;
##             ScaleZoom, ScaleSize: simplified; 
##             rename original functions ScaleZoom3, ScaleSize3;
##             CropLTRB, CropLTWH: float arguments
## v2019-07-11 prefix 'private' functions with underscore
## v2020-01-05 retire R41_BITMAX, add _nextHiBit, QGaussBlur, 
##             CropLTRB@absolute, InfoString@subtitle
## v2020-04-22 ReadFormatTime

global R41_HISTX = 264 ## amount classic Histogram adds to clip width (with added borders)
#global R41_BITMAX = 16 ## max implicit bit depth (float temp. disabled pending more tests)

#######################################################################################
### TABLE OF CONTENTS 
### http://avisynth.nl/index.php/User:Raffriff42/Utils-r41_Quick_Reference
#######################################################################################

### STRING FUNCTIONS 

    ### count the number of line breaks (for multi-line Subtitle(align=1|2|3) 
    #@ function CountLines(string s, bool "lsp") 

    ### Split long lines for [[Subtitle]] line wrap
    #@ function SplitLines(string s, int "lastcol", bool "reflow")

    ### Get part of a full path to right of last '\'
    #@ function GetNameFromPath(string path)

    ### Get part of a full path to left of last '\'
    #@ function GetParentFolder(string path)

    ### format seconds as hh:mm:ss.ddd
    #@ function FormatTime(float fsec, int "decimals")

    ### format hours/minutes/seconds as hh:mm:ss.ddd
    #@ function FormatTime(int t_hours, int t_mins, float t_secs, int "decimals")

    ### read a string of the form hh:mm:ss.ddd and return time in seconds
    #@ function ReadFormatTime(string s)

    ### for bits==32, return "S", else return String(bits)
    #@ function BitsToPixelType(string prefix, int bits, int "chroma")

### NUMERIC FUNCTIONS 

    ### return argument 'f' as integer and ensure it is modulo 'm'
    #@ function modx(int m, float f, int "dir")

    ### MOD-4-and-at-least-16 helper function
    #@ function m4(float f) 

    ### format a Float as a String with (by default) 2 decimals
    #@ function StrinF(float f, int "decimals")

    ### bugfixed [[IsFloat]]
    #@ function IsReallyFloat(val v)

    ### given 'Y', 'U', 'V' [, 'A'] return an Avisynth [[color_yuv]]
    #@ function MakeYUVColor(float y, float u, float v, float "a")

    ### given 'R', 'G', 'B' [, 'A'] return an Avisynth color
    #@ function MakeRGBColor(float r, float "g", float "b", float "a")

    ### given Avisynth color, set its transparency
    #@ function transparent_color(float a, int color)

    ### scale [[ColorYUV]]'s 'gain_x', 'gamma_x' & 'cont_x'  
    ### to more intuitive values (like [[Tweak]]'s) 
    #@ function f2c(float f)

    ### return True if [[SSRC]] can handle converting 'rate1' into 'rate2'
    #@ function _ssrc_ok(int rate1, int rate2)

    ### [[_ssrc_ok]] helper: Greatest Common Divisor
    #@ function _gcd(int x, int y)

    ### calculate new width, given height, for preserving aspect ratio
    #@ function CalcWidth(clip C, float fhgt, int "mod", int "lim")

    ### calculate new height, given width, for preserving aspect ratio
    #@ function CalcHeight(clip C, float fwid, int "mod", int "lim")

    ### merge hours, minutes, seconds to a single seconds value
    #@ function TimeToSeconds(int t_hours, int t_mins, float t_secs)

### DEEP COLOR ARGUMENT SCALING FUNCTIONS 

    ### return TV-black level for given bit depth
    #@ function _getTVBlack(int bits)

    ### return TV-white level for given bit depth
    #@ function _getTVWhite(int bits)

    ### return integer fullscale value for given bit depth
    #@ function _getFullscale(int bits)

    ### return next higher bit depth 
    #@ function _nextHiBit(int bits)

    ### scale a value from one fullscale range to another
    #@ function _scff(int fs_in, int fs_out, float f, bool "cx")

    ### scale a value from one bit depth to another
    #@ function scbf(int bits_in, int bits_out, float f, bool "cx")

    ### scale a value from one bit depth to another; clamp output
    #@ function scbx(int bits_in, int bits_out, float f)

    ### scale a value from one bit depth to another; string result 
    #@ function scbs(int bits_in, int bits_out, float f, int "decimals")

    ### scale an 8-bit value for target clip 'T'
    #@ function sc8f(clip T, float f, bool "cx")

    ### scale an 8-bit value for target clip 'T'; clamp output
    #@ function sc8x(clip T, float f)

    ### scale an 8-bit value for target clip 'T'; string result
    #@ function sc8s(clip T, float f, int "decimals")

### UTILITY FILTERS 

    ### Convert from anything to planar RGB(A) 
    #@ function ToRGB(clip C, string "matrix", int "bits_out", val "alpha")

    ### Convert from anything to YUV(A)444
    #@ function To444(clip C, string "matrix", int "bits_out", val "alpha")

    ### Convert from anything to YUV(A)422
    #@ function To422(clip C, string "matrix", int "bits_out", val "alpha")

    ### Convert from anything to YUV(A)420
    #@ function To420(clip C, string "matrix", int "bits_out", val "alpha")

    ### Convert from anything to Y-only
    #@ function To400(clip C, string "matrix", int "bits_out")

    ### Convert from anything to YUV(A)xxx (444|422|420|400)
    #@ function _ToYUVx(clip C, int chroma, string "matrix", int "bits_out", val "alpha")

    ### Convert from anything to best equivalent 16-bit version
    #@ function To16bit(clip C, clip "A")

    ### Convert from anything to best equivalent higher-bit-depth version
    #@ function ToHibit(clip C, int bits, clip "A")

    ### Convert from anything to best equivalent lower-bit-depth version
    #@ function ToLobit(clip C, int bits, bool "dither", clip "A")

    ### Convert from anything to 'best' (v2.6x compatible) equivalent 8-bit version
    #@ function To8bit(clip C, bool "dither")

    ### pass RGB through Stack16
    #@ function ToStack16(clip C, bool "swap_planes")

    ### recover RGB previously passed through ToStack16
    #@ function FromStack16(clip C, clip T, bool "swap_planes")

    ### add an alpha plane from another clip
    #@ function AddAlphaPlane42(clip C, clip A, bool "silent")

    ### make changes needed to display on VirtualDub2 (fka VirtualDub FilterMod)
    #@ function ToVdub2(clip C, bool "dither")

    ### Match color format of source 'C' to template 'T'
    #@ function MatchColorFormat(clip C, clip T, string "matrix", bool "keepbits", bool "dither")

    ### Match audio properties of source 'C' to template 'T'
    #@ function MatchAudioFormat(clip C, clip T, bool "allowresample")

    ### transport RGB in YV24: G=>Y, B=>U, R=>V
    #@ function GBR2YUV(clip C, bool "yuva")

    ### transport YV24 in RGB: Y=>G, U=>B, V=>R
    #@ function YUV2GBR(clip C, clip "A", bool "rgb32")

    ### convert levels from 'TV' (black=16d, white=235d) to 'PC' (black=0, white=255d)
    #@ function ToPC(clip C)

    ### convert levels from 'PC' (black=0, white=255d) to 'TV' (black=16d, white=235d)
    #@ function ToTV(clip C)

    ### 709->601 (less green, more red)
    #@ function To601(clip C)

    ### 601->709 (more green, less red)
    #@ function To709(clip C)

    ### alias for To709
    #@ function MatrixGreen(clip C)

    ### alias for To601
    #@ function MatrixRed(clip C)

    ### Stack clip 'C' horizontally until it is at least 'wid' wide
    #@ function _stack_to_wid(clip C, int wid, clip "R", bool "flip")

    ### Stack clip 'C' vertically until it is at least 'hgt' high
    #@ function _stack_to_hgt(clip C, int hgt, clip "R", bool "flip")

    ### Stack clip 'C' until it is 'wid' x 'hgt'
    #@ function stack_to_size(clip C, int wid, int hgt, bool "flip")

    ### remove sRGB gamma transfer function (if bit depth > 8) for linear-light processing
    ### ( used in [[#ScaleZoom3]], [[#ScaleSize]] )
    #@ function remove_gamma(clip C, string "matrix", bool "enable")

    ### apply standard gamma transfer function (if bit depth > 8) 
    #@ function restore_gamma(clip C, string "matrix", bool "enable")

    ### ConvertBits wrapper
    #@ function ConvertBits42(clip C, int bits, int "dither", bool "nobias")

### COLOR AND OVERLAY FILTERS

    ### scale 0-255 [[Levels]] arguments to current bit depth
    #@ function Levelss(clip C, 
    ##\            float input_low, float gamma, float input_high,
    ##\            float output_low, float output_high, bool "coring", 
    ##\            bool "dither", bool "chroma")

    ### call [[#Levelss]] independently for red, green, blue (alpha)
    #@ function LevelssRGB(clip C,  
    ##\              string "RLevels", string "GLevels", string "BLevels",  
    ##\              float "defBlk", float "defWht", bool "coring", bool "dither")

    ### gamma adjustment (more = brighter lowlights)
    #@ function _GammaCurve(clip C, float gamma, bool "tvrange")

    ### 'anti-gamma' adjustment (more = darker highlights)
    #@ function _AntigammaCurve(clip C, float antigamma, bool "tvrange")

    ### 'S'-curve luma adjustment
    #@ function GammaCurves(clip C, float gamma, float antigamma, bool "tvrange")

    ### emulate color temperature changes in three luma ranges
    #@ function CheapColorTemp(clip C, 
    ##\               int offset_lo, int offset_mid, int offset_hi)

    ### apply ColorYUV U & V offsets to three luma ranges
    #@ function ColorYUVx3(clip C,
    ##\               float "off_u_lo",  float "off_u_mid",  float "off_u_hi",
    ##\               float "off_v_lo",  float "off_v_mid",  float "off_v_hi",
    ##\               bool "showmasks")

    ### merge 'Lo', 'Hi' clips based on clip 'T' luma
    #@ function MergeLH(clip T, clip Lo, clip Hi, float "lothresh", float "hithresh")

    ### merge 'Lo', 'Mid', 'Hi' clips based on clip 'T' luma
    #@ function MergeLMH(clip T, clip Lo, clip Mid, clip Hi, float "bias",
    ##\               float "ctr_lo", float "ctr_hi", float "qfactor")

    ### [[Layer]] with support for 'mask', 'opacity' and 'align' parameters 
    #@ function LayerAligned(clip base, clip over, string "op", int "level", 
    ##\               clip "mask", float "opacity", int "align")

    ### [[Overlay]] with support for 'align' parameter 
    ### supports adding borders to, or letterboxing, inset clip
    #@ function OverlayAligned(clip base, clip over, 
    ##\               int "x", int "y", clip "mask", float "opacity", string "mode",
    ##\               bool "greymask", string "output", bool "ignore_conditional",
    ##\               bool "pc_range", int "align", int "borderwidth", int "bordercolor")

    ### [[Limiter]] with knee zone; implemented using [[Expr]]
    #@ function SoftLimiter2(clip C, 
    ##\               int "y_adj", float "max_sat", int "taper",
    ##\               int "min_y", int "max_y",  
    ##\               int "min_u", int "max_u", 
    ##\               int "min_v", int "max_v", 
    ##\               int "knee_y", int "knee_c")

### TIMELINE FILTERS

    ### "slip" (advance or delay) a clip in time.
    #@ function Slip(clip C, int offset)

    ### cut or dissolve to synchronized alternate clip
    #@ function CutToSync(clip A, clip B, int "mark", int "fade")

    ### like [[Dissolve]], but support [[Overlay]] modes
    #@ function DissolveMode(clip A, clip B, int ddur, string "mode", float "opacity")

    ### change speed over a wide range (basic FF and slo-mo; no motion compensation)
    #@ function ChangeSpeed(
    ##\               clip C, float factor, bool "pitchfix", bool "noblend")

    ### audio only: change speed over a wide range 
    #@ function ChangeAudioSpeed(
    ##\               clip C, float factor, bool "pitchfix")

### SHARPEN & BLUR FILTERS
    ### quick Gaussian blur
    #@ function QGaussBlur(clip C, float radx, float "rady")

### CROP, RESIZE AND TRANSFORM FILTERS

    ### alias for [[#Cropd]] with argument order: Left, Top, Right, Bottom
    #@ function CropLTRB(clip C, int left, int top, int right, int bottom, 
    ##\                 bool "align", int "mod", bool "absolute", 
    ##\                 int "minwidth", int "minheight", int "show")

    ### alias for [[#Cropd]] with argument order: Left, Top, Width, Height
    #@ function CropLTWH(clip C, int left, int top, int width, int height, 
    ##\                 bool "align", int "mod", 
    ##\                 int "minwidth", int "minheight", int "show")

    ### show a helpful diagnostic string on [[Crop]] failure; optionally enforce [[Mod]]
    #@ function Cropd(clip C, int x, int y, int wid, int hgt, bool "align", int "mod")

    ### (ScaleZoom sizes by percent; ScaleSize by width and/or height)
    #@ function ScaleZoom(clip C, float factor, int "mod")

    ### switch (or fade) between three [[Resize]] clips depending on scale factor
    ### (overridable with user-specified resizers e.g. nnedi3 etc)
    ### (ScaleZoom3 sizes by percent; ScaleSize3 by width and/or height)
    #@ function ScaleZoom3(clip C, float factor, int "mod", 
    ##\               string "sm", string "med", string "lg",
    ##\               float "thrSm", float "thrLg", bool "fade", bool "ident", 
    ##\               bool "gamma", bool "hibit", int "show", bool "debug")

    ### (ScaleZoom sizes by percent; ScaleSize by width and/or height)
    #@ function ScaleSize(clip C, float fwid, float fhgt, int "mod")

    ### switch (or fade) between three [[Resize]] clips depending on scale factor
    ### (overridable with user-specified resizers e.g. nnedi3 etc)
    ### (ScaleZoom3 sizes by percent; ScaleSize3 by width and/or height)
    #@ function ScaleSize3(clip C, float fwid, float fhgt, int "mod", 
    ##\               string "sm", string "med", string "lg",
    ##\               float "thrSm", float "thrLg", bool "fade", bool "ident", 
    ##\               bool "gamma", bool "hibit", int "show", bool "debug")

    ### crop to size with smooth pan & tilt (range -1.0_1.0; center @ 0, 0)
    #@ function CropPanTilt(clip C, int wid, int hgt, float "panRt", float "tiltDn",
    ##\               string "title", int "align", int "color", float "size")

    ### crop to size with smooth animated pan & tilt, expressed as pixels (center @ off_x=0, off_y=0)
    #@ function CropShift(clip C, int wid, int hgt, float "off_x", float "off_y")

    ### crop or expand a clip to ensure it is a certain size (symmetrically by default) 
    #@ function CropEx(clip C, float wid, float hgt, int "mod",   
    ##\               int "border", string "mode", 
    ##\               int "align", int "dx", int "dy", int "show", bool "debug")

    ### CropEx helper: borders with repeated edge pixels
    #@ function _Padding(clip C, int left, int top, int right, int bottom)

    ### CropEx helper: borders with mirrored edge pixels
    #@ function _MirrorBorders(clip C, int left, int top, int right, int bottom)

    ### CropEx helper: soft, dark borders
    #@ function _BlurBorders(clip C, int left, int top, int right, int bottom, 
    ##\                    float "gain", float "sat", int "blue",
    ##\                    float "noise", int "pblur", int "tblur", int "scene")

    ### shift a clip up-down and left-right (with sub-pixel precision)
    #@ function Shift(clip C, float offh, float offv)

    ### shift Chroma relative to Luma
    #@ function ShiftUV(clip C, float "ux", float "uy", float "vx", float "vy")

    ### shift and/or resize Red and Blue relative to Green
    #@ function ShiftRedBlue(clip C, 
    ##\               float "rx", float "ry",
    ##\               float "bx", float "by",
    ##\               float "rxd", float "ryd",
    ##\               float "bxd", float "byd")

    ### make side-by-side split screen, cropping both to fit
    #@ function SplitScreen(clip A, clip B, clip "S", 
    ##\               int "border", float "pan", float "panB", 
    ##\               int "wid", int "splitPos", 
    ##\               string "titleA", string "titleB", int "align")
    
    ### make over-and-under split screen, cropping both to fit
    #@ function SplitScreenVert(clip A, clip B, clip "S", 
    ##\               int "border", float "tiltA", float "tiltB", 
    ##\               int "hgt", int "splitPos", 
    ##\               string "titleA", string "titleB", int "align")

### DEBUGGING FILTERS

    ### return true if running in Avisynth+, false otherwise
    #@ function IsAvsPlus()

    ### return AVS+ build number, if present; else 0
    #@ function VersionBuildNumber()

    ### return basic clip properties as a string
    #@ function InfoString(val C, string "label", bool "subtitle")

    ### for clip identification, show a semitransparent text string, very large by default
    #@ function bigsub(clip C, string msg, float "sizeMult", bool "enable",
    ##\               int "text_color", int "halo_color", int "align")

    ### [[Eval]] a script snippet; show script & its return value (clip or nonclip);
    #@ function EvalShow(clip "c", string "s", 
    ##\               string "font", float "size", 
    ##\               int "text_color", int "halo_color", 
    ##\               int "align", string "name")

    ### Display a script snippet & its return value (clip or nonclip);
    #@ function ShowSnippet(clip "c", string "s", val "r", 
    ##\               string "font", float "size", 
    ##\               int "text_color", int "halo_color", 
    ##\               float "x", float "y", int "align")

    ### show a mask clip overlaid on another clip for visualization
    #@ function ShowMask(clip C, clip M, String "mode", float "opacity")

    ### ColorbarsHD2 with clip properties adjusted to match template 'T'
    #@ function ColorbarsHD2(clip T, float "tonedb")

    ### [[ColorbarsHD]] with optional RGB & deep color output; size & audio level changes
    #@ function ColorbarsHD2(int "width", int "height", bool "rgb_out", 
    ##\               int "bits_out", int "bits_gen", bool "dither", float "tonedb")

    ### return color ramp clip w/ same specs as template clip 'T' (RGB, Y only)
    #@ function ColorRamp(clip T, int "left_color", int "right_color", int "height", bool "zigs")

    ### return color ramp clip w/ same specs as template clip 'T' (any color format)
    #@ function ColorRampEx(clip T, int "left_color", int "right_color", int "height", 
    ##\               bool "zigs", bool "ontop", bool "onside", bool "inset")

    ### return grayscale ramp clip w/ same specs as template clip 'T' (alias for [[ColorRampEx]])
    #@ function Grayramp(clip T, int "height", bool "zigs", bool "ontop", bool "onside", bool "inset")

    ### YUV/RGB vectorscope with optional audio meters
    #@ function Vector2(clip C, string "mode", string "matrix", bool "bottom", 
    ##\               bool "labels", int "marks", bool "audio")

    ### vectorscope quadrant and (optional) color labels 
    #@ function _vector_labels(clip T, int "bits", bool "colors", bool "flip")

    ### vectorscope graticule marks 
    #@ function _vector_marks(clip T, int "bits", int "style")

    ### Classic [[Histogram]], waveform on top (or on bottom); supports RGB
    ### many little enhancements; accepts both YUV & RGB
    #@ function HistogramTurn(clip C, bool "parade", bool "shrink", bool "bottom", bool "turn")

    ### show video waveform + vectorscope; many little enhancements; accepts both YUV & RGB
    #@ function ScopeR(clip C, bool "shrink", bool "vector", string "matrix", 
    ##\               bool "parade", bool "bottom", string "mode", 
    ##\               bool "labels", int "marks", bool "audio", bool "turn")

    ### Augmented [[Histogram]]; reduce or eliminate high, low and center highlighting;
    #@ function _Hist2(clip C, string "mode", float "factor", int "tvrange_offset", bool "keepsource")
    
    ### classic Histogram for RGB
    #@ function _HistRGB(clip C, bool "parade", bool "keepsource")

    ### Simple waveform + vectorscope. Accepts 8-bit, YUV(A) only.
    #@ function ScopeY(clip C, bool "shrink", bool "vector", bool "levels",  
    ##\               bool "bottom", string "mode", bool "labels", int "marks", 
    ##\               bool "audio")

    ### print color channel statistics on the screen
    #@ function Analyze(clip C, bool "format")

    ### print color channel statistics on the screen 
    #@ function AnalyzeFmt(clip C, int "left", int "top", int "width", int "height",
    ##\                   int "text_color", int "halo_color", float "fontsize", 
    ##\                   bool "chroffset", bool "draftmode")

    ### like [[#AnalyzeFmt]], but for a single channel (Y,R,G,B,A)
    #@ function AnalyzeY(clip C, string label, bool enable,
    ##\                   int "text_color", int "halo_color", 
    ##\                   float "fontsize", bool "draftmode")

    ### like [[#AnalyzeFmt]], but for a single channel & relative to midscale (U,V)
    #@ function AnalyzeUV(clip C, string label, bool enable,
    ##\                   int "text_color", int "halo_color", float "fontsize", 
    ##\                   bool "chroffset", bool "draftmode")

    ### show original & 3 channels (Y, U, V or R, G, B) in quad split
    #@ function ShowChannelsQuad(clip C, bool "analyze", bool "uinvert", bool "chroffset")

    ### [[ShowFrameNumber]] with support for 'opacity' and 'align'
    #@ function ShowFrameNumberAligned(
    ##\               clip C, bool "scroll", int "offset",
    ##\               float "x", float "y", string "font", int "size",
    ##\               int "text_color", int "halo_color",
    ##\               float "font_width", float "font_angle",
    ##\               float "opacity", int "align")


#######################################################################################
### STRING FUNCTIONS 
#######################################################################################

##################################
### count the number of line breaks (for multi-line Subtitle(align=1|2|3) 
## line break == Chr(10) == '\n'
##
## @ lsp - if true, count "\n" as line break also - cf. [[Subtitle]]; default true
##
function CountLines(string s, bool "lsp") 
{
    lsp = Default(lsp, true)

    s = (!lsp) ? s
    \ : s.ReplaceStr("\n", Chr(10))

    linecount = 1
    for (i=1, StrLen(s)) {
        s1 = MidStr(s, i) 
        if (Ord(s1)==10) {
            linecount = linecount + 1 
        }
    }
    return linecount
}

##################################
### Split long lines for [[Subtitle]] line wrap
##
## @ lastcol - maximum line length before breaking; default 80.
## @ reflow  - if false (default), preserves existing line breaks;
##             if true, remove any existing line breaks (word wrap).
##
## Note: SplitLines always interprets "\n" sequence as a newline.
## (emulating Subtitle 'lsp' option behavior)
##
## >>>>> (if using in Subtitle: REMEMBER TO ADD THE 'lsp' ARGUMENT)
##
## version 1.1 2017-05-15 preserve existing line breaks
## version 1.2 2017-11-26 reflow
##
function SplitLines(string s, int "lastcol", bool "reflow")
{
    lastcol = Default(lastcol, 80)
    reflow  = Default(reflow, false)

    s = !(reflow) ? s
    \ : s.ReplaceStr(Chr(10), "").ReplaceStr(Chr(13), " ")

    s = s.ReplaceStr(Chr(10), "\n").ReplaceStr(Chr(13), " ")
    
    n = FindStr(s, "\n")
    p = FindStr(RevStr(LeftStr(s, lastcol)), " ")
    return (n>0) 
    \ ? SplitLines(LeftStr(s, n+0), lastcol) + SplitLines(MidStr(s, n+1), lastcol)
    \ : (StrLen(s)<lastcol) 
    \   ? TrimLeft(s)
    \   : (p < 12)
    \       ? TrimLeft(LeftStr(s, lastcol-p)) + "\n" +  
    \         SplitLines(MidStr(s, lastcol-p+1), lastcol)
    \       : TrimLeft(LeftStr(s, lastcol)) + "\n" +  
    \         SplitLines(MidStr(s, lastcol+1), lastcol)
}

##################################
### Get part of a full path to right of last '\'
## if no backslash is present, return entire path
## http://forum.doom9.org/showthread.php?p=1661093#post1661093
##
function GetNameFromPath(string path)
{
    p = FindStr(RevStr(path), "\")
    return (p==0) ? path 
    \ : RightStr(path, p-1)
}

##################################
### Get part of a full path to left of last '\'
## if no backslash is present, return entire path
##
function GetParentFolder(string path)
{
    p = FindStr(RevStr(path), "\")
    return (p==0) ? path 
    \ : LeftStr(path, StrLen(path)-p)
}

## see also 'FFFormatTime(int ms)' @ FFMS2.avsi
##################################
### format seconds as hh:mm:ss.ddd
###  (suitable for [[SoxFilter]] etc)
##
## @ decimals - number of decimal seconds; range 0_5; default 3
##
function FormatTime(float fsec, int "decimals")
{
    t_hours = Int(Int(fsec)/3600)
    t_secs2 = fsec - Float(3600 * t_hours)
    t_mins  = Int(Int(fsec)/3600) 
    t_secs3 = t_secs2 - Float(60 * t_mins)
    return FormatTime(t_hours, t_mins, t_secs3, decimals)  
}

##################################
### format hours/minutes/seconds as hh:mm:ss.ddd
###  (suitable for [[SoxFilter]] etc)
##
## @ decimals - number of decimal seconds; range 0_5; default 3
##
function FormatTime(int t_hours, int t_mins, float t_secs, int "decimals")
{
    decimals = Min(Max(0, Default(decimals, 3)), 5)

    t_secs = t_secs + t_mins*60 + t_hours*60*60

    t_int  = Floor(t_secs)
    t_frac = t_secs - Float(t_int)
    hh     = t_int / (60 * 60)
    mm     = (t_int % (60 * 60)) / 60
    ss     = t_int % 60

    shh = (hh<=0) ? "" : String(hh)+ ":"

    smm = (mm<=0 && shh.StrLen==0) ? "" : String(mm) + ":"
    smm = (smm.StrLen>2 || smm.StrLen==0) ? smm : "0" + smm

    sss = String(ss) + (decimals==0 ? "" : ".")
    sss = (sss.StrLen>2 || smm.StrLen==0) ? sss : "0" + sss

    sff = String(t_frac, "%1."+String(decimals)+"f").MidStr(3)

    return (t_secs<0) 
    \  ? "-" + FormatTime(0, 0, -t_secs) 
    \  : shh + smm + sss + sff
}

##################################
### read a string of the form hh:mm:ss.ddd and return time in seconds
##
## @ s - string of the form 
##          H:MM:SS[.ms]
##       or    M:SS[.ms]
##       or       S[.ms]
##
##  (does not attempt to validate input - "Garbage In, Garbage Out")
##
## @ Example - trim using timestamps from media player etc
## | AudioTrim(
## | \  ReadFormatTime("0:07.050"), 
## | \  ReadFormatTime("1:38:10.733")
## | \ )
##
function ReadFormatTime(string s)
{
    s  = TrimAll(s)
    p1 = FindStr(s, ":")
    p2 = (p1<2) ? 0 
    \  : FindStr(MidStr(s, p1+1), ":") + p1
    
    s1 = (p1<2) ? s
    \  : LeftStr(s, p1-1)

    s2 = (p1<2) ? ""
    \  : (p2<(p1+2)) ? MidStr(s, p1+1)
    \  : LeftStr(MidStr(s, p1+1), p2-p1-1)

    s3 = (p1<2) ? ""
    \  : (p2<(p1+2)) ? ""
    \  : MidStr(s, p2+1)

    ss = (p1<2) 
    \       ? Value(s)
    \  : (p2<(p1+2)) 
    \       ? (Int(Value(s1)) * 60) + Value(s2)
    \  : (Int(Value(s1)) * 3600) + (Int(Value(s2)) * 60) + Value(s3)

[*
n = Chr(13)
Assert(false, 
\       "s = '" + s + "'"
\ + n + "p1 = " + String(p1)
\ + n + "p2 = " + String(p2)
\ + n + "s1 = '" + s1 + "'"
\ + n + "s2 = '" + s2 + "'"
\ + n + "s3 = '" + s3 + "'"
\ + n + "ss = " + String(ss)
\ )
*]
    return ss
}

##################################
### build a PixelType string (planar types only)
##
## @ prefix - allowed values "RGB", "RGBA", "YUV", "YUVA", "Y"
## @ bits   - BitsPerComponent (8|10|12|14|16|32)
## @ chroma - for YUV types; allowed values (444|422|420); plus 0 for non-YUV
##
function BitsToPixelType(string prefix, int bits, int "chroma")
{
    prefix = UCase(prefix)
    prefix = (StrCmpi(prefix, "RGB" )==0) ? prefix
    \      : (StrCmpi(prefix, "RGBA")==0) ? prefix
    \      : (StrCmpi(prefix, "YUV" )==0) ? prefix
    \      : (StrCmpi(prefix, "YUVA")==0) ? prefix
    \      : (StrCmpi(prefix, "Y"   )==0) ? prefix
    \      : ""
    Assert(StrLen(prefix)>0,
    \   "BitsToPixelType: 'prefix' not one of (RGB|RGBA|YUV|YUVA|Y)")

    isrgb  = FindStr(prefix, "RGB")==1
    isyuv  = FindStr(prefix, "YUV")==1
    isalph = (StrCmpi(prefix, "YUVA")==0 || StrCmpi(prefix, "RGBA")==0)
    chroma = Default(chroma, 0)
    schrom = (chroma==444) ? "444"
    \      : (chroma==422) ? "422"
    \      : (chroma==420) ? "420"
    \      : ""
    Assert(!isyuv || StrLen(schrom)>0,
    \   "BitsToPixelType: 'YUV' prefix requires 'chroma'=(444|422|420)")

    prefix = (isyuv) ? prefix+schrom : prefix
    
    prefix = (isrgb)           ? prefix+"P" : prefix
    prefix = (isyuv && bits>0) ? prefix+"P" : prefix
    
    sbits  = ((isrgb || isyuv)  && bits==32) ? "S" 
    \      : ((isyuv [* && isalph *]) && bits==8 ) ? "8" 
    \      : ((isrgb || isyuv)  && bits==8 ) ? "" 
    \      : String(bits)
    return (prefix + sbits)
}

#######################################################################################
### NUMERIC FUNCTIONS 
#######################################################################################

##################################
### return argument 'f' as integer and ensure it is modulo 'm'
##
## @ m - mod value; minimum = 1, no other restrictions
## @ f - input (may be positive or negative)
## @ dir - if -1, round toward zero (default); 
##         if  0, round to nearest 
##
function modx(int m, float f, int "dir")
{
    m  = Max(1, Abs(m))
    d  = Default(dir, -1)
    sg = Sign(f)
    x  = (m>0) ? -1 : 1
    i  = Round(Abs(f))

    return (d==0) 
    \ ? Max(m, Int(Round(f/Float(m))*m))
    \ : sg * Max(0, i + x * (i % m))
} 

##################################
### MOD-4-and-at-least-16 helper function
## (round to nearest)
## @ Didée
function m4(float f) 
{
    (f<16) ? 16 : Int(Round(f/4.0)*4)
}

#######################################
### format a Float as a String with (by default) 2 decimals
##
function StrinF(float f, int "decimals")
{
    decimals = Min(Max(0, Default(decimals, 2)), 8)
    return String(f, "%0."+String(decimals)+"f")
}

# http://forum.videohelp.com/threads/382601-CropResize-Script?p=2478303#post2478303
##################################
### bugfixed [[IsFloat]]
## see http://avisynth.nl/index.php/Internal_functions#IsFloat
## thanks hello_hello
##
function IsReallyFloat(val v)
{
    return (IsInt(v)==false) && IsFloat(v) 
}

#######################################
### given 'Y', 'U', 'V' [, 'A'] return an Avisynth [[color_yuv]]
##
## @ a - 0.0 = transparent, 1.0 = opaque.
##
function MakeYUVColor(float y, float u, float v, float "a") {
    y = Min(Max(0, Round(y)), 255) 
    u = Min(Max(0, Round(u)), 255)
    v = Min(Max(0, Round(v)), 255)
    a = 255 - Min(Max(0, Round(Default(a, 1.0) * 256.0)), 255)
    
    return   a.BitLShift(24)
    \ .BitOr(y.BitLShift(16))
    \ .BitOr(u.BitLShift(8))
    \ .BitOr(v)
}

#######################################
### given 'R', 'G', 'B' [, 'A'] return an Avisynth color
##
## @ r, g, b - 0_255 
## @ a - 0.0 = transparent, 1.0 = opaque.
##
function MakeRGBColor(float r, float "g", float "b", float "a") {

    r = Min(Max(0, Round(r)),             255) ## thanks Gavino
    g = Min(Max(0, Round(Default(g, r))), 255)
    b = Min(Max(0, Round(Default(b, g))), 255)
    a = 255 - Min(Max(0, Round(Default(a, 1.0) * 256.0)), 255)

    return   a.BitLShift(24)
    \ .BitOr(r.BitLShift(16))
    \ .BitOr(g.BitLShift(8))
    \ .BitOr(b)
}

#######################################
### given Avisynth color, set its transparency
## @ a - 0.0 = transparent, 1.0 = opaque.
##
function transparent_color(float a, int color) {
    a = 255 - Min(Max(0, Round(a * 256.0)), 255)
    return BitOr(a.BitLShift(24), BitAnd(color, $ffffff))
}

#######################################
### scale [[ColorYUV]]'s 'gain_x', 'gamma_x' & 'cont_x'  
### to more intuitive values (like [[Tweak]]'s) 
##
function f2c(float f) {
    return Round((f - 1.0) * 256.0) 
}

##################################
### return True if [[SSRC]] can handle converting 'rate1' into 'rate2'
## (per documentation)
##
function _ssrc_ok(int rate1, int rate2) {
    frqgcd = (rate2<1 || rate1<1) ? 1 : _gcd(rate1, rate2) 
    fs1    = (rate2 > rate1) ? (rate1 / frqgcd) : (rate2 / frqgcd)
    return (frqgcd>1) && ((fs1==1) || ((fs1 % 2)==0) || ((fs1 % 3)==0))
}

# http://users.telenet.be/darnley/avisynth/mine.html
##################################
### [[_ssrc_ok]] helper: Greatest Common Divisor
##
function _gcd(int x, int y)
{
    t = x % y
    x = y
    y = t
    return (y>0) ? _gcd(x, y) : x
}

###############################
### calculate new width, given height, for preserving aspect ratio
##
## @ mod - new height & width will be divisible by this number 
##          (allowed values 1|2|4|8|16|32, default 1)
## @ lim - result forced to >= 'lim' (default=='mod')
##
## ex. [[Spline64Resize]](CalcWidth(720), 720).[[CropEx]](1280, 720)
##
function CalcWidth(clip C, float fhgt, int "mod", int "lim")
{
    mdd = Max(1,   Default(mod, 1))
    lim = Max(mdd, Default(lim, mdd))

    Assert(IsClip(C) && C.hasVideo, 
    \   "CalcWidth: invalid source clip")
    Assert(fhgt>0.001, 
    \   "CalcWidth: 'fhgt' must be > 0")
    Assert((mdd==1||mdd==2||mdd==4||mdd==8||mdd==16||mdd==32), 
    \  "CalcWidth: 'mod' argument not one of (1|2|4|8|16|32)")

    aspect = Float(C.Width) / Float(C.Height)
    wid    = Round((fhgt*aspect)/mdd)*mdd

    return Max(lim, wid)
}

###############################
### calculate new height, given width, for preserving aspect ratio
##
## @ mod - new height & width will be divisible by this number 
##          (allowed values 1|2|4|8|16|32, default 2)
## @ lim - result forced to >= 'lim' (default=='mod')
##
## ex. [[Spline64Resize]](1280, CalcHeight(1280)).[[CropEx]](1280, 720)
##
function CalcHeight(clip C, float fwid, int "mod", int "lim")
{
    mdd = Max(1,   Default(mod, 2))
    lim = Max(mdd, Default(lim, mdd))

    Assert(IsClip(C) && C.hasVideo, 
    \   "CalcHeight: invalid source clip")
    Assert(fwid>0, 
    \   "CalcHeight: 'wid' must be > 0")
    Assert((mdd==1||mdd==2||mdd==4||mdd==8||mdd==16||mdd==32), 
    \  "CalcHeight: 'mod' argument not one of (1|2|4|8|16|32)")

    aspect = Float(C.Width) / Float(C.Height)
    hgt    = Round((fwid/aspect)/mdd)*mdd

    return Max(lim, hgt) 
}

##################################
### merge hours, minutes, seconds to a single seconds value
##
function TimeToSeconds(int t_hours, int t_mins, float t_secs)
{
    return Float(t_hours * 3600)
    \    + Float(t_mins  * 60)
    \    + t_secs
}

#######################################################################################
### DEEP COLOR ARGUMENT SCALING FUNCTIONS 
#######################################################################################

#######################################
### return TV-black level for given bit depth
##
function _getTVBlack(int bits)
{
    return (bits==8)  ? 16.0
    \    : (bits==10) ? 64.0 
    \    : (bits==12) ? 256.0
    \    : (bits==14) ? 1024.0
    \    : (bits==16) ? 4096.0
    \    : (bits==32) ? 16.0/256.0 [* should be 0.0, IMHO *]
    \    : Assert(false,
    \        "_getTVBlack: 'bits' not one of (8|10|12|14|16|32)") 
}

#######################################
### return TV-white level for given bit depth
##
function _getTVWhite(int bits)
{
    return (bits==8)  ? 235.0
    \    : (bits==10) ? 940.0 
    \    : (bits==12) ? 3670.0
    \    : (bits==14) ? 15040.0
    \    : (bits==16) ? 60160.0
    \    : (bits==32) ? 235.0/256.0 [* should be 1.0, IMHO *]
    \    : Assert(false,
    \        "_getTVWhite: 'bits' not one of (8|10|12|14|16|32)") 
}

# https://forum.doom9.org/showthread.php?p=1804992#post1804992
#######################################
### return integer fullscale value for given bit depth
##
function _getFullscale(int bits)
{
    return (bits==8)  ? 255
    \    : (bits==10) ? 1020 
    \    : (bits==12) ? 4080
    \    : (bits==14) ? 16330
    \    : (bits==16) ? 65280
    \    : (bits==32) ? 1    [* 255.0/256.0 ?? *]
    \    : Assert(false,
    \        "_getFullscale: 'bits' not one of (8|10|12|14|16|32)") 
}

#######################################
### return next higher bit depth 
### (except keep 16 bit and 32bit as-is)
### (replaces earlier R41_BITMAX logic)
##
function _nextHiBit(int bits)
{
    return (bits==8)  ? 10
    \    : (bits==10) ? 12
    \    : (bits==12) ? 14
    \    : (bits==14) ? 16
    \    : (bits==16) ? 16
    \    : (bits==32) ? 32
    \    : Assert(false,
    \        "_nextHiBit: 'bits' not one of (8|10|12|14|16|32)") 
}

## ('_scff' short for 'SCale with Fullscale param, Float result') 
#######################################
### scale a value from one fullscale range to another
##
## @ fs_in  - the fullscale value in the range being converted from 
## @ fs_out - the fullscale value in the range being converted to
## @ cx     - if true, clamp output to [0_'fs_out']
## @ returns float if not clamped; 
##   else returns int for int formats, float for float
##
function _scff(int fs_in, int fs_out, float f, bool "cx")
{
    clamp = Default(cx, false)
    fin   = Float( (fs_in==1)  ? 256.0/255.0 : fs_in+1  )
    fout  = Float( (fs_out==1) ? 256.0/255.0 : fs_out+1 )
    
    fr    = (fs_in==fs_out) ? f : f * fout / fin ## unclamped result

    fr    =  (clamp==false) ? fr : Min(Max(0.0, fr), fs_out)
    fr    =  (clamp==false) ? fr : (fs_out==1) ? fr : Round(fr)
    return fr
}

## ('scbf' short for 'SCale with Bits param, Float result') 
#######################################
### scale a value from one bit depth to another
##
## @ bits_in  - the bit depth being converted from 
## @ bits_out - the bit depth being converted to
## @ cx       - if true, clamp output
## @ returns float if not clamped; 
##   else returns int for int formats, float for float
##
function scbf(int bits_in, int bits_out, float f, bool "cx")
{
    return _scff(_getFullscale(bits_in), _getFullscale(bits_out), f, cx)
}
#######################################
### scale a value from one bit depth to another; clamp output
##
## @ bits_in  - the bit depth being converted from 
## @ bits_out - the bit depth being converted to
## @ returns int for int formats, float for float
##
function scbx(int bits_in, int bits_out, float f)
{
    return scbf(bits_in, bits_out, f, true)
}
#######################################
### scale a value from one bit depth to another; string result 
##
## @ bits_in  - the bit depth being converted from 
## @ bits_out - the bit depth being converted to
## @ returns String, unclamped
##
function scbs(int bits_in, int bits_out, float f, int "decimals")
{
    decimals = Min(Max(0, Default(decimals, 4)), 8)
    return String(scbf(bits_in, bits_out, f), "%0."+String(decimals)+"f") 
}

#######################################
### scale an 8-bit value for target clip 'T'
##
## @ T  - clip with target bit depth (assume 'bits_in' = 8)
## @ cx - if true, clamp output
## @ returns float if not clamped; 
##   else returns int for int formats, float for 32-bit float
##
function sc8f(clip T, float f, bool "cx")
{
    return scbf(8, T.BitsPerComponent, f, cx)
} 
#######################################
### scale an 8-bit value for target clip 'T'; clamp output
##
## @ T - clip with target bit depth
## @ returns int for int formats, float for 32-bit float
##
function sc8x(clip T, float f)
{
    return scbf(8, T.BitsPerComponent, f, true)
} 
#######################################
### scale an 8-bit value for target clip 'T'; string result
## @ T - clip with target bit depth (assume 'bits_in' = 8)
## @ returns String, unclamped
##
function sc8s(clip T, float f, int "decimals")
{
    return scbs(8, T.BitsPerComponent, f, decimals)
} 

#######################################################################################
### UTILITY FILTERS 
#######################################################################################

##################################
### Convert from anything to planar RGB(A)
##  * Process internally at the next higher bit depth.
##
## @ matrix   - ignored if not converting from YUV; default "Rec601"
## @ bits_out - output bit depth, one of (8|10|12|14|16|32); default same as source
## @ alpha    - sets the alpha channel.
##              * if 'alpha' == "keep" (default), use the existing alpha channel if present;
##              * if 'alpha' == "none", any existing alpha channel is removed;
##              * if 'alpha' == "add", a new opaque alpha channel is added;
##              * if 'alpha' is a clip, it becomes the alpha channel of the resulting clip;
##                overrides any existing alpha channel.
##                   * if 'alpha' is a YUVA or RGBA clip, the A channel is used;
##                   * if 'alpha' is a YUV or Y-only clip, the Y channel is used;
##              * else, an error is raised.
##
## Return planar RGB(A)
##
function ToRGB(clip C, string "matrix", int "bits_out", val "alpha")
{
    matrix = Default(matrix, "Rec601")
    alpha  = Default(alpha, "keep")
    biti   = C.BitsPerComponent
    bito   = Default(bits_out, biti)
    #bitn   = (bito>=16) ? R41_BITMAX : (bito + 2) ## intermediate bit depth
    bitn   = _nextHiBit(bito)

    Assert(bito==8||bito==10||bito==12||bito==14||bito==16||bito==32,
    \   "ToRGB: 'bits_out' argument must be one of (8|10|12|14|16|32)")

    C = (IsString(alpha) && StrCmpi(alpha, "none")==0) 
    \ ? C.RemoveAlphaPlane
    \ : C

    A = (IsString(alpha) && StrCmpi(alpha, "none")==0)
    \    ? Nop
    \ : (IsString(alpha) && StrCmpi(alpha, "add")==0)
    \    ? C.AddAlphaPlane.ExtractA
    \       .ConvertBits42(bito)
    \ : (IsString(alpha) && StrCmpi(alpha, "keep")==0)
    \    ? (C.HasAlpha) 
    \       ? C.ExtractA
    \          .ConvertBits42(bito)
    \       : Nop
    \ : (IsClip(alpha) && alpha.HasAlpha)
    \    ? alpha.ExtractA
    \       .ConvertBits42(bito)
    \ : (IsClip(alpha) && alpha.IsY)
    \    ? alpha.ConvertBits42(bito)
    \ : (IsClip(alpha) && alpha.IsYUV)
    \    ? alpha.ExtractY
    \       .ConvertBits42(bito)
    \ : Assert(false, "ToRGB: invalid 'alpha' argument ('keep'|'add'|'none'|clip)")

    Q = (C.IsRGB)    ? C 
    \ : (bitn<=biti) ? C 
    \ : C.ToHibit(bitn) 

    R = (C.IsRGB) 
    \ ? Q.ConvertToPlanarRGB
    \    .ConvertBits42(bito)
    \ : Q.ConvertToPlanarRGB(matrix=matrix)
    \    .ConvertBits42(bito)

    return (IsClip(A))
    \ ? CombinePlanes(R.ExtractR, R.ExtractG, R.ExtractB, A, 
    \           planes="RGBA")
    \ : R
}

##################################
### Convert from anything to YUV(A)444
##  * Process internally at the next higher bit depth.
##
## @ matrix   - ignored if not converting from RGB; default "Rec601"
## @ bits_out - output bit depth, one of (8|10|12|14|16|32); default same as source
## @ alpha    - sets the alpha channel.
##              * if 'alpha' == "none" (default), any existing alpha channel is removed;
##              * if 'alpha' == "keep", use the existing alpha channel if present;
##              * if 'alpha' == "add", a new opaque alpha channel is added;
##              * if 'alpha' is a clip, it becomes the alpha channel of the resulting clip;
##                overrides any existing alpha channel.
##                  * if 'alpha' is a YUVA or RGBA clip, the A channel is used;
##                  * if 'alpha' is a YUV or Y-only clip, the Y channel is used;
##              * else, an error is raised.
##
## Return YUV(A)444
##
function To444(clip C, string "matrix", int "bits_out", val "alpha")
{
    return C._ToYUVx(444, matrix, bits_out, alpha)
}

##################################
### Convert from anything to YUV(A)422
##  * Process internally at the next higher bit depth.
##
## @ matrix   - ignored if not converting from RGB; default "Rec601"
## @ bits_out - output bit depth, one of (8|10|12|14|16|32); default same as source
## @ alpha    - sets the alpha channel.
##              * if 'alpha' == "none" (default), any existing alpha channel is removed;
##              * if 'alpha' == "keep", use the existing alpha channel if present;
##              * if 'alpha' == "add", a new opaque alpha channel is added;
##              * if 'alpha' is a clip, it becomes the alpha channel of the resulting clip;
##                overrides any existing alpha channel.
##                  * if 'alpha' is a YUVA or RGBA clip, the A channel is used;
##                  * if 'alpha' is a YUV or Y-only clip, the Y channel is used;
##              * else, an error is raised.
##
## Return YUV(A)422
##
function To422(clip C, string "matrix", int "bits_out", val "alpha")
{
    Assert(IsClip(C) && C.Width%2==0,
    \   "To422: source width not modulo-2")
    return C._ToYUVx(422, matrix, bits_out, alpha)
}

##################################
### Convert from anything to YUV(A)420
##  * Process internally at the next higher bit depth.
##
## @ matrix   - ignored if not converting from RGB; default "Rec601"
## @ bits_out - output bit depth, one of (8|10|12|14|16|32); default same as source
## @ alpha    - sets the alpha channel.
##              * if 'alpha' == "none" (default), any existing alpha channel is removed;
##              * if 'alpha' == "keep", use the existing alpha channel if present;
##              * if 'alpha' == "add", a new opaque alpha channel is added;
##              * if 'alpha' is a clip, it becomes the alpha channel of the resulting clip;
##                overrides any existing alpha channel.
##                  * if 'alpha' is a YUVA or RGBA clip, the A channel is used;
##                  * if 'alpha' is a YUV or Y-only clip, the Y channel is used;
##              * else, an error is raised.
##
## Return YUV(A)420
##
function To420(clip C, string "matrix", int "bits_out", val "alpha")
{
    Assert(IsClip(C) && C.Width%2==0 && C.Height%2==0,
    \   "To420: source width or height not modulo-2")
    return C._ToYUVx(420, matrix, bits_out, alpha)
}

##################################
### Convert from anything to Y-only
##  * Process internally at the next higher bit depth.
##
## @ matrix   - ignored if not converting from RGB; default "Rec601"
## @ bits_out - output bit depth, one of (8|10|12|14|16|32); default same as source
##
## Return YUV(A)420
##
function To400(clip C, string "matrix", int "bits_out")
{
    Assert(IsClip(C) && C.Width%2==0 && C.Height%2==0,
    \   "To400: source width or height not modulo-2")
    return C._ToYUVx(400, matrix, bits_out, "none")
}

##################################
### Convert from anything to YUV(A)xxx (444|422|420|400)
##  * Process internally at the next higher bit depth.
##
## @ chroma   - one of (444|422|420|400) ("400" = Y-only w/ no alpha)
## @ matrix   - ignored if not converting from RGB; default "Rec601"
## @ bits_out - output bit depth, one of (8|10|12|14|16|32); default same as source
## @ alpha    - sets the alpha channel.
##              * if 'alpha' == "none" (default), any existing alpha channel is removed;
##              * if 'alpha' == "keep", use the existing alpha channel if present;
##              * if 'alpha' == "add", a new opaque alpha channel is added;
##              * if 'alpha' is a clip, it becomes the alpha channel of the resulting clip;
##                overrides any existing alpha channel.
##                  * if 'alpha' is a YUVA or RGBA clip, the A channel is used;
##                  * if 'alpha' is a YUV or Y-only clip, the Y channel is used;
##              * else, an error is raised.
##
## Return YUV(A)xxx
##
function _ToYUVx(clip C, int chroma, string "matrix", int "bits_out", val "alpha")
{
    matrix = Default(matrix, "Rec601")
    biti   = C.BitsPerComponent
    bito   = Default(bits_out, biti)
    alpha  = Default(alpha, "none")
    #bitn   = (bito>=16) ? R41_BITMAX : (bito + 2) ## intermediate bit depth
    bitn   = _nextHiBit(bito)
    isyuv  = (C.IsYUV || C.IsYUVA || C.IsY)   

    Assert(chroma==444||chroma==422||chroma==420||chroma==400,
    \   "ToYUV: 'chroma' must be one of (444|422|420|400)")
    Assert(bito==8||bito==10||bito==12||bito==14||bito==16||bito==32,
    \   "ToYUV: 'bits_out' argument must be one of (8|10|12|14|16|32)")

    C = (IsString(alpha) && StrCmpi(alpha, "none")==0) 
    \ ? C.RemoveAlphaPlane
    \ : C

    A = (IsString(alpha) && StrCmpi(alpha, "none")==0)
    \    ? Nop
    \ : (IsString(alpha) && StrCmpi(alpha, "add")==0)
    \    ? C.AddAlphaPlane.ExtractA
    \       .ConvertBits42(bito)
    \ : (IsString(alpha) && StrCmpi(alpha, "keep")==0)
    \    ? (C.HasAlpha) 
    \       ? C.ExtractA
    \          .ConvertBits42(bito)
    \       : Nop
    \ : (IsClip(alpha) && alpha.HasAlpha)
    \    ? alpha.ExtractA
    \       .ConvertBits42(bito)
    \ : (IsClip(alpha) && alpha.IsY)
    \    ? alpha.ConvertBits42(bito)
    \ : (IsClip(alpha) && alpha.IsYUV)
    \    ? alpha.ExtractY
    \       .ConvertBits42(bito)
    \ : Assert(false, "ToRGB: invalid 'alpha' argument ('keep'|'add'|'none'|clip)")

    Q = (isyuv)      ? C 
    \ : (bitn<=biti) ? C 
    \ : C.ToHibit(bitn) 

    R = (isyuv) 
    \ ? Q._ConvertToYXX(chroma)
    \    .ConvertBits42(bito)
    \ : Q.ConvertToPlanarRGB
    \    ._ConvertToYXX(chroma, matrix=matrix)
    \    .ConvertBits42(bito)

    R = (chroma!=400 && IsClip(A))
    \ ? CombinePlanes(R.ExtractY, R.ExtractU, R.ExtractV, A, planes="YUVA",
    \       pixel_type=BitsToPixelType("YUVA", bito, chroma))
    \ : R

    return R

    #########################################################
    function _ConvertToYXX(clip C, int chroma, string "matrix") 
    {
        return (chroma==444) ? C.ConvertToYUV444(matrix=matrix)
        \  :   (chroma==422) ? C.ConvertToYUV422(matrix=matrix)
        \  :   (chroma==420) ? C.ConvertToYUV420(matrix=matrix)
        \                    : C.ConvertToY(matrix)
    }
}

##################################
### Convert from anything to best equivalent 16-bit version
##  * no RGB>YUV conversions
##
## @ A - if supplied, becomes the alpha channel of the resulting clip;
##       overrides any existing alpha channel.
##       * if 'A' is RGBA or YUVA, the A channel is used;
##       * if 'A' YUV or Y-only,   the Y channel is used;
##       * else, 'A' is ignored.
##
## Returns:
##   any RGB(A) -> RGB(A)P16
##   any 444    -> YUV(A)444P16
##   any 422    -> YUV(A)422P16
##   any 420    -> YUV(A)420P16
##   any Yxx    -> YxxP16 // no alpha  
##
function To16bit(clip C, clip "A")
{
    return (C.BitsPerComponent==32)
    \ ? C.ToLobit(16, A)
    \ : C.ToHibit(16, A)
}

##################################
### Convert from anything to best equivalent higher-bit-depth version
##  * no RGB>YUV conversions
##  * 32-bit sources are passed through unchanged
##
## @ bits - one of (8|10|12|14|16|32); 
##          * if not greater than current bit depth, no action taken
##          * "bits=8" always does nothing
## @ A    - if supplied, becomes the alpha channel of the resulting clip;
##          overrides any existing alpha channel.
##          * if 'A' is RGBA or YUVA, the A channel is used;
##          * if 'A' YUV or Y-only,   the Y channel is used;
##          * else, 'A' is ignored.
##
## Returns:
##   any RGB(A) -> RGB(A)P'bits' // NOT RGB48/64
##   any 444    -> YUV(A)444P'bits'
##   any 422    -> YUV(A)422P'bits'
##   any 420    -> YUV(A)420P'bits'
##   any Yxx    -> YxxP'bits' // no alpha  
##
function ToHibit(clip C, int bits, clip "A")
{
    Assert(bits==8||bits==10||bits==12||bits==14||bits==16||bits==32,
    \   "ToHibit: 'bits' argument must be one of (10|12|14|16|32)")

    biti = C.BitsPerComponent
    bito = bits

    A  = (bito<=biti) 
    \    ? Nop
    \ : (Defined(A) && IsClip(A) && A.HasAlpha)
    \    ? A.ExtractA
    \       .ConvertBits42(bito)
    \ : (Defined(A) && IsClip(A) && A.IsY)
    \    ? A.ConvertBits42(bito)
    \ : (Defined(A) && IsClip(A) && A.IsYUV)
    \    ? A.ExtractY
    \       .ConvertBits42(bito)
    \ : (C.HasAlpha)
    \    ? C.ExtractA
    \       .ConvertBits42(bito)
    \ : Nop 

    R = (bito<=biti) ? C
    \ : (C.IsRGB64 || C.IsRGB32) 
    \    ? C.ConvertToPlanarRGBA
    \       .ConvertBits42(bito)
    \ : (C.IsRGB48 || C.IsRGB24)
    \    ? C.ConvertToPlanarRGB
    \       .ConvertBits42(bito)
    \ : (C.IsYUY2)
    \    ? C.ConvertToYUV422
    \       .ConvertBits42(bito)
    \ : (C.IsYV411)
    \    ? C.ConvertToYUV411
    \       .ConvertBits42(bito)
    \ : C.ConvertBits42(bito)

    chroma = (R.Is444) ? 444 
    \      : (R.Is422) ? 422 
    \      : (R.Is420) ? 420
    \      : 0
    R = (bito<=biti) ? C
    \ : (R.IsRGB)
    \    ? (IsClip(A)==false) ? R
    \    : CombinePlanes(R.ExtractR, R.ExtractG, R.ExtractB, A, "RGBA")
    \ : (R.Is444 || R.Is422 || R.Is420)
    \    ? (IsClip(A)==false) ? R
    \    : CombinePlanes(R.ExtractY, R.ExtractU, R.ExtractV, A, "YUVA", 
    \        pixel_type=BitsToPixelType("YUVA", bito, chroma) )
    \ : R
    return R
}

##################################
### Convert from anything to best equivalent lower-bit-depth version
##  * no RGB>YUV conversions
##  * 8-bit sources are passed through unchanged
##
## @ bits   - one of (8|10|12|14|16|32); 
##            * if not less than current bit depth, no action taken
##            * "bits=32" always does nothing
## @ dither - if true, add dither when applicable; default false
## @ A      - if supplied, becomes the alpha channel of the resulting clip;
##            overrides any existing alpha channel.
##            * if 'A' is RGBA or YUVA, the A channel is used;
##            * if 'A' YUV or Y-only,   the Y channel is used;
##            * else, 'A' is ignored.
##
## Returns:
##   any RGB(A) -> RGB(A)P'bits'    // NOT RGB48/64
##   any 444    -> YUV(A)444P'bits'
##   any 422    -> YUV(A)422P'bits' // NOT YUY2
##   any 420    -> YUV(A)420P'bits'
##   any Yxx    -> YxxP'bits' // no alpha  
##
function ToLobit(clip C, int bits, bool "dither", clip "A")
{
    Assert(bits==8||bits==10||bits==12||bits==14||bits==16||bits==32,
    \   "ToLobit: 'bits' argument must be one of (10|12|14|16|32)")

    biti = C.BitsPerComponent
    bito = bits
    dith = (Default(dither, false) && biti>8 && biti<32 && bito<biti) ? 0 : -1

    A = (bito>=biti) ? Nop
    \ : (Defined(A) && IsClip(A) && A.HasAlpha)
    \    ? A.ExtractA
    \       .ConvertBits42(bito)
    \ : (Defined(A) && IsClip(A) && A.IsY)
    \    ? A.ConvertBits42(bito)
    \ : (Defined(A) && IsClip(A) && A.IsYUV)
    \    ? A.ExtractY
    \       .ConvertBits42(bito)
    \ : (C.HasAlpha)
    \    ? C.ExtractA
    \       .ConvertBits42(bito)
    \ : Nop 

    R = (bito>=biti) ? C
    \ : (C.IsRGB64 || C.IsRGB32) 
    \    ? C.ConvertToPlanarRGBA
    \       .ConvertBits42(bito, dither=dith)
    \ : (C.IsRGB48 || C.IsRGB24)
    \    ? C.ConvertToPlanarRGB
    \       .ConvertBits42(bito, dither=dith)
    \ : (C.IsYUY2)
    \    ? C.ConvertToYUV422
    \       .ConvertBits42(bito, dither=dith)
    \ : (C.IsYV411)
    \    ? C.ConvertToYUV411
    \       .ConvertBits42(bito, dither=dith)
    \ : C.ConvertBits42(bito, dither=dith)

    return (bito>=biti) ? C
    \ : (R.IsRGB)
    \    ? (IsClip(A)==false) ? R
    \    : CombinePlanes(R.ExtractR, R.ExtractG, R.ExtractB, A, "RGBA")
    \ : (R.Is444 || R.Is422 || R.Is420)
    \    ? (IsClip(A)==false) ? R
    \    : CombinePlanes(R.ExtractY, R.ExtractU, R.ExtractV, A, "YUVA")
    \ : R
}

##################################
### Convert from anything to 'best' (v2.6x compatible) equivalent 8-bit version
##  no RGB>YUV conversions
##
## @ dither  - if true, add dither when applicable; default false
##
## Returns:
##   any RGBA -> RGB32
##   any RGB  -> RGB24
##   any 444  -> YV24
##   any 422  -> YUY2
##   any 420  -> YV12
##   any Yxx  -> Y8
##   YV411 (no change)
## (no YUVA output, so save your alpha channel elsewhere)
##
function To8bit(clip C, bool "dither")
{
    biti = C.BitsPerComponent
    dith = (Default(dither, false) && biti>8 && biti<32) ? 0 : -1 

    R  = (C.IsRGB32) ? C
    \  : (C.IsRGB24) ? C
    \  : (C.IsYV24)  ? C
    \  : (C.IsYV12)  ? C
    \  : (C.IsYV16)  ? C
    \  : (C.IsYUY2)  ? C
    \  : (C.IsYV411) ? C
    \  : (C.IsY8)    ? C
    \  : (C.IsRGB)
    \     ? (C.HasAlpha)
    \        ? C.ConvertBits42(8, dither=dith)
    \           .ConvertToRGB32
    \        : C.ConvertBits42(8, dither=dith)
    \           .ConvertToRGB24
    \  : (C.Is444) 
    \     ? C.RemoveAlphaPlane
    \        .ConvertBits42(8, dither=dith)
    \        .ConvertToYV24
    \  : (C.Is422)
    \     ? C.RemoveAlphaPlane
    \        .ConvertBits42(8, dither=dith)
    \        .ConvertToYUY2
    \  : (C.Is420)
    \     ? C.RemoveAlphaPlane
    \        .ConvertBits42(8, dither=dith)
    \        .ConvertToYV12
    \  : (C.IsY) 
    \     ? C.ConvertBits42(8, dither=dith)
    \  : Assert(false, 
    \        "To8bit: unrecognized color format")

    return R
}

##################################
### pass RGB through Stack16
##  (all major 16bit formats supported, but only RGB requires special handling)
##  (ConvertToStacked accepts only YUV444P16, YUV422P16, YUV420P16 and Y16)
##  Note alpha channel (if present) is removed, but [[#FromStack16]] can restore it.
##
## @ C - 16-bit only
## @ swap_planes - if true, transport RGB in YV24: G=>Y, B=>U, R=>V;
##       else (default), convert RGB to to YV24.
##       Default=YV24 because most Stack16 filters expect TV-range YUV;
##       but swap_planes is useful for filters that handle GBR.
##
function ToStack16(clip C, bool "swap_planes")
{
    Assert(C.BitsPerComponent==16, 
    \   "ToStack16: invalid source clip (16-bit only)")
    swp = Default(swap_planes, false)
    C
    RemoveAlphaPlane
    (IsRGB)
    \ ? (swp) ? GBR2YUV : ConvertToYUV444 
    \ : Is444 ? Last
    \ : Is422 ? Last
    \ : Is420 ? Last
    \ : IsY   ? Last
    \ : To420
    ConvertToStacked ## YUV444P16; YUV422P16; YUV420P16; Y16
    return Last
}

##################################
### recover RGB previously passed through ToStack16
##  (all major color formats supported, but only RGB requires special handling)
##
## @ T - template clip for restoring original color format;
##       Note: alpha data is copied from 'T' if present and possible
##       (if any other clip properties not compatible, alpha is ignored)
## @ swap_planes - use whatever you used in ToStack16
##
function FromStack16(clip C, clip T, bool "swap_planes")
{
    Assert(C.BitsPerComponent==8, 
    \   "FromStack16: invalid source clip (8-bit only)")
    Assert(T.BitsPerComponent==16, 
    \   "FromStack16: invalid template clip (16-bit only)")
    swp = Default(swap_planes, false)
    C
    ConvertFromStacked

    (T.IsRGB)
    \ ? (swp)   ? YUV2GBR.MatchColorFormat(T)
    \           : Last.MatchColorFormat(T) 
    \ : T.Is444 ? Last
    \ : T.Is422 ? Last
    \ : Is420   ? Last
    \ : T.IsY   ? Last
    \ : MatchColorFormat(T)
    (T.HasAlpha)
    \ ? AddAlphaPlane42(T, silent=1>0)
    \ : Last
    return Last
} 

#######################################
### add an alpha plane from another clip
##
## @ C - must be RGB(A), YUV444 or YUV420
## @ A - RGBA, YUVA, YUV or Y-only; if YUV, alpha is taken from the Y (luma) channel. 
##       Must be same size as source; bit depth is converted as required.
## @ silent - if true, do not raise errors, simply return C unchanged; default false.
##
function AddAlphaPlane42(clip C, clip A, bool "silent")
{
    silent = Default(silent, false)
    Assert(silent || (IsClip(C) && (C.IsRGB||C.Is444||C.Is420)),
    \   "AddAlphaPlane42: source must be RGB(A), YUV444 or YUV420") 
    bits = C.BitsPerComponent

    A = (IsClip(A) && A.HasAlpha)
    \    ? A.ExtractA
    \       .ConvertBits42(bits)
    \ : (IsClip(A) && A.IsY)
    \    ? A.ConvertBits42(bits)
    \ : (IsClip(A) && A.IsYUV)
    \    ? A.ExtractY
    \       .ConvertBits42(bits)
    \ : Nop

    Assert(silent || IsClip(A), 
    \   "AddAlphaPlane42: invalid alpha source clip 'A'")
    Assert(silent || (A.Width==C.Width && A.Height==C.Height),
    \   "AddAlphaPlane42: alpha source clip 'A' size does not match")

    R = C
    chroma = (R.Is444) ? 444 
    \      : (R.Is422) ? 422 
    \      : (R.Is420) ? 420
    \      : 0
    try {
        R = (!IsClip(A)) ? C
        \ : (C.IsRGB)
        \    ? CombinePlanes(C.ExtractR, C.ExtractG, C.ExtractB, A, "RGBA", 
        \          pixel_type=BitsToPixelType("RGBA", bits))
        \    : CombinePlanes(C.ExtractY, C.ExtractU, C.ExtractV, A, "YUVA", 
        \          pixel_type=BitsToPixelType("YUVA", bits, chroma))
    }
    catch(err_msg) {
        Assert(silent,
        \   "AddAlphaPlane42: " + err_msg)
    }

    R = (!IsClip(A)) ? C
    \ : (C.IsRGB32)
    \    ? R.ConvertToRGB32 
    \ : (C.IsRGB24)
    \    ? R.ConvertToRGB24 
    \ : (C.IsRGB64)
    \    ? R.ConvertToRGB64 
    \ : (C.IsRGB48)
    \    ? R.ConvertToRGB48 
    \ : (C.IsYV24) 
    \    ? R.ConvertToYV24
    \ : (C.IsYUY2)
    \    ? R.ConvertToYUY2
    \ : (C.IsYV16) 
    \    ? R.ConvertToYV16
    \ : (C.IsYV12)
    \    ? R.ConvertToYV12
    \ : (C.IsYV411)
    \    ? R.ConvertToYV411
    \ : (C.IsY8)
    \    ? R.ConvertToY8
    \ : (C.IsRGB||C.Is444||C.Is422||C.Is420||C.IsY)
    \    ? R
    \ : Assert(false, 
    \      "AddAlphaPlane42: unrecognized color format")
    return R
}

## fka ToVdubFM
##################################
### make changes needed to display on VirtualDub2 (fka VirtualDub FilterMod)
##  [https://sourceforge.net/projects/vdfiltermod/]
##
## @ dither - if true, reduce bit depth to 8 bit with dithering if applicable;
##            default false
##
## VirtualDub2 does not currently support all AVS+ color spaces; 
## ToVdub2 does minimally-destructive translation
## per docs, VirtualDub2 accepts:
##      10-bit 422 (v210 interleaved)
##      16-bit 422, 444, 420 (planar)
##      16-bit RGBA
## this filter returns:
##       8-bit formats unchanged, except YV411->YV420
##      10-bit 422 (planar, not interleaved)
##      16-bit 422 (planar)
##      16-bit RGBA
##
## version 2017-04-29 raffriff42
## version 2017-05-16 dither option; bugfixes after more thorough testing
## version 2017-05-22 16-bit 444 not displaying, so falling back to 422
## version 2018-03-10 for VirtualDub2 v19.0 (greatly improved YUV support)
## version 2018-03-13 revert 2018-03-10; name change
##
function ToVdub2(clip C, bool "dither")
{
    dit8 = Default(dither, false)
    bits = C.BitsPerComponent
    dith = (bits > 8 && bits < 32) ? 0 : -1

    Assert(IsClip(C),
    \   "ToVdub2: clip 'C' appears to be invalid")
    Assert(HasVideo(C),
    \   "ToVdub2: clip 'C' appears not to contain video")
    Assert(C.Height>0 && C.Width>0,
    \   "ToVdub2: clip 'C' appears to be zero width or height")

    CY = (C.HasAlpha) ? C.RemoveAlphaPlane : C

    R = (C.IsRGB24) ? C
    \ : (C.IsRGB32) ? C
    \ : (C.IsYV24)  ? C
    \ : (C.IsYUY2)  ? C
    \ : (C.IsYV12)  ? C
    \ : (C.IsYV411) ? C.ConvertToYV12
    \ : (C.IsY8)    ? C
    \
    \ : (C.IsRGB && C.NumComponents==4) 
    \   ? (bits==8)  ? C                          .ConvertToRGB32
    \   : (bits==16) ? C                          .ConvertToRGB64
    \   : (dit8) ? C.ConvertBits42(8, dither=dith).ConvertToRGB32 
    \            : C.ConvertBits42(16)            .ConvertToRGB64 
    \
    \ : (C.IsRGB && C.NumComponents==3) 
    \   ? (bits==8)  ? C                          .ConvertToRGB24
    \   : (bits==16) ? C                          .ConvertToRGB64
    \   : (dit8) ? C.ConvertBits42(8, dither=dith).ConvertToRGB24 
    \            : C.ConvertBits42(16)            .ConvertToRGB64 
    \                                          [* 16bit: ConvertToRGB48 ng *]
    \ : (C.Is444) 
    \   ? (bits==8)  ? CY                          .ConvertToYV24
    \   : (bits==16) ? CY                          .ConvertToYUV444
    \   : (dit8) ? CY.ConvertBits42(8, dither=dith).ConvertToYV24 
    \            : CY.ConvertBits42(16)            .ConvertToYUV444 
    \                                          [* 16bit: ConvertToYUV444 ng ???? *]  
    \ : (C.Is422)
    \   ? (bits==8)  ? CY                          .ConvertToYUY2
    \   : (bits==10) ? CY                          .ConvertToYUV422
    \   : (dit8) ? CY.ConvertBits42(8, dither=dith).ConvertToYUY2 
    \            : CY.ConvertBits42(16)            .ConvertToYUV422  
    \ : (C.Is420) 
    \   ? (bits==8)  ? CY                          .ConvertToYV12
    \   : (bits==10) ? CY                          .ConvertToYUV420
    \   : (dit8) ? CY.ConvertBits42(8, dither=dith).ConvertToYV12 
    \            : CY.ConvertBits42(16)            .ConvertToYUV420 
    \                                          [* 16bit: ConvertToYUV420 ng *]
    \ : (C.IsY)
    \   ? (bits==8)  ? C                           .ConvertToY8
    \   : (bits==10) ? C                           .ConvertToYUV422
    \   : (dit8) ? C.ConvertBits42(8, dither=dith) .ConvertToY8 
    \            : C.ConvertBits42(16)             .ConvertToYUV422  
    \                                          [* 16bit: ConvertToY ng ? *]
    \ : Assert(false,
    \   "ToVdub2: internal error 2: clip 'C' has unrecognized pixel type")

    Assert(IsClip(R),
    \   "ToVdub2: internal error 4: clip 'R' invalid")
    Assert(HasVideo(R),
    \   "ToVdub2: internal error 6: clip 'R' has no video")
    Assert(R.Height>0 && R.Width>0,
    \   "ToVdub2: internal error 8: clip 'R' zero width or height")
    return R
}

##################################
### Match color format (PixelType) of source 'C' to template 'T'
##  (for ease of splicing, etc)
##
## @ matrix    - ignored if not converting between RGB<>YUV; default "Rec601"
## @ keepbits  - if true, retain original bit depth; 
##               else (default) force bit depth to match 'T'
## @ dither    - if true, add dither when converting to lower bit depth; default false
##
## version 2017-05-16 bugfixes
## version 2017-11-24 bugfixes; rename 'matchbits' ~> 'keepbits'
## version 2020-01-01 YUY2 bugfix h/t hello_hello
##
function MatchColorFormat(clip C, clip T, string "matrix", bool "keepbits", bool "dither")
{
    Assert(IsClip(C) && C.HasVideo, 
    \   "MatchColorFormat: clip 'C' invalid")
    Assert(IsClip(T) && T.HasVideo, 
    \   "MatchColorFormat: clip 'T' invalid")

    matrix = Default(matrix, "Rec601")
    keep   = Default(keepbits, false)
    biti   = C.BitsPerComponent
    bito   = (keep) ? C.BitsPerComponent : T.BitsPerComponent
    dith   = (Default(dither, false) && biti>8 && biti<32 && bito<biti) ? 0 : -1

    A = (C.HasAlpha) 
    \ ? C.ExtractA.ConvertBits42(bito)
    \ : Nop

    C = (C.IsPlanar) 
    \ ? C
    \ : (C.IsRGB) 
    \    ? C.ConvertToPlanarRGB
    \    : C.ConvertToYUV444

    ## upconvert (if applicable) *before* YUV<>RGB 
    C  = (biti<bito) 
    \  ? C.ConvertBits42(bito) 
    \  : C

    R  = (T.IsRGB)
    \     ? (C.IsRGB)
    \         ? C
    \         : C.ConvertToPlanarRGB(matrix=matrix)
    \  : (T.Is444) 
    \     ? (C.IsRGB)
    \         ? C.ConvertToYUV444(matrix=matrix)
    \         : C.ConvertToYUV444
    \  : (T.Is422) 
    \     ? (C.IsRGB)
    \         ? C.ConvertToYUV422(matrix=matrix)
    \         : C.ConvertToYUV422
    \  : (T.Is420) 
    \     ? (C.IsRGB)
    \         ? C.ConvertToYUV420(matrix=matrix)
    \         : C.ConvertToYUV420
    \  : (T.IsYUY2)
    \     ? (C.IsRGB)
    \         ? C.ConvertToYUV422(matrix=matrix)
    \            .ConvertBits42(8, dither=dith).ConvertToYUY2
    \         : C.ConvertToYUV422
    \            .ConvertBits42(8, dither=dith).ConvertToYUY2
    \  : (T.IsYV411)
    \     ? (C.IsRGB)
    \         ? C.ConvertToYUV411(matrix=matrix)
    \            .ConvertBits42(8, dither=dith).ConvertToYV411
    \         : C.ConvertToYUV411
    \            .ConvertBits42(8, dither=dith).ConvertToYV411
    \  : (T.IsY) 
    \     ? (C.IsRGB)
    \         ? C.ConvertToYUV420(matrix=matrix).ConvertToY
    \         : C.ConvertToYUV420.ConvertToY
    \  : Assert(false, 
    \        "MatchColorFormat: unrecognized template format (1)")

    bitr = R.BitsPerComponent
    dith = (Default(dither, false) && bitr>8 && bitr<32 && bito<bitr) ? 0 : -1
    R  = R.ConvertBits42(bito, dither=dith)

    Assert(T.BitsPerComponent==R.BitsPerComponent
    \   && T.IsRGB==R.IsRGB
    \   && T.Is444==R.Is444 
    \   && T.Is422==R.Is422 
    \   && T.Is420==R.Is420
    \   && T.IsYUY2==R.IsYUY2
    \   && T.IsYV411==R.IsYV411
    \   && T.IsY==R.IsY, 
    \ "MatchColorFormat: internal error (1): T="+T.PixelType+"; R="+R.PixelType)

    R  = (T.IsRGB32)
    \     ? R.ConvertToRGB32 
    \  : (T.IsRGB24)
    \     ? R.ConvertToRGB24 
    \  : (T.IsRGB64)
    \     ? R.ConvertToRGB64 
    \  : (T.IsRGB48)
    \     ? R.ConvertToRGB48 
    \  : (T.IsYV24) 
    \     ? R.ConvertToYV24
    \  : (T.IsYUY2)
    \     ? R.ConvertToYUY2
    \  : (T.IsYV16) 
    \     ? R.ConvertToYV16
    \  : (T.IsYV12)
    \     ? R.ConvertToYV12
    \  : (T.IsYV411)
    \     ? R.ConvertToYV411
    \  : (T.IsY8)
    \     ? R.ConvertToY8
    \  : (T.IsRGB||T.Is444||T.Is422||T.Is420||T.IsY)
    \     ? R
    \  : Assert(false, 
    \        "MatchColorFormat: unrecognized template format (2)")

    R = (T.HasAlpha && C.HasAlpha) 
    \ ? R.AddAlphaPlane(A)
    \ : R 

    R = (T.HasAlpha)
    \ ? (R.HasAlpha)  ? R : R.AddAlphaPlane
    \ : (!R.HasAlpha) ? R : R.RemoveAlphaPlane

    Assert(T.PixelType==R.PixelType, 
    \   "MatchColorFormat: internal error (99): T='"+T.PixelType+"'; R='"+R.PixelType+"'")
    return R
}

##################################
### Match audio properties of source 'C' to template 'T'
##  (for ease of splicing, etc)
##  Properties matched:
##  number of channels (see note), bit depth, sample rate
##  Properties NOT matched:
##  audio duration (new audio may have much longer duration but not shorter)
##
## AudioChannels handling:
##   if 'T' has no audio, returns 'C'.KillAudio;
##   if 'C' has no audio, copies silenced audio from 'T';
##   if 'T' and 'C' have the same channel count, no change is made;
##   if 'T' has 1 channel, returns 'C'.ConvertToMono;
##   if 'T' has 2 channels and 'C' has 1, returns 'C' with split mono;
##   otherwise, an error is raised (manual intervention is needed)
##
## @ allowresample - if true, resample audio to match template if needed;
##                   if false (the default), use [[AssumeSampleRate]],
##                   which may affect audio pitch or audio/video sync.
##
function MatchAudioFormat(clip C, clip T, bool "allowresample")
{
    Assert(IsClip(C), 
    \   "MatchAudioFormat: clip 'C' invalid")
    Assert(IsClip(T), 
    \   "MatchAudioFormat: clip 'T' invalid")

    allowresample = Default(allowresample, false)

    D = (T.HasAudio==false) ? C.KillAudio
    \ : (C.HasAudio==false) ? C.AudioDub(T.Loop).Amplify(0)
    \ : (C.AudioChannels==T.AudioChannels) ? C
    \ : (C.AudioChannels==2 && T.AudioChannels==1) ? C.ConvertToMono
    \ : (C.AudioChannels==1 && T.AudioChannels==2) ? C.MergeChannels(C, C)
    \ : Assert(false, 
    \       "MatchAudioFormat: channels > 2") 

    ## use AssumeSampleRate if 'allowresample' = false, or:
    ##  (1) pitch shift less than (arbitrary) 2%, AND
    ##  (2) change in duration less than (arbitrary) 25 msec
    dur   = (C.HasAudio) ? C.AudioDuration : 0.0
    Tfr   = (T.HasAudio) ? T.AudioRate : 0
    Cfr   = (C.HasAudio) ? C.AudioRate : 0
    Tff   = Float(Tfr)
    Cff   = Float(Cfr)
    asok  = (allowresample==false) ? true
    \     : (Tfr<1 || Cfr<1) ? false
    \     : (Abs(1.0 - Tff / Cff) <= 0.02) &&
    \       (Abs(dur - (dur * Tff / Cff)) < 0.025)
                                                        
    ## else, use SSRC if sample rate ratio is allowed:
    ssok = _ssrc_ok(Cfr, Tfr)

    ## ...else, use ResampleAudio 
    rsok = (Tfr>=1 && Cfr>=1)

    D = (Cfr==Tfr) ? D
    \ : (asok) ? D.AssumeSampleRate(Tfr)
    \ : (ssok) ? D.ConvertAudioToFloat.SSRC(Tfr)
    \ : (rsok) ? D.ConvertAudioToFloat.ResampleAudio(Tfr)
    \ : D

    D = (Tfr<1 || Cfr<1) ? D
    \ : (D.IsAudioFloat==T.IsAudioFloat) && (D.AudioBits==T.AudioBits) ? D
    \ : (T.IsAudioFloat)  ? D.ConvertAudioToFloat 
    \ : (T.AudioBits==32) ? D.ConvertAudioTo32bit
    \ : (T.AudioBits==24) ? D.ConvertAudioTo24bit
    \ : (T.AudioBits==16) ? D.ConvertAudioTo16bit
    \ : (T.AudioBits==8)  ? D.ConvertAudioTo8bit
    \ : Assert(false, 
    \       "MatchAudioFormat: unrecognized sample format") 

    return D
}

#######################################
### transport Planar RGB(A) in YUV(A)444: G=>Y, B=>U, R=>V
##
## @ yuva - if true (default) AND source has alpha channel, output is YUVA; else it's YUV
##
function GBR2YUV(clip C, bool "yuva")
{
    Assert(C.IsPlanarRGB || C.IsPlanarRGBA, 
    \   "GBR2YUV: source must be Planar RGB(A)")
    yuva = Default(yuva, true)
    
    return (C.NumComponents==4 && yuva)
    \ ? CombinePlanes(C.ExtractG, C.ExtractB, C.ExtractR, C.ExtractA, "YUVA",
    \       pixel_type=BitsToPixelType("YUVA", C.BitsPerComponent, 444))
    \ : CombinePlanes(C.ExtractG, C.ExtractB, C.ExtractR, "YUV",
    \       pixel_type=BitsToPixelType("YUV", C.BitsPerComponent, 444))
}

#######################################
### transport YUV(A)444 in Planar RGB(A): Y=>G, U=>B, V=>R
##
## @ A - if supplied, provides the alpha data to merge into the output; 
##       RGBA, YUVA, YUV or Y-only; if YUV, alpha is taken from the Y (luma) channel. 
##
function YUV2GBR(clip C, clip "A")
{
    Assert(C.Is444, 
    \   "YUV2GBR: source 'C' must be 4:4:4")
    Assert(!Defined(A) || A.HasAlpha || A.IsYUV || A.IsYUVA || A.IsY,
    \   "YUV2GBR: alpha source 'A' must be RGBA, YUVA, YUV or Y-only")

    bits = C.BitsPerComponent
    A = (Defined(A) && IsClip(A) && A.HasAlpha)
    \    ? A.ExtractA
    \       .ConvertBits42(bits)
    \ : (Defined(A) && IsClip(A) && A.IsY)
    \    ? A.ConvertBits42(bits)
    \ : (Defined(A) && IsClip(A) && A.IsYUV)
    \    ? A.ExtractY
    \       .ConvertBits42(bits)
    \ : (C.HasAlpha)
    \    ? C.ExtractA
    \ : Nop

    return IsClip(A)
    \ ? CombinePlanes(C.ExtractY, C.ExtractU, C.ExtractV, A, "GBRA",
    \       pixel_type=BitsToPixelType("RGBA", bits))
    \ : (C.NumComponents==4) 
    \     ? CombinePlanes(C.ExtractY, C.ExtractU, C.ExtractV, C.ExtractA, "GBRA",
    \           pixel_type=BitsToPixelType("RGBA", bits))
    \     : CombinePlanes(C.ExtractY, C.ExtractU, C.ExtractV, "GBR",
    \           pixel_type=BitsToPixelType("RGB", bits))
}

##############################
### TV->PC: convert levels from 'TV' (black=16d, white=235d) to 'PC' (black=0, white=255d)
## 
function ToPC(clip C)
{
    ## R, G, B, Y
    ## Eq.1    (x-16) * 255/(235-16) 
    ## Eq.2  ( (x-16) * 255/  219 ) - 0.5 ## round down
    ##
    sy = ("x 16@d - 255@d 219@d / * ")
    \    .ReplaceStr("@d", (C.IsRGB ? " scalef" : " scaleb"))

    ## U, V
    ## Eq.1    (x-128) * 255/(240-16) + 128
    ## Eq.2  ( (x-128) * 255/  224    + 128 ) - 0.5
    ##
    su = ("x 128@d - 255@d 224@d / * 128@d + ")
    \    .ReplaceStr("@d", (C.IsRGB ? " scalef" : " scaleb"))

    ## upconvert bit depth for less banding
    bito = C.BitsPerComponent
    #R    = C.ToHibit(R41_BITMAX)
    R    = C.ToHibit(_nextHiBit(bito))
    biti = R.BitsPerComponent
    Assert(biti<32 && bito<32, "ToPC: float32 not tested")
    
    ## downconvert bit depth as part of the Expr call
    ## (TODO: use built-in Expr constants)
    sscale = (bito==biti) ? "" : (" $n * $d / ") 
    \     .ReplaceStr("$n", String(_getFullscale(bito)))
    \     .ReplaceStr("$d", String(_getFullscale(biti)))
    sy = sy + sscale
    su = su + sscale

    return (C.IsRGB) ? R.Expr(sy, sy, sy, format=C.PixelType)
    \    : (C.IsY)   ? R.Expr(sy, format=C.PixelType)
    \                : R.Expr(sy, su, su, format=C.PixelType)
}

##############################
### PC->TV: convert levels from 'PC' (black=0, white=255d) to 'TV' (black=16d, white=235d)
##
function ToTV(clip C)
{
    ## R, G, B, Y
    ## Eq.1    x * (235-16)/255 + 16 
    ## Eq.2  ( x *   219   /255 + 16 ) - 0.5 ## round down
    ##
    sy = ("x 219@d 255@d / * 16@d + ")
    \    .ReplaceStr("@d", (C.IsRGB ? " scalef" : " scaleb"))

    ## U, V
    ## Eq.1    (x-128) * (240-16)/255 + 128
    ## Eq.2  ( (x-128) *   224   /255 + 128 ) - 0.5
    ##
    su = ("x 128@d - 224@d 255@d / * 128@d + ")
    \    .ReplaceStr("@d", (C.IsRGB ? " scalef" : " scaleb"))

    ## upconvert bit depth for less banding
    bito = C.BitsPerComponent
    #R    = C.ToHibit(R41_BITMAX)
    R    = C.ToHibit(_nextHiBit(bito))
    biti = R.BitsPerComponent
    Assert(biti<32 && bito<32, "ToTV: float32 not tested")

    ## downconvert bit depth as part of the Expr call
    ## (TODO: use built-in Expr constants)
    sscale = (bito==biti) ? "" : (" $n * $d / ") 
    \     .ReplaceStr("$n", String(_getFullscale(bito)))
    \     .ReplaceStr("$d", String(_getFullscale(biti)))
    sy = sy + sscale
    su = su + sscale

    return (C.IsRGB) ? R.Expr(sy, sy, sy, format=C.PixelType)
    \    : (C.IsY)   ? R.Expr(sy, format=C.PixelType)
    \                : R.Expr(sy, su, su, format=C.PixelType)
}

##############################
### 709->601 (less green, more red)
function To601(clip C)
{
    bitn = _nextHiBit(C.BitsPerComponent)
    return (C.IsRGB)
    \ ? C.To444("Rec601", bits_out=bitn).MatchColorFormat(C, "Rec709") 
    \ : C.ToRGB("PC.709", bits_out=bitn).MatchColorFormat(C, "PC.601")
}

##############################
### 601->709 (more green, less red)
function To709(clip C)
{
    bitn = _nextHiBit(C.BitsPerComponent)
    return (C.IsRGB)
    \ ? C.To444("Rec709", bits_out=bitn).MatchColorFormat(C, "Rec601")
    \ : C.ToRGB("PC.601", bits_out=bitn).MatchColorFormat(C, "PC.709")
}

##############################
### alias for [[#To709]]
function MatrixGreen(clip C)
{
    return To709(C)
}

##############################
### alias for [[#To601]]
function MatrixRed(clip C)
{
    return To601(C)
}

##############################
### Stack clip 'C' horizontally until it is at least 'wid' wide
##
function _stack_to_wid(clip C, int wid, clip "R", bool "flip") {
    R = Default(R, C)
    flip = Default(flip, false)
    C2 = (flip) ? C.FlipHorizontal : C
    return (R.Width >= wid) ? R
    \  : _stack_to_wid(C, wid, StackHorizontal(R, C2))
}

##############################
### Stack clip 'C' vertically until it is at least 'hgt' high
##
function _stack_to_hgt(clip C, int hgt, clip "R", bool "flip") {
    R = Default(R, C)
    flip = Default(flip, false)
    C2 = (flip) ? C.FlipVertical : C
    return (R.Height >= hgt) ? R
    \  : _stack_to_hgt(C, hgt, StackVertical(R, C2))
}

##############################
### Stack clip 'C' until it is 'wid' x 'hgt'
##
function stack_to_size(clip C, int wid, int hgt, bool "flip") {
    flip = Default(flip, false)
    C ## Last
    _stack_to_wid(wid, flip=flip)
    _stack_to_hgt(hgt, flip=flip)
    Crop(0, 0, wid, hgt)
    return Last
}

##################################
### remove gamma transfer function (if bit depth > 8) for linear-light processing
##  improves appearance of certain filters like [[Resize]];
### ( used in [[#ScaleZoom3]], [[#ScaleSize3]] )
##  must call restore_gamma before final output.
##
##  Disabled for 8-bit processing as it would create banding; 12-bit recommended minimum.
##
## @ matrix  - transfer function; one of (sRGB|Rec709|Rec2020); default "sRGB"
## @ tvrange - if true, anchor gamma curve on TV black (16d) and TV white (235d);
##             default false for RGB source, true for YUV; 
##             for Y-only sources, if 'tvrange' not specified, an error is raised.
## @ enable  - default true; if false, do nothing (bypass)
##
## @ version 2018-03-19 - tvrange
##
function remove_gamma(clip C, string "matrix", bool "tvrange", bool "enable")
{
    Assert((C.IsRGB || C.IsYUV) && C.IsPlanar42, 
    \   "remove_gamma: planar RGB(A) or planar YUV only")
    Assert(!C.IsY || Defined(tvrange), 
    \   "remove_gamma: 'tvrange' must be defined for Y-only clips")
    matrix  = Default(matrix, "sRGB")
    tvrange = Default(tvrange, !C.IsRGB)
    enable  = Default(enable,  true)

    matrix_id = (FindStr(matrix, "709")>0) ? 1
    \         : (FindStr(matrix, "202")>0) ? 2
    \         : 0 ## default = sRGB

    ## sRGB to linear
    ## https://en.wikipedia.org/wiki/SRGB
    as = 1.055
    ts = 0.04045 ## (~0.0031308 * 12.92)
    ms = 12.92   ## slope
    gs = 2.4     ## gamma

    ## Rec.709 to linear
    ## https://en.wikipedia.org/wiki/Rec._709
    a7 = 1.099
    t7 = 0.081   ## (~0.018 * 4.5)
    m7 = 4.5     ## slope
    g7 = 1/0.45  ## gamma (~2.222...)

    ## Rec.2020 to linear
    ## https://en.wikipedia.org/wiki/Rec._2020
    a2 = 1.09929682680944
    t2 = 0.0812428582986315  ## (~0.018053968510807 * 4.5) (??)
    m2 = 4.5     ## slope
    g2 = 1/0.45  ## gamma (~2.222...)

    a = Select(matrix_id, as, a7, a2)
    g = Select(matrix_id, gs, g7, g2)
    m = Select(matrix_id, ms, m7, m2)
    t = Select(matrix_id, ts, t7, t2)

    ## (x <= t) 
    ##   ? x / m
    ##   : ((x + (a - 1.0)) / a)^g
    ##
    sx  = "X 255@d / $t <= x 255@d / $m / X 255@d / $a 1 - + $a / $g ^ ? 255@d * "

    ## tvrange: ToPC, gamma, ToTV
    stv = "x 16@d - 255@d 219@d / * 0.48@d - X^ "
    \   + sx
    \   + "219@d 255@d / * 16@d + 0.48@d -  "
    spc = "x X^ " + sx 
    
    s = (tvrange) ? stv : spc 
    s = s.ReplaceStr("@d", (C.IsRGB ? " scalef" : " scaleb"))
    \    .ReplaceStr("$a", String(a, "%0.9f"))
    \    .ReplaceStr("$g", String(g, "%0.9f"))
    \    .ReplaceStr("$m", String(m, "%0.9f"))
    \    .ReplaceStr("$t", String(t, "%0.9f"))

    return (enable==false || C.BitsPerComponent==8) ? C 
    \ : (C.IsRGB)  
    \     ? C.Expr(s,  s,   s)
    \     : C.Expr(s, "x", "x") 
}

##################################
### apply gamma transfer function (if bit depth > 8) 
##  only call this if gamma was previously removed.
##
## @ matrix  - transfer function; one of (sRGB|Rec709|Rec2020); default "sRGB"
## @ tvrange - if true, anchor gamma curve on TV black (16d) and TV white (235d);
##             default false for RGB source, true for YUV; 
##             for Y-only sources, if 'tvrange' not specified, an error is raised.
## @ enable  - default true; if false, do nothing (bypass)
##
## @ version 2018-03-19 - tvrange
##
function restore_gamma(clip C, string "matrix", bool "tvrange", bool "enable")
{
    Assert((C.IsRGB || C.IsYUV) && C.IsPlanar42, 
    \   "restore_gamma: planar RGB(A) or planar YUV only")
    Assert(!C.IsY || Defined(tvrange), 
    \   "restore_gamma: 'tvrange' must be defined for Y-only clips")
    matrix  = Default(matrix, "sRGB")
    tvrange = Default(tvrange, !C.IsRGB)
    enable  = Default(enable,  true)

    matrix_id = (FindStr(matrix, "709")>0) ? 1
    \         : (FindStr(matrix, "202")>0) ? 2
    \         : 0 ## default = sRGB

    ## linear to sRGB
    ## https://en.wikipedia.org/wiki/SRGB
    as = 1.055
    ts = 0.0031308
    ms = 12.92 ## slope
    gs = 2.4   ## gamma

    ## linear to Rec.709
    ## https://en.wikipedia.org/wiki/Rec._709
    a7 = 1.099
    t7 = 0.018
    m7 = 4.5    ## slope
    g7 = 1/0.45 ## gamma (~2.222...)

    ## linear to Rec.2020
    ## https://en.wikipedia.org/wiki/Rec._2020
    a2 = 1.09929682680944
    t2 = 0.018053968510807
    m2 = 4.5    ## slope
    g2 = 1/0.45 ## gamma (~2.222...)

    a = Select(matrix_id, as, a7, a2)
    g = Select(matrix_id, gs, g7, g2)
    m = Select(matrix_id, ms, m7, m2)
    t = Select(matrix_id, ts, t7, t2)

    ## (x < t) 
    ##   ? x * m
    ##   : a * (x ^ (1.0/g)) - (a - 1.0)
    ##
    sx  = "X 255@d / $t <= X 255@d / $m * X 255@d / 1 $g / ^ $a * $a 1 - - ? 255@d * "
    
    ## tvrange: ToPC, gamma, ToTV
    stv = "x 16@d - 255@d 219@d   / * 0.48@d - X^ "
    \   + sx
    \   + "219@d 255@d / * 16@d + 0.48@d -  "
    spc = "x X^ " + sx
    
    s = (tvrange) ? stv : spc 
    s = s.ReplaceStr("@d", (C.IsRGB ? " scalef" : " scaleb"))
    \    .ReplaceStr("$a", String(a, "%0.9f"))
    \    .ReplaceStr("$g", String(g, "%0.9f"))
    \    .ReplaceStr("$m", String(m, "%0.9f"))
    \    .ReplaceStr("$t", String(t, "%0.9f"))

    return (enable==false || C.BitsPerComponent==8) ? C 
    \ : (C.IsRGB)  
    \     ? C.Expr(s,  s,   s)
    \     : C.Expr(s, "x", "x") 
}

##################################
### ConvertBits wrapper
##
## @ dither - if 0, add ordered dither; if -1, do not add dither.
## @ nobias - if true, never call _Bias; default false 
##
function ConvertBits42(clip C, int bits, int "dither", bool "nobias")
{
    bito    = bits
    dither  = Default(dither, -1)
    biti    = C.BitsPerComponent
    nobias  = Default(nobias, false) 
    vertest = (!IsAvsPlus || VersionBuildNumber>=2632)

    bias = vertest   ? false
    \ :  nobias      ? false
    \ : (biti==8)    ? false
    \ : (biti==32)   ? false
    \ : (bito>=biti) ? false
    \ : (dither>=0)  ? false
    \ : true

    C
    (bias) ? _Bias42(bito) : Last

    return ConvertBits(bito, dither=dither)

    ################################
    ## ConvertBits downconversion rounding issue (temp fix)
    ## https://forum.doom9.org/showthread.php?p=1821007#post1821007
    function _Bias42(clip C, int bito)
    {
        biti = C.BitsPerComponent
        IsFP = (biti==32)
        f    = 0.48
        n    = scbf(bito, biti, f) - 1.0 

        R  = (IsFP) ? C
        \  : (C.IsRGB)
        \     ? (C.HasAlpha)
        \        ? C.RGBAdjust(rb=2*n, gb=n, bb=3*n, ab=n)
        \        : C.RGBAdjust(rb=2*n, gb=n, bb=3*n)
        \  : (C.IsY) 
        \     ? C.ConvertToYUV420
        \        .ColorYUV(off_y=f, off_u=f, off_v=f) 
        \        .ConvertToY
        \  : (C.IsYUVA) 
        \     ? C.RemoveAlphaPlane._Bias42(bito)
        \        .AddAlphaPlane(C.ExtractA._Bias42(bito))
        \  : (C.IsYUV) 
        \     ? C.ColorYUV(off_y=f, off_u=f, off_v=f)
        \  : C

        return (IsFP||biti==8||biti==32||bito>=biti) 
        \   ? C 
        \   : R 
    }
}

##################################
### IsPlanar wrapper
##
function IsPlanar42(clip C)
{
    return !(C.IsInterleaved42)
}

##################################
### IsInterleaved wrapper
##
function IsInterleaved42(clip C)
{
    vertest = (!IsAvsPlus || VersionBuildNumber>=2632)

    return (vertest)  ? C.IsInterleaved
    \  : (C.IsYUY2)   ? true
    \  : (C.IsRGB24)  ? true
    \  : (C.IsRGB32)  ? true
    \  : (C.IsRGB48)  ? true
    \  : (C.IsRGB64)  ? true
    \  : false
}

#######################################################################################
### COLOR AND OVERLAY FILTERS
#######################################################################################

##################################
### scale 0-255 [[Levels]] arguments to current bit depth
##
## @ input_x, output_x - now Float to allow fractional values
## @ coring  - cf. Levels (should be false for RGB or full-range YUV)
## @ dither  - cf. Levels
## @ chroma  - if true (default), process chroma like Levels; else bypass YUV chroma
##
function Levelss(clip C, 
\            float input_low, float gamma, float input_high,
\            float output_low, float output_high, 
\            bool "coring", bool "dither", bool "chroma")
{
    coring = Default(coring, true)
    dither = Default(dither, false)
    chroma = Default(chroma, true)

    input_low   = C.sc8f(input_low) 
    input_high  = C.sc8f(input_high)
    output_low  = C.sc8f(output_low)
    output_high = C.sc8f(output_high) 

    return (C.IsRGB||C.IsY||chroma)
    \ ? C.Levels(
    \         input_low, gamma, input_high,
    \         output_low, output_high, 
    \         coring, dither)
    \ : (C.IsYUVA)
    \ ?  CombinePlanes(
    \       C.ExtractY
    \        .Levels(
    \             input_low, gamma, input_high, 
    \             output_low, output_high, 
    \             coring, dither), 
    \       C.ExtractU, C.ExtractV, C.ExtractA, "YUVA", 
    \             pixel_type=C.PixelType)
    \ :  CombinePlanes(
    \       C.ExtractY
    \        .Levels(
    \             input_low, gamma, input_high, 
    \             output_low, output_high, 
    \             coring, dither), 
    \       C.ExtractU, C.ExtractV, "YUV", 
    \             pixel_type=C.PixelType)
}

##################################
### call [[#Levelss]] independently for red, green, blue & alpha
##
## @ C       - RGB or RGBA
## @ RLevels - the five main [[#Levelss]] arguments as a string, 
##             affecting the Red channel; 
##             default is "0, 1.0, 255, 0, 255" 
##             no constraints or error checking.
## @ GLevels - the same, for Green
## @ BLevels - the same, for Blue
## @ ALevels - the same, for Alpha if present
## @ coring  - cf. Levels (should be false for full-range RGB)
## @ dither  - cf. Levels
##
function LevelssRGB(clip C,  
\            string "RLevels", string "GLevels", string "BLevels", string "ALevels",  
\            bool "coring", bool "dither")
{
    Assert(C.IsRGB, 
    \   "LevelssRGB: source must be RGB(A)")
    
    coring = Default(coring, true )
    dither = Default(dither, false)
    
    defLvls = ("0, 1, 255, 0, 255")
    
    RLevels = Default(RLevels, defLvls) 
    GLevels = Default(GLevels, defLvls) 
    BLevels = Default(BLevels, defLvls)
    ALevels = Default(ALevels, defLvls)

    C
    (!HasAlpha)
    \ ? ConvertToPlanarRGB
    \ : ConvertToPlanarRGBA
    T = Last

    scommon = (", coring=$c, dither=$d")
    \         .ReplaceStr("$c", String(coring))
    \         .ReplaceStr("$d", String(dither))

    R = (RLevels==defLvls) 
    \   ? ExtractR 
    \   : Eval("ExtractR.Levelss(" + RLevels + scommon + ")")
    G = (GLevels==defLvls) 
    \   ? ExtractG
    \   : Eval("ExtractG.Levelss(" + GLevels + scommon + ")")
    B = (BLevels==defLvls) 
    \   ? ExtractB
    \   : Eval("ExtractB.Levelss(" + BLevels + scommon + ")")
    A = (!C.HasAlpha) ? Nop
    \ : (ALevels==defLvls)
    \   ? ExtractA
    \   : Eval("ExtractA.Levelss(" + ALevels + scommon + ")")
    
    (!C.HasAlpha)
    \ ? CombinePlanes(R, G, B, "RGB", sample_clip=T)
    \ : CombinePlanes(R, G, B, A, "RGBA", sample_clip=T)

    return MatchColorFormat(C)
}

#######################################
### gamma adjustment (more = brighter lowlights)
## 
## @ tvrange   - if true, anchor curve on TV black (16d) and TV white (235d);
##               default false for RGB source, true for YUV; 
##               for Y-only sources, if 'tvrange' not specified, an error is raised.
##
function _GammaCurve(clip C, float gamma, bool "tvrange") 
{
    Assert(!C.IsY || Defined(tvrange), 
    \   "_GammaCurve: 'tvrange' must be defined for Y-only clips")
    tvrange = Default(tvrange, !C.IsRGB)
    C
    if (tvrange) {
        Levelss(16, gamma, 235, 16, 235, coring=false, chroma=false)
    }
    else {
        Levelss(0, gamma, 255, 0, 255, coring=false, chroma=false)
    }
    return Last
}

#######################################
### 'anti-gamma' adjustment (more = darker highlights)
##
## @ tvrange   - if true, anchor curve on TV black (16d) and TV white (235d);
##               default false for RGB source, true for YUV; 
##               for Y-only sources, if 'tvrange' not specified, an error is raised.
##
function _AntigammaCurve(clip C, float antigamma, bool "tvrange") 
{
    Assert(!C.IsY || Defined(tvrange), 
    \   "_AntigammaCurve: 'tvrange' must be defined for Y-only clips")
    tvrange = Default(tvrange, !C.IsRGB)
    C
    if (tvrange) {
        Invert.ColorYUV(off_y=(-5))
        Levelss(16, antigamma, 235, 16, 235, coring=false, chroma=false)
        Invert.ColorYUV(off_y=(-5))
    }
    else {
        Invert
        Levelss(2, antigamma, 253, 2, 253, coring=false, chroma=false)
        Invert
    }
    return Last
}

## fka 'GammaScurve'
## replaces 'SGradation' family
###################################
### 'S'-curve luma adjustment
##
## @ gamma     - gamma adjustment (more = brighter lowlights)
## @ antigamma - 'anti-gamma' adjustment (more = darker highlights)
## @ tvrange   - if true, anchor curve on TV black (16d) and TV white (235d);
##               default false for RGB source, true for YUV; 
##               for Y-only sources, if 'tvrange' not specified, an error is raised.
##
function GammaCurves(clip C, float gamma, float antigamma, bool "tvrange")
{
    Assert(!C.IsY || Defined(tvrange), 
    \   "Gammacurves: 'tvrange' must be defined for Y-only clips")
    tvrange = Default(tvrange, !C.IsRGB)
    C
    Lo = _GammaCurve(gamma, tvrange)
    Hi = _AntigammaCurve(antigamma, tvrange)
    return MergeLH(C, Lo, Hi) 
}

#######################################################################################
# http://forum.doom9.org/showthread.php?p=1671928#post1671928
#include "E:\Data\VideoAuxdata\test\White Balance\white-bal.avs"
# C:\Users\raff4\Dropbox\Public\Screenshots\mt_lut_calc_2.ods
## see also:
# https://github.com/ladipro/avisynth_filters/wiki/KelvinColorShift
# http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
#######################################
### emulate color temperature changes in three luma ranges
##
## @ offset_x - arbitrary units; <0 means lower temp (warmer colors)
##              (range -50_25; default 0)
##
function CheapColorTemp(clip C, 
\               int offset_lo, int offset_mid, int offset_hi)
{
    Assert(IsClip(C) && C.IsYUV, 
    \   "CheapColorTemp: source must be YUV")
    offset_lo  = Min(Max(-50, offset_lo),  25)
    offset_mid = Min(Max(-50, offset_mid), 25)
    offset_hi  = Min(Max(-50, offset_hi),  25)

    return C.ColorYUVx3(
    \          off_u_lo =offset_lo,  off_v_lo =Round(-0.7*offset_lo),
    \          off_u_mid=offset_mid, off_v_mid=Round(-0.7*offset_mid),
    \          off_u_hi =offset_hi,  off_v_hi =Round(-0.7*offset_hi))
}

# https://forum.doom9.org/showthread.php?p=1671928#post1671928
#######################################
### apply ColorYUV U & V offsets to three luma ranges
##
## @ cont_x, off_x - see [[ColorYUV]]
## @ showmasks     - if true, show original + 3 masks in quad split
##
## Example (null processing)
## | ColorYUVx3(
## | \   off_u_lo =0, off_v_lo =0,
## | \   off_u_mid=0, off_v_mid=0,
## | \   off_u_hi =0, off_v_hi =0)
##
function ColorYUVx3(clip C,
\               float "off_u_lo",  float "off_u_mid",  float "off_u_hi",
\               float "off_v_lo",  float "off_v_mid",  float "off_v_hi",
\               bool "showmasks")
{
    off_u_lo   = Float(Default(off_u_lo,   0.0))
    off_u_mid  = Float(Default(off_u_mid,  0.0))
    off_u_hi   = Float(Default(off_u_hi,   0.0))
    off_v_lo   = Float(Default(off_v_lo,   0.0))
    off_v_mid  = Float(Default(off_v_mid,  0.0))
    off_v_hi   = Float(Default(off_v_hi,   0.0))

    showmasks  = Default(showmasks, false)

    C_lo  = C.ColorYUV(
    \           off_u=off_u_lo,  off_v=off_v_lo)
    C_mid = C.ColorYUV(
    \           off_u=off_u_mid, off_v=off_v_mid)
    C_hi  = C.ColorYUV(
    \           off_u=off_u_hi,  off_v=off_v_hi)

    return MergeLMH(C, C_lo, C_mid, C_hi, showmasks=showmasks) 
}

#######################################
### merge 'Lo', 'Hi' clips based on clip 'T' luma
## can be used for simple luma keying 
##
## @ T        - control clip: 
##              - dark areas pass clip 'Lo';
##              - light areas pass clip 'Hi';
##              - for YUV(A), uses Y channel only;
##              - YUV luma assumed TV range.
##              - properties (Width, Height, color format) must match 'Lo', 'Hi'.
## @ Lo, Hi   - source clips: properties must be compatible with one another
## @ lothresh - level to pass 'Lo' clip 100%, default 16d for RGB, 32d for YUV
## @ hithresh - level to pass 'Hi' clip 100%, default 239d for RGB, 223d for YUV
## 
function MergeLH(clip T, clip Lo, clip Hi, float "lothresh", float "hithresh")
{
    Assert(Lo.Width==Hi.Width && Lo.Height==Hi.Height
    \   && Lo.Width==T.Width  && Lo.Height==T.Height,
    \   "MergeLH: 'Lo', 'Hi' and 'T' height and width must match")
    Assert(Lo.PixelType==Hi.PixelType
    \   && Lo.PixelType==T.PixelType,
    \   "MergeLH: 'Lo', 'Hi' and 'T' color format and bit depth must match")

    lothresh = Default(lothresh, (T.IsRGB ?  16 : 32))
    hithresh = Default(hithresh, (T.IsRGB ? 239 : 223))

    ##  eq. Min(Max(0, (x-lo)*255/(hi-lo)/255), 1)
    ##      
    s = ("x $tlo - 255@d * $thi $tlo - / 255@d / 1 min 0 max A^ "
    \ +  "1 A - y * A z * + ")
    \   .ReplaceStr("255@d", "range_size")
    \   .ReplaceStr("$tlo",  T.sc8s(lothresh))
    \   .ReplaceStr("$thi",  T.sc8s(hithresh))

    return (Lo.HasAlpha)
    \ ? Expr(T, Lo, Hi, s, s, s, s, format=Lo.PixelType)
    \ : Expr(T, Lo, Hi, s, s, s,    format=Lo.PixelType)
}

## old version here: http://forum.doom9.org/showthread.php?p=1691736#post1691736
#######################################
### merge 'Lo', 'Mid', 'Hi' clips based on clip 'T' luma
##
## @ T        - control clip: 
##              - dark areas pass clip 'Lo';
##              - light areas pass clip 'Hi';
##              - properties (Width, Height, color format) must match Lo/Mid/Hi;
##              - for YUV(A), uses Y channel only;
##              - YUV luma always expanded TV->PC.
## @ Lo, Mid, Hi - source clips: size and color format must match clip 'T'.
##
## @ showmasks - if true, show original + 3 masks in quad split
##
## -- A D V A N C E D   A R G U M E N T S -----------------------------------
## @ bias      - if < 0, favor 'Lo' clip; if > 0, favor 'Hi' clip; default 0.0
## @ ctr_lo    - peak response luminance for low mask 'bandpass';
##               range = -127d_127d; default 0d
## @ ctr_hi    - peak response luminance for high mask;
##               range = 127d_383d; default 255d
## @ qfactor   - sharpness of the 'bandpass filter'; 
##               higher values result in steeper slope, narrower 'passband'
##               range = 0.0(sharp)_40.0(broad); default 0.7;
##               "useable" range = 0.4_1.4
##             
## Example - desaturate at luma extremes
## | MergeLMH(Last, Grayscale, Last, Grayscale)
## | ## ...... ^T .... ^Lo ... ^Mid ... ^Hi ...
##
## @ v2017-05-19 AVS+, MaskTools 2.2.x deep color
## @ v2018-04-14 AVS+ Expr
##
function MergeLMH(clip T, clip Lo, clip Mid, clip Hi, float "bias",
\               float "ctr_lo", float "ctr_hi", float "qfactor",
\               bool "showmasks")
{
    Assert(Lo.Width==Mid.Width && Lo.Height==Mid.Height
    \   && Lo.Width==Hi.Width && Lo.Height==Hi.Height
    \   && Lo.Width==T.Width && Lo.Height==T.Height,
    \   "MergeLMH: 'Lo', 'Mid', 'Hi' and 'T' height and width must match")
    Assert(Lo.PixelType==Mid.PixelType 
    \   && Lo.PixelType==Hi.PixelType
    \   && Lo.PixelType==T.PixelType,
    \   "MergeLMH: 'Lo', 'Mid', 'Hi' and 'T' color format and bit depth must match")

    bias = Default(bias, 0.0)
    show = Default(showmasks, false)

    T = (Abs(bias)<0.01) ? T
    \ : (   bias < 0.00) ? T._GammaCurve(1.0/(-bias+1.0), tvrange=false)
    \                    : T._GammaCurve(   bias+1.0    , tvrange=false)

    bits = T.BitsPerComponent
    cLo  = Min(Max( -127, Default(ctr_lo,   0.0)), 127)
    cHi  = Min(Max(  127, Default(ctr_hi, 255.0)), 383)
    q    = Min(Max(0.001, Default(qfactor, 0.7)),  40.0)
    ramp = Min(Max(0, 59.82 * Pow(q, -0.76)),  512)
    wid  = 60

    ## Lo * Min(Max(0, (1+((wid/510)*(255/ramp)))-(((x-cLo)/255)*(255/ramp))), 1)
    sLo = ("$wid $rng2 / $rng $ramp / * 1 + "
    \   + "x $cLo - $rng / $rng $ramp / * - "
    \   + "0 max 1 min ")
    \   .ReplaceStr("$rng2 ", "range_size 2 * ")
    \   .ReplaceStr("$rng ", "range_size ")
    \   .ReplaceStr("$wid",   T.sc8s(wid))
    \   .ReplaceStr("$ramp",  T.sc8s(ramp))
    \   .ReplaceStr("$cLo",   T.sc8s(cLo)) 

    ## Hi * Min(Max(0, (1+((wid/510)*(255/ramp)))-(((cHi-x)/255)*(255/ramp))), 1)
    sHi = ("$wid $rng2 / $rng $ramp / * 1 + "
    \   + "$cHi x - $rng / $rng $ramp / * - "
    \   + "0 max 1 min")
    \   .ReplaceStr("$rng2 ", "range_size 2 * ")
    \   .ReplaceStr("$rng ", "range_size ")
    \   .ReplaceStr("$wid",   T.sc8s(wid))
    \   .ReplaceStr("$ramp",  T.sc8s(ramp))
    \   .ReplaceStr("$cHi",   T.sc8s(cHi)) 

    ## x=T; y=Lo; x=Hi; a=Mid
    sMerge = ("y " + sLo + " L@ * "
    \      +  "z " + sHi + " H@ * + "
    \      +  "a 1 L H + - * + ")

    Tx =  T
    if (!T.IsRGB) {
        
        sPix = BitsToPixelType("YUV", bits, 444)

        sToPC = ("x 16@d - 255@d 219@d / * 0.48@d - ")
        \    .ReplaceStr("@d", " scaleb")
        
        Tx = CombinePlanes(T, T, T, "YUV", "YYY", 
        \       pixel_type=sPix)
        \    .Expr(sToPC, "x", "x")
        \    .MatchColorFormat(T)
    }

    R = (T.IsRGB)
    \ ? Expr(Tx, Lo, Hi, Mid, sMerge)
    \ : Expr(Tx, Lo, Hi, Mid, sMerge)

    return (!show) ? R
    \  : StackVertical(
    \       StackHorizontal(T.AddBorders(0,0,8,0), mask_lo).AddBorders(0,0,0,8),
    \       StackHorizontal(mask_mid.AddBorders(0,0,8,0), mask_hi)
    \    ).BilinearResize(T.Width, T.height)
    \     .Subtitle("Low",    align=9)
    \     .Subtitle("\nMid",  align=4, lsp=0)
    \     .Subtitle("\nHigh", align=6, lsp=0)
}

##################################
### [[Layer]] with support for 'mask', 'opacity' and 'align' parameters 
##
## @ op, level, threshold, use_chroma - cf. Layer
## @ base, over  - RGB32 or RGB64 only
## @ x, y        - unlike Layer, act as offset to calculated 'align' values
## @ mask        - if supplied, set alpha channel of clip 'over'
## @ opacity     - if supplied, override 'level' (range 0.0_1.0)
## @ align       - @see [[Subtitle]] ("number pad notation")
##
function LayerAligned(clip base, clip over, string "op", int "level", 
\               int "x", int "y", int "threshold", bool "use_chroma", 
\               clip "mask", float "opacity", int "align")
{
    Assert(base.IsRGB32 || base.IsRGB64,
    \   "LayerAligned: 'base' clip must be RGB32 or RGB64")
    Assert(over.IsRGB32 || over.IsRGB64,
    \   "LayerAligned: 'over' clip must be RGB32 or RGB64")
    
    lvl = Default(level, 257)
    opc = Default(opacity, Float(lvl)/257.0)
    lvl = Round(257.0 * opc)
    x   = Default(x, 0)
    y   = Default(y, 0)
    aln = Default(align, 7)

    try {
        over = IsClip(mask) 
        \    ? over.ResetMask.Mask(mask) 
        \    : over
    }
    catch(err_msg) {
        Assert(false,
        \   "LayerAligned: 'mask' clip could not be used: " + err_msg)
    }

    ## right, center, left
    x = (aln==3||aln==6||aln==9) ? x + base.Width     - over.Width
    \ : (aln==2||aln==5||aln==8) ? x + (base.Width/2) - (over.Width/2)
    \ : x

    ## bottom, middle, top
    y = (aln==1||aln==2||aln==3) ? y + base.Height     - over.Height
    \ : (aln==4||aln==5||aln==6) ? y + (base.Height/2) - (over.Height/2)
    \ : y

    return (lvl<1) ? base
    \ : Layer(base, over, op, lvl, x, y, threshold, use_chroma)
}

##################################
### [[Overlay]] with support for 'align' parameter 
### supports adding borders to, or letterboxing, inset clip
##
## @ mask, opacity, mode, greymask, output, 
##   ignore_conditional, pc_range - cf. Overlay
## @ x, y        - unlike Overlay, act as offset to calculated 'align' values
## @ align       - @see [[Subtitle]] ("number pad notation")
## @ borderwidth - @see [[AddBorders]]/[[Letterbox]] (Letterbox if less than zero)
## @ bordercolor - @see AddBorders
## (NOTE border does not work when using 'mask')
## @ show        - show x and y arguments; default 0; 
##                 if 1 through 9, sets position in "number pad notation" (cf. [[Subtitle]])
##
function OverlayAligned(clip base, clip over, 
\               int "x", int "y", clip "mask", float "opacity", string "mode",
\               bool "greymask", string "output", bool "ignore_conditional",
\               bool "pc_range", int "align", int "borderwidth", int "bordercolor",
\               int "show")
{
    Assert(!base.IsYV411 && (base.IsRGB||base.IsYUV||base.IsYUVA), 
    \  "OverlayAligned 'base' - YV411 not accepted") ## (cf. Overlay)
    Assert(!over.IsYV411 && (over.IsRGB||over.IsYUV||over.IsYUVA), 
    \  "OverlayAligned 'over' - YV411 not accepted") ## (cf. Overlay)
    x   = Default(x, 0)
    y   = Default(y, 0)
    opc = Default(opacity, 1.0)
    aln = Default(align, 7)
    bdr = Default(borderwidth, 0)
    clr = Default(bordercolor, 0)
    shw = Default(show, 0)

    ## if border > 0, call AddBorders
    over = (bdr <= 0) ? over [*     L    T    R   B   *]
    \ : (aln==1) ? over.AddBorders(  0, bdr, bdr,   0, clr)
    \ : (aln==2) ? over.AddBorders(bdr, bdr, bdr,   0, clr)
    \ : (aln==3) ? over.AddBorders(bdr, bdr,   0,   0, clr)
    \ : (aln==4) ? over.AddBorders(  0, bdr, bdr, bdr, clr)
    \ : (aln==5) ? over.AddBorders(bdr, bdr, bdr, bdr, clr)
    \ : (aln==6) ? over.AddBorders(bdr, bdr,   0, bdr, clr)
    \ : (aln==8) ? over.AddBorders(bdr,   0, bdr, bdr, clr)
    \ : (aln==9) ? over.AddBorders(bdr,   0,   0, bdr, clr)
    \ :            over.AddBorders(  0,   0, bdr, bdr, clr) ## (aln==7)

    ## if border < 0, call Letterbox
    bdr = -bdr
    over = (bdr <= 0) ? over [*    T    B    L   R   *]
    \ : (aln==1) ? over.Letterbox(bdr,   0,   0, bdr, clr)
    \ : (aln==2) ? over.Letterbox(bdr,   0, bdr, bdr, clr)
    \ : (aln==3) ? over.Letterbox(bdr,   0, bdr,   0, clr)
    \ : (aln==4) ? over.Letterbox(bdr, bdr,   0, bdr, clr)
    \ : (aln==5) ? over.Letterbox(bdr, bdr, bdr, bdr, clr)
    \ : (aln==6) ? over.Letterbox(bdr, bdr, bdr,   0, clr)
    \ : (aln==8) ? over.Letterbox(  0, bdr, bdr, bdr, clr)
    \ : (aln==9) ? over.Letterbox(  0, bdr, bdr,   0, clr)
    \ :            over.Letterbox(  0, bdr,   0, bdr, clr) ## (aln==7)

    ## right, center, left
    x = (aln==3||aln==6||aln==9) ? x + base.Width     - over.Width
    \ : (aln==2||aln==5||aln==8) ? x + (base.Width/2) - (over.Width/2)
    \ : x

    ## bottom, middle, top
    y = (aln==1||aln==2||aln==3) ? y + base.Height     - over.Height
    \ : (aln==4||aln==5||aln==6) ? y + (base.Height/2) - (over.Height/2)
    \ : y

    over = (shw>=1 && shw<=9)
    \ ? over.Subtitle42("overlay(x="+String(x)+",y="+String(y)+")", 
    \         size=56*Sqrt(over.Height/720.0), lsp=0, align=shw, 
    \         text_color=color_silver)
    \ : over

    return (opc<0.001) ? base
    \ : Overlay(base, over, x, y, mask, opc, mode, 
    \           greymask, output, ignore_conditional, pc_range)
}

##################################
### [[Subtitle]] wrapper
##
function Subtitle42(clip C, string text, float "x", float "y", 
\                   int "first_frame", int "last_frame",
\                   string "font", float "size", int "text_color", int "halo_color", 
\                   int "align", int "spc", int "lsp",
\                   float "font_width", float "font_angle", bool "interlaced")
{
    vertest = (!IsAvsPlus || VersionBuildNumber>=2632)
    C

    ## if RGB(A) planar, swap RGB -> GRB
    (vertest) ? Last
    \ : (IsPlanarRGB)
    \    ? CombinePlanes("RGB", source_planes="GRB")
    \ : (IsPlanarRGBA)
    \    ? CombinePlanes("RGBA", source_planes="GRBA")
    \    : Last

    Subtitle(text, x, y, first_frame, last_frame,
    \       font, size, text_color, halo_color, align, 
    \       spc, lsp, font_width, font_angle, interlaced)

    ## if RGB(A) planar, swap GRB -> RGB
    (vertest) ? Last
    \ : (IsPlanarRGB)
    \    ? CombinePlanes("RGB", source_planes="GRB")
    \ : (IsPlanarRGBA)
    \    ? CombinePlanes("RGBA", source_planes="GRBA")
    \    : Last
    return Last
}

#######################################
### [[Limiter]] with knee zone; implemented using [[Expr]]
##
## @ C       - source clip; YUV(A) only, 8-16bit. (A is unchanged)
## @ max_lum - percent of 16d-235d luma range allowed
##             maximum 1.2 (120%), minimum 0.4 (40%); no default;
##             overrides min_y, max_y below.
## @ max_sat - percent of 16d-240d chroma range allowed;
##             maximum 1.2 (120%), minimum 0.4 (40%); no default;
##             overrides min_u, max_u, min_v, max_v below.
## @ taper   - amount of chroma "taper" (added chroma limiting at luma extremes)
##             higher values => less saturation at extreme darks & lights;
##             range 0 (off) to 4; default 2
##
## -- A D V A N C E D   A R G U M E N T S -----------------------------------
## @ min_y   - Y channel lower bound; default  16d ("white")
## @ max_y   - Y channel upper bound; default 235d ("black")
## @ min_u   - U channel lower bound; default  16d ("yellow")
## @ max_u   - U channel upper bound; default 240d ("blue")
## @ min_v   - V channel lower bound; default  16d ("green/cyan")
## @ max_v   - V channel upper bound; default 240d ("red/magenta")
## @ knee_y  - depth of  luma  soft-clipping zone. range 10-60; default 20.
## @ knee_c  - depth of chroma soft-clipping zone. range 10-60; default 20.
##
## @ Examples:
## | SoftLimiter2(taper=0) ## limit to TV range, no 'taper'
## | SoftLimiter2(max_lum=1.2, max_sat=1.2, taper=0) ## almost no limiting
## | SoftLimiter2(max_sat=0.7)  ## limit to "natural" looking colors
## | SoftLimiter2(max_lum=1.05) ## "under-limit" luma slightly
##
## @ version 1.0 2018-03-18 
##
function SoftLimiter2(clip C, 
\               float "max_lum", float "max_sat", int "taper",
\               int "min_y", int "max_y",  
\               int "min_u", int "max_u", 
\               int "min_v", int "max_v", 
\               int "knee_y", int "knee_c")
{
    Assert(C.IsYUV||C.IsYUVA,
    \   "SoftLimiter2: source must be YUV(A)")
    C
    bits  = BitsPerComponent

    lum   = Min(Max(0.4, Default(max_lum, 1.0)), 1.2)
    lum   = Round(lum*110) ## (235-16)/2; 126 ± 110
    sat   = Min(Max(0.4, Default(max_sat, 1.0)), 1.2)
    sat   = Round(sat*112) ## (240-16)/2; 128 ± 112
    kny   = Min(Max(10, Default(knee_y, 20)), 60)
    knc   = Min(Max(10, Default(knee_c, 20)), 60)

    p1y   = Min(Max(0, Default(min_y, 16)), 64)
    p1y   = !Defined(max_lum) ? p1y : Min(Max(-kny, 126-lum), 126-40)
    p2y   = p1y + kny
    p5y   = Min(Max(255-64, Default(max_y, 235)), 255)
    p5y   = !Defined(max_lum) ? p5y : Min(Max(126+40, 126+lum), 255+kny)
    p4y   = p5y - kny

    p1u   = Min(Max(0, Default(min_u, 16)), 64)
    p1u   = !Defined(max_sat) ? p1u : Min(Max(-knc, 128-sat), 128-40)
    p2u   = p1u + knc
    p5u   = Min(Max(255-64, Default(max_u, 240)), 255)
    p5u   = !Defined(max_sat) ? p5u : Min(Max(128+40, 128+sat), 255+knc)
    p4u   = p5u - knc

    p1v   = Min(Max(0, Default(min_v, 16)), 64)
    p1v   = !Defined(max_sat) ? p1v : Min(Max(-knc, 128-sat), 128-40)
    p2v   = p1v + knc
    p5v   = Min(Max(255-64, Default(max_v, 240)), 255)
    p5v   = !Defined(max_sat) ? p5v : Min(Max(128+40, 128+sat), 255+knc)
    p4v   = p5v - knc

    taper = Min(Max(0, Default(taper, 2)), 4)
    widu  = Select(taper, 0, 200, 180, 140, 140)
    widv  = Select(taper, 0, 200, 160, 120,  80)
    rampu = Select(taper, 0, 110, 105,  95,  95)
    rampv = Select(taper, 0, 110,  95,  75,  65)
    ##  ................. 0 .. 1 .. 2 .. 3 .. 4

    ## Eq. (x < $p2) ? ((x / $p2 * ($p2-$p1)) + $p1)
    ##   : (x > $p4) ? (((x-$p4) / (255-$p4) * ($p5-$p4)) + $p4)
    ##   : x
    s0  = "x $p2 < " + "x $p2 / $p2 $p1 - * $p1 + "
    \   + "x $p4 > " + "x $p4 - range_size $p4 - / $p5 $p4 - * $p4 + "
    \   + "x ? ? "
    
    sy = s0.ReplaceStr("$p1",    sc8s(p1y))
    \      .ReplaceStr("$p2",    sc8s(p2y))
    \      .ReplaceStr("$p4",    sc8s(p4y))
    \      .ReplaceStr("$p5",    sc8s(p5y))

    ## taper:
    ## Eq. = ( 1 + $width / 512 * 256 / $ramp ) - ( abs(x-$center) / 256 * 256 / $ramp ) 
    ## [above result limited to 0,1] [u,v normalized to ±128d]
    st = "X^ "
    \  + "$width range_size 2 * / range_size $ramp / * "
    \  + "1 + y range_half - abs range_size / range_size $ramp / * - "
    \  + "0 max 1 min X range_half - * range_half + "
    su = (taper==0) ? s0 : s0 + st
    sv = (taper==0) ? s0 : s0 + st
    
    su = su.ReplaceStr("$p1",    sc8s(p1u))
    \      .ReplaceStr("$p2",    sc8s(p2u))
    \      .ReplaceStr("$p4",    sc8s(p4u))
    \      .ReplaceStr("$p5",    sc8s(p5u))
    \      .ReplaceStr("$width", sc8s(widu))
    \      .ReplaceStr("$ramp",  sc8s(rampu))

    sv = sv.ReplaceStr("$p1",    sc8s(p1v))
    \      .ReplaceStr("$p2",    sc8s(p2v))
    \      .ReplaceStr("$p4",    sc8s(p4v))
    \      .ReplaceStr("$p5",    sc8s(p5v))
    \      .ReplaceStr("$width", sc8s(widv))
    \      .ReplaceStr("$ramp",  sc8s(rampv))

    O  = Last
    Y  = ExtractY
    U  = ExtractU
    V  = ExtractV

    Y  = Y.Expr(sy)
    Ys = Y.BilinearResize(U.Width, U.Height)
    U  = Expr(U, Ys, su)
    V  = Expr(V, Ys, sv)

    (C.HasAlpha)
    \ ? CombinePlanes(Y, U, V, C, "YUVA", source_planes="YYYA", pixel_type=C.PixelType)
    \ : CombinePlanes(Y, U, V,    "YUV",  source_planes="YYY",  pixel_type=C.PixelType)
    return Last
}

#######################################################################################
### TIMELINE FILTERS
#######################################################################################

#######################################
### "slip" (advance or delay) a clip in time.
##  Adds head or tail padding; clip is normally Trimmed later.
##
## @ C - clip to be advanced or delayed 
## @ offset - if positive, clip is advanced;
##            if negative, clip is delayed
##
function Slip(clip C, int offset)
{
    lenTrim = (offset > 0) ?  offset : 0
    lenPad  = (offset < 0) ? -offset : 0

    C = (lenPad==0) ? C 
    \ : C.Trim(0, -1).Loop(lenPad) + C.Trim(0, C.Framecount-lenPad)

    C = (lenTrim==0) ? C
    \ : C.Trim(lenTrim, 0) + C.Trim(C.Framecount-lenTrim, -1).Loop(lenTrim)
    return C
} 

#######################################
### cut or dissolve to synchronized alternate clip
##
## @ A     - main movie
## @ B     - alternate clip (synchronized with clip 'A')
## @ mark  - frame where 'A'->'B' fade begins
##           (default 0; start of clip 'A')
## @ fade  - number of frames for 'A'->'B' fade
##           (default 0; cut to clip 'B' at frame 'mark')
##
function CutToSync(clip A, clip B, int "mark", int "fade")
{
    mark  = Max(0, Default(mark,  0))
    fade  = Max(0, Default(fade,  0))

    Assert(A.FrameCount>=mark+fade+1,
    \   "CutToSync: clip A too short"+Chr(10)
    \ + "(FrameCount < mark+fade+1)")
    Assert(B.FrameCount>=mark+fade+1,
    \   "CutToSync: clip B too short"+Chr(10)
    \ + "(FrameCount < mark+fade+1)")

    R = ((mark+fade)==0) ? B
    \ : Dissolve(A.Trim(0, ((mark+fade)==1) ? -1 : mark+fade-1),
    \            B.Trim(mark, 0), 
    \            fade)
    return R
}

#######################################
### like [[Dissolve]], but support [[Overlay]] modes
##
## @ ddur - duration of the transition (minimum allowed value 3 frames)
## @ mode - overlay effect at transition center (see [[Overlay]]: mode)
## @ opacity - overlay opacity at transition center (see Overlay: opacity) (default 0.5)
##
## @ version 1.0 raffriff42 10-Oct-2015
##
function DissolveMode(clip A, clip B, int ddur, string "mode", float "opacity")
{
    Assert(A.IsClip && A.HasVideo
    \   && B.IsClip && B.HasVideo,
    \   "DissolveMode: both clips must contain video")
    Assert(A.PixelType==B.PixelType,
    \   "DissolveMode: clip color formats do not match")
    Assert(A.FramerateNumerator==B.FramerateNumerator
    \   && A.FramerateDenominator==B.FramerateDenominator, 
    \   "DissolveMode: clip frame rates do not match")
    Assert(A.Width==B.Width
    \   && A.Height==B.Height,
    \   "DissolveMode: clip frame sizes do not match")
    Assert(A.IsInterleaved==B.IsInterleaved
    \   && (A.IsInterleaved==false || A.GetParity==B.GetParity),
    \   "DissolveMode: clip interlacing properties do not match")
    Assert(A.AudioRate==B.AudioRate 
    \   && A.AudioBits==B.AudioBits   
    \   && A.IsAudioInt==B.IsAudioInt,
    \   "DissolveMode: clip audio formats do not match")
    Assert(A.AudioChannels==B.AudioChannels,
    \   "DissolveMode: clip audio channel counts do not match")
    Assert(!A.IsYV411 && !B.IsYV411, 
    \  "DissolveMode: YV411 not accepted") ## (cf. Overlay)

    ddur  = Min(Max(3, ddur), A.Framecount-1)
    mode  = Default(mode, "blend")
    opac  = Default(opacity, 0.5)
    #cdur  = Min(Max(0, Default(cdur, 0)), ddur-2)
    
    cdur  = 0 #Min(cdur, ddur-2)
    ddur  = ddur-cdur
    dur_a = ddur/2
    dur_b = Max(0, ddur-dur_a)

    dbg = "ddur  " + String(ddur)  + "\n"
    \   + "cdur  " + String(cdur)  + "\n"
    \   + "dur_a " + String(dur_a) + "\n"
    \   + "dur_b " + String(dur_b) + "\n"
    
    #A = A.bigsub("A")
    #B = B.bigsub("B")

    C = Overlay(A.Trim(A.Framecount-ddur+1, 0), B, opacity=opac, mode=mode) 
        ## (C.FrameCount == ddur-1)

    R = A.Trim(0, A.Framecount-ddur) 
    \ ++ Dissolve(
    \       A.Trim(A.Framecount-ddur+1, -dur_a), 
    \       C,
    \       dur_a).Trim(0, -dur_a)
    \ ++ Dissolve(
    \       C.Trim(dur_a+1, 0), 
    \       B.Trim(dur_a+1, 0), 
    \       dur_b)

    R = R.AudioDub(Dissolve(A, B, ddur).KillVideo)

    return R #.Subtitle(dbg, align=4, lsp=0)
}

#######################################
### change speed over a wide range (basic FF and slo-mo; no motion compensation)
##
## @ factor - 0.33 for 1/3 speed, etc; 
##    min = 0.001; max = min([[FrameCount]], 1000) 
##    (if > FrameCount, duration would be 0);
##    if argument is out of range, an error occurs.
##
## @ pitchfix - if true, maintain audio pitch with speed 
##    (default false; allow pitch to rise or fall)
##
## @ noblend - if true, never blend frames (default false)
##
## @ fpsnum, fpsden - output frame rate; default same as 'C'
##
## @ v2014-02-24 raffriff42
## @ v2018-04-14 fpsnum, fpsden
##
function ChangeSpeed(clip C, float factor, 
\               bool "pitchfix", bool "noblend", int "fpsnum", int "fpsden")
{
    pitchfix = Default(pitchfix, false)
    noblend  = Default(noblend, false)
    fpsnum   = Max(1, Default(fpsnum, C.FrameRateNumerator))
    fpsden   = Max(1, Default(fpsden, C.FrameRateDenominator))

    Assert(!C.IsYV411 && (C.IsYUV||C.IsYUVA), 
    \  "ChangeSpeed: RGB, YV411 not accepted") ## (cf. Overlay)
    Assert(factor>=0.001, 
    \  "ChangeSpeed bad argument: factor<0.001")
    Assert(factor<=1000.0, 
    \  "ChangeSpeed bad argument: factor>1000")
    Assert(factor<=C.FrameCount, 
    \  "ChangeSpeed bad argument: factor>FrameCount")

    AS  = C.KillAudio.AssumeFPS(C.FrameRate * factor)

    temprad = Round(0.5 * factor) 
    TS = (factor<1.0 || temprad==0 || noblend) 
    \  ? AS 
    \  : AS.Overlay(
    \       AS.TemporalSoften(temprad, 255, 255, 48, 2), 
    \       opacity=0.7)

    R  = (factor<1.5 && noblend==false)  
    \  ? AS.ConvertFPS(fpsnum, fpsden) 
    \  : TS.ChangeFPS(fpsnum, fpsden, linear=(factor<10.0))

    return (Abs(factor-1.0) < (0.5/C.FrameCount)) ? C
    \  : (!C.HasAudio) ? R 
    \  : R.AudioDub( C.ChangeAudioSpeed(factor, pitchfix) )
}

#######################################
### audio only: change speed over a wide range 
##
## @ factor - 0.33 for 1/3 speed, etc; 
##    min = 0.01; max < 1000;
##    if argument is out of range, an error occurs.
##
## @ pitchfix - if true, maintain audio pitch with speed 
##    (default false; allow pitch to rise or fall)
##
## @ v2017-04-11 split from [[ChangeSpeed]]
## @ v2018-04-14 tweak 'sequence' for slo-mo when correcting pitch
##
function ChangeAudioSpeed(
\               clip C, float factor, bool "pitchfix")
{
    Assert(C.HasAudio, 
    \  "ChangeAudioSpeed bad argument: source has no audio")
    Assert(factor>=0.01, 
    \  "ChangeAudioSpeed bad argument: factor < 0.01")
    Assert(factor<=1000.0, 
    \  "ChangeAudioSpeed bad argument: factor > 1000")

    pitchfix = Default(pitchfix, false)

    A = (factor > 0.7)
    \ ? (pitchfix)
    \    ? C.ConvertAudioToFloat.TimeStretch(tempo = factor*100.0)
    \    : C.ConvertAudioToFloat.TimeStretch(rate  = factor*100.0)
    \ : (pitchfix)
    \    ? C.ConvertAudioToFloat.TimeStretch(tempo = factor*100.0, sequence=50)
    \    : C.ConvertAudioToFloat.TimeStretch(rate  = factor*100.0)

    R = (Abs(factor-1.0) < 0.0001) ? C
    \ : (C.AudioDuration/factor < 0.001) ? C.AudioTrim(0.0, length=0.0)
    \ : (C.AudioBits==32) ? A.ConvertAudioTo32bit
    \ : (C.AudioBits==24) ? A.ConvertAudioTo24bit
    \ : (C.AudioBits==16) ? A.ConvertAudioTo16bit
    \ : (C.AudioBits==8)  ? A.ConvertAudioTo8bit
    \ : A ## (==float)

    return (factor > 0.99) ? R 
    \ : R.AudioTrim(0.0, length=C.AudioDuration)
}

#######################################################################################
### SHARPEN & BLUR FILTERS
#######################################################################################

##################################################
### quick Gaussian blur
##
function QGaussBlur(clip C, float radx, float "rady")
{
    radx = Max(1.0, radx)            
    rady = Max(1.0, Default(rady, radx))

    return (radx<0.1 && rady<0.1) ? C
    \ : C.BilinearResize(
    \        Max(16, modx(4, Float(C.Width)/(radx+1.0))), 
    \        Max(16, modx(4, FLoat(C.Height)/(rady+1.0))))
    \    .Blur(0.3)
    \    .GaussResize(
    \        C.Width, C.Height, p=19)
    ## p=19: softest w/o visible 'blockiness' 
}

#######################################################################################
### CROP, RESIZE AND TRANSFORM FILTERS
#######################################################################################

##################################################
### alias for [[#Cropd]] with argument order: Left, Top, Right, Bottom
##
## @ left, top, right, bottom, align - cf. [[Crop]]
## @ mod  - adjusts crop to modulo 'mod'; default 2
## @ absolute - if true, 'right' & 'bottom' are absolute coords. Default false.
##     | 
##     | ## default behavior:
##     | CropLTRB(10, 20, 30, 40)
##     | ## removes 10 px from left, 20 from top, 
##     | ## 30 px from right, and 40 px from bottom.
##     |
##     | ## 'absolute' mode:
##     | CropLTRB(10, 20, 30, 40, absolute=true)
##     | ## specifies top-left and bottom-right corners of the
##     | ## source clip to be returned.
##     | 
## @ minwidth, minheight - resulting clip will be at least this size;
##     default 0 (invalid crop values may raise errors)
## @ show - show final Crop aruments;
##     default 0; if 1 through 9, sets position in "number pad notation" (cf. [[Subtitle]])
##
## @ version 1.1 - float arguments
## @ version 1.2 - absolute option
##
function CropLTRB(clip C, float left, float top, float right, float bottom, 
\                 bool "align", int "mod", bool "absolute",
\                 int "minwidth", int "minheight", int "show")
{
    md = Max(1, Default(mod, 2))
    ab = Default(absolute, false)
    mx = Default(minwidth,  0)
    my = Default(minheight, 0)
    sh = Default(show, 0)

    L  = modx(md, left)
    T  = modx(md, top)
    R  = modx(md, right)
    B  = modx(md, bottom)

    L  = Min(Max(0, L), C.Width-mx)
    T  = Min(Max(0, T), C.Height-my)
    R  = (ab) 
    \  ? (C.Width-Max((mx+L), R))
    \  : Min(Max(0, R), C.Width-(mx+L))
    B  = (ab)
    \  ? (C.Height-Max((my+T),B))
    \  : Min(Max(0, B), C.Height-(my+T))

    C.Cropd(L, T, -R, -B, align, md)
    return (sh<1 || sh>9) ? Last
    \ : Subtitle42("crop("+String(L)+","+String(T)
    \         +","+String(R)+","+String(B)+")", 
    \         size=56*Sqrt(Height/720.0), lsp=0, align=sh, 
    \         text_color=color_cyan)
}

##################################################
### alias for [[#Cropd]] with argument order: Left, Top, Width, Height
##
## @ left, top, width, height, align - cf. [[Crop]]
##    (0 width or height means keep source dimension)
## @ mod - adjusts crop to modulo 'mod'; default 2
## @ minwidth, minheight - resulting clip will be at least this size;
##         default 0 (invalid crop values may raise errors)
## @ show - show final Crop aruments;
##         default 0; if 1 through 9, sets position in "number pad notation" (cf. [[Subtitle]])
##
## @ version 1.1 - float arguments
##
function CropLTWH(clip C, float left, float top, float width, float height, 
\                 bool "align", int "mod", 
\                 int "minwidth", int "minheight", int "show")
{
    md = Max(1, Default(mod, 2))
    mx = Default(minwidth,  0)
    my = Default(minheight, 0)
    sh = Default(show, 0)

    L  = modx(md, left)
    T  = modx(md, top)
    W  = modx(md, width)
    H  = modx(md, height)

    L  = Min(Max(0, L), C.Width-mx)
    T  = Min(Max(0, T),  C.Height-my)
    W  = (W==0) ? (C.Width-L)  : Min(Max(mx, W), C.Width-L)
    H  = (H==0) ? (C.Height-T) : Min(Max(my, H), C.Height-T)

    C.Cropd(L, T, W, H, align, md)
    return (sh<1 || sh>9) ? Last
    \ : Subtitle42("crop("+String(L)+","+String(T)
    \         +","+String(L+W)+","+String(T+H)+")", 
    \         size=56*Sqrt(Height/720.0), lsp=0, align=sh, 
    \         text_color=color_cyan)
}

##################################################
### show a helpful diagnostic string on [[Crop]] failure; optionally enforce [[Mod]]
##
## @ x, y, wid, hgt, align - cf. [[Crop]]
## @ mod - adjusts crop to modulo 'mod'; default 1
##
## @ version 1.1 - float arguments
##
function Cropd(clip C, float x, float y, float wid, float hgt, bool "align", int "mod")
{
    align  = Default(align, false)
    mdd    = Default(mod, 1)

    Assert(Defined(C) && IsClip(C) && C.HasVideo, 
    \  "Cropd: " + C.InfoString)
    Assert((mdd==1||mdd==2||mdd==4||mdd==8||mdd==16||mdd==32), 
    \  "Cropd: 'mod' argument not one of (1|2|4|8|16|32)")

    x   = modx(mdd, x)
    y   = modx(mdd, y)
    wid = modx(mdd, wid)
    hgt = modx(mdd, hgt)

    try {
        return C.Crop(x, y, wid, hgt, align)
    }
    catch(err_msg) {
        n = Chr(10)
        m = "; "
        args = "(" + "x:"   + String(x)
        \      + m + "y:"   + String(y)
        \      + m + "wid:" + String(wid)
        \      + m + "hgt:" + String(hgt) + ")"            
        \ + m + "(x+wid):"  + String(x+wid)
        \ + m + "(y+hgt):"  + String(y+hgt)
        Assert(false, err_msg + n + "Cropd " + args + n + C.InfoString)
    }
} 

##################################
### (ScaleZoom sizes by percent; ScaleSize by width and/or height)
##  (minimum output dimension 8x8)
##
## @ factor - 0.5 for 50% size, 1.2 for 120%, etc
##            (minimum output dimension 8x8)
##            For example, given a 1920x1080 source,
##            | ScaleZoom(0.33, 16)
##            returns a 640x352 clip.
## @ mod    - new size modulo; default 4; must be one of (1|2|4|8|16|32) 
##
function ScaleZoom(clip C, float factor, int "mod")
{
    return C.ScaleSize(
    \           (factor*C.Width), (factor*C.Height), mod) 
}

##################################
### switch (or fade) between three [[Resize]] clips depending on scale factor
### (overridable with user-specified resizers e.g. nnedi3 etc)
### (ScaleZoom3 sizes by percent; ScaleSize3 by width and/or height)
##  (minimum output dimension 8x8)
##
## @ factor - 0.5 for 50% size, 1.2 for 120%, etc
##            (minimum output dimension 8x8)
##            For example, given a 1920x1080 source,
##            | ScaleZoom3(0.33, 16)
##            returns a 640x352 clip.
## @ mod    - new size modulo; default 4; must be one of (1|2|4|8|16|32) 
##
## -- A D V A N C E D   A R G U M E N T S -----
## @see [[#ScaleSize3]] below
##
function ScaleZoom3(clip C, float factor, int "mod", 
\               string "sm", string "med", string "lg",
\               float "thrSm", float "thrLg", bool "fade", bool "ident", 
\               bool "gamma", bool "hibit", int "show", bool "debug")
{
    return C.ScaleSize3(
    \           (factor*C.Width), (factor*C.Height), mod, 
    \           sm, med, lg, thrSm, thrLg, fade, ident, gamma, hibit, debug) 
}

##################################
### (ScaleZoom sizes by percent; ScaleSize by width and/or height)
##  (minimum output dimension 8x8)
##
## @ fwid  - new width
## @ fhgt  - new height
##             (minimum output dimension 8x8)
##             (if 'fwid' <= 0, it is calculated from 'fhgt' and aspect ratio)
##             (if 'fhgt' <= 0, it is calculated from 'fwid' and aspect ratio)
##             (if both <= 0, an error is raised)
##             For example, given a 1920x1080 source,
##             | ScaleSize(-1, 480, 16)
##             returns an 848x480 clip.
## @ mod    - new size modulo; default 4; must be one of (1|2|4|8|16|32) 
##
## version 1.0 2019-07-05 simplified ScaleSize3
##
function ScaleSize(clip C, float fwid, float fhgt, int "mod")
{
    mdd   = Default(mod, 4)

    Assert(fwid>0.01 || fhgt>0.01,
    \   "ScaleSize: either 'wid' or 'hgt' must be > 0")
    Assert(C.Height>0 && C.Width>0,
    \   "ScaleSize: source has zero pixels width or height")
    Assert((mdd==1||mdd==2||mdd==4||mdd==8||mdd==16||mdd==32), 
    \   "ScaleSize: 'mod' argument not one of (1|2|4|8|16|32)")

    forx = Float(C.Width)
    fory = Float(C.Height)
    aspc = forx/fory   ## aspect ratio

    fwid = (fwid>-0.01) ? fwid : fhgt*aspc ## calc from aspect if needed
    fhgt = (fhgt>-0.01) ? fhgt : fwid/aspc

    fx   = fwid/C.Width    ## scale factor: x 
    fy   = fhgt/C.Height   ## scale factor: y
    fxy  = Pow(fx*fy, 0.5) ## scale factor: geometric mean

    mwid = Max(mdd, Round(fwid/mdd)*mdd) ## modulo-restricted width, height   
    mhgt = Max(mdd, Round(fhgt/mdd)*mdd) 
    
    Assert(mwid>=8 && mhgt>=8,
    \   "ScaleSize: final width and height must be >= 8")

    adjX = (Float(mwid)-fwid)/fx ## pre-crop (crop before resize) 
    adjY = (Float(mhgt)-fhgt)/fy

    src_L = -adjX/2.0
    src_T = -adjY/2.0 
    src_W = Float(C.Width) +adjX
    src_H = Float(C.Height)+adjY

    bcuba = (fxy<0.6) ? -0.5 : 0.0
    bcubb = (fxy<0.6) ? 0.0 : 0.75

    n = Chr(10)
    dbg =  "ScaleSize:"
    \   + n + String(mdd,       "mod= %0.0f")
    \   + n + String(C.Width,   "in_wid=   %0.0f")
    \   + n + String(C.Height,  "in_hgt=   %0.0f")
    \   + n + String(fwid,      "arg_wid= %0.2f")
    \   + n + String(fhgt,      "arg_hgt= %0.2f")
    \   + n + String(fx,        "fx= %0.2f")
    \   + n + String(fy,        "fy= %0.2f")
    \   + n + String(fxy,       "scalefactor= %0.2f")
    \   + n + String(mwid,      "out_wid= %0.0f")
    \   + n + String(mhgt,      "out_hgt= %0.0f")
    \   + n + String(mwid-fwid, "raw     adjX= %+0.2f")
    \   + n + String(mhgt-fhgt, "raw     adjY= %+0.2f")
    \   + n + String(adjX,      "scaled adjX= %+0.2f")
    \   + n + String(adjY,      "scaled adjY= %+0.2f")
    \   + n + String(src_L,     "src_L= %+0.2f")
    \   + n + String(src_T,     "src_T= %+0.2f")
    \   + n + String(src_W,     "src_W= %0.2f")
    \   + n + String(src_H,     "src_H= %0.2f")
    #Assert(false, InfoString(C, "C") + n + dbg)

    return C.BicubicResize(mwid, mhgt, bcuba, bcubb, src_L, src_T, src_W, src_H)
}  

##################################
### switch (or fade) between three [[Resize]] clips depending on scale factor
### (overridable with user-specified resizers e.g. nnedi3 etc)
### (ScaleZoom3 sizes by percent; ScaleSize3 by width and/or height)
##  (minimum output dimension 8x8)
##
## @ fwid  - new width
## @ fhgt  - new height
##             (minimum output dimension 8x8)
##             (if 'fwid' <= 0, it is calculated from 'fhgt' and aspect ratio)
##             (if 'fhgt' <= 0, it is calculated from 'fwid' and aspect ratio)
##             (if both <= 0, an error is raised)
##             For example, given a 1920x1080 source,
##             | ScaleSize3(-1, 480, 16)
##             returns an 848x480 clip.
## @ mod    - new size modulo; default 4; must be one of (1|2|4|8|16|32) 
##
## -- A D V A N C E D   A R G U M E N T S -----------------------------------
## @ sm    - resizer for downscaling smaller than 'thrSm' (see below)
## @ med   - resizer for subtle size adjustments
## @ lg    - resizer for upscaling greater than 'thrLg' (see below)
##            If supplied, MUST be name of a filter with [[Resize]] signature:
##             | filter(clip, int target_width, int target_height,
##             |   float src_left, float src_top, float src_width, float src_height) 
##             (default 'sm' ="ScaleSize_small",  gamma-aware [[BicubicResize]](b=-0.5, c=0.25))
##             (default 'med'="ScaleSize_medium", gamma-aware [[Spline64Resize]])
##             (default 'lg' ="ScaleSize_large",  gamma-aware [[GaussResize]](p=50))
## @ thrSm - scale factor below which the 'sm' resizer is used; default 0.65
## @ thrLg - scale factor above which the 'lg' resizer is used; default 1.33
## @ fade  - if true, crossfade between small & medium, and between medium & large; default false.
##             (the idea being to avoid a sudden shift in appearance at the transition)
##             (might be good for very long zooms, but watch out for H- or V-shift issues)
## @ ident - if true, show an on-screen identifier for the small, medium & large clips; default false.
## @ gamma - if true (default) and if bit depth > 8, do linear-light processing 
##           @see [[#remove_gamma]] (may retain more highlights but slightly slower)
## @ hibit - if true, process internally at the next higher bit depth; default false
## @ show  - show final height and width (to show all arguments, use 'debug')
##           default 0; if 1 through 9, sets position in "number pad notation" (cf. [[Subtitle]])
## @ debug - if true, show internal variables on screen; default false; 'show' has priority
##
## version 2.0 2017-04-16 raffriff42
## version 2.1 2017-05-6  auto-nogamma
## version 2.2 2017-05-11 optional user-supplied resize functions
## version 2.3 2018-01-17 'hibit' option
## version 2.4 2019-05-28 'show' option
##
function ScaleSize3(clip C, float fwid, float fhgt, int "mod", 
\               string "sm", string "med", string "lg",
\               float "thrSm", float "thrLg", bool "fade", bool "ident", 
\               bool "gamma", bool "hibit", int "show", bool "debug")
{
    mdd   = Default(mod, 4)
    sm    = Default(sm,  "ScaleSize_small")
    med   = Default(med, "ScaleSize_medium")
    lg    = Default(lg,  "ScaleSize_large")
    thrSm = Default(thrSm, 0.65)
    thrLg = Default(thrLg, 1.33)
    fade  = Default(fade,  false)
    idnt  = Default(ident, false)
    hibit = Default(hibit, false)
    biti  = C.BitsPerComponent
    bitn  = _nextHiBit(biti)
    show  = Default(show, 0)
    debug = Default(debug, false)

    C = (!hibit)     ? C 
    \ : (bitn<=biti) ? C 
    \ : C.ToHibit(bitn) 
    gamma = Default(gamma, C.BitsPerComponent>8)

    Assert(fwid>0.01 || fhgt>0.01,
    \   "ScaleSize3: either 'wid' or 'hgt' must be > 0")
    Assert(C.Height>0 && C.Width>0,
    \   "ScaleSize3: source has zero pixels width or height")
    Assert((mdd==1||mdd==2||mdd==4||mdd==8||mdd==16||mdd==32), 
    \   "ScaleSize3: 'mod' argument not one of (1|2|4|8|16|32)")

    forx = Float(C.Width)
    fory = Float(C.Height)
    aspc = forx/fory   ## aspect ratio

    fwid = (fwid>-0.01) ? fwid : fhgt*aspc ## calc from aspect if needed
    fhgt = (fhgt>-0.01) ? fhgt : fwid/aspc

    fx   = fwid/C.Width    ## scale factor: x 
    fy   = fhgt/C.Height   ## scale factor: y
    fxy  = Pow(fx*fy, 0.5) ## scale factor: geometric mean

    mwid = Max(mdd, Round(fwid/mdd)*mdd) ## modulo-restricted width, height   
    mhgt = Max(mdd, Round(fhgt/mdd)*mdd) 
    
    Assert(mwid>=8 && mhgt>=8,
    \   "ScaleSize3: final width and height must be >= 8")

    adjX = (Float(mwid)-fwid)/fx ## pre-crop (crop before resize) 
    adjY = (Float(mhgt)-fhgt)/fy

    src_L = -adjX/2.0
    src_T = -adjY/2.0 
    src_W = Float(C.Width) +adjX
    src_H = Float(C.Height)+adjY

    n = Chr(10)
    dbg =  "ScaleSize3:"
    \   + n + String(mdd,       "mod= %0.0f")
    \   + n + String(C.Width,   "in_wid=   %0.0f")
    \   + n + String(C.Height,  "in_hgt=   %0.0f")
    \   + n + String(fwid,      "arg_wid= %0.2f")
    \   + n + String(fhgt,      "arg_hgt= %0.2f")
    \   + n + String(fx,        "fx= %0.2f")
    \   + n + String(fy,        "fy= %0.2f")
    \   + n + String(fxy,       "scalefactor= %0.2f")
    \   + n + String(mwid,      "out_wid= %0.0f")
    \   + n + String(mhgt,      "out_hgt= %0.0f")
    \   + n + String(mwid-fwid, "raw     adjX= %+0.2f")
    \   + n + String(mhgt-fhgt, "raw     adjY= %+0.2f")
    \   + n + String(adjX,      "scaled adjX= %+0.2f")
    \   + n + String(adjY,      "scaled adjY= %+0.2f")
    \   + n + String(src_L,     "src_L= %+0.2f")
    \   + n + String(src_T,     "src_T= %+0.2f")
    \   + n + String(src_W,     "src_W= %0.2f")
    \   + n + String(src_H,     "src_H= %0.2f")
    #Assert(false, InfoString(C, "C") + n + dbg)

    CG = (C.IsYUY2) ? C.ConvertToYV24
    \  : (C.IsRGB24 || C.IsRGB48) ? C.ConvertToPlanarRGB
    \  : (C.IsRGB32 || C.IsRGB64) ? C.ConvertToPlanarRGBA
    \  : C
    CG = (gamma) ? CG.remove_gamma : C

    ## "callback functions" 
    CLG = Apply(lg,  CG, mwid, mhgt, src_L, src_T, src_W, src_H)
    CMG = Apply(med, CG, mwid, mhgt, src_L, src_T, src_W, src_H)
    CSG = Apply(sm,  CG, mwid, mhgt, src_L, src_T, src_W, src_H)

    CL = (gamma) ? CLG.restore_gamma : CLG
    CM = (gamma) ? CMG.restore_gamma : CMG
    CS = (gamma) ? CSG.restore_gamma : CSG

    CL = (C.IsYUY2) ? CL.ConvertToYUY2 : CL
    CM = (C.IsYUY2) ? CM.ConvertToYUY2 : CM
    CS = (C.IsYUY2) ? CS.ConvertToYUY2 : CS

    CL = (idnt) ? CL.bigsub("L#-") : CL 
    CM = (idnt) ? CM.bigsub("#M#") : CM 
    CS = (idnt) ? CS.bigsub("-#S") : CS 

    ## switch (or fade) between scaling methods depending on scale factor:
    R = (fade && fxy > 1.2 * thrLg) ? CL
    \ : (fade && fxy > 0.8 * thrLg) ? Merge(CM, CL, fxy-thrLg)
    \ : (fade && fxy > 1.2 * thrSm) ? CM
    \ : (fade && fxy > 0.8 * thrSm) ? Merge(CS, CM, 2*fxy-thrSm) 
    \ : (fxy > thrLg) ? CL
    \ : (fxy > thrSm) ? CM
    \                 : CS

    R = R.MatchColorFormat(C)
    R = (show>=1 && show<=9)
    \ ? R.Subtitle42("resize("+String(mwid, "%0.0f,")+String(mhgt, "%0.0f")+")", 
    \         size=56*Sqrt(R.Height/720.0), lsp=0, align=show, 
    \         text_color=color_yellow)
    \ : (debug)  
    \   ? R.Subtitle42(dbg.ReplaceStr(Chr(10), "\n"), size=12, 
    \                  x=R.Width*3/8, y=R.Height*1/16, lsp=0)
    \   : R
    return R

    ## ScaleSize3 "callback functions" - user-overridable: 

    ###############################
    ### for downscaling smaller than aprox. 0.5x
    function ScaleSize_small(clip C, 
    \                   int   mwid,  int   mhgt, 
    \                   float src_L, float src_T, 
    \                   float src_W, float src_H)
    {
        return C.BicubicResize(mwid, mhgt, -0.5, 0.25,
        \           src_L, src_T, src_W, src_H)
    }
    ###############################
    ### for subtle size adjustments
    function ScaleSize_medium(clip C, 
    \                   int   mwid,  int   mhgt, 
    \                   float src_L, float src_T, 
    \                   float src_W, float src_H)
    {
        return C.Spline64Resize(mwid, mhgt,
        \           src_L, src_T, src_W, src_H)
    }
    ###############################
    ### for upscaling greater than aprox. 2x
    ### (if substituting nnedi3 etc, watch out for image shift issues)
    ##
    function ScaleSize_large(clip C, 
    \                   int   mwid,  int   mhgt, 
    \                   float src_L, float src_T, 
    \                   float src_W, float src_H)
    {
        return C.GaussResize(mwid, mhgt,
        \           src_L, src_T, src_W, src_H, p=50)
    }
}

# http://forum.doom9.org/showthread.php?p=1737682#post1737682
##################################
### crop to size with smooth pan & tilt (range -1.0_1.0; center @ 0, 0)
## related: [[#CropShift]]
##                                                                  
## @ panRt  - -1=left, 0=center, +1=right; [default 0]
## @ tiltDn - -1=up,   0=center, +1=down;  [default 0]
## 
## @ title  - will be added as a [[Subtitle]] (used in eg, [[StackTwoAcrossCropped]]) 
## @ align  - see Subtitle: align
## @ color  - see Subtitle: text_color
## @ size   - see Subtitle: size
##
function CropPanTilt(clip C, int wid, int hgt, float "panRt", float "tiltDn",
\               string "title", int "align", int "color", float "size")
{
    C
    bdrWid = (wid - Width)
    bdrHgt = (hgt - Height)

    xctr  = Min(Max(-1.0, Default(panRt, 0.0)), 1.0) 
    yctr  = Min(Max(-1.0, Default(tiltDn, 0.0)), 1.0)

    bdrLt = Abs(Float(bdrWid) / 2.0)
    bdrLt = bdrLt + bdrLt * xctr
    bdrLt = Sign(bdrWid) * bdrLt
    
    bdrTp = Abs(Float(bdrHgt) / 2.0) 
    bdrTp = bdrTp + bdrTp * yctr
    bdrTp = Sign(bdrHgt) * bdrTp
    
    align = Default(align, 7) 
    color = Default(color, $ffff00) 
    size  = Default(size, Height/32) 

    Assert(bdrLt<=0 && bdrTp<=0, 
    \   "CropPanTilt: clip too small for target size")

    Spline36Resize(wid, hgt, -bdrLt, -bdrTp, wid, hgt)
    return (!defined(title)) ? Last 
    \  : Subtitle(String(title), size=size, text_color=color, align=align, lsp=0)
}

##################################
### crop to size with smooth animated pan & tilt, expressed as pixels (center @ off_x=0, off_y=0)
## (maximum shift in any direction restricted to number of cropped pixels on that side)
## related: CropPanTilt, CropEx
##
## @ off_x  <0=left, 0=center, >0=right; [default 0]
## @ off_y  <0=up,   0=center, >0=down;  [default 0]
##
function CropShift(clip C, int wid, int hgt, float "off_x", float "off_y")
{
    off_x = Default(off_x, 0.0)
    off_y = Default(off_y, 0.0)

    bdrWid = (wid - C.Width)
    bdrHgt = (hgt - C.Height)

    bdrLt = Abs(Float(bdrWid) / 2.0)
    bdrLt = bdrLt - off_x
    bdrLt = Sign(bdrWid) * bdrLt
    
    bdrTp = Abs(Float(bdrHgt) / 2.0) 
    bdrTp = bdrTp - off_y
    bdrTp = Sign(bdrHgt) * bdrTp

    (bdrLt<=0 && bdrTp<=0) ? Nop
    \ : Assert(false, "CropShift: clip too small for target size")

    return C.Spline36Resize(wid, hgt, -bdrLt, -bdrTp, wid, hgt)
} 

# https://forum.doom9.org/showthread.php?p=1739635#post1739635
### fka UUSize4
##################################
### crop or expand a clip to ensure it is a certain size (symmetrically by default) 
### with size forced to mod-4, mod-8 etc
##
## @ wid, hgt - New desired width & height (will be rounded to nearest 'mod')
## @ mod      - [[Mod]] value; one of (1|2|4|8|16|32); default 2
##              (an error will be raised if 'mod' too small, eg for YV411 or interlaced clips)
## @ border   - Border color; default 0 (black border)
## @ mode     - Expand method: (extend|mirror|blur|border) 
##                * extend: edge pixels repeated; useful for avoiding edge artifacts
##                  with certain filters; intended to be cropped out later on.
##                * mirror: like "extend" but edge pixels repeated in reverse order.
##                * blur: darkened, blurry, stretched edge content.
##                  Suitable for fixing vertical aspect "phone" video for example.
##                * border: black or colored borders, aka letterboxing.
##              Default "border" (also fallback in case of invalid 'mode')
##
## -- A D V A N C E D   A R G U M E N T S -----------------------------------
## @ align    - Position clip within new frame size;
##              @see [[Subtitle]] "number pad notation".
##              For example, if align=7 and expanding, image is placed at top-left;
##              and if cropping, top-left portion is preserved. Default 5 (centered)
## @ dx, dy   - Shift output in x/y direction. Positive = right/down. Default 0. 
##              Note output shift rounded to nearest mod-2 unless 'mod'=1.
## @ show     - show final L, T, B, R arguments (to show all arguments, use 'debug')
##              default 0; if 1 through 9, sets position in "number pad notation" (cf. [[Subtitle]])
## @ debug    - Show internal variables; 'show' has priority
##
## EXAMPLES:
## | ## black borders
## | CropEx(x, y) 
## | ## color borders
## | CropEx(x, y, border=color_red) 
## | ## extend edges
## | CropEx(x, y, mode="extend") 
## | ## mirror borders
## | CropEx(x, y, mode="mirror")
##
##  v.1.1 - align, dx, dy
##  v.1.2 - if change in width & height < 2 px, use [[Resize#Cropping]]
##
function CropEx(clip C, float wid, float hgt, int "mod",   
\               int "border", string "mode", 
\               int "align", int "dx", int "dy", int "show", bool "debug")
{
    mode    = Default(mode, "border")
    border  = Default(border, 0)
    aln     = Default(align, 5)
    dx      = Default(dx, 0)
    dy      = Default(dy, 0)
    show    = Default(show, 0)
    dbug    = Default(debug, false)
    mdd     = (C.IsYV411||C.IsFieldBased) ? 4 : (C.IsRGB||C.IsY||C.Is444) ? 1 :  2
    mdd     = Max(mdd, Default(mod, mdd))

    Assert((mdd==1||mdd==2||mdd==4||mdd==8||mdd==16||mdd==32), 
    \  "CropEx: 'mod' argument not one of (1|2|4|8|16|32)")

    try {
        return _CropExTry(C, wid, hgt, mdd, border, mode, aln, dx, dy, show, dbug)
    }
    catch (err_msg) {
        Assert(FindStr(err_msg, "multiple")==0 && FindStr(err_msg, "Mod ")==0, 
        \   "CropEx 'mod' argument too small: " + Chr(10) + err_msg) 
        Assert(false, 
        \   "CropEx internal error: " + Chr(10) + err_msg) 
    }

    function _CropExTry(clip C, float wid, float hgt, int mdd,   
    \               int border, string mode, 
    \               int aln, int dx, int dy, int show, bool dbug)
    {
        border = Min(Max(0, border), $ffffff)

        wid = Round(wid)
        hgt = Round(hgt)
        out_wid = modx(mdd, wid)
        out_hgt = modx(mdd, hgt)

        C ## Last==C

        bdrX  = out_wid - Width
        bdrY  = out_hgt - Height

        ## border-left: 
        bdrLt = (aln==1||aln==4||aln==7) ? 0     [* left   *]
        \     : (aln==3||aln==6||aln==9) ? bdrX  [* right  *]
        \     : Round(0.5*bdrX)                  [* center *]

        ## border-top: 
        bdrTp = (aln==7||aln==8||aln==9) ? 0     [* top    *]
        \     : (aln==1||aln==2||aln==3) ? bdrY  [* bottom *]
        \     : Round(0.5*bdrY)                  [* center *]

        ## enforce mod restriction
        bdrLt = modx(mdd, bdrLt)
        bdrTp = modx(mdd, bdrTp)

        ## right and bottom get the remainder
        bdrRt = (bdrX - bdrLt) 
        bdrBt = (bdrY - bdrTp)

        ## add dx/dy shift:
        dx    = modx(mdd, dx)
        dy    = modx(mdd, dy)
        bdrTp = bdrTp + dy
        bdrLt = bdrLt + dx
        bdrRt = bdrRt - dx
        bdrBt = bdrBt - dy

        mode = (mode=="extend")  ? mode
        \    : (mode=="mirror")  ? mode
        \    : (mode=="blur")    ? mode
        \    : "border"

        t = Chr(9)
        n = Chr(10)
        dbg=                    "CropEx:      "     +t+String(mdd,        "mod= %0.0f")
        \  +n+String(Width,     "in_wid= %0.0f  ")  +t+String(Height,     "in_hgt= %0.0f")
        \  +n+String(wid,       "arg_wid= %0.0f ")  +t+String(hgt,        "arg_hgt= %0.0f")
        \  +n+String(bdrX,      "bdrX= %+0.0f   ")  +t+String(bdrY,       "bdrY= %+0.0f")
        \  +n+String(bdrLt,     "bdrLt= %+0.0f  ")  +t+String(bdrTp,      "bdrTp= %+0.0f")
        \  +n+String(bdrRt,     "bdrRt= %+0.0f  ")  +t+String(bdrBt,      "bdrBt= %+0.0f")
        \  +n+String(out_wid,   "out_wid= %0.0f ")  +t+String(out_hgt,    "out_hgt= %0.0f")
        \  +n+String(border,    "mode= '%0.0f'  ")  +t+String(border,     "border= %0.0f")
        #Assert(false, dbg)

        ## use resize-crop for minor crop or expand; ignore errors
        temp = Last
        useResize = mdd<=2 && Abs(bdrX)<=2 && Abs(bdry)<=2
        try {
            (useResize)
            \ ? BilinearResize(out_wid, out_hgt, 0.5*bdrX, 0.5*bdrY, Width, Height)
            \ : Last
        }
        catch (err_msg) {
            useResize = false
            Last = temp
        }

        (useResize || (bdrLt<=0 && bdrRt<=0 && bdrTp<=0 && bdrBt<=0))
        \ ? Last 
        \ : (mode=="extend") ? _Padding(
        \       Max(0, bdrLt), Max(0, bdrTp), 
        \       Max(0, bdrRt), Max(0, bdrBt))
        \ : (mode=="mirror") ? _MirrorBorders(
        \       Max(0, bdrLt), Max(0, bdrTp), 
        \       Max(0, bdrRt), Max(0, bdrBt))
        \ : (mode=="blur") ? _BlurBorders(
        \       Max(0, bdrLt), Max(0, bdrTp), 
        \       Max(0, bdrRt), Max(0, bdrBt))
        \ : AddBorders(
        \       Max(0, bdrLt), Max(0, bdrTp), 
        \       Max(0, bdrRt), Max(0, bdrBt), border) 

        (useResize || (bdrLt>=0 && bdrRt>=0 && bdrTp>=0 && bdrBt>=0))
        \ ? Last 
        \ : Crop(
        \       ((bdrLt<0) ? -bdrLt : 0), 
        \       ((bdrTp<0) ? -bdrTp : 0), 
        \       ((bdrRt<0) ?  bdrRt : out_wid), 
        \       ((bdrBt<0) ?  bdrBt : out_hgt))

        return (show>=1 && show<=9)
        \ ? Subtitle42("cropex("
        \       + String(bdrLt, "%+0.0f,") 
        \       + String(bdrTp, "%+0.0f,") 
        \       + String(bdrRt, "%+0.0f,") 
        \       + String(bdrBt, "%+0.0f")+")", 
        \         size=56*Sqrt(Height/720.0), lsp=0, align=show, 
        \         text_color=color_magenta)
        \ : (dbug)  
        \ ? Subtitle42(SplitLines(dbg), font="Courier New", x=16, align=4, lsp=0)
        \ : Last
    }
}


# http://forum.doom9.org/showthread.php?p=1596804#post1596804
##################################
### CropEx helper: borders with repeated edge pixels
##
## @ left, top, right, bottom - size of borders to be added
##
function _Padding(clip C, int left, int top, int right, int bottom)
{
    left   = Max(0, left)
    top    = Max(0, top)
    right  = Max(0, right)
    bottom = Max(0, bottom)

    w = C.Width
    h = C.Height
    C.PointResize(
    \   w+left+right, h+top+bottom, 
    \   -left, -top, 
    \   w+left+right, h+top+bottom)
}

# http://forum.doom9.org/showthread.php?p=1739635#post1739635
##################################
### CropEx helper: borders with mirrored edge pixels
##
## @ left, top, right, bottom - size of borders to be added
##
function _MirrorBorders(clip C, int left, int top, int right, int bottom)
{
    bdrLt = Max(0, left  )
    bdrTp = Max(0, top   )
    bdrRt = Max(0, right )
    bdrBt = Max(0, bottom)

    C ## Last==c

    (bdrLt==0) ? Last : StackHorizontal(
    \                       _stack_to_wid(bdrLt, flip=true)
    \                       .Crop(0, 0, bdrLt, 0)
    \                       .FlipHorizontal, 
    \                       Last)

    (bdrRt==0) ? Last : StackHorizontal(
    \                       Last, 
    \                       _stack_to_wid(bdrRt, flip=true)
    \                       .Crop(Width-bdrRt, 0, bdrRt, 0)
    \                       .FlipHorizontal)

    (bdrTp==0) ? Last : StackVertical(
    \                       _stack_to_hgt(bdrTp, flip=true)
    \                       .Crop(0, 0, 0, bdrTp)
    \                       .FlipVertical, 
    \                       Last)

    (bdrBt==0) ? Last : StackVertical(
    \                       Last, 
    \                       _stack_to_hgt(bdrBt, flip=true)
    \                       .Crop(0, Height-bdrBt, 0, bdrBt)
    \                       .FlipVertical)    
    return Last
}

# https://forum.doom9.org/showthread.php?p=1807908#post1807908
##################################
### CropEx helper: soft, dark borders
##
## @ left, top, right, bottom - size of borders to be added
##
## -- A D V A N C E D   A R G U M E N T S -----------------------------------
## @ gain   - brightness of pillarbox portion; 
##              range 0.2_2.0; default 0.9 (slightly darker)
##              (bypass / substitute plain black borders if gain < 0.1)
## @ sat    - saturation of pillarbox portion; 
##              range 0.0_2.0; default 0.6 (60%)
## @ blue   - blue shift of pillarbox portion; 
##              range -32_32; default 0 (none; 2=subtle)
## @ pblur  - amount of pillarbox blur; 
##              range 0_200; default 100 (strong)
## @ tblur  - radius of temporal blur; 
##              range 0_9; default 0 (off)
## @ scene - pillarbox temporal blur scene change threshold
##              range 0_255; default 32
## @ fullblur - if true, blur entire image; else (default) blur borders only
## @ version 2.1.2
##
function _BlurBorders(clip C, int left, int top, int right, int bottom, 
\                    float "gain", float "sat", int "blue",
\                    int "pblur", int "tblur", int "scene", bool "fullblur")
{
    Assert(!C.IsYV411, 
    \  "BlurBorders: YV411 not accepted") ## (cf. Overlay)
    C
    wid   = Width  + left + right
    hgt   = Height + top + bottom 

    gain  = Min(Max(0.0,  Default(gain,  0.9 )), 2.0)
    sat   = Min(Max(0.0,  Default(sat,   0.6 )), 2.0)
    blue  = Min(Max(-32,  Default(blue,  0   )), 32)
    blur  = Min(Max(0,    Default(pblur, 100 )), 200)
    tblur = Min(Max(0,    Default(tblur, 0   )), 9)
    scene = Min(Max(0,    Default(scene, 32  )), 255)
    fblur = Default(fullblur, false)

    ## TEMPORAL SOFTEN (if desired) (performed first as it adds artifacts)
    (tblur==0) ? Last 
    \ : TemporalSoften(tblur, 255, 255, scene, 2)

    ## STRETCH + BLUR
    w = Max(16, m4(Float(wid)/blur))
    h = Max(16, m4(Float(hgt)/blur))
    BilinearResize(w, h)
    GaussResize(wid, hgt, p=19)
    ## p=19: softest w/o visible 'blockiness' 

    ## DARKEN, DESATURATE
    (C.IsRGB) ? ConvertToYUV444 : Last
    ColorYUV(gain_y=f2c(gain), off_u=blue, cont_u=f2c(sat), cont_v=f2c(sat))
    (C.IsRGB) ? MatchColorFormat(C) : Last

    return (fblur) ? Last
    \ : Last.Overlay(C, x=left, y=top)
} 

##################################
### shift a clip up-down and left-right (with sub-pixel precision);
### this results in repeated edge pixels
##
function Shift(clip C, float offh, float offv)
{
    C 
    BilinearResize(Width, Height, -offh, -offv, Width, Height)
    return Last
}

## animated demo: https://forum.doom9.org/showthread.php?p=1774699#post1774699
##==> see also http://avisynth.nl/images/ChromaShiftSP.avsi
##################################
### shift Chroma relative to Luma
## (YUV, YUVA) 
##  
function ShiftUV(clip C, float "ux", float "uy", float "vx", float "vy")
{
    Assert(C.IsYUV || C.IsYUVA, 
    \  "ShiftUV: source must be YUV(A)")
    ux = Float(Default(ux, 0))
    uy = Float(Default(uy, 0))
    vx = Float(Default(vx, ux))
    vy = Float(Default(vy, uy))

    U = C.ExtractU
    V = C.ExtractV
    
    U = U.BilinearResize(U.Width, U.Height, -ux, -uy, U.Width, U.Height)
    V = V.BilinearResize(V.Width, V.Height, -vx, -vy, V.Width, V.Height)
    
    return (C.NumComponents==3)
    \ ? CombinePlanes(C.ExtractY, U, V, "YUV")
    \ : CombinePlanes(C.ExtractY, U, V, C.ExtractA, "YUVA")
}

# https://forum.doom9.org/showthread.php?p=1803247#post1803247
##################################
### shift and/or resize Red and Blue relative to Green
##  (RGB24, RGB32, RGB48, RGB64, RGB10/12/14/16/32, RGBA10/12/14/16/32)
##
## @ rx,  ry,  bx,  by  - ± "shift" red & blue position
## @ rxd, ryd, bxd, byd - ± "delta" width & height for advanced convergence
##
function ShiftRedBlue(clip C, 
\               float "rx", float "ry",
\               float "bx", float "by",
\               float "rxd", float "ryd",
\               float "bxd", float "byd")
{
    Assert(C.IsRGB, 
    \   "ShiftRedBlue: source must be RGB")
    rx  = Float(Default(rx,  0))
    ry  = Float(Default(ry,  0))
    bx  = Float(Default(bx,  0))
    by  = Float(Default(by,  0))
    rxd = Float(Default(rxd, 0))
    ryd = Float(Default(ryd, 0))
    bxd = Float(Default(bxd, 0))
    byd = Float(Default(byd, 0))

    C
    R = ExtractR.Spline64Resize(Width, Height, -rx, -ry, Width-rxd, Height-ryd)
    G = ExtractG
    B = ExtractB.Spline64Resize(Width, Height, -bx, -by, Width-bxd, Height-byd)

    R = (NumComponents==3)
    \ ? CombinePlanes(R, G, B, "RGB")
    \ : CombinePlanes(R, G, B, ExtractA, "RGBA")
    return R.MatchColorFormat(C)
}

### fka UUStackTwoAcrossCropped
##################################
### make side-by-side split screen, cropping both to fit
##
## @ A, B      - source clips: A on left side, B on right (heights must match)
## @ S         - sound source; must be a clip, "A" or "B" [default clip A]
## @ border    - border between clips [default = 8]
## @ pan       - range = -1.0_1.0: -1.0=left, 0.0=center, +1.0=right; [default = 0.0]
## @ panB      - range = -1.0_1.0: -1.0=left, 0.0=center, +1.0=right; [default = 'pan']
##
## @ wid       - output width [default = input width]
## @ splitPos  - range = 20 to 80: 20=divider 20% from left; 80=80% from left [default = 50]
##
## @ titleA, B - short identifier strings for debugging
## @ align     - see [[Subtitle]]: align [default 7]
##
## @version 1.0 28-May-2012 raffriff42
## @version 1.1 02-Apr-2014 (@ wid)
## @version 1.2 09-Jun-2019 splitPos
## @version 1.3 06-Dec-2020 bugfix(!)
##
function SplitScreen(clip A, clip B, val "S", 
\               int "border", float "pan", float "panB", 
\               int "wid", int "splitPos", 
\               string "titleA", string "titleB", int "align")
{
    Assert(IsClip(A) && HasVideo(A), "SplitScreen: source 'A' not valid")
    Assert(IsClip(B) && HasVideo(B), "SplitScreen: source 'B' not valid")
    Assert(A.Width==B.Width, "SplitScreen: source heights must match")

    s = Default(S, A)
    S = (IsString(S) && StrCmpi(S, "A")==0) ? A
    \ : (IsString(S) && StrCmpi(S, "B")==0) ? B
    \ : (IsClip(S)) ? S
    \ : 0

    inWid   = Default(wid, A.Width)
    inHgt   = Min(A.Height, B.Height)     
    border  = m4(Default(border, 8))
    border2 = Int(border / 2) 
    splitPos  = Float(Min(Max(20, Default(splitPos, 50)), 80)) / 100.0
    pan     = Min(Max(-1.0, Float(Default(pan, 0.0))),  1.0)
    panB    = Min(Max(-1.0, Float(Default(panB, pan))), 1.0)

    align = Default(align, 7)

    widA = modx(2, Float(inWid) * splitPos)
    widB = modx(2, Float(inWid) * (1.0 - splitPos))

    A = A.CropPanTilt(widA-border2, inHgt, pan,  0.0, titleA, align)
    B = B.CropPanTilt(widB-border2, inHgt, panB, 0.0, titleB, align)
 
    A = A.AddBorders(0,       0, border2, 0)
    B = B.AddBorders(border2, 0, 0,       0)

    R = StackHorizontal(A, B)

    return (!IsClip(S))  ? R 
    \    : (!S.HasAudio) ? R 
    \    : AudioDub(R, S)
}

### fka UUStackTwoOverCropped
##################################
### make over-and-under split screen, cropping both to fit
##
## @ A, B      - source clips: A on top, B below (widths must match)
## @ S         - sound source; must be a clip, "A" or "B" [default clip A]
## @ border    - border between clips [default = 8]
##
## @ tiltA     - range = -1.0 to +1.0: -1.0=up,   0.0=center, +1.0=down; [default = 0.0]
## @ tiltB     - range = -1.0 to +1.0: -1.0=up,   0.0=center, +1.0=down; [default = 0.0]
## @ splitPos    - range = 20 to 80: 20=divider 20% from top; 80=80% from top [default = 50]
##
## @ hgt       - output height [default = input width]
## @ splitPos  - range = 20 to 80: 20=divider 20% from top; 80=80% from top [default = 50]
##
## @ titleA, B - short identifier strings for debugging
## @ align     - see [[Subtitle]]: align [default 7]
##
## @version 1.0 28-May-2012 raffriff42
## @version 1.1 02-Apr-2014 (@ wid)
## @version 1.2 09-Jun-2019 splitPos
##
function SplitScreenVert(clip A, clip B, val "S", 
\               int "border", float "tiltA", float "tiltB", 
\               int "hgt", int "splitPos", 
\               string "titleA", string "titleB", int "align")
{
    Assert(IsClip(A) && HasVideo(A), "SplitScreenVert: source 'A' not valid")
    Assert(IsClip(B) && HasVideo(B), "SplitScreenVert: source 'B' not valid")
    Assert(A.Width==B.Width, "SplitScreenVert: source widths must match")

    s = Default(S, A)
    S = (IsString(S) && StrCmpi(S, "A")==0) ? A
    \ : (IsString(S) && StrCmpi(S, "B")==0) ? B
    \ : (IsClip(S)) ? S
    \ : 0

    inWid   = Min(A.Width, B.Width)     
    inHgt   = Default(hgt, A.Height)
    border  = m4(Default(border, 8))
    border2 = Int(border / 2) 
    splitPos  = Float(Min(Max(20, Default(splitPos, 50)), 80)) / 100.0
    tiltA   = Min(Max(-1.0, Float(Default(tiltA, 0.0))), 1.0)
    tiltB   = Min(Max(-1.0, Float(Default(tiltB, 0.0))), 1.0)

    align = Default(align, 7)

    hgtA = modx(2, Float(inHgt) * splitPos)
    hgtB = modx(2, Float(inHgt) * (1.0 - splitPos))

    A = A.CropPanTilt(inWid, hgtA-border2, 0.0, tiltA, titleA, align)
    B = B.CropPanTilt(inWid, hgtB-border2, 0.0, tiltB, titleB, align)
 
    A = A.AddBorders(0, 0,       0, border2)
    B = B.AddBorders(0, border2, 0, 0)

    R = StackVertical(A, B) #.CropPanTilt(inWid, inHgt)

    return (!IsClip(S))  ? R 
    \    : (!S.HasAudio) ? R 
    \    : AudioDub(R, S)
}

#######################################################################################
### DEBUGGING FILTERS
#######################################################################################

##################################
### return true if running in Avisynth+, false otherwise
##
function IsAvsPlus()
{
    sVer = LCase(VersionString) 
    return (FindStr(sVer, "avisynth+")    > 0)
    \   || (FindStr(sVer, "avisynthplus") > 0)
}

##################################
### return AVS+ build number, if present; else 0
##
function VersionBuildNumber()
{
    ## example version strings:
    ## "AviSynth 2.08 (avisynth.org) 22 nov. 2002"
    ## "AviSynth 2.60, build:Mar 31 2015 [16:38:54]"
    ## "AviSynth 2.61, build:May 17 2016[16:06:18] VC2008Exp"
    ## "AviSynth+ 0.1 (r2508, MT, x86_64)"
    ## ................ ^^^^ VersionBuildNumber

    sVer = LCase(VersionString)
    pVer = FindStr(sVer, "avisynth+")
    sVr2 = (pVer==0) ? "" : TrimLeft(MidStr(sVer, pVer+9))
    pVr2 = (pVer==0) ? 0  : FindStr(sVr2, "(r")
    nVr2 = (pVr2==0) ? 0  : Round(Value(MidStr(sVr2, pVr2+2)))    
    return nVr2
}

##################################
### return basic variable properties as a string
##  (useful in an Assert popup to get clip info without returning the clip itself)
##  (can also be displayed as a [[Subtitle]])
##
## @ C - any variable; if 'C" is a clip, show clip properties; 
##       else if a string, float etc, show its type and value
## @ label    - a short identifier string; optional
## @ subtitle - if true, format for multiline subtitle (see example)
##
## Example 
## | Assert(false, InfoString) ## show info about current 'Last' variable
## | Assert(false, InfoString(C, "C") ## show info about 'C'
## | Subtitle(InfoString(C, subtitle=true), lsp=0)
##
function InfoString(val C, string "label", bool "subtitle")
{
    label = Default(label, "")
    issub = Default(subtitle, false)
    n = Chr(10)
    m = ", " 
    C
    sv = !(Defined(C) && IsClip(C) && C.HasVideo) ? "(no video)"
    \ : "Video: " + PixelType + m + String(Width) +"x" + String(Height)
    \ + m + String(FrameRate, "%0.3f fps")
    \ + m + String(FrameCount, "%0.0f")+" fr "
    \ + "("+FormatTime(Float(FrameCount)/FrameRate)+")"
    \ + (IsFieldBased ? m +(GetParity ? "TFF" : "BFF") : "")

    sa = !(Defined(C) && IsClip(C) && C.HasAudio) ? "(no audio)"
    \ : "Audio: " + String(AudioChannels, "%0.0f ch")
    \ + m + String(AudioBits, " %0.0f bits")
    \ + m + String(Float(AudioRate)/1000.0, " %0.3f kHz")
    \ + m + FormatTime(AudioDuration)

    srtn = !(Defined(C)) 
    \   ? "InfoString: " + TrimAll(label) + " (undefined)"
    \ : (IsString(C))  
    \   ? "InfoString: " + TrimAll(label) + n + "(string) '" + String(C) + "'"
    \ : (IsReallyFloat(C))  
    \   ? "InfoString: " + TrimAll(label) + n + "(float) "   + StrinF(C, 3)
    \ : (IsInt(C))  
    \   ? "InfoString: " + TrimAll(label) + n + "(int) "     + String(C)
    \ : (IsBool(C))  
    \   ? "InfoString: " + TrimAll(label) + n + "(bool) "    + String(C)
    \ : (IsClip(C))  
    \   ? "InfoString: " + TrimAll(label) + n + sv + n + sa
    \   : "InfoString: " + TrimAll(label) + " (not a clip)" + n + String(C)
    ## TODO future Array type?

    return (issub) 
    \ ? srtn.ReplaceStr(n, "\n")
    \ : srtn
}

##################################
### for clip identification, show a semitransparent text string, very large by default
##
## @ sizeMult   - adjust size if needed (default 1.0 means text size = 'C'.Height) 
## @ enable     - if true, bypass this filter (useful with a 'master' control variable) 
## @ text_color - default semitransparent yellow
## @ halo_color - default fully transparent
## @ align      - default 2 
##
function bigsub(clip C, string msg, float "sizeMult", bool "enable",
\               int "text_color", int "halo_color", int "align")
{
    enable     = Default(enable, true)
    sizeMult   = Default(sizeMult, 1.0)
    text_color = Default(text_color, $aaffff00)
    halo_color = Default(halo_color, $ff000000)
    aln        = Default(align, 2)

    return (enable==false) ? C : 
    \   C.Subtitle42(msg, align=aln, size=Round(sizeMult * Float(C.Height)), 
    \          text_color=text_color, halo_color=halo_color)
}

##################################
### [[Eval]] a script snippet; show script & its return value (clip or nonclip);
## [[ShowSnippet]] wrapper for case where snippet does not access external variables
##
## @ c     - the background video; default [[BlankClip]]
## @ s     - a snippet of AviSynth code; any string allowed as an argument to Eval.
## @ font, size, text_color, halo_color, align,
##         - cf. [[Subtitle]], except default text_color=green & size=auto 
##           (to disable text, set 'size' = 0)
## @ name  - script name for error reporting purposes
##
## NOTE - in the snippet, 'C' and 'Last' both reference the background clip
##
## Examples (assuming 'Last' is a valid clip):
## | x=0.5
## | s="RGBAdjust(x, x, x)"
## | EvalShow(s) ## Error - "I don't know what 'x' means" (use ShowSnippet)
## | 
## | s="x=0.5
## | RGBAdjust(x, x, x)"
## | EvalShow(s) ## OK to access variables defined *within* snippet
## 
## | ## nonclip result; display result as text
## | s="x=128
## | x*x"
## | EvalShow(s) 
##
function EvalShow(clip "c", string "s", 
\               string "font", float "size", 
\               int "text_color", int "halo_color", 
\               int "align", string "name")
{
    C     = (Defined(c) && IsClip(c)) ? c : BlankClip
    s     = Default(s, "# (empty)")
    size  = Default(size, Max(8.0, Min(C.Height/16.0, C.Width/36.0)))
    sname = Default(name, "eval_show")

    r = C.Eval(s, sname)
    return C.ShowSnippet(s, r, font, size, 
    \               text_color, halo_color, 
    \               align=align) 
}

##################################
### Display a script snippet & its return value (clip or nonclip);
## Required in place of [[EvalShow]] where snippet accesses external variables
##
## @ c - the background video; default [[BlankClip]]
## @ s - a snippet of AviSynth code; any legal [[Eval]] string.
## @ r - the snippet's return value when Evaluated (external to this filter)
##       default is 'C'
## @ font, size, text_color, halo_color, align, x, y 
##     - cf. [[Subtitle]], except default text_color=green & size=auto 
##
## NOTE - in the snippet, 'C' and 'Last' both reference the background clip
##
## Examples (assuming 'Last' is a valid clip):
## | ## clip result; call [[Eval]] to execute the snippet, ShowSnippet to display it
## | x=0.5
## | s="RGBAdjust(x, x, x)"
## | Eval(s).ShowSnippet(s)
##
## | ## nonclip result; display snippet + result as text
## | x=128
## | s="x*x"
## | r=Eval(s)
## | ShowSnippet(s, r) 
##
function ShowSnippet(clip "c", string "s", val "r", 
\               string "font", float "size", 
\               int "text_color", int "halo_color", 
\               float "x", float "y", int "align")
{
    C          = (Defined(c) && IsClip(c)) ? c : BlankClip
    s          = Default(s, "# (empty)")
    size       = Default(size, Max(8.0, Min(C.Height/16.0, C.Width/36.0)))
    font       = Default(font, "Courier New")
    text_color = Default(text_color, $80ff80)
    halo_color = Default(halo_color, $333333)
    aln        = Default(align, 7)
    r          = Default(r, C)

    ## x = 8 if align=1,4,7 or none; -1 if align=2,5,8; or width-8 if align=3,6,9
    ## y = size if align=4,5,6 or none; 0 if align=7,8,9; or height-1 if align=1,2,3 
    ## (per Subtitle)
    ax = (aln==3||aln==6||aln==9) ? C.Width-8
    \  : (aln==2||aln==5||aln==8) ? -1
    \  : 8

    ay = (aln==1||aln==2||aln==3) ? C.Height-size
    \  : (aln==7||aln==8||aln==9) ? size/2.0
    \  : C.Height/2.0-size/2.0

    x = Default(x, ax)
    y = Default(y, ay)

    ## remove leading newlines:
    while (Ord(s)==13 || Ord(s)==10) { 
        s = MidStr(s, 2) 
    }

    s = s.ReplaceStr(Chr(10), "\n").ReplaceStr(Chr(13), " ") 

    ## TODO: optionally remove comments

    return IsClip(r) 
    \ ? r.Subtitle42(s, 
    \           font=font, size=size, text_color=text_color, 
    \           halo_color=halo_color, x=x, y=y, align=align, lsp=0)
    \ : IsString(r)
    \   ? C.Subtitle42(s + " = \n'" + R + "'\nlen=" + String(StrLen(R)), 
    \           font=font, size=size, text_color=text_color, 
    \           halo_color=halo_color, x=x, y=y, align=align, lsp=0) 
    \ : (IsBool(r) || IsFloat(r) || IsInt(r))
    \   ? C.Subtitle42(s + " = \n" + String(r), 
    \           font=font, size=size, text_color=text_color, 
    \           halo_color=halo_color, x=x, y=y, align=align, lsp=0) 
    \   : C.Subtitle42(s + " = \n(no valid result)", 
    \           font=font, size=size, text_color=text_color, 
    \           halo_color=halo_color, x=x, y=y, align=align, lsp=0) 
}

##################################
### show a mask clip overlaid on another clip for visualization
##
## @ C - background; RGB & YV411 not accepted
## @ M - mask;       RGB & YV411 not accepted
## @ mode - one of (""|"luma"|"cyan"); default "" (all channels in Add mode)
## @ opacity - cf. [[Overlay]]
##
function ShowMask(clip C, clip M, String "mode", float "opacity")
{
    Assert(!C.IsYV411 && (C.IsYUV||C.IsYUVA), 
    \  "ShowMask: RGB, YV411 not accepted") ## (cf. Overlay)
    Assert(!M.IsYV411 && (M.IsYUV||M.IsYUVA), 
    \  "ShowMask: clip 'M' - RGB, YV411 not accepted") ## (cf. Overlay)
    mode = Default(mode, "")
    opacity = Float(Default(opacity, 0.7))

    MM = CombinePlanes(BlankClip(M), M, M, 
    \        "RGB", "YYY", BitsToPixelType("RGB", C.BitsPerComponent))
    \    .RGBAdjust(2, 2, 2)
    \    .MatchColorFormat(C)

    CY = C.Overlay(MM, mode="blend", opacity=0.4*opacity) 
    CL = C.Overlay(M,  mode="luma",  opacity=0.6*opacity) 
    CA = C.Overlay(M,  mode="add",   opacity=0.9*opacity)

    return (StrCmpi(mode,"cyan")==0) ? CY 
    \    : (StrCmpi(mode,"luma")==0) ? CL 
    \    : CA
}

##################################
### [[#ColorbarsHD2]] with clip properties adjusted to match template 'T'
##
## @ tonedb - level of audio tone in dB; default -18.0
##
function ColorbarsHD2(clip T, float "tonedb")
{
    Assert(T.HasVideo,
    \   "ColorbarsHD2: invalid template clip 'T'")

    ColorbarsHD2(T.Width, T.Height, T.IsRGB, T.BitsPerComponent, tonedb=tonedb)
    \  .MatchColorFormat(T)
    \  .MatchAudioFormat(T)
    \  .AssumeFPS(T)
    return Last
}

##################################
### [[ColorbarsHD]] with optional RGB & deep color output; size & audio level changes
##  (default 1280x720, TV-range, 29.97 fps, 1 hour long, audio tone @ -18dB, 48kz float)
##
## @ width    - default 1280 (ColorbarsHD default was 1288)
## @ height   - default 720
## @ rgb_out  - if true, return full-range RGB32 (8bit) or PlanarRGBA;
##              else (default) return TV-range YV24 (8bit) or YUV444
## @ bits_out - output    bit depth, one of (8|10|12|14|16); default 8
## @ bits_gen - generated bit depth, one of (8|10|12|14|16); default 16 (if rgb_out==true), or bits_out
## @ dither   - if true, add dither when down-converting from 'bits_gen' to 'bits_out'; default false
## @ tonedb   - level of audio tone in dB; default -18.0 (was 0.0)
##
## @ version 1.1 2017-04-28 raffriff42
## @ version 1.2 2017-05-15 add bits_gen, tonedb 
## @ version 1.3 2017-10-07 if rgb_out, set bits_gen==16
##
function ColorbarsHD2(int "width", int "height", bool "rgb_out", 
\               int "bits_out", int "bits_gen", bool "dither", float "tonedb")
{
    wid = Default(width, 1280)
    hgt = Default(height, 720)
    rgb = Default(rgb_out, false)
    bto = Default(bits_out, 8)
    btg = (rgb) ? 16 : Default(bits_gen, bto)
    dth = (Default(dither, false) && (bto < btg)) ? 0 : -1
    tdb = Min(Default(tonedb, -18.0), 0.0)
    
    Assert(bto==8||bto==10||bto==12||bto==14||bto==16,
    \   "ColorbarsHD2: 'bits_out' not one of (8|10|12|14|16)")
    Assert(btg==8||btg==10||btg==12||btg==14||btg==16,
    \   "ColorbarsHD2: 'bits_gen' not one of (8|10|12|14|16)")

    R = ColorbarsHD(wid, hgt, pixel_type=BitsToPixelType("YUV", btg, 444))
    \   .AmplifyDB(tdb)

    R = (rgb==true)  ? R.ConvertToPlanarRGBA(matrix="Rec709") : R
    R = (bto!= btg)  ? R.ConvertBits42(bto, dither=dth) : R    
    R = (bto==8 && rgb==true)  ? R.ConvertToRGB32 : R
    R = (bto==8 && rgb==false) ? R.ConvertToYV24 : R    
    return R 
}

##################################
### return color ramp clip w/ same specs as template clip 'T'
##
## @ T           - determines all properties except colors and Height.
##                 (ramp always generated at 16-bit)
## @ left_color  - any RGB color; default Black
## @ right_color - any RGB color; default White
## @ height      - minimum height = 8; default T.Height
## @ zigs        - if true, 8 pixels on left and right reverse ramp direction;
##                 useful for determining whether clipping has occurred.
##
function ColorRamp(clip T, int "left_color", int "right_color", int "height", bool "zigs")
{
    zig = Default(zigs, false)
    wid = (zig) ? T.Width - 16 : T.Width

    lcc = Default(left_color,  $000000)
    rcc = Default(right_color, $ffffff)
    hgt = Max(8, Default(height, T.Height))

    ## thanks jagabo
    # https://forum.videohelp.com/threads/385341-avisynth-how-to-add-borders#post2498735
    bitn = _nextHiBit(T.BitsPerComponent)
    #T16 = T.ToRGB(bits_out=R41_BITMAX)
    T16 = T.ToRGB(bits_out=bitn)
    StackHorizontal(
    \   BlankClip(T16, width=1, height=hgt, color=lcc),
    \   BlankClip(T16, width=1, height=hgt, color=rcc))

    BilinearResize(2*wid, hgt)

    MatchColorFormat(T, dither=true)

    Crop(wid/2, 0, -wid/2, -0)
    return (!zig) ? Last
    \ : StackHorizontal(
    \       Crop(      0, 0, 8, 0).FlipHorizontal,
    \       Last,
    \       Crop(Width-8, 0, 0, 0).FlipHorizontal
    \   )    
}

##################################
### return color ramp clip w/ same specs as template clip 'T' (any color format)
##
## @ T       - Any color format (8, 10, 12, 14 or 16-bit);
##             determines all properties except colors and Height.
##             (ramp always generated at 16-bit)
## @ left_color  - any RGB color; default Black
## @ right_color - any RGB color; default White
## @ height  - if ontop=false and onside=false, determines resulting clip height; 
##             else determines height (top) or width (side) of ramp; default T.Height
## @ zigs    - if true, 8 pixels on left and right reverse ramp direction;
##             useful for determining whether clipping has occurred.
## @ ontop   - if true, add to top of clip; default false
## @ onside  - if true, rotate and add to right onside; overrides 'ontop'; default false
## @ inset   - if true and ontop or onside = true, 
##             crop the source as required to maintain original size; default false
##
function ColorRampEx(clip T, int "left_color", int "right_color", int "height", 
\                    bool "zigs", bool "ontop", bool "onside", bool "inset")
{
    lcc  = Default(left_color,  $000000)
    rcc  = Default(right_color, $ffffff)
    hgt  = Default(height, T.Height)
    zig  = Default(zigs, false)
    top  = Default(ontop, false)
    side = Default(onside, false)
    inst = Default(inset, false)
#return T.Info

    TR = (side) ? T.TurnLeft : T
    TH = TR.To16bit
#return TH.Info ## source, turned left
#return TR.Info
    
    (T.IsRGB) 
    \ ? ColorRamp(TH,       lcc, rcc, hgt, zig)
    \ : ColorRamp(TH.ToRGB, lcc, rcc, hgt, zig)
    MatchColorFormat(T, dither=true)
    Trim(0, length=1).Loop(T.FrameCount)
#return Last.Info ## ramp only

    ## HACK "Last.Height" because "Height" is arg name
    (top) ? StackVertical(
    \       Last.CropEx(TR.Width, Last.Height, mod=1), 
    \       (inst) ? TR.CropLTRB(0, hgt, 0, 0) : TR
    \ ) 
    \ : (side) ? StackVertical(
    \       Last.CropEx(TR.Width, Last.Height, mod=1), 
    \       (inst) ? TR.CropLTRB(0, hgt, 0, 0) : TR
    \ ) 
    \ : Last
    (side) ? TurnRight : Last
#return Last.Info ## source + ramp on right

    return (top && T.HasAudio) 
    \ ? AudioDub(T) 
    \ : Last
}

##################################
### return grayscale ramp clip w/ same specs as template clip 'T' (alias for [[ColorRampEx]])
##
## @ T      - Any color format (8, 10, 12, 14 or 16-bit);
##            determines all properties except Height. 
## @ height - if 'ontop'=false and 'onside'=false, determines resulting clip height; 
##            else determines height (ontop) or width (onside) of ramp; default T.Height
## @ zigs   - if true, 8 pixels on left and right reverse ramp direction;
##            useful for determining whether clipping has occurred.
## @ ontop  - if true, add to top of clip; default false
## @ onside - if true, rotate and add to right onside; overrides 'ontop'; default false
## @ inset  - if true, crop the source as required to maintain original size; default false
##
function Grayramp(clip T, int "height", bool "zigs", bool "ontop", bool "onside", bool "inset")
{
    return ColorRampEx(T, $000000, $ffffff, height, zigs, ontop, onside, inset)
}

#############################
### YUV/RGB vectorscope with optional audio meters
##
##  Inverted to emulate analog vectorscope;
##  red is top-left and hue increases counter-clockwise
##
## @ C      - YUV(A) or RGB(A); minimum height 260.
##              Note, to expand height to 260 minimum, use something like 
##              | CropEx(Width, Max(260, Height), align=8)
## @ mode   - "color" or "color2"; default "color"
## @ matrix - determines RGB conversion (if needed)
## @ bottom - if true, put scope in lower-right; else (default) put in upper-right
## @ labels - if true (default), add axis labels
## @ marks  - color bar reference mark (graticule) layout: 
##            0=none (default); 1=ColorBars/601; 2=ColorBars/709; 3=ColorbarsHD
## @ audio  - if true and if C.Height >= 384, 
##                add audio levels and lissajous scope below vector scope;
##            else if true and C.Height >= 260, 
##                superimpose lissajous scope over vector.
##            Default false.
##
function Vector2(clip C, string "mode", string "matrix", bool "bottom", 
\               bool "labels", int "marks", bool "audio")
{
    Assert(C.Height>=260,
    \   "Vector2: source clip minimum height = 260")
    matrix = Default(matrix, "Rec601")    
    modes  = Default(mode, "color")    
    bottom = Default(bottom, false)
    labels = Default(labels, true)
    marks  = Default(marks, 0)
    audio  = Default(audio, false)
    bits   = C.BitsPerComponent
    C
    (bits==8) ? Last 
    \ : To8bit
    (C.IsYUV && !C.IsYV411) ? Last 
    \ : ConvertToYV24(matrix=matrix)

    mode = (StrCmpi(modes, "color")==0)  ? 1
    \    : (StrCmpi(modes, "color2")==0) ? 2
    \    : Assert(false,
    \        "Vector2: invalid 'mode' argument")

    PointResize(Height, Height)

    FlipVertical
    (mode==1) ? Histogram("color")
    \         : Histogram("color2")
    Crop(Height, 0, 0, 256)
    FlipVertical

    if (mode==2) {
        ## mode="color2"
        ## brighten up to make faint dots visible:
        ColorYUV(off_y=(-20*15), gain_y=20, f2c=true)
        ColorYUV(gain_y=0.6, cont_v=0, cont_u=0, f2c=true)
    }

    H2=BlankClip(Last)
    \   .Histogram("color2")
    \   .Crop(Width, 0, 0, 256)
    \   .ColorYUV(off_y=(-20*15), gain_y=20, f2c=true)
    \   .ColorYUV(gain_y=0.6, cont_v=0, cont_u=0, f2c=true)
    \   .Trim(0, length=1).Loop(C.FrameCount)
    Tweak(sat=0.5)
    Overlay(H2, mode="lighten", opacity=(mode==1?0.25:1.0))

    if (labels) {
        Lbls = C._vector_labels(colors=1>0)
        Mrks = C._vector_marks(style=marks)
        Overlay(Lbls, mask=Lbls.ExtractA)
        Overlay(Mrks, mask=Mrks.ExtractA, mode="lighten", opacity=0.5)
    }

    if (audio && C.HasAudio && (C.Height-Height)>=128) {
        
        A  = (C.AudioChannels<=2) ? C 
        \  : C.GetChannels(1, 2)
        
        hgt = Max(16, modx(4, 1.33*(C.Height-Height)))
        B = BlankClip(Last, height=hgt).AudioDub(A)
        
        S = B.Histogram("StereoY8")
        \    .CropEx(Width, C.Height-Height, align=5)

        H = B.Histogram("audiolevels")
        \     .CropEx(Width, C.Height-Height, align=8)
        \     .Levelss(0, 1.0, 255, 0, 130, chroma=1>0) 
        \     .Overlay(S, mode="add", opacity=0.7)
        
        (bottom) ? StackVertical(H, Last)
        \        : StackVertical(Last, H)
    } 
    else if (audio && C.HasAudio) {
        S = Histogram("StereoY8")
        OverlayAligned(S, mode="add", align=5, opacity=0.3)
    }
    else {
        (bottom) 
        \  ? AddBorders(0, Max(0, C.Height-Height), 0, 0)
        \  : AddBorders(0, 0, 0, Max(0, C.Height-Height))
    }

    (Height==C.Height) ? Last 
    \ : CropEx(Width, C.Height, align=8)
    MatchColorFormat(C) 
    StackHorizontal(C, Last)
    return Last
}

#############################################
### vectorscope quadrant and (optional) color labels 
## (labels only; no vectorscope; assume vectorscope is flipped vertically)
##
## @ T      - template clip for bit depth, framerate etc
## @ bits   - determines resulting clip size; cf. Histogram:bits; 
##            size = 256 (bits=8, default and fallback); 512 (bits=9); 
##            1024 (bits=10); 2048 (bits=11); 4096 (bits=12) 
## @ colors - if true, label axes plus the six major colors; else axes only (default)
##
## @ returns black clip with labels: RGBA with mask on A channel, no audio
##
## @ Example usage
## | Histogram("color2").Crop(...).FlipVertical
## | Lbls = _vector_labels(...)
## | Overlay(Lbls, mask=Lbls.ExtractA)
##
function _vector_labels(clip T, int "bits", bool "colors")
{
    bits   = Default(bits, 8)
    dims   = (bits==12) ? 4096
    \      : (bits==11) ? 2048
    \      : (bits==10) ? 1024
    \      : (bits==9)  ? 512
    \      : 256
    sc     = Float(dims) / 256  ## scale factor
    sz     = 16 * sc            ## base font size
    szs    = 3*sz/4             ## smaller font size
    colors = Default(colors, false)

    fg = $666666
    bg = $282828

    BlankClip(T, channels=0, audio_rate=0, width=dims, height=dims, 
    \   color=$ff000000, 
    \   pixel_type=BitsToPixelType("RGBA", T.BitsPerComponent))
    
    sz2 = sz/2
    zs2 = szs/2
    sz4 = sz/4

    R = Last
    \ .Subtitle("U+",   x=sc*240-sz2, y=sc*105-sz2, text_color=fg, halo_color=bg, size=sz)
    \ .Subtitle("0°",   x=sc*235-zs2, y=sc*123-zs2, text_color=fg, halo_color=bg, size=szs)
    \ .Subtitle("V+",   x=sc*140-sz2, y=sc* 25-sz2, text_color=fg, halo_color=bg, size=sz)
    \ .Subtitle("90°",  x=sc*135-zs2, y=sc* 10-zs2, text_color=fg, halo_color=bg, size=szs)
    \ .Subtitle("U-",   x=sc* 25-sz2, y=sc*140-sz2, text_color=fg, halo_color=bg, size=sz)
    \ .Subtitle("180°", x=sc* 20-szs, y=sc*120-zs2, text_color=fg, halo_color=bg, size=szs)
    \ .Subtitle("V-",   x=sc*132-sz2, y=sc*230-sz2, text_color=fg, halo_color=bg, size=sz)
    \ .Subtitle("270°", x=sc*132-szs, y=sc*245-zs2, text_color=fg, halo_color=bg, size=szs)
    
    R = (!colors) ? R : R
    \ .Subtitle("B", x=sc*205-sz4, y=sc*110-sz2, text_color=$4c4cff, halo_color=bg, size=sz)
    \ .Subtitle("M", x=sc*165-sz4, y=sc* 40-sz2, text_color=$bc4cbc, halo_color=bg, size=sz)
    \ .Subtitle("R", x=sc* 75-sz4, y=sc* 40-sz2, text_color=$ff4c4c, halo_color=bg, size=sz)
    \ .Subtitle("Y", x=sc* 45-sz4, y=sc*145-sz2, text_color=$a3a351, halo_color=bg, size=sz)
    \ .Subtitle("G", x=sc* 70-sz4, y=sc*225-sz2, text_color=$4cb04c, halo_color=bg, size=sz)
    \ .Subtitle("C", x=sc*170-sz4, y=sc*230-sz2, text_color=$66b0b0, halo_color=bg, size=sz)

    ## alpha: raise halo_color+4 -> white
    A = R.ExtractG.Levels(0, 1.0, R.sc8x($24), 0, R.sc8x($ff), coring=false)
    R = R.AddAlphaPlane42(A)

    return R.Trim(0, length=1).Loop(T.Framecount) 
}

#############################################
### vectorscope graticule marks 
## (marks only; no vectorscope; assume vectorscope is flipped vertically)
## (marks NOT in final position, pending further testing on multiple systems)
##
## @ T      - template clip for bit depth, framerate etc
## @ bits   - determines resulting clip size; cf. Histogram:bits; 
##            size = 256 (bits=8, default and fallback); 512 (bits=9); 
##            1024 (bits=10); 2048 (bits=11); 4096 (bits=12)
## @ style  - color bar reference mark (graticule) layout: 
##            0=none (default); 1=ColorBars/601; 2=ColorBars/709; 3=ColorbarsHD
##
## @ returns black clip with labels: RGBA with mask on A channel, no audio
##
## @ Example usage
## | Histogram("color2").Crop(...).FlipVertical
## | Mrks = _vector_marks(...)
## | Overlay(Mrks, mask=Mrks.ExtractA, mode="lighten", opacity=0.5)
##
function _vector_marks(clip T, int "bits", int "style")
{
    bits   = Default(bits, 8)
    style  = Max(0, Default(style, 0))
    dims   = (bits==12) ? 4096
    \      : (bits==11) ? 2048
    \      : (bits==10) ? 1024
    \      : (bits==9)  ? 512
    \      : 256
    sc     = Float(dims) / 256  ## scale factor
    sz     = 16 * sc            ## base font size
    szb    = 3  * sz            ## bigger font size

    ## colors optimized for use with example in description
    fg = $bfbfbf
    bg = $282828

    BlankClip(T, channels=0, audio_rate=0, width=dims, height=dims, 
    \   pixel_type=BitsToPixelType("RGBA", T.BitsPerComponent))

    fnt = "Times New Roman"
    ch  = "¤"
    sz3 = szb/3
    sz4 = szb/4
    sz5 = szb/5

    bluX = 0.5*sc*Select(style, 0, 399, 399, 424, 426)-sz5
    magX = 0.5*sc*Select(style, 0, 351, 367, 386, 366)-sz5
    redX = 0.5*sc*Select(style, 0, 207, 220, 216, 200)-sz5
    yelX = 0.5*sc*Select(style, 0, 110, 111,  86,  86)-sz5
    grnX = 0.5*sc*Select(style, 0, 159, 143, 124, 144)-sz5
    cynX = 0.5*sc*Select(style, 0, 304, 289, 294, 310)-sz5
    ##                          0   1    2    3    4 (4=experimental HSL)

    bluY = 0.5*sc*Select(style, 0, 262, 253, 254, 264)-sz3
    magY = 0.5*sc*Select(style, 0, 116, 108,  84,  98)-sz3
    redY = 0.5*sc*Select(style, 0,  92,  94,  68,  70)-sz3
    yelY = 0.5*sc*Select(style, 0, 212, 224, 220, 210)-sz3
    grnY = 0.5*sc*Select(style, 0, 356, 367, 390, 376)-sz3
    cynY = 0.5*sc*Select(style, 0, 382, 381, 404, 404)-sz3
    ##                          0   1    2     3   4 (4=experimental HSL)

    ## B, M, R, Y, G, C
    R = (style==0) ? Last : Last
    \ .Subtitle(ch, font=fnt, x=bluX, y=bluY, text_color=fg, halo_color=bg, size=szb)
    \ .Subtitle(ch, font=fnt, x=magX, y=magY, text_color=fg, halo_color=bg, size=szb)
    \ .Subtitle(ch, font=fnt, x=redX, y=redY, text_color=fg, halo_color=bg, size=szb)
    \ .Subtitle(ch, font=fnt, x=yelX, y=yelY, text_color=fg, halo_color=bg, size=szb)
    \ .Subtitle(ch, font=fnt, x=grnX, y=grnY, text_color=fg, halo_color=bg, size=szb)
    \ .Subtitle(ch, font=fnt, x=cynX, y=cynY, text_color=fg, halo_color=bg, size=szb)

    ## alpha: raise halo_color+4 -> white
    A = R.ExtractG.Levels(0, 1.0, R.sc8x($24), 0, R.sc8x($aa), coring=false)
    R = R.AddAlphaPlane42(A)

    return R.Trim(0, length=1).Loop(T.Framecount) 
}

##################################
### Classic [[Histogram]], waveform on top (or on bottom); supports RGB
### many little enhancements; accepts both YUV & RGB
##
## @ parade - if true (default), show RGB waveforms side-by-side;
##            else, show RGB waveforms superimposed 
## @ shrink - if true, shrink clip+waveform & add side borders so output size = input
##            if false (default), height increases by R41_HISTX px 
## @ bottom - if true, put histogram below video (default false)
## @ turn   - if true (default), turn histogram 90 deg left
##
function HistogramTurn(clip C, bool "parade", bool "shrink", bool "bottom", bool "turn")
{
    Assert(C.Height>=260,
    \   "HistogramTurn: source clip minimum height = 260")
    parade = Default(parade, true)
    shrink = Default(shrink, false)
    bottom = Default(bottom, false)
    turn   = Default(turn, true)

    return C.ScopeR(shrink=shrink, vector=false, parade=parade, bottom=bottom, turn=turn)   
}

# fka VideoScopes
# http://forum.videohelp.com/threads/381327-Free-vectorscope-for-windows-64-bit?p=2467250#post2467250
##################################
### show video waveform + vectorscope; many little enhancements; accepts both YUV & RGB
##  (superceded for YUV sources by [[ScopeY]], which is faster and simpler to use)
##  (this routine is called by ScopeY and HistogramTurn)
##
## @ shrink - if true, shrink clip+scopes & add side borders so output size = input;
##            if false (default), height increases by R41_HISTX px 
## @ vector - if true, show Histogram("color2") (inverted emulate analog vectorscope)
## @ matrix - if source is RGB and 'vector'=true, use this matrix; default "Rec709"
##            otherwise 'matrix' is ignored (does not affect waveform or main image)
## @ parade - if true, show RGB waveforms side-by-side;
##            else (default), show RGB waveforms superimposed
## @ bottom - if true and 'turn'==true, put scopes below video (default false)
## @ mode   - vectorscope mode, "color" or "color2"; default "color"
## @ labels - if true (default), add axis labels
## @ marks  - color bar reference mark (graticule) layout: 
##            0=none (default); 1=ColorBars/601; 2=ColorBars/709; 3=ColorbarsHD
## @ audio  - if true, add audio levels and lissajous meters
## @ turn   - if true (default), turn histogram 90 deg left
##
## version 2017-05-09 support RGB, deep color
## version 2017-05-18 matrix argument
##
function ScopeR(clip C, bool "shrink", bool "vector", string "matrix", 
\               bool "parade", bool "bottom", string "mode", 
\               bool "labels", int "marks", bool "audio", bool "turn")
{
    Assert(C.Height>=260,
    \   "ScopeR: source clip minimum height = 260")
    shrink = Default(shrink, false)
    vector = Default(vector, false)
    matrix = Default(matrix, "Rec709")
    parade = Default(parade, false)
    bottom = Default(bottom, false)
    mode   = Default(mode, "color")    
    labels = Default(labels, true)
    marks  = Default(marks, 0)
    audio  = Default(audio, false)
    turn   = Default(turn, true)

    Assert(shrink==false || (C.Width>=360 && C.Height>=360), 
    \   "ScopeR: source must be at least 360x360 for shrink mode") 

    mode = (StrCmpi(mode, "color")==0)  ? mode
    \    : (StrCmpi(mode, "color2")==0) ? mode
    \    : Assert(!vector,
    \        "ScopeR: invalid 'mode' argument")

    bits = C.BitsPerComponent
    wid  = C.Width
    hgt  = C.Height
    dth  = (bits>8 && bits<32) ? 0 : -1    
    C    = (!shrink) ? C
    \      : C.ScaleSize(C.CalcWidth(hgt-R41_HISTX, 4), hgt-R41_HISTX, 2)

    R = (bits==8)
    \ ? (C.IsRGB) 
    \   ? C.KillAudio
    \      ._TurnRightIf(turn)
    \      ._HistRGB(parade)
    \      .Levels(24, 2.5, 235, 0, 255, coring=false)
    \      ._TurnLeftIf(turn)
    \      .MatchColorFormat(C)
    \   : C.KillAudio
    \      ._TurnRightIf(turn)
    \      ._Hist2
    \      .Levels(24, 2.5, 235, 0, 255, coring=false)
    \      ._TurnLeftIf(turn)
    \ : (C.IsRGB) 
    \   ? C.KillAudio
    \      .ConvertBits42(8, dither=dth)
    \      ._TurnRightIf(turn)
    \      ._HistRGB(parade)
    \      .Levelss(24, 2.5, 235, 0, 255, coring=false)
    \      ._TurnLeftIf(turn)
    \      .ConvertBits42(bits).MatchColorFormat(C) 
    \   : C.KillAudio
    \      .ConvertBits42(8, dither=dth)
    \      ._TurnRightIf(turn)
    \      ._Hist2
    \      .Levelss(24, 2.5, 235, 0, 255, coring=false)
    \      ._TurnLeftIf(turn)
    \      .ConvertBits42(bits)

    R = (turn)
    \ ? (bottom) 
    \    ? StackVertical(C, R)
    \    : StackVertical(R, C)
    \ : StackHorizontal(C, R)

    V = (vector)
    \ ? C.Vector2(mode, matrix, labels=labels, marks=marks, audio=audio)
    \    .Crop(C.Width, 0, 0, Min(C.Height, 256))
    \ : Nop

    R = (vector) 
    \ ? R.StackHorizontal(
    \       V.CropEx(V.Width, R.Height, align=(bottom?1:7)) )
    \ : R

    R = (shrink) 
    \ ? R.CropEx(wid, hgt) 
    \ : R

    return (C.HasAudio)
    \ ? R.AudioDub(C) 
    \ : R

    ###################################
    function _TurnLeftIf(clip C, bool b)
    {
        return (b) ? C.TurnLeft : C
    }
    ###################################
    function _TurnRightIf(clip C, bool b)
    {
        return (b) ? C.TurnRight : C
    }

}

#######################################
### Augmented [[Histogram]]; reduce or eliminate high, low and center highlighting;
### no effect if any explicit 'legacy' 'mode' argument is specified.
##
## @ mode       - one of (classic2|classic2f|classic|levels|color|color2); default 'classic2f')
## @ factor     - only valid with 'mode'='levels'; see [[Histogram]]
## @ keepsource - if true, add to right side of picture like classic Histogram;
##                else (default), return only the histogram (right-most R41_HISTX pixels)
##
## version 1.1 - faster 'classic2f' mode by default
## version 1.2 - mode 'classic2' now same as 'classic2f'
## version 1.3 - 'keepsource'
##
function _Hist2(clip C, string "mode", float "factor", int "tvrange_offset", bool "keepsource")
{
    Assert(C.IsYUV || C.IsYUVA,
    \   "_Hist2: source must be YUV(A)")
    mode  = Default(mode, "classic2f")
    aln   = 0>0 ## crop align (no noticeable effect on speed)
    off   = Default(tvrange_offset, 0)
    keep  = Default(keepsource, false)

    H = (mode=="levels") 
    \ ? C.Histogram(mode, factor)
    \ : C.Histogram(mode) 

    R = (mode=="classic2") 
    \ ? (H.Is444) ? H : H.ConvertToYV24 [* cropping by odd numbers *]
    \ : H

    R = (mode=="classic2" || mode=="classic2f") ? StackHorizontal(
    \       R.Crop(C.Width, 0, 16, 0, aln)                         [* low zone    *]
    \        .ColorYUV(off_y=(-56+off), off_u=(128-20), off_v=(128-160))           
    \        .AddBorders(4, 0, 0, 0),
    \       R.Crop(C.Width+16, 0, 220, 0, aln).Grayscale,          [* mid         *]
    \       R.Crop(C.Width+236, 0, 20, 0, aln)                     [* high zone   *]
    \        .ColorYUV(off_y=(-56+off), off_u=(128-20), off_v=(128-160))
    \        .AddBorders(0, 0, 4, 0)
    \   )
    \ : H
    global R41_HISTX = 264 ## 256+8: 2 borders, 4px each

    return (mode=="classic2" || mode=="classic2f") 
    \ ? (keep) ? StackHorizontal(C, R) : R
    \ : (keep) ? H : H.Crop(0, 0, C.Width, 0, aln)
}

#############################
### classic Histogram for RGB
##
## @ parade     - if true, show RGB waveforms side-by-side;
##                else, show RGB waveforms superimposed  (default true)
## @ keepsource - if true, add to right side of picture like classic Histogram;
##                else (default), return only the histogram (right-most R41_HISTX pixels)
##
## version 1.3 - 'keepsource'
##
function _HistRGB(clip C, bool "parade", bool "keepsource")
{
    Assert(C.IsRGB,
    \   "_HistRGB: source must be RGB")
    parade = Default(parade, true)
    keep   = Default(keepsource, false)

    R = C.ExtractR._Hist2(mode="classic2", tvrange_offset=-8, keepsource=keep) 
    G = C.ExtractG._Hist2(mode="classic2", tvrange_offset=-8, keepsource=keep)
    B = C.ExtractB._Hist2(mode="classic2", tvrange_offset=-8, keepsource=keep)

    R = (!parade) ? R : R.BicubicResize(R.Width, m4(R.Height/3.0))
    G = (!parade) ? G : G.BicubicResize(G.Width, m4(G.Height/3.0))
    B = (!parade) ? B : B.BicubicResize(B.Width, m4(B.Height/3.0))

    R = R.Levels(0, 1.0, 230, 0, 255, coring=false)
    B = B.Levels(8, 1.0, 180, 0, 255, coring=false)

    h = C.Height-R.Height
    R = (!parade) ? R : R.AddBorders(0, 0,   0, h)
    G = (!parade) ? G : G.AddBorders(0, h/2, 0, h-h/2)
    B = (!parade) ? B : B.AddBorders(0, h,   0, 0)

    return CombinePlanes(R, G, B, "RGB", source_planes="YYY", 
    \           pixel_type=BitsToPixelType("RGB", C.BitsPerComponent))
    \      .RGBAdjust(b=2.0, bb=-10)
}

##################################
### Simple waveform + vectorscope. Accepts 8-bit, YUV(A) only.
##
## @ shrink - if true, shrink clip+scopes & add borders so output size = input (within range 360_1440);
##            if false (default), height increases by R41_HISTX px 
## @ vector - if true (default), show Histogram("color2") (inverted to emulate analog vectorscope) 
## @ levels - if true, show Histogram("levels", 1.0); default false.
## @ bottom - if true, put scopes below video (default false)
## @ mode   - vectorscope mode, "color" or "color2"; default "color"
## @ labels - if true (default), add axis labels
## @ marks  - color bar reference mark (graticule) layout: 
##            0=none (default); 1=ColorBars/601; 2=ColorBars/709; 3=ColorbarsHD
## @ audio  - if true, add audio levels and lissajous meters
##
## * Smaller heights are faster to process; scopes look relatively bigger; 
##   (at height=512, scopes occupy the bottom half of the output; at 720, about 1/3; at 1080, 1/4)
##
function ScopeY(clip C, bool "shrink", bool "vector", bool "levels",  
\               bool "bottom", string "mode", bool "labels", int "marks", 
\               bool "audio")
{
    Assert(IsClip(C) && (C.IsYUV || C.IsYUVA), 
    \   "ScopeY: source must be YUV(A)")
    Assert(!C.IsYV411 || !levels, 
    \  "ScopeY: YV411 not accepted with 'levels argument")
    Assert(C.Height>=260,
    \   "ScopeY: source clip minimum height = 260")
    
    shrink = Default(shrink, false)
    vector = Default(vector, true)
    levels = Default(levels, false)
    bottom = Default(bottom, false)
    mode   = Default(mode, "color")    
    labels = Default(labels, true)
    marks  = Default(marks, 0)
    audio  = Default(audio, false)

    Assert(C.Width>=96 && C.Height>=96, 
    \   "ScopeY: source must be at least 96x96") 
    Assert(shrink==false || (C.Width>=360 && C.Height>=360), 
    \   "ScopeY: source must be at least 360x360 for shrink mode") 
    cwid = C.Width
    chgt = C.Height
    C 

    mode = (StrCmpi(mode, "color")==0)  ? mode
    \    : (StrCmpi(mode, "color2")==0) ? mode
    \    : Assert(!vector,
    \        "ScopeY: invalid 'mode' argument")

    shgt = chgt - R41_HISTX
    (shrink) 
    \ ? ScaleSize(CalcWidth(shgt, 4), shgt, 2).Sharpen(0.5)
    \ : Last

    L=Histogram("levels", 1.0)
    \ .Crop(Last.Width, 0, 0, 256)
    \ .Tweak(sat=0.5, cont=0.7)

    ScopeR(shrink=false, vector=false, bottom=bottom)   

    ## if bottom=true or levels=true, put vscope on bottom
    (!vector) 
    \ ? (!levels) 
    \     ? Last 
    \     : AddBorders(0, 0, R41_HISTX, 0) 
    \ : Vector2(mode, bottom=(bottom||levels), 
    \           labels=labels, marks=marks, audio=audio)

    ## if bottom=true and vector=false, put levels on bottom
    (!levels) 
    \ ? Last 
    \ : OverlayAligned(L, align=(bottom && !vector)?3:9)

    (shrink) 
    \ ? CropEx(cwid, chgt) 
    \ : Last
    return Last
}

##################################
### print color channel statistics on the screen
## (auto switch between RGBAdjust(analyze=true) and ColorYUV(analyze=true)
## (AVS+ 8, 10, 12, 14, 16 bit; no float as of r2455)
##
## @ format - nicer formatting; cf. [[#AnalyzeFmt]]
##
function Analyze(clip C, bool "format")
{
    fmt = Default(format, false)
    bits = C.BitsPerComponent
    Assert(bits<32 || fmt==false,
    \   "Analyze(format=true): 8|10|12|14|16 bits only")
    return (fmt) 
    \ ? C.AnalyzeFmt(chroffset=false)
    \ : (C.IsRGB) 
    \   ? C.RGBAdjust(analyze=true) 
    \   : C.ColorYUV(analyze=true)
}

##################################
### print color channel statistics on the screen 
## (like [[ColorYUV]] or [[RGBAdjust]] w/ analyze=true, but reformatted)
##
## @ C - bits depths 8-16 (float not correctly formatted currently)
## @ left, top, width, height - set the sample window; 
##                by default, sample entire frame; minimum size 8x8;
##                if any value is set, 'draftmode' is disabled.
##                (resulting clip will be dimmed outside the window)
## @ text_color - cf. Subtitle; default light green
## @ halo_color - cf. Subtitle; default black
## @ fontsize   - cf. Subtitle; default Height/20
## @ chroffset  - if true (default), chroma zero = 128d (zero saturation)
## @ draftmode  - if true, process at half size; default false
##
## Note: due to use of global variables,
## all AnalyzeFmt instances share common optional arguments
## (unless wrapped in [[ScriptClip]])
##
function AnalyzeFmt(clip C, int "left", int "top", int "width", int "height",
\                   int "text_color", int "halo_color", float "fontsize", 
\                   bool "chroffset", bool "draftmode")
{
    Assert(C.Height>=80,
    \   "AnalyzeFmt: source clip minimum height = 80")
    minwinx = 8
    minwiny = 8
    Lw = Default(left,   -1)
    Tw = Default(top,    -1)
    Ww = Default(width,  -1)
    Hw = Default(height, -1)
    bb = (Lw>=0 || Tw>=0 || Ww>=0 || Hw>=0) ## true if any value is set
    global analyzef_Lw = (!bb) ? 0 : Min(Max(0, Lw), C.Width-minwinx)
    global analyzef_Tw = (!bb) ? 0 : Min(Max(0, Tw), C.Height-minwiny)
    global analyzef_Ww = (!bb) ? C.Width  : Min(Max(minwinx, Ww), C.Width-Max(0, Lw))
    global analyzef_Hw = (!bb) ? C.Height : Min(Max(minwiny, Hw), C.Height-Max(0, Tw))
    global analyzef_bb = bb
    global analyzef_d  = (bb) ? false : Default(draftmode,  false)
    global analyzef_t = Default(text_color, $40ff40)
    global analyzef_h = Default(halo_color, $0)
    global analyzef_z = Default(fontsize,   Max(8, C.Height/20.0))
    global analyzef_o = Default(chroffset,  true)

    C
    (analyzef_d) 
    \ ? BicubicResize(modx(4, 0.5*Width), modx(4, 0.5*Height))
    \ : Last 
    (IsRGB) 
    \ ? _analyzeRGB
    \ : _analyzeYUV
    (analyzef_d) 
    \ ? BicubicResize(C.Width, C.Height)
    \ : Last 
    return Last

    function _analyzeRGB(clip C)
    {
        C
        Assert(IsRGB, "_analyzeRGB: RGB/RGBA sources only")
        (IsInterleaved42) ? ConvertToPlanarRGBA : Last
        ScriptClip(Last, """
            t   = analyzef_t
            h   = analyzef_h
            z   = analyzef_z
            z   = (analyzef_d) ? z/2 : z 
            n   = "\n"
            s0  = "%0.0f"
            s2  = "%0.2f"
            bb  = analyzef_bb

            CC  = (!bb) ? Last
            \   : CropLTWH(analyzef_Lw, analyzef_Tw, analyzef_Ww, analyzef_Hw)

            (!bb) ? Last
            \   : Levelss(0, 1.0, 255, 48, 255-92, chroma=true)
            \     .Overlay(CC, x=analyzef_Lw, y=analyzef_Tw)

            s =n+"average = " 
            \ +n+"median  = " 
            \ +n+"minimum = " 
            \ +n+"maximum = " 
            \ +n+"99% min = " 
            \ +n+"99% max = " 
            \ +n+ ((!bb) ? "" 
            \     :  "window: Left="+String(analyzef_Lw)
            \     +", Top="+String(analyzef_Tw)
            \     +", Wid="+String(analyzef_Ww)
            \     +", Hgt="+String(analyzef_Hw))
 
            Subtitle42(s, font="Courier New", x=z/2, y=z/2, lsp=0,
            \       text_color=t, halo_color=h, size=z)

            s = "R"
            \ +n+String(CC.AverageR,           s2) 
            \ +n+String(CC.RPlaneMedian,       s2) 
            \ +n+String(CC.RPlaneMin,          s0) 
            \ +n+String(CC.RPlaneMax,          s0) 
            \ +n+String(CC.RPlaneMin(1.0/256), s0) 
            \ +n+String(CC.RPlaneMax(1.0/256), s0) 
            Subtitle42(s, font="Courier New", x=z*7, y=z/2, lsp=0,
            \       text_color=t, halo_color=h, size=z)

            s = "G"
            \ +n+String(CC.AverageG,           s2) 
            \ +n+String(CC.GPlaneMedian,       s2) 
            \ +n+String(CC.GPlaneMin,          s0) 
            \ +n+String(CC.GPlaneMax,          s0) 
            \ +n+String(CC.GPlaneMin(1.0/256), s0) 
            \ +n+String(CC.GPlaneMax(1.0/256), s0) 
            Subtitle42(s, font="Courier New", x=z*14, y=z/2, lsp=0,
            \       text_color=t, halo_color=h, size=z)

            s = "B"
            \ +n+String(CC.AverageB,           s2) 
            \ +n+String(CC.BPlaneMedian,       s2) 
            \ +n+String(CC.BPlaneMin,          s0) 
            \ +n+String(CC.BPlaneMax,          s0) 
            \ +n+String(CC.BPlaneMin(1.0/256), s0) 
            \ +n+String(CC.BPlaneMax(1.0/256), s0) 
            Subtitle42(s, font="Courier New", x=z*21, y=z/2, lsp=0,
            \       text_color=t, halo_color=h, size=z)
        """)
        (C.IsInterleaved42) ? MatchColorFormat(C) : Last
        return Last
    }

    function _analyzeYUV(clip C)
    {
        C
        Assert(!IsRGB, "_analyzeYUV: YUV/YUVA/Y sources only")
        (IsInterleaved42) ? ConvertToYUV422 : Last
        ScriptClip(Last, """
            t   = analyzef_t
            h   = analyzef_h
            z   = analyzef_z
            z   = (analyzef_d) ? z/2 : z 
            n   = "\n"
            s0  = "%0.0f"
            s2  = "%0.2f"
            s_0 = (analyzef_o) ? "%+0.0f" : "%0.0f"
            s_2 = (analyzef_o) ? "%+0.2f" : "%0.2f"
            off = (analyzef_o) ? sc8x(128) : 0
            bb  = analyzef_bb

            CC  = (!bb) ? Last
            \   : CropLTWH(analyzef_Lw, analyzef_Tw, analyzef_Ww, analyzef_Hw)

            (!bb) ? Last
            \   : Levelss(0, 1.0, 255, 48, 255-92, chroma=true)
            \     .Overlay(CC, x=analyzef_Lw, y=analyzef_Tw)

            s =n+"average  = " 
            \ +n+"median   = " 
            \ +n+"minimum  = " 
            \ +n+"maximum  = " 
            \ +n+"99% min  = " 
            \ +n+"99% max  = " 
            if (!IsY) {
                s=s+n+"99% diff = "
            }
            s=s+n+ ((!bb) ? "" 
            \     :  "window: Left="+String(analyzef_Lw)
            \     +", Top="+String(analyzef_Tw)
            \     +", Wid="+String(analyzef_Ww)
            \     +", Hgt="+String(analyzef_Hw))

            Subtitle42(s, font="Courier New", x=z/2, y=z/2, lsp=0,
            \       text_color=t, halo_color=h, size=z)

            s = "Y"
            \ +n+String(CC.AverageLuma,        s2) 
            \ +n+String(CC.YPlaneMedian,       s2) 
            \ +n+String(CC.YPlaneMin,          s0) 
            \ +n+String(CC.YPlaneMax,          s0) 
            \ +n+String(CC.YPlaneMin(1.0/256), s0) 
            \ +n+String(CC.YPlaneMax(1.0/256), s0) 
            \ +n+"n/a"
            Subtitle42(s, font="Courier New", x=z*7, y=z/2, lsp=0,
            \       text_color=t, halo_color=h, size=z)

            if (!IsY) {
                s = "U"
                \ +n+String(CC.AverageChromaU-off,     s_2) 
                \ +n+String(CC.UPlaneMedian-off,       s_2) 
                \ +n+String(CC.UPlaneMin-off,          s_0) 
                \ +n+String(CC.UPlaneMax-off,          s_0) 
                \ +n+String(CC.UPlaneMin(1.0/256)-off, s_0) 
                \ +n+String(CC.UPlaneMax(1.0/256)-off, s_0) 
                \ +n+String(CC.UPlaneMinMaxDifference(1.0/256), s_0) 
                Subtitle42(s, font="Courier New", x=z*14, y=z/2, lsp=0,
                \       text_color=t, halo_color=h, size=z)

                s = "V"
                \ +n+String(CC.AverageChromaV-off,     s_2) 
                \ +n+String(CC.VPlaneMedian-off,       s_2) 
                \ +n+String(CC.VPlaneMin-off,          s_0) 
                \ +n+String(CC.VPlaneMax-off,          s_0) 
                \ +n+String(CC.VPlaneMin(1.0/256)-off, s_0) 
                \ +n+String(CC.VPlaneMax(1.0/256)-off, s_0) 
                \ +n+String(CC.VPlaneMinMaxDifference(1.0/256), s_0) 
                Subtitle42(s, font="Courier New", x=z*21, y=z/2, lsp=0,
                \       text_color=t, halo_color=h, size=z)
            }
        """)
        (C.IsInterleaved42) ? MatchColorFormat(C) : Last
        return Last
    }
}

##################################
### like [[#AnalyzeFmt]], but for a single channel (Y,R,G,B,A)
##
## @ C - bits depths 8-16 (float not correctly formatted currently)
## @ label      - short channel identifier 
## @ enable     - if true, show analysis, else show label only
## @ text_color - cf. Subtitle; default 62% gray
## @ halo_color - cf. Subtitle; default black
## @ fontsize   - cf. Subtitle; default Height/12
## @ draftmode  - if true, process at half size; default false
##
## Note stats labeled "99%" actually 99.6% (255/256) 
##
## Note: due to use of global variables,
## all AnalyzeY instances share common optional arguments
## (unless wrapped in [[ScriptClip]])
##
function AnalyzeY(clip C, string label, bool enable,
\                 int "text_color", int "halo_color", 
\                 float "fontsize", bool "draftmode")
{
    global analyzey_t = Default(text_color, $9F9F9F)
    global analyzey_h = Default(halo_color, $0)
    global analyzey_z = Default(fontsize,   Max(8, C.Height/12.0))
    global analyzey_d = Default(draftmode,  false)

    C
    (analyzey_d) 
    \ ? BicubicResize(modx(4, 0.5*Width), modx(4, 0.5*Height))
    \ : Last 
    (!enable) ? Last : ScriptClip(Last, """
        t  = analyzey_t
        h  = analyzey_h
        z  = analyzey_z
        z  = (analyzey_d) ? z/2 : z 
        n  = "\n"
        s0 = "%0.0f"
        s2 = "%0.2f"

        s =  String(AverageLuma,        "average = " + s2) 
        \ +n+String(YPlaneMedian,       "median  = " + s2) 
        \ +n+String(YPlaneMin,          "minimum = " + s0) 
        \ +n+String(YPlaneMax,          "maximum = " + s0) 
        \ +n+String(YPlaneMin(1.0/256), "99%% min = " + s0) 
        \ +n+String(YPlaneMax(1.0/256), "99%% max = " + s0) 

        Subtitle42(s, font="Courier New", x=z/2, y=1.5*z, lsp=0,
        \          text_color=t, halo_color=h, size=z)
    """)
    z = analyzey_z
    z = (analyzey_d) ? z/2 : z 
    Subtitle42(label, font="Courier New", x=z/2, y=z/2,
    \  text_color=analyzey_t, halo_color=analyzey_h, size=z)
    (analyzey_d) 
    \ ? BicubicResize(C.Width, C.Height)
    \ : Last 
    return Last
}

##################################
### like [[#AnalyzeFmt]], but for a single channel & relative to midscale (U,V)
##
## @ C - bits depths 8-16 (float not correctly formatted currently)
## @ label      - short channel identifier 
## @ enable     - if true, show analysis, else show label only
## @ text_color - cf. Subtitle; default 62% gray
## @ halo_color - cf. Subtitle; default black
## @ fontsize   - cf. Subtitle; default Height/12
## @ chroffset  - if true (default), chroma zero = 128d (zero saturation)
## @ draftmode  - if true, process at half size; default false
##
## Note stats labeled "99%" actually 99.6% (255/256) 
##
## Note: due to use of global variables,
## all AnalyzeUV instances share common optional arguments
## (unless wrapped in [[ScriptClip]])
##
function AnalyzeUV(clip C, string label, bool enable,
\                 int "text_color", int "halo_color", float "fontsize", 
\                 bool "chroffset", bool "draftmode")
{
    global analyzeu_t = Default(text_color, $9F9F9F)
    global analyzeu_h = Default(halo_color, $0)
    global analyzeu_z = Default(fontsize,   Max(8, C.Height/12.0))
    global analyzeu_o = Default(chroffset,  true)
    global analyzeu_d = Default(draftmode,  false)

    C
    (analyzeu_d) 
    \ ? BicubicResize(modx(4, 0.5*Width), modx(4, 0.5*Height))
    \ : Last 
    (!enable) ? Last : ScriptClip(Last, """
        t   = analyzeu_t
        h   = analyzeu_h
        z   = analyzeu_z
        z   = (analyzeu_d) ? z/2 : z 
        n   = "\n"
        s_0 = (analyzeu_o) ? "%+0.0f" : "%0.0f"
        s_2 = (analyzeu_o) ? "%+0.2f" : "%0.2f"
        off = (analyzeu_o) ? sc8x(128) : 0

        s =  String(AverageLuma-off,        "average  = " + s_2) 
        \ +n+String(YPlaneMedian-off,       "median   = " + s_2) 
        \ +n+String(YPlaneMin-off,          "minimum  = " + s_0) 
        \ +n+String(YPlaneMax-off,          "maximum  = " + s_0) 
        \ +n+String(YPlaneMin(1.0/256)-off, "99%% min  = " + s_0) 
        \ +n+String(YPlaneMax(1.0/256)-off, "99%% max  = " + s_0) 
        \ +n+String(YPlaneMinMaxDifference(1.0/256), "99%% diff = " + s_0) 

        Subtitle42(s, font="Courier New", x=z/2, y=1.5*z, lsp=0,
        \         text_color=t, halo_color=h, size=z)
    """)
    z = analyzeu_z
    z = (analyzeu_d) ? z/2 : z 
    Subtitle42(label, font="Courier New", x=z/2, y=z/2,
    \  text_color=analyzeu_t, halo_color=analyzeu_h, size=z)
    (analyzeu_d) 
    \ ? BicubicResize(C.Width, C.Height)
    \ : Last 
    return Last
}

##################################
### show original & 3 channels (Y, U, V or R, G, B) in quad split
## if RGB:
##    C (full color) & G channel on top, 
##    with B & R below
## if YUV:
##    C (full color) & Y channel on top, 
##    with U & V below
##
## @ analyze   - if true, print color channel statistics like [[#AnalyzeFmt]]
## @ uinvert   - (YUV mode) if true (default), show 'U' channel inverted 
##               so warm colors always brighter, cool colors darker
## @ chroffset - (YUV mode) if true (default), chroma zero = 128d (zero saturation)
##
function ShowChannelsQuad(clip C, bool "analyze", bool "uinvert", bool "chroffset")
{
    Assert(!C.IsY, "ShowChannelsQuad: RGB/RGBA/YUV/YUVA sources only")
    analyze   = Default(analyze, false)
    uinvert   = Default(uinvert, true)
    chroffset = Default(chroffset,  true)

    return (C.IsRGB) 
    \ ? C._showChannelsRGB(analyze) 
    \ : C._showChannelsYUV(analyze, uinvert, chroffset)

    ##################################
    ### show quad split 
    ###  C (full color) & G channel on top, 
    ### with B & R below
    ##
    function _showChannelsRGB(clip C, bool "analyze")
    {
        Assert(C.IsRGB,
        \   "ShowChannelsRGB: source must be RGB")
        alyz = Default(analyze, false)
        size = Max(8, C.Height/20.0)

        C
        wid2 = modx(2, 0.5*Width)
        hgt2 = modx(2, 0.5*Height)

        (IsInterleaved42) ? ConvertToPlanarRGBA : Last
        BicubicResize(wid2, hgt2)

        G = ExtractG.AnalyzeY("G", alyz, fontsize=size)
        \           .MatchColorFormat(Last)
        R = ExtractR.AnalyzeY("R", alyz, fontsize=size)
        \           .MatchColorFormat(Last)
        B = ExtractB.AnalyzeY("B", alyz, fontsize=size)
        \           .MatchColorFormat(Last)

        StackVertical(
        \   StackHorizontal(Last, G),
        \   StackHorizontal(B,    R))
        (C.IsInterleaved42) ? MatchColorFormat(C) : Last
        PointResize(C.Width, C.Height, 0, 0, C.Width, C.Height)
        return Last
    }

    ## see also: https://forum.doom9.org/showthread.php?p=1676821
    ## (show U+/U-, V+/V- separately)
    ##################################
    ### show quad split: 
    ###  C (full color) & Y channel on top, 
    ### with U & V below
    ##
    ## @ uinvert - if true (default), show 'U' channel inverted so warm colors 
    ##             always brighter, cool colors darker (no effect on RGB)
    ##
    function _showChannelsYUV(clip C, bool "analyze", bool "uinvert", bool "chroffset")
    {
        Assert(C.IsYUV || C.IsYUVA,
        \   "ShowChannelsYUV: source must be YUV(A)")
        alyz = Default(analyze, false)
        uinv = Default(uinvert, true)
        coff = Default(chroffset, true)
        size = Max(8, C.Height/20.0)

        C
        wid2 = modx(2, 0.5*Width)
        hgt2 = modx(2, 0.5*Height)

        R = BicubicResize(wid2, hgt2)
        Y = R.ExtractY.AnalyzeY("Y", alyz, fontsize=size)
        \    .MatchColorFormat(C)
        
        s = (coff)
        \ ? (uinv)
        \    ? "-U (+Yel, +Grn, -Blu)"
        \    : "+U (+Blu, -Yel, -Grn)"
        \ : (uinv) ? "-U" : "U"
        U = ExtractU.Spline64Resize(wid2, hgt2)
        U = (!uinv) ? U : U.Invert
        U = U.AnalyzeUV(s, alyz, fontsize=size, chroffset=coff)
        \    .MatchColorFormat(C)
        
        s = (coff)
        \ ? "+V (+Red, -Grn, -Cyn)"
        \ : "V"
        V = ExtractV.Spline64Resize(wid2, hgt2)
        V = V.AnalyzeUV(s, alyz, fontsize=size, chroffset=coff)
        \    .MatchColorFormat(C)

        StackVertical(
        \   StackHorizontal(R, Y),
        \   StackHorizontal(U, V))
        PointResize(C.Width, C.Height, 0, 0, C.Width, C.Height)
        return Last
    }
}

##################################
### [[ShowFrameNumber]] with support for 'opacity' and 'align'
### ('scroll' argument always false unless 'align' < 0)
##
## @ opacity - @see [[Overlay]]
## @ align   - @see [[Subtitle]] ("number pad notation") default 2
##
function ShowFrameNumberAligned(
\               clip C, bool "scroll", int "offset",
\               float "x", float "y", string "font", int "size",
\               int "text_color", int "halo_color",
\               float "font_width", float "font_angle",
\               float "opacity", int "align")
{
    scr = Default(scroll,     true)
    off = Default(offset,     0)
    x   = Default(x,          0)
    y   = Default(y,          0)
    fnt = Default(font,       "Arial")
    siz = Default(size,       24*Round(C.Width/1024.0))
    txt = Default(text_color, $ffff00)
    hal = Default(halo_color, $0)
    wid = Default(font_width, 0)
    ang = Default(font_angle, 0.0)
    opc = Default(opacity,    1.0)
    aln = Default(align,      2)

    siz = Max(16.0, siz)
    number_width = 6*siz ## approximate width of frame number (assume avg. 6 digits)

    xa = (aln==3||aln==6||aln==9) ? x + C.Width     - number_width
    \  : (aln==2||aln==5||aln==8) ? x + (C.Width/2) - (number_width/2)
    \  : x + siz

    ya = (aln==1||aln==2||aln==3) ? y + C.Height     - siz
    \  : (aln==4||aln==5||aln==6) ? y + (C.Height/2) - (siz/2)
    \  : y + siz + siz/2

    return (aln<0)
    \ ? C.ShowFrameNumber(scroll=scr, offset=off, 
    \           x=x, y=y, font=fnt, size=siz, 
    \           text_color=transparent_color(opc, txt), 
    \           halo_color=transparent_color(opc, hal), 
    \           font_width=wid, font_angle=ang)
    \ : C.ShowFrameNumber(scroll=false, offset=off, 
    \           x=xa, y=ya, font=fnt, size=siz, 
    \           text_color=transparent_color(opc, txt), 
    \           halo_color=transparent_color(opc, hal), 
    \           font_width=wid, font_angle=ang) 
}

__END__
