#!/usr/bin/env bash

# dependencies: dunst, (swaylock | gtklock | hyprlock)

dunstctl set-paused true && @LOCK_COMMAND@ && dunstctl set-paused false
