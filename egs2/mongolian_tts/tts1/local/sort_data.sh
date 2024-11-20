#!/bin/bash

for split in train dev test; do
    echo "Sorting files for \${split}..."
    
    # Sort all files
    LC_ALL=C sort -u data/\${split}/text -o data/\${split}/text
    LC_ALL=C sort -u data/\${split}/wav.scp -o data/\${split}/wav.scp
    LC_ALL=C sort -u data/\${split}/utt2spk -o data/\${split}/utt2spk
    
    # Regenerate spk2utt
    utils/utt2spk_to_spk2utt.pl data/\${split}/utt2spk > data/\${split}/spk2utt
    
    # Use custom validation
    ./local/validate_tts_data.sh data/\${split}
done