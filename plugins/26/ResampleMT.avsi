function PointResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        PointResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function BilinearResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        BilinearResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function BicubicResizeMT(clip clip, int "target_width", int "target_height", float "b", float "c", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        BicubicResizeMT(clip, target_width, target_height, b, c, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function LanczosResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        LanczosResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function Lanczos4ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        Lanczos4ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function BlackmanResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        BlackmanResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function Spline16ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        Spline16ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function Spline36ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        Spline36ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function Spline64ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        Spline64ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function GaussResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", float "p", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        GaussResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, p, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function SincResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        SincResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function SinPowResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", float "p", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        SinPowResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, p, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}

function SincLin2ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        SincLin2ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, ThreadLevel)
}


function DeBilinearResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeBilinearResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeBicubicResizeMT(clip clip, int "target_width", int "target_height", float "b", float "c", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeBicubicResizeMT(clip, target_width, target_height, b, c, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeLanczosResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeLanczosResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeLanczos4ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeLanczos4ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeBlackmanResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeBlackmanResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeSpline16ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeSpline16ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeSpline36ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeSpline36ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeSpline64ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeSpline64ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeGaussResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", float "p", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeGaussResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, p, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeSincResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeSincResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeSinPowResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", float "p", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeSinPowResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, p, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}

function DeSincLin2ResizeMT(clip clip, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "threads", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "sleep", int "prefetch", int "range", int "accuracy", int "order", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/ResampleMT.dll")
        DeSincLin2ResizeMT(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, threads, logicalCores, MaxPhysCore, SetAffinity, sleep, prefetch, range, accuracy, order, ThreadLevel)
}