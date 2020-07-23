
function SSXSharpen(clip input, int "ssw", int "ssh", int "xstren", int "xthresh") {
##
## SSXSharpen
## Sharpens the picture using supersampling techniques.
##
## Usage: SSXSharpen()
##
## Parameters:
ssw      = Default(ssw, 4)        # supersample factor horizontally, 0-inf
ssh      = Default(ssh, 4)        # supersample factor vertically, 0-inf
xstren   = Default(xstren, 255)   # xsharpening strength, 0-255
xthresh  = Default(xthresh, 255)  # xsharpening threshold, 0-255
##

input.LanczosResize(input.width*ssw, input.height*ssh)
XSharpen(xstren, xthresh)
LanczosResize(input.width, input.height)
}


function SSXSharpen2(clip input, int "ssw", int "ssh", int "xstren", int "xthresh") {
##
## SSXSharpen
## Sharpens the picture using supersampling techniques.
##
## Usage: SSXSharpen()
##
## Parameters:
ssw      = Default(ssw, 4)        # supersample factor horizontally, 0-inf
ssh      = Default(ssh, 4)        # supersample factor vertically, 0-inf
xstren   = Default(xstren, 255)   # xsharpening strength, 0-255
xthresh  = Default(xthresh, 255)  # xsharpening threshold, 0-255
##

input.Spline36Resize(input.width*ssw, input.height*ssh)
XSharpen(xstren, xthresh)
Spline36Resize(input.width, input.height)
}