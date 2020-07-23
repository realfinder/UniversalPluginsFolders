##Dust Version 5 by Steady 01/23/2003

LoadPlugin("DustV5.dll")
AVIsource("my.avi")

## Faerydust (temporal only) maximum detail
#FaeryDust([limit=2],[output="RGB/RGB32/RGB24/YUY2"])

## PixieDust (Temporal + spatial) max compression
PixieDust([limit=5],[output="RGB/RGB32/RGB24/YUY2"])

## GoldDust (heavy spatial) max noise removal
GoldDust([limit=8],[output="RGB/RGB32/RGB24/YUY2"])

## SpaceDust (Spacial only) max speed
SpaceDust([output="RGB/RGB32/RGB24/YUY2])

## Version 5 changes:
## Greatly reduced blockiness with motion
## many small changes

## Known issues:
## Very slow
## Only one instance per script
