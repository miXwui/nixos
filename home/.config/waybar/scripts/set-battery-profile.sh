#!/usr/bin/env bash

if command -v tlp > /dev/null 2>&1; then
	sudo tlp bat
fi

if command -v powerprofilesctl > /dev/null 2>&1; then
	powerprofilesctl set power-saver
fi
