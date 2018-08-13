" Assume vim-plug is present and plugins are installed
let should_plug_install=0

" Install vim-plug if it's not already present
if empty(glob('~/.vim/autoload/plug.vim'))
  echo "Downloading vim-plug..."
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let should_plug_install = 1
endif

" Even if vim-plug is present, install plugins if they are missing
if !isdirectory($HOME."/.vim/plugged")
  let should_plug_install=1
endif

" Initialize plugins
call plug#begin('~/.vim/plugged')

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

" Smooth scrolling
Plug 'yuttie/comfortable-motion.vim'
  noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(10)<CR>
  noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-10)<CR>

" Allows toggling comments with <leader>c<space>
Plug 'scrooloose/nerdcommenter'
  let g:NERDSpaceDelims = 1

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

" Ack, used with ag
Plug 'mileszs/ack.vim'
  if executable('ag')
    let g:ackprg = 'ag --vimgrep'
  endif

" Git integration
Plug 'tpope/vim-fugitive'

Plug 'sukima/xmledit'
  let g:xmledit_enable_html=1
  function! HtmlAttribCallback( xml_tag )
  endfunction
Plug 'itchyny/lightline.vim'
  set noshowmode
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
    return s:word_count . 'w'
  endfunction
  " let g:lightline = {}
  " let g:lightline.active = {
      " \ 'left': [ [ 'mode', 'paste' ],
      " \           [ 'readonly', 'filename', 'modified' ] ],
      " \ 'right': [ [ 'lineinfo' ],
      " \            [ 'percent' ],
      " \            [ 'fileformat', 'fileencoding', 'filetype', 'wordcount' ] ] }
  " let g:lightline.inactive = {
      " \ 'left': [ [ 'filename' ] ],
      " \ 'right': [ [ 'lineinfo' ],
      " \            [ 'percent' ] ] }
  " let g:lightline.tabline = {
      " \ 'left': [ [ 'tabs' ] ],
      " \ 'right': [ [ 'close' ] ] }
  " let g:lightline.component_function = {
      " \ 'wordcount': 'WordCount',
      " \ }
Plug 'jiangmiao/auto-pairs'
  let g:AutoPairsShortcutFastWrap = '<C-W>'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-endwise'
Plug 'godlygeek/tabular'
Plug 'benmills/vimux'
  nnoremap <leader>rn :VimuxPromptCommand<CR>
  nnoremap <leader>rl :VimuxRunLastCommand<CR>
  nnoremap <leader>a :autocmd BufWritePost * :VimuxRunLastCommand<CR>
  nnoremap <leader>x :autocmd! BufWritePost *<CR>
"Plug 'ksmithbaylor/tomorrow-theme', { 'rtp': 'vim' }
Plug 'rakr/vim-one'
Plug 'lilydjwg/colorizer'

" Typescript
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
  let g:nvim_typescript#type_info_on_hold = 1
  let g:nvim_typescript#default_mappings = 1
Plug 'Shougo/deoplete.nvim'
  let g:deoplete#enable_at_startup = 1
Plug 'Shougo/denite.nvim'

" Language-specific plugins
Plug 'othree/html5.vim'
  autocmd BufNewFile,BufRead *.ejs set filetype=html
Plug 'neovimhaskell/haskell-vim', { 'for': 'haskell' }
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'pangloss/vim-javascript'
  let g:javascript_ignore_javaScriptdoc = 1
  let g:javascript_plugin_flow = 1
Plug 'mxw/vim-jsx'
  let g:jsx_ext_required = 0
Plug 'hail2u/vim-css3-syntax'
Plug 'zaiste/tmux.vim'
Plug 'elmcast/elm-vim'
  " au BufEnter,BufWritePost *.elm ElmMake
Plug 'raichoo/purescript-vim'
Plug 'elixir-lang/vim-elixir'
Plug 'rust-lang/rust.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'digitaltoad/vim-pug'
Plug 'jparise/vim-graphql'
Plug 'posva/vim-vue'
Plug 'dart-lang/dart-vim-plugin'

" Linting
Plug 'w0rp/ale'

" Plug 'benekastah/neomake'
  " let g:neomake_javascript_enabled_makers = ['eslint']
  " " load local eslint in the project root
  " " modified from https://github.com/mtscout6/syntastic-local-eslint.vim
  " let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
  " let g:neomake_javascript_eslint_exe = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
  " "let g:neomake_open_list = 2
  " nnoremap <leader>l :Neomake<CR>
  " autocmd! BufWritePost,BufEnter *.js Neomake

" Formatting
Plug 'sbdchd/neoformat'
  let g:neoformat_c_clangformat = { 'exe': 'clang-format', 'args': ['-style=Google'], 'stdin': 1 }
  let g:neoformat_enabled_c = ['clangformat']
  let g:neoformat_cpp_clangformat = g:neoformat_c_clangformat
  let g:neoformat_enabled_cpp = g:neoformat_enabled_c

Plug 'prettier/vim-prettier'
  let g:prettier#autoformat = 0

Plug 'mhinz/vim-mix-format'
  let g:mix_format_on_save = 0

Plug 'mindriot101/vim-yapf'
  let g:yapf_style = "facebook"

" Why not?
Plug 'johngrib/vim-game-code-break', { 'on': 'VimGameCodeBreak' }

" All plugins have been declared. If needed, install them and quit
call plug#end()
if should_plug_install == 1
  :echo "Installing plugins..."
  :silent! PlugInstall
  :echo "Done! Please re-launch.\n"
  :qa
endif
