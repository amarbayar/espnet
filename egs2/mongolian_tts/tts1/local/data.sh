#!/bin/bash

# Set bash to 'debug' mode
set -e
set -u
set -o pipefail
set -x  # Debug output

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') ($fname:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

SECONDS=0

log "Data preparation started..."

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

# Path to your Mongolian dataset
db_root=downloads/mongolian_tts
log "Checking db_root: ${db_root}"

# Check if data exists
[ ! -d "${db_root}" ] && log "ERROR: '${db_root}' doesn't exist." && exit 1;
[ ! -f "${db_root}/metadata.csv" ] && log "ERROR: Metadata file doesn't exist." && exit 1;
[ ! -d "${db_root}/wavs" ] && log "ERROR: Wavs directory doesn't exist." && exit 1;

# Create data directories
mkdir -p data
log "Created data directories"

# Run the new Python script for data preparation
python3 data_prep.py "${db_root}"

# Process each split: train, valid, test
for split in train valid test; do
    log "Processing ${split} set..."
    
    if [ -f data/${split}/utt2spk ]; then
        # Create spk2utt from utt2spk
        utils/utt2spk_to_spk2utt.pl data/${split}/utt2spk > data/${split}/spk2utt
        log "Created spk2utt for ${split}"

        # Fix and validate data directory
        utils/fix_data_dir.sh data/${split}
        utils/validate_data_dir.sh --non-print --no-feats data/${split} 
        log "Validated ${split} directory"
    else
        log "ERROR: utt2spk file not created for ${split}"
        exit 1
    fi
done

log "Successfully finished. [elapsed=${SECONDS}s]"
