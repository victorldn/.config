#!/usr/bin/env bash

id="$1"
shift
desc="$*"

eww update active_task_id="$id" active_task_desc="$desc"
eww update active_task_time="$(~/.config/eww/scripts/org-task-clock-total.sh "$id")"
eww update quick_notes_yuck="$(~/.config/eww/scripts/org-task-notes-yuck.sh)"
