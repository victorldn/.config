echo "=== SESSION ==="
echo "$XDG_SESSION_TYPE"

echo "=== GPU ==="
lspci -k | grep -EA3 'VGA|3D|Display'

echo "=== XRANDR ==="
xrandr --query

echo "=== DRM ==="
for f in /sys/class/drm/card*-*/status; do
    printf '%s: %s\n' "$f" "$(cat "$f")"
done

echo "=== USB-C / TYPE-C ==="
find /sys/class/typec -maxdepth 2 -type l -o -type f 2>/dev/null | sort
