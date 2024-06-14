#!/usr/bin/env bash

# dependencies: pw-cat, wireplumber, zenity

source_ids=()
source_descriptions=()
default_source_index=0
counter=0

while read -r line; do

  id="$(echo "$line" | cut -d '.' -f 1 | sed 's/^│//' | awk '{$1=$1};1')"
  source_description="$(echo "$line" | cut -d '[' -f 1 | cut -d '.' -f 2 | sed 's/^ *//g')"

  if echo "$id" | grep -q '*'; then
    default_source_index=$counter
    default_id="$(echo "$id" | cut -d "*" -f 2 | sed 's/^ *//g')"
    source_ids+=("$default_id")
    source_descriptions+=("$source_description")
  else
    source_ids+=("$id")
    source_descriptions+=("$source_description")
  fi

  let counter+=1

  # Example of grep result fed to the while loop:
  # ```text
  #  │  *   57. ALC295 Analog                       [vol: 1.00 MUTED]
  #  │      58. USB Audio CODEC                     [vol: 1.00]
  # ```
done < <(wpctl status --nick | grep -ozP '(?s)Sources:\K.*?(?=Filters:)' | xargs --null | grep '\.')

let source_id_to_set=default_source_index+1
if (($source_id_to_set >= ${#source_ids[@]})); then source_id_to_set=0; fi

wpctl set-default ${source_ids[$source_id_to_set]} &&
  notify-send -h string:desktop-entry:audio -h string:x-dunst-stack-tag:audio "Set default source" "${source_descriptions[$source_id_to_set]}"
