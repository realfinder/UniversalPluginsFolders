function BlockKiller(clip source)
{
    y=source.greyscale()
    y=y.ChannelBlockKiller() 
    u=source.utoy()
    u=u.ChannelBlockKiller() 
    v=source.vtoy()
    v=v.ChannelBlockKiller() 
      
    return ytouv(u, v, y)  
}

function ChannelBlockKiller(clip source)
{
    source
"""   spline36resize(source.width*16,source.height*16)
    gradfunkmirror() 
    gradfunkmirror() 
    gradfunkmirror() 
    spline36resize(source.width*8,source.height*8)
    gradfunkmirror() 
    gradfunkmirror() 
    gradfunkmirror() """
    spline36resize(source.width*4,source.height*4)
    gradfunkmirror() 
    gradfunkmirror() 
    gradfunkmirror() 
    spline36resize(source.width*2,source.height*2)
    gradfunkmirror() 
    gradfunkmirror() 
    gradfunkmirror() 
    spline36resize(source.width,source.height)
    gradfunkmirror() 
    gradfunkmirror() 
    gradfunkmirror() 

    return last
}