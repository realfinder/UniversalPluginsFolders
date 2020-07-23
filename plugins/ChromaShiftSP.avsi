#ChromaShift_SP: Shift chroma with subpixel accuracy, basic function by IanB, made standalone by McCauley

function ChromaShiftSP (clip clp, float "X",float "Y") {

X = default(X, 0.0) # positive values shift the chroma to left, negative values to right
Y = default(Y, 0.0) # positive values shift the chroma upwards, negative values downwards

w = clp.Width()
h = clp.Height()

clp.MergeChroma(clp.Spline16Resize(w, h, X, Y, w+X, h+Y)) }