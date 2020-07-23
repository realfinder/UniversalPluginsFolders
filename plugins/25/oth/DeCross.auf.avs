info = LoadPlugin("DeCross.dll")
filt = AvisynthFilters("DeCross", info)
func = filt.AddFunction("DeCross")

func.AddTrack("輝度閾値", 30, 0, 127)
func.AddTrack("ノイズ",   60, 0, 127)
func.AddTrack("範囲",      1, 0, 4)
func.AddCheck("範囲表示", false)

return filt
