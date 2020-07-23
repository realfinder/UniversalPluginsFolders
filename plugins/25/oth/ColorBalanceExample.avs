ColorYUV(BlankClip(pixel_type="YUY2"),showyuv=true).ConvertToRGB().BilinearResize(448,600)


ColorBalance(last, \
 \
0.0,0.0,0.0, \
 \
0.0,0.0,0.0, \
 \
0.0,0.0,0.0, \
Select(0, false, true), \
Select(1, false, true), \
Select(0, false, true)) \

### AvsP marked script ###
# ColorYUV(BlankClip(pixel_type="YUY2"),showyuv=true).ConvertToRGB().BilinearResize(448,600)
# 
# [ColorBalance=1]
# ColorBalance(last, \
# [<separator="Shadows">] \
# [<"S: Cyan-Red", -100.0, 100.0, 0.0>],[<"S: Magenta-Green", -100.0, 100.0, 0.0>],[<"S: Yellow-Blue", -100.0, 100.0, 0.0>], \
# [<separator="Midtones">] \
# [<"M: Cyan-Red", -100.0, 100.0, 0.0>],[<"M: Magenta-Green", -100.0, 100.0, 0.0>],[<"M: Yellow-Blue", -100.0, 100.0, 0.0>], \
# [<separator="Highlights">] \
# [<"H: Cyan-Red", -100.0, 100.0, 0.0>],[<"H: Magenta-Green", -100.0, 100.0, 0.0>],[<"H: Yellow-Blue", -100.0, 100.0, 0.0>], \
# Select([<"Preserve Luminosity", 0, 1, 0>], false, true), \
# Select([<"Clone Gimp", 0, 1, 1>], false, true), \
# Select([<"16 Bit Color", 0, 1, 0>], false, true)) \
# [/ColorBalance]
### AvsP marked script ###