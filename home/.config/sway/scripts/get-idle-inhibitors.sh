#!/usr/bin/env bash

output=$(swaymsg -t get_tree -r | jq -C '..|select(objects) | select(.inhibit_idle == true) | {pid, app_id, inhibit_idle, name}')

if [ -z "$output" ]; then
    echo "Nothing's inhibiting idle."
else
    echo "$output"
fi

