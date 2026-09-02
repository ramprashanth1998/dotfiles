# dotfiles (macOS / zsh)

A trimmed port of my Linux setup — Omarchy + Hyprland + fish — to a Mac
running zsh. Hyprland is gone, and so is most of what Omarchy shipped by
default; what's left is the part I actually use.

```sh
git clone <this repo> ~/dotfiles
~/dotfiles/install.sh
```

## Assumed already installed

`install.sh` does not install these and will not fight them:

- **Homebrew**
- **Xcode Command Line Tools** — provides `git`, so Homebrew's `git` is not in
  the Brewfile. Apple's is new enough for everything in `config/git/config`.
- **uv** (`~/.local/bin`). Already on PATH via `zprofile`; nothing to configure.

Claude Code is managed by **mise**, not by the curl installer. If a
curl-installed copy is still around, remove `~/.local/bin/claude` — `zprofile`
puts mise's shims ahead of `~/.local/bin`, so the mise copy wins on PATH either
way, but leaving both means two things trying to self-update.

## Layout

```
zsh/
  zprofile        login shell: brew shellenv, PATH
  zshrc           interactive entry point, sources the rest
  envs.zsh        EDITOR, BAT_THEME, MANPAGER
  options.zsh     history, completion, keybindings (fish parity)
  aliases.zsh     ls/eza, .., tools, git
  functions.zsh   autoloads zsh/functions/*
  functions/      one file per function, mirroring ~/.config/fish/functions/
  init.zsh        mise, starship, zoxide, fzf, try + zsh plugins
config/           symlinked into ~/.config
  ghostty/ git/ nvim/ mise/ btop/ starship.toml
Brewfile
```

Machine-local stuff (work tokens, one-off PATH entries) goes in
`~/.zshrc.local`, which is sourced last and never committed.

## fish → zsh

The fish config was itself a hand port of Omarchy's `default/bash/{envs,
aliases,functions,init}`, so the same file split is kept here.

Surviving functions, each autoloaded from `zsh/functions/`:

| | |
|---|---|
| `n` | nvim, defaulting to `.` |
| `compress` / `decompress` | tar+gzip |
| `ga` / `gd` | create / remove a git worktree + branch |
| `rsw` / `lsw` / `dsw` | rsync-on-change watcher, list, stop |
| `fip` / `dip` / `lip` | SSH port forwards: start, stop, list |
| `ssh` + `_ssh_disarm` / `_ssh_interactive` | terminal cleanup and auto-reconnect on a dropped SSH session |

zsh has none of fish's interactive behavior built in, so `init.zsh` pulls in
`zsh-autosuggestions`, `zsh-syntax-highlighting`, and
`zsh-history-substring-search` (bound to ↑/↓), and `options.zsh` sets up
shared/deduped history, `AUTO_CD`, and case-insensitive completion.

## What changed on the way over

| Thing | Linux | macOS |
|---|---|---|
| `EDITOR` | `omarchy-launch-editor --inline` | `nvim` |
| `open` | `xdg-open` wrapper function | native `open`, no wrapper |
| Clipboard (nvim) | `wl-copy`/`wl-paste`, tmux + herdr + SSH | OSC 52, SSH only |
| Terminal theme | `~/.local/state/omarchy/current/theme/*` | tokyonight, pinned inline |
| Git credentials | `git-credential-libsecret` | `osxkeychain` |
| `rsw` watcher | `inotifywait` + `setsid` | `fswatch` + disowned job, PIDs in `~/.local/state/rsw` |
| `lsw` / `lip` | `pgrep -af` | `pgrep` + `ps` (macOS `pgrep` has no `-a`) |
| Meta key | Alt sends Meta | `macos-option-as-alt = left` |
| Copy/paste keys | Shift/Ctrl-Insert | native Cmd-C/Cmd-V |
| Font size | 11 | 14 (Retina) |

Ghostty keeps the Shift-Enter / Alt-Shift-Enter CSI-u bindings from the Linux
config — TUIs like Claude Code use Shift-Enter for a literal newline.

## Deliberately dropped

- **Everything Hyprland**: `~/.config/hypr`, waybar, the Omarchy theme system,
  `~/.config/environment.d`, `xdg-terminals.list`, autostart.
- **tmux** and **herdr**, with their layout functions (`tdl`/`tds`/`tdlm`/`tsl`,
  `hdl`/`hds`/`hdlm`/`hsl`) and the `t`, `h`, `ic`, `ix`, `icx` aliases.
- **alacritty** and **kitty** — Ghostty is the only terminal here.
- **zed**, **opencode** (and its `c` alias), **codex** (and its `cy` alias).
- **1Password**: the SSH agent config and all commit/tag signing
  (`commit.gpgsign`, `gpg.format = ssh`, `op-ssh-sign`).
- **mise runtimes**: `bun`, `codex`, `dotnet`, `go`, `node`, `python`.
  mise now manages `claude` and `gh`.
- **`iso2sd` and `format-drive`** — built on `lsblk`/`parted`/`mkfs.exfat` and
  `omarchy-drive-select`. The macOS equivalent is `diskutil`.
- **`~/.XCompose`** — X11 only. Closest macOS equivalents are System Settings →
  Keyboard → Text Replacements, or Karabiner-Elements.
- **nvim `all-themes.lua` / `omarchy-theme-hotreload.lua`** — both existed only
  to hot-swap colorschemes when Omarchy changed the system theme. `theme.lua`
  (tokyonight-night) and `transparency.lua` are kept.

## Notes

- `config/nvim/lazy-lock.json` is committed, so plugin versions match the Linux
  box. It still lists the dropped theme plugins; `:Lazy clean` prunes them.
- `jq` is still in the Brewfile even though its only callers here (the herdr
  layout functions) are gone — it's generally useful, drop it if you disagree.
