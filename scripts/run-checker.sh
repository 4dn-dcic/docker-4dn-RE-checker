#!/bin/sh
BAM_FILE="$1 $2"
MOTIF="$3 $4"

perl $(which 4DN_REcount.pl) ${BAM_FILE} ${MOTIF} 

