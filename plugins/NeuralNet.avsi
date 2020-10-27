function NeuralNetBP(clip clip, clip train, int "sf", int "ef", int "lx", int "ty", int "rx", int "by", int "elx", int "ety", int "erx", int "eby", bool "white", int "xpts", int "ypts", int "tlx", int "tty", int "trx", int "tby", int "thresh", int "tf", float "wh", float "wo", int "iter", bool "test", float "minstep", int "wset", int "cwt", int "hnodes", int "bestof", string "activate", bool "line")
{
LoadPlugin(AviSynthPluginsDir + "25/NeuralNet.dll")
        NeuralNetBP(clip, train, sf, ef, lx, ty, rx, by, elx, ety, erx, eby, white, xpts, ypts, tlx, tty, trx, tby, thresh, tf, wh, wo, iter, test, minstep, wset, cwt, hnodes, bestof, activate, line)
}

function NeuralNetLN(clip clip, clip train, int "sf", int "ef", int "lx", int "ty", int "rx", int "by", int "elx", int "ety", int "erx", int "eby", int "xpts", int "ypts", int "tlx", int "tty", int "trx", int "tby", int "tf", float "wh", int "iter", int "wset", int "bestof", bool "line")
{
LoadPlugin(AviSynthPluginsDir + "25/NeuralNet.dll")
        NeuralNetLN(clip, train, sf, ef, lx, ty, rx, by, elx, ety, erx, eby       , xpts, ypts, tlx, tty, trx, tby        , tf, wh    , iter               , wset             , bestof          , line)
}

function NeuralNetRP(clip clip, clip train, int "sf", int "ef", int "lx", int "ty", int "rx", int "by", int "elx", int "ety", int "erx", int "eby", bool "white", int "xpts", int "ypts", int "tlx", int "tty", int "trx", int "tby", int "thresh", int "tf", float "wh", float "wo", int "iter", bool "test", string "plot", int "wset", int "nplot", int "hnodes", int "bestof", string "activate", bool "line")
{
LoadPlugin(AviSynthPluginsDir + "25/NeuralNet.dll")
        NeuralNetRP(clip, train, sf, ef, lx, ty, rx, by, elx, ety, erx, eby, white, xpts, ypts, tlx, tty, trx, tby, thresh, tf, wh, wo, iter, test, plot, wset, nplot, hnodes, bestof, activate, line)
}