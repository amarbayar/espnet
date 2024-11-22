import os
import csv
import random
import unicodedata
from pathlib import Path
import subprocess

def normalize_text(text):
    """Normalize text to ensure consistency and pass validation."""
    return unicodedata.normalize("NFC", text)

def prepare_mb_data(metadata_file, out_dir, train_ratio=0.9, valid_ratio=0.05):
    """Prepare data using only MB speaker utterances."""
    os.makedirs(out_dir, exist_ok=True)
    
    # Collect MB utterances
    mb_data = []
    with open(metadata_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            if row[0].startswith('MB'):
                # Normalize the text to handle Cyrillic properly
                utt_id, text = row[0], normalize_text(row[1])
                mb_data.append((utt_id, text))
    
    # Shuffle data
    random.seed(42)  # for reproducibility
    random.shuffle(mb_data)
    
    # Split data
    total = len(mb_data)
    n_train = int(total * train_ratio)
    n_valid = int(total * valid_ratio)
    
    train_data = mb_data[:n_train]
    valid_data = mb_data[n_train:n_train + n_valid]
    test_data = mb_data[n_train + n_valid:]
    
    # Write splits
    splits = {
        'train': train_data,
        'valid': valid_data,
        'test': test_data
    }
    
    for split_name, split_data in splits.items():
        split_dir = Path(out_dir) / split_name
        os.makedirs(split_dir, exist_ok=True)
        
        # Sort the split data by utt_id
        split_data = sorted(split_data, key=lambda x: f"mb_{x[0]}")
        
        # Create wav.scp, text, and utt2spk
        with open(split_dir / 'wav.scp', 'w', encoding='utf-8') as wav_f, \
             open(split_dir / 'text', 'w', encoding='utf-8') as text_f, \
             open(split_dir / 'utt2spk', 'w', encoding='utf-8') as utt2spk_f:
            
            for uttid, text in split_data:
                # Create unique utterance ID
                utt_id = f"mb_{uttid}"
                wav_path = f"downloads/mongolian_tts/wavs/{uttid}.wav"
                
                if not os.path.exists(wav_path):
                    print(f"Warning: audio file {wav_path} doesn't exist")
                    continue
                    
                wav_f.write(f"{utt_id} {wav_path}\n")
                text_f.write(f"{utt_id} {text}\n")
                utt2spk_f.write(f"{utt_id} mb_speaker\n")
        
        # Generate spk2utt and ensure it's sorted
        subprocess.run(
            f"utils/utt2spk_to_spk2utt.pl {split_dir}/utt2spk | sort > {split_dir}/spk2utt",
            shell=True, check=True
        )
    
    print(f"\nData split statistics:")
    print(f"Train set: {len(train_data)} utterances")
    print(f"Valid set: {len(valid_data)} utterances")
    print(f"Test set: {len(test_data)} utterances")

if __name__ == "__main__":
    prepare_mb_data("downloads/mongolian_tts/metadata.csv", "data")
