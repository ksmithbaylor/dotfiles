function prepend_path() {
    local command=$1 path_location=$2

    if command_exists $command; then
        export PATH=$path_location:$PATH
    fi
}

# Least important first
prepend_path true       $HOME/bin/j/bin
prepend_path cabal      $HOME/.cabal/bin
prepend_path cabal      $HOME/Library/Haskell/bin
prepend_path stack      /usr/local/stack
prepend_path stack      $HOME/.local/bin
prepend_path pdflatex   /usr/local/texlive/2016/bin/x86_64-darwin/
prepend_path nodebrew   $HOME/.nodebrew/current/bin
if command_exists yarn; then
  export PATH=$(yarn global bin):$PATH
fi
prepend_path true       $HOME/.cargo/bin
prepend_path true       $HOME/bin
prepend_path brew       /usr/local/bin
prepend_path brew       /usr/local/sbin

unset prepend_path
