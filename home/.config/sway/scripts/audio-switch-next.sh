#!/usr/bin/env bash

# dependencies: pw-cat, wireplumber, zenity

sink_ids=()
sink_descriptions=()
default_sink_index=0
counter=0

while read -r line; do

  id="$(echo "$line" | cut -d '.' -f 1 | sed 's/^│//' | awk '{$1=$1};1')"
  sink_description="$(echo "$line" | cut -d '[' -f 1 | cut -d '.' -f 2 | sed 's/^ *//g')"

  if echo "$id" | grep -q '\*'; then
    default_sink_index=$counter
    default_id="$(echo "$id" | cut -d "*" -f 2 | sed 's/^ *//g')"
    sink_ids+=("$default_id")
    sink_descriptions+=("$sink_description")
  else
    sink_ids+=("$id")
    sink_descriptions+=("$sink_description")
  fi

  ((counter += 1))

  # Example of grep result fed to the while loop:
  # ```text
  #  │  *   55. DELL U3421WE                        [vol: 0.40]
  #  │      56. ALC295 Analog                       [vol: 0.35]
  #  │      59. USB Audio CODEC                     [vol: 0.10]
  #  │      86. JBL Flip 5                          [vol: 0.22]
  # ```
done < <(wpctl status --nick | grep -ozP '(?s)Sinks:\K.*?(?=Sources:)' | xargs --null | grep '\.')

((sink_id_to_set = default_sink_index + 1))
if ((sink_id_to_set >= ${#sink_ids[@]})); then sink_id_to_set=0; fi

wpctl set-default "${sink_ids[$sink_id_to_set]}" &&
  notify-send -h string:desktop-entry:audio -h string:x-dunst-stack-tag:audio "Set default sink" "${sink_descriptions[$sink_id_to_set]}"
