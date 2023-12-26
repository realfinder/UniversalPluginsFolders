RawSourcePlus
=============

### Loading raw video data from files

for Avisynth+ r2150 or greater\
This filter is only for Avisynth+MT. Avisynth2.6 is not supported.

#### requirements

- Windows Vista sp2 or later
- Avisynth+ r2150 or greater
- Visual C++ Redistributable Packages for Visual Studio 2019

#### How to use

```
RawSourcePlus (string "file", int "width", int "height", string "pixel\_type", int "fpsnum", int "fpsden", string "index", bool "show", int "sarnum", int "sarden")
```

RawSourcePlus opens a video file which contains 8bit, 9bit, 10bit, 16bit or float YUV444, YUV422, YUV411, YUV420, Gray, or RGB video data.

It has capability to read from a pipe by using `"-"`. YUV4MPEG2-header is required.

There are three ways how the positions of the video frame data are calculated:
- a YUV4MPEG2-header is found, width/height/framerate/pixeltype/fieldorder is set according to the header data. Only fixed-length FRAME headers without 'm'tag are supported.
- width, height and pixel\_type is given as arguments. Then the positions are calculated assuming that only video data is in the file.
- an "index" string (or file) is given together with width, height, pixel\_type. The index string can contain all or partial positions of the frames.

Supported pixel_types are:
- RGB, RGBA, BGR, BGRA, ARGB, ABGR (interleaved RGB without subsampling, resulting in AviSynth's RGB24 or RGB32)
- YUY2(YUYV), YVYU, UYVY, VYUY (interleaved horizontally subsampled resulting in AviSynth's YUY2)
- YV24, YUV444P8 (planar 8bit without subsampling, resulting in AviSynth's YV24)
- YV16, YUV422P8 (planar 8bit horizontally subsampled, it is converted to AviSynth's YV16)
- YV12, I420, IYUV, YUV420P8 (planar 8bit horizontally and vertically subsampled resulting in AviSynth's YV12)
- YV411, YUV411P8, Y41B (planar horizontally subsampled, it is converted to AviSynth's YV411)
- NV12, NV21 (chroma interleaved 8bit horizontally and vertically subsampled, those are converted to AviSynth's YV12)
- Y8, GRAY8 (luma only resulting in AviSynth's Y8)
- RGB48, RGBA64, BGR48, BGRA64, ARGB64, ABGR64 (interleaved RGB without subsampling, resulting in AviSynth+'s RGB48 or RGB64)
- YUV444P9, YUV444P10, YUV444P12, YUV444P14, YUV444P16, YUV444PS (planar 9\~16bit or float without subsampling, resulting in AviSynth+'s YUV444P10/12/14/16/S)
- YUV422P9, YUV422P10, YUV422P12, YUV422P14, YUV422P16, YUV422PS (planar 9\~16bit or float horizontally subsampled, resulting in AviSynth+'s YUV422P10/12/14/16/S)
- YUV422P10be, YUV422P12be, YUV422P14be, YUV422P16be (planar 10\~16bit horizontally subsampled, resulting in AviSynth+'s YUV422P10/12/14/16)
- YUV420P9, YUV420P10, YUV420P12, YUV420P14, YUV420P16, YUV420PS (planar 9\~16bit or float horizontally and vertically subsampled resulting in AviSynth+'s YUV420P10/12/14/16/S)
- P210, P216 (chroma interleaved 16bit horizontally subsampled, those are converted to AviSynth+'s YUV422P16)
- P010, P016 (chroma interleaved 16bit horizontally and vertically subsampled, those are converted to AviSynth+'s YUV420P16)
- UYVY10le, UYVY10be, UYVY12le, UYVY12be, UYVY14le, UYVY14be, UYVY16le, UYVY16be (little-endian or big-endian interleaved 10\~16bit horizontally subsampled, those are converted to AviSynth+'s YUV422P10/12/14/16)
- Y10, Y12, Y14, Y16, Y32, GREY16, GREYS (luma only 10\~16bit or float resulting in AviSynth+'s Y10/12/14/16/32)
- GBRP, GBRP10, GBRP12, GBRP14, GBRP16, GBRPS (planar 8\~16bit or float RGB without subsampling, resulting in Avisynth+'s RGBP/10/12/14/16/S)
- GBRAP, GBRAP10, GBRAP12, GBRAP14, GBRAP16, GBRAPS (planar 8\~16bit or float RGB with alpha, resulting in Avisynth+'s RGBAP/10/12/14/16/S)
- YUVA444, YUVA444P10, YUVA444P12, YUVA444P14, YUVA444P16, YUVA444PS (planar 8\~16bit or float YUV444 with alpha, resulting in AviSynth+'s YUVA444/P10/P12/P14/P16/PS)
- YUVA422, YUVA422P10, YUVA422P12, YUVA422P14, YUVA422P16, YUVA422PS (planar 8\~16bit or float YUV422 with alpha, resulting in AviSynth+'s YUVA422/P10/P12/P14/P16/PS)
- YUVA420, YUVA420P10, YUVA420P12, YUVA420P14, YUVA420P16, YUVA420PS (planar 8\~16bit or float YUV420 with alpha, resulting in AviSynth+'s YUVA420/P10/P12/P14/P16/PS)

The default value of framerate is 25fps, you can change it with specified 'fpsnum' and 'fpsden' if you need (e.g. for NTSC-material).

With show=true (only for non-pipe input) the actually used byteposition for that frame is displayed, followed by:\
K = position given in index is used\
D = position by adding current delta is used\
B = position by adding currend big\_delta is used

#### Some simple examples:

```
RawSourcePlus("d:\yuv4mpeg.y4m")  #this assumes there is a valid YUV4MPEG2-header inside.
# If not, default values are used: width=720, height=576, pixel_type="YUY2".
```

```
RawSourcePlus("d:\src6_625.raw",720,576,"BGRA") # really a raw file
# If you are unsure about the pixel_type, simply try out all possible values.
```

#### Using an index-string:

You can enter the byte positions of the video frames directly.

```
RawSourcePlus("d:\yuv.mov",720,576,"UYVY", index="0:192512 1:1021952 25:21120512 50:42048512 75:62976512")
```

This is useful if it's not really raw video, but e.g. uncompressed MOV files or a file with some kind of header.\
It will work whenever the spacing of the frames is fixed or has at least two fixed intervalls (e.g. audio data interleaved with the video every 25th frame).\
You enter pairs of `framenumber:byteposition`.\
Internally there are two step values (for the byte positions): delta and big\_delta.\
delta is stored everytime when two adjacent framenumbers are given, the default value is width\*height\*bytes\_per\_pixel.\
big\_delta is stored, when three framenumbers with the same two intervals are given. The default value is 0 (meaning there is no useful big\_delta present).\
If those conditions are not met, the internal values of delta and big\_delta is not updated, only the given bytepositions in the index are used.\
big\_delta is reset to 0 if the resulting position would be behind the given one (see beyond).

Here are some possible cases:

| Case | Description |
| --- | --- |
| 0:    0 | frame 0 starts at byte 0, step to frame 1 is default = width\*height\*bytes_per_pixel |
| 0:10000 | frame 0 starts at 10000 |
| 0:  5000<br>1: 15000<br><br><br><br>25:290000<br><br><br>50:590000<br><br><br><br>75:890000<br><br><br> | frame 0 at 5000<br>frame 1 at 15000 (delta=10000)<br>frame 2 at 25000<br>...<br>frame 25 at 290000 (using entry instead of delta which would be at 255000)<br>frame 26 at 300000 (still using delta)<br>...<br>frame 50 at 590000 (using entry instead of delta)<br>>> because 25...50 = 50...75 now big_delta is set to 300000 (590000-290000)<br>frame 51 at 600000 (still using delta)<br>...<br>frame 75 at 890000 (using entry which is the same as using big_delta)<br>...<br>frame 100 at 1190000 (using big_delta)<br>frame 101 at 1200000 (using delta)...frame 125 at 1490000 (using big_delta) |
| 0:  5000<br>1: 15000<br>25:290000<br>50:590000<br>75:890000<br><br>100:950000<br><br><br><br> | the same as in the previous example<br><br><br><br>frame 75 at 890000<br>>> because 890000+300000 > 950000 now big_delta is reset to 0.<br>frame 100 at 950000<br>frame 101 at 960000 (using delta)<br>...<br>frame 125 at 1200000 (there is NO big_delta) |

The index string is treated as a filename, if there is an "." inside. The data is then read from that file, line breaks don't matter.

#### note:

This filter is automatically registerd as MT\_SERIALIZED.\
You don't have to set it yourself.

#### Exported variables:

FFSAR_NUM, FFSAR_DEN, FFSAR.

#### Building

##### Windows

Use solution files.

##### Linux

###### Requirements

- Git
- C++11 compiler
- CMake >= 3.16

```
git clone https://github.com/Asd-g/RawSource_2.6x && \
cd RawSource_2.6x && \
mkdir build && \
cd build && \

cmake ..
make -j$(nproc)
sudo make install
```

#### LICENSE:

Same as the original plugin.
