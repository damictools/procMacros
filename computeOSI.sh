#/bin/bash

recompute=1

# Any subsequent commands which fail will cause the shell script to exit immediately
set -e

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo
  echo "Error: illegal number of parameters."
  echo "Use:"
  echo $0 "<RAW_DATA_DIRs> <OUT_BASE_DIR> <optional CONFIG_FILE>"
  echo
  exit 1
fi

if [ "$#" == 3 ]; then
  confFile=$3
  if [ ! -f "$confFile" ]; then
    echo
    echo "Error: config file "$confFile" does not exist."
    echo 
    exit 1
  fi
  opts=`grep %computeOSI_Opts% $confFile |sed 's# *%computeOSI_Opts% *##'`
fi
echo
echo $0 will use the following opts: $opts
echo

RAW_DATA_DIR=$1
OUT_BASE_DIR=$2

echo $RAW_DATA_DIR
echo $OUT_BASE_DIR

TS=`date +%s`

[ "X$SCRATCH" = "X" ] && SCRATCH=/tmp/damic/
if [ -d "/scratch/damic/" ]
then 
  SCRATCH=/scratch/damic/
fi

if [[ -z "$OUT_BASE_DIR" ]]
then
  echo
  echo Error: no output directory provided. Will not continue.
  echo
  exit 1
fi 

for i in $RAW_DATA_DIR
do
  if [ ! -d "$i" ]
  then
    echo
    echo Error: raw data directory does not exist. Will not continue.
    echo Could not find: $i
    echo
    exit 1
  fi
done

if [ ! -d "$OUT_BASE_DIR" ]
then
  mkdir -p $OUT_BASE_DIR
fi

if [ ! -d "$OUT_BASE_DIR/osi" ]
then
  mkdir -p $OUT_BASE_DIR/osi
fi

if [ ! -d "$SCRATCH/$USER/temp/temp$TS" ]
then
  mkdir -p $SCRATCH/$USER/temp/temp$TS
else
  echo
  echo Error: temp dir already exist. This should not happend. Please check whats going on and delete it. Will not continue.
  echo
  exit 1
fi
TEMP_DIR=$SCRATCH/$USER/temp/temp$TS

for i in $RAW_DATA_DIR
do
  ls $i/*.fits.fz >> $TEMP_DIR/list.dat
done
mv -f $TEMP_DIR/list.dat $OUT_BASE_DIR/list.dat
LISTNAME=$OUT_BASE_DIR/list.dat
osiEXE=$DAMIC_SOFT_ROOT/subtractOverscan/subtractOverscan.exe
imageStatsEXE=$DAMIC_SOFT_ROOT/imageStats/imageStats.exe


for inFileName in `cat $LISTNAME`
do
  echo
  echo ===============================
  echo $inFileName
  echo ===============================
  echo

#  sigma=`$imageStatsEXE $inFileName |grep 5: | awk '{print $3}'`
#  if [ $sigma = "0" ]
#  then
#    echo
#    echo Not a good image, skipping..
#    echo 
#  else
  tmpName=$TEMP_DIR"/osi_"`echo $inFileName |sed 's#/# #g' |awk '{print $NF}'  |sed 's#\.fz$##'`
  outName=$OUT_BASE_DIR"/osi/osi_"`echo $inFileName |sed 's#/# #g' |awk '{print $NF}'  |sed 's#\.fz$##'`
  if [ ! -f "$outName" ] || [ $recompute == 1 ]; then
    $osiEXE $inFileName -o $tmpName $opts
    mv -f $tmpName $outName
  else
    echo "Omitting, OSI file already exist."
  fi
 # fi
  echo
  echo ===============================
  echo
done

echo
echo Deleting temporary directory: $TEMP_DIR
echo
rm -rf $TEMP_DIR

echo
