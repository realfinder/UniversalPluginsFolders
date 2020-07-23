function TCPServer(clip clip, int "port")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TCPDeliver.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TCPDeliver.dll")
        TCPServer(clip, port)
}

function TCPSource(string hostname, int "port", string "compression")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TCPDeliver.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TCPDeliver.dll")
        TCPSource(hostname, port, compression)
}