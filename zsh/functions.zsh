# Autoload every file in zsh/functions as a function of the same name --
# the zsh equivalent of fish's ~/.config/fish/functions/ directory.
fpath=("$DOTFILES/zsh/functions" $fpath)
for _fn in "$DOTFILES"/zsh/functions/*(N:t); do
  autoload -Uz "$_fn"
done
unset _fn
