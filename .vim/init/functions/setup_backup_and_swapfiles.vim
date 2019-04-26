" Put backup and swap files in a central location
function! SetupBackupAndSwapfiles()
  silent !mkdir -p $HOME/.vim/swapfiles > /dev/null 2>&1
  silent !mkdir -p $HOME/.vim/backup > /dev/null 2>&1
  set directory=$HOME/.vim/swapfiles//
  set backupdir=$HOME/.vim/backup//
endfunction
