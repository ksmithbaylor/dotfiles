function command_exists() {
    command -v "$1" > /dev/null
}

function is_mac() {
    [[ $(uname) == "Darwin" ]] && return 0
}

function is_linux() {
    [[ $(uname) == "Linux" ]] && return 0
}
