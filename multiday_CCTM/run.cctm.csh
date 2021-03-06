#!/bin/csh -f

# ====================== CCTMv5.0.2 Run Script ====================== #
# Usage: run.cctm >&! cctm_D502a.log &                                #
# The following environment variables must be set for this script to  #
# execute properly:                                                   #
#   setenv M3DATA =  input/output data directory                      #
# To report problems or request help with this script/program:        #
#             http://www.cmascenter.org/html/help.html                #
# =================================================================== #
 
#> Source the config.cmaq file to set the run environment
 source ../config.cmaq
 
#> Check that M3DATA is set:
 if ( ! -e $M3DATA ) then
    echo "   $M3DATA path does not exist"
    exit 1
    endif
 echo " "; echo " Input data path, M3DATA set to $M3DATA"; echo " "
 
 set PROC     = mpi #> serial or mpi
 set APPL     = Example 
 set MECH     = cb05tume_ae5_aq 
 set GRID     = 12
 set G        = 12

#> horizontal domain decomposition
if ( $PROC == serial ) then
   setenv NPCOL_NPROW "1 1"; set NPROCS   = 1 # single processor setting
else
   setenv NPCOL_NPROW "8 4"; set NPROCS   = 32
#   setenv NPCOL_NPROW "1 1"; set NPROCS   = 1 
endif

#> timestep run parameters

set FIRSTDAY = 2010364
set TODAY  = $argv[1]

if ( $TODAY <= 2010365 ) then 
   set CFG      = v502_MPI
   set EXEC     = CCTM_v502_MPI_Linux2_x86_64intel
else
   set CFG      = v502.0.3dInline_CH4
   set EXEC     = CCTM_v502_3dInline_CH4_Linux2_x86_64intel
endif

#> Set the working directory:
 set BASE     = $M3HOME/scripts/cctm
 set BLD      = ${BASE}/BLD_${CFG}
 cd $BASE; date; cat $BASE/cfg.$CFG; echo "    "; set echo

if ( $TODAY == 2011001 ) then
   set YEST = 2010365
else
   @ YEST = $TODAY - 1
endif
set STTIME   = 000000        # beginning GMT time (HHMMSS)
set NSTEPS   = 240000        # time duration (HHMMSS) for this run
set TSTEP    = 010000        # output time step interval (HHMMSS)
set GDATE = `/apps/ioapi_30/072908/Linux2_x86pg_pgcc_nomp/datshift $TODAY 0`
echo $GDATE

set YEAR  = `echo $GDATE | cut -c1-4`
set YR    = `echo $GDATE | cut -c3-4`
set MONTH = `echo $GDATE | cut -c5-6`
set DAY   = `echo $GDATE | cut -c7-8`
set MN = `echo $MONTH | awk '{printf "%2.1i", $0}'`

setenv YMD ${YEAR}${MONTH}${DAY}

# =====================================================================
# CCTM Configuration Options
# =====================================================================

#setenv LOGFILE $BASE/$APPL.log  #> log file name; uncomment to write standard output to a log, otherwise write to screen

setenv GRID_NAME ${GRID}KM             #> check GRIDDESC file for GRID_NAME options
setenv GRIDDESC  $M3DATA/met/$GRID_NAME/2011001/GRIDDESC  #> horizontal grid defn

if ( $YEAR == 2010 || $GRID == 36 ) then
   setenv AVG_CONC_SPCS   "O3 NO NO2 CO ANO3I ANO3J ANH4I ANH4J ASO4I ASO4J AECI AECJ" # NO CO NO2 ASO4I ASO4J NH3" #> ACONC file species; comment or set to "ALL" to write all species to ACONC
   setenv ACONC_BLEV_ELEV " 1 1"  #> ACONC file layer range; comment to write all layers to ACONC
   #setenv ACONC_END_TIME Y #> override default beginning ACON timestamp [ default: N ]
else
   setenv AVG_CONC_SPCS   "ALL" # NO CO NO2 ASO4I ASO4J NH3" #> ACONC file species; comment or set to "ALL" to write all species to ACONC
   setenv ACONC_BLEV_ELEV " 1 1"  #> ACONC file layer range; comment to write all layers to ACONC
   #setenv ACONC_END_TIME Y #> override default beginning ACON timestamp [ default: N ]
endif
   #setenv CONC_SPCS "ALL" #> CONC file species; comment or set to "ALL" to write all species to CONC
   #setenv CONC_BLEV_ELEV " 1 1" #> CONC file layer range; comment to write all layers to CONC
endif

if ( $GRID == 36 ) then
   setenv CTM_MAXSYNC    720    #> max sync time step (sec) [default: 720]
else
   setenv CTM_MAXSYNC    300    #> max sync time step (sec) [default: 720]
endif
setenv CTM_MINSYNC     60    #> min sync time step (sec) [default: 60]
setenv CTM_CKSUM        N    #> write cksum report [ default: Y ]
setenv CLD_DIAG         N    #> write cloud diagnostic file [ default: N ]
setenv CTM_AERDIAG      Y    #> aerosol diagnostic file [ default: N ]
setenv CTM_PHOTDIAG     N    #> photolysis diagnostic file [ default: N ]
setenv CTM_SSEMDIAG     N    #> sea-salt emissions diagnostic file [ default: N ]
setenv CTM_WB_DUST      N    #> use inline windblown dust emissions [ default: Y ]
setenv CTM_ERODE_AGLAND Y    #> use agricultural activity for windblown dust [ default: N ]; ignore if CTM_WB_DUST = N
setenv CTM_DUSTEM_DIAG  Y    #> windblown dust emissions diagnostic file [ default: N ]; ignore if CTM_WB_DUST = N
setenv CTM_LTNG_NO      N    #> turn on lightning NOx [ default: N ]
setenv CTM_WVEL         Y    #> save derived vertical velocity component to conc file [ default: N ]
setenv KZMIN            Y    #> use Min Kz option in edyintb [ default: Y ], otherwise revert to Kz0UT
setenv CTM_ILDEPV       Y    #> calculate in-line deposition velocities [ default: Y ]
setenv CTM_MOSAIC       N    #> landuse specific deposition velocities [ default: N ]
setenv CTM_ABFLUX       N    #> Ammonia bi-directional flux for in-line deposition velocities [ default: N ]; ignore if CTM_ILDEPV = N
setenv CTM_HGBIDI       N    #> Mercury bi-directional flux for in-line deposition velocities [ default: N ]; ignore if CTM_ILDEPV = N
setenv CTM_SFC_HONO     Y    #> Surface HONO interaction [ default: Y ]; ignore if CTM_ILDEPV = N
setenv CTM_DEPV_FILE    N    #> write diagnostic file for deposition velocities [ default: N ]
setenv CTM_BIOGEMIS     N    #> calculate in-line biogenic emissions [ default: N ]
setenv B3GTS_DIAG       N    #> write biogenic mass emissions diagnostic file [ default: N ]; ignore if CTM_BIOGEMIS = N
setenv CTM_PT3DEMIS     Y    #> calculate in-line plume rise for elevated point emissions [ default: N ]
setenv PT3DDIAG         N    #> optional 3d point source emissions diagnostic file [ default: N]; ignore if CTM_PT3DEMIS = N
setenv PT3DFRAC         N    #> optional layer fractions diagnostic (play) file(s) [ default: N]; ignore if CTM_PT3DEMIS = N
setenv IOAPI_LOG_WRITE  N    #> turn on excess WRITE3 logging [ options: T | F ]
setenv FL_ERR_STOP      N    #> stop on inconsistent input files
setenv PROMPTFLAG       N    #> turn on I/O-API PROMPT*FILE interactive mode [ options: T | F ]
setenv IOAPI_OFFSET_64  N    #> support large timestep records (>2GB/timestep record) [ options: YES | NO ]
setenv EXECUTION_ID $EXEC    #> define the model execution id

set DISP = delete            #> [ delete | update | keep ] existing output files

# =====================================================================
#> Input/Output Directories
# =====================================================================

set BCpath    = $M3DATA/icbc/              #> boundary conditions input directory
set EMISpath  = $M3DATA/emis/cmaq.cb05.${G}km      #> surface emissions input directory
set IN_PTpath = $M3DATA/emis/cmaq.cb05.36km        #> elevated emissions input directory (in-line point only)
set IN_LTpath = $M3DATA/lightning #> lightning NOx input directory
set METpath   = $M3DATA/met/$GRID_NAME/$TODAY #> meteorology input directory 
set JVALpath  = $M3DATA/jproc     #> offline photolysis rate table directory
set OMIpath   = $M3DATA/raw/phot  #> ozone columne data for the photolysis model
set LUpath    = $M3DATA/dust      #> BELD landuse data for windblown dust model
set SZpath    = $M3DATA/ocean     #> Surf zone file for in-line seasalt emissions

set OUTDIR   = $M3DATA/cctm/${GRID}KM   #> output file directory

# =====================================================================
#> Input Files
# =====================================================================

#> Initial conditions
if ( $TODAY == $FIRSTDAY ) then
   set ICpath    = $M3DATA/icbc     #> initial conditions input directory 
   set ICFILE = ic.${G}km.cb05_ae5.cmaq502.$FIRSTDAY.gmt.hr0.nest.ncf 
   #set ICpath    = $M3DATA/icon              #> initial conditions input directory 
else 
   set ICpath = $M3DATA/cctm/${GRID}KM
   if ( $TODAY == 2011001 ) then
      set ICFILE = CCTM_v502_MPI_Linux2_x86_64intel.CGRID.${GRID}KM_${YEST}.ncf
   else
      set ICFILE =  $EXEC.CGRID.${APPL}_${GRID}KM_${YEST}.ncf
   endif
endif

#> Boundary conditions
set BCFILE = bc.${G}km.cb05_ae5.cmaq502.$TODAY.gmt.nest.ncf  

#> Off-line photolysis rates 
set JVALfile  = JTABLE_${TODAY}

#> Ozone column data
set OMIfile   = OMI.dat

#> MCIP meteorology files 
set EXTN = $TODAY
setenv GRID_DOT_2D $METpath/GRIDDOT2D_${EXTN}
setenv GRID_CRO_2D $METpath/GRIDCRO2D_${EXTN}
setenv MET_CRO_2D $METpath/METCRO2D_${EXTN}
setenv MET_CRO_3D $METpath/METCRO3D_${EXTN}
setenv MET_DOT_3D $METpath/METDOT3D_${EXTN}
setenv MET_BDY_3D $METpath/METBDY3D_${EXTN}

#> Emissions files 

if ( $CTM_PT3DEMIS == 'N' ) then
   set EMISfile  = emis_mol.abmp.$TODAY.${G}km.cmaq.cb05.ncf  #> Offline 3d emissions file name
else
   #> In-line emissions configuration
   setenv CTM_EMLAYS 25
   if ( $YEAR == 2010 ) then
      set EMISfile  = emis_mol.low.$TODAY.${G}km.cmaq.cb05.ncf #> Surface emissions
   else
      set EMISfile  = emis_mol3d.abmp.$TODAY.${G}km.cmaq.cb05.ncf #> Surface emissions
   endif
   setenv NPTGRPS 1          #> Number of elevated source groups
   setenv STK_GRPS_01 $IN_PTpath/stack_groups.$TODAY.36km.ncf
   setenv LAYP_STTIME $STTIME
   setenv LAYP_NSTEPS $NSTEPS
   setenv STK_EMIS_01 $IN_PTpath/inln_all.$TODAY.1.36km.cb05.ncf
   setenv LAYP_STDATE $TODAY
endif

#> Lightning NOx configuration
if ( $CTM_LTNG_NO == 'Y' ) then
   setenv LTNGNO $IN_LTpath/nox_CMAQ-BENCHMARK.35L.$EMISDATE  #> offline calculated lightning NOx
#   setenv LTNGNO "InLine"    #> set LTNGNO to "Inline" to activate in-line calculation

#> In-line lightning NOx options
   setenv LTNGPARAM N        #> use lightning parameter file? [ default: Y ]
   setenv LTNGPARM_FILE $M3DATA/params/LTNG_RATIO.2004.$MONTH.ioapi #> lightning parameter file; ignore if LTNGPARAM = N
   setenv LTNGDIAG N         #> write lightning diagnostic file [ default: N ]
   setenv LTNGOUT $OUTDIR/$EXEC.LTNGDIAG.${CFG}_${EMISDATE} #> lightning diagnostic file; ignore if LTNGDIAG = N
endif

#> In-line biogenic emissions configuration
if ( $CTM_BIOGEMIS == 'Y' ) then   
   set GSPROpath = ${M3DATA}/emis
   setenv GSPRO $GSPROpath/gspro_cb05soa_notoxics_cmaq_poc_09nov2007.txt
   set IN_BEISpath = ${M3DATA}/emis
   setenv B3GRD     $IN_BEISpath/b3grd_CMAQ-BENCHMARK_C70_2006am_Fulltox.ncf
   setenv BIOG_SPRO     B10C5 # speciation profile to use for biogenics
   setenv BIOSW_YN      N     # use frost date switch [ default: Y ]
   setenv BIOSEASON $IN_BEISpath/bioseason.cmaq.2002_02b_CMAQ-BENCHMARK_v31.ncf #> ignore season switch file if BIOSW_YN = N
   setenv SUMMER_YN     Y     # Use summer normalized emissions? [ default: Y ]
   setenv PX_VERSION    N     # MCIP is PX version? [ default: N ]
   setenv B3GTS_DIAG Y #> beis mass emissions diagnostic file [ default: N ]
   setenv INITIAL_RUN Y # non-existent or not using SOILINP [ default: N ]; default uses SOILINP
   setenv SOILINP $OUTDIR/$EXEC.SOILINP.${CFG}_${EMISDATE}  # Biogenic NO soil input file; ignore if INITIAL_RUN = Y
endif

#> Windblown dust emissions configuration
if ( $CTM_WB_DUST == 'Y' ) then
   setenv DUST_LU_1 $LUpath/beld3_CMAQ-BENCHMARK_output_a.ncf
   setenv DUST_LU_2 $LUpath/beld3_CMAQ-BENCHMARK_output_tot.ncf
   if ( $CTM_ERODE_AGLAND == 'Y' ) then
      setenv CROPMAP01 ${M3DATA}/crop/BeginPlanting_12km_CMAQ-BENCHMARK
      setenv CROPMAP04 ${M3DATA}/crop/EndPlanting_12km_CMAQ-BENCHMARK
      setenv CROPMAP08 ${M3DATA}/crop/EndHarvesting_12km_CMAQ-BENCHMARK
   endif
endif

#> In-line sea salt emisisions configuration
setenv OCEAN_1 $SZpath/ocean_file_${G}km.ncf #> horizontal grid-dependent surf zone file

# =====================================================================
#> Output Files
# =====================================================================

#> set output file name extensions
 setenv CTM_APPL ${APPL}_${GRID}KM_${TODAY}
#> set output file names
 set CONCfile  = $EXEC.CONC.${CTM_APPL}.ncf               # CTM_CONC_1
 set ACONCfile = $EXEC.ACONC.${CTM_APPL}.ncf              # CTM_ACONC_1
 set CGRIDfile = $EXEC.CGRID.${CTM_APPL}.ncf              # CTM_CGRID_1
 set DD1file   = $EXEC.DRYDEP.${CTM_APPL}.ncf             # CTM_DRY_DEP_1
 set DV1file   = $EXEC.DEPV.${CTM_APPL}.ncf               # CTM_DEPV_DIAG
 set PT1file   = $EXEC.PT3D.${CTM_APPL}.ncf               # CTM_PT3D_DIAG
 set BIO1file  = $EXEC.B3GTS_S.${CTM_APPL}.ncf            # B3GTS_S
 set SOIL1file = $EXEC.SOILOUT.${CTM_APPL}.ncf            # SOILOUT
 set WD1file   = $EXEC.WETDEP1.${CTM_APPL}.ncf            # CTM_WET_DEP_1
 set WD2file   = $EXEC.WETDEP2.${CTM_APPL}.ncf            # CTM_WET_DEP_2
 set AV1file   = $EXEC.AEROVIS.${CTM_APPL}.ncf            # CTM_VIS_1
 set AD1file   = $EXEC.AERODIAM.${CTM_APPL}.ncf           # CTM_DIAM_1
 set RJ1file   = $EXEC.PHOTDIAG1.${CTM_APPL}.ncf          # CTM_RJ_2
 set RJ2file   = $EXEC.PHOTDIAG2.${CTM_APPL}.ncf          # CTM_RJ_2
 set SSEfile   = $EXEC.SSEMIS.$CTM_APPL.ncf               # CTM_SSEMIS_1
 set DSEfile   = $EXEC.DUSTEMIS.$CTM_APPL.ncf             # CTM_DUST_EMIS_1
 set PA1file   = $EXEC.PA_1.${CTM_APPL}.ncf               # CTM_IPR_1
 set PA2file   = $EXEC.PA_2.${CTM_APPL}.ncf               # CTM_IPR_2
 set PA3file   = $EXEC.PA_3.${CTM_APPL}.ncf               # CTM_IPR_3
 set IRR1file  = $EXEC.IRR_1.${CTM_APPL}.ncf              # CTM_IRR_1
 set IRR2file  = $EXEC.IRR_2.${CTM_APPL}.ncf              # CTM_IRR_2
 set IRR3file  = $EXEC.IRR_3.${CTM_APPL}.ncf              # CTM_IRR_3
 set DEPVFSTfile = $EXEC.DEPVFST.${CTM_APPL}.ncf          # CTM_DEPV_FST
 set DEPVMOSfile = $EXEC.DEPVMOS.${CTM_APPL}.ncf          # CTM_DEPV_MOS
 set DDFSTfile = $EXEC.DDFST.${CTM_APPL}.ncf              # CTM_DRY_DEP_FST
 set DDMOSfile = $EXEC.DDMOS.${CTM_APPL}.ncf              # CTM_DRY_DEP_MOS
#> In-line biogenic emissions output files
if ( $CTM_BIOGEMIS == 'Y' ) then 
   setenv B3GTS_S $OUTDIR/$EXEC".B3GTS_S".${CTM_APPL}
   setenv SOILOUT $OUTDIR/$EXEC".SOILOUT".${CTM_APPL}  # Biogenic NO soil output file
endif

#> set floor file (neg concs)
setenv FLOOR_FILE $BASE/FLOOR_${CTM_APPL}.txt

#> create output directory 
if ( ! -d "$OUTDIR" ) mkdir -p $OUTDIR

#> look for existing log files
                              
 set test = `ls CTM_LOG_???.${CTM_APPL}.txt`
 if ( "$test" != "" ) then
    if ( $DISP == 'delete' ) then
       echo " ancillary log files being deleted"
       foreach file ( $test )
          echo " deleting $file"
          rm $file
          end
       else
       echo "*** Logs exist - run ABORTED ***"
       exit 1
       endif
    endif

#> for the run control ...

setenv CTM_STDATE      $TODAY
setenv CTM_STTIME      $STTIME
setenv CTM_RUNLEN      $NSTEPS
setenv CTM_TSTEP       $TSTEP
setenv EMIS_1 $EMISpath/$EMISfile
setenv INIT_GASC_1 $ICpath/$ICFILE
setenv INIT_AERO_1 $INIT_GASC_1
setenv INIT_NONR_1 $INIT_GASC_1
setenv INIT_TRAC_1 $INIT_GASC_1
setenv BNDY_GASC_1 $BCpath/$BCFILE
setenv BNDY_AERO_1 $BNDY_GASC_1
setenv BNDY_NONR_1 $BNDY_GASC_1
setenv BNDY_TRAC_1 $BNDY_GASC_1
setenv OMI $OMIpath/$OMIfile
setenv XJ_DATA $JVALpath/$JVALfile
set TR_DVpath = $METpath
set TR_DVfile = $MET_CRO_2D
 
#> species defn & photolysis
setenv gc_matrix_nml ${BLD}/GC_$MECH.nml
setenv ae_matrix_nml ${BLD}/AE_$MECH.nml
setenv nr_matrix_nml ${BLD}/NR_$MECH.nml
setenv tr_matrix_nml ${BLD}/Species_Table_TR_0.nml
 
#> check for photolysis input data
setenv CSQY_DATA ${BLD}/CSQY_DATA_$MECH
if (! (-e $CSQY_DATA ) ) then
   echo " $CSQY_DATA  not found "
  exit 1
endif

#>- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 source $BASE/outck.q

 ls -l $BLD/$EXEC; size $BLD/$EXEC
 unlimit
 limit


#> Executable call for single PE, uncomment to invoke
 /usr/bin/time  $BLD/$EXEC

#> Executable call for multi PE, configure for your system 
# set MPI = /usr/local/intel/impi/3.2.2.006/bin64
# set MPIRUN = $MPI/mpirun
# time $MPIRUN -r ssh -np $NPROCS $BLD/$EXEC

 date
 exit
