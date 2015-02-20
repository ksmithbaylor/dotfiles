export EDITOR=vim
export HISTFILESIZE=10000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export ANDROID_HOME=$(brew --prefix android-sdk)

if command_exists rbenv; then
    export RBENV_ROOT=/usr/local/var/rbenv
    eval "$(rbenv init - zsh)"
fi

if command_exists nodenv; then
    export NODENV_ROOT=/usr/local/var/nodenv
    eval "$(nodenv init - zsh)"
fi
