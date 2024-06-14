#!/usr/bin/env bash

# dependencies: dunstify, grim, slurp, swappy

dunstify "Sectional Screenshot" && grim -g "$(slurp)" - | swappy -f -

# Can use inotify save to monitor for file saves
# https://github.com/jtheoof/swappy/issues/58#issuecomment-785804847
# set -e

# while true; do
#     inotifywait -q -e create /tmp/screenshots/
#     notify-send "Screenshot saved"
# done
