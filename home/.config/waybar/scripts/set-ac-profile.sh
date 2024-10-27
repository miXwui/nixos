#!/usr/bin/env bash

if command -v tlp >/dev/null 2>&1; then
  sudo tlp ac
fi

if command -v powerprofilesctl >/dev/null 2>&1; then
  powerprofilesctl set balanced
fi
