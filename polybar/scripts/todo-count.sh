#!/usr/bin/env bash

emacsclient --eval "$(cat <<'ELISP'
(progn
  (require 'org)
  (setq org-agenda-files '("~/org/inbox.org" "~/org/tasks.org"))
  (let ((count 0))
    (dolist (file org-agenda-files)
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-map-entries
           (lambda ()
             (unless (string= (org-entry-get nil "EWW_DEFAULT") "true")
               (setq count (1+ count))))
           "TODO=\"TODO\""))))
    count))
ELISP
)" 2>/dev/null | tr -cd '0-9'
