#!/usr/bin/env bash

# dependencies: grim, swappy, jq

grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') - | swappy -f -