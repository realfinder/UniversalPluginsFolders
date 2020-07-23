function MotionProtectedFPS(
 \ clip input, float FPS, 
 \ int "mode", int "protection",
 \ int "iterate", int "reset", int "initialise")
{
mode       = default(mode, warpfast)
protection = default(protection, 80)
iterate    = default(iterate, 2)
reset      = default(reset, 50)
initialise = default(initialise, 6)

originalFPS = input.framerate()
input

mp    = FindMotion(iterate = iterate, reset = reset,
 \       initialise = initialise)
p     = MotionFPS(FPS,mode,Motion = mp)
maskp = mp.SumStretchFPSMask(FPS, protection)

mn    = FindMotion(iterate = iterate, reset = reset,
 \       initialise = initialise, from = next)
n     = MotionFPS(FPS,mode,Motion = mn, source = next)
maskn = mn.SumStretchFPSMask(FPS, protection, source = next)

maskp
assumeFPS(originalFPS)
CombineFPS(FPS, maskp, maskn.Invert())
bilinearresize(width*8, height*8)
crop(0, 0, input.width(), input.height())
fity2uv()

maskedmerge(p, n, last, u=3, v=3)
}