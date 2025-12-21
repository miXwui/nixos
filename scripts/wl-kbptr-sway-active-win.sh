#!/usr/bin/env sh

# https://github.com/moverest/wl-kbptr/blob/main/helpers/wl-kbptr-sway-active-win

active_area=$(swaymsg -t get_tree | jq --raw-output \
	'.. | (.nodes? + .floating_nodes? // empty)[] | select (.focused) | .rect | "\(.width)x\(.height)+\(.x)+\(.y)"')
wl-kbptr --restrict "$active_area" $@
