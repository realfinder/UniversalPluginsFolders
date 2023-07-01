Function BlockDetect(clip input, int "period_min", int "period_max", int_array "planes", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BlockDetect.dll")
        BlockDetect(input, period_min, period_max, planes=planes, opt=opt)
}