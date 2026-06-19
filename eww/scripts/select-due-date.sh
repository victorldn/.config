#!/usr/bin/env bash

selected=$(zenity --calendar \
  --title="Select Due Date" \
  --date-format="%Y-%m-%d")

[ -z "$selected" ] && exit 0

eww update new_task_due="$selected"
