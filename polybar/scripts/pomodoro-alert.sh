#!/usr/bin/env bash

status="$(~/.config/eww/scripts/pomodoro-status.sh)"

if [ "$status" = "active" ]; then
  echo ""
else
  echo "%{F#ff5555}NO TASK%{F-}"
fi
