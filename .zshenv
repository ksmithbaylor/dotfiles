if [[ $PROFILE_STARTUP = true ]]; then
  exec 3>&2 2> >(tee /tmp/sample-time.log |
                   sed -u 's/^.*$/now/' |
                   gdate -f - +%s.%N >/tmp/sample-time.tim)

  set -x
fi

source ~/.scripts/common/util.sh
source ~/.scripts/common/path.sh
source ~/.scripts/common/exports.sh
source ~/.scripts/common/aliases.sh

if [[ -v IN_NEOVIM ]]; then
  export PATH=$HOME/.local/share/mise/shims:$PATH
else
  eval "$(mise activate zsh)"
fi

[ -f ~/circle/.circlerc ] && source ~/circle/.circlerc
