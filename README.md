# docker-4dn-RE-checker

_The current version of this pipeline pulls the Docker image from a public AWS Elastic Container Registry. If you prefer to pull from Docker Hub (DH), please use the tagged version utilizing DH: `v1.2_DH`._

This repo contains the source files for a docker image stored in both `4dndcic/4dn-re-checker:v1.2` and AWS `public.ecr.aws/dcic-4dn/4dn-re-checker:v1.2`.

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
