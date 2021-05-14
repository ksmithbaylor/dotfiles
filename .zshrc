# PS4=$'+ %D{%s.%6.}\011 '
# exec 3>&2 2>/tmp/zshstart.$$.log

if [[ $PROFILE_STARTUP = true ]]; then
  exec 3>&2 2> >(tee /tmp/sample-time.log |
                   gsed -u 's/^.*$/now/' |
                   gdate -f - +%s.%N >/tmp/sample-time.tim)

  set -x
fi

source ~/.scripts/common/util.sh
source ~/.scripts/common/path.sh
source ~/.scripts/common/exports.sh
source ~/.scripts/common/aliases.sh
source ~/.scripts/zsh/prompt.sh
source ~/.scripts/zsh/completions.sh
source ~/.scripts/zsh/keys.sh
source ~/.scripts/zsh/history.sh
source ~/.scripts/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.scripts/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/coinbase/.coinbaserc ] && source ~/coinbase/.coinbaserc

if [[ $PROFILE_STARTUP = true ]]; then
  set +x
  exec 2>&3 3>&-

  paste <(
    while read tim ; do
      crt=000000000$((${tim//.}-10#0$last))
      printf "%12.9f\n" ${crt:0:${#crt}-9}.${crt:${#crt}-9}
      last=${tim//.}
    done < /tmp/sample-time.tim
  ) /tmp/sample-time.log | sort -rn | less
fi
