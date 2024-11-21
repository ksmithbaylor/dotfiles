export EDITOR=nvim
export HISTFILESIZE=100000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export GPG_TTY=`tty`
export ERL_AFLAGS="-kernel shell_history enabled"

if command_exists cargo; then
  source "$HOME/.cargo/env"
fi
