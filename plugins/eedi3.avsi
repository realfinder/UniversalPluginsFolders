function eedi3(clip clip, int "field", bool "dh", bool "Y", bool "U", bool "V", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", bool "hp", bool "ucubic", bool "cost3", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", clip "sclip", int "threads", clip "mclip", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/eedi3.dll") : LoadPlugin(AviSynthPluginsDir + "26/eedi3.dll")
        eedi3(clip, field, dh, Y, U, V, alpha, beta, gamma, nrad, mdis, hp, ucubic, cost3, vcheck, vthresh0, vthresh1, vthresh2, sclip, threads, mclip, opt)
}

function eedi3_rpow2(clip clip, int "rfactor", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", bool "hp", bool "ucubic", bool "cost3", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", string "cshift", int "fwidth", int "fheight", float "ep0", float "ep1", int "threads", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/eedi3.dll") : LoadPlugin(AviSynthPluginsDir + "26/eedi3.dll")
        eedi3_rpow2(clip, rfactor, alpha, beta, gamma, nrad, mdis, hp, ucubic, cost3, vcheck, vthresh0, vthresh1, vthresh2, cshift, fwidth, fheight, ep0, ep1, threads, opt)
}