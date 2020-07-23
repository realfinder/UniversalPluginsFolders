function dfttest(clip clip, bool "Y", bool "U", bool "V", int "ftype", float "sigma", float "sigma2", float "pmin", float "pmax", int "sbsize", int "smode", int "sosize", int "tbsize", int "tmode", int "tosize", int "swin", int "twin", float "sbeta", float "tbeta", bool "zmean", string "sfile", string "sfile2", string "pminfile", string "pmaxfile", float "f0beta", string "nfile", int "threads", int "opt", string "nstring", string "sstring", string "ssx", string "ssy", string "sst", int "dither", bool "lsb", bool "lsb_in", bool "quiet")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/dfttest.dll") : LoadPlugin(AviSynthPluginsDir + "26/dfttest.dll")
        dfttest(clip, Y, U, V, ftype, sigma, sigma2, pmin, pmax, sbsize, smode, sosize, tbsize, tmode, tosize, swin, twin, sbeta, tbeta, zmean, sfile, sfile2, pminfile, pmaxfile, f0beta, nfile, threads, opt, nstring, sstring, ssx, ssy, sst, dither, lsb, lsb_in, quiet)
}

