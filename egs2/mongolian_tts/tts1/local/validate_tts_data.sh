#!/bin/bash

if [ \$# -ne 1 ]; then
  echo "Usage: \$0 <data-dir>"
  exit 1
fi

data=\$1

# Check required files exist
for f in wav.scp text utt2spk; do
  if [ ! -f \$data/\$f ]; then
    echo "validate_tts_data.sh: no such file \$f"
    exit 1;
  fi
done

# Check file sizes
n_wav=\$(wc -l < \$data/wav.scp)
n_text=\$(wc -l < \$data/text)
n_utt2spk=\$(wc -l < \$data/utt2spk)

if [ \$n_wav -ne \$n_text ] || [ \$n_wav -ne \$n_utt2spk ]; then
    echo "Inconsistent number of lines:"
    echo "wav.scp: \$n_wav"
    echo "text: \$n_text"
    echo "utt2spk: \$n_utt2spk"
    exit 1
fi

echo "Data validation completed successfully for \$data (\$n_wav utterances)"