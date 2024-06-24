#!/usr/bin/env bash

# This script gets latitude and longitude based on IP address.
# However, we're currently using GeoClue instead.

# From and thanks:
# https://rumpelsepp.org/blog/geolocation-for-gammastep/
# archive: https://codeberg.org/rumpelsepp/homepage/src/branch/master/content/blog/2021-10-26-geolocation-for-gammastep.md

# Called from ~/.config/systemd/user/gammastep.service

# dependencies: jq

set -eu

resp="$(curl -Ls https://ipapi.co/json)"
gammastep -l "$(jq ".latitude" <<<"$resp")":"$(jq ".longitude" <<<"$resp")" -m wayland

### systemd service

# `~/.config/systemd/user/gammastep.service`

# [Unit]
# Description=Display colour temperature adjustment
# PartOf=graphical-session.target
# After=graphical-session.target NetworkManager-wait-online.service

# [Service]
# ExecStart=%h/.local/bin/gammastep-wrapper.sh

# [Install]
# WantedBy=graphical-session.target
