function prepend_path() {
    local command=$1 path_location=$2

    if command_exists $command; then
        export PATH=$path_location:$PATH
    fi
}

# Least important first
prepend_path true       $HOME/bin/j/bin
prepend_path true       $HOME/bin
prepend_path nodebrew   $HOME/.nodebrew/current/bin
prepend_path brew       /usr/local/bin

unset prepend_path
