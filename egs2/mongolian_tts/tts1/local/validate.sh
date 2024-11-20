#!/bin/bash

# Define log function
log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') ($fname:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

validate_data_prep() {
    local data_dir=$1

    # Check data directories
    if [ ! -d "${data_dir}/train" ] || [ ! -d "${data_dir}/dev" ] || [ ! -d "${data_dir}/test" ]; then
        log "ERROR: Data directories not created."
        return 1
    fi

    # Check metadata files
    for split in train dev test; do
        metadata_file="${data_dir}/${split}/metadata.txt"
        if [ ! -f "${metadata_file}" ]; then
            log "ERROR: ${metadata_file} not found."
            return 1
        fi
    done

    # Check wav.scp, text and utt2spk files
    for split in train dev test; do
        for file in wav.scp text utt2spk spk2utt; do
            file_path="${data_dir}/${split}/${file}"
            if [ ! -f "${file_path}" ]; then
                log "ERROR: ${file_path} not found."
                return 1
            fi
        done
    done

    log "Data preparation validated successfully."
}

# Call validation function
log "Starting validation..."
validate_data_prep data
log "Validation completed."