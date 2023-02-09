#!/usr/bin/env zsh

set -e

SCRIPT_NAME=$(basename "$0")
if [ "$#" -lt 3 ]; then
  echo "Usage: ${SCRIPT_NAME} <msi_path> <build_version> <release_type>"
  exit 1
fi

MSIPATH=$1
#Fully Qualified Build Version Number. E.g. 1.0.1+5678
FQBVN=$2
#Release Type
RELTYPE=$3

case $RELTYPE in
  (latest|stable) ;;
  (*) echo "Invalid RELTYPE. Valid RELTYPE: latest|stable"; exit 1;;
esac

mkdir -p syncdir
gsutil -m cp ${MSIPATH}/*.msi  gs://winrepo/${RELTYPE}/${FQBVN}/
gsutil -m -o "GSUtil:parallel_process_count=1" rsync -r -i gs://winrepo syncdir
python3 .github/workflows/genlisting.py syncdir -r
gsutil -m -o "GSUtil:parallel_process_count=1" rsync -r syncdir gs://winrepo
