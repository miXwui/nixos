#!/bin/bash

# dependencies: dunstify, grim, slurp, wl-copy

dunstify "Color piCCin THICC" && grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n 1 | cut -d ' ' -f 4 | tr '[:upper:]' '[:lower:]' | tee >(wl-copy) | while read OUTPUT; do dunstify "piCCed HEXY: $OUTPUT"; done
