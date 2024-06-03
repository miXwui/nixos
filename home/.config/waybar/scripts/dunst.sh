#!/bin/bash

COUNT=$(dunstctl count waiting)
ENABLED=
DISABLED=
if [ $COUNT != 0 ]; then DISABLED=" $COUNT"; fi
# if dunstctl is-paused | grep -q "false" ; then echo $ENABLED; else echo $DISABLED; fi

if dunstctl is-paused | grep -q "false"; then
  jq -c -r --null-input \
    --arg text "$ENABLED" \
    --arg tooltip "$ENABLED" \
    '{
      "text": $text,
      "alt": "unmuted",
      "tooltip": $tooltip,
      "class": "unmuted"
    }'
else
  jq -c -r --null-input \
    --arg text "$DISABLED" \
    --arg tooltip "$DISABLED" \
    '{
      "text": $text,
      "alt": "muted",
      "tooltip": $tooltip,
      "class": "muted"
    }'
fi
