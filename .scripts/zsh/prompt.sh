source $HOME/.scripts/zsh/git_prompt_string.sh

autoload colors && colors
for COLOR in Red Green Yellow Blue Magenta Cyan Black White Orange; do
    eval _$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
    eval _Bold_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
eval _Reset='%{$reset_color%}'

if is_mac; then
    if command_exists gdate; then
        _DATE_COMMAND="gdate"
    else
        echo "Please run \`brew install coreutils\`"
    fi
else
    _DATE_COMMAND=date
fi

function _pretty_print_time() {
    local d=$1 h=$2 m=$3 s=$4 ms=$5 d2='%02d' d3='%03d'

    [ $d -gt 0 ] && printf "%d d, $d2:$d2:$d2.$d3 h\n" $d $h $m $s $ms && return
    [ $h -gt 0 ] && printf "%d:$d2:$d2.$d3 h\n"           $h $m $s $ms && return
    [ $m -gt 0 ] && printf "%d:$d2.$d3 m\n"                  $m $s $ms && return
    [ $s -gt 0 ] && printf "%d.$d3 s\n"                         $s $ms && return
    printf "%d ms\n" $ms
}

function _start_timer {
    export _start="$($_DATE_COMMAND +%s%3N)"
    export _timer_is_active=1
}

function _stop_timer {
    export _previous=$?
    local duration ms s m h d

    if [[ $_timer_is_active == 1 ]]; then
        local end=$($_DATE_COMMAND +%s%3N)
        (( duration = end - _start ))
    else
        (( duration = 0 ))
    fi

    (( ms = duration % 1000 ))
    (( s = duration / 1000 % 60 ))
    (( m = duration / 60000 % 60 ))
    (( h = duration / 3600000 % 24 ))
    (( d = duration / 86400000 ))

    export _pretty_duration="$(_pretty_print_time $d $h $m $s $ms)"
    export _timer_is_active=0
}

function _prompt {
    echo -ne "\e]1;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\a"
    local pwd_length_limit=20
    if command_exists tico; then
      local directory=$(tico $(print -D $PWD))
    else
      local directory=$(pwd | sed -e "s|$HOME|~|" |
                  perl -pe "s|(~?/[^/]+/).{$pwd_length_limit,}(/[^/]+/?\$)|\$1...\$2|")
    fi
    local gitstatus=$(git_prompt_string)

    [ $_previous -eq 0 ] &&
        local status_color=${_Green} previous_status="" ||
        local status_color=${_Red} previous_status="[$_previous] 😭  "

    PROMPT=$'${_Blue}╭$(printf "%$(($(tput cols) - 1))s" | tr " " "─")\n'
    PROMPT+="${_Blue}│ "
    PROMPT+="${_Yellow}%D{%r}"
    PROMPT+="${_Bold_Black} │ "
    PROMPT+="${_Cyan}$_pretty_duration ⤴ "
    PROMPT+="${_Bold_Black} │"
    if [ -f .ruby-version ] && command_exists rvm-prompt; then
      PROMPT+="${_Bold_Red}"
      PROMPT+=" ($(rvm-prompt))"
      PROMPT+="${_Reset}"
    fi
    if [ ! -z $gitstatus ]; then
      PROMPT+="${_Reset} "
      PROMPT+=$gitstatus
      PROMPT+="${_Reset}"
    else
      PROMPT+=" "
    fi
    PROMPT+="${status_color}%U$directory%u "
    PROMPT+="$previous_status"
    PROMPT+=$'\n${_Blue}╰─▶ '
    PROMPT+="${_Reset}"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _start_timer
add-zsh-hook precmd _stop_timer
add-zsh-hook precmd _prompt
