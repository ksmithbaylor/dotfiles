export EDITOR=vim
export HISTFILESIZE=10000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

if which rbenv > /dev/null; then
    export RBENV_ROOT=/usr/local/var/rbenv
    eval "$(rbenv init -)"
fi

if which nodenv > /dev/null; then
    export NODENV_ROOT=/usr/local/var/nodenv
    eval "$(nodenv init -)"
fi
