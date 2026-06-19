#!/usr/bin/env bash

MODE="$1"
STATE_FILE="/tmp/eww-pomodoro.pid"

stop_existing() {
  if [ -f "$STATE_FILE" ]; then
    old_pid="$(cat "$STATE_FILE")"
    kill "$old_pid" 2>/dev/null
    rm -f "$STATE_FILE"
  fi
}

run_timer() {
  total_seconds="$1"
  label="$2"

  stop_existing

  (
    eww update pomo_state="$label"

    remaining="$total_seconds"

    while [ "$remaining" -ge 0 ]; do
      mins=$((remaining / 60))
      secs=$((remaining % 60))

      eww update pomo_time="$(printf '%02d:%02d' "$mins" "$secs")"

      sleep 1
      remaining=$((remaining - 1))
    done

    eww update pomo_state="🚨 TIME UP 🚨"w

    # Alternative symbol: 
    notify-send \
      --urgency=critical \
      --expire-time=0 \
      "🍅 Pomodoro complete" \
      "$label finished"

    (
	end=$((SECONDS + 10))
	while [ $SECONDS -lt $end ]; do
	    canberra-gtk-play -i complete
	    sleep 0.25
	done
    ) &
    
    rm -f "$STATE_FILE"
  ) &

  echo "$!" > "$STATE_FILE"
}

case "$MODE" in
  work)
    minutes="$(eww get pomo_minutes 2>/dev/null)"
    minutes="${minutes:-25}"
    run_timer "$((minutes * 60))" "working"
    ;;
  break)
    run_timer 300 "break"
    ;;
  reset)
    stop_existing
    eww update pomo_time="25:00"
    eww update pomo_state="stopped"
    ;;
  *)
    echo "Usage: pomodoro.sh work|break|reset"
    exit 1
    ;;
esac
