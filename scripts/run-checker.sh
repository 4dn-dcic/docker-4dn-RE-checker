#!/bin/sh
BAM_FILE="$1 $2"
MOTIF="$3 $4"
QUAL="$5 $6"
MIN_PATH="$7 $8"

perl $(which 4DN_REcount.pl) ${BAM_FILE} ${MOTIF} ${QUAL} ${MIN_PATH}
