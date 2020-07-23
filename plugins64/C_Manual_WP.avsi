function Manual_WP(clip clip, float "x", float "y", int "R", int "G", int "B", int "mode", int "debug", float "debug_val", bool "sixtyFour", float "dst_x", float "dst_y")
{
LoadPlugin(AviSynthPlugins64Dir + "cplugin/C_Manual_WP_x64.dll")
        Manual_WP(clip, x, y, R, G, B, mode, debug, debug_val, sixtyFour, dst_x, dst_y)
}