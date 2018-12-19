" Clear trailing whitespace in the whole file
nnoremap <silent> <leader>ww :%s/\s\+$//<CR>:let @/=''<CR><C-o>
