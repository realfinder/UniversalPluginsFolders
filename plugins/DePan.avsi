function DePan(clip clip, clip "data", float "offset", int "subpixel", float "pixaspect", bool "matchfields", int "mirror", int "blur", bool "info", string "inputlog")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/DePan.dll") : LoadPlugin(AviSynthPluginsDir + "26/DePan.dll")
        DePan(clip, data, offset, subpixel, pixaspect, matchfields, mirror, blur, info, inputlog)
}

function DePanInterleave(clip clip, clip "data", int "prev", int "next", int "subpixel", float "pixaspect", bool "matchfields", int "mirror", int "blur", bool "info", string "inputlog")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/DePan.dll") : LoadPlugin(AviSynthPluginsDir + "26/DePan.dll")
        DePanInterleave(clip, data, prev, next, subpixel, pixaspect, matchfields, mirror, blur, info, inputlog)
}

function DePanStabilize(clip clip, clip "data", float "cutoff", float "damping", float "initzoom", bool "addzoom", int "prev", int "next", int "mirror", int "blur", int "dxmax", int "dymax", float "zoommax", float "rotmax", int "subpixel", float "pixaspect", int "fitlast", float "tzoom", bool "info", string "inputlog", int "method")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/DePan.dll") : LoadPlugin(AviSynthPluginsDir + "26/DePan.dll")
        DePanStabilize(clip, data, cutoff, damping, initzoom, addzoom, prev, next, mirror, blur, dxmax, dymax, zoommax, rotmax, subpixel, pixaspect, fitlast, tzoom, info, inputlog, method)
}

function DePanScenes(clip clip, string "inputlog", int "plane")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/DePan.dll") : LoadPlugin(AviSynthPluginsDir + "26/DePan.dll")
        DePanScenes(clip, inputlog, plane)
}

