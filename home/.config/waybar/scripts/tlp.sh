#!/bin/bash

EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)

if cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference | grep -q "balance_performance"; then
  jq -c -r --null-input \
    --arg text "$EPP" \
    --arg tooltip "$EPP" \
    '{
      "text": $text,
      "alt": "ac",
      "tooltip": $tooltip,
      "class": "ac"
    }'
else
  jq -c -r --null-input \
    --arg text "$EPP" \
    --arg tooltip "$EPP" \
    '{
      "text": $text,
      "alt": "bat",
      "tooltip": $tooltip,
      "class": "bat"
    }'
fi
