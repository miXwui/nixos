#!/bin/bash

# dependencies: pw-cat, wireplumber, zenity

sink_ids=()
sink_descriptions=()
default_sink_index=0
counter=0

while read -r line; do

  id="$(echo "$line" | cut -d '.' -f 1 | cut -d "│" -f 2 | sed 's/^ *//g')"
  sink_description="$(echo "$line" | cut -d '[' -f 1 | cut -d '.' -f 2 | sed 's/^ *//g')"

  if echo "$id" | grep -q '*'; then
    default_sink_index=$counter
    default_id="$(echo "$id" | cut -d "*" -f 2 | sed 's/^ *//g')"
    sink_ids+=("$default_id")
    sink_descriptions+=("$sink_description")
  else
    sink_ids+=("$id")
    sink_descriptions+=("$sink_description")
  fi

  let counter+=1

done < <(wpctl status | grep -ozP '(?s)Sinks:\K.*?(?=Sink)' | xargs --null | grep '\.')

let sink_id_to_set=default_sink_index+1
if (($sink_id_to_set >= ${#sink_ids[@]})); then sink_id_to_set=0; fi

wpctl set-default ${sink_ids[$sink_id_to_set]} &&
  notify-send -h string:desktop-entry:audio -h string:x-dunst-stack-tag:audio "${sink_descriptions[$sink_id_to_set]}" "Set default device"
