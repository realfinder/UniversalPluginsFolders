info = LoadPlugin("DeCross.dll")
filt = AvisynthFilters("DeCross", info)

func = filt.AddFunction("ConvertToYUY2", hidden = true)

func = filt.AddFunction("DeCross")

func.AddTrack("�P�x臒l", 30, 0, 127)
func.AddTrack("�m�C�Y",   60, 0, 127)
func.AddTrack("�͈�",      1, 0, 4)
func.AddCheck("�͈͕\��", false)

func = filt.AddFunction("ConvertToRGB32", hidden = true)

return filt
