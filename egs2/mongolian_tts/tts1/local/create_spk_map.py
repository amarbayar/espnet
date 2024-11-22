import os
import csv
from pathlib import Path

def create_simplified_speaker_mapping(metadata_file):
    """Create simplified speaker mapping with MB and CommonVoice sources."""
    mb_count = 0
    cv_count = 0
    
    # Create basic mapping
    spk2id = {
        'mb_speaker': 0,
        'cv_speaker': 1
    }
    
    with open(metadata_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            file_id = row[0]
            if file_id.startswith('MB'):
                mb_count += 1
            else:
                cv_count += 1
    
    # Save mapping
    os.makedirs('data', exist_ok=True)
    with open('data/spk2id', 'w', encoding='utf-8') as f:
        for spk, idx in spk2id.items():
            f.write(f'{spk}\t{idx}\n')
    
    print(f"Statistics:")
    print(f"MB Speaker utterances: {mb_count}")
    print(f"CommonVoice utterances: {cv_count}")
    print(f"Total utterances: {mb_count + cv_count}")
    
    return spk2id, mb_count, cv_count

if __name__ == "__main__":
    spk2id, mb_count, cv_count = create_simplified_speaker_mapping("downloads/mongolian_tts/metadata.csv")
    print("\nSpeaker mapping:")
    for spk, idx in spk2id.items():
        print(f"{spk}: {idx}")