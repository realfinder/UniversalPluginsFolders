function DiffCol(clip a, clip b, int "col", int "colnum", bool "hista", bool "histb") {
	# By Andrew Revvo 2011
	col = default(col, 1)
	colnum = default(colnum, 8)
	hista = default(hista, true)
	histb = default(histb, true)
	w1 = Floor(b.width()/colnum/2)*2
	w = b.width()
	h = b.height()
	a = (a.width() != w) ? a.Spline36Resize(w, h) : a
	ac = a.Crop(w1*(col), 0, w1,h)
	bc = b.Crop(w1*(col), 0, w1,h)
	dc = Subtract(bc, ac).Levels(117,1,159,0,255)
	b.Overlay(ac, w1*(col+1),0)
	Overlay(dc, w1*(col+2),0)
	histb ? Overlay(b.Histogram(mode="levels").Crop(w, 0, 256,226), w-256-4, h-226-130) : last
	hista ? Overlay(a.Histogram(mode="levels").Crop(w, 0, 256,226), w-256-256-6, h-226-130) : last
}