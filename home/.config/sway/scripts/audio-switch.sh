#!/usr/bin/env bash

# dependencies: wireplumber, zenity

lines=()

while read -r line; do
  substr1="$(echo "$line" | cut -d '[' -f 1)"
  substr2="[$(echo "$line" | cut -d '[' -f 2)"

  # # shellcheck disable=SC2001
  # id=$(echo "${substr1:4:5}" | sed 's/^[[:space:]]*//') # POSIX compatible
  temp_id="${substr1:4:5}"
  id=${temp_id//[[:blank:]]/}

  # # shellcheck disable=SC2001
  # default=$(echo "${substr1:3:3}" | sed 's/^[[:space:]]*//' # POSIX compatible)
  tmp_default="${substr1:3:3}"
  default=${tmp_default//[[:blank:]]/}

  # # shellcheck disable=SC2001
  # device=$(echo "${substr1:11}" | sed 's/^[[:space:]]*//') # POSIX compatible
  tmp_device="${substr1:11}"
  device=${tmp_device//[[:blank:]]/}

  # # shellcheck disable=SC2001
  # volume=$(echo "${substr2}" | sed 's/^[[:space:]]*//') # POSIX compatible
  tmp_volume="${substr2}"
  volume=${tmp_volume//[[:blank:]]/}

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

wpctl set-default "$device"
