#!/usr/bin/env bash
set -euo pipefail

BAD="${1:-}"

case "$BAD" in
    DP-1-0.8)
        xrandr --output DP-1-0.8 --off
        sleep 2
        xrandr \
            --output DP-1-0.8 \
            --mode 2560x1440 \
            --rate 59.95 \
            --left-of DP-1-2 \
            --primary
	/home/vicdon01/.config/polybar/launch.sh
        ;;

    DP-1-2)
        xrandr --output DP-1-2 --off
        sleep 2
        xrandr \
            --output DP-1-2 \
            --mode 2560x1440 \
            --rate 59.95 \
            --right-of DP-1-0.8
	/home/vicdon01/.config/polybar/launch.sh
        ;;

    *)
        echo "Usage: $0 DP-1-0.8|DP-1-2"
        exit 1
        ;;
esac
