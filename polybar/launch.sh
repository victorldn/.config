#!/usr/bin/env bash

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 1
done

for monitor in $(polybar -m | cut -d: -f1); do
  MONITOR=$monitor polybar main -c ~/.config/polybar/config.ini &
done
