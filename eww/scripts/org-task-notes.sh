#!/usr/bin/env bash

DEFAULT_TASK_ID="inbox-scratchpad"

id="$(eww get active_task_id 2>/dev/null)"
id="${id:-$DEFAULT_TASK_ID}"

emacsclient --eval "$(cat <<ELISP
(progn
  (require 'org)
  (require 'org-id)
  (require 'subr-x)

  (let ((m (org-id-find "$id" 'marker)))
    (if (not m)
        "No notes yet"
      (with-current-buffer (marker-buffer m)
        (save-restriction
          (widen)
          (save-excursion
            (goto-char m)
            (org-back-to-heading t)
            (let ((subtree-end (save-excursion
                                 (org-end-of-subtree t t)))
                  (notes nil))
              (while (re-search-forward "^[[:space:]]*- .+$" subtree-end t)
                (let ((line (string-trim
                             (buffer-substring-no-properties
                              (line-beginning-position)
                              (line-end-position)))))
                  (push (replace-regexp-in-string "^[[:space:]]*- " "" line)
                        notes)))
              (if notes
                  (mapconcat #'identity
                             (last (nreverse notes) 8)
                             "\n")
                "No notes yet"))))))))
ELISP
)" | sed 's/^"//; s/"$//; s/\\n/\n/g; s/\\"/"/g'
