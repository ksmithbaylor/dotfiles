function! VimuxSlime()
  call VimuxSendText(@v)
  call VimuxSendKeys("Enter")
endfunction

" If text is selected, save it in the v buffer and send that buffer it to tmux
vmap <Leader>rr "vy :call VimuxSlime()<CR>

" If no text is selected, send the whole line
nmap <Leader>rr "vyy :call VimuxSlime()<CR>
