AviSynthDeinterlaceSwitch is an AviSynth plugin for switching between two clips depending on if the scenes in the source clip are interlaced or not.
The purpuse of the plugin is to pass through non-interlaced material unchanged, while applying a deinterlacer only on interlaced scenes in the material.
Copyright (c) 2020-2024  Mattias von Schantz

The collection includes the following filter:

| Filter            | Description                                                             | Color support |
|-------------------|-------------------------------------------------------------------------|---------------|
| DeinterlaceSwitch | Switches clips depending on the interlace status of the source clip     | YV12, 8 bit   |
| LineDoubleSwitch  | Switches clips depending on the line doubling status of the source clip | YV12, 8 bit   |

Dependencies when compiling:
 * FFTW



DeinterlaceSwitch
--------------------------------------------------------------------------------------------------------------------------------

Description

	Traditional deinterlacers look for interlace artifacts (like an object appearing in one place in the first field and in
	another in the second field) in a frame, and deinterlaces it using some algorithm if such artifact are found. This works
	for frames with obvious motion, but can fail on frames that are mostly still.

	Imagine a video with a man standing still and after a while waving his hand. The frames where he's waving will very
	obviously be interlaced when you inspect them. But the frames where he's not waving will only show minimal interlace
	artifact because while he's standing still, he's not *perfectly* still. A deinterlacer must use some form of threshold
	to ignore artifacts that are too small, or risk deinterlacing everything, including non-interlaced frames.

	These artifact might not be immediately visible, unless you inspect the frame carefully, but they can be a problem if you
	try to upscale the image, as that will make even small interlace artifacts left look bad.

	_DeinterlaceSwitch_ instead use a scene based approach. It first divides the clip into scenes, and if even a few frames are
	obviously interlaced in a scene, it assumes the entire scene is interlaced. Thus it can apply a deinterlacer even on
	frames where the interlace artifacts are so small a threshold-based traditional deinterlacer would have missed them.

Syntax and parameters

	DeinterlaceSwitch(clip progressive, clip deinterlaced, bool "info", bool "visualize")

	clip progressive
		The clip to return if the scene in the source clip is progressive.

	clip deinterlaced
		The clip to return if the scene in the source clip is interlaced.

	bool info = false
		Layers scene and metric information on top of the output. Mostly used for debugging.

	bool visualize = false
		Outputs the internal interlace detection buffer as a video. Mostly used for debugging.

Example

	function ConditionalDeinterlace(clip c, bool "info", bool "visualize")
	{
		info = default(info, false)
		visualize = default(visualize, false)
		DeinterlaceSwitch(c, c, c.QTGMC(Preset="Very Slow", Tuning="DV-SD", EdiThreads=12, SourceMatch=3).SelectEven(), info, visualize)
	}



LineDoubleSwitch
--------------------------------------------------------------------------------------------------------------------------------

Description

	There are DVDs in existance where some scenes have been deinterlaced by repeating one field, effectively halving the
	resolution of that scene. This looks good enough when viewed at standard definition, but when upscaled, these
	doubled lines will produce stairstepping artifacts.

	These artifacts can be removed by, for example, downsampling the frame to half height and then upsampling it again using
	an interpolating upsampler. However, you only want to do this for scenes where this deinterlacing technique has been
	applied - not on every scene, as that cut the resolution in half even on scenes where both fields contain information.

	_LineDoubleSwitch_ use a scene based approach to detect line doubled scenes, and can based on that switch between
	outputing an untouched frame or a corrected frame based on this information.

Note

	LineDoubleSwitch is experimental, not well tested, and not considered production quality yet.

Syntax and parameters

	LineDoubleSwitch(clip progressive, clip corrected, bool "info", bool "visualize")

	clip progressive
		The clip to return if the scene in the source clip is full resolution.

	clip corrected
		The clip to return if the scene in the source clip is line doubled.

	bool info = false
		Layers scene and metric information on top of the output. Mostly used for debugging.

	bool visualize = false
		Outputs the internal line doubling detection buffer as a video. Mostly used for debugging.

Example

	function ConditionalLineDoublingInterpolation(clip c, bool "info", bool "visualize")
	{
		info = default(info, false)
		visualize = default(visualize, false)
		LineDoubleSwitch(c, c, c.PointResize(width, height/2).Spline64Resize(width, height*2), info, visualize)
	}
