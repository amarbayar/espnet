#!/bin/bash

set -e
set -u
set -o pipefail

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

train_set="train"
dev_set="dev"
test_set="test"
fs=24000  # Your sampling rate

# Default values for data directory and metadata file
db_root=${1:-downloads/mongolian_tts}
metadata_file=${db_root}/metadata.csv
audio_dir=${db_root}/wavs

# Check if metadata file exists
[ ! -f "${metadata_file}" ] && echo "Cannot find metadata.csv at ${metadata_file}" && exit 1;
[ ! -d "${audio_dir}" ] && echo "Cannot find wavs directory at ${audio_dir}" && exit 1;

# Create data directories
mkdir -p data/{train,dev,test}

# Calculate number of utterances for each set
total_lines=$(wc -l < "${metadata_file}")
n_train=$(( total_lines * 80 / 100 ))  # 80% for training
n_dev=$(( total_lines * 10 / 100 ))    # 10% for development
n_test=$(( total_lines - n_train - n_dev ))
echo "Train: ${n_train}, Dev: ${n_dev}, Test: ${n_test}"

# Perform splits
head -n ${n_train} "${metadata_file}" > data/${train_set}/metadata.txt
tail -n +$(( n_train + 1 )) "${metadata_file}" | head -n ${n_dev} > data/${dev_set}/metadata.txt
tail -n +$(( n_train + n_dev + 1 )) "${metadata_file}" > data/${test_set}/metadata.txt

# Verify splits
echo "Train file: $(wc -l < data/${train_set}/metadata.txt) lines"
echo "Dev file: $(wc -l < data/${dev_set}/metadata.txt) lines"
echo "Test file: $(wc -l < data/${test_set}/metadata.txt) lines"
echo "test"
# Function to process each split
process_split() {
    local set=$1
    echo "Processing ${set} set..."
    local data_dir=data/${set}
    mkdir -p ${data_dir}

    # Create required files
    > ${data_dir}/wav.scp
    > ${data_dir}/text
    > ${data_dir}/utt2spk

    # Process metadata
    while IFS='|' read -r file_id text; do
        # Clean up file_id and text
        file_id=$(echo "${file_id}" | tr -d ' ')
        text=$(echo "${text}" | tr -d '"' | sed -e 's/^ *//' -e 's/ *$//')

        # Create utterance ID
        utt_id="mn_${file_id}"

        # Check if audio file exists
        wav_file="${audio_dir}/${file_id}.wav"
        if [ ! -f "${wav_file}" ]; then
            echo "Warning: audio file ${wav_file} doesn't exist"
            continue
        fi

        # Add to wav.scp
        echo "${utt_id} ${wav_file}" >> ${data_dir}/wav.scp

        # Add to text
        echo "${utt_id} ${text}" >> ${data_dir}/text

        # Add to utt2spk (treating all as single speaker for now)
        echo "${utt_id} mn_speaker1" >> ${data_dir}/utt2spk
    done < ${data_dir}/metadata.txt

    # Generate spk2utt
    utils/utt2spk_to_spk2utt.pl ${data_dir}/utt2spk > ${data_dir}/spk2utt

    # Check data directory
    utils/fix_data_dir.sh ${data_dir}
    utils/validate_data_dir.sh --no-feats ${data_dir}
}

# Process each data split
for subset in ${train_set} ${dev_set} ${test_set}; do
    process_split ${subset}
done

echo "Data preparation completed!"
