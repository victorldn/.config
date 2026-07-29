#!/usr/bin/env bash

# Start the Emacs daemon for Org/Eww integrations.
# Ensure the daemon is running.
pgrep -x emacs >/dev/null 2>&1 || emacs --daemon &

# Open one GUI frame if none exist.
if ! emacsclient -e '(> (length (visible-frame-list)) 0)' 2>/dev/null | grep -q t; then
    emacsclient -c &
fi

# Start irccloud. The fact this app starts unconditionally means it must be
# improved.
chromium --app="https://www.irccloud.com/irc/oftc/channel/gcc"

# Start graphical applications only when they are not already running.
pgrep -x kitty >/dev/null 2>&1 || kitty &
pgrep -x firefox >/dev/null 2>&1 || firefox &
pgrep -x slack >/dev/null 2>&1 || slack &
pgrep -x spotify >/dev/null 2>&1 || spotify &
