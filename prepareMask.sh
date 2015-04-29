#/bin/bash

MAD_CUT=6

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
  opts=`grep %prepareMask_Opts% $confFile |sed 's# *%prepareMask_Opts% *##'`
fi
echo
echo $0 will use the following opts: $opts
echo

BASE_DIR=$1

trimEXE=$DAMIC_SOFT_ROOT/trimSide/trimSide.exe
makeMask=$DAMIC_SOFT_ROOT/makeMask/makeMask.exe

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

if [ ! -f "$BASE_DIR/mad.fits" ]
then
  echo
  echo Error: mad file does not exist. Will not continue.
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

echo
echo
echo ===============================
echo Computing Mask
echo ===============================
echo
$trimEXE -r $BASE_DIR/mad.fits -o $TEMP_DIR/trim_mad.fits $opts
$makeMask $TEMP_DIR/trim_mad.fits -c $MAD_CUT -o $TEMP_DIR"/mask"$MAD_CUT"_sel_R.fits"
mv -f $TEMP_DIR/"mask"$MAD_CUT"_sel_R.fits" $BASE_DIR/"mask"$MAD_CUT"_sel_R.fits"
rm $TEMP_DIR/trim_mad.fits

echo
echo Deleting temporary directory: $TEMP_DIR
echo
rm -rf $TEMP_DIR

echo
