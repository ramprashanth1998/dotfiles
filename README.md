# dotfiles

Personal customizations layered on top of a [HyDE](https://github.com/HyDE-Project/HyDE)
Hyprland setup. These are **deltas**, not a full desktop — install HyDE first.

## What's here

| Path | Purpose |
|------|---------|
| `hypr/monitors.conf` | Monitor layout, workspace→monitor bindings, hidden ws 11 pinned to laptop |
| `hypr/userprefs.conf` | ws 11 keybinds (Mod+`), zen/steam opacity overrides, misc Hyprland prefs |
| `hypr/hypridle.conf` | Idle timeouts (dim/lock/dpms/suspend) |
| `hypr/scripts/waybar-per-monitor.py` | Hides laptop Waybar while external monitor attached; restores on unplug |
| `systemd/user/waybar-per-monitor.service` | Runs the above as a user service |
| `reapply-hyde-tweaks.sh` | Re-applies HyDE-managed bits a `hyde update` can overwrite (ws 11 hidden in Waybar modules) |

## Fresh-system install

```bash
# 1. install HyDE first
git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
cd ~/HyDE/Scripts && ./install.sh

# 2. clone + install these dotfiles
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles && ./install.sh
```

`install.sh` symlinks files into place (backing up any existing ones to
`~/.dotfiles-backup/<timestamp>/`), enables the Waybar service, and runs the
re-apply script.

## ⚠️ Monitor names are machine-specific

`eDP-1` (laptop) and `HDMI-A-1` (external) are hardcoded. On a different
machine, run `hyprctl monitors`, then update:

- `hypr/monitors.conf`
- `hypr/scripts/waybar-per-monitor.py` (`LAPTOP` / `EXTERNAL` constants)

then `systemctl --user restart waybar-per-monitor.service && hyprctl reload`.

## After a `hyde update`

```bash
~/reapply-hyde-tweaks.sh
```
