#!/usr/bin/env bash

# dependencies: dunstify, wf-recorder, slurp

if killall -s SIGINT wf-recorder; then
  dunstify "SUCCESSFULLY KILLED GIF RECORDER WHEW WHEW WHEW"
else
  dunstify "Recording gif WHEEEEEEEeeee" && wf-recorder -g "$(slurp)" -f ~/Videos/recording_$(date +"%Y-%m-%d_%H:%M:%S.gif") -c gif && dunstify "Dun dun dun stopped recording the gifs11!!"
fi
