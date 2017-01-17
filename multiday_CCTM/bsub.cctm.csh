#!/bin/csh -f

 set GRID = 12
 set GR = 12km
 set STDATE   = 2010364
 set ENDATE   = 2011181
 set TODAY    = 2011105
 @ TOMM = $TODAY + 1
 if ( $TOMM == 2010366 ) set TOMM = 2011001

 while ( $TODAY <= $ENDATE )

setenv RUNDIR /CMAQv51/scripts/cctm

#unzip input files
source /CMAQv51/scripts/config.cmaq
set IN_PTpath = $M3DATA/emis/cmaq.cb05.36km
set EMISpath  = $M3DATA/emis/cmaq.cb05.$GR
set EMISfile  = emis_mol3d.abmp.$TODAY.$GR.cmaq.cb05.ncf #> Surface emissions

setenv EMIS_1 $EMISpath/$EMISfile
setenv STK_GRPS_01 $IN_PTpath/stack_groups.$TODAY.36km.ncf
setenv STK_EMIS_01 $IN_PTpath/inln_all.$TODAY.1.36km.cb05.ncf
if ( -e $EMIS_1.gz )      gunzip $EMIS_1.gz
if ( -e $STK_GRPS_01.gz ) gunzip $STK_GRPS_01.gz
if ( -e $STK_EMIS_01.gz ) gunzip $STK_EMIS_01.gz


#BSUB -n 32
#BSUB -J CMAQ12
#BSUB -a mvapich2
#BSUB -oo LOGS/run.cctm.%J.qlog
#BSUB -q week

mpirun.lsf $RUNDIR/run.cctm.csh $TODAY

@ TODAY = $TODAY + 1
if ( $TODAY == 2010366 ) then
  set TODAY = 2011001
endif

end #while

