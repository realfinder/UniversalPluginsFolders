# AMVIVTC() by Zarxrax
# v1.01 2009-01-07
#
#   AMVIVTC is very simple, with only one primary argument: mode
#   Some additional arguments are available however: tfmmode, pp, and decimate
#   mode has three settings, ranging from 1-3. The mode is actually just a preset which configures appropriate values for the pp and decimate settings.
#       mode=1 should be used when you are encoding your footage to a lossless file. It is equivalent to pp=1, decimate=3
#       mode=2 should be used when you edit avs scripts directly.
#       mode=3 is suitable for when you are making proxy files for "bait-and-switch" editing.
#   decimate specifies the decimation method to use
#       decimate=0 disables decimation
#       decimate=1 uses a high quality decimation technique that does not support random access. It should only be used when converting your scripts to lossless files.
#       decimate=2 uses a decimation technique that supports random access.
#   tfmmode specifies one of 7 different field matching methods. If you think fields are being matched incorrectly, try changing this to 2 or 5, but don't mess with this setting unless you know what you are doing.
#   pp specifies the postprocessing method to use on combed frames. 
#       pp=0 disables postprocessing
#       pp=1 is a very high quality but slow method
#       pp=2 is another good but slow method that you may find more pleasing than pp=1
#       pp=3 a fast method that is appropriate when editing avs files directly
#################################################################################

function AMVIVTC (clip c, int "mode", int "decimate", int "tfmmode", int "pp") {
    mode	= default(mode, 1)
    tfmmode = default(tfmmode, 1)
    pp = (mode==1 || mode==3) ? default(pp, 1) : default(pp,3)
    decimate = (mode==1) ? default(decimate, 1) : default(decimate,2)
    dmode = (decimate==2) ? 0 : 1 

    Deinted = c.TDeint(edeint=c.nnedi(),emask=c.TMM())
    Deinted2 = c.TDeint(mode=2, mtnmode=3, blim=100)

    video = (pp==0) ? c.TFM(mode=tfmmode, PP=0,slow=2) : c
    video = (pp==1) ? c.TFM(mode=tfmmode, PP=2,slow=2,clip2=Deinted) : video
    video = (pp==2) ? c.TFM(mode=tfmmode, PP=2,slow=2,clip2=Deinted2) : video
    video = (pp==3) ? c.TFM(mode=tfmmode, PP=2, slow=2) : video
    
    video = (decimate==1 || decimate==2) ? video.TDecimate(mode=dmode) : video
    
    #for testing
    #video = video.subtitle("mode="+String(mode)+"; tfmmode="+String(tfmmode)+"; pp="+String(pp)+"; decimate="+String(decimate)+"; dmode="+String(dmode))
    return video
}

############################
# AMVDeint() by Zarxrax
# v1.0 2009-01-07
#
#   AMVDeint() is a VERY simple filter which simple calls different deinterlacing methods based on the mode setting.
#   These deinterlacers can not be tweaked in any way, but it gives you an easy way to try multiple types of deinterlacers without having to remember lots of commands.
#   mode is the only setting, and can be a value from 0 to 4, with 0 being the fastest method, and 4 being the slowest.
##########################################################################################################################

function AMVDeint (clip c, int "mode") {
    mode = default(mode, 4)
    parity = c.GetParity ? 1 : 0
    video = (mode==0) ? c.LeakKernelDeint(order=parity,threshold=10) : c
    video = (mode==1) ? c.SangNom(order=parity,aa=32) : video
    video = (mode==2) ? c.Tdeint() : video
    video = (mode==3) ? c.TDeint(mode=2, mtnmode=3, blim=100) : video
    video = (mode==4) ? c.TDeint(edeint=c.nnedi(),emask=c.TMM()): video
    
    return video
}