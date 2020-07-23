############################################################################
# This is a script which works with SSIQ. The basic problem with SSIQ is
# that it can alter the color on the entire picture, which is a very very
# bad thing.
# All we want to do is remove rainbows, while leaving everything else alone.
# This filter first applies SSIQ to the entire picture. Then it locates the
# edges.
# Finally, it layers ONLY the de-rainbowed edges onto the orig video.
#
#
# Filter Requirements: SSIQ()
############################################################################
#LoadPlugin("mt_masktools.dll")
#LoadPlugin("SSIQ.dll")

#input = DirectShowSource("...")
#SmartSSIQ(input, 1)

function SmartSSIQ(clip input, int "strength")
{
strength = default(strength, 1) #processing strength, 0-255

# apply rainbow remover to the entire video
derainbow = input.SSIQ(11, 300, false)

# create an edge mask from the rainbow video
lutexpr = "x .2 ^ 110 *"
# uncomment to use masktools 1
edgemask = input.edgemask(thY1=1, thY2=255, type="sobel").inflate().yv12lut(yexpr=lutexpr).GreyScale()
#edgemask = input.mt_edge(thY1=1, thY2=255, mode="sobel").mt_inflate().mt_lut(yexpr=lutexpr).GreyScale()

# apply ssiq only to masked area, using "strength"
result = overlay(input, derainbow, mode="blend", mask=edgemask, opacity=strength/255.0).Limiter()

return result
}