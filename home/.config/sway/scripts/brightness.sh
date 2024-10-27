#!/usr/bin/env bash

# dependencies: dunstify, light

get_brightness() {
  # light returns a float, so we round up to an integer using ceiling, \
  # since light -S 0.1 doesn't turn off the backlight. 0.1 => 1.
  # https://bits.mdminhazulhaque.io/linux/round-number-in-bash-script.html
  light -G | awk '{print ($0-int($0)>0)?int($0)+1:int($0)}'
}

notify_brightness() {
  brightness=$(get_brightness)
  # if [ "$brightness" -eq 0 ]; then
  #   icon_name=display-brightness-off-symbolic
  # elif [ "$brightness" -le 30 ]; then
  #   icon_name=display-brightness-low-symbolic
  # elif [ "$brightness" -le 70 ]; then
  #   icon_name=display-brightness-medium-symbolic
  # else
  #   icon_name=display-brightness-high-symbolic
  # fi
  # Send the notification
  # dunstify -h string:x-dunst-stack-tag:brightness "Brightness: $brightness%" -h int:value:"$brightness" -h string:desktop-entry:brightness -t 1500 --icon "$icon_name"
  dunstify -h string:x-dunst-stack-tag:brightness "Brightness: $brightness%" -h int:value:"$brightness" -h string:desktop-entry:brightness -t 1500
}

brightness=$(get_brightness)
case "$1" in
up)
  if [ "$brightness" -le 0 ]; then
    light -S 1
  elif [ "$brightness" -ge 1 ] && [ "$brightness" -le 4 ]; then
    light -S 5
  else
    light -A 5
  fi
  notify_brightness
  ;;
down)
  if [ "$brightness" -ge 2 ] && [ "$brightness" -le 5 ]; then
    light -S 1
  elif [ "$brightness" -le 1 ]; then
    light -S 0
  else
    light -U 5
  fi
  notify_brightness
  ;;
*)
  echo "Not the right arguments (up/down)"
  echo "$1"
  exit 2
  ;;
esac
