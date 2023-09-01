" When highlighting all of a word, don't jump to the next one
" https://stackoverflow.com/a/49944815
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>

" Tree shortcuts
nnoremap <silent> <C-t> :NvimTreeToggle<CR>
nnoremap <silent> <leader>nf :NvimTreeFindFile<CR>

" Search shortcuts
nnoremap <C-p> <Cmd>Telescope find_files<CR>
nnoremap <leader>f <Cmd>Telescope live_grep<CR>
nnoremap <leader>e <Cmd>Telescope grep_string<CR>

" Quicker creation and navigation of tabs
nnoremap <leader>] :tabn<CR>
nnoremap <leader>[ :tabp<CR>
nnoremap <leader><CR> :tabnew<CR>
nnoremap <leader>{ :tabm -1<CR>
nnoremap <leader>} :tabm +1<CR>
nnoremap <leader>t :TabRename<Space>

" Splits the window vertically or horizontally and switches to the new one
nnoremap <leader>s <C-w>v<C-w>l
nnoremap <leader>h <C-w>s<C-w>j

" Buffer shortcuts, using Plug 'Asheq/close-buffers.bim'
nnoremap <silent> <leader>kt :Bdelete this<CR>
nnoremap <silent> <leader>ka :Bdelete all<CR>
nnoremap <silent> <leader>ko :Bdelete other<CR>
nnoremap <silent> <leader>kh :Bdelete hidden<CR>
nnoremap <silent> <leader>ks :Bdelete select<CR>

" Skips hooks when saving
cnoreabbrev W noau w

" Re-highlight lines in visual mode after indent
vnoremap < <gv
vnoremap > >gv

" Search by visual selection
vnoremap * y/<C-r>"<CR>N

" Enable 'line bubbling' (requires vim-unimpaired)
nmap <C-k> [e
nmap <C-j> ]e
vmap <C-k> [egv
vmap <C-j> ]egv
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi

" Make Vim handle long lines correctly
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

" Clear the current search
nnoremap <leader><space> :noh<cr>

" Clear trailing whitespace in the whole file
nnoremap <silent> <leader>ww :%s/\s\+$//<CR>:let @/=''<CR><C-o>

" Magical "newspaper-column" scrollbinding of a single file
nnoremap <silent> <leader>vs :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>

" Automatically strip trailing blank lines on all files on save
function! TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
au BufWritePre * call TrimEndLines()

" Run commands in a tmux pane
nnoremap <leader>rn :VimuxPromptCommand<CR>
nnoremap <leader>rl :VimuxRunLastCommand<CR>
nnoremap <leader>rt :VimuxRunCommand getline(".")<CR>
nnoremap <leader>a :autocmd BufWritePost * :VimuxRunLastCommand<CR>
nnoremap <leader>x :autocmd! BufWritePost *<CR>

" Send lines to a tmux pane, selected or not
function! VimuxSlime()
  call VimuxSendText(@v)
  call VimuxSendKeys("Enter")
endfunction
vmap <Leader>rr "vy :call VimuxSlime()<CR>
nmap <Leader>rr "vyy :call VimuxSlime()<CR>

" Count words in a file
function! WordCount()
  let s:old_status = v:statusmsg
  let position = getpos(".")
  exe ":silent normal g\<c-g>"
  let stat = v:statusmsg
  let s:word_count = 0
  if stat != '--No lines in buffer--'
    let s:word_count = str2nr(split(v:statusmsg)[11])
    let v:statusmsg = s:old_status
  end
  call setpos('.', position)
  echo s:word_count . 'w'
endfunction
nnoremap <leader>wc :call WordCount()<CR>

" Testing commands
nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ts :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tg :TestVisit<CR>

" Pair wrapping
let g:AutoPairsShortcutFastWrap = '<C-w>'
