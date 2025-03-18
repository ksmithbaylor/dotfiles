imap <silent><script><expr> <C-A> copilot#Accept("\<CR>")
imap <silent><script><expr> <C-Q> copilot#Clear()
nnoremap <leader><space> :noh<cr>:call copilot#Clear()<cr>
let g:copilot_no_tab_map = v:true
let g:copilot_filetypes = { 'codecompanion': v:false }
" let g:copilot_proxy = 'http://localhost:12345'
" let g:copilot_proxy_strict_ssl = v:false
