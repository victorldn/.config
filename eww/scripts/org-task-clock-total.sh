#!/usr/bin/env bash

id="$1"
[ -z "$id" ] && id="$(eww get active_task_id 2>/dev/null)"
[ -z "$id" ] && echo "0m" && exit 0

mins="$(emacsclient --eval "
(progn
  (load-file \"~/.config/eww/scripts/org-todos.el\")
  (eww-org-clock-minutes-for-id \"$id\"))
" 2>/dev/null | tr -cd '0-9')"

[ -z "$mins" ] && mins=0

h=$((mins / 60))
m=$((mins % 60))

if [ "$h" -gt 0 ]; then
  printf "%dh %02dm\n" "$h" "$m"
else
  printf "%dm\n" "$m"
fi
