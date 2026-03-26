function GamMac(Clip c,int "LockChan",int "Scale",
      \ Float "RedMul",Float "GrnMul", Float "BluMul",
      \ Float "Th",Float "loTh",Float "hiTh",
      \ Float "LockVal",int "RngLim",Float "GamMax",
      \ Clip "dc",
      \ int "x",int "y",int "w",int "h",
      \ int "omin", int "omax",
      \ Bool "Show",int "Verbosity",Bool "Coords",
      \ Bool "Dither"
      \ )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/GamMac.dll") : LoadPlugin(AviSynthPluginsDir + "26/GamMac.dll")
        GamMac(c,LockChan,Scale,
      \ RedMul,GrnMul,BluMul,
      \ Th,loTh,hiTh,
      \ LockVal,RngLim,GamMax,
      \ dc,
      \ x,y,w,h,
      \ omin,omax,
      \ Show,Verbosity,Coords,
      \ Dither
      \ )
}