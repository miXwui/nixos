#!/usr/bin/env bash

EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)

if grep -q "balance_performance" /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference; then
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
