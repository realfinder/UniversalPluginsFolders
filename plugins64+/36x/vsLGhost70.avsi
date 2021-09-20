Function vsLGhost(clip clip, int_array "mode", int_array "shift", int_array "intensity", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/vsLGhost.dll")
        vsLGhost(clip, mode=mode, shift=shift, intensity=intensity, y=y, u=u, v=v, opt=opt)
}