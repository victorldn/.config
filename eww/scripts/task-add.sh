#!/usr/bin/env bash

title="$(eww get new_task 2>/dev/null)"
due="$(eww get new_task_due 2>/dev/null)"

[ -z "$title" ] && exit 0

emacsclient --eval "
(progn
  (require 'org)
  (require 'org-id)
  (find-file \"~/org/inbox.org\")
  (goto-char (point-max))
  (unless (bolp) (insert \"\n\"))
  (insert \"* TODO $title\n\")
  (forward-line -1)
  (org-id-get-create)
  (when (and \"$due\" (not (string= \"$due\" \"\")))
    (org-deadline nil \"$due\"))
  (save-buffer))
"

eww update new_task="" new_task_due=""
eww update tasks_yuck="$(~/.config/eww/scripts/org-table.yuck.sh)"
