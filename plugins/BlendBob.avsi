function BlendBob(clip clip, bool "show", float "pnThresh", float "diffBias", float "diffScale", int "forceMatch", int "derainbow", int "rainbowThresh", int "rainbowRadius", int "badFrames", int "dupeThresh", float "dupeBias", float "dupeScale", bool "coring", int "forceCPU")
{
LoadPlugin(AviSynthPluginsDir + "25/BlendBob.dll")
    BlendBob(clip, show, pnThresh, diffBias, diffScale, forceMatch, derainbow, rainbowThresh, rainbowRadius, badFrames, dupeThresh, dupeBias, dupeScale, coring, forceCPU)
}