#!/usr/bin/env bash
# Install personal caelestia dotfiles on top of an existing caelestia setup.
#
# PREREQUISITE: install caelestia FIRST (https://github.com/caelestia-dots/caelestia).
# These are deltas layered on top of a working caelestia install, not a standalone DE.
#
# Symlinks tracked files into place (edits then flow back to the repo) and
# reloads Hyprland.
#
# NOTE: everything under ~/.config/caelestia/ lives in caelestia's *user* dir and
# survives `caelestia install`. foot.ini does NOT — it is a managed file with no
# override hook, so a reinstall clobbers it. Either re-run this script afterwards
# or install with:  caelestia install --disable-components foot
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# repo-relative path  ->  absolute destination
declare -A LINKS=(
    ["caelestia/hypr-user.lua"]="$HOME/.config/caelestia/hypr-user.lua"
    ["caelestia/shell.json"]="$HOME/.config/caelestia/shell.json"
    ["caelestia/user-config.fish"]="$HOME/.config/caelestia/user-config.fish"
    ["foot/foot.ini"]="$HOME/.config/foot/foot.ini"
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

# Empty per-monitor state dirs caelestia expects; git cannot track empty dirs.
mkdir -p "$HOME/.config/caelestia/monitors/eDP-1" "$HOME/.config/caelestia/monitors/HDMI-A-1"

echo ":: Reloading Hyprland"
hyprctl reload || true

echo ":: Restarting caelestia shell"
caelestia shell -d || true

cat <<'EOF'

:: Done.

!! foot.ini is a caelestia-MANAGED file with no user-override hook.
   A `caelestia install` will overwrite it and you lose font size 16.
   Either re-run this script afterwards, or install with:
     caelestia install --disable-components foot

!! MONITOR NAMES are hardcoded for the original machine (eDP-1 + HDMI-A-1,
   both 1920x1080@144). On a different system, run `hyprctl monitors` and
   update ~/.config/caelestia/hypr-user.lua, then: hyprctl reload
EOF
