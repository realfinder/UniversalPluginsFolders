Function ClipClop(clip source, clip_array_nz sourcex, string "Cmd",string "SCmd", bool "Show", bool "Ver",int "dv", bool "NoErr",string "Nickname",bool "Purge")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/ClipClop.dll")
        ClipClop(source, sourcex, Cmd=Cmd, SCmd=SCmd, Show=Show, Ver=Ver, dv=dv, NoErr=NoErr, Nickname=Nickname, Purge=Purge)
}