#!/bin/bash

entries="⇠ Logout\n Lock\n⏾ Suspend\n⭮ Reboot\n⏻ Shutdown"

selected=$(echo -e $entries|wofi --width 30% --height 25% --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  lock)
      swaylock;;
  logout)
    loginctl terminate-user $USER;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
