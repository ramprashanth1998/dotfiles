#!/usr/bin/env bash
# Install personal HyDE dotfiles on top of an existing HyDE setup.
#
# PREREQUISITE: install HyDE FIRST (https://github.com/HyDE-Project/HyDE).
# These are deltas layered on top of a working HyDE install, not a standalone DE.
#
# Symlinks tracked files into place (edits then flow back to the repo), enables
# the per-monitor waybar service, and re-applies HyDE-managed tweaks.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# repo-relative path  ->  absolute destination
declare -A LINKS=(
    ["hypr/monitors.conf"]="$HOME/.config/hypr/monitors.conf"
    ["hypr/userprefs.conf"]="$HOME/.config/hypr/userprefs.conf"
    ["hypr/hypridle.conf"]="$HOME/.config/hypr/hypridle.conf"
    ["hypr/scripts/waybar-per-monitor.py"]="$HOME/.config/hypr/scripts/waybar-per-monitor.py"
    ["systemd/user/waybar-per-monitor.service"]="$HOME/.config/systemd/user/waybar-per-monitor.service"
    ["reapply-hyde-tweaks.sh"]="$HOME/reapply-hyde-tweaks.sh"
)

echo ":: Linking dotfiles (backups -> $BACKUP)"
for rel in "${!LINKS[@]}"; do
    src="$REPO/$rel"
    dst="${LINKS[$rel]}"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "   ok   $dst"
        continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$dst" "$BACKUP/$rel"
        echo "   bak  $dst"
    fi
    ln -s "$src" "$dst"
    echo "   link $dst"
done

chmod +x "$REPO/hypr/scripts/waybar-per-monitor.py" "$REPO/reapply-hyde-tweaks.sh"

echo ":: Enabling per-monitor waybar service"
systemctl --user daemon-reload
systemctl --user enable --now waybar-per-monitor.service || true

echo ":: Re-applying HyDE-managed tweaks (ws-11 hide in waybar modules)"
"$HOME/reapply-hyde-tweaks.sh" || true

echo ":: Reloading Hyprland"
hyprctl reload || true

cat <<'EOF'

:: Done.

!! MONITOR NAMES are hardcoded for the original machine (eDP-1 + HDMI-A-1).
   On a different system, run `hyprctl monitors` and update the names in:
     - ~/.config/hypr/monitors.conf
     - ~/.config/hypr/scripts/waybar-per-monitor.py   (LAPTOP / EXTERNAL)
   then: systemctl --user restart waybar-per-monitor.service && hyprctl reload
EOF
