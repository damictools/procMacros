#/bin/bash
BASEDIR=$1

echo $BASEDIR

EXTRACTEXE=$DAMIC_SOFT_ROOT/extract/extract.exe
EXTRACTCONFIG=`pwd`/extractConfigFS.xml

TS=`date +%s`

[ "X$SCRATCH" = "X" ] && SCRATCH=/tmp/damic/
if [ -d "/scratch/damic/" ]
then 
  SCRATCH=/scratch/damic/
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

$EXTRACTEXE `ls $BASEDIR/scn/scn_*.fits*` -o $TEMP_DIR/catalog.root -m $BASEDIR/"mask6_sel_R.fits" -c $EXTRACTCONFIG

mv -f $TEMP_DIR/catalog.root $BASEDIR

echo
echo Deleting temporary directory: $TEMP_DIR
echo
rm -rf $TEMP_DIR

echo
