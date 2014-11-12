function command_exists() {
    command -v "$1" > /dev/null
}

function _pretty_print_time() {
    local h=$1 m=$2 s=$3 ms=$4

    [ $h -gt 0 ] && printf "%d:%02d:%02d.%03d h\n" $h $m $s $ms && return
    [ $m -gt 0 ] && printf "%d:%02d.%03d m\n" $m $s $ms && return
    [ $s -gt 0 ] && printf "%d.%03d s\n" $s $ms && return
    printf "%d ms\n" $ms
}

autoload colors && colors
for COLOR in Red Green Yellow Blue Magenta Cyan Black White Orange; do
    eval _$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
done
eval _Reset='%{$reset_color%}'
