Plug 'benmills/vimux'
nnoremap <leader>rn :VimuxPromptCommand<CR>
nnoremap <leader>rl :VimuxRunLastCommand<CR>
nnoremap <leader>rt :VimuxRunCommand getline(".")<CR>
nnoremap <leader>a :autocmd BufWritePost * :VimuxRunLastCommand<CR>
nnoremap <leader>x :autocmd! BufWritePost *<CR>
