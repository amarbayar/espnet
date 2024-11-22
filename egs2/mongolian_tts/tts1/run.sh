#!/usr/bin/env bash

# Set bash to 'debug' mode
set -e
set -u
set -o pipefail

# Basic settings
fs=24000
n_fft=2048
n_shift=300
win_length=1200

# Stage and Stop stage
stage=0
stop_stage=100

skip_data_prep=false
skip_train=false
skip_eval=false

# GPU settings
ngpu=1  # number of gpus ("0" uses cpu, otherwise use gpu)
nj=32   # number of parallel jobs
dumpdir=dump # directory to dump features

train_set="train"
valid_set="valid"
test_sets="test"

train_config=conf/tuning/train_tacotron2_mongolian.yaml
inference_config=conf/decode.yaml

# Token settings
token_type=char
cleaner=none
g2p=none

# Parse command line arguments
. utils/parse_options.sh || exit 1

# Define opts after parsing arguments
opts="--audio_format wav"

# First, prepare MB-only data
if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ] && [ "${skip_data_prep}" = false ]; then
    echo "Stage 0: Preparing MB speaker data"
    python local/data_prep.py
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    echo "Stage 2: Format wav.scp and create dump directories"
    # Make sure dump directory exists
    mkdir -p ${dumpdir}/raw/org/${train_set}
    mkdir -p ${dumpdir}/raw/org/${valid_set}
    mkdir -p ${dumpdir}/raw/org/${test_sets}
    
    # Copy data files
    for x in ${train_set} ${valid_set} ${test_sets}; do
        cp data/${x}/wav.scp ${dumpdir}/raw/org/${x}/
        cp data/${x}/text ${dumpdir}/raw/org/${x}/
        cp data/${x}/utt2spk ${dumpdir}/raw/org/${x}/
        cp data/${x}/spk2utt ${dumpdir}/raw/org/${x}/
    done
fi

# Call the main TTS training script
./tts.sh \
    --lang mn \
    --feats_type raw \
    --fs "${fs}" \
    --n_fft "${n_fft}" \
    --n_shift "${n_shift}" \
    --win_length "${win_length}" \
    --token_type "${token_type}" \
    --cleaner "${cleaner}" \
    --g2p "${g2p}" \
    --train_config "${train_config}" \
    --inference_config "${inference_config}" \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_sets}" \
    --srctexts "data/${train_set}/text" \
    --min_wav_duration 0.1 \
    --max_wav_duration 15.0 \
    --ngpu "${ngpu}" \
    --nj "${nj}" \
    --dumpdir "${dumpdir}" \
    --stage "${stage}" \
    --stop_stage "${stop_stage}" \
    --skip_train "${skip_train}" \
    ${opts} "$@"