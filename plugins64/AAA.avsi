# AAA - AnimeAntiAliasing
#
# Thanks @ Didée, mf, Akirasuto, SpikeSpiegel & ScharfisBrain...
#________________________________________________________________________________________
#
# Usage: AAA(Xres, Yres, Xshrp, Yshrp, Us, Ds, chroma)
#________________________________________________________________________________________
#
# Xres/Yres = The final resolution... InputSize = OutputSize is the default
#
# Xshrp/Yshrp = Unfilter strength... Settings of 15,15 are the defaults
#
# Us = Resizer for upsampling... 0 = PointResize (default) / 1 = Lanczos
#
# Ds = Resizer for downsampling... 0 = Bilinear (default) / 1 = Bicubic / 2 = Lanczos
#
# Chroma = Enable/disable chroma antialiasing... Disable = false (default) / enable = true
#________________________________________________________________________________________
#
# Example...
#
# Import("C:\Programme\AviSynth 2.5\plugins\AAA.avs")
#
# AAA(720,576,20,20,1,2,chroma=false)
#________________________________________________________________________________________

function AAA(clip clp, int "Xres", int "Yres", int "Xshrp", int "Yshrp", 
\ int "US", int "DS", bool "chroma")
      {
        clp = clp.isYV12() ? clp : clp.ConvertToYV12()
        ox = clp.width
        oy = clp.height
        Xres  = default(Xres,  ox)
        Yres  = default(Yres,  oy)
        us  = default(us, 1)
ds = default(ds, 2)
        Xshrp = default(Xshrp, 15)
        Yshrp = default(Yshrp, 15)
chroma = default(chroma, false)
        
        us==0 ? clp.PointResize(ox*2,oy*2) : clp.LanczosResize(ox*2,oy*2)

        TurnLeft()
        SangNom()

        TurnRight()
        SangNom()

        ds==0 ? BilinearResize(Xres,Yres) : 
\ ds==1 ? BicubicResize(Xres,Yres) : 
\ LanczosResize(Xres,Yres)

        Unfilter(Xshrp,Yshrp)

        chroma ? MergeChroma(clp.Lanczosresize(Xres,Yres)) : last

        }
