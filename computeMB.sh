#/bin/bash

# Any subsequent commands which fail will cause the shell script to exit immediately
set -e

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo
  echo "Error: illegal number of parameters."
  echo "Use:"
  echo $0 "<OUT_BASE_DIR> <optional CONFIG_FILE>"
  echo
  exit 1
fi

if [ "$#" == 2 ]; then
  confFile=$2
  if [ ! -f "$confFile" ]; then
    echo
    echo "Error: config file "$confFile" does not exist."
    echo 
    exit 1
  fi
  opts=`grep %computeMB_Opts% $confFile |sed 's# *%computeMB_Opts% *##'`
fi
echo
echo $0 will use the following opts: $opts
echo

BASE_DIR=$1

mbEXE=$DAMIC_SOFT_ROOT/checkConsistencyAndComputeMedian/checkConsistencyAndComputeMedian.exe
maskEXE=$DAMIC_SOFT_ROOT/makeMask/makeMask.exe

TS=`date +%s`

[ "X$SCRATCH" = "X" ] && SCRATCH=/tmp/damic/
if [ -d "/scratch/damic/" ]
then
  SCRATCH=/scratch/damic/
fi

if [[ -z "$BASE_DIR" ]]
then
  echo
  echo Error: no base directory provided. Will not continue.
  echo
  exit 1
fi 

if [ ! -d "$BASE_DIR" ]
then
  echo
  echo Error: base directory does not exist. Will not continue.
  echo
  exit 1
fi

if [ ! -d "$BASE_DIR/osi" ]
then
  echo
  echo Error: OSI directory does not exist. Will not continue.
  echo
  exit 1
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



ls $BASE_DIR/osi/osi_*.fits > $TEMP_DIR/mbImageList.dat
mv -f $TEMP_DIR/mbImageList.dat $BASE_DIR/mbImageList.dat

echo
echo
echo ===============================
echo Computing MB
echo ===============================
echo
$mbEXE -i $BASE_DIR/mbImageList.dat -o $TEMP_DIR/masterBias.fits
mv -f $TEMP_DIR/masterBias.fits $BASE_DIR/masterBias.fits

echo
echo
echo ===============================
echo Computing MAD
echo ===============================
echo
$mbEXE -i $BASE_DIR/mbImageList.dat -o $TEMP_DIR/mad.fits -m
mv -f $TEMP_DIR/mad.fits $BASE_DIR/mad.fits


echo
echo Deleting temporary directory: $TEMP_DIR
echo
rm -rf $TEMP_DIR

echo
