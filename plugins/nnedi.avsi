function nnedi(clip clip, int "field", bool "dh", bool "Y", bool "U", bool "V", int "threads", int "opt", string "name")
{
LoadPlugin(AviSynthPluginsDir + "25/nnedi.dll")
        nnedi(clip, field, dh, Y, U, V, threads, opt, name)
}