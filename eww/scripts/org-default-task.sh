#!/usr/bin/env bash

emacsclient --eval "$(cat <<'ELISP'
(progn
  (require 'org)
  (require 'org-id)
  (let ((m (org-id-find "inbox-scratchpad" 'marker)))
    (if m
        (with-current-buffer (marker-buffer m)
          (goto-char m)
          (format "active_task_id=%S\nactive_task_desc=%S"
                  "inbox-scratchpad"
                  (substring-no-properties (org-get-heading t t t t))))
      "active_task_id=\"\"\nactive_task_desc=\"No active task\"")))
ELISP
)" | sed 's/^"//; s/"$//; s/\\n/\n/g; s/\\"/"/g'
