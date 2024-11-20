#!/usr/bin/env bash

# Set bash to 'debug' mode, it will exit on:
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

# Basic settings
fs=24000
n_fft=2048
n_shift=300
win_length=1200

opts="--audio_format wav "

train_set="train"
valid_set="dev"
test_sets="test"

train_config=conf/tuning/train_fastspeech2_mongolian.yaml
inference_config=conf/decode.yaml

# Use char as the token type since we're working with Mongolian Cyrillic
token_type=char
cleaner=none
g2p=none

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
    ${opts} "$@"