#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0

requirements:
- class: DockerRequirement
  dockerPull: "4dndcic/4dn-re-checker:v1.1"

- class: "InlineJavascriptRequirement"

inputs:
  bamfile:
    type: File
    inputBinding:
      prefix: -bam
      position: 1

  motif:
    type:
      - type: record
        name: regex
        fields:
          regex:
            type: string
            inputBinding:
              position: 2
              prefix: -m

      - type: record
        name: common_enz
        fields:
          common_enz:
            type: string
            inputBinding:
              position: 2
              prefix: -e

  wobble:
    type: string?
    inputBinding:
      position: 3
      prefix: -w
    default: T

  map_qual:
    type: string?
    inputBinding:
      position: 4
      prefix: -q

  min_length:
    type: string?
    inputBinding:
      position: 5
      prefix: -c

outputs:
  motif_percent:
    type: stdout
stdout: check-out.txt

baseCommand: "run-checker.sh"

