" File tree sidebar
Plug 'scrooloose/nerdtree'
  nnoremap <silent> <C-t> :NERDTreeToggle<CR>
  nnoremap <silent> <leader>nf :NERDTreeFind<CR>
  nnoremap <silent> <leader>nt :NERDTreeToggle<CR>
  let g:NERDTreeCaseSensitiveSort = 1
  let g:NERDTreeSortOrder = ['__tests__', '^index\.js', '^shared', '^[A-Z].*\.js', '\/$', '^\.']
  let g:NERDTreeShowHidden = 1
  let g:NERDTreeMinimalUI = 1
  let g:NERDTreeDirArrows = 1
  let g:NERDTreeCascadeOpenSingleChildDir = 1
  let g:NERDTreeAutoDeleteBuffer = 1
  let g:NERDTreeSortHiddenFirst = 1

" Shows git status of files in file tree
Plug 'Xuyuanp/nerdtree-git-plugin'
