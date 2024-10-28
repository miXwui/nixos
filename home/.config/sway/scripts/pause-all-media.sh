#!/usr/bin/env bash

# Get a list of all active media players
players=$(playerctl --list-all)

# Check if there are any players
if [ -z "$players" ]; then
    echo "No media players are currently active."
    exit 0
fi

# Loop through each player and send the pause command
for player in $players; do
    playerctl --player="$player" pause
done

echo "Paused all active media players."
