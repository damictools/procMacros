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
  opts=`grep %subtractCorrNoise_Opts% $confFile |sed 's# *%subtractCorrNoise_Opts% *##'`
fi
echo
echo $0 will use the following opts: $opts
echo

BASE_DIR=$1

scnEXE=$DAMIC_SOFT_ROOT/reduceNoise/reduceNoise.exe

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

if [ ! -d "$BASE_DIR/mbs_sel" ]
then
  echo
  echo Error: MBS directory does not exist. Will not continue.
  echo
  exit 1
fi

if [ ! -d "$BASE_DIR/scn" ]
then
  mkdir -p $BASE_DIR/scn
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

rm -f $BASE_DIR/scnImageList.dat
ls $BASE_DIR/mbs_sel/mbs_*.fits > $TEMP_DIR/scnImageList.dat
mv -f $TEMP_DIR/scnImageList.dat $BASE_DIR/scnImageList.dat


for inFileName in `cat $BASE_DIR/scnImageList.dat`
do
  echo
  echo ===============================
  echo $inFileName
  echo ===============================
  echo

  tmpName=$TEMP_DIR"/scn_"`echo $inFileName |sed 's#/# #g' |awk '{print $NF}'`
  outName=$BASE_DIR"/scn/scn_"`echo $inFileName |sed 's#/# #g' |awk '{print $NF}'`

  echo $tmpName
  echo 
  echo $outName
  echo
  $scnEXE $inFileName -o $tmpName $opts
  mv -f $tmpName $outName

  echo
  echo ===============================
  echo
done

echo
echo Deleting temporary directory: $TEMP_DIR
echo
rm -rf $TEMP_DIR

echo
