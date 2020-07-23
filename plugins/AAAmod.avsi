# AAAmod
#
# Thanks @ SpikeSpiegel, Didée, mf, Akirasuto & ScharfisBrain...
#________________________________________________________________________________________
#
# Usage: AAAmod(Xres, Yres, Shrp, Us, Ds, chroma, Order, AAstr, ss_x, ss_y)
#________________________________________________________________________________________
#
# Xres/Yres = The final resolution... InputSize = OutputSize is the default
#
# Shrp = Unsharpmask strength... 30 is the default
#
# Us = Resizer for upsampling... 0 = PointResize (default) / 1 = Lanczos
#
# Ds = Resizer for downsampling... 0 = Bilinear (default) / 1 = Bicubic Catmull-Rom / 2 = Lanczos
#
# Chroma = Enable/disable chroma antialiasing... Disable = false (default) / enable = true
#
# Order = 0=Top Field, 1= Bottom Field, 2= Bob... default is 1
#
# AAstr = Anti-Aliasing strength in Sangnom... default is 48
#
# ss_x = Supersampling coefficient for x effective range 2.0-3.0... if using Pointresize then set to 2.0
#
# ss_y = Supersampling coefficient for y effective range 2.0-3.0... if using Pointresize then set to 2.0
#
#________________________________________________________________________________________
#
# Example...
#
#Import("C:\Programme\AviSynth 2.5\plugins\AAAmod.avs")
# 
# AAAmod(656,480,40,1,2,chroma=false,order=1,AAstr=48,ss_x=2.15,ss_y=2.25)
#________________________________________________________________________________________

function AAAmod(clip clp, int "Xres", int "Yres", int "Shrp",  
\ int "US", int "DS", bool "chroma", int "order", int "AAstr", float "ss_x", float "ss_y")
      {
        clp = clp.isYV12() ? clp : clp.ConvertToYV12()
        ox = clp.width
        oy = clp.height
        Xres  = default(Xres,  ox)
        Yres  = default(Yres,  oy)
        Shrp = default(Shrp, 30)
        us  = default(us, 1)
        ds = default(ds, 2)
        chroma = default(chroma, false)
        order = Default(order, 1) # 0=Top Field, 1= Bottom Field, 2= Bob
        AAstr = Default(AAstr, 48)
        ss_x = default(ss_x, 2) #For pointresize use 2.0
        ss_y = default(ss_y, 2) #For pointresize use 2.0

        xxs=round(ox*ss_x/8)*8
        yys=round(oy*ss_y/8)*8




        
        us==0 ? clp.PointResize(xxs,yys) : clp.Lanczos4Resize(xxs,yys)

        TurnLeft()
        SangNom(order,AAstr)


        TurnRight()
        SangNom(order,AAstr)



UnsharpMask(Shrp)
#LimitedSharpenFaster(ss_x=1.0,ss_y=1.0, Smode=4, strength=200)

        ds==0 ? BilinearResize(Xres,Yres) : 
\ ds==1 ? BicubicResize(Xres,Yres,0,.5) : 
\ LanczosResize(Xres,Yres)

        

        chroma ? MergeChroma(clp.Lanczosresize(Xres,Yres)) : last

        }