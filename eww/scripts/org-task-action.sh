#!/usr/bin/env bash

action="$1"
id="$2"

[ -z "$action" ] && exit 1
[ -z "$id" ] && exit 1

case "$action" in
  done)
    emacsclient --eval "
      (progn
        (require 'org)
        (require 'org-id)
        (let ((m (org-id-find \"$id\" 'marker)))
          (when m
            (with-current-buffer (marker-buffer m)
              (goto-char m)
              (org-todo \"DONE\")
              (save-buffer)))))
    "
    ;;

  *)
    exit 1
    ;;
esac

eww update tasks_yuck="$(~/.config/eww/scripts/org-table.yuck.sh)"
