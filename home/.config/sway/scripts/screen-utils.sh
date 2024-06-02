#!/bin/bash

# dependencies: zenity

option=$(zenity --list \
  --column="Option" \
  --column="Command" \
  1 "Screenshot focused display (Ctrl+Print)" \
  2 "Screenshot all displays (Ctrl+Shift+Print)" \
  3 "Record GIF Start/Stop (Ctrl+Alt+Shift+G)")

case $option in

1)
  ~/.config/sway/scripts/screenshot-current-display.sh
  ;;

2)
  ~/.config/sway/scripts/screenshot-all-displays.sh
  ;;

3)
  ~/.config/sway/scripts/gif-record.sh
  ;;

*)
  echo 'Invalid option'
  ;;
esac
