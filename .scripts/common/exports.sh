export EDITOR=nvim
export HISTFILESIZE=100000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export GPG_TTY=`tty`
export ERL_AFLAGS="-kernel shell_history enabled"

if command_exists rbenv; then
    export RBENV_ROOT=/usr/local/var/rbenv
    eval "$(rbenv init -)"
fi

if command_exists nodenv; then
    export NODENV_ROOT=/usr/local/var/nodenv
    eval "$(nodenv init -)"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command_exists pyenv; then
    eval "$(pyenv init -)"
fi
