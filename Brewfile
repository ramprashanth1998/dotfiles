# brew bundle --file=~/dotfiles/Brewfile
#
# Not here on purpose:
#   git      -- comes with the Xcode Command Line Tools
#   uv       -- installed separately, into ~/.local/bin
#   claude   -- managed by mise (config/mise/config.toml)
#   gh       -- managed by mise

# --- terminal ---
cask "ghostty"

# --- shell ---
brew "starship"         # prompt
brew "mise"             # runtime/tool manager
brew "zoxide"           # smarter cd
brew "fzf"
brew "eza"              # ls replacement
brew "bat"              # cat/man pager
brew "fd"
brew "ripgrep"
brew "jq"
brew "gum"              # used by the gd worktree function
brew "coreutils"        # g-prefixed GNU tools when a script needs them
brew "fswatch"          # rsw's file watcher (replaces inotify-tools)
brew "rsync"            # macOS ships an ancient rsync

# fish-like interactivity for zsh
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-history-substring-search"

# --- editor / dev ---
brew "neovim"
brew "lazygit"
brew "lazydocker"
brew "btop"

# --- fonts ---
cask "font-caskaydia-mono-nerd-font"

# Not in Homebrew: try -> https://github.com/tobi/try (see the `try` init in
# zsh/init.zsh; drop that block if you don't install it).
