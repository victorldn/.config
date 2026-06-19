#!/usr/bin/env bash

action="$1"
id="$2"

[ -z "$action" ] && exit 1
[ -z "$id" ] && exit 1

case "$action" in
  done)
    task "$id" done
    ;;
  delete)
    task "$id" delete rc.confirmation=no
    ;;
  *)
    exit 1
    ;;
esac

eww update tasks_yuck="$(~/.config/eww/scripts/task-table.yuck.sh)"
