#!/usr/bin/env bash

LOG=/tmp/polybar-launch.log

echo "$(date) launching polybar" >> "$LOG"

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 1
done

polybar --list-monitors >> "$LOG" 2>&1

for monitor in $(polybar --list-monitors | cut -d: -f1); do
  echo "$(date) starting bar on $monitor" >> "$LOG"
  MONITOR="$monitor" polybar main -c ~/.config/polybar/config.ini >> "$LOG" 2>&1 &
done
