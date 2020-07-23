function RestoreAnimation ( clip input, int "Xres", int "Yres", int "Xres2", int "Yres2", float "linestr", int "dQuant")
{

o       = input
Xres    = default( Xres,     1280 )
Yres    = default( Yres,      720 )
linestr = default( linestr,  0.15 )
dQuant  = default( dQuant,     33 )
Xres2   = default( Xres2, 1920)
Yres2   = default( Yres2, 1080)


# Darken the lines before hand, otherwise they fade into nothingness
o = o.Toon(linestr)

# Remove any blocking. Tweak to tastes if it's too strong
o = o.Deblock(quant=dQuant, bOffset=14)

# Get rid of most of the artifacts
o = o.dfttest()

# Antialias the lines so they don't look like crap, and then upscale
# so that the next step filters better.
o = o.AAA(Chroma=true)
o = o.Spline36Resize(Xres2,Yres2)

# Light blurring and sharpen the edges
o = o.aWarpSharp(depth=24,blurlevel=4,thresh=0.3,cm=1)
o = o.LimitedSharpenFaster(edgemode=1,strength=200)

# Get rid any other artifacts
o = o.deen("a2d",3,6,6)
o = o.Dehalo_alpha()

# Scale to intended resolution
o = o.Spline36Resize(Xres,Yres)

Return(o)
}