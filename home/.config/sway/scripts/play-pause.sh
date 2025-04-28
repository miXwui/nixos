#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null)

if [[ "$status" == "Playing" ]]; then
  # ISSUE:
  # Only will pause the most recently played Firefox tab
  # https://github.com/altdesktop/playerctl/issues/253
  playerctl -a pause
elif [[ "$status" == "Paused" ]]; then
  # Only play the last played player
  # https://github.com/altdesktop/playerctl/issues/161#issue-548463643
  playerctl --player playerctld play
fi
