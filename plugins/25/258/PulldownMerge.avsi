/*

  PulldownMerge - 5つの周期パターンからプログレッシブクリップを選択

    clip                         テレシネクリップ (2-2-2-4等の変則的な周期は非対応)

    mode [default:0]          1  解除パターン IPPPI
                              2  解除パターン IIPPP
                              3  解除パターン PIIPP
                              4  解除パターン PPIIP
                              5  解除パターン PPPII
                              0  すべてのパターンを一覧表示（強制 fast モード）

    fast [default:false]  false  FlexibleMergeでフィールドブレンドされた高画質なクリップを返します
                           true  Mergeでブレンドされた低画質なクリップを返します（高速）

    adjust [default:true] false  終端の縞と重複フレームを削除し、すべてのフレームを一意のプログレッシブにします。
                                 フレーム数が完全な4/5ではなくなります。
                           true  終端の縞フレームを削除し、フレーム数をすべて4/5に調整します。
                                 終端に重複フレームが発生します。

*/
function PulldownMerge(clip clip, int "mode", bool "fast",  bool "adjust") {
adjust=Default(adjust,true)
return adjust==true?PulldownMerge_adjustON(clip,mode,fast):PulldownMerge_adjustOFF(clip,mode,fast)
}
function PulldownMerge_adjustOFF(clip clip, int "mode", bool "fast") {
mode=Default(mode,0)
fast=Default(fast,false)
Assert(0<=mode&&mode<=5, "error.")

#  IPPPI
v1=clip.DoubleWeave().Pulldown(1,4)
v2=clip.DoubleWeave().Pulldown(2,4)
mode01_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode01_merge=Merge(v1,v2)

mode01_flxmerge=(clip.FrameCount%5==0?mode01_flxmerge.RemoveLastFrame():mode01_flxmerge)
mode01_flxmerge=(clip.FrameCount%5==1?mode01_flxmerge.RemoveLastFrame():mode01_flxmerge)
mode01_merge=(clip.FrameCount%5==0?mode01_merge.RemoveLastFrame():mode01_merge)
mode01_merge=(clip.FrameCount%5==1?mode01_merge.RemoveLastFrame():mode01_merge)

#  IIPPP
v1=clip.DoubleWeave().Pulldown(1,3)
v2=clip.DoubleWeave().Pulldown(1,4)
mode02_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode02_merge=Merge(v1,v2)

mode02_flxmerge=(clip.FrameCount%5==1?mode02_flxmerge.RemoveLastFrame():mode02_flxmerge)
mode02_flxmerge=(clip.FrameCount%5==2?mode02_flxmerge.RemoveLastFrame():mode02_flxmerge)
mode02_merge=(clip.FrameCount%5==1?mode02_merge.RemoveLastFrame():mode02_merge)
mode02_merge=(clip.FrameCount%5==2?mode02_merge.RemoveLastFrame():mode02_merge)

#  PIIPP
v1=clip.DoubleWeave().Pulldown(0,3)
v2=clip.DoubleWeave().Pulldown(1,3)
mode03_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode03_merge=Merge(v1,v2)

mode03_flxmerge=(clip.FrameCount%5==2?mode03_flxmerge.RemoveLastFrame():mode03_flxmerge)
mode03_flxmerge=(clip.FrameCount%5==3?mode03_flxmerge.RemoveLastFrame():mode03_flxmerge)
mode03_merge=(clip.FrameCount%5==2?mode03_merge.RemoveLastFrame():mode03_merge)
mode03_merge=(clip.FrameCount%5==3?mode03_merge.RemoveLastFrame():mode03_merge)

#  PPIIP
v1=clip.DoubleWeave().Pulldown(0,2)
v2=clip.DoubleWeave().Pulldown(0,3)
mode04_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode04_merge=Merge(v1,v2)

mode04_flxmerge=(clip.FrameCount%5==3?mode04_flxmerge.RemoveLastFrame():mode04_flxmerge)
mode04_flxmerge=(clip.FrameCount%5==4?mode04_flxmerge.RemoveLastFrame():mode04_flxmerge)
mode04_merge=(clip.FrameCount%5==3?mode04_merge.RemoveLastFrame():mode04_merge)
mode04_merge=(clip.FrameCount%5==4?mode04_merge.RemoveLastFrame():mode04_merge)

#  PPPII
v1=clip.DoubleWeave().Pulldown(0,2).Trim(1,0)
v2=clip.DoubleWeave().Pulldown(2,4)
mode05_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode05_merge=Merge(v1,v2)

mode05_flxmerge=(clip.FrameCount%5==4?mode05_flxmerge.RemoveLastFrame():mode05_flxmerge)
mode05_flxmerge=(clip.FrameCount%5==0?mode05_flxmerge.RemoveLastFrame():mode05_flxmerge)
mode05_merge=(clip.FrameCount%5==4?mode05_merge.RemoveLastFrame():mode05_merge)
mode05_merge=(clip.FrameCount%5==0?mode05_merge.RemoveLastFrame():mode05_merge)

#  View
view=ShowFiveVersions( \
mode01_merge.CombCheck().SubTitle("IPPPI (mode=1)",size=96), \
mode02_merge.CombCheck().SubTitle("IIPPP (mode=2)",size=96), \
mode03_merge.CombCheck().SubTitle("PIIPP (mode=3)",size=96), \
mode04_merge.CombCheck().SubTitle("PPIIP (mode=4)",size=96), \
mode05_merge.CombCheck().SubTitle("PPPII (mode=5)",size=96))

clip_flxmerge= mode!=0 ? \
(mode!=1?(mode!=2?(mode!=3?(mode!=4?(mode!=5?(nop()): \
(mode05_flxmerge)):(mode04_flxmerge)):(mode03_flxmerge)):(mode02_flxmerge)):(mode01_flxmerge)):(view)

clip_merge= mode!=0 ? \
(mode!=1?(mode!=2?(mode!=3?(mode!=4?(mode!=5?(nop()): \
(mode05_merge)):(mode04_merge)):(mode03_merge)):(mode02_merge)):(mode01_merge)):(view)

return fast==true?clip_merge:clip_flxmerge
}

function PulldownMerge_adjustON(clip clip, int "mode", bool "fast") {
mode=Default(mode,0)
fast=Default(fast,false)
Assert(0<=mode&&mode<=5, "error.")

#  IPPPI
v1=clip.DoubleWeave().Pulldown(1,4)
v2=clip.DoubleWeave().Pulldown(2,4)
mode01_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode01_merge=Merge(v1,v2)

mode01_flxmerge=(clip.FrameCount%5==0?mode01_flxmerge.RemoveLastFrame().AddLastFrame():mode01_flxmerge)
mode01_flxmerge=(clip.FrameCount%5==2?mode01_flxmerge.AddLastFrame():mode01_flxmerge)
mode01_flxmerge=(clip.FrameCount%5==3?mode01_flxmerge.AddLastFrame():mode01_flxmerge)
mode01_flxmerge=(clip.FrameCount%5==4?mode01_flxmerge.AddLastFrame():mode01_flxmerge)
mode01_merge=(clip.FrameCount%5==0?mode01_merge.RemoveLastFrame().AddLastFrame():mode01_merge)
mode01_merge=(clip.FrameCount%5==2?mode01_merge.AddLastFrame():mode01_merge)
mode01_merge=(clip.FrameCount%5==3?mode01_merge.AddLastFrame():mode01_merge)
mode01_merge=(clip.FrameCount%5==4?mode01_merge.AddLastFrame():mode01_merge)

#  IIPPP
v1=clip.DoubleWeave().Pulldown(1,3)
v2=clip.DoubleWeave().Pulldown(1,4)
mode02_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode02_merge=Merge(v1,v2)

mode02_flxmerge=(clip.FrameCount%5==1?mode02_flxmerge.RemoveLastFrame().AddLastFrame():mode02_flxmerge)
mode02_flxmerge=(clip.FrameCount%5==3?mode02_flxmerge.AddLastFrame():mode02_flxmerge)
mode02_flxmerge=(clip.FrameCount%5==4?mode02_flxmerge.AddLastFrame():mode02_flxmerge)
mode02_merge=(clip.FrameCount%5==1?mode02_merge.RemoveLastFrame().AddLastFrame():mode02_merge)
mode02_merge=(clip.FrameCount%5==3?mode02_merge.AddLastFrame():mode02_merge)
mode02_merge=(clip.FrameCount%5==4?mode02_merge.AddLastFrame():mode02_merge)

#  PIIPP
v1=clip.DoubleWeave().Pulldown(0,3)
v2=clip.DoubleWeave().Pulldown(1,3)
mode03_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode03_merge=Merge(v1,v2)

mode03_flxmerge=(clip.FrameCount%5==2?mode03_flxmerge.RemoveLastFrame().AddLastFrame():mode03_flxmerge)
mode03_flxmerge=(clip.FrameCount%5==4?mode03_flxmerge.AddLastFrame():mode03_flxmerge)
mode03_merge=(clip.FrameCount%5==2?mode03_merge.RemoveLastFrame().AddLastFrame():mode03_merge)
mode03_merge=(clip.FrameCount%5==4?mode03_merge.AddLastFrame():mode03_merge)

#  PPIIP
v1=clip.DoubleWeave().Pulldown(0,2)
v2=clip.DoubleWeave().Pulldown(0,3)
mode04_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode04_merge=Merge(v1,v2)

mode04_flxmerge=(clip.FrameCount%5==3?mode04_flxmerge.RemoveLastFrame().AddLastFrame():mode04_flxmerge)
mode04_merge=(clip.FrameCount%5==3?mode04_merge.RemoveLastFrame().AddLastFrame():mode04_merge)

#  PPPII
v1=clip.DoubleWeave().Pulldown(0,2).Trim(1,0)
v2=clip.DoubleWeave().Pulldown(2,4)
mode05_flxmerge=auto_merge_order(v1,v2,nmax=5)
mode05_merge=Merge(v1,v2)

mode05_flxmerge=(clip.FrameCount%5==1?mode05_flxmerge.AddLastFrame():mode05_flxmerge)
mode05_flxmerge=(clip.FrameCount%5==2?mode05_flxmerge.AddLastFrame():mode05_flxmerge)
mode05_flxmerge=(clip.FrameCount%5==3?mode05_flxmerge.AddLastFrame():mode05_flxmerge)
mode05_flxmerge=(clip.FrameCount%5==4?mode05_flxmerge.RemoveLastFrame().AddLastFrame().AddLastFrame():mode05_flxmerge)
mode05_merge=(clip.FrameCount%5==1?mode05_merge.AddLastFrame():mode05_merge)
mode05_merge=(clip.FrameCount%5==2?mode05_merge.AddLastFrame():mode05_merge)
mode05_merge=(clip.FrameCount%5==3?mode05_merge.AddLastFrame():mode05_merge)
mode05_merge=(clip.FrameCount%5==4?mode05_merge.RemoveLastFrame().AddLastFrame().AddLastFrame():mode05_merge)

#  View
view=ShowFiveVersions( \
mode01_merge.CombCheck().SubTitle("IPPPI (mode=1)",size=96), \
mode02_merge.CombCheck().SubTitle("IIPPP (mode=2)",size=96), \
mode03_merge.CombCheck().SubTitle("PIIPP (mode=3)",size=96), \
mode04_merge.CombCheck().SubTitle("PPIIP (mode=4)",size=96), \
mode05_merge.CombCheck().SubTitle("PPPII (mode=5)",size=96))

clip_flxmerge= mode!=0 ? \
(mode!=1?(mode!=2?(mode!=3?(mode!=4?(mode!=5?(nop()): \
(mode05_flxmerge)):(mode04_flxmerge)):(mode03_flxmerge)):(mode02_flxmerge)):(mode01_flxmerge)):(view)

clip_merge= mode!=0 ? \
(mode!=1?(mode!=2?(mode!=3?(mode!=4?(mode!=5?(nop()): \
(mode05_merge)):(mode04_merge)):(mode03_merge)):(mode02_merge)):(mode01_merge)):(view)

return fast==true?clip_merge:clip_flxmerge
}

function AddLastFrame(clip clip) {
return clip++clip.Trim(clip.FrameCount-1,clip.FrameCount-1)
}
function RemoveLastFrame(clip clip) {
return clip.Trim(0,clip.FrameCount-2)
}
