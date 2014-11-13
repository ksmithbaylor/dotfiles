function command_exists() {
    command -v "$1" > /dev/null
}

function _pretty_print_time() {
    local d=$1 h=$2 m=$3 s=$4 ms=$5 d2='%02d' d3='%03d'

    [ $d  -gt 0 ] && printf "%d d, $d2:$d2:$d2.$d3 h\n" $d $h $m $s $ms && return
    [ $h  -gt 0 ] && printf "%d:$d2:$d2.$d3 h\n"           $h $m $s $ms && return
    [ $m  -gt 0 ] && printf "%d:$d2.$d3 m\n"                  $m $s $ms && return
    [ $s  -gt 0 ] && printf "%d.$d3 s\n"                         $s $ms && return
    printf "%d ms\n" $ms
}

autoload colors && colors
for COLOR in Red Green Yellow Blue Magenta Cyan Black White Orange; do
    eval _$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
done
eval _Reset='%{$reset_color%}'

bindkey -e
