LoadPlugin("Anaglyph.dll")

atyp = "red-cyan"
ptyp = "RGB24"

# Load left/right eye images.
L = ImageSource("AnaglyphTestL.jpg", pixel_type = ptyp).Trim(0, 30) #.Subtitle("Left", x = 10, y = 5, align = 7, text_color = $E0E0E0)
R = ImageSource("AnaglyphTestR.jpg", pixel_type = ptyp).Trim(0, 30) #.Subtitle("Right", x = 1270, y = 5, align = 9, text_color = $E0E0E0)

# Create side-by-side comparison of different matrices.
test1 = StackVertical( \
	StackHorizontal( \
		Anaglyph(L, R, "color", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Full Color", x = 320, y = 350, align = 2), \
		Anaglyph(L, R, "halfcolor", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Half Color", x = 320, y = 350, align = 2) \
	), StackHorizontal( \
		Anaglyph(L, R, "optimized", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Optimized", x = 320, y = 350, align = 2), \
		Anaglyph(L, R, "grey", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Grey", x = 320, y = 350, align = 2) \
	) \
)

# Create Dubois anaglyph and show channel separation.
ana = Anaglyph(L, R, "dubois", atyp, convergence = -6).Subtitle("Dubois", x = 640, y = 700, align = 2)
test2 = ana \
	.Overlay(ana.ShowRed(ptyp).Lanczos4Resize(128, 72).Frame($FF0000), x = 750, y = 580) \
	.Overlay(ana.ShowGreen(ptyp).Lanczos4Resize(128, 72).Frame($00FF00), x = 900, y = 580) \
	.Overlay(ana.ShowBlue(ptyp).Lanczos4Resize(128, 72).Frame($0000FF), x = 1050, y = 580)

# Test color reproduction on extremely colorful image (peek with one eye at a time).
L = ImageSource("AnaglyphColorsL.png", pixel_type = ptyp).Trim(0, 30)
R = ImageSource("AnaglyphColorsR.png", pixel_type = ptyp).Trim(0, 30)
test3 = StackVertical( \
	StackHorizontal( \
		Anaglyph(L, R, "color", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Full Color", x = 320, y = 350, align = 2), \
		Anaglyph(L, R, "halfcolor", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Half Color", x = 320, y = 350, align = 2) \
	), StackHorizontal( \
		Anaglyph(L, R, "dubois", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Dubois", x = 320, y = 350, align = 2), \
		Anaglyph(L, R, "grey", atyp).Lanczos4Resize(640, 360).Frame(0).Subtitle("Grey", x = 320, y = 350, align = 2) \
	) \
)

# Show both test images sequentially.
return test1.FadeIO(10) + test2.FadeIO(10) + test3.FadeIO(10)

# Draw a 2 pixel frame around the specified clip.
function Frame(clip c, int color) {
	return c.Letterbox(2, 2, 2, 2, color)
}

