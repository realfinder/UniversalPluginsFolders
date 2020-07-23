function maskcrop(clip last,clip "maskc",string "masks", string "filter", int "xMul", int "yMul",bool "chroma", bool "border"){
xMul=default(xMul, 4)
yMul=default(yMul, 2)
chroma=default(chroma,true)
border=default(border,true)
maskexpr=default(masks, """mt_makediff(last,last.loop(2,0,0), U=3,V=3).mt_lut("x 123 < 255 x 133 >  255 0 ? ?", U=3,V=3).Removegrain(1)""")
filter=default(filter, "dfttest(sigma=16,tbsize=1,sbsize=16,sosize=12)")
xs=string(xMul)
ys=string(yMul)
cs=string(chroma)
bs=string(border)
global maskclipshitei=(defined(maskc)==false)?eval(maskexpr):maskc

scriptclip("
input=last
"+bs+"?crop(4,4,-4,-4):input
mask=maskclipshitei
top = mask.MaskCropT("+ys+","+cs+")
left= mask.MaskCropL("+xs+","+cs+")
bottom = mask.MaskCropB("+ys+","+cs+")
right = mask.MaskCropR("+xs+","+cs+")

cmask=(bottom<=top+"+xs+"||right<=left+"+ys+")?mask:mask.crop(left,top,right-left,bottom-top)
cropped="+bs+"?((bottom<=top+"+xs+"||right<=left+"+ys+")?input.crop(4,4,-4,-4):input.crop(left+4,top+4,right-left-4,bottom-top-4)):\
	(bottom<=top+"+xs+"||right<=left+"+ys+")?input:input.crop(left,top,right-left,bottom-top)
filted=cropped."+filter+"
cmereged=mt_merge(cropped,filted,cmask,Y=3,U=3,V=3)
(bottom<=top+"+xs+"||right<=left+"+ys+")?input:"+bs+"?overlay(input,cmereged,left+4,top+4):overlay(input,cmereged,left,top)
")
return last
}