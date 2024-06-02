#!/bin/bash

# dependencies: wireplumber, zenity

lines=()

while read -r line; do
  substr1="$(echo "$line" | cut -d '[' -f 1)"
  substr2="[$(echo "$line" | cut -d '[' -f 2)"
  
  id=$(echo "${substr1:4:5}" | sed 's/^[[:space:]]*//')
  default=$(echo "${substr1:3:3}" | sed 's/^[[:space:]]*//')
  device=$(echo "${substr1:11}" | sed 's/^[[:space:]]*//')
  volume=$(echo "${substr2}" | sed 's/^[[:space:]]*//')

  lines+=("$id" "$default" "$device" "$volume")
done < <(wpctl status | grep 'vol')

# set -x
device=$(
  zenity --list --title="Audio Picker" --text="Set default audio device" \
    --column="ID" \
    --column="Default" \
    --column="Device" \
    --column="Volume" \
    "${lines[@]}"
)
# set +x

wpctl set-default $device
