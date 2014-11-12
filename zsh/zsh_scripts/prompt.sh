_start_timer () {
    export _start="$(gdate +%s%3N)"
    export _timer_is_active=1
}

_stop_timer () {
    export _previous=$?
    local time_difference h m s ms

    if [[ $_timer_is_active == 1 ]]; then
        local _end=$(gdate +%s%3N)
        (( time_difference = $_end - $_start ))
        (( ms = $time_difference % 1000 ))
        (( s = $time_difference / 1000 ))
        (( m = s / 60 ))
        (( h = m / 60 ))
        export _pretty_duration="$(_pretty_print_time $h $m $s $ms)"
    else
        export _pretty_duration='0 ms'
    fi

    export _timer_is_active=0
}

_prompt () {
    local pwd_length_limit=14
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
