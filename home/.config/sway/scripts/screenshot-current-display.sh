#!/bin/bash

# dependencies: grim, swappy, jq

grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') - | swappy -f -