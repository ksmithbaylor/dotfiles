Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install() }}

let g:coc_global_extensions = [
  \ 'coc-json',
  \ 'coc-css',
  \ 'coc-html',
  \ 'coc-tsserver',
  \ 'coc-tslint-plugin',
  \ 'coc-rls',
  \ 'coc-python',
  \ 'coc-highlight',
  \ 'coc-snippets'
  \ ]

map <C-]> <Plug>(coc-definition)
map <leader>? <Plug>(coc-codeaction)
map <leader>R <Plug>(coc-rename)
map <leader>F <Plug>(coc-fix-current)
" command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
