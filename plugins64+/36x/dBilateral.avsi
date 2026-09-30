Function dBilateral(clip clip, clip "ref", int_array "radius", float_array "thr", float_array "flat", float_array "wmin", float_array "subspl", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/dBilateral.dll")
        dBilateral(clip, ref, radius=radius, thr=thr, flat=flat, wmin=wmin, subspl=subspl, y=y, u=u, v=v, opt=opt)
}