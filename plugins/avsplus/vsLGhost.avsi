Function vsLGhost(clip clip, int_array_nz "mode", int_array_nz "shift", int_array_nz "intensity", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/vsLGhost.dll")
        vsLGhost(clip, mode=mode, shift=shift, intensity=intensity, y=y, u=u, v=v, opt=opt)
}