#!/usr/bin/env bash

# dependencies: zenity

option=$(zenity --list --title="Fast Commands" --text="Select a goTTa G0 fAsTT!!!11 COMMAND SANIC" \
  --column="Option" \
  --column="Folder" \
  00 "Screen utils (Mod+Print)" \
  01 "Pick Color (Ctrl+Shift+Alt+K+C)" \
  02 "Zenity Color Picker (Ctrl+Shift+Alt+C)" \
  03 "GColor3" \
  04 "Gnome Tweaks" \
  1 "tmp" \
  2 "documents" \
  3 "videos" \
  4 "pictures" \
  5 "music" \
  6 "DSA" \
  7 "CCM" \
  100 "Find App ID")

case $option in

00)
  ~/.config/sway/scripts/screen-utils.sh

  ;;

01)
  ~/.config/sway/scripts/pick-color.sh
  ;;

02)
  ~/.config/sway/scripts/color-picker.sh
  ;;

03)
  gcolor3
  ;;

04)
  gnome-tweaks
  ;;

1)
  nautilus "$XDG_DOWNLOAD_DIR"
  ;;

2)
  nautilus "$XDG_DOCUMENTS_DIR"
  ;;

3)
  nautilus "$XDG_VIDEOS_DIR"
  ;;

4)
  nautilus "$XDG_PICTURES_DIR"
  ;;

5)
  nautilus "$XDG_MUSIC_DIR"
  ;;

6)
  nautilus "$XDG_WORK_DIR/desophy/ccm/ccm-website"
  ;;

7)
  nautilus "$XDG_WORK_DIR/desophy/dsa/dsa-website"
  ;;

100)
  foot sh -c "swaymsg -t get_tree | less"
  ;;

*)
  echo 'Invalid option'
  ;;
esac
