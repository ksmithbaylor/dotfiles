_prompt () {
    local previous=$?
    local Red='\e[0;31m'
    local Green='\e[0;32m'
    local Yellow='\e[0;33m'
    local Reset='\e[0m'
    local PwdLimit=14
    local Dir=$(pwd |
                sed -e "s|$HOME|~|" |
                perl -pe "s|(~?/[^/]+/).{$PwdLimit,}(/[^/]+/?\$)|\$1...\$2|")

    if [ $previous -eq 0 ]; then
        local Color=$Green
    else
        local Color=$Red
    fi

    PS1="$Yellow[\T] $Color$Dir \$ $Reset"
}

PROMPT_COMMAND=_prompt
