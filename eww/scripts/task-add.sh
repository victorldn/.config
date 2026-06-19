#!/usr/bin/env bash

desc="$(eww get new_task)"
due="$(eww get new_task_due)"

[ -z "$desc" ] && exit 0

if [ -n "$due" ]; then
  task add "$desc" due:"$due"
else
  task add "$desc"
fi

eww update new_task="" new_task_due=""
eww update tasks_yuck="$(~/.config/eww/scripts/task-table.yuck.sh)"
