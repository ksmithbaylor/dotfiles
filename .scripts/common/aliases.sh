if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

alias l="ls -F1 $colorflag"
alias ls="ls $colorflag"
alias ll="ls -AFlh $colorflag"
alias lll="ls -aFlhrt $colorflag"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias -- -="cd -"
alias ':q'='exit'
alias brake="bundle exec rake"
alias st="git status"
alias cm="git commit -m"
alias 'cm-'="git commit --amend"
alias cma="git commit -am"
alias co="git checkout"
alias gd="clear && git diff"
alias gdc="clear && git diff --cached"
alias gap="git add -p"
alias gb="git branch"
alias gba="git branch -a"
alias lg="git lg"
alias lgu="git lg @{u}.."
alias push="git push"
alias pushnew='git push -u origin $(git rev-parse --abbrev-ref HEAD)'
alias pull="git pull"
alias up="git up"
alias note="cat > /dev/null"
alias tmux="tmux -2"
alias vim="nvim"
alias b="bundle exec"
alias tls="tmux ls"
alias tn="tmux new -s"
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias pg="docker run -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres"
alias vimchanged="git status --porcelain | cut -c 4- | xargs nvim -p"
alias btc="echo \"\\\$\$(curl -s https://api.pro.coinbase.com/products/BTC-USD/ticker | jq -r .bid)\""
alias eth="echo \"\\\$\$(curl -s https://api.pro.coinbase.com/products/ETH-USD/ticker | jq -r .bid)\""
alias rosetta="env /usr/bin/arch -x86_64 /bin/zsh --login"
alias dcmp="docker-compose"
alias mux="tmuxinator start"
alias gcli="npm run -s gateway-cli --"

sand() {
  local name="$1"
  local dir="$(mktemp -d -t sand.$name)"
  cd "$dir" || return
  echo "Created and moved to sandbox directory: $dir"
  exec nvim +ClaudeCode
}

chatai() {
  echo "export OPENAI_API_KEY=\"$(pbpaste)\"" > ~/circle/.chatai_api_key
  source ~/circle/.chatai_api_key
}

replace() {
  local search="$1"
  local replace="$2"

  if [[ $(git diff --name-only) ]]; then
    echo "There are uncommitted changes in the git repo. Please stage, commit, or stash them first."
    return 1
  fi

  shift 2
  rg "${search}" -r "${replace}" "$@"

  echo
  read -s -k '?(press y to continue, any other key to cancel) '

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo
    echo replacing...
    rg "${search}" --files-with-matches | xargs sed -i '' "s/${search}/${replace}/g"
  else
    echo
    echo
    echo "Cancelled."
  fi

}

katie() {
  while read message; do
    osascript -e "tell application \"Messages\" to send \"$message\" to buddy \"Katie Smith\""
  done
}

dockspacer() {
  defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
  killall Dock
}

ta() {
  if [ $# -gt 0 ]; then
    tmux a -t $1
  else
    tmux a
  fi
}

tc() {
  tmux new -t $1 -s $1-
}

td() {
  for session in $(tmux list-sessions -F '#{session_name}' | grep $1 | grep -e '-$'); do
    tmux kill-session -t $session
  done
}

if is_mac; then
    alias tu="top -o cpu"
    alias tm="top -o mem"

    command_exists open && alias o="open"
    command_exists reattach-to-user-namespace && alias open="reattach-to-user-namespace open"
else
    alias tu="top -o %CPU"
    alias tm="top -o %MEM"
fi

if command_exists tree; then
    alias t="tree -ACaF --dirsfirst"
    alias t2="t -L 2"
    alias t3="t -L 3"
    alias t4="t -L 4"
fi

function mdcd {
    mkdir -p "$1"
    cd "$1"
}

# Colorized man pages from https://gist.github.com/cocoalabs/2fb7dc2199b0d4bf160364b8e557eb66
function man {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
      man "$@"
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

if command_exists tmuxinator; then
  alias gitmonitor="tmuxinator start gitmonitor"
fi

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

if command_exists highlight; then
    function hl { # Prints out a file with syntax highlighting
        # Highlight with 'moria' theme to terminal, and suppress errors
        highlight "$1" -s moria -O xterm256 2> /dev/null

        if (($? != 0)); then # If the command had errors
            cat "$1" # Just cat the file out instead
        fi
    }
fi

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

function runc {
    local filename=$1
    local exe=${filename%.c}
    local args=($(cat $filename | grep '@ARGS' | head -n1 | sed 's/\/\/ @ARGS //'))
    local compilation=$(cat $filename | grep '@COMPILE' | head -n1 | sed 's/\/\/ @COMPILE //')

    if [[ -z $compilation ]]; then
        cc -std=c99 -Werror -Wall $filename -o $exe && ./$exe $args
    else
        eval "$compilation $filename -o $exe" && ./$exe $args
    fi
}

export MARKPATH=$HOME/.marks
function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

function mark {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark {
    rm -i "$MARKPATH/$1"
}

if is_mac; then
    function marks {
        ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-15s -> %s\n", $1, $2}'
    }
else
    function marks {
        ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
    }
fi
