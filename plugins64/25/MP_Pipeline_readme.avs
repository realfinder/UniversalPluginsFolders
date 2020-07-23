"""
MP_Pipeline 0.18

Change log:
0.18.1
*  New feature: Always kill children on plugin destruction
*  Allow using setmtmode in script block

0.18
* Fix deadlock when exported clip is consumed by multiple script block

0.17
* Properly terminate slave processes when initialization fails
* Fix "Not a clip" error when using ### inherit and the last block is empty

0.16
* Try to silent all error dialogs on exit of slave process
* Slave process shouldn't be stuck on exit anymore, it will terminate itself if it doesn't exit cleanly after 15 seconds
* Fix ### branch statement, previously it incorrectly rejects some input

0.15
* Properly clean script environment up on exit
* Allow using different avisynth dll to run script block (### dll)

0.14
* Fixed another crashing bug

0.13
* Fixed a bug that causes occasional crashing

0.12
* Fixed a problem that makes scripts unable to be loaded in some programs

0.11
* Greatly improved performance, maximum 80% overhead reduction
* New feature: Ability to lock threads to cores, may improve performance in some cases
* (0.10 is skipped to avoid confusion)

0.9
* New feature: Frame prefetching
* New feature: Exporting multiple clip variables in a single process
* New feature: Code block can be shared between processes

0.3
* Binaries in the x86 folder are in correct version now (In 0.2 the win64 slave is actually win32...)
* Integrated a patched TCPDeliver, no longer depend on the external one
* Fixed random crash when filter chain is destroyed
* Thunked branching

0.2
* x64 support (please copy TCPDeliver.dll in the package to respective plugin folder)
* x86/x64 mixed slave process (requires both x86/x64 version of AviSynth to be installed)
* Add a script variable in branch slave process, make it distinguishable in script

Web: 
http://www.nmm-hd.org/newbbs/viewtopic.php?f=7&t=498
http://forum.doom9.org/showthread.php?t=163281

Source code:
https://github.com/SAPikachu/MP_Pipeline

Copyleft 2011-2012 SAPikachu (sapikachu@gmail.com, http://www.sapikachu.net)
Licensed under GPL (http://www.gnu.org/copyleft/gpl.html).

Usage example:

"""

LoadPlugin("MP_Pipeline.dll")
SetMemoryMax(1)
MP_Pipeline("""

### platform: win64
# this part of script will be run in a 64 bit process

### dll: avisynth.dll
# you can use a different version of avisynth to run script block, just specify path to the avisynth dll like the line above

BlankClip()
ConvertToYV12()

# The line below is setmtmode for avs-mt to set mt mode for the next block (not the current)
### setmtmode: 2,12
# The line below is splitter
### ###

### platform: win32

### inherit start ###

# Codes in this block will be copied to all downstream processses (including the main process),
# so you can add LoadPlugin() calls here.

### inherit end ###

ScriptClip("Subtitle(string(current_frame))")
AddGrainC(1.0)

# the two lines below to enable MT in avs-mt
setmtmode(1)
distributor()

### ###


### platform: win32

a = ColorBars().ConvertToYV12().Subtitle("This is clip A, branch ID = " + string(MP_PIPELINE_BRANCH_ID)) # .ScriptClip("Subtitle(string(current_frame), y=20)")
b = ColorBars().ConvertToYV12().Subtitle("This is clip B, branch ID = " + string(MP_PIPELINE_BRANCH_ID)) # .ScriptClip("Subtitle(string(current_frame), y=20)")

tnlmeans

Subtitle(string(MP_PIPELINE_BRANCH_ID), y=30)


### export clip: a, b
# Export some clip variables to the next downstream process.
# The variables are only available in the next process, unless you add a PASS CLIP statement (see below)

# This part will run parallelly in 4 processes, specified by BRANCH statement below.
### branch: 4, 3

# SOME OTHER FILTERS # <-- Note: Lines after branch statement will be added after SelectEvery

### prefetch: 5, 2
# Prefetch max. 5 frames in this process, 2 frames behind currently requested frame will be kept to allow backward seeking
# All cache frames will be purged if we seek more than 2 frames backward

### ###

StackHorizontal(last, a)

### pass clip: b
# Clip b will also be available in the next process.
# Note that b in the next process is directly imported from the upstream process, that means any changes to this variable
# in current process won't be visible in next process

### prefetch: 5, 2

### ###


StackHorizontal(last, b)

### prefetch: 5, 2

### ###

# Codes here will be run in the main process, all statements (branch, prefetch etc.) in this block will be ignored
last

""")

"""

Note: This example script is used for demostration only. It is far from optimal. You need to tweak the settings yourself for best speed.

Available statements:

### branch: <number of branch processes>[, <thunk size>]

Parallelize script processing. See example above for details. 

Note that this statement is only suitable for spatial filters. For temporal filters, the processing speed may be slower than single process due to filter mechanics.

Thunking:

You can specify thunk size in the branch statement. For example if you write "### branch: 4, 4", slave processes will process frames like this:

Process 0:  0,  1,  2,  3, 16, 17, 18, 19, ...
Process 1:  4,  5,  6,  7, 20, 21, 22, 23, ...
Process 2:  8,  9, 10, 11, 24, 25, 26, 27, ...
Process 3: 12, 13, 14, 15, 28, 29, 30, 31, ...

If thunk size is set to 1 or omitted, it will behave like using regular SelectEvery and Interleave.

#######################################################

### platform: <win32|win64>

Run the containing part of script on specified platform, so that you can use 32bit filter in 64bit main process, or vice vesa.

#######################################################

### prefetch: <max frames in cache per clip>, <frames to keep behind current frame>

Enable prefetching. Please see example above for details.

Note: Don't enable prefetching in processes that require random access (such as processes that are upstream of branched process) unless you know what you are doing, otherwise performance may be significantly degraded.

#######################################################

### export clip: <one or more clip variables separated by comma>

Please see the example above for details.

#######################################################

### pass clip: <one or more clip variables separated by comma>

Please see the example above for details.

#######################################################

### lock threads to cores

Slave processes with this statement will lock their worker threads into a core. This may improve performance for some scripts.

Core selection is on a round-robin manner, with awareness of hyper-threading.

#######################################################

### inherit start ### / ### inherit end ###

Duplicate codes into downstream processes.

"""

trim(0, 100)

