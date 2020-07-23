## HDR-sources.avsi
## Licensed under the MIT License. Copyright (c) 2015-2016 Andrew Revvo (andrew.revvo~gmail~com)
## The latest version: http://www.snovidenie.com/plugins/hdr/

#global WmCore = "C:\some_dir_with_plugins"
#LoadPlugin(WmCore+"\HDRCore.dll")
#LoadPlugin(WmCore+"\avss_26.dll")
#LoadPlugin(WmCore+"\DirectShowSource.dll")
#LoadPlugin(WmCore+"\LSMASHSource.dll")

function VideoDS(string file, float "fps", int "subsampling", int "bitdepth", string "fmt", int "flip", int "play", int "hwmode", int "threads") {
	# Do not use this function with 100% CPU and MT
	# Requires: dss2 mod LAV, HDRCore
	# LoadPlugin(WmCore+"\avss_26.dll")
	fps = default(fps, -1)
	subsampling = default(subsampling, 420)
	bitdepth = default(bitdepth, 8)
	fmt = default(fmt, "auto") # YV12, YUY2, RGB24, RGB32 RGB or ""
	flip = default(flip, 0)==1 # 0/1
	play = default(play, 1)==1 # 0-make, 1-play
	hwmode = string(default(hwmode, 0)) # 0-software, 1-CUDA, 2-QuickSync, 3-DXVA2(copy-back)
	threads = string(default(threads, 0))
	preroll = play ? 10 : 200
	pixel_type = fmt=="auto" ?
	\ subsampling==420 ? "YV12" :
	\ subsampling==422 ? "YUY2" :
	\ subsampling==444 ? "YUY2" : fmt : fmt
	dss2(file, fps=fps, preroll=preroll, cache=20, flipv=flip, pixel_type=pixel_type,
	\	lavs="l2 vc2 sm0 sl[] sa[] es0 ti0", lavd="l2 t"+threads+" r2 d1 dm0 fo0 sd0 vc1 hm"+hwmode+" hc7 hr3 hd0 hq0 ti0")
	IsYUY2() ? ConvertToYV16() : last
	IsYUV() ? Bitdepth(from=8, to=bitdepth) : last
}

function AudioDS(clip c, string file) {
	# Requires: DirectShowSource
	# LoadPlugin(WmCore+"\DirectShowSource.dll")
	try {
		c.AudioDub(DirectShowSource(file, video=false))
	} catch(err_msg) {
		c.AudioSilent()
	}
}

function VideoLS(string file, int "fpsnum", int "fpsden", int "subsampling", int "bitdepth", string "fmt", int "threads", bool "dr") {
	# Requires: LSMASHSource, HDRCore
	# LoadPlugin(WmCore+"\LSMASHSource.dll")
	fpsnum = default(fpsnum, 0)
	fpsden = default(fpsden, 1)
	subsampling = default(subsampling, 420)
	bitdepth = default(bitdepth, 8)
	fmt = default(fmt, "auto") # YUV420P8,YUV422P8,YUV444P8,YUV420P16,YUV422P16,YUV444P16,RGB24
	stacked_out = bitdepth==88
	threads = default(threads, 0)
	dr = default(dr, true)
	bitdepth_code = bitdepth==8 ? "8" : "16"
	format = fmt=="auto" ?
	\ subsampling==420 ? "YUV420P"+bitdepth_code :
	\ subsampling==422 ? "YUV422P"+bitdepth_code :
	\ subsampling==444 ? "YUV444P"+bitdepth_code : fmt : fmt
	LSMASHVideoSource(file, threads=threads, stacked=stacked_out, fpsnum=fpsnum, fpsden=fpsden, format=format, seek_mode=0, seek_threshold=10, dr=dr)
	IsYUV() ? (bitdepth==32) ? Bitdepth(from=16, to=32) : last : last
}

function AudioLS(clip c, string file, int "track", string "layout", int "rate") {
	# Requires: LSMASHSource
	# LoadPlugin(WmCore+"\LSMASHSource.dll")
	track = default(track, 0)
	layout = default(layout, "")
	rate = default(rate, 0)
	try {
		c.AudioDub(LSMASHAudioSource(file, track=track, skip_priming=true, layout=layout, rate=rate))
	} catch(e) {
		c.AudioSilent()
	}
}

function VideoLA(string file, int "fpsnum", int "fpsden", int "subsampling", int "bitdepth", string "fmt", int "threads", bool "dr") {
	# Requires: LSMASHSource, HDRCore 
	# LoadPlugin(WmCore+"\LSMASHSource.dll")
	fpsnum = default(fpsnum, 0)
	fpsden = default(fpsden, 1)
	subsampling = default(subsampling, 420)
	bitdepth = default(bitdepth, 8)
	fmt = default(fmt, "auto") # YUV420P8,YUV422P8,YUV444P8,YUV420P16,YUV422P16,YUV444P16,RGB24
	stacked_out = bitdepth==88
	threads = default(threads, 0)
	dr = default(dr, true)
	bitdepth_code = bitdepth==8 ? "8" : "16"
	format = fmt=="auto" ?
	\ subsampling==420 ? "YUV420P"+bitdepth_code :
	\ subsampling==422 ? "YUV422P"+bitdepth_code :
	\ subsampling==444 ? "YUV444P"+bitdepth_code : fmt : fmt
	LWLibavVideoSource(file, stream_index=-1, threads=threads, stacked=stacked_out, fpsnum=fpsnum, fpsden=fpsden, format=format, seek_mode=0, seek_threshold=10, dr=dr, cache=true)
	IsYUV() ? (bitdepth==32) ? Bitdepth(from=16, to=32) : last : last
}

function AudioLA(clip c, string file, int "stream_index", string "layout", int "rate") {
	# Requires: LSMASHSource
	# LoadPlugin(WmCore+"\LSMASHSource.dll")
	stream_index = default(stream_index, -1)
	layout = default(layout, "")
	rate = default(rate, 0)
	try {
		c.AudioDub(LWLibavAudioSource(file, stream_index=stream_index, layout=layout, av_sync=true, cache=true, rate=rate))
	} catch(e) {
		c.AudioSilent()
	}
}

function AudioSilent(clip c) {
	c.AudioDub(BlankClip(c, channels=1, audio_rate=48000, sample_type="16bit"))
}
