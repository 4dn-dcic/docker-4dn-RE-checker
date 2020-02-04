#!/bin/sh
BAM_FILE="$1 $2"
MOTIF="$3 $4"
WOBBLE="$5 $6"
QUAL="$7 $8"
MIN_PATH="$9 ${10}"

perl $(which 4DN_REcount.pl) ${BAM_FILE} ${MOTIF} ${QUAL} ${MIN_PATH} ${WOBBLE}
