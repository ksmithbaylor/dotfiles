function EnsureVimPlugInstalled()
  " Assume vim-plug is present and plugins are installed
  let g:should_plug_install = 0
  
  " Install vim-plug if it's not already present
  if empty(glob('~/.vim/autoload/plug.vim'))
    echo "Downloading vim-plug..."
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    let g:should_plug_install = 1
  endif
  
  " Even if vim-plug is present, install plugins if they are missing
  if !isdirectory($HOME."/.vim/plugged")
    echo "Plugin directory not present"
    let g:should_plug_install = 1
  endif

  if g:should_plug_install
    echo "Will run :PlugInstall"
  endif
endfunction
