#!/usr/bin/env bash

# dependencies: dunst, (swaylock | gtklock | hyprlock)

# Pause notifications and run lock command. Lock command should not be
# daemonized, e.g. `swaylock`. Notifications resume upon unlock.
# https://github.com/swaywm/swaylock/issues/129#issuecomment-578901095
(dunstctl set-paused true && @LOCK_COMMAND@ && dunstctl set-paused false) &
# @LOCK_COMMAND@
