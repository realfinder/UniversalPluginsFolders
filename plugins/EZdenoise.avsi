function EZdenoise(clip Input, int "thSAD", int "thSADC", int "TR", int "BLKSize", int "Overlap")
{
thSAD = default(thSAD, 150)
thSADC = default(thSADC, thSAD)
TR = default(TR, 3)
BLKSize = default(BLKSize, 16)
Overlap = default(Overlap, BLKSize/2)

Super = Input.MSuper(pel=1)
Multi_Vector = Super.MAnalyse(Multi=True, Delta=TR, BLKSize=BLKSize, Overlap=Overlap)

Input.MDegrainN(Super, Multi_Vector, TR, thSAD=thSAD, thSAD2=thSAD/2, thSADC=thSADC, thSADC2=thSADC/2)
}