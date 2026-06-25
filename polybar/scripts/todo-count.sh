#!/usr/bin/env bash

emacsclient --eval "$(cat <<'ELISP'
(progn
  (require 'org)
  (require 'org-id)
  (let ((count 0)
        (files '("~/org/inbox.org" "~/org/tasks.org")))
    (dolist (file files)
      (with-current-buffer (find-file-noselect file)
        (org-with-wide-buffer
         (goto-char (point-min))
         (while (re-search-forward org-heading-regexp nil t)
           (let ((todo (substring-no-properties
                        (or (org-get-todo-state) "")))
                 (is-default (string= (org-entry-get nil "EWW_DEFAULT") "true")))
             (when (and (string= todo "TODO")
                        (not is-default))
               (setq count (1+ count))))))))
    count))
ELISP
)" 2>/dev/null | tr -cd '0-9'
