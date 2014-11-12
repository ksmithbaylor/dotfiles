function _prepend_path() {
    local command=$1
    local path_location=$2

    if which $command > /dev/null; then
        export PATH=$path_location:$PATH
    fi
}

# Least important first
_prepend_path true       ~/bin
_prepend_path nodebrew   ~/.nodebrew/current/bin
_prepend_path brew       /usr/local/bin

unset _prepend_path
