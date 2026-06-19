#!/usr/bin/env bash

action="$1"
id="$2"

[ -z "$action" ] && exit 1
[ -z "$id" ] && exit 1

emacsclient --eval "
(progn
  (require 'org)
  (require 'org-id)
  (let ((m (org-id-find \"$id\" 'marker)))
    (when m
      (with-current-buffer (marker-buffer m)
        (goto-char m)
        (pcase \"$action\"
          (\"in\"  (org-clock-in))
          (\"out\" (when (org-clocking-p) (org-clock-out)))
          (_ nil))
        (save-buffer)))))
"
