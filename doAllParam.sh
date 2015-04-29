#!/bin/bash

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

RAW_DATA_DIR=$1
OUT_BASE_DIR=$2
CONFIG_FILE=$3

./computeOSI.sh $RAW_DATA_DIR $OUT_BASE_DIR $CONFIG_FILE
./computeMB.sh $OUT_BASE_DIR
./computeMBS.sh $OUT_BASE_DIR
./subtractCorrNoise.sh $OUT_BASE_DIR
./prepareMask.sh $OUT_BASE_DIR
./extractFixedSigma.sh $OUT_BASE_DIR

echo
echo All done!
echo
