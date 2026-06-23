#!/usr/bin/env bash

DEFAULT_TASK_ID="inbox-scratchpad"

id="$(eww get active_task_id 2>/dev/null)"
note="$(eww get quick_note 2>/dev/null)"

id="${id:-$DEFAULT_TASK_ID}"
[ -z "$note" ] && exit 0

note_json="$(printf '%s' "$note" | jq -Rs .)"

emacsclient --eval "$(cat <<ELISP
(progn
  (require 'org)
  (require 'org-id)

  (let ((m (org-id-find "$id" 'marker)))
    (unless m
      (error "No Org task found for ID: $id"))

    (with-current-buffer (marker-buffer m)
      (save-excursion
        (goto-char m)
        (org-back-to-heading t)

        (let* ((subtree-end (save-excursion
                              (org-end-of-subtree t t)))
               logbook-beg
               logbook-end)

          ;; Find an existing LOGBOOK drawer within this subtree only.
          (save-excursion
            (when (re-search-forward "^[ \t]*:LOGBOOK:[ \t]*$" subtree-end t)
              (setq logbook-beg (match-beginning 0))
              (when (re-search-forward "^[ \t]*:END:[ \t]*$" subtree-end t)
                (setq logbook-end (match-beginning 0)))))

          ;; If no valid LOGBOOK exists, create one after planning/properties.
          (unless logbook-end
            (goto-char m)
            (org-back-to-heading t)
            (org-end-of-meta-data t)
            (insert "  :LOGBOOK:\n  :END:\n")
            (setq logbook-end (save-excursion
                                (re-search-backward "^[ \t]*:END:[ \t]*$")
                                (match-beginning 0))))

          ;; Insert note just before LOGBOOK's :END:.
          (goto-char logbook-end)
          (insert "  - "
                  (format-time-string "[%Y-%m-%d %a %H:%M] ")
                  $note_json
                  "\n"))

        (save-buffer)))))
ELISP
)"

eww update quick_note=""
eww update quick_notes_yuck="$(~/.config/eww/scripts/org-task-notes-yuck.sh)"
