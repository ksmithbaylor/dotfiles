export EDITOR=vim
export HISTFILESIZE=10000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export ANDROID_HOME=$(brew --prefix android-sdk)

# Docker
export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/kevin/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1

if command_exists rbenv; then
    export RBENV_ROOT=/usr/local/var/rbenv
    eval "$(rbenv init - zsh)"
fi

if command_exists nodenv; then
    export NODENV_ROOT=/usr/local/var/nodenv
    eval "$(nodenv init - zsh)"
fi

if command_exists jenv; then
    export JENV_ROOT=/usr/local/opt/jenv
    eval "$(jenv init - zsh)"
fi
