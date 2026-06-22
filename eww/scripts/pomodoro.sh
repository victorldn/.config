#!/usr/bin/env bash

MODE="$1"
STATE_FILE="/tmp/eww-pomodoro.pid"

task_id="$(eww get active_task_id 2>/dev/null)"

clock_task() {
  local action="$1"

  [ -z "$task_id" ] && return 0

  ~/.config/eww/scripts/org-clock-action.sh "$action" "$task_id"
}

to_seconds() {
  IFS=: read -r m s <<EOF
$1
EOF
  echo $((10#$m * 60 + 10#$s))
}

to_mmss() {
  total="$1"
  [ "$total" -lt 0 ] && total=0
  printf '%02d:%02d' "$((total / 60))" "$((total % 60))"
}

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

    eww update pomo_time="$(to_mmss "$total_seconds")"

    while true; do
	current="$(eww get pomo_time 2>/dev/null)"
	remaining="$(to_seconds "$current")"

	[ "$remaining" -le 0 ] && break

	sleep 1

	current="$(eww get pomo_time 2>/dev/null)"
	remaining="$(to_seconds "$current")"
	remaining=$((remaining - 1))

	eww update pomo_time="$(to_mmss "$remaining")"
    done

    eww update pomo_state="🚨 TIME UP 🚨"

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
    
    if [ "$label" = "working" ]; then
	clock_task out
    fi

    rm -f "$STATE_FILE"
  ) &

  echo "$!" > "$STATE_FILE"
}

case "$MODE" in
  work)
    minutes="$(eww get pomo_minutes 2>/dev/null)"
    minutes="${minutes:-25}"
    clock_task in

    if [ -f /tmp/pomodoro-alert.pid ]; then
	kill "$(cat /tmp/pomodoro-alert.pid)" 2>/dev/null
	rm -f /tmp/pomodoro-alert.pid
    fi

    run_timer "$((minutes * 60))" "working"
    ;;
  break)
    clock_task out
    run_timer 300 "break"
    ;;
  reset)
      stop_existing
      clock_task out
      eww update pomo_minutes="25"
      eww update pomo_time="25:00"
      eww update pomo_state="stopped"
    ;;
  *)
    echo "Usage: pomodoro.sh work|break|reset"
    exit 1
    ;;
esac

