function prepend_path() {
    local command=$1 path_location=$2

    if command_exists $command; then
        export PATH=$path_location:$PATH
    fi
}

# path_helper is returning nonsense for some reason, do it manually
PATH=$(echo $(cat /etc/paths && cat /etc/paths.d/*) | cat | sed 's/ /:/g')

# Least important first
prepend_path true /opt/homebrew/sbin
prepend_path true /opt/homebrew/bin
prepend_path true $HOME/.cargo/bin
prepend_path true $HOME/.foundry/bin
prepend_path true $HOME/bin

eval "$(mise activate zsh)"

export PATH
unset prepend_path
