#!/usr/bin/env bash

# adapted from https://github.com/swaywm/sway/issues/4558#issuecomment-535863610

current_window_pid=$(swaymsg -t get_tree | grep -A 45 '"focused": true' | egrep 'pid' | cut -d \: -f 2 | sed 's/[^0-9]*//g')

kill -9 $current_window_pid
