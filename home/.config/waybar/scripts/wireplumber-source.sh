#!/usr/bin/env bash

get_volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
class=""
volume=""
if [[ $get_volume = *"MUTED"* ]]; then
  # `Volume: 1.00 [MUTED]`
  class="muted"
  volume=$(echo "scale = 0; ($(echo $get_volume | tr -d 'Volume: ' | tr -d '[MUTED]' | tr -d '[:space:]') * 100) / 1" | bc -l)
else
  # `Volume: 1.00`
  class="unmuted"
  volume=$(echo "scale = 0; ($(echo $get_volume | tr -d 'Volume: ' | tr -d '[:space:]') * 100) / 1" | bc -l)
fi
source_description=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ | grep "* node.nick" | grep -o '"[^"]\+"' | sed 's/"//g')

jq -c -r --null-input \
  --arg volume "$volume" \
  --arg source_description "$source_description" \
  --arg class "$class" \
  '{"text": $volume, "alt": $class, "tooltip": $source_description, "class": $class}'
