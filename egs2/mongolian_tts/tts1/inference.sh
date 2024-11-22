# Using the best validation checkpoint (recommended to start with) 
./run.sh --stage 8 --stop_stage 8 --tts_exp exp/tts_fastspeech2_mn_train --inference_model valid.loss.best.pth --inference_tag inference_valid.loss.best 

# Or using the latest checkpoint 
# ./run.sh --stage 8 --stop_stage 8  --tts_exp exp/tts_fastspeech2_mn_train  --inference_model latest.pth  --inference_tag inference_latest