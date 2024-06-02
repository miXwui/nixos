#!/bin/bash

# dependencies: zenity

option=$(zenity --list --title="Fast Commands" --text="Select a goTTa G0 fAsTT!!!11 COMMAND SANIC" \
  --column="Option" \
  --column="Folder" \
  00 "Screen utils (Mod+Print)" \
  01 "Pick Color (Ctrl+Shift+Alt+K+C)" \
  02 "Zenity Color Picker (Ctrl+Shift+Alt+C)" \
  03 "GColor3" \
  04 "Gnome Tweaks" \
  1 "Downloads" \
  2 "Documents" \
  3 "Videos" \
  4 "Pictures" \
  5 "Music" \
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
  nautilus ~/Downloads
  ;;

2)
  nautilus ~/Documents
  ;;

3)
  nautilus ~/Videos
  ;;

4)
  nautilus ~/Pictures
  ;;

5)
  nautilus ~/Music
  ;;

6)
  nautilus ~/Work/desophy/ccm/ccm-website
  ;;

7)
  nautilus ~/Work/desophy/dsa/dsa-website
  ;;

100)
  foot sh -c "swaymsg -t get_tree | less"
  ;;

*)
  echo 'Invalid option'
  ;;
esac
