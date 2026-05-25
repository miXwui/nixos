#!/usr/bin/env bash

# dependencies: dunstify, brightnessctl

get_brightness() {
  # Get the brightness in percentage since `brightnessctl get` returns raw values.
  # setting, e.g., 0.1 doesn't turn off the backlight, so we get the ceiling.
  # 0.1 => 1
  current=$(brightnessctl get)
  max=$(brightnessctl max)
  awk -v c="$current" -v m="$max" 'BEGIN{v=c/m*100; print int(v) + ((v>int(v))?1:0) "%"}'
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
    brightnessctl set 1%
  elif [ "$brightness" -ge 1 ] && [ "$brightness" -le 4 ]; then
    brightnessctl set 5%
  else
    brightnessctl set +5%
  fi
  notify_brightness
  ;;
down)
  if [ "$brightness" -ge 2 ] && [ "$brightness" -le 5 ]; then
    brightnessctl set 1%
  elif [ "$brightness" -le 1 ]; then
    brightnessctl set 0%
  else
    brightnessctl set 5%-
  fi
  notify_brightness
  ;;
*)
  echo "Not the right arguments (up/down)"
  echo "$1"
  exit 2
  ;;
esac
