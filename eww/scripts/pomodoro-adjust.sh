#!/usr/bin/env bash

action="$1"
minutes="$(eww get pomo_minutes 2>/dev/null)"
minutes="${minutes:-25}"

case "$action" in
  plus) minutes=$((minutes + 5)) ;;
  minus) minutes=$((minutes - 5)) ;;
esac

[ "$minutes" -lt 5 ] && minutes=5
[ "$minutes" -gt 120 ] && minutes=120

eww update pomo_minutes="$minutes"

state="$(eww get pomo_state 2>/dev/null)"
if [ "$state" = "stopped" ]; then
  eww update pomo_time="$(printf '%02d:00' "$minutes")"
fi
