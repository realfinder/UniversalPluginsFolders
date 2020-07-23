#HybridFuPP 0.98a by FuPP

Function HybridFuPP(clip input, int "width", int "height", bool "Fast", bool "Dering", bool "Deblock", int "MP_Mode",       \
                    int "EM_Mode", int "DB_Q", int "DB_Off_a" , int "DB_Off_b", int "M_Thr", int "M_SCD", int "E_Thr",      \
                    int "D_Thr", int "B_Thr", int "Resizer", int "S_Str", int "T_Str", int "S_Radius", float "S_Dist",      \
                    int "C_Str", int "M_Str", bool "E_Auto_Str", int "E_Str_X", int "E_Str_Y", int "E_Str_B",               \
                    int "E_Str_N", int "LP_Str", int "DR_Str", int "DR_Radius", string "show", string "N1", string "N2",    \
                    string "M", string "E1", string "E2", string "LP", string "DR", string "Preset", bool "Skin",           \
                    int "Enh_Str", bool "ARAdjust", int "Skin_Type", bool "DS_Enh", int "DS_Enh_Thr", bool "DB_M_Only")
{
width      = Default(width , width(input))
height     = Default(height, height(input))
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

_Resizer    = Select(preset_num, 3    , 4    , 5    , 2    , 0    , 2    , 0    , 3    )
_Fast       = Select(preset_num, true , true , true , true , true , true , true , true )
_S_Str      = Select(preset_num, 10   , 5    , 7    , 12   , 12   , 7    , 20   , 6    )
_S_Radius   = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 1    , 2    , 1    ) 
_S_Dist     = Select(preset_num, 0.1  , 0.1  , 0.1  , 0.1  , 0.1  , 0.1  , 0.1  , 0.1  )
_T_Str      = Select(preset_num, 3    , 3    , 2    , 5    , 5    , 6    , 15   , 5    )
_C_Str      = Select(preset_num, 8    , 8    , 8    , 8    , 8    , 9    , 9    , 8    )
_MP_Mode    = Select(preset_num, 2    , 2    , 2    , 2    , 2    , 2    , 2    , 2    )
_M_Thr      = Select(preset_num, 7    , 7    , 7    , 7    , 7    , 7    , 7    , 7    )
_M_SCD      = Select(preset_num, 260  , 260  , 260  , 260  , 260  , 260  , 260  , 260  ) 
_M_Str      = Select(preset_num, 120  , 120  , 80   , 120  , 120  , 0    , 60   , 120  ) 
_EM_Mode    = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 1    , 1    , 1    )
_E_Thr      = Select(preset_num, 12   , 10   , 10   , 14   , 14   , 8    , 6    , 14   )
_E_Auto_Str = Select(preset_num, false, false, false, false, false, true , false, true )
_E_Str_X    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 46   , 46   , 0    )
_E_Str_Y    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 46   , 46   , 0    )
_E_Str_B    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , -2   , -2   , 0    )
_E_Str_N    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 7    )
_Dering     = Select(preset_num, false, false, false, false, false, true , false, false)
_DR_Radius  = Select(preset_num, 1    , 1    , 1    , 1    , 1    , 1    , 1    , 1    )
_DR_Str     = Select(preset_num, 30   , 30   , 30   , 30   , 30   , 60   , 60   , 30   )
_D_Thr      = Select(preset_num, 35   , 32   , 31   , 37   , 39   , 30   , 30   , 30   )
_B_Thr      = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 180  )
_LP_Str     = Select(preset_num, 30   , 30   , 30   , 30   , 30   , 40   , 40   , 30   )
_DS_Enh     = Select(preset_num, false, false, false, false, false, false, false, false)
_DS_Enh_Thr = Select(preset_num, 50   , 50   , 50   , 50   , 50   , 50   , 50   , 68   )
_DS_Enh_Str = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 2    )
_Deblock    = Select(preset_num, false, false, false, false, false, false, false, false)
_DB_M_Only  = Select(preset_num, false, false, false, false, false, false, false, false)
_DB_Q       = Select(preset_num, 25   , 25   , 25   , 25   , 25   , 25   , 25   , 25   )
_DB_Off_a   = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    )
_DB_Off_b   = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    )
_Skin       = Select(preset_num, false, false, false, false, false, false, false, true )
_Skin_Type  = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 0    )
_Enh_str    = Select(preset_num, 0    , 0    , 0    , 0    , 0    , 0    , 0    , 2    )
_ARAdjust   = Select(preset_num, false, false, false, false, false, false, false, true )

Resizer    = Default(Resizer, _Resizer)
Fast       = Default(Fast, _Fast)

S_Str      = Default(S_Str, _S_Str)
S_Radius   = Default(S_Radius, _S_Radius)
S_Dist     = Default(S_Dist, _S_Dist)
T_Str      = Default(T_Str, _T_Str)
C_Str      = Default(C_Str, _C_Str)

MP_Mode    = Default(MP_Mode, _MP_Mode)
M_Thr      = Default(M_Thr, _M_Thr)
M_SCD      = Default(M_SCD, _M_SCD)
M_Str      = Default(M_Str, _M_Str)

D_Thr      = Default(D_Thr, _D_Thr)
B_Thr      = Default(B_Thr, _B_Thr)
LP_Str     = Default(LP_Str, _LP_Str)
DS_Enh     = Default(DS_Enh, _DS_Enh)
DS_Enh_Thr = Default(DS_Enh_Thr, _DS_Enh_Thr)

Deblock    = Default(Deblock, _Deblock)
DB_M_Only  = Default(DB_M_Only, _DB_M_Only)
DB_Q       = Default(DB_Q, _DB_Q)
DB_Off_a   = Default(DB_Off_a, _DB_Off_a)
DB_Off_b   = Default(DB_Off_b, _DB_Off_b)

EM_Mode    = Default(EM_Mode, _EM_Mode)
E_Thr      = Default(E_Thr, _E_Thr)
E_Auto_Str = Default(E_Auto_Str, _E_Auto_Str)
E_Str_X    = E_Auto_Str==true ? (width(input)/float(width) <1 ? 0 : \
             round((width(input)/float(width)-1)*380)-5*resizer+15) : Default(E_Str_X, _E_Str_X)
E_Str_Y    = E_Auto_Str==true ? (height(input)/float(height) <1 ? 0 : \
             round((height(input)/float(height)-1)*58)-5*resizer+15) : Default(E_Str_Y, _E_Str_Y)
E_Str_B    = Default(E_Str_B, _E_Str_B)
E_Str_N    = Default(E_Str_N, _E_Str_N)

Dering     = Default(Dering, _Dering)
DR_Str     = Default(DR_Str, _DR_Str)
DR_Radius  = Default(DR_Radius, _DR_Radius)

Skin       = Default(Skin, _Skin)
Skin_Type  = Default(Skin_Type, _Skin_Type)

Enh_Str    = Default(Enh_Str, _Enh_Str)

ARAdjust   = Default(ARAdjust, _ARAdjust)


mod_preset = False

current  =  string(fast)        +   \
            string(dering)      +   \
            string(MP_Mode)     +   \
            string(EM_Mode)     +   \
            string(M_Thr)       +   \
            string(M_Scd)       +   \
            string(D_Thr)       +   \
            string(B_Thr)       +   \
            string(E_Thr)       +   \
            string(Resizer)     +   \
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
            string(DB_Q)        +   \
            string(DB_Off_a)    +   \
            string(DB_Off_b)    +   \
            string(Skin)        +   \
            string(Enh_Str)     +   \
            string(Skin_Type)   +   \
            string(ARAdjust)


_defaults = string(_fast)       +   \
            string(_dering)     +   \
            string(_EM_Mode)    +   \
            string(_MP_Mode)    +   \
            string(_M_Thr)      +   \
            string(_M_Scd)      +   \
            string(_D_Thr)      +   \
            string(_B_Thr)      +   \
            string(_E_Thr)      +   \
            string(_Resizer)    +   \
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
            string(_DB_Q)       +   \
            string(_DB_Off_a)   +   \
            string(_DB_Off_b)   +   \
            string(_Skin)       +   \
            string(_Enh_Str)    +   \
            string(_Skin_Type)  +   \
            string(_ARAdjust)


mod_preset = current != _defaults ? True : mod_preset

Def_N1     = ""
Def_N2     = """Deen("a3d", S_Radius, S_Str, 3*C_Str, T_Str, C_Str, S_Dist, 9)"""
Def_E1     =   "UnFilter(E_Str_X, E_Str_Y).Addgrain(E_Str_N,0,0)"
Def_E2     =   "ColorYUV(off_Y = E_Str_B)"
Def_M      = """Deen("a2d", 1, M_Str   , 0, 0, 0, 0, 0)"""
Def_LP     = """Deen("a2d", 2, LP_Str  , 0, 0, 0, 0, 0)"""
Def_DR     = """Deen("a2d", 2, DR_Str  , 0, 0, 0, 0, 0)"""

N1         = Default(N1, Def_N1)
N2         = Default(N2, Def_N2)
E1         = Default(E1, Def_E1)
E2         = Default(E2, Def_E2)
M          = Default(M , Def_M )
LP         = Default(LP, Def_LP)
DR         = Default(DR, Def_DR)


D_process2 = (DS_Enh == false || Ds_Enh_Thr == 0) ? false : true
D_process  = (LP == "" || LP_Str == 0 || D_Thr == 0) ? false : true
B_process  = (LP == "" || LP_Str == 0 || B_Thr == 0) ? false : true
E_process  = (E1 == "" && E2 == "") || (E_Str_X == 0 && E_Str_Y == 0 && E_Str_B == 0 && E_Auto_Str == false) ? false : true
M_process  = (M  == "" || M_Str == 0 || M_Thr == 0) ? false : true

Assert(isyv12(input) == true, chr(10) + "This is not an YV12 clip ! Please convert color space to YV12 before using"
      \                               + " HybridFuPP" + chr(10))

Assert((Width(input)%4 != 0 || Height(input)%4 != 0)  == false, chr(10) + "Width and height (source) must be dividable by 4"\
                                                                        + " if you want to use HybridFuPP ! Please Crop if "\
                                                                        + "necessary !" + chr(10))

Assert(((Width(input)%8 != 0 || Height(input)%8 != 0) && Deblock) == false, chr(10) + "Width and height (source) must be "  \
                                                                                    + "dividable by 8 if you want to use "  \
                                                                                    + "deblocking ! Please Crop if "        \
                                                                                    + "necessary !" + chr(10))

Assert((MP_Mode!=2 && DB_M_Only) == false, chr(10) + "Deblocking Motion Only can only be when MP_Mode = 2" + chr(10))

Bl_Size    = 0
Bl_Size    = (Width%8  == 0 && Height%8  == 0) ? 8  : Bl_Size
Bl_Size    = (Width%16 == 0 && Height%16 == 0) ? 16 : Bl_Size
Bl_Size    = (M_Process || findstr(Ucase(show),"M") != 0) ? Bl_Size : 1

Assert(Bl_Size != 0, chr(10) + "Width and height (destination) must be dividable by 8 if you want to show motion or use "
      \                      + "motion processing" + chr(10))

_input     = Deblock && DB_M_Only == false ? input.Deblock(DB_Q, DB_Off_A, DB_Off_B) : input
Resizer2   = Resizer < 2 ? 0 : ceil((Resizer-2)/2)
Static     = Eval("_input." + (N1 !="" ? N1 + "." : N1) + "Resizer(width, height, Resizer)"  + (N2 !="" ? "." + N2 : N2))
Static2    = Eval("_input." + (N1 !="" ? N1 + "." : N1) + "Resizer(width, height, Resizer2)" + (N2 !="" ? "." + N2 : N2))
clip       = Fast ? Static : _input.Resizer(width, height, Resizer)

global Null_Mask = BlankClip(1, width, height, color=$000000, pixel_type="yv12")

D          = (findstr(Ucase(show),"D") != 0 || D_process) ? DM(clip, D_Thr) : Null_Mask
D2         = mt_logic(mt_lutf(clip, clip, "avg", "x 75 <= 255 0 ?"), mt_logic(DM(Clip, DS_Enh_Thr), \
                                                                              DM(Clip, D_Thr+8),"xor"), "and")
B          = (show != "" || B_process) ? BM(clip, B_Thr) : NOP()
LM         = NOP()
LM         = (D_process && B_process == false) ? D : LM
LM         = (B_process && D_process == false) ? B : LM
LM         = (B_process && D_process) ? mt_Logic(D, B, "or") : LM
EM         = (findstr(Ucase(show),"E") != 0 || E_process || Dering) ? EM(clip, EM_Mode, E_thr)                : Null_Mask
MM         = (findstr(Ucase(show),"M") != 0 || (M_process && MP_Mode == 2)) ? MM(clip, M_Thr, M_SCD, Bl_Size) : Null_Mask
RM         = (findstr(Ucase(show),"R") != 0 || Dering) ? DR_Radius(EM,DR_Radius,0)                            : Null_Mask
SM         = (findstr(Ucase(show),"S") != 0 || Skin) ? (E_process ? mt_logic(EM,SM(clip, Skin_Type),"andn")   :             \
                                                        SM(clip, Skin_Type))                                  : Null_Mask
BA         = (findstr(Ucase(show),"A") != 0 || ARAdjust) ? BA(input).pointresize(width,height)                : Null_Mask

Luma       = (B_process || D_process)    ? Eval("Static2." + LP) : NOP()
Enhanced   = (Skin || D_Process2) ? _input.Resizer(width, height, 5).sharpen(Enh_Str*0.15).addgrain(Enh_str,0,0) : NOP()
Edges      = E_process                   ? Eval("Clip." + (E1 !="" ? E1 + "." : E1) + "Resizer(width, height, Resizer)"     \
                                                + (E2 !="" ? "." + E2 : E2)) : NOP()
DeRinging  = Dering                      ? Eval("Clip." + DR)    : NOP()
Motion     = (M_process && MP_Mode == 2) ? (DB_M_Only ? Eval("Static2." + M ).Deblock(DB_Q, DB_Off_A, DB_Off_B) :           \
                                            Eval("Static2." + M )) : NOP()
Final      = ARAdjust                    ? mt_Merge(Static, Static2,   BA)         : Static
Final      = (B_process || D_process)    ? mt_Merge(Final,  Luma,      LM)         : Final
Final      = D_Process2                  ? mt_Merge(Final,  Enhanced,  D2)         : Final
Final      = Dering                      ? mt_Merge(Final,  DeRinging, RM)         : Final
Final      = Skin                        ? mt_Merge(Final,  Enhanced,  SM)         : Final
Final      = E_process                   ? mt_Merge(Final,  Edges,     EM)         : Final
Final      = (M_process && MP_Mode == 2) ? mt_Merge(Final,  Motion,    MM)         : 
      \      (M_process && MP_Mode == 1) ? MDenoise(Final, M_Thr, M_SCD, Bl_Size) : Final

return (show == "") ? Final : Show(Final, EM, MM, RM, D, D2, B, SM, BA, show, width, height, Fast, Dering, Deblock, MP_Mode,\
                                   EM_Mode, DB_Q, DB_Off_a, DB_Off_b, M_Thr, M_SCD, E_Thr, D_Thr, B_Thr, Resizer, S_Str,    \
                                   T_Str, S_Radius, S_Dist, M_Str, E_Auto_Str, E_Str_X, E_Str_Y, E_Str_B, E_Str_N, LP_Str,  \
                                   DR_Str, DR_Radius, C_Str , Preset, mod_preset, Skin, Enh_Str, ARAdjust, Skin_Type,       \
                                   DS_Enh, DS_Enh_Thr, DB_M_Only)
}

Function EM(clip i, int mode, int e_th)
{
e_mask = mode == 1 ? mt_makediff(i.blur(1.58).blur(1.58),i).mt_binarize(threshold=135).mt_inflate().mt_inflate() :
     \   mode == 2 ? mt_logic(i.mt_binarize(105,upper=true).mt_expand(),i.mt_binarize(110,upper=false).mt_expand(),"and").  \
                     mt_deflate() : NOP()
return e_mask
}


Function RM(clip i, dr_rad)
{
return mt_logic(i,i.DR_Radius(DR_rad,1),"xor").mt_binarize(upper=false)
}


Function DR_Radius(clip i, int dr_rad, int count)
{
return count > dr_rad ? i : DR_Radius(i.mt_expand(), dr_rad, count+1)
}


Function MM(clip i, int m_th, int scd, int bl_sz)
{
return mt_Binarize(i.MVMask(MVAnalyse(i, isb=false, lambda=1000, blksize=bl_sz), ml=m_th, Gamma=50, ThSCD1=scd, thSCD2=135),\
                   Upper=False, Threshold=30)
}


Function DM(clip i, int d_th)
{
return mt_Binarize(i, threshold = d_th, upper=true).mt_deflate()
}


Function BM(clip i, int b_th)
{
return mt_Binarize(i, threshold = b_th, upper = false).mt_inpand()
}


Function BA(clip i)
{
global BA_i = i
return scriptclip(BA_i, "averageluma() > 56 ? subtract(BA_i,BA_i.unfilter(-255,-255)).mt_expand().mt_binarize(upper=true,127) : subtract(BA_i,BA_i.unfilter(-255,-255)).mt_expand().mt_binarize(upper=true,126)")
}


Function SM(clip i, int sk_type)
{
global SM_i = i
global SM_1 = scriptclip(Skin_t1(SM_i),  """(averageluma() > 52 ? Null_Mask : Skin_t1(SM_i))""")
global SM_2 = scriptclip(Skin_t2(SM_i),  """(averageluma() > 52 ? Null_Mask : Skin_t2(SM_i))""")
return sk_type==1 ? SM_1 : (sk_type==2 ? SM_2 : conditionalfilter(i, SM_1, SM_2,"averageluma(SM_1)",">","averageluma(SM_2)"))
}


Function Skin_t1(clip i)
{
y    =        i.mt_lut("x 57 <= x 160 >= | 0 255 ?")
u    = i.utoy().mt_lut("x 100 <= x 125 >= | 0 255 ?") 
v    = i.vtoy().mt_lut("x 141 <= x 171 >= | 0 255 ?")
uv   = mt_logic(u,v,"and").pointresize(width(i),height(i))
yuv  = mt_logic(uv,y,"and")
return yuv
}


Function Skin_t2(clip i)
{
y    =        i.mt_lut("x 60 <= x 130 >= | 0 255 ?") 
u    = i.utoy().mt_lut("x 96 <= x 132 >= | 0 255 ?")
v    = i.vtoy().mt_lut("x 130 <= x 152 >= | 0 255 ?")
uv   = mt_logic(u,v,"and").pointresize(width(i),height(i))
yuv  = mt_logic(uv,y,"and")
return yuv
}


Function MDenoise(clip i, int m_th, int scd, int bl_sz)
{
b1 = i.MVAnalyse(isb = true,  blksize = bl_sz, lambda = 1000, delta = 1)
f1 = i.MVAnalyse(isb = false, blksize = bl_sz, lambda = 1000, delta = 1)
return i.MVDenoise(b1, f1, tht = m_th, thsad = scd)
}


Function Resizer(clip i, int w, int h, int t)
{
return  (t == 0) ?  BilinearResize(i, w, h)               : 
      \ (t == 1) ?  BicubicResize( i, w, h, 0.333, 0.333) : 
      \ (t == 2) ?  BicubicResize( i, w, h, 0.2  , 0.4  ) : 
      \ (t == 3) ?  BicubicResize( i, w, h, 0    , 0.5  ) : 
      \ (t == 4) ?  BicubicResize( i, w, h, 0    , 0.6  ) : 
      \ (t == 5) ?  LanczosResize( i, w, h)               : 
      \ (t == 6) ? Spline36Resize( i, w, h)               : Nop()
}


Function Show(clip i, clip em, clip mm, clip rm, clip dm, clip d2, clip bm, clip sm, clip ba, string sh, int w, int h,      \
              bool Fast, bool Dering, bool deblock, int MP_Mode, int EM_Mode, int DB_Q, int DB_Off_a, int DB_Off_b,         \
              int M_Thr, int M_SCD, int E_Thr, int D_Thr, int B_Thr, int Resizer, int S_Str, int T_Str, int S_Radius,       \
              float S_Dist, int M_Str, bool E_Auto_Str, int E_Str_X , int E_Str_Y, int E_Str_B, int E_Str_N, int LP_Str,    \
              int DR_Str, int DR_Radius, int C_Str, string Preset, bool mod_preset, bool Skin, int Enh_Str, bool ARAdjust,  \
              int Skin_Type, bool DS_Enh, int DS_Enh_Thr, bool DB_M_Only)
{
MM_Blank = BlankClip(1, w, h, color=$FFFF0F, pixel_type="yv12")
DM_Blank = BlankClip(1, w, h, color=$FFF0,   pixel_type="yv12")
D2_Blank = BlankClip(1, w, h, color=$5FFF,   pixel_type="yv12")
BM_Blank = BlankClip(1, w, h, color=$FF0A,   pixel_type="yv12")
EM_Blank = BlankClip(1, w, h, color=$FF0808, pixel_type="yv12")
RM_Blank = BlankClip(1, w, h, color=$FFBF0A, pixel_type="yv12")
SM_Blank = BlankClip(1, w, h, color=$FF00C0, pixel_type="yv12")
AM_Blank = BlankClip(1, w, h, color=$FFA0F0, pixel_type="yv12")

EShow = FindStr(UCase(sh),"E")
MShow = FindStr(UCase(sh),"M")
RShow = FindStr(UCase(sh),"R")
DShow = FindStr(UCase(sh),"D")
XShow = FindStr(UCase(sh),"X")
BShow = FindStr(UCase(sh),"B")
PShow = FindStr(UCase(sh),"P")
SShow = FindStr(UCase(sh),"S")
AShow = FindStr(UCase(sh),"A")


mod = mod_preset ? "(mod)" : ""

i = EShow != 0 ? Overlay(i, EM_Blank, Mask=em, Mode="chroma", opacity=0.6) : i
i = MShow != 0 ? Overlay(i, MM_Blank, Mask=mm, Mode="blend" , opacity=0.3) : i
i = RShow != 0 ? Overlay(i, RM_Blank, Mask=rm, Mode="blend" , opacity=0.7) : i
i = DShow != 0 ? Overlay(i, DM_Blank, Mask=dm, Mode="blend" , opacity=0.4) : i
i = XShow != 0 ? Overlay(i, D2_Blank, Mask=d2, Mode="blend" , opacity=0.2) : i
i = BShow != 0 ? Overlay(i, BM_Blank, Mask=mt_Logic(bm, bm.mt_Inpand(), "xor"), Mode="blend", Opacity=1) : i
i = SShow != 0 ? Overlay(i, SM_Blank, Mask=sm, Mode="blend", Opacity=0.2) : i
i = AShow != 0 ? Overlay(i, AM_Blank, Mask=ba, Mode="blend", Opacity=0.4) : i

i = EShow != 0 ? i.SubTitle("Edges" ,                  text_color=$FF0808, size=14, x=16, y=h-104)  : i
i = MShow != 0 ? i.SubTitle("Motion",                  text_color=$FFFF0F, size=14, x=16, y=h-92)   : i
i = RShow != 0 ? i.SubTitle("DeRinging",               text_color=$FFBF0A, size=14, x=16, y=h-80)   : i
i = DShow != 0 ? i.SubTitle("Dark areas",              text_color=$FFF0,   size=14, x=16, y=h-68)   : i
i = XShow != 0 ? i.SubTitle("Dark Scenes Enhancement", text_color=$5FFF,   size=14, x=16, y=h-56)   : i
i = BShow != 0 ? i.SubTitle("Bright areas",            text_color=$FF0A,   size=14, x=16, y=h-44)   : i
i = BShow != 0 ? i.SubTitle("Skin",                    text_color=$FF00C0, size=14, x=16, y=h-32)   : i
i = BShow != 0 ? i.SubTitle("Auto Resizer Adjustment", text_color=$FFA0F0,   size=14, x=16, y=h-20) : i

i = PShow != 0 ? i.SubTitle("General Parameters" ,               text_color=$FFFFFF,size=13,x=16,y=0)                       : i
i = PShow != 0 ? i.SubTitle("Preset     = " + string(Preset)+mod,text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=12)   : i
i = PShow != 0 ? i.SubTitle("Resizer    = " + string(Resizer),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=22)   : i
i = PShow != 0 ? i.SubTitle("Fast       = " + string(fast),      text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=32)   : i

i = PShow != 0 ? i.SubTitle("Denoising N2 (no motion)" ,         text_color=$FFFFFF,size=13,x=16,y=45)                      : i
i = PShow != 0 ? i.SubTitle("S_Str      = " + string(S_Str),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=57)   : i
i = PShow != 0 ? i.SubTitle("T_Str      = " + string(T_Str),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=67)   : i
i = PShow != 0 ? i.SubTitle("S_Radius   = " + string(S_Radius),  text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=77)   : i
i = PShow != 0 ? i.SubTitle("S_Dist     = " + string(S_Dist),    text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=87)   : i
i = PShow != 0 ? i.SubTitle("C_Str      = " + string(C_Str),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=97)   : i

i = PShow != 0 ? i.SubTitle("Denoising M (motion)" ,             text_color=$FFFFFF,size=13,x=16,y=110)                     : i
i = PShow != 0 ? i.SubTitle("MP_Mode    = " + string(MP_Mode),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=122)  : i
i = PShow != 0 ? i.SubTitle("M_Thr      = " + string(M_Thr),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=132)  : i
i = PShow != 0 ? i.SubTitle("M_SCD      = " + string(M_SCD),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=142)  : i
i = PShow != 0 ? i.SubTitle("M_Str      = " + string(M_Str),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=152)  : i

i = PShow != 0 ? i.SubTitle("Luma processing LP" ,               text_color=$FFFFFF,size=13,x=16,y=165)                     : i
i = PShow != 0 ? i.SubTitle("D_Thr      = " + string(D_Thr),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=177)  : i
i = PShow != 0 ? i.SubTitle("B_Thr      = " + string(B_Thr),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=187)  : i
i = PShow != 0 ? i.SubTitle("LP_Str     = " + string(LP_Str),    text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=197)  : i
i = PShow != 0 ? i.SubTitle("DS_Enh     = " + string(DS_Enh),    text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=207)  : i
i = PShow != 0 ? i.SubTitle("DS_Enh_Thr = " + string(DS_Enh_Thr),text_color=$FFFFFF,font="COURIER NEW",size=12,x=18,y=217)  : i

i = PShow != 0 ? i.SubTitle("Deblocking" ,                       text_color=$FFFFFF,size=13,x=174,y=0)                      : i
i = PShow != 0 ? i.SubTitle("Deblock    = " + string(Deblock),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=12)  : i
i = PShow != 0 ? i.SubTitle("DB_M_Only  = " + string(DB_M_Only), text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=22)  : i
i = PShow != 0 ? i.SubTitle("DB_Q       = " + string(DB_Q),      text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=32)  : i
i = PShow != 0 ? i.SubTitle("DB_Off_a   = " + string(DB_Off_a),  text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=42)  : i
i = PShow != 0 ? i.SubTitle("DB_Off_b   = " + string(DB_Off_b),  text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=52)  : i

i = PShow != 0 ? i.SubTitle("Edges E1+E2 / Dering DR" ,          text_color=$FFFFFF,size=13,x=174,y=65)                     : i
i = PShow != 0 ? i.SubTitle("EM_Mode    = " + string(EM_Mode),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=77)  : i
i = PShow != 0 ? i.SubTitle("E_Thr      = " + string(E_Thr),     text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=87)  : i
i = PShow != 0 ? i.SubTitle("E_Auto_Str = " + string(E_Auto_Str),text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=97)  : i
i = PShow != 0 ? i.SubTitle("E_Str_X    = " + string(E_Str_X),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=107) : i
i = PShow != 0 ? i.SubTitle("E_Str_Y    = " + string(E_Str_Y),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=117) : i
i = PShow != 0 ? i.SubTitle("E_Str_B    = " + string(E_Str_B),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=127) : i
i = PShow != 0 ? i.SubTitle("E_Str_N    = " + string(E_Str_N),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=137) : i
i = PShow != 0 ? i.SubTitle("Dering     = " + string(Dering),    text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=147) : i
i = PShow != 0 ? i.SubTitle("DR_Str     = " + string(DR_Str),    text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=157) : i
i = PShow != 0 ? i.SubTitle("DR_Radius  = " + string(DR_Radius), text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=167) : i

i = PShow != 0 ? i.SubTitle("'Skin' Processing" ,                text_color=$FFFFFF,size=13,x=174,y=180)                    : i
i = PShow != 0 ? i.SubTitle("Skin       = " + string(Skin),      text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=192) : i
i = PShow != 0 ? i.SubTitle("Skin_Type  = " + string(Skin_Type), text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=202) : i

i = PShow != 0 ? i.SubTitle("Enhancer (Skin & Dark Sc.)" ,       text_color=$FFFFFF,size=13,x=174,y=215)                    : i
i = PShow != 0 ? i.SubTitle("Enh_Str    = " + string(Enh_Str),   text_color=$FFFFFF,font="COURIER NEW",size=12,x=176,y=227) : i

return i
}
