#HybridFuPP 0.992b by FuPP

Function HybridFuPP(clip input, int "width", int "height", string "Preset", int "Resizer", bool "Fast", bool "ARAdjust",    \
                    bool "Dering", bool "Deblock", bool "DB_M_Only", bool "DB_D_Only", bool "Skin", int "Enh_Str",          \
                    int "D_Mode", int "MP_Mode", int "S_Str", int "T_Str", int "S_Radius", float "S_Dist", int "C_Str",     \
                    int "M_Thr", int "M_SCD", int "M_Str", int "M_TRadius", int "Bl_size",int "ME_Resizer",                 \
                    bool "E_Auto_Str", int "EM_Mode", int "E_Thr", int "E_Str_X", int "E_Str_Y", int "E_Str_B",             \
                    int "E_Str_N", int "DR_Str", int "DR_Radius", int "D_Thr", int "B_Thr", int "LP_Str", bool "DS_Enh",    \
                    int "DS_Enh_Thr", int "DB_Q", int "DB_Off_a" , int "DB_Off_b", string "show", string "N1", string "N2", \
                    string "M", string "E1", string "E2", string "LP", string "DR")
{
swidth     = width(input)
sheight    = height(input)
width      = Default(width , swidth)
height     = Default(height, sheight)
Rwidth     = float(width)/swidth   > 1 ? 0 : float(width)/swidth
Rheight    = float(height)/sheight > 1 ? 0 : float(height)/sheight

Preset     = Default(Preset, "high")
Show       = Default(Show  , "")

preset_num = -1

preset_num = Preset == "medium"    ? 0 : preset_num
preset_num = Preset == "high"      ? 1 : preset_num
preset_num = Preset == "very high" ? 2 : preset_num
preset_num = Preset == "low"       ? 3 : preset_num
preset_num = Preset == "very low"  ? 4 : preset_num
preset_num = Preset == "anime1"    ? 5 : preset_num
preset_num = Preset == "anime2"    ? 6 : preset_num
preset_num = Preset == "HybridQ"   ? 7 : preset_num

Assert(preset_num >=0 ? true : false, chr(10) + "This preset does not exist !" + chr(10))

#                                MED    HIGH   VHIGH  LOW    VLOW   AN1    AN2    HYBQ
_Resizer    = Select(preset_num, 3    , 6    , 8    , 2    , 0    , 2    , 0    , 6    )
_ARAdjust   = Select(preset_num, false, false, false, false, false, false, false, true )
_Fast       = Select(preset_num, true , true , true , true , true , true , true , true )
_D_Mode     = Select(preset_num, 2    , 2    , 2    , 2    , 2    , 1    , 1    , 2    )

D_Mode     =  Default(D_Mode, _D_Mode)

_S_Str      = D_Mode == 1 ? \
              Select(preset_num, 10   , 5    , 7    , 12   , 12   , 7    , 20   , 6    ) :                                  \
              D_Mode == 2 ? \
              Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    ) :                                  \
              D_Mode == 3 ? \
              Select(preset_num, 2    , 2    , 1.7  , 2    , 2    , 3    , 3    , 2    ) : 0

_S_Radius   = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 1    , 2    , 1    )
_S_Dist     = Select(preset_num, 0.1  , 0.1  , 0.1  , 0.1  , 0.1  , 0.1  , 0.1  , 0.1  )
_T_Str      = Select(preset_num, 3    , 3    , 2    , 5    , 5    , 6    , 15   , 5    )
_C_Str      = Select(preset_num, 8    , 8    , 8    , 8    , 8    , 9    , 9    , 8    )
_MP_Mode    = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 0    , 0    , 1    )
_ME_Resizer = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    )
_M_Thr      = Select(preset_num, 5    , 5    , 5    , 5    , 5    , 5    , 5    , 5    )
_M_SCD      = Select(preset_num, 260  , 260  , 260  , 260  , 260  , 260  , 260  , 260  )
_M_Str      = Select(preset_num, 120  , 120  , 80   , 120  , 120  , 0    , 0    , 120  )
_M_TRadius  = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 0    , 0    , 1    )
_EM_Mode    = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 2    , 2    , 1    )
_E_Thr      = Select(preset_num, 135  , 135  , 135  , 135  , 135  , 135  , 135  , 135  )
_E_Auto_Str = Select(preset_num, false, false, false, false, false, false, false, true )
_E_Str_X    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 46   , 46   , 30   )
_E_Str_Y    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 46   , 46   , 30   )
_E_Str_B    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , -2   , -2   , 0    )
_E_Str_N    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 7    )
_Dering     = Select(preset_num, false, false, false, false, false, true , false, false)
_DR_Radius  = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 1    , 1    , 1    )
_DR_Str     = Select(preset_num, 30   , 30   , 30   , 30   , 30   , 60   , 60   , 30   )
_D_Thr      = Select(preset_num, 28   , 28   , 28   , 32   , 32   , 30   , 30   , 24   )
_B_Thr      = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 180  )
_LP_Str     = Select(preset_num, 30   , 30   , 30   , 30   , 30   , 40   , 40   , 30   )
_DS_Enh     = Select(preset_num, false, false, false, false, false, false, false, true )
_DS_Enh_Thr = Select(preset_num, 48   , 48   , 48   , 48   , 48   , 48   , 48   , 48   )
_Deblock    = Select(preset_num, false, false, false, false, false, false, false, false)
_DB_M_Only  = Select(preset_num, false, false, false, false, false, false, false, false)
_DB_D_Only  = Select(preset_num, false, false, false, false, false, false, false, false)
_DB_Q       = Select(preset_num, 25   , 25   , 25   , 25   , 25   , 25   , 25   , 25   )
_DB_Off_a   = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    )
_DB_Off_b   = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    )
_Skin       = Select(preset_num, false, false, false, false, false, false, false, true )
_Enh_str    = Select(preset_num, 3    , 3    , 3    , 3    , 3    , 3    , 3    , 3    )

_Bl_Size   = D_Mode == 2 ? 8 : 16

ARAdjust   = Default(ARAdjust, _ARAdjust)
Resizer    = Default(Resizer, _Resizer)
Resizer2   = Resizer < 2 ? 0 : ceil((Resizer-2)/2)

Fast       = Default(Fast, _Fast)

S_Str      = Default(S_Str, _S_Str)
S_Radius   = Default(S_Radius, _S_Radius)
S_Dist     = Default(S_Dist, _S_Dist)
T_Str      = Default(T_Str, _T_Str)
C_Str      = Default(C_Str, _C_Str)
MP_Mode    = Default(MP_Mode, _MP_Mode)
ME_Resizer = Default(ME_Resizer, _ME_Resizer)
Bl_size    = Default(Bl_size, _BL_size)
M_Thr      = Default(M_Thr, _M_Thr)
M_SCD      = Default(M_SCD, _M_SCD)
M_Str      = Default(M_Str, _M_Str)
M_TRadius  = Default(M_TRadius, _M_TRadius)

D_Thr      = Default(D_Thr, _D_Thr)
B_Thr      = Default(B_Thr, _B_Thr)
LP_Str     = Default(LP_Str, _LP_Str)
DS_Enh     = Default(DS_Enh, _DS_Enh)
DS_Enh_Thr = Default(DS_Enh_Thr, _DS_Enh_Thr)

Deblock    = Default(Deblock, _Deblock)
DB_M_Only  = Default(DB_M_Only, _DB_M_Only)
DB_D_Only  = Default(DB_D_Only, _DB_D_Only)
DB_Q       = Default(DB_Q, _DB_Q)
DB_Off_a   = Default(DB_Off_a, _DB_Off_a)
DB_Off_b   = Default(DB_Off_b, _DB_Off_b)

EM_Mode    = Default(EM_Mode, _EM_Mode)
E_Thr      = Default(E_Thr, _E_Thr)
E_Auto_Str = Default(E_Auto_Str, _E_Auto_Str)

E_Str_X    = E_Auto_Str==true ? AutoStrCalc(Rwidth, Rheight, Resizer, "X") : Default(E_Str_X, _E_Str_X)
E_Str_Y    = E_Auto_Str==true ? AutoStrCalc(Rwidth, Rheight, Resizer, "Y") : Default(E_Str_Y, _E_Str_Y)
E_Str_B    = Default(E_Str_B, _E_Str_B)
E_Str_N    = Default(E_Str_N, _E_Str_N)

Dering     = Default(Dering, _Dering)
DR_Str     = Default(DR_Str, _DR_Str)
DR_Radius  = Default(DR_Radius, _DR_Radius)

Skin       = Default(Skin, _Skin)

Enh_Str    = Default(Enh_Str, _Enh_Str)

global S_Str    = S_Str
global S_Radius = S_Radius
global S_Dist   = S_Dist
global T_Str    = T_Str
global C_Str    = C_Str

M_TRadius = MP_Mode == 2 ? 1 : M_TRadius 

mod_preset = False

current  =  string(fast)        +   \
            string(dering)      +   \
            string(EM_Mode)     +   \
            string(MP_Mode)     +   \
            string(ME_Resizer)  +   \
            string(M_Thr)       +   \
            string(M_Scd)       +   \
            string(M_TRadius)   +   \
            string(D_Thr)       +   \
            string(B_Thr)       +   \
            string(E_Thr)       +   \
            string(Resizer)     +   \
            string(D_Mode)      +   \
            string(S_Str)       +   \
            string(T_Str)       +   \
            string(S_Radius)    +   \
            string(S_Dist)      +   \
            string(M_Str)       +   \
            string(LP_Str)      +   \
            string(DS_Enh)      +   \
            string(DS_Enh_Thr)  +   \
            string(DR_Str)      +   \
            string(DR_Radius)   +   \
            string(E_Auto_Str)  +   \
            string(E_Str_X)     +   \
            string(E_Str_Y)     +   \
            string(E_Str_B)     +   \
            string(E_Str_N)     +   \
            string(C_Str)       +   \
            string(Deblock)     +   \
            string(DB_M_Only)   +   \
            string(DB_D_Only)   +   \
            string(DB_Q)        +   \
            string(DB_Off_a)    +   \
            string(DB_Off_b)    +   \
            string(Skin)        +   \
            string(Enh_Str)     +   \
            string(ARAdjust)


_defaults = string(_fast)       +   \
            string(_dering)     +   \
            string(_EM_Mode)    +   \
            string(_MP_Mode)    +   \
            string(_ME_Resizer) +   \
            string(_M_Thr)      +   \
            string(_M_Scd)      +   \
            string(_M_TRadius)  +   \
            string(_D_Thr)      +   \
            string(_B_Thr)      +   \
            string(_E_Thr)      +   \
            string(_Resizer)    +   \
            string(_D_Mode)     +   \
            string(_S_Str)      +   \
            string(_T_Str)      +   \
            string(_S_Radius)   +   \
            string(_S_Dist)     +   \
            string(_M_Str)      +   \
            string(_LP_Str)     +   \
            string(_DS_Enh)     +   \
            string(_DS_Enh_Thr) +   \
            string(_DR_Str)     +   \
            string(_DR_Radius)  +   \
            string(_E_Auto_Str) +   \
            string(_E_Str_X)    +   \
            string(_E_Str_Y)    +   \
            string(_E_Str_B)    +   \
            string(_E_Str_N)    +   \
            string(_C_Str)      +   \
            string(_Deblock)    +   \
            string(_DB_M_Only)  +   \
            string(_DB_D_Only)  +   \
            string(_DB_Q)       +   \
            string(_DB_Off_a)   +   \
            string(_DB_Off_b)   +   \
            string(_Skin)       +   \
            string(_Enh_Str)    +   \
            string(_ARAdjust)


mod_preset = current != _defaults ? True : mod_preset

Def_N1     = ""
Def_N2     = D_Mode == 1 ? """Deen("a3d", S_Radius, S_Str, 3*C_Str, T_Str, C_Str, S_Dist, 9)""" :                           \
             D_Mode == 2 ?   "Mdegrain"+string(M_TRadius)+"(sc, b, f, "+ (M_TRadius > 1 ? "b2, f2, " : "")                  \
                                                                       + (M_TRadius > 2 ? "b3, f3, " : "")                  \
                                                                       + "thscd1 = scd, thscd2=135, plane=4)" :             \
             D_Mode == 3 ?   "fft3dfilter(bt=3, sigma=S_Str, plane=4)" : ""
Def_E1     =                 "UnFilter(E_Str_X, E_Str_Y).Addgrain(E_Str_N,0,0)"
Def_E2     =                 "ColorYUV(off_Y = E_Str_B)"
Def_M      =               """Deen("a2d", 1, M_Str   , 0, 0, 0, 0, 0)"""
Def_LP     =               """Deen("a2d", 2, LP_Str  , 0, 0, 0, 0, 0)"""
Def_DR     =               """Deen("a2d", 2, DR_Str  , 0, 0, 0, 0, 0)"""

N1         = Default(N1, Def_N1)
N2         = Default(N2, Def_N2)
E1         = Default(E1, Def_E1)
E2         = Default(E2, Def_E2)
M          = Default(M , Def_M )
LP         = Default(LP, Def_LP)
DR         = Default(DR, Def_DR)

D_process2 = (DS_Enh == false || Ds_Enh_Thr == 0 || Enh_Str == 0) ? false : true
D_process  = (LP == "" || LP_Str == 0 || D_Thr == 0) ? false : true
B_process  = (LP == "" || LP_Str == 0 || B_Thr == 0) ? false : true
E_process  = (E1 == "" && E2 == "") || (E_Str_X == 0 && E_Str_Y == 0 && E_Str_B == 0 && E_Auto_Str == false) ? false : true
M_process  = (M_TRadius == 0 || MP_Mode == 0) ? false : true

Assert(isyv12(input) == true,                                  chr(10) + "This is not an YV12 clip ! Please convert color " \
                                                               + "space to YV12 before using HybridFuPP" + chr(10))

Assert((swidth%2 != 0 || sheight%2 != 0) == false,             chr(10) + "Width and height (source) must be dividable by 2" \
                                                               + " if you want to use HybridFuPP ! Please Crop if "         \
                                                               + "necessary !" + chr(10))

Assert((width%8 != 0 || height%8 != 0) == false,               chr(10) + "final Width and height must be dividable by 8"    \
                                                               + " if you want to use HybridFuPP !" + chr(10))
                                                             
Assert(((swidth%8 != 0 || sheight%8 != 0) && Deblock) == false,chr(10) + "Width and height (source) must be dividable by 8 "\
                                                               + "if you want to use deblocking !" + chr(10))

Assert(Bl_Size == 4 || Bl_Size == 8 || Bl_Size == 16 ,         chr(10) + "Motion Compensation block size must be 4, 8 or 16"\
                                                               + chr(10))

Assert(string(D_mode)+string(M_TRadius) <> "20",               chr(10) + "When using D_Mode = 2, M_Tradius must be set to a"\
                                                               + " value between 1 and 3" + chr(10))

Assert(M_TRadius <= 3,                                         chr(10) + "Valid range for M_TRadius : 0 - 3" + chr(10))

Assert((findstr(Ucase(show),"M") != 0 ? "1" : "") + string(M_process) <> "1false",                                          \
                                                               chr(10) + "Motion Mask can not be displayed if M_TRadius = 0"\
                                                               + " or MP_Mode = 0" + chr(10))

Assert(Enh_Str >= 0 && Enh_Str <= 5,                           chr(10) + "Valid range for Enh_Str : 0 - 5" + chr(10))


_input     = Deblock ? input.Deblock(DB_Q, DB_Off_A, DB_Off_B) : input

#return input.bicubicresize(width, height).subtitle(D_process2)

global NulC= BlankClip(1, width, height, color=$000000, pixel_type="yv12").levels(0, 1, 16, 0, 0, coring=false)

basic      = _input.resizer(width, height, ME_Resizer)

#super      = M_process ? (Deblock && DB_M_Only ? input.resizer(width, height, ME_Resizer).Msuper() : basic.MSuper()) : NulC
super      = (M_process || (Deblock && DB_M_Only)) ? basic.MSuper() : NulC

bv         = (M_process || (Deblock && DB_M_Only)) && M_TRadius >=1 ? \
                       MAnalyse(super, isb = true,  lambda=1000, blksize=Bl_size, overlap=max(Bl_size/2,2))          : NulC
fv         = (M_process || (Deblock && DB_M_Only)) && M_TRadius >=1 ? \
                       MAnalyse(super, isb = false, lambda=1000, blksize=Bl_size, overlap=max(Bl_size/2,2))          : NulC
bv2        = (M_process || (Deblock && DB_M_Only)) && M_TRadius >=2 ? \
                       MAnalyse(super, isb = true,  lambda=1000, blksize=Bl_size, overlap=max(Bl_size/2,2), delta=2) : NulC
fv2        = (M_process || (Deblock && DB_M_Only)) && M_TRadius >=2 ? \
                       MAnalyse(super, isb = false, lambda=1000, blksize=Bl_size, overlap=max(Bl_size/2,2), delta=2) : NulC
bv3        = (M_process || (Deblock && DB_M_Only)) && M_TRadius >=3 ? \
                       MAnalyse(super, isb = true,  lambda=1000, blksize=Bl_size, overlap=max(Bl_size/2,2), delta=3) : NulC
fv3        = (M_process || (Deblock && DB_M_Only)) && M_TRadius >=3 ? \
                       MAnalyse(super, isb = false, lambda=1000, blksize=Bl_size, overlap=max(Bl_size/2,2), delta=3) : NulC

_dbmo      = Deblock && DB_M_Only ? MM(basic, fv, bv, M_Thr, M_SCD, Bl_Size) : NulC

D          = (findstr(Ucase(show),"D") != 0 || D_process || (Deblock && DB_D_Only)) ? DM(basic, D_Thr) : NulC
D2         = D_Process2 || (Deblock && DB_D_Only) ? XM(basic, DS_Enh_Thr, D_Thr) : NulC

_dbdo      = Deblock && DB_D_Only ? mt_logic(D, D2, "or") : NulC

_input     = Deblock && (DB_M_Only || DB_D_Only) ? mt_Merge(input, _input, bilinearresize(mt_logic(_dbmo, _dbdo, "or"),     \
                       swidth, sheight)) : _input

BA         = (findstr(Ucase(show),"A") != 0 || ARAdjust) ? BA(_input).pointresize(width,height) : NulC

Before1    =            Eval("_input." + (N1 !="" ? "Denoise(super, bv, fv, bv2, fv2, bv3, fv3, M_TRadius, M_SCD, N1,       \
                             M_Process, MP_Mode)." : "") + "Resizer(width, height, Resizer )")
Before2    = Aradjust ? Eval("_input." + (N1 !="" ? "Denoise(super, bv, fv, bv2, fv2, bv3, fv3, M_TRadius, M_SCD, N1,       \
                             M_Process, MP_Mode)." : "") + "Resizer(width, height, Resizer2)") : NOP()

Denoised   = Eval((Aradjust ? "MT_Merge(Before1, Before2, BA)" : "Before1") + (N2 !="" ? ".Denoise(super, bv, fv, bv2, fv2, \
                   bv3, fv3, M_TRadius, M_SCD, N2, M_Process, MP_Mode)" : ""))

clip       = Fast ? Denoised : _input.Resizer(width, height, Resizer)

#D2         = D_Process2 ? mt_logic(mt_lutf(clip, clip, "avg", "x 46 <= 255 0 ?"), mt_logic(DM(Clip, DS_Enh_Thr),           \
#                                                                              DM(Clip, D_Thr+3),"xor"), "and") : NOP()

B          = (show != "" || B_process) ? BM(clip, B_Thr) : NOP()
LM         = NOP()
LM         = (D_process && B_process == false) ? D : LM
LM         = (B_process && D_process == false) ? B : LM
LM         = (B_process && D_process) ? mt_Logic(D, B, "or") : LM
EM         = (findstr(Ucase(show),"E") != 0 || E_process || Dering) ? EM(clip, EM_Mode, E_thr)                 : NulC
MM         = (findstr(Ucase(show),"M") != 0 || M_process) ? MM(clip, fv, bv, M_Thr, M_SCD, Bl_Size)            : NulC
RM         = (findstr(Ucase(show),"R") != 0 || Dering) ? DR_Radius(EM, DR_Radius,0)                            : NulC
SM         = (findstr(Ucase(show),"S") != 0 || Skin) ? (E_process ? mt_logic(EM, SM(clip), "andn") : SM(clip)) : NulC

Luma       = (B_process || D_process)    ? Eval("Denoised." + LP) : NOP()

Enhanced   = (Skin || D_Process2)        ? _input.sharpen(Enh_Str*0.2).addgrain(Enh_str,0,0).Resizer(width, height,6) : NOP()

Edges      = E_process                   ? Eval("_input." + (E1 !="" ? E1 + "." : E1) + "Resizer(width, height, Resizer)"   \
                                           + (E2 !="" ? "." + E2 : E2)) : NOP()

DeRinging  = Dering                      ? Eval("Clip." + DR) : NOP()

Motion     = (M_process && MP_Mode == 2) ? (DB_M_Only ? Eval("Denoised." + M ).Deblock(DB_Q, DB_Off_A, DB_Off_B) :          \
                                            Eval("Denoised." + M )) : NOP()

Final      = (B_process || D_process)    ? mt_Merge(Denoised, Luma,      LM) : Denoised
Final      = D_Process2                  ? mt_Merge(Final,    Enhanced,  D2) : Final
Final      = Dering                      ? mt_Merge(Final,    DeRinging, RM) : Final
Final      = Skin                        ? mt_Merge(Final,    Enhanced,  SM) : Final
Final      = E_process                   ? mt_Merge(Final,    Edges,     EM) : Final
Final      = (M_process && MP_Mode == 2) ? mt_Merge(Final,    Motion,    MM) :                                              \
             (M_process && MP_Mode == 1) ? mt_Merge(Final,    clip,      MM) : Final

return (show == "") ? Final : Show(Final, input, EM, MM, RM, D, D2, B, SM, BA, show, width, height, Fast, Dering, Deblock,  \
                                   MP_Mode, EM_Mode, DB_Q, DB_Off_a, DB_Off_b, M_Thr, M_SCD, E_Thr, D_Thr, B_Thr, Resizer,  \
                                   Resizer2, D_Mode, S_Str, T_Str, S_Radius, S_Dist, M_TRadius, M_Str, E_Auto_Str, E_Str_X, \
                                   E_Str_Y, E_Str_B, E_Str_N, LP_Str, DR_Str, DR_Radius, C_Str, Preset, mod_preset, Skin,   \
                                   Enh_Str, ARAdjust, DS_Enh, DS_Enh_Thr, ME_Resizer, Bl_Size, DB_M_Only, N1, N2, E1, E2,   \
                                   M, LP, DR, swidth, sheight)
}


Function EM(clip i, int mode, int e_th)
{
diff = mode == 2 ? mt_makediff(i.blur(1.58).blur(1.58),i) : NOP()
a    = mode == 2 ? diff.mt_binarize(threshold = e_th-4).mt_inflate().mt_inflate() : NOP()
b    = mode == 2 ? diff.mt_binarize(threshold = e_th  ).mt_inflate().mt_inflate() : NOP()
c    = mode == 2 ? i.mt_binarize(62, upper=true) : NOP()

return mode == 2 ? mt_logic(b,mt_logic(a,c,"and"),"or") : \
                   mt_makediff(i.blur(1.58).blur(1.58),i).mt_binarize(threshold=e_th).mt_inflate().mt_inflate()
}


Function RM(clip i, dr_rad)
{
return mt_logic(i, i.DR_Radius(DR_rad, 1),"xor").mt_binarize(upper=false)
}


Function DR_Radius(clip i, int dr_rad, int count)
{
return count > dr_rad ? i : DR_Radius(i.mt_expand(), dr_rad, count+1)
}


Function MM(clip i, clip f, clip b, int m_th, int scd, int bl_sz)
{
#m_th=5
#scd=260
fmm = i.MMask(f, ml=m_th, Gamma=50, ThSCD1=scd, thSCD2=135)
bmm = i.MMask(b, ml=m_th, Gamma=50, ThSCD1=scd, thSCD2=135)

return mt_Binarize(mt_logic(fmm, bmm, "and"), Upper=False, Threshold=30).mt_inpand()
}


Function DM(clip i, int d_th)
{
return mt_Binarize(i, threshold = d_th, upper=true).mt_deflate()
}


Function XM(clip i, int d_ens_th, int d_th)
{
return mt_logic(mt_lutf(i, i, "avg", "x 46 <= 255 0 ?"), mt_logic(DM(i, d_ens_th), DM(i, d_th+3),"xor"), "and")
}


Function BM(clip i, int b_th)
{
return mt_Binarize(i, threshold = b_th, upper = false).mt_inpand()
}


Function BA(clip i)
{
global BA_i = i
return scriptclip(BA_i, "averageluma() >56 ? subtract(BA_i,BA_i.unfilter(-255,-255)).mt_expand().mt_binarize(upper=true,127)\
                         : subtract(BA_i,BA_i.unfilter(-255,-255)).mt_expand().mt_binarize(upper=true,126)")
}


Function SM(clip i)
{
Smask = scriptclip(i,"avu=averagechromau()"+chr(13)+ "avv=averagechromav()"+chr(13)+ \
                   """skin("52","190",string(avu*0.84),string(avu*0.99),string(avv*1.05),string(avv*1.18)).averageluma()>68?\
                      NulC : skin("52","190",string(avu*0.84),string(avu*0.99),string(avv*1.05),string(avv*1.18))""")
return Smask
}


Function Skin(clip i, string y1, string y2, string u1, string u2, string v1, string v2)
{
y    =        i.mt_lut("x "+y1+" <= x "+y2+" >= | 0 255 ?")
u    = i.utoy().mt_lut("x "+u1+" <= x "+u2+" >= | 0 255 ?") 
v    = i.vtoy().mt_lut("x "+v1+" <= x "+v2+" >= | 0 255 ?")
uv   = mt_logic(u,v,"and").pointresize(width(i),height(i))
yuv  = mt_logic(uv,y,"and")
return yuv
}


Function Denoise(clip i, clip sc, clip b, clip f, clip b2, clip f2, clip b3, clip f3, int m_trad,                           \
                 int scd, string DN_String, bool mprocess, int mpmode)
{
m_trad = mprocess ? (FindStr(UCase(DN_String),"MDEGRAIN") != 0 || mpmode == 2 ? 0 : m_trad) : 0

bc  = m_trad >=1 ? MCompensate(i, sc, b,  thSCD1=scd) : NOP()
fc  = m_trad >=1 ? MCompensate(i, sc, f,  thSCD1=scd) : NOP()
bc2 = m_trad >=2 ? MCompensate(i, sc, b2, thSCD1=scd) : NOP()
fc2 = m_trad >=2 ? MCompensate(i, sc, f2, thSCD1=scd) : NOP()
bc3 = m_trad >=3 ? MCompensate(i, sc, b3, thSCD1=scd) : NOP()
fc3 = m_trad >=3 ? MCompensate(i, sc, f3, thSCD1=scd) : NOP()

return m_trad == 0 ? eval("i." + DN_String) :                                                                               \
       m_trad == 1 ? eval("interleave(fc, i, bc)."                     + DN_String + ".selectevery(3,1)") :                 \  
       m_trad == 2 ? eval("interleave(fc2, fc, i, bc, bc2)."           + DN_String + ".selectevery(5,2)") :                 \
       m_trad == 3 ? eval("interleave(fc3, fc2, fc, i, bc, bc2, bc3)." + DN_String + ".selectevery(7,3)") : i
}


Function AutoStrCalc(float rw, float rh, int ra, string axis)
{
ref = axis == "X" ? rw : rh
return ref == 0 ? 0 : min(60, max(0, int((1-(float(ra)/10-0.2))*(max(rw, rh) == ref ? -180*ref+180 : (-180*max(rw, rh)+180) \
                          *(min(rw, rh)/max(rw, Rh))))))
}


Function Resizer(clip i, int w, int h, int t)
{
return  (t == 0) ? BilinearResize(i, w, h)               : 
      \ (t == 1) ?  BicubicResize(i, w, h, 0.333, 0.333) : 
      \ (t == 2) ?  BicubicResize(i, w, h, 0.2  , 0.4  ) : 
      \ (t == 3) ?  BicubicResize(i, w, h, 0    , 0.5  ) : 
      \ (t == 4) ?  BicubicResize(i, w, h, 0    , 0.6  ) : 
      \ (t == 5) ?  LanczosResize(i, w, h)               : 
      \ (t == 6) ? Spline16Resize(i, w, h)               : 
      \ (t == 7) ? Spline36Resize(i, w, h)               : 
      \ (t == 8) ? Spline64Resize(i, w, h)               : Nop()
}


Function Resizer_String(int r)
{
return  (r == 0) ? "Bilinear"  : 
      \ (r == 1) ? "Bic(0.3,0.3)" : 
      \ (r == 2) ? "Bic(0.2,0.4)" : 
      \ (r == 3) ? "Bic(0,0.5)"   : 
      \ (r == 4) ? "Bic(0,0.6)"   : 
      \ (r == 5) ? "Lanczos 3"    : 
      \ (r == 6) ? "Spline 16"    : 
      \ (r == 7) ? "Spline 36"    : 
      \ (r == 8) ? "Spline 64"    : ""
}


Function Show(clip i, clip s, clip em, clip mm, clip rm, clip dm, clip d2, clip bm, clip sm, clip ba, string sh, int w,     \
              int h, bool Fast, bool Dering, bool deblock, int MP_Mode, int EM_Mode, int DB_Q, int DB_Off_a, int DB_Off_b,  \
              int M_Thr, int M_SCD, int E_Thr, int D_Thr, int B_Thr, int Resizer, int resizer2, int D_Mode, int S_Str,      \ 
              int T_Str, int S_Radius, float S_Dist, int M_TRadius, int M_Str, bool E_Auto_Str, int E_Str_X , int E_Str_Y,  \
              int E_Str_B, int E_Str_N, int LP_Str, int DR_Str, int DR_Radius, int C_Str, string Preset, bool mod_preset,   \
              bool Skin, int Enh_Str, bool ARAdjust, bool DS_Enh, int DS_Enh_Thr, int ME_Resizer, int Bl_Size,              \
              bool DB_M_Only, string n1, string n2, string e1, string e2, string m, string lp, string dr, int swidth,       \
              int sheight)
{
MM_Blank = BlankClip(1, w, h, color=$FFFF0F, pixel_type="yv12")
DM_Blank = BlankClip(1, w, h, color=$FFF0,   pixel_type="yv12")
D2_Blank = BlankClip(1, w, h, color=$5FFF,   pixel_type="yv12")
BM_Blank = BlankClip(1, w, h, color=$FF0A,   pixel_type="yv12")
EM_Blank = BlankClip(1, w, h, color=$FF0808, pixel_type="yv12")
RM_Blank = BlankClip(1, w, h, color=$FFBF0A, pixel_type="yv12")
SM_Blank = BlankClip(1, w, h, color=$FF00C0, pixel_type="yv12")
AM_Blank = BlankClip(1, w, h, color=$FFA0F0, pixel_type="yv12")

EShow  = FindStr(UCase(sh),"E")
MShow  = FindStr(UCase(sh),"M")
RShow  = FindStr(UCase(sh),"R")
DShow  = FindStr(UCase(sh),"D")
XShow  = FindStr(UCase(sh),"X")
BShow  = FindStr(UCase(sh),"B")
PShow  = FindStr(UCase(sh),"P")
FShow  = FindStr(UCase(sh),"F")
SShow  = FindStr(UCase(sh),"S")
AShow  = FindStr(UCase(sh),"A")
SVShow = FindStr(UCase(sh),"-")
SHShow = FindStr(UCase(sh),"|")
ILShow = FindStr(UCase(sh),"/")

Fshow = PShow != 0 ? 0 : Fshow

mod = mod_preset ? "(mod)" : ""

i = EShow != 0 ? Overlay(i, EM_Blank, Mask=em, Mode="chroma",                                 opacity=0.6) : i
i = MShow != 0 ? Overlay(i, MM_Blank, Mask=mm, Mode="blend" ,                                 opacity=0.3) : i
i = RShow != 0 ? Overlay(i, RM_Blank, Mask=rm, Mode="blend" ,                                 opacity=0.7) : i
i = DShow != 0 ? Overlay(i, DM_Blank, Mask=dm, Mode="blend" ,                                 opacity=0.4) : i
i = XShow != 0 ? Overlay(i, D2_Blank, Mask=d2, Mode="blend" ,                                 opacity=0.2) : i
i = BShow != 0 ? Overlay(i, BM_Blank, Mask=mt_Logic(bm, bm.mt_Inpand(), "xor"), Mode="blend", opacity=1  ) : i
i = SShow != 0 ? Overlay(i, SM_Blank, Mask=sm, Mode="blend" ,                                 opacity=0.2) : i
i = AShow != 0 ? Overlay(i, AM_Blank, Mask=ba, Mode="blend" ,                                 opacity=0.4) : i

i = EShow != 0 ? i.SubTitle("Edges",                             text_color=$FF0808,                  size=14,x=16,y=h-104):i
i = MShow != 0 ? i.SubTitle("Motion",                            text_color=$FFFF0F,                   size=14,x=16,y=h-92):i
i = RShow != 0 ? i.SubTitle("DeRinging",                         text_color=$FFBF0A,                   size=14,x=16,y=h-80):i
i = DShow != 0 ? i.SubTitle("Dark areas",                        text_color=$FFF0,                     size=14,x=16,y=h-68):i
i = XShow != 0 ? i.SubTitle("Dark Scenes Enhancement",           text_color=$5FFF,                     size=14,x=16,y=h-56):i
i = BShow != 0 ? i.SubTitle("Bright areas",                      text_color=$FF0A,                     size=14,x=16,y=h-44):i
i = SShow != 0 ? i.SubTitle("Skin",                              text_color=$FF00C0,                   size=14,x=16,y=h-32):i
i = AShow != 0 ? i.SubTitle("Auto Resizer Adjustment",           text_color=$FFA0F0,                   size=14,x=16,y=h-20):i

fnt  = "COURIER NEW"
Tcol = $FFFFFF

x1 = 18
x2 = 192
x3 = 316

y1 = 16
i = PShow != 0 ? i.SubTitle("General Parameters" ,                      text_color=Tcol,           size=13, x=x1-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("Preset     = " + string(Preset) + mod,     text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Fast       = " + string(fast),             text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("ARAdjust   = " + string(ARAdjust),         text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Resizer    = " + string(Resizer) + ":" + Resizer_string(Resizer),                              \
                                                                        text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Resizer2   = " + (ARAdjust ? string(Resizer2) + ":" + Resizer_string(Resizer2) : "N/A"),       \
                                                                        text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Enh_Str    = " + string(Enh_Str),          text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i

y1=y1+14
i = PShow != 0 ? i.SubTitle("Edges E1/E2 + Dering DR" ,                 text_color=Tcol,           size=13, x=x1-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("EM_Mode    = " + string(EM_Mode),          text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("E_Thr      = " + string(E_Thr),            text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("E_Auto_Str = " + string(E_Auto_Str),       text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("E_Str_X    = " + string(E_Str_X),          text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("E_Str_Y    = " + string(E_Str_Y),          text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("E_Str_B    = " + string(E_Str_B),          text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("E_Str_N    = " + string(E_Str_N),          text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Dering     = " + string(Dering),           text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DR_Str     = " + string(DR_Str),           text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DR_Radius  = " + string(DR_Radius),        text_color=Tcol, font=fnt, size=12, x=x1,   y=y1) : i


y1 = 16
i = PShow != 0 ? i.SubTitle("Deblocking" ,                              text_color=Tcol,           size=13, x=x2-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("Deblock    = " + string(Deblock),          text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DB_M_Only  = " + (Deblock ? string(DB_M_Only) : "N/A"),                                        \
                                                                        text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DB_Q       = " + (Deblock ? string(DB_Q) : "N/A"),                                             \
                                                                        text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DB_Off_a   = " + (Deblock ? string(DB_Off_a) : "N/A"),                                         \
                                                                        text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DB_Off_b   = " + (Deblock ? string(DB_Off_b) : "N/A"),                                         \
                                                                        text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i

y1=y1+24

i = PShow != 0 ? i.SubTitle("Luma processing LP" ,                      text_color=Tcol,           size=13, x=x2-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("D_Thr      = " + string(D_Thr),            text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("B_Thr      = " + string(B_Thr),            text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("LP_Str     = " + string(LP_Str),           text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DS_Enh     = " + string(DS_Enh),           text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("DS_Enh_Thr = " + (DS_Enh ? string(DS_Enh_Thr) : "N/A"),                                        \
                                                                        text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i

y1=y1+24
i = PShow != 0 ? i.SubTitle("'Skin' Processing" ,                       text_color=Tcol,           size=13, x=x2-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("Skin       = " + string(Skin),             text_color=Tcol, font=fnt, size=12, x=x2,   y=y1) : i

y1=16

i = PShow != 0 ? i.SubTitle("Denoising N1/N2",                          text_color=Tcol,           size=13, x=x3-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("D_Mode     = " + string(D_Mode),           text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("MP_Mode    = " + string(MP_Mode),          text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("ME_Resizer = " + string(ME_Resizer) + ":" + Resizer_string(ME_Resizer),                        \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Bl_Size    = " + string(BL_Size),          text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("S_Str      = " + string(S_Str),            text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("T_Str      = " + (D_Mode==1 ? string(T_Str) : "N/A"), \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("S_Radius   = " + (D_Mode==1 ? string(S_Radius) : "N/A"), \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("S_Dist     = " + (D_Mode==1 ? string(S_Dist) : "N/A"), \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("C_Str      = " + (D_Mode==1 ? string(C_Str) : "N/A"), \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("M_TRadius  = " + string(M_TRadius),        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("M_Thr      = " + string(M_Thr),            text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("M_SCD      = " + string(M_SCD),            text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("M_Str      = " + (MP_Mode == 2 ? string(M_Str) : "N/A"),                                       \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+20
i = PShow != 0 ? i.SubTitle("Other Infos" ,                             text_color=Tcol,           size=13, x=x3-2, y=y1) : i
y1=y1+12
i = PShow != 0 ? i.SubTitle("Input  size = " + string(swidth) + " x " + string(sheight),                                    \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i
y1=y1+10
i = PShow != 0 ? i.SubTitle("Output size = " + string(w) + " x " + string(h),                                               \
                                                                        text_color=Tcol, font=fnt, size=12, x=x3,   y=y1) : i

                                                                    
i = FShow != 0 ? i.SubTitle("Filters Chains" ,                          text_color=Tcol,           size=13, x=16,   y=0 ) : i
i = FShow != 0 ? i.SubTitle("N1          = " + n1,                      text_color=Tcol, font=fnt, size=12, x=18,   y=12) : i
i = FShow != 0 ? i.SubTitle("N2          = " + n2,                      text_color=Tcol, font=fnt, size=12, x=18,   y=22) : i
i = FShow != 0 ? i.SubTitle("M           = " + m,                       text_color=Tcol, font=fnt, size=12, x=18,   y=32) : i
i = FShow != 0 ? i.SubTitle("LP          = " + lp,                      text_color=Tcol, font=fnt, size=12, x=18,   y=42) : i
i = FShow != 0 ? i.SubTitle("E1          = " + e1,                      text_color=Tcol, font=fnt, size=12, x=18,   y=52) : i
i = FShow != 0 ? i.SubTitle("E2          = " + e2,                      text_color=Tcol, font=fnt, size=12, x=18,   y=62) : i
i = FShow != 0 ? i.SubTitle("DR          = " + dr,                      text_color=Tcol, font=fnt, size=12, x=18,   y=72) : i


ns = w > swidth   ?  s.addborders((w-swidth)/2,0,(w-swidth)/2,0,$808080)   : s
ns = h > sheight  ? ns.addborders(0,(h-sheight)/2,0,(h-sheight)/2,$808080) : ns
ns = ns.subtitle("Source",     width(ns)/2-24)
ni = w <= swidth  ?  i.addborders((swidth-w)/2,0,(swidth-w)/2,0,$808080)   : i
ni = h <= sheight ? ni.addborders(0,(sheight-h)/2,0,(sheight-h)/2,$808080) : ni
ni = ni.subtitle("HybridFuPP", width(ni)/2-40)

return SVShow !=0 ? stackvertical(ns, ni) : (SHShow != 0 ? Stackhorizontal(ns, ni) : (ILShow !=0 ? interleave(ns, ni) : i))
}
