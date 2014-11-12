[ ls --color > /dev/null 2>&1 ] &&
    _colorflag="--color" ||
    _colorflag="-G"

alias l="ls -Ap ${_colorflag}"
alias ll="ls -Aplah ${_colorflag}"
alias lll="ls -Aplahrt ${_colorflag}"
if which tree > /dev/null; then
    alias t="tree -ACa --dirsfirst"
fi

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias -- -="cd -"

# Program shortcuts
alias o="open"
alias tu="top -o cpu"
alias tm="top -o vsize"
alias brake="bundle exec rake"
alias st="git status"
alias cm="git commit -m"
alias cma="git commit -am"
alias co="git checkout"
alias gd="git diff"
alias lg="git lg"
alias push="git push"
alias pull="git pull"
if which clipper > /dev/null; then
    alias clip="nc localhost 8377"
fi

function mdcd() {
    mkdir -p $1
    cd $1
}

function repeat {
    NUM="$1"
    while [ true ]; do
        eval $2;
        sleep $NUM
    done
}

function try {
    mkdir -p $HOME/main/try
    cd $HOME/main/try
    mkdir $1
    cd $1
}

function ove() {
    ssh tworker@$1.onyx.ove.com
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
    for file in $@; do
        vim "+colorscheme newsprint" -c "hardcopy > $file.ps" -c "quit" $file
        ps2pdf $file.ps
        rm $file.ps
    done

    if [ ! -z $PRINTER ]; then
        for file in $@; do
            lpr -P $PRINTER $file.pdf
            sleep 1
            rm $file.pdf
        done
    fi
}


function ip() {
    echo "Public: $(dig +short myip.opendns.com @resolver1.opendns.com)"
    echo "Private: $(ifconfig | grep inet | grep -v inet6 | grep -v '127.0.0.1' | awk '{print $2}')"
}

function trimextension {
    local BASE=$(basename "$1")
    echo "${BASE%.*}"
}

function runjava {
    local RJFILE=$1
    local RJCLASS=$(trimextension $1)
    shift
    echo "--- Compiling $RJFILE..."
    javac $RJFILE
    if [ $? -eq 0 ]; then
        echo "--- Running the $RJCLASS class"
        if [ "$#" -ne 0 ]; then
            java $RJCLASS $@
        else
            java $RJCLASS
        fi
        rm *.class 2> /dev/null
    else
        echo "There were compilation issues."
    fi
}

# Print the argument in binary, grouped by 4s
function bin {
    if [[ $1 == "-r" ]]; then
        shift
        str=""
        for s in $@; do str=$str$s; done
        ruby -e "puts '$str'.to_i(2).to_s"
    else
        ruby -e "puts $1.to_s(2).reverse.scan(/.{1,4}/).map{|s|s.ljust(4,'0')}.join(' ').reverse"
    fi
}

# Print the argument in hexidecimal, grouped by bytes
function hex {
    if [[ $1 == "-r" ]]; then
        shift
        str=""
        for s in $@; do str=$str$s; done
        ruby -e "puts '$str'.to_i(16).to_s"
    else
        ruby -e "puts $1.to_s(16).reverse.scan(/../).map{|s|s.ljust(2,'0')}.join(' ').reverse"
    fi
}

if which highlight > /dev/null; then
    function hl { # Prints out a file with syntax highlighting
        # Highlight with 'moria' theme to terminal, and suppress errors
        highlight $1 -s moria -O xterm256 2> /dev/null

        if (($? != 0)); then # If the command had errors
            cat $1 # Just cat the file out instead
        fi
    }
fi
