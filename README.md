# dotfiles — `caelestia` branch

Personal customizations layered on top of a
[caelestia](https://github.com/caelestia-dots/caelestia) Hyprland setup.
These are **deltas**, not a full desktop — install caelestia first.

Kept as a reference snapshot of the CachyOS + caelestia era.
See the `hyde` branch for the previous HyDE-based setup.

## What's here

| Path | Purpose |
|------|---------|
| `caelestia/hypr-user.lua` | Monitor layout, ws→monitor bindings, `Super+W` → zen, zen opacity + JetBrains Toolbox window rules, mise PATH for GUI apps |
| `caelestia/shell.json` | Quickshell settings — idle timeouts, opaque bar, auto-hide bar, fuzzy launcher, Spotify as default player |
| `caelestia/user-config.fish` | mise activation for fish |
| `foot/foot.ini` | Terminal config. **Only delta from upstream is `font=...:size=16`** (upstream ships 12) |

## Fresh-system install

```bash
# 1. install caelestia first
git clone --depth 1 https://github.com/caelestia-dots/caelestia ~/caelestia
cd ~/caelestia && ./install.fish

# 2. clone + install these dotfiles
git clone -b caelestia git@github.com:ramprashanth1998/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

`install.sh` symlinks files into place (backing up any existing ones to
`~/.dotfiles-backup/<timestamp>/`) and reloads Hyprland.

## ⚠️ Config persistence — read before editing anything

`caelestia install` **force-overwrites** managed files under `~/.config/`
(`hypr/*`, `foot.ini`, …) from the pristine dots in
`~/.local/state/caelestia/dots`. Edits made directly to those files are lost on
every reinstall.

What survives, and how:

| Change | Where it goes | Survives reinstall? |
|---|---|---|
| Hyprland monitors / keybinds / window rules | `~/.config/caelestia/hypr-user.lua` | ✅ user dir, sourced last by `hyprland.lua` |
| Hyprland variable overrides | `~/.config/caelestia/hypr-vars.lua` | ✅ merged over `variables.lua` |
| Shell settings | `~/.config/caelestia/shell.json` | ✅ user dir |
| fish additions | `~/.config/caelestia/user-config.fish` | ✅ user dir |
| **foot font size** | `~/.config/foot/foot.ini` | ❌ **no override hook** |

For foot, either re-run `./install.sh` after each caelestia install, or skip the
component entirely:

```bash
caelestia install --disable-components foot
```

Selective installs generally: `caelestia install --disable-components LIST` /
`--enable-components LIST`.

## `hypr-user.lua` notes

Global `hl` is available in that file (`hl.monitor`, `hl.bind`,
`hl.workspace_rule`, `hl.window_rule`, `hl.on`, `hl.timer`, `hl.env`,
`hl.dsp.exec_cmd`). Reload with `hyprctl reload`.

Contains a Layout A / Layout B block for swapping which monitor sits on the
left — comment one out, uncomment the other.

The JetBrains Toolbox rule is a `window.open` event hook plus a timer: Toolbox
is XWayland and repositions *itself* off-screen (x = -440) hunting for a system
tray that doesn't exist, so a plain `center = true` rule isn't enough — it has
to be re-centered shortly after mapping.

## ⚠️ Monitor names are machine-specific

`eDP-1` (laptop) and `HDMI-A-1` (external, ASUS VG249Q3A) are hardcoded, both
`1920x1080@144`. Workspaces 1–9 are pinned to the external, ws 10 to the
built-in; Hyprland auto-falls everything onto the laptop when the external is
absent, so no extra config is needed for undocked use.

On a different machine, run `hyprctl monitors` and update
`caelestia/hypr-user.lua`, then `hyprctl reload`.
