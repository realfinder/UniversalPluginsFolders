#
# RawSource (string filename, int width, int height, string pixel_type, int offset)
#    for loading raw video data
#
# filename: the raw file e.g. a YUV-file
# width, height: you must specify the image dimensions. width is max 2880
# pixel_type: the type of the raw data. An appropriate mapping to AviSynth's internal data is done
#    supported types: RGB, RGBA, BGR, BGRA, YUYV, UYUV (interleaved);  I420, YV12 (planar)
# 
# the framerate is fixed to 25fps, you can change it with AssumeFPS, if you need (e.g. for NTSC-material)
#
# <2005-04-12> NEW: if a YUV4MPEG2-header is found, width/height/framerate/pixeltype is set according to the header data. Only fixed-length FRAME headers are supported.
# <2005-09-21> NEW: you can provide an arbitrary offset to the first data. No further parsing is then done.

#LoadPlugin("c:\myprojects\rawsource\release\rawsource.dll")

#RawSource("d:\avitest\src6_ref__625.yuv",720,576,"BGRA")
#RawSource("c:\_video\test2.2vuy",720 , 304, "UYVY", offset=4*256)
RawSource("d:\blue_sky.yuv",1920,1080,"YV12")
bilinearresize(352,288)
imagewriter("d:\", 0,2,"ebmp")
converttorgb32