#!/usr/bin/env bash

time="$(eww get pomo_time 2>/dev/null)"
state="$(eww get pomo_state 2>/dev/null)"
task="$(eww get active_task_desc 2>/dev/null)"

[ -z "$time" ] && exit 0
[ "$state" = "stopped" ] && exit 0

if [ -n "$task" ] && [ "$task" != "No active task" ]; then
  short_task="$(printf '%s' "$task" | cut -c1-30)"
  echo "🍅 $time $short_task"
else
  echo "🍅 $time"
fi
