# LoadPlugin("Shuffle.dll")

function ColorSampleSource(int "width", int "height", int "totalLength", int "sampleLength", float "fps")
{
    width = Default(width, 320)
    height = Default(height, 240)
    sampleLength = Default(sampleLength, 5)
    fps = Default(fps, 24.0)

    # by default, generate a 30-second clip
    totalLength = Default(totalLength, Ceil(30.0 * fps))
    Assert(totalLength > 0, "ColorSampleSource: totalLength must be > 0")

    red     =     BlankClip(color=$FF0000, length=sampleLength, fps=fps, width=width, height=height, pixel_type="yuy2")
    green   = red.BlankClip(color=$00FF00)
    blue    = red.BlankClip(color=$0000FF)
    cyan    = red.BlankClip(color=$00FFFF)
    magenta = red.BlankClip(color=$FF00FF)
    yellow  = red.BlankClip(color=$FFFF00)

    red + green + blue + cyan + magenta + yellow

    Loop(Ceil(Float(totalLength) / FrameCount()))
    Trim(0, -totalLength)

    return last
}


function FrameMontage(clip c, int "seed", int "groupSize", bool "showSeed", int "blurRadius")
{
    groupSize = Default(groupSize, 10)
    showSeed = Default(showSeed, false)
    blurRadius = Default(blurRadius, groupSize / 2)

    c = c.Shuffle(seed=seed, groupSize=groupSize, showSeed=showSeed)

    # blend frames together
    #
    # (NOTE: requires AviSynth 2.5.5 (2004-03-14 build) or later to produce
    # smooth transitions)
    #
    c = c.TemporalSoften(blurRadius, 255, 255, scenechange=255)

    return c
}


# Uses Overlay's chroma mode with a shuffled, blended color clip
# to color a base clip.
#
# This might be good for use with dance footage.
#
function Disco(clip c, int "seed", int "groupSize", bool "showSeed", int "blurRadius")
{
    groupSize = Default(groupSize, 10)
    showSeed = Default(showSeed, false)

    color = ColorSampleSource(c.Width(), c.Height(), c.FrameCount(), groupSize + 1, c.FrameRate())
    color = color.FrameMontage(seed, groupSize, showSeed, blurRadius)
    return Overlay(c, color, mode="chroma", opacity=0.66)
}


# Replace ColorSampleSource with an AVI source clip for some (mildly?)
# interesting results.
#
ColorSampleSource()
FrameMontage(showSeed=true)

# ... or try using the following function on an AVI source clip (probably
# works best with music videos)
#
# Disco(showSeed=true)
