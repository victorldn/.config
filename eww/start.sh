#!/usr/bin/env bash

eww daemon

sleep 1

eval "$(
  ~/.config/eww/scripts/org-default-task.sh
)"

eww update \
  active_task_id="$active_task_id" \
  active_task_desc="$active_task_desc"

eww update quick_notes_text="$(~/.config/eww/scripts/org-task-notes.sh)"
