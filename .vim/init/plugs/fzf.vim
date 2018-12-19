" Fuzzy finder, used for file/buffer finding and project searching
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
  set rtp+=~/.fzf
  set rtp+=/usr/local/opt/fzf
  let g:fzf_command_prefix = 'Fzf'
  let g:fzf_layout = { 'down': '~50%' }
  " Search through open buffers
  nnoremap <C-l> :FzfBuffers<CR>
  " Folder search with preview
  nnoremap <C-s> :Ag<CR>
  command! -nargs=* Ag
    \ call fzf#vim#ag(<q-args>, fzf#vim#with_preview('right:50%', '?'))
  " Fuzzy file find with preview
  nnoremap <C-p> :FF -c -o --directory<CR>
  command! -nargs=* FF
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview('right:50%', '?'))
