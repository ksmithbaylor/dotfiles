set encoding=utf-8

" Get rid of vi-era compatibility, we are better than that.
set nocompatible

" Backup and swap files in a central location
silent !mkdir -p $HOME/.vim/swapfiles > /dev/null 2>&1
silent !mkdir -p $HOME/.vim/backup > /dev/null 2>&1
set directory=$HOME/.vim/swapfiles//
set backupdir=$HOME/.vim/backup//

" Initialize Vundle and load plugins (plugin manager)
" If vundle is not installed, do it first
let should_plugin_install=0
if !filereadable($HOME."/.vim/bundle/Vundle.vim/README.md")
  silent !mkdir -p $HOME/.vim/bundle
  silent !git clone https://github.com/gmarik/Vundle.vim $HOME/.vim/bundle/Vundle.vim > /dev/null 2>&1
  let should_plugin_install=1
endif

filetype off " Needed to initialize Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

" ----------------------------- BEGIN PLUGIN LIST ------------------------------

" Directory tree popover, use CTRL-E to toggle
Plugin 'scrooloose/nerdtree'
nmap <C-e> :NERDTreeToggle<CR>
map <silent> <leader>nf :NERDTreeFind<CR>
let g:NERDTreeCaseSensitiveSort = 1
let g:NERDTreeSortOrder = ['__tests__', '^index\.js', '^shared', '^[A-Z].*\.js', '\/$', '^\.']
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeCascadeOpenSingleChildDir = 1
let g:NERDTreeAutoDeleteBuffer = 1
"let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeSortHiddenFirst = 1

" Convenience menu for switching buffers
Plugin 'jlanzarotta/bufexplorer'

" Commenter, (leader)c<space> to (un)comment
Plugin 'scrooloose/nerdcommenter'

" Fuzzy-finds a file in the current directory and subdirectories
"Plugin 'kien/ctrlp.vim'
"set wildignore+=*/node_modules/**
"let g:ctrlp_show_hidden=1
"let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:50'
"let g:ctrlp_user_command = {
      "\ 'types': {
      "\ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']
      "\ },
      "\ 'fallback': 'find %s -type f'
      "\ }

Plugin 'junegunn/fzf.vim'
set rtp+=~/.fzf
let g:fzf_command_prefix = 'Fzf'
let g:fzf_layout = { 'down': '~40%' }
nnoremap <C-p> :FzfGitFiles<CR>
nnoremap <C-s> :FzfAg<CR>
nnoremap <C-l> :FzfBuffers<CR>

Plugin 'airblade/vim-gitgutter'
let g:gitgutter_max_signs=10000

" Auto-close xml/html tags
Plugin 'sukima/xmledit'
let g:xmledit_enable_html=1
function HtmlAttribCallback( xml_tag )
endfunction

" Awesome minimalistic statusline
Plugin 'itchyny/lightline.vim'
nnoremap <Leader>] :tabn<CR>
nnoremap <Leader>[ :tabp<CR>
nnoremap <Leader><CR> :tabnew<CR>

" Auto-pair brackets and stuff
Plugin 'jiangmiao/auto-pairs'
let g:AutoPairsShortcutFastWrap = '<C-W>'

" Pairs of mappings
Plugin 'tpope/vim-unimpaired'
" Enables line bubbling using unimpaired shortcuts
nmap <C-k> [e
nmap <C-j> ]e
vmap <C-k> [egv
vmap <C-j> ]egv
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi

" Aligns text on certain characters
Plugin 'godlygeek/tabular'
nmap <leader>l= :Tabularize /=<CR>
vmap <leader>l= :Tabularize /=<CR>
nmap <leader>l: :Tabularize /:\zs<CR>
vmap <leader>l: :Tabularize /:\zs<CR>

" Change surroundings of a word
Plugin 'tpope/vim-surround'

" Enable some plugins like surround.vim to be repeated
Plugin 'tpope/vim-repeat'

" Haskell highlighting
Plugin 'neovimhaskell/haskell-vim'

" Clojure stuff
"Plugin 'tpope/vim-leiningen'
Plugin 'guns/vim-clojure-static'
Plugin 'kien/rainbow_parentheses.vim'
  autocmd BufEnter *.clj,*.cljs RainbowParenthesesToggle
  autocmd Syntax *.clj,*.cljs RainbowParenthesesLoadRound
  autocmd Syntax *.clj,*.cljs RainbowParenthesesLoadSquare
  autocmd Syntax *.clj,*.cljs RainbowParenthesesLoadBraces
Plugin 'tpope/vim-fireplace'
Plugin 'kovisoft/slimv'
  let g:slimv_swank_cmd = '! xterm -e clisp -i ~/bin/start-swank.lisp &'
Plugin 'vim-scripts/paredit.vim'
" Plugin 'jpalardy/vim-slime'
"     let g:slime_target = 'tmux'
"     let g:slime_paste_file = tempname()
"
"     nmap ,e va(<C-c><C-c>
"     nmap ,d <C-c><C-c>
"
"     autocmd BufEnter *.clj RainbowParenthesesToggle
"     autocmd BufLeave *.clj RainbowParenthesesToggle
"     autocmd Syntax * RainbowParenthesesLoadRound
"     autocmd Syntax * RainbowParenthesesLoadSquare
"     autocmd Syntax * RainbowParenthesesLoadBraces
"
"     let g:rbpt_colorpairs = [
"                 \ ['magenta',     'purple1'],
"                 \ ['cyan',        'magenta1'],
"                 \ ['green',       'slateblue1'],
"                 \ ['yellow',      'cyan1'],
"                 \ ['red',         'springgreen1'],
"                 \ ['magenta',     'green1'],
"                 \ ['cyan',        'greenyellow'],
"                 \ ['green',       'yellow1'],
"                 \ ['yellow',      'orange1'],
"                 \ ]
"     let g:rbpt_max = 9

" Ruby stuff
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-endwise'
"Plugin 'pgr0ss/vimux-ruby-test'
"map <leader>rb :RunAllRubyTests<CR>
"map <leader>rf :RunRubyFocusedTest<CR>

" Coffeescript support
"Plugin 'kchmck/vim-coffee-script'

" Handlebars support
"Plugin 'mustache/vim-mustache-handlebars'
"let g:mustache_abbreviations = 1

" awesome tmux integration
Plugin 'benmills/vimux'
nnoremap <Leader>rn :VimuxPromptCommand<CR>
nnoremap <Leader>rl :VimuxRunLastCommand<CR>

" Syntax highlighting and colors
Plugin 'ksmithbaylor/tomorrow-theme', {'rtp': 'vim/'} " modified
Plugin 'othree/html5.vim'
Plugin 'lilydjwg/colorizer'
Plugin 'pangloss/vim-javascript'
let g:javascript_ignore_javaScriptdoc = 1
Plugin 'mxw/vim-jsx'
let g:jsx_ext_required = 0
"Plugin 'kongo2002/fsharp-vim'
"Plugin 'guersam/vim-j'
Plugin 'zaiste/tmux.vim'
Plugin 'lambdatoast/elm.vim'
    au BufWritePost *.elm ElmMakeCurrentFile
Plugin 'raichoo/purescript-vim'
Plugin 'elixir-lang/vim-elixir'
Plugin 'rust-lang/rust.vim'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'digitaltoad/vim-pug'

" Searching
Plugin 'mileszs/ack.vim'
let g:ackprg = 'ag --nogroup --nocolor --column'

" Linting
Plugin 'benekastah/neomake'
let g:neomake_javascript_enabled_makers = ['eslint']
" load local eslint in the project root
" modified from https://github.com/mtscout6/syntastic-local-eslint.vim
let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
let g:neomake_javascript_eslint_exe = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
"let g:neomake_open_list = 2
nnoremap <leader>l :Neomake<CR>
autocmd! BufWritePost,BufEnter *.js Neomake

" ------------------------------ END PLUGIN LIST -------------------------------

" Finish initializing Vundle plugins
call vundle#end()
if should_plugin_install == 1
  :silent! PluginInstall
  :qa
endif
filetype plugin indent on



" General Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configure syntax highlighting
syntax enable
colorscheme Tomorrow-Night-Bright

" Change gutter line numbers to be lighter
highlight LineNr      ctermbg=235
highlight LineNr      ctermfg=241

" Necessary for tmux support
set t_Co=256
set t_ut=

" Default tab settings, may be overridden in syntax-specific files
set tabstop=2      " Width of a tab character
set shiftwidth=2   "
set softtabstop=2  " Number of spaces per tabstop
set expandtab      " Uses spaces in place of tab characters

" General options to make things better
set encoding=utf-8                " Default encoding is UTF-8
set scrolloff=3                   " Don't let the cursor get to the edge
set autoindent                    " Start new lines at the same indent level
set showmode                      " Shows the current mode at bottom
set showcmd                       " Shows extra info about the current command
set hidden                        " Hides buffers when they are abandoned
set wildmenu                      " Tab-completion of menu options
set wildmode=list:longest         " List as many possibilities as possible
set visualbell                    " Flash screen instead of beeping for bell
set cursorline                    " Highlight the current line
set ttyfast                       " Improves smoothness in fast terminals
set backspace=indent,eol,start    " Not sure what this does, but I trust him
set laststatus=2                  " Put a statusline in every buffer
set number                        " Display the absolute line number as well
set colorcolumn=81                " Put line after 80 columns

" Tame searching and moving
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

" Make Vim handle long lines correctly
set wrap
set textwidth=80
set formatoptions=qrn1
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

" Show invisible characters
set list
set listchars=tab:▸\

" Re-highlight lines in visual mode after indent
:vnoremap < <gv
:vnoremap > >gv

" Makes Vim use the same zshrc so aliases are available in shell commands
set shell=/bin/bash\ --rcfile\ ~/.bashrc\ -i

" When saving a session, only save certain things
set ssop=blank,buffers,curdir,help,tabpages

" Enable mouse movements
set mouse=nicr

" Set clipboard pasting to automatically work
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif
  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"
  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction
let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

" Highlight trailing whitespace
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufRead,InsertLeave * match ExtraWhitespace /\s\+$/
" Set up highlight group & retain through colorscheme changes
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
map <silent> <LocalLeader>ws :highlight clear ExtraWhitespace<CR>

" Automatically strip trailing blank lines on all files
function! TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
au BufWritePre * call TrimEndLines()

" A wrapper function to restore the cursor position, window position,
" and last search after running a command.
function! Preserve(command)
  " Save the current cursor position
  let save_cursor = getpos(".")
  " Save the window position
  normal H
  let save_window = getpos(".")
  call setpos('.', save_cursor)

  " Do the business:
  execute a:command

  " Restore the window position
  call setpos('.', save_window)
  normal zt
  " Restore the cursor position
  call setpos('.', save_cursor)
endfunction

" highlight all of the word under the cursor
nnoremap * :call Preserve('call feedkeys("*N", "n")')<CR>
" re-indent the whole file
nnoremap <leader>i :call Preserve('normal gg=G')<CR>
" clear trailing whitespace in the whole file
nnoremap <silent> <leader>ww :%s/\s\+$//<CR>:let @/=''<CR><C-o>

" splits the window vertically or horizontally and switches to the new one
nnoremap <leader>s <C-w>v<C-w>l
nnoremap <leader>h <C-w>s<C-w>j

" Move tab left and right
nnoremap <leader>{ :tabm -1<CR>
nnoremap <leader>} :tabm +1<CR>

" Search by visual selection
vnorem * y/<C-r>"<CR>N

nnoremap <leader>a :autocmd BufWritePost * :VimuxRunLastCommand<CR>
nnoremap <leader>x :autocmd! BufWritePost *<CR>

vmap <leader>b S{i(<C-w><C-c>l%
nnoremap <leader>m 0d$i////////////////////////////////////////////////////////////////////////////////<C-c>0

" NEOVIM!
if has("nvim")
  set shell=/usr/local/bin/zsh
  tnoremap <Esc> <C-\><C-n>
endif

" Get rid of the delay after ESC for mappings and shorten it for key codes
"set timeoutlen=1000 ttimeoutlen=10
"autocmd InsertEnter * set timeoutlen=0
"autocmd InsertLeave * set timeoutlen=1000