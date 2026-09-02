# --- tool init (port of Omarchy default/bash/init) ---

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if [[ ${TERM:-} != "dumb" ]] && command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"

  # Same cd override as the fish config: plain cd for real directories,
  # zoxide's jump for everything else, printing where it landed.
  cd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi
      printf "\U000F17A9 "
      pwd
    fi
  }
fi

if command -v fzf &>/dev/null; then
  # fzf >= 0.48 ships its own shell integration (Ctrl-T, Ctrl-R, Alt-C).
  eval "$(fzf --zsh)"
fi

if command -v try &>/dev/null; then
  # try's init is slow enough to notice at every prompt, so defer it: the first
  # `try` call replaces this stub with the real thing.
  try() {
    unfunction try
    eval "$(SHELL=$(command -v zsh) command try init ~/Work/tries)"
    try "$@"
  }
fi

# --- fish-like interactive extras (from Homebrew) ---
# These are what make zsh feel like the fish shell you're leaving behind.
_zsh_plugin_dir="$(brew --prefix 2>/dev/null)/share"

# Inline suggestion of the rest of the command from history, accept with →
if [[ -r "$_zsh_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$_zsh_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# Up/Down search history for lines matching what's already typed (fish default)
if [[ -r "$_zsh_plugin_dir/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
  source "$_zsh_plugin_dir/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

# Red/green command validity as you type. Must be sourced last.
if [[ -r "$_zsh_plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$_zsh_plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _zsh_plugin_dir

# gh completions (gh comes from mise, so it isn't in brew's completion path)
if command -v gh &>/dev/null; then
  eval "$(gh completion -s zsh)"
fi
