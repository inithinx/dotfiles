swayidle -w timeout 120 'swaylock -f -c 000000' \
            timeout 300 'hyprctl dispatch dpms off' \
            timeout 600 'systemctl suspend' \
            resume 'hyprctl dispatch dpms on' \
            before-sleep 'swaylock -f -c 000000' &
