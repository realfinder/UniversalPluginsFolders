setmemorymax(1024)
#loadplugin(".\AddGrainC.dll")
loadplugin(".\Debug\AddGrainC.dll")
#loadplugin(".\Release\AddGrainC.dll")
#loadplugin(".\RelSym\AddGrainC.dll")

yv12 = blankclip(pixel_type="yv12" ,color=$808080,width=512,height=320,length=10).loop(1000000)
yuy2 = blankclip(pixel_type="yuy2" ,color=$808080,width=512,height=320,length=10).loop(1000000)
rgb =  blankclip(pixel_type="rgb24",color=$808080,width=512,height=320,length=10).loop(1000000)
rgba = blankclip(pixel_type="rgb32",color=$808080,width=512,height=320,length=10).loop(1000000)

stackvertical(yv12.addgrainc(200,200).ConvertToRGB32(), \
		yuy2.addgrainc(200,200,seed=12).ConvertToRGB32(), \
		yuy2.addgrainc(200,200).ConvertToRGB32(), \
		rgb.addgrainc(200,200).ConvertToRGB32(), \
		rgba.addgrainc(200,200).ConvertToRGB32())

