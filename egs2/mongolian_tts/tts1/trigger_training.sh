# After much trial this worked
# The key was --teacher_dumpdir exp/tts_train_tacotron2_raw_char/decode_use_teacher_forcingtrue_train.loss.ave
# Also the updates to the train_fastspeech2_mongolian.yaml config
./run.sh --stage 7 --stop_stage 7 --train_config conf/tuning/train_fastspeech2_mongolian.yaml     --tag fastspeech2_mn_train     --teacher_dumpdir exp/tts_train_tacotron2_raw_char/decode_use_teacher_forcingtrue_train.loss.ave     --ngpu 1