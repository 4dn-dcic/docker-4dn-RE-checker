# docker-4dn-RE-checker

## Building docker image
```
docker build -t 4dndcic/4dn-re-checker:v1.2 .
docker push 4dndcic/4dn-re-checker:v1.2
```
## Tool wrappers
Tool wrappers are located in the `scripts` directory and given names of the format `run-[*].sh`. These wrappers are copied to the docker image at build time.

### run-checker.sh
Runs 4DN-REcount.pl. Used by RE-checker.cwl

### Usage
```
run-checker.sh -bam <bam_file> <optional_flags>
```
