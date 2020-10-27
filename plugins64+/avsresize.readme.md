# HOW TO BUILD

1. Checkout zimg into ..\$(SolutionDir).
2. Checkout the latest AviSynthPlus into ..\$(SolutionDir).
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
```
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
	bool "approximate_gamma",
    bool "prefer_props")
```        
- width: output width in pixels
- height: output height in pixels
- pixel_type:
    ```
    "YV24" ("YUV444", "YUV444P8"), "YV16" ("YUV422", "YUV422P8"), "YV12" ("YUV420", "YUV420P8"), "YV411" ("YUV411", "YUV411P8"), "Y8",
    "YUV444P10", "YUV422P10", "YUV420P10", "Y10",
    "YUV444P12", "YUV422P12", "YUV420P12", "Y12",
    "YUV444P14", "YUV422P14", "YUV420P14", "Y14",
    "YUV444P16", "YUV422P16", "YUV420P16", "Y16",
    "YUV444PS", "YUV422PS", "YUV420PS", "Y32",
    "RGBP" ("RGBP8"),
    "RGBP10",
    "RGBP12",
    "RGBP14",
    "RGBP16",
    "RGBPS",
    "RGBAP" ("RGBAP8"),
    "RGBAP10",
    "RGBAP12",
    "RGBAP14",
    "RGBAP16",
    "RGBAPS",
    "YUVA444" ("YUVA444P8"), "YUVA422" ("YUVA422P8"), "YUVA420" (YUVA420P8"),
    "YUVA444P10", "YUVA422P10", "YUVA420P10",
    "YUVA444P12", "YUVA422P12", "YUVA420P12",
    "YUVA444P14", "YUVA422P14", "YUVA420P14",
    "YUVA444P16", "YUVA422P16", "YUVA420P16",
    "YUVA444PS", "YUVA422PS", "YUVA420PS"
    ```
- colorspace_op:
	- matrix
        ```
        "rgb" (0),
        "709" (1),
        "unspec" (2),
        "fcc" (4),
        "470bg" ("601") (5),
        "170m" (6),
        "240m" (7),
        "ycgco" (8),
        "2020ncl" ("2020") (9),
        "2020cl" (10),
        "chromancl" (12),
        "chromacl" (13),
        "ictcp" (14)
        ```
	- transfer
        ```
        "709" (1),
        "unspec" (2),
        "470m" (4),
        "470bg" (5),
        "601" (6),
        "240m" (7), 
        "linear" (8),
        "log100" (9),
        "log316" (10),
        "xvycc" (11),
        "srgb" (13),
        "2020_10" ("2020") (14),
        "2020_12" (15),
        "st2084" (16),
        "std-b67" (18)
        ```
	- primaries
        ```
        "709" (1),
        "unspec" (2),
        "470m" (4),
        "470bg" (5),
        "170m" (6),
        "240m" (7),
        "film" (8),
        "2020" (9),
        "st428" ("xyz") (10),
        "st431-2" ("dci-p3") (11),
        "st432-1" ("display-p3") (12),
        "jedec-p22" (22)
        ```
	- range
        ```
        "limited" ("l") (1),
        "full" ("f") (0)
        ```
Format is: `"matS[:transS[:primS[:rangeS]]]=>matD[:transD[:primD[:rangeD]]]"`
Example JPEG to MPEG: `"170m:709:709:f=>709:709:709:l"`
- chromaloc_op (default left):
    ```
    "left" ("mpeg2") (0),
    "center" ("jpeg", "mpeg1") (1),
    "top_left" (2),
    "top" (3),
    "bottom_left" (4),
    "bottom" (5)
    ```
Format is" `"[locS]=>[locD]"`
Example JPEG to MPEG2: `"center=>left"`
- interlaced (default: false): whether to use interlaced mode 
- resample_filter (default bicubic 0/0.5):
    ```
    "point",
    "bilinear",
    "bicubic",
    "spline16",
    "spline36",
    "spline64",
    "lanczos"
    ```
- filter_param_a: first parameter to resampler
- filter_param_b: second parameter to resampler
Example Bicubic (Mitchell-Netravali): `resample_filter="bicubic", filter_param_a=0.333, filter_param_b=0.333`
Example 4-tap Lanczos: `resample_filter="lanczos", filter_param_a=4`
- resample_filter_uv: resampling mode for chroma (same filters as "resample_filter")
- filter_param_a_uv: first parameter to chroma resampler
- filter_param_b_uv: second parameter to chroma resampler
- dither_type (default "none"):
    ```
    "none",
    "ordered",
    "random",
    "error_diffusion"
    ```
- cpu_type:
    ```
    "none",
    "avx",
    "avx_e" ("ivy"),
    "avx2",
    "avx512f,
    "avx512_skx" ("skx"),
    "avx512_clx",
    "avx512_pmc" ("cannon"),
    "avx512_snc" ("ice"))
    ```
- nominal_luminance (default 100): nominal peak luminance in cd/m^2 when converting HDR content to RGB Linear
- approximate_gamma (default true): evaluating transfer functions at reduced precision
- prefer_props (default false): whether frame properties or arguments take precedence when both are present. This option affects the source matrix/transfer/primaries/range/chromaloc_op arguments and their frame property equivalents.
The name of the frame properties that are read and set are: `_ChromaLocation, _ColorRange, _Matrix, _Transfer, _Primaries`
The frame properties read and set the corresponding numerical index of the parameters. For example: matrix `"709"` has numerical index `1` and the frame property have value of `1`.

See VapourSynth documentation for valid string constants.