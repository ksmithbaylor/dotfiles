function prepend_path() {
    local command=$1 path_location=$2

    if command_exists $command; then
        export PATH=$path_location:$PATH
    fi
}

# Least important first
prepend_path true       $HOME/main/tst/code/compose-services/bin
prepend_path true       $HOME/bin/j/bin
prepend_path cabal      $HOME/.cabal/bin
prepend_path cabal      $HOME/Library/Haskell/bin
prepend_path stack      /usr/local/stack
prepend_path stack      $HOME/.local/bin
prepend_path true       /Library/TeX/texbin
prepend_path true       /usr/local/mysql/bin
prepend_path nodebrew   $HOME/.nodebrew/current/bin
prepend_path cargo      $HOME/.cargo/bin
prepend_path brew       /usr/local/bin
prepend_path brew       /usr/local/sbin
prepend_path true       $HOME/bin
prepend_path rvm        $HOME/.rvm/bin
prepend_path rbenv      /usr/local/var/rbenv/shims

if command_exists cargo; then
  source "$HOME/.cargo/env"
fi

unset prepend_path
