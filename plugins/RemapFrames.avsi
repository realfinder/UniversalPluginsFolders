function RemapFrames(clip clip, string "filename", string "mappings", clip "sourceClip")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        RemapFrames(clip, filename, mappings, sourceClip)
}


function RemapFramesSimple(clip clip, string "filename", string "mappings")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        RemapFramesSimple(clip, filename, mappings)
}


function ReplaceFramesSimple(clip baseClip, clip sourceClip, string "filename", string "mappings")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        ReplaceFramesSimple(baseClip, sourceClip, filename, mappings)
}

function remf(clip clip, string "filename", string "mappings", clip "sourceClip")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        remf(clip, filename, mappings, sourceClip)
}


function remfs(clip clip, string "filename", string "mappings")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        remfs(clip, filename, mappings)
}


function rfs(clip baseClip, clip sourceClip, string "filename", string "mappings")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        rfs(baseClip, sourceClip, filename, mappings)
}

function rfs_transform(string "mappings", string "op", bool "open", bool "discrete")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        rfs_transform(mappings, op, open, discrete)
}

function rfs_merge(string "s0", string "s1", string "s2", string "s3", string "s4", string "s5", string "s6", string "s7", string "s8", string "s9")
{
LoadPlugin(AviSynthPluginsDir + "25/RemapFrames.dll")
        rfs_merge(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9)
}