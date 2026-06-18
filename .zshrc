source ~/.scripts/zsh/prompt.sh
source ~/.scripts/zsh/completions.sh
source ~/.scripts/zsh/keys.sh
source ~/.scripts/zsh/history.sh
source ~/.scripts/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.scripts/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/circle/.chatai_api_key ] && source ~/circle/.chatai_api_key

# wt — git worktree manager.  rbenv-style: the `wt` binary works everywhere
# (in scripts, use `cd "$(wt path <branch>)"`); this only adds the interactive
# auto-cd wrapper.  Lives in .zshrc (not .zshenv) so the `wt` subprocess never
# re-sources it.  No-op if `wt` isn't installed.
command_exists wt && eval "$(wt shell-init)"

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

export PATH="$HOME/.local/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/kevin.smith/.bun/_bun" ] && source "/Users/kevin.smith/.bun/_bun"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/google-cloud-sdk/path.zsh.inc' ]; then . '/usr/local/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/google-cloud-sdk/completion.zsh.inc' ]; then . '/usr/local/google-cloud-sdk/completion.zsh.inc'; fi
