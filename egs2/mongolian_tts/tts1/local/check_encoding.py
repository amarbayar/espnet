import sys

def check_files():
    """Check if text files contain valid Cyrillic Mongolian text."""
    splits = ['train', 'valid', 'test']
    
    for split in splits:
        print(f"\nChecking {split} set:")
        with open(f"data/{split}/text", 'r', encoding='utf-8') as f:
            lines = f.readlines()
            print(f"Total lines: {len(lines)}")
            # Check first and last line
            if lines:
                print("First line sample:", lines[0].strip())
                print("Last line sample:", lines[-1].strip())
                
                # Check if Cyrillic characters are present
                has_cyrillic = any('а' <= c <= 'я' or 'А' <= c <= 'Я' for c in lines[0])
                print(f"Has Cyrillic: {has_cyrillic}")

if __name__ == "__main__":
    check_files()