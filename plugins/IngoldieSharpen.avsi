function IngoldieSharpen(clip src, float amountH,float "amountV",bool "MMX",Bool "Chroma",clip "dn",clip "dh") {
# Mt_Tools.
amountV=Default(amountV,amountH) Chroma=default(Chroma,false)
dn.Defined ? eval("""
Sharpened = dn.Sharpen(amountH,amountV,MMX) # denoised + sharpen
hSharpened = dh.Defined ? dh.Sharpen(amountH,amountV,MMX) : nop() # dehaloed + sharpen
hSharpDif = dh.Defined ? MT_MakeDiff(src,hSharpened,U=(Chroma)?3:1,V=(Chroma)?3:1) : nop() # Diff (original, (dehaloed + sharpen))
dn = dh.Defined ? MT_addDiff(dn,hSharpDif,U=(Chroma)?3:1,V=(Chroma)?3:1) : dn # add dehalo diff to dn
SharpDif = MT_MakeDiff(dn,Sharpened,U=(Chroma)?3:1,V=(Chroma)?3:1) # Diff (denoised, (denoised + sharpen))
Result = MT_MakeDiff(src,SharpDif,U=(Chroma)?3:2,V=(Chroma)?3:2) # Sub SharpDif from src
""") : dh.Defined ? eval("""
hSharpened = dh.Sharpen(amountH,amountV,MMX) # dehaloed + sharpen
hSharpDif = MT_MakeDiff(src,hSharpened,U=(Chroma)?3:1,V=(Chroma)?3:1) # Diff (original, (dehaloed + sharpen))
Result = MT_MakeDiff(src,hSharpDif,U=(Chroma)?3:2,V=(Chroma)?3:2) # Sub hSharpDif from src
""") : eval("""
Result = src.Sharpen(amountH,amountV,MMX)
Result = (Chroma)?Result:Result.MergeChroma(src)
""")
Return Result
}