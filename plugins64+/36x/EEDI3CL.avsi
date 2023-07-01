Function EEDI3CL(clip input, int "field", bool "dh", int_array "planes", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", bool "hp", bool "ucubic", bool "cost3", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", clip "sclip", int "opt", int "device", bool "list_device", bool "info", bool "luma")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/EEDI3CL.dll")
        EEDI3CL(input, field, dh, planes=planes, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, hp=hp, ucubic=ucubic, cost3=cost3, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, vthresh2=vthresh2, sclip=sclip, opt=opt, device=device, list_device=list_device, info=info, luma=luma)
}