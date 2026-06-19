#!/usr/bin/env bash

inactive_since=""

while true; do

  status="$(~/.config/eww/scripts/pomodoro-status.sh)"

  if [ "$status" = "active" ]; then
    inactive_since=""
  else

    if [ -z "$inactive_since" ]; then
      inactive_since="$(date +%s)"

      eww open dashboard >/dev/null 2>&1
    fi

    now="$(date +%s)"
    elapsed=$((now - inactive_since))

    if [ "$elapsed" -ge 60 ]; then
      notify-send \
        --urgency=critical \
        "No active Pomodoro"

      (
	  SECONDS=0

	  while [ $SECONDS -lt 30 ]; do
	      canberra-gtk-play -i complete
	      sleep 1
	  done
      ) &

      inactive_since=$((now - 30))
    fi
  fi

  sleep 5
done
