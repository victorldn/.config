#!/usr/bin/env bash

eww daemon

for _ in $(seq 1 30); do
  eww state >/dev/null 2>&1 && break
  sleep 1
done

for _ in $(seq 1 60); do
  emacsclient --eval '(progn (require '\''org) (emacs-pid))' >/dev/null 2>&1 && break
  sleep 1
done

eval "$("$HOME/.config/eww/scripts/org-default-task.sh")"

eww update \
  active_task_id="$active_task_id" \
  active_task_desc="$active_task_desc"

eww update tasks_yuck="$("$HOME/.config/eww/scripts/org-table.yuck.sh")"
eww update quick_notes_yuck="$("$HOME/.config/eww/scripts/org-task-notes-yuck.sh")"
eww update active_task_time="$("$HOME/.config/eww/scripts/org-task-clock-total.sh")"
