#!/usr/bin/env bash

inactive_since=""
ALERT_PID_FILE="/tmp/pomodoro-alert.pid"
SILENCE_FILE="/tmp/pomodoro-alert-silenced"

close_alert() {
  if [ -f "$ALERT_PID_FILE" ]; then
    kill "$(cat "$ALERT_PID_FILE")" 2>/dev/null
    rm -f "$ALERT_PID_FILE"
  fi
}

alert_running() {
  [ -f "$ALERT_PID_FILE" ] && kill -0 "$(cat "$ALERT_PID_FILE")" 2>/dev/null
}

while true; do
  status="$(~/.config/eww/scripts/pomodoro-status.sh)"

  if [ "$status" = "active" ]; then
    inactive_since=""
    close_alert
    rm -f "$SILENCE_FILE"
  else
    if [ -z "$inactive_since" ]; then
      inactive_since="$(date +%s)"
      eww open dashboard >/dev/null 2>&1
    fi

    now="$(date +%s)"
    elapsed=$((now - inactive_since))

    if [ "$elapsed" -ge 1 ] && ! alert_running && [ ! -f "$SILENCE_FILE" ]; then
      zenity --warning \
        --title="No active Pomodoro" \
        --text="Select a task and start a timer." &

      alert_pid=$!
      echo "$alert_pid" > "$ALERT_PID_FILE"

      (
        while kill -0 "$alert_pid" 2>/dev/null; do
          status="$(~/.config/eww/scripts/pomodoro-status.sh)"
          [ "$status" = "active" ] && break

          canberra-gtk-play -i complete
          sleep 1
        done
      ) &

      (
        wait "$alert_pid"
        rm -f "$ALERT_PID_FILE"
        touch "$SILENCE_FILE"
      ) &
    fi
  fi

  sleep 5
done
