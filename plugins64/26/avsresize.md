# HOW TO BUILD

1. Checkout z.lib into $(SolutionDir)zimg.
2. Checkout pinterf/AviSynthPlus MT branch into $(SolutionDir)AviSynthPlus
3. Use provided solution file.
4. ???
5. **Prophet**

# HOW TO USE
## AviSynth compatibility mode
- z_PointResize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_BilinearResize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_BicubicResize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_LanczosResize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_Lanczos4Resize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_Spline16Resize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_Spline36Resize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")
- z_Spline64Resize(clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither")

chromaloc_op - see below for the valid values;
dither (same as dither_type) - see below for the valid values;

## VapourSynth compatibility mode
    z_ConvertFormat(
        clip clip,
        int "width",
        int "height",
        str "pixel_type",
        str "colorspace_op",
        str "chromaloc_op",
        bool "interlaced",
        float "src_left",
        float "src_top",
        float "src_width",
        float "src_height",
        str "resample_filter",
        float "filter_param_a",
        float "filter_param_b",
        str "resample_filter_uv",
        float "filter_param_a_uv",
        float "filter_param_b_uv",
        str "dither_type",
		str "cpu_type",
		float "nominal_luminance",
		bool "approximate_gamma")
        
    width:                  output width in pixels
    height:                 output height in pixels
    pixel_type:             output pixel type ("YV24" ("YUV444", "YUV444P8"), "YV16" ("YUV422", "YUV422P8"), "YV12" ("YUV420", "YUV420P8"), "YUV9", "YV411" ("YUV411", "YUV411P8"), "Y8", "YUV444P10", "YUV422P10", "YUV420P10", "Y10", "YUV444P12", "YUV422P12", "YUV420P12", "Y12", "YUV444P14", "YUV422P14", "YUV420P14", "Y14", "YUV444P16", "YUV422P16", "YUV420P16", "Y16", "YUV444PS", "YUV422PS", "YUV420PS", "Y32", "RGBP" ("RGBP8"), "RGBP10", "RGBP12", "RGBP14", "RGBP16", "RGBPS", "RGBAP" ("RGBAP8"), "RGBAP10", "RGBAP12", "RGBAP14", "RGBAP16", "RGBAPS", "YUVA444" ("YUVA444P8"), "YUVA422" ("YUVA422P8"), "YUVA420" (YUVA420P8"), "YUVA444P10", "YUVA422P10", "YUVA420P10", "YUVA444P12", "YUVA422P12", "YUVA420P12", "YUVA444P14", "YUVA422P14", "YUVA420P14", "YUVA444P16", "YUVA422P16", "YUVA420P16", "YUVA444PS", "YUVA422PS", "YUVA420PS")
    colorspace_op:          colorspace operation description: 
	- matrix ( "rgb", "709", "unspec", "fcc", "470bg" ("601"), "170m", "240m", "ycgco", "2020ncl" ("2020"), "2020cl", "chromancl", "chromacl", "ictcp") 
	- transfer ("709", "unspec", "470m", "470bg", "601", "240m", "linear", "log100", "log316", "xvycc", "srgb", "2020_10" ("2020"), "2020_12", "st2084", "std-b67") 
	- primaries ("709", "unspec", "470m", "470bg", "170m", "240m", "film", "2020", "st428" ("xyz"), "st431-2" ("dci-p3"), "st432-1" ("display-p3"), "jedec-p22")
	- range ("limited" ("l"), "full" ("f"))
        Format is
			"matS[:transS[:primS[:rangeS]]]=>matD[:transD[:primD[:rangeD]]]"
        Example JPEG to MPEG: "170m:709:709:f=>709:709:709:l"
    chromaloc_op:           chroma location operation description ("left" ("mpeg2"),"center" ("jpeg", "mpeg1"), "top_left")
        Format is "[locS]=>[locD]"
        Example JPEG to MPEG2: "center=>left"
    interlaced:             whether to use interlaced mode (default: false)
    resample_filter:        resampling mode ("point", "bilinear", "bicubic", "spline16", "spline36", "spline64", "lanczos")
    filter_param_a:         first parameter to resampler
    filter_param_b:         second parameter to resampler
        Example Bicubic (Mitchell-Netravali):
            resample_filter="bicubic", filter_param_a=0.333, filter_param_b=0.333
        Example 4-tap Lanczos: resample_filter="lanczos", filter_param_a=4
    resample_filter_uv:     resampling mode for chroma (same filters as "resample_filter")
    filter_param_a_uv:      first parameter to chroma resampler
    filter_param_b_uv:      second parameter to chroma resampler
    dither_type:            dithering type ("none", "ordered", "random", "error_diffusion") (default "none")
	cpu_type:				cpu type ("none", "avx" , "avx_e" ("ivy"), "avx2", "avx512f, "avx512_skx" ("skx"), "avx512_clx", "avx512_pmc" ("cannon"), "avx512_snc" ("ice"))
	nominal_luminance:		nominal peak luminance in cd/m^2 when converting HDR content to RGB Linear (default 100)
	approximate_gamma:		evaluating transfer functions at reduced precision (default true)

See VapourSynth documentation for valid string constants.