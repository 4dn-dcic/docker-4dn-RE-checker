#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.2

requirements:
- class: DockerRequirement
  dockerPull: "4dndcic/4dn-re-checker:v1.3"

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
        name: common_enz
        fields:
          common_enz:
            type: string
            default: AluI
            inputBinding:
              position: 2
              prefix: -e

outputs:
  motif_percent:
    type: stdout
stdout: check-out.txt

baseCommand: ["perl", "REchecker_ChIAPET.pl"]

