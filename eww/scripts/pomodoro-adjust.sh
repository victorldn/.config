#!/usr/bin/env bash

action="$1"
step_seconds=300

time="$(eww get pomo_time 2>/dev/null)"
minutes_setting="$(eww get pomo_minutes 2>/dev/null)"
state="$(eww get pomo_state 2>/dev/null)"

minutes_setting="$(eww get pomo_minutes 2>/dev/null | tr -cd '0-9')"
minutes_setting="${minutes_setting:-25}"
state="${state:-stopped}"

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

case "$action" in
  plus)
    if [ "$state" = "working" ] || [ "$state" = "break" ]; then
      seconds="$(to_seconds "$time")"
      seconds=$((seconds + step_seconds))
      eww update pomo_time="$(to_mmss "$seconds")"
    else
      minutes_setting=$((minutes_setting + 5))
      [ "$minutes_setting" -gt 120 ] && minutes_setting=120
      eww update pomo_minutes="$minutes_setting" pomo_time="$(printf '%02d:00' "$minutes_setting")"
    fi
    ;;

  minus)
    if [ "$state" = "working" ] || [ "$state" = "break" ]; then
      seconds="$(to_seconds "$time")"
      seconds=$((seconds - step_seconds))
      [ "$seconds" -lt 60 ] && seconds=60
      eww update pomo_time="$(to_mmss "$seconds")"
    else
      minutes_setting=$((minutes_setting - 5))
      [ "$minutes_setting" -lt 5 ] && minutes_setting=5
      eww update pomo_minutes="$minutes_setting" pomo_time="$(printf '%02d:00' "$minutes_setting")"
    fi
    ;;
esac
