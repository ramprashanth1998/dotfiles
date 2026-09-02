#!/usr/bin/env bash
# Symlink this repo into place on a fresh Mac and install the packages it needs.
#
#   git clone <this repo> ~/dotfiles && ~/dotfiles/install.sh
#
# Re-running is safe: existing real files are backed up to <name>.bak once,
# and symlinks are refreshed in place.
#
# Assumes Homebrew, the Xcode Command Line Tools (for git), uv, and the
# curl-installed Claude Code are already present.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1" dest="$HOME/$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    :  # existing symlink, just repoint it
  elif [[ -e "$dest" ]]; then
    if [[ -e "$dest.bak" ]]; then
      echo "  skip  $2 (real file present, $2.bak already exists)"
      return
    fi
    mv "$dest" "$dest.bak"
    echo "  moved $2 -> $2.bak"
  fi

  ln -sfn "$src" "$dest"
  echo "  link  $2"
}

echo "==> Homebrew packages"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found on PATH. Install it first: https://brew.sh" >&2
  exit 1
fi
brew bundle --file="$DOTFILES/Brewfile"

echo "==> Symlinks"
link zsh/zshrc                .zshrc
link zsh/zprofile             .zprofile
link config/starship.toml     .config/starship.toml
link config/git/config        .config/git/config
link config/ghostty/config    .config/ghostty/config
link config/nvim              .config/nvim
link config/mise/config.toml  .config/mise/config.toml
link config/btop/btop.conf    .config/btop/btop.conf

echo "==> mise"
mise install

cat <<'NOTE'

==> Manual steps left
  1. Set Ghostty as the default terminal, and check that Option-as-Meta feels
     right (config/ghostty/config: macos-option-as-alt = left).
  2. Open nvim once to let lazy.nvim sync plugins against lazy-lock.json.
  3. Optional: `try` (github.com/tobi/try) -- zsh/init.zsh sets it up lazily
     and skips it silently if absent.
NOTE
