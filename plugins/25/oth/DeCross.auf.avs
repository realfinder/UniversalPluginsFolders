info = LoadPlugin("DeCross.dll")
filt = AvisynthFilters("DeCross", info)
func = filt.AddFunction("DeCross")

func.AddTrack("�P�x臒l", 30, 0, 127)
func.AddTrack("�m�C�Y",   60, 0, 127)
func.AddTrack("�͈�",      1, 0, 4)
func.AddCheck("�͈͕\��", false)

return filt
