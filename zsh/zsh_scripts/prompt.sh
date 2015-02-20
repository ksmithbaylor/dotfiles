_start_timer () {
    export _start="$(gdate +%s%3N)"
    export _timer_is_active=1
}

_stop_timer () {
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

_prompt () {
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
