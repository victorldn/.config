#!/usr/bin/env bash
set -euo pipefail
POLYBAR_LAUNCH="${HOME}/.config/polybar/launch.sh"
HOOK_DIR="${HOME}/.config/autorandr/postswitch"
HOOK_FILE="${HOOK_DIR}/polybar"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

echo "Checking autorandr..."

if ! need_cmd autorandr; then
  echo "autorandr is not installed."
  echo
  echo "Install it with:"
  echo "  sudo apt install autorandr"
  echo
  echo "Then rerun this script."
  exit 1
fi

echo "autorandr found: $(command -v autorandr)"

if [ ! -x "$POLYBAR_LAUNCH" ]; then
  echo "ERROR: Polybar launcher not found or not executable:"
  echo "  $POLYBAR_LAUNCH"
  echo
  echo "Fix with:"
  echo "  chmod +x $POLYBAR_LAUNCH"
  exit 1
fi

echo "Checking autorandr profiles..."

if ! autorandr --detected >/dev/null 2>&1; then
  echo "autorandr did not run successfully."
  echo "Try running:"
  echo "  autorandr --save current"
  exit 1
fi

if [ -z "$(autorandr --detected 2>/dev/null)" ]; then
  echo "No autorandr profile appears to match the current setup."
  echo
  echo "Create one now with:"
  echo "  autorandr --save current"
  echo
  echo "Then rerun this script."
  exit 1
fi

mkdir -p "$HOOK_DIR"

cat > "$HOOK_FILE" <<EOF
#!/usr/bin/env bash
$POLYBAR_LAUNCH
EOF

chmod +x "$HOOK_FILE"

echo "Installed autorandr postswitch hook:"
echo "  $HOOK_FILE"

echo
echo "Testing hook by running:"
echo "  autorandr --change"
autorandr --change || true

echo
echo "Checking autorandr user services..."

if systemctl --user list-unit-files 2>/dev/null | grep -q '^autorandr\.service'; then
  systemctl --user enable --now autorandr.service
  echo "Enabled autorandr.service"

elif systemctl --user list-unit-files 2>/dev/null | grep -q '^autorandr-lid-listener\.service'; then
  systemctl --user enable --now autorandr-lid-listener.service
  echo "Enabled autorandr-lid-listener.service"

else
  echo "No autorandr systemd user service found."
  echo
  echo "Add the following to your Regolith/i3 configuration:"
  echo
  echo "  exec_always --no-startup-id autorandr --change"
  echo
  echo "This ensures autorandr runs after login and i3 reloads."
  echo
  echo "The Polybar hook is already installed:"
  echo "  ~/.config/autorandr/postswitch/polybar"
fi

echo
echo "Done."
