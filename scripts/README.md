# run-checker.sh
Runs 4DN-REcount.pl. Used by RE-checker.cwl

## Usage
```
run-checker.sh -bam <bam_file> <additional_flags>
```
Either the `-m` or the `-e` flag must be used. All other flags are optional.

### Additional Flags
`-m` `string`    Restriction enzyme motif (e.g. "AGCT|TCGA") \
`-e` `string`    Commonly used RE motif: [AluI, NotI, MboI, DpnII, HindIII, NcoI, MboI+HinfI] \
`-w` `boolean`   Allows matching of RE motif within a short range of the clip position (default: T) \
`-q` `integer`   Minimum mapping quality for the reference alignment (default: 0) \
`-c` `integer`   Minimum softclipped read length for mapping the reads to the TE assembly (default: 5)
