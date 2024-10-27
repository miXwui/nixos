#!/usr/bin/env bash

types=$(wl-paste -l)

if echo "$types" | grep -q 'image'; then
  dunstify -h string:desktop-entry:wl-paste "$types" "copeePEE-PASTA-ED"
fi
