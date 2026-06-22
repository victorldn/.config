#!/usr/bin/env bash

state="$(eww get pomo_state 2>/dev/null)"
task="$(eww get active_task_id 2>/dev/null)"

if [ "$state" = "working" ] && [ -n "$task" ] && [ "$task" != "inbox-scratchpad" ]; then
  echo "active"
else
  echo "inactive"
fi
