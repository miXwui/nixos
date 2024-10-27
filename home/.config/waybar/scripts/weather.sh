#!/usr/bin/env bash

IFS=":" read -ra split_response <<<"$(curl -s "https://v2.wttr.in/?format=3")"

location=${split_response[0]}
weather=$(echo "${split_response[1]}" | cut -c 2- | sed 's/  */ /g')

jq -c -r --null-input \
  --arg location "$location" \
  --arg weather "$weather" \
  '{"text": $weather, "tooltip": $location}'
