# --- envs (port of Omarchy default/bash/envs) ---

# Omarchy's EDITOR was `omarchy-launch-editor --inline`, a Linux launcher.
# On macOS, nvim directly.
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export VISUAL="$EDITOR"

# BROWSER is unset on purpose: macOS `open` already routes URLs to the default
# browser, and gh/etc. fall back to it.

export BAT_THEME=ansi

# Color man pages with bat
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export LANG="${LANG:-en_US.UTF-8}"

# Homebrew's GNU coreutils provide g-prefixed binaries; the un-prefixed gnubin
# dir is deliberately NOT added, so scripts written against BSD tools keep
# working.
