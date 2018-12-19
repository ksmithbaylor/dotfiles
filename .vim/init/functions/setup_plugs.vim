function SetupPlugs()
  " Initialize plugins
  call plug#begin('~/.vim/plugged')

  " Load all plug declarations
  runtime! init/plugs/*.vim
  runtime! init/plugs/language_specific.vim

  " All plugins have been declared!
  call plug#end()

  " If needed, install them and quit
  if g:should_plug_install == 1
    :echo "Installing plugins..."
    :silent! PlugInstall
    :echo "Done! Please re-launch.\n"
    :qa
  endif
endfunction
