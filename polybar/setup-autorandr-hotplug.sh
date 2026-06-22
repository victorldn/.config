#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${USER}"
USER_ID="$(id -u)"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/autorandr-change.service"
UDEV_RULE="/etc/udev/rules.d/99-autorandr-hotplug.rules"

Environment=DISPLAY=${DISPLAY}
Environment=XAUTHORITY=%h/.Xauthority

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

if ! need_cmd autorandr; then
  echo "autorandr is not installed."
  echo "Install with: sudo apt install autorandr"
  exit 1
fi

mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Run autorandr after display hotplug

[Service]
Type=oneshot
KillMode=process
Environment=DISPLAY=${DISPLAY}
Environment=XAUTHORITY=%h/.Xauthority
ExecStart=/bin/bash -lc 'echo "$(date) hotplug service running" >> /tmp/polybar-hotplug.log; /usr/bin/autorandr --change || true; sleep 4; echo "$(date) launching polybar" >> /tmp/polybar-hotplug.log; %h/.config/polybar/launch.sh >> /tmp/polybar-hotplug.log 2>&1; echo "$(date) done" >> /tmp/polybar-hotplug.log'
EOF


systemctl --user daemon-reload

echo "Installed user service:"
echo "  $SERVICE_FILE"

echo "Installing udev rule. You may be prompted for sudo."

sudo tee "$UDEV_RULE" >/dev/null <<EOF
ACTION=="change", SUBSYSTEM=="drm", RUN+="/usr/bin/su ${USER_NAME} -c 'XDG_RUNTIME_DIR=/run/user/${USER_ID} systemctl --user start autorandr-change.service'"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=drm

echo
echo "Installed udev rule:"
echo "  $UDEV_RULE"
echo
echo "Test with:"
echo "  systemctl --user start autorandr-change.service"
echo "  journalctl --user -u autorandr-change.service -n 50 --no-pager"
