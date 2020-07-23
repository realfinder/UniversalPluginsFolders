function Stabilisemod2_all(clip o, bool "padding", float "repthr", float "difthr")
{
LoadPlugin(AviSynthPluginsDir + "CelStabilise/CelBackground_23Sep05B.dll")
import(AviSynthPluginsDir + "CelStabilise/CelStabilise.avs")
difthr = default (difthr, 30)
global  cell_s_padding = padding
global  cell_s_repthr  = repthr
global  cell_s_difthr  = difthr
ScriptClip(o, """
                                                sc=last.cFrameDiff(prevf=false, chroma=false, denoise=true, nt=1)
                                                sc < cell_s_difthr ? trim(0,current_frame-2) ++ trim(current_frame-1, FrameCount()-1).Stabilisemod(cell_s_padding, cell_s_repthr) : last
""")
}

function Stabilisemod2(clip o, bool "padding", float "repthr")
{
LoadPlugin(AviSynthPluginsDir + "CelStabilise/CelBackground_23Sep05B.dll")
import(AviSynthPluginsDir + "CelStabilise/CelStabilise.avs")
global  c_min_scene_size = 5
global  c_scene_num = 1
global  c_scene_begin = 0
global  c_scene_end   = -1
global  cell_s_padding = padding
global  cell_s_repthr  = repthr
ScriptClip(o, """
source=last
vectors     = source.MSuper(pel=2, hpad=12, vpad=12, rfilter=2,    isse=true).MAnalyse(isb=false, search=3, searchparam=3, isse=true,    lambda=440, dct=4)
source.MSCDetection(vectors, thscd1=248, thscd2=50)

    # detect new scene
    global  newscene = (current_frame < c_scene_end + c_min_scene_size) ? false \
                                                                    : (AverageLuma>250)

    # remember where scene started for subsequent filtering.
    # this probably doesn't work well if not accesing the clip linearly.
    c_scene_begin = newscene ? c_scene_end+1 : c_scene_begin
    c_scene_end   = newscene ? current_frame-1    : c_scene_end
    global  c_scene_num  = (newscene && (current_frame > 0)) ? c_scene_num+1 : c_scene_num
    c_scene_num > 1 ? source.trim(0,c_scene_begin-1) ++ source.trim(c_scene_begin,c_scene_end) ++ source.trim(c_scene_end+1,source.FrameCount()-1).Stabilisemod(cell_s_padding, cell_s_repthr) : source
""")
RequestLinear(8,10, 5, false, false)
}