#!/usr/bin/env bash

echo "225" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
