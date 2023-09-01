" When highlighting all of a word, don't jump to the next one
" https://stackoverflow.com/a/49944815
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>

" Tree shortcuts
nnoremap <silent> <C-t> :NvimTreeToggle<CR>
nnoremap <silent> <leader>nf :NvimTreeFindFile<CR>
