export EDITOR=nvim
export HISTFILESIZE=100000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export GPG_TTY=`tty`

# Android Studio / React Native
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# is_mac && command_exists brew && command_exists android && export ANDROID_HOME=$(brew --prefix android-sdk)

# if command_exists rbenv; then
    # export RBENV_ROOT=/usr/local/var/rbenv
    # eval "$(rbenv init -)"
# fi

if command_exists nodenv; then
    export NODENV_ROOT=/usr/local/var/nodenv
    eval "$(nodenv init -)"
fi

if command_exists pair; then
  pair() {
    if gem list -i pair-up 2>/dev/null 1>/dev/null; then
      command pair "$@"
      if [[ -s "$HOME/.pair-up_export_authors" ]] ; then source "$HOME/.pair-up_export_authors" ; fi
    else
      echo "You do not have pair-up installed for your current ruby version."
      echo "Please run $> gem install pair-up"
    fi
  }
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# if command_exists opam; then
  # eval $(opam config env)
# fi

# if [ -f /usr/libexec/java_home ]; then
  # export JAVA_HOME=$(/usr/libexec/java_home)
# fi
