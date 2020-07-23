Deen for avisynth 2.5 - beta 2 - by MarcFD
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

deen is a set of assembly-optimised denoisers.
requires a ISSE capable cpu and YV12 colorspace.

use :
^^^^^
deen(string "name",int "mode",int "thrY",int "thrUV", float "ti")

name :
you choose the denoising method here.
default : "c3d"

mode :
with "c3d", it's the weight matrix.
- 0 <121> matrix (default)
- 1 <111> matrix (softer)
with other methods, it's the spatial raduis.
default : 0

thrY,UV :
luma (Y) and chroma (UV) thresholds.
higher values blend more. 
default : 10,12

ti :
temporal influence.
maximal mean local temporal difference
allowed to enable 3d filtering.
default is 3

methods
^^^^^^^
several methods are implemented :

- this release is a preview for the "c3d" mode.
it's fully functionnal, and i results are very
very close to vlad's Convolution3D filter.

- you can test "a3d"&"a2d" mode. it's my own
2d/3d denoising algo implemention. it's in beta-stage.
you can try deen("a3d",1,10,12) as an alternative 
to c3d with <111> matrix or deen("a2d",2,10,12) 
for 5x5 spatial filtering.

- "m2d" is in alpha-stage.
but you can take a look at deen("m2d",1,10,12)
(mmxed 2d msoften2 / 21x21 emulation )

02 dec 2002 - Copyright (C) MarcFD