function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    if has('nvim')
      !cargo build --release
    else
      !cargo build --release --no-default-features --features json-rpc
    endif
  endif
endfunction

Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }
" let g:markdown_composer_open_browser=0
" let g:markdown_composer_autostart=0

Plug 'tpope/vim-markdown'
let g:markdown_fenced_languages = ['css', 'javascript', 'js=javascript', 'typescript']
