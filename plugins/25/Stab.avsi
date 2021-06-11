##############################################################################
#Original script by g-force converted into a stand alone script by McCauley  #
#latest version from December 10, 2008                                       #
##############################################################################

function Stab (clip clp, int "range", int "dxmax", int "dymax") {

range = default(range, 1)
dxmax = default(dxmax, 4)
dymax = default(dymax, 4)

temp  = clp.TemporalSoften(7,255,255,25,2)
inter = Interleave(temp.Repair(clp.TemporalSoften(1,255,255,25,2)),clp)
mdata = DePanEstimate(inter,range=range,trust=0,dxmax=dxmax,dymax=dymax)

DePan(inter,data=mdata,offset=-1)
SelectEvery(2,0) }