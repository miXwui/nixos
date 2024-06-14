#!/usr/bin/env bash

# https://github.com/fennerm/flashfocus/issues/68
# Would use if I could find a simple no-dependency way to run
# this script with just sway when mouse focuses a new window

for OP in 0.905 0.82 0.745 0.68 0.625 0.58 0.545 0.52 0.505 0.5 0.505 0.52 0.545 0.58 0.625 0.68 0.745 0.82 0.905 1; do
        swaymsg opacity $OP
        sleep .005
done
