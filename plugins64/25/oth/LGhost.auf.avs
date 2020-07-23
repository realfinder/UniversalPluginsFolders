info = LoadPlugin("LGhost.dll")
filt = AvisynthFilters("LGhost", info)
func = filt.AddFunction("LGhost")

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

func.AddTrack("モード", 0,    0,   4)
func.AddTrack("位置",   0, -100, 100)
func.AddTrack("強度",   0,  -50,  50)

filt.SetClipboard()

return filt
