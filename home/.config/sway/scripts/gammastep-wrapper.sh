#!/usr/bin/env bash

# From and thanks:
# https://rumpelsepp.org/blog/geolocation-for-gammastep/

# Called from ~/.config/systemd/user/gammastep.service

# dependencies: jq

set -eu

resp="$(curl -Ls https://ipapi.co/json)"
gammastep -l "$(jq ".latitude" <<<"$resp")":"$(jq ".longitude" <<<"$resp")" -m wayland
