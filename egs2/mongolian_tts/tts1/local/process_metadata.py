import sys
import codecs
import os

def process_split(split):
    input_file = f'data/{split}/metadata.txt'
    wav_scp = f'data/{split}/wav.scp'
    text_file = f'data/{split}/text'
    utt2spk = f'data/{split}/utt2spk'
    db_root = 'downloads/mongolian_tts'

    print(f"Processing {split} set...")
    print(f"Input file: {input_file}")
    print(f"Reading from: {os.path.abspath(input_file)}")

    # Ensure the output files exist
    open(wav_scp, 'a').close()
    open(text_file, 'a').close()
    open(utt2spk, 'a').close()

    try:
        with codecs.open(input_file, 'r', 'utf-8') as f:
            for line in f:
                if not line.strip():
                    continue
                try:
                    file_id, text = line.strip().split('|', 1)
                    file_id = file_id.strip()
                    text = text.strip()
                    utt_id = f"mn_{file_id}"

                    # Check if audio file exists
                    wav_file = f"{db_root}/wavs/{file_id}.wav"
                    if not os.path.exists(wav_file):
                        print(f"Warning: audio file {wav_file} doesn't exist")
                        continue

                    # Write to wav.scp
                    with open(wav_scp, 'a', encoding='utf-8') as wav_f:
                        wav_f.write(f"{utt_id} {wav_file}\n")
                        print(f"Writing to wav.scp: {utt_id} {wav_file}")

                    # Write to text
                    with open(text_file, 'a', encoding='utf-8') as text_f:
                        text_f.write(f"{utt_id} {text}\n")
                        print(f"Writing to text: {utt_id} {text}")

                    # Write to utt2spk
                    with open(utt2spk, 'a', encoding='utf-8') as spk_f:
                        spk_f.write(f"{utt_id} mn_speaker1\n")
                        print(f"Writing to utt2spk: {utt_id} mn_speaker1")

                except Exception as e:
                    print(f"Error processing line: {line.strip()}")
                    print(f"Error: {str(e)}")
    except Exception as e:
        print(f"Error opening input file: {input_file}")
        print(f"Error: {str(e)}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python process_metadata.py <split>")
        sys.exit(1)

    split = sys.argv[1]
    process_split(split)
