autocmd FileType solidity call Solidity_settings()

function! Solidity_settings() abort
  setlocal shiftwidth=4
  setlocal tabstop=4
  setlocal softtabstop=4
  setlocal expandtab
  setlocal textwidth=0
  setlocal wrapmargin=0
endfunction
