
function BicubicSharp(clip c, float "r", float "edges", float "g", float "wg", float "bl", float "str", int "mode", int "bitdepth") {
	# BicubicSharp by Andrew Revvo
	# Requires: HDRCore, HDRSharp, Dither
	# Y8, YV12, YV16, YV24
	#LoadPlugin(WmCore+"\HDRSharp.dll")
	#LoadPlugin(WmCore+"\dither.dll")
	r = default(r, 2.0)+1.0
	r = r<=0 ? 0 : r
	edges = default(edges, 0.5)
	g = default(g, 2.2)
	wg = default(wg, 5.0)
	bl = default(bl, 0.0)
	str = default(str, 0.5)*70
	mode = default(mode, 1)
	bitdepth = default(bitdepth, 8)
	b = VersionNumber() < 2.60 ? c.Bitdepth(from=bitdepth, to=88) : c.ConvertToY8().Bitdepth(from=bitdepth, to=88)
	w = b.width()
	h = b.height() / 2
	b = b.Dither_resize16(int(w/r), int(h/r), kernel="bicubic")
	b = b.Dither_resize16(w, h, kernel="bicubic")
	b = b.Bitdepth(from=88, to=16)
	c.UnsharpMask16Y(b, edges=edges, g=g, wg=wg, bl=bl, str=str, mode=mode, bitdepth=bitdepth)
}

function BicubicSharp8(clip c, float "r", float "edges", float "g", float "wg", float "bl", float "str", int "mode", int "bitdepth") {
	# BicubicSharp8 by Andrew Revvo
	# Requires: HDRCore, HDRSharp
	# Y8, YV12, YV16, YV24
	#LoadPlugin(WmCore+"\HDRSharp.dll")
	r = default(r, 2.0)+1.0
	r = r<=0 ? 0 : r
	edges = default(edges, 0.5)
	g = default(g, 2.2)
	wg = default(wg, 5.0)
	bl = default(bl, 0.0)
	str = default(str, 0.5)*70
	mode = default(mode, 1)
	bitdepth = default(bitdepth, 8)
	b = VersionNumber() < 2.60 ? c.Bitdepth(from=bitdepth, to=8) : c.ConvertToY8().Bitdepth(from=bitdepth, to=8)
	w = b.width()
	h = b.height()
	b = b.BicubicResize(int(w/r), int(h/r))
	b = b.BicubicResize(w, h)
	c.UnsharpMask8Y(b, edges=edges, g=g, wg=wg, bl=bl, str=str, mode=mode, bitdepth=bitdepth)
}
