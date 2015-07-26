
if is_mac; then
    if command_exists gfind; then
        _FIND_COMMAND=gfind
    else
        echo "Please run \`brew install coreutils\`"
    fi
else
    _FIND_COMMAND=find
fi

_completemarks() {
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$($_FIND_COMMAND $MARKPATH -type l -printf "%f\n")
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
  return 0
}

complete -F _completemarks jump unmark
