export EDITOR=nvim
export HISTFILESIZE=10000
export CLICOLOR=true
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
# is_mac && command_exists brew && command_exists android && export ANDROID_HOME=$(brew --prefix android-sdk)

if command_exists rbenv; then
    export RBENV_ROOT=/usr/local/var/rbenv
    eval "$(rbenv init -)"
fi

if command_exists nodenv; then
    export NODENV_ROOT=/usr/local/var/nodenv
    eval "$(nodenv init -)"
fi

if command_exists pair; then
  eval "$(pair --setup)"
fi

# if command_exists opam; then
  # eval $(opam config env)
# fi

# if [ -f /usr/libexec/java_home ]; then
  # export JAVA_HOME=$(/usr/libexec/java_home)
# fi
