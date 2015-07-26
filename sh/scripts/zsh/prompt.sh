autoload colors && colors
for COLOR in Red Green Yellow Blue Magenta Cyan Black White Orange; do
    eval _$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
done
eval _Reset='%{$reset_color%}'

function _pretty_print_time() {
    local d=$1 h=$2 m=$3 s=$4 ms=$5 d2='%02d' d3='%03d'

    [ $d -gt 0 ] && printf "%d d, $d2:$d2:$d2.$d3 h\n" $d $h $m $s $ms && return
    [ $h -gt 0 ] && printf "%d:$d2:$d2.$d3 h\n"           $h $m $s $ms && return
    [ $m -gt 0 ] && printf "%d:$d2.$d3 m\n"                  $m $s $ms && return
    [ $s -gt 0 ] && printf "%d.$d3 s\n"                         $s $ms && return
    printf "%d ms\n" $ms
}

function _start_timer {
    export _start="$(gdate +%s%3N)"
    export _timer_is_active=1
}

function _stop_timer {
    export _previous=$?
    local duration ms s m h d

    if [[ $_timer_is_active == 1 ]]; then
        local end=$(gdate +%s%3N)
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
    local pwd_length_limit=20
    local directory=$(pwd | sed -e "s|$HOME|~|" |
                perl -pe "s|(~?/[^/]+/).{$pwd_length_limit,}(/[^/]+/?\$)|\$1...\$2|")

    [ $_previous -eq 0 ] &&
        local status_color=${_Green} previous_status='' ||
        local status_color=${_Red} previous_status="($_previous) "

    PROMPT=''
    PROMPT+="${_Yellow}["
    PROMPT+="${_Yellow}%* "
    PROMPT+="${_Yellow}/ "
    PROMPT+="${_Cyan}$_pretty_duration"
    PROMPT+="${_Yellow}] "
    PROMPT+="${status_color}$directory "
    PROMPT+="$previous_status\$ "
    PROMPT+="${_Reset}"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _start_timer
add-zsh-hook precmd _stop_timer
add-zsh-hook precmd _prompt
