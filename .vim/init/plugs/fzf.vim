" Fuzzy finder, used for file/buffer finding and project searching
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

set rtp+=~/.fzf
set rtp+=/usr/local/opt/fzf
let g:fzf_command_prefix = 'Fzf'

let $FZF_DEFAULT_OPTS='--layout=reverse --inline-info'

" Fuzzy file finding
nnoremap <silent> <C-p> :call FuzzyFindFile()<CR>
function! FuzzyFindFile(...)
  let g:fzf_layout = { 'window': 'call FloatingFZF(30, 100)' }
  :FzfGitFiles -c -o --directory
endfunction

" Search through open buffers
nnoremap <silent> <C-l> :call FuzzyBuffers()<CR>
function! FuzzyBuffers(...)
  let g:fzf_layout = { 'window': 'call FloatingFZF(20, 80)' }
  :FzfBuffers
endfunction

" Helper for creating floating centered window
function! FloatingFZF(h, w)
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = a:h
  let width = a:w
  let col = float2nr((&columns - width) / 2)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': 1,
        \ 'col': col,
        \ 'width': width,
        \ 'height': height
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction
