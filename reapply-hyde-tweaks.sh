#!/usr/bin/env bash
# Re-apply personal HyDE tweaks that a `hyde update` can overwrite.
#
# What HyDE updates can clobber:
#   - ~/.local/share/waybar/modules/hyprland-workspaces*.jsonc  (ws-11 hide)
#
# What already survives updates (no action needed here):
#   - ws-11 pin to laptop        -> ~/.config/hypr/monitors.conf
#   - Mod+` keybinds             -> ~/.config/hypr/userprefs.conf
#   - per-monitor waybar output  -> waybar-per-monitor.service + script
#
# Safe to run anytime; it is idempotent.
set -euo pipefail

HIDDEN_WS='^11$'
MODULES_DIR="$HOME/.local/share/waybar/modules"
SERVICE="waybar-per-monitor.service"

echo ":: Re-applying ws-11 hide to Waybar workspace modules..."
python3 - "$MODULES_DIR" "$HIDDEN_WS" <<'PY'
import glob, json, os, sys
modules_dir, hidden = sys.argv[1], sys.argv[2]
patched = 0
for path in glob.glob(os.path.join(modules_dir, "hyprland-workspaces*.jsonc")):
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception as e:
        print(f"   skip {os.path.basename(path)} (parse error: {e})")
        continue
    key = next(iter(data))
    ignore = data[key].get("ignore-workspaces", [])
    if hidden not in ignore:
        ignore.append(hidden)
        data[key]["ignore-workspaces"] = ignore
        with open(path, "w") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
            f.write("\n")
        print(f"   patched {os.path.basename(path)}")
        patched += 1
    else:
        print(f"   ok      {os.path.basename(path)} (already hidden)")
print(f":: modules updated: {patched}")
PY

echo ":: Ensuring per-monitor waybar service is enabled and running..."
systemctl --user enable --now "$SERVICE" >/dev/null 2>&1 || true
if systemctl --user is-active --quiet "$SERVICE"; then
    echo "   $SERVICE active"
else
    echo "   WARNING: $SERVICE not active (check: systemctl --user status $SERVICE)"
fi

echo ":: Reloading Waybar to apply..."
killall -SIGUSR2 waybar 2>/dev/null || true

echo ":: Done."
