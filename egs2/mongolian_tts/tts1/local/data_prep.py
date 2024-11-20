import os
import sys
import csv
from pathlib import Path

def split_metadata(metadata_file, train_file, dev_file, test_file, train_ratio=0.8, dev_ratio=0.1):
    """Splits metadata into train, dev, and test sets."""
    with open(metadata_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    total_lines = len(lines)
    n_train = int(total_lines * train_ratio)
    n_dev = int(total_lines * dev_ratio)
    n_test = total_lines - n_train - n_dev
    
    print(f"Total lines: {total_lines}")
    print(f"Train: {n_train}, Dev: {n_dev}, Test: {n_test}")

    # Write splits
    with open(train_file, "w", encoding="utf-8") as train_f:
        train_f.writelines(lines[:n_train])
    
    with open(dev_file, "w", encoding="utf-8") as dev_f:
        dev_f.writelines(lines[n_train:n_train + n_dev])
    
    with open(test_file, "w", encoding="utf-8") as test_f:
        test_f.writelines(lines[n_train + n_dev:])
    
    print(f"Train file: {len(lines[:n_train])} lines")
    print(f"Dev file: {len(lines[n_train:n_train + n_dev])} lines")
    print(f"Test file: {len(lines[n_train + n_dev:])} lines")


def process_split(set_name, metadata_file, audio_dir, output_dir):
    """Processes metadata split into wav.scp, text, and utt2spk."""
    print(f"Processing {set_name} set...")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    wav_scp = output_dir / "wav.scp"
    text = output_dir / "text"
    utt2spk = output_dir / "utt2spk"

    # Open output files
    with wav_scp.open("w", encoding="utf-8") as wav_f, \
         text.open("w", encoding="utf-8") as text_f, \
         utt2spk.open("w", encoding="utf-8") as utt2spk_f:
        
        with open(metadata_file, "r", encoding="utf-8") as f:
            reader = csv.reader(f, delimiter="|")
            for file_id, transcript in reader:
                file_id = file_id.strip()
                transcript = transcript.strip().strip('"')
                utt_id = f"mn_{file_id}"
                wav_file = audio_dir / f"{file_id}.wav"
                
                if not wav_file.exists():
                    print(f"Warning: audio file {wav_file} doesn't exist")
                    continue

                # Write to wav.scp, text, and utt2spk
                wav_f.write(f"{utt_id} {wav_file}\n")
                text_f.write(f"{utt_id} {transcript}\n")
                utt2spk_f.write(f"{utt_id} mn_speaker1\n")
    
    # Generate spk2utt
    spk2utt = output_dir / "spk2utt"
    spk2utt_content = {}
    with utt2spk.open("r", encoding="utf-8") as utt2spk_f:
        for line in utt2spk_f:
            utt_id, spk_id = line.strip().split()
            spk2utt_content.setdefault(spk_id, []).append(utt_id)
    
    with spk2utt.open("w", encoding="utf-8") as spk2utt_f:
        for spk_id, utt_ids in spk2utt_content.items():
            spk2utt_f.write(f"{spk_id} {' '.join(utt_ids)}\n")
    
    print(f"Finished processing {set_name} set!")


def main(db_root="downloads/mongolian_tts"):
    metadata_file = Path(db_root) / "metadata.csv"
    audio_dir = Path(db_root) / "wavs"

    if not metadata_file.exists():
        print(f"Cannot find metadata.csv at {metadata_file}")
        sys.exit(1)
    
    if not audio_dir.exists():
        print(f"Cannot find wavs directory at {audio_dir}")
        sys.exit(1)
    
    data_dir = Path("data")
    train_dir = data_dir / "train"
    dev_dir = data_dir / "dev"
    test_dir = data_dir / "test"

    train_metadata = train_dir / "metadata.txt"
    dev_metadata = dev_dir / "metadata.txt"
    test_metadata = test_dir / "metadata.txt"

    data_dir.mkdir(parents=True, exist_ok=True)

    # Split metadata
    split_metadata(metadata_file, train_metadata, dev_metadata, test_metadata)

    # Process splits
    for set_name, metadata_path, output_dir in [
        ("train", train_metadata, train_dir),
        ("dev", dev_metadata, dev_dir),
        ("test", test_metadata, test_dir),
    ]:
        process_split(set_name, metadata_path, audio_dir, output_dir)
    
    print("Data preparation completed!")


if __name__ == "__main__":
    main()
