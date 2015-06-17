function apply_aliases() {
    if ls --color > /dev/null 2>&1; then
        local colorflag="--color"
    else
        local colorflag="-G"
    fi

    alias l="ls -F1 $colorflag"
    alias ll="ls -AFlh $colorflag"
    alias lll="ls -aFlhrt $colorflag"
    if command_exists tree; then
        alias t="tree -ACaF --dirsfirst"
        alias t2="t -L 2"
        alias t3="t -L 3"
        alias t4="t -L 4"
    fi

    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."
    alias .....="cd ../../../.."
    alias ......="cd ../../../../.."
    alias -- -="cd -"
    alias ':q'='exit'

    alias o="open"
    alias tu="top -o cpu"
    alias tm="top -o mem"
    alias brake="bundle exec rake"
    alias st="git status"
    alias cm="git commit -m"
    alias cma="git commit -am"
    alias co="git checkout"
    alias gd="git diff"
    alias lg="git lg"
    alias push="git push"
    alias pull="git pull"
    alias up="git pull"
    alias tags="tag -l *"
    alias todo="todo.sh -d ~/dotfiles/todo-txt/todo.cfg"
    alias untagged="tags | egrep '^[a-z0-9-]* *$'"
    alias dcmp="docker-compose"
    if command_exists clipper; then
        alias clip="nc localhost 8377"
    fi
}

apply_aliases
unset apply_aliases

function mdcd() {
    mkdir -p "$1"
    cd "$1"
}

function repeatedly {
    local interval="$1" command="$2"
    while [ true ]; do
        eval "$command"
        sleep "$interval"
    done
}

function try {
    mdcd "$HOME/main/try/$1"
}

function ove() {
    ssh "tworker@$1.onyx.ove.com"
}

function _tmux_new_window() {
    tmux new-window -n "$1"
    tmux select-window -t "$1"
    tmux send-keys "$2" C-m
}

function chestnut() {
    _tmux_new_window 'Vim'          'vim'
    _tmux_new_window 'Browser REPL' '{ sleep 2; echo "(browser-repl)"; cat; } | lein repl'
    _tmux_new_window 'Server'       '{ echo "(run)"; cat; } | lein repl'
    _tmux_new_window 'LR'           'livereload resources'
    tmux select-window -t 'Vim'
    open -g 'http://localhost:10555/' -a "$(grealpath '/Applications/Google Chrome.app')"
}

function printall {
    for file in "$@"; do
        vim "+colorscheme newsprint" -c "hardcopy > $file.ps" -c "quit" "$file"
        ps2pdf "$file.ps"
        rm "$file.ps"
    done
}

function ip() {
    echo "Public: $(dig +short myip.opendns.com @resolver1.opendns.com)"
    echo "Private: $(ifconfig | grep inet | grep -v inet6 | grep -v '127.0.0.1' | awk '{print $2}')"
}

function runjava {
    local filename="$1" classname="${$(basename "$1")%.*}"
    shift
    echo "--- Compiling $filename"
    javac "$filename"
    if [ $? -eq 0 ]; then
        echo "--- Running the $classname class"
        if [ "$#" -ne 0 ]; then
            java "$classname" "$@"
        else
            java "$classname"
        fi
        rm ./*.class 2> /dev/null
    else
        echo "There were compilation issues."
    fi
}

# Print the argument in binary, grouped by 4s
function bin {
    if [[ "$1" == "-r" ]]; then
        shift
        local str=""
        for s in "$@"; do
            str="$str$s"
        done
        ruby -e "puts '$str'.to_i(2).to_s"
    else
        ruby -e "puts $1.to_s(2).reverse.scan(/.{1,4}/).map{|s|s.ljust(4,'0')}.join(' ').reverse"
    fi
}

# Print the argument in hexidecimal, grouped by bytes
function hex {
    if [[ $1 == "-r" ]]; then
        shift
        local str=""
        for s in "$@"; do
            str="$str$s"
        done
        ruby -e "puts '$str'.to_i(16).to_s"
    else
        ruby -e "puts $1.to_s(16).reverse.scan(/../).map{|s|s.ljust(2,'0')}.join(' ').reverse"
    fi
}

if command_exists highlight; then
    function hl { # Prints out a file with syntax highlighting
        # Highlight with 'moria' theme to terminal, and suppress errors
        highlight "$1" -s moria -O xterm256 2> /dev/null

        if (($? != 0)); then # If the command had errors
            cat "$1" # Just cat the file out instead
        fi
    }
fi

function timecard {
    vim -c '/\s[123456789]\s' $HOME/main/manheim/timecard
}

function gh {
    git clone "https://github.com/$1/$2.git" $3
}

function couch {
    if [[ $# -eq 0 || $1 = '--help' || $1 = '-h' ]]; then
        echo "Usage: couch [<host>] <method> <path>"
        echo "  host - location of the couchdb server, defaults to localhost:5984 if not present"
        echo "  method - HTTP method (GET, PUT, POST, DELETE, etc)"
        echo "  path - URL path after the host"
        echo "Examples:"
        echo "  couch GET /"
        echo "  couch PUT /test"
        echo "  couch cdb.example.com GET /"
    else
        if [[ $# -eq 2 ]]; then
            local host='localhost:5984'
        else
            local host=$1
            shift
        fi

        local method=$1
        local url=$2

        curl -s -X $method $host$url | underscore print --color
    fi
}

function rmswap {
    find . -name '*.swp' -exec rm {} \;
    find . -name '*.swo' -exec rm {} \;
}
