Function vsLGhost(clip clip, int_array "mode", int_array "shift", int_array "intensity", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/vsLGhost.dll")
        vsLGhost(clip, mode, shift, intensity, y, u, v, opt)
}