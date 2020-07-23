function TomsMoComp(clip clip, int "TopFirst", int "SearchEffort", int "VerticalFilter")
{
LoadPlugin(AviSynthPluginsDir + "25/TomsMoComp.dll")
        TomsMoComp(clip, TopFirst, SearchEffort, VerticalFilter)
}

   function TomsBob (clip c) 
   {
       c = c.SeparateFields.TomsMoComp(0,-1,0).SimpleResize(c.width,c.height+1) 

       # add this if your clip starts on a half-frame (e.g. a top-field in a BottomFirst clip) 
       c = c.Trim(1,0) 

       # invert these for TopFirst source material 
       bottom = c.SelectEven()
       top = c.SelectOdd()

       bottom = bottom.Crop(0,1,0,0) 
       top = top.Crop(0,0,0,-1) 
       return Interleave(bottom, top) 
   }