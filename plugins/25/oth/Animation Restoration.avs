#####################################################################
# Animation Restoration v 1.06 (Jan 23, 2008)                       #
# aka "Remation" (No idea how I came up with the name)              #
# Created by Sagekilla                                              #
#                                                                   #
# WHAT IT DOES:                                                     #
# Filters most animated content to remove blocking, noise, color    #
# artifacts, ringing, haloing, sharpen and antialias lines walk     #
# your dog, and generally make your video look a lot better.        #
#                                                                   #
# The defaults seem to work very well across most of my animated    #
# content. Only setting you'll need to provide is width and height. #
# Otherwise, if you have any questions/comments/suggestions/etc     #
# please see me on MSN. My email for it is zeratual2004@hotmail.com #
#                                                                   #
# Required plugins: aWarpSharp.avsi /  AAA.avsi / Deblock.dll       #
#                   deen.dll / dftest.dll / DeHalo_Alpha.avsi       #
#                   LimitedSharpenFaster.avsi / Toon.dll            #
#                                                                   #
#                                                                   #
#####################################################################

function Remation ( clip input, int "Xres", int "Yres", float "scale", float "linestr", 
 \                  int "dQuant", int "bOffset", int "dBlur", int "qBlur", float "thBlur", 
 \                  int "shrpstr",  bool "Deblock",  bool "AA", bool "Sharp", bool "Dehalo" ) 
{
o       = input
Xres    = default( Xres,     1280 ) # Output width
Yres    = default( Yres,      720 ) # Output height
scale   = default( scale,     1.5 ) # Scales resolution for filtering
linestr = default( linestr,  0.15 ) # Line darken strength
dQuant  = default( dQuant,     33 ) # Deblock strength
bOffset = default( bOffset,     0 ) # Deblock Offset
dBlur   = default( dBlur,      12 ) # Blur strength
qBlur   = default( qBlur,       4 ) # Blur "quality"
thBlur  = default( thBlur,    0.3 ) # Blur threshold
shrpstr = default( shrpstr,   200 ) # Sharpen strength
Deblock = default( deblock,  true ) # Toggle deblock
AA      = default( AA,       true ) # Toggle AA
Sharp   = default( Sharp,    true ) # Toggle Sharpening
Dehalo  = default( Dehalo,   true ) # Toggle Dehaloing
Xres2   = Floor(m2(Xres*scale))
Yres2   = Floor(m2(Yres*scale))


# Darken the lines before hand with toon, otherwise they fade.
# Then remove any blocking. Tweak to tastes if it's too strong.
o = (linestr > 0) ? o.Toon(linestr) : o
o = (Deblock==true) ? o.Deblock(quant=dQuant, bOffset=bOffset) : o


# Get rid of most of the color artifacts and noise.
o = o.dfttest()


# Antialias the lines so they don't look like crap, and
# then upscale so that the following steps filter better.
o = (AA==true) ? o.AAA(Chroma=true) : o
o = o.Spline36Resize(Xres2,Yres2)


# Light blurring and sharpen the edges
o = o.aWarpSharp(depth=dBlur,blurlevel=qBlur,thresh=thBlur,cm=1)
o = (Sharp==true) ? o.LimitedSharpenFaster(edgemode=1,strength=shrpstr) : o

# Get rid any other artifacts
o = o.deen("a2d",3,6,6)
o = o.Dehalo_alpha()


# Scale to intended resolution
o = o.Spline36Resize(Xres,Yres)

Return(o)
}

function m2(float num)
{
 return int(num / 2) * 2
}