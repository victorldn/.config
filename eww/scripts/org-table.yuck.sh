#!/usr/bin/env bash

raw="$(emacsclient --eval '
(progn
  (load-file "~/.config/eww/scripts/org-todos.el")
  (with-output-to-string
    (eww-org-render-todos)))
')"

raw="${raw#\"}"
raw="${raw%\"}"

printf '%b\n' "$raw" | sed 's/\\"/"/g'
