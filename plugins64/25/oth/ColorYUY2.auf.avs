info = LoadPlugin("ColorYUY2.dll")
filt = AvisynthFilters("YUY2 color adjust filter", info)
func = filt.AddFunction("ColorYUY2")

func.AddTrack("Y(gain)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("Y(offs)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("Y(gamm)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("Y(cont)", 0, -256, 256, -256.0, 256.0)

func.AddTrack("U(gain)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("U(offs)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("U(gamm)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("U(cont)", 0, -256, 256, -256.0, 256.0)

func.AddTrack("V(gain)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("V(offs)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("V(gamm)", 0, -256, 256, -256.0, 256.0)
func.AddTrack("V(cont)", 0, -256, 256, -256.0, 256.0)

func.AddValue(0.0)
func.AddValue(0.0)
func.AddValue(0.0)
func.AddValue(0.0)

func.AddValue(0.0)
func.AddValue(0.0)
func.AddValue(0.0)
func.AddValue(0.0)

func.AddValue(0.0)
func.AddValue(0.0)
func.AddValue(0.0)
func.AddValue(0.0)

func.AddArray("levels", 0, "", "TV->PC", "PC->TV", "PC->TV.Y", "TV->PC.Y", "709->601", "709TV->601PC", "709PC->601TV")
func.AddArray("opt", 0, "", "coring", "1-254")
func.AddArray("matrix", 0, "", "rec709", "rec601s", "rec709s")

func.AddTrack("debug",   0,  0,   5)
func.AddTrack("hscale", 70, 10, 100)

func.AddTrack("X", 0, -1, 1280)
func.AddTrack("Y", 0, -1,  960)

func.AddArray("interpolation", 0, "", "411->422", "411->422R", "411->444", "411->444R", "420->422", "420->444", "422->444")
func.AddArray("output", 0, "", "YUY2", "YV12", "I420", "RGB32", "RGB24")

return filt
