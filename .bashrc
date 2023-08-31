stty icrnl

source ~/.scripts/common/util.sh
source ~/.scripts/common/path.sh
source ~/.scripts/common/exports.sh
source ~/.scripts/common/aliases.sh
source ~/.scripts/bash/prompt.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
. "$HOME/.cargo/env"
