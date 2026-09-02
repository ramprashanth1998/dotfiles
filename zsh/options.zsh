# --- zsh behavior ---
#
# fish gives all of this for free; zsh needs it spelled out. These are the
# settings that make zsh feel like the fish prompt you're coming from.

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY          # timestamp each entry
setopt INC_APPEND_HISTORY        # write as you go, not just on exit
setopt SHARE_HISTORY             # new shells see other shells' history
setopt HIST_IGNORE_ALL_DUPS      # keep only the most recent copy of a command
setopt HIST_IGNORE_SPACE         # leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! into the line instead of running it

# Navigation
setopt AUTO_CD                   # `foo` cds into ./foo
setopt AUTO_PUSHD                # every cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Globbing / misc
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS      # allow `# comment` at the prompt

# Completion
autoload -Uz compinit
# Refresh the dump at most once a day; compinit's full security check on every
# shell start is the usual cause of slow zsh startup.
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:descriptions' format '%F{blue}%d%f'
zstyle ':completion:*' group-name ''

# Edit the current command line in $EDITOR with Ctrl-X Ctrl-E (fish's Alt-E)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
