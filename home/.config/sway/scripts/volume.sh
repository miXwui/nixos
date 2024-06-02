#!/bin/bash

# Inspiration from https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# and https://github.com/dunst-project/dunst/blob/master/contrib/progress-notify.sh
# and https://unix.stackexchange.com/a/646585

# dependencies: dunstify, pactl

# You can call this script like this:
# $./volume.sh up
# $./volume.sh down
# $./volume.sh mute

get_volume() {
    # https://lists.sr.ht/~mil/sxmo-devel/patches/26368
    # adding 2>/dev/null
    # else sway.log would include things like
    # tr: write error: Broken pipe
    # tr: write error
    # pactl list sinks | tr ' ' '\n' 2>/dev/null | grep -m1 '%' | tr -d '% '
    echo "scale = 0; ($(wpctl status | grep "*" | sed 's/.*\[\([^]]*\)\].*/\1/g' | head -1 | tr -d 'vol: ') * 100) / 1" | bc -l
}

is_mute() {
    test "$(pactl list sinks | grep 'Mute:' | sed -r 's/\s+Mute: //g')" = 'yes' && echo return 0 || return 1
}

send_notification() {
    volume=$(get_volume)
if [ "$volume" -eq 0 ]; then
    icon_name=audio-volume-muted
elif [ "$volume" -le 30 ]; then
    icon_name=audio-volume-low
elif [ "$volume" -le 70 ]; then
    icon_name=audio-volume-medium
else
    icon_name=audio-volume-high
fi
# Send the notification
#dunstify -h string:x-dunst-stack-tag:volume "Volume: "$volume"%" --icon "$icon_name" -t 2000 -h int:value:$volume -h string:desktop-entry:volume -t 1500
dunstify -h string:x-dunst-stack-tag:volume "Volume: ""$volume""%" -t 2000 -h int:value:"$volume" -h string:desktop-entry:volume -t 1500
}

case $1 in
    up)
# Set the volume on (if it was d)
pactl set-sink-mute @DEFAULT_SINK@ 0 > /dev/null
# Up the volume (+ 5%)
pactl set-sink-volume @DEFAULT_SINK@ +5% > /dev/null
send_notification
;;
    down)
pactl set-sink-mute @DEFAULT_SINK@ 0 > /dev/null
pactl set-sink-volume @DEFAULT_SINK@ -5% > /dev/null
send_notification
;;
    mute)
    # Toggle mute
pactl set-sink-mute @DEFAULT_SINK@ toggle > /dev/null
if is_mute ; then
            #dunstify -h string:x-dunst-stack-tag:volume "Muted" --icon audio-volume-muted -t 1500
            dunstify -h string:x-dunst-stack-tag:volume "Muted" -t 1500
else
    send_notification
fi
;;
    *)
        echo "Not the right arguments (up/down/mute)"
        echo "$1"
        exit 2
esac

