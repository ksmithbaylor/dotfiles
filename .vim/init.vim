" Install and configure plugins
source $HOME/.vim/plugs.vim

" Put backup and swap files in a central location
silent !mkdir -p $HOME/.vim/swapfiles > /dev/null 2>&1
silent !mkdir -p $HOME/.vim/backup > /dev/null 2>&1
set directory=$HOME/.vim/swapfiles//
set backupdir=$HOME/.vim/backup//

" General options to make things better
set nocompatible                  " Don't use old vi-era compatibility settings
set encoding=utf-8                " Default encoding is UTF-8
set scrolloff=1                   " Don't let the cursor get to the edge
set autoindent                    " Start new lines at the same indent level
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
set cinkeys-=0#                   " Don't force # directives to column 0 (OpenMP)
set wrap
set textwidth=80
set formatoptions=qrn1
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
set tabstop=2      " Width of a tab character
set shiftwidth=2   "
set softtabstop=2  " Number of spaces per tabstop
set expandtab      " Uses spaces in place of tab characters
set list               " invisible characters
set listchars=tab:▸\

" Makes Vim use the same zshrc so aliases are available in shell commands
set shell=/bin/bash\ --rcfile\ ~/.bashrc\ -i

" When saving a session, only save certain things
set ssop=blank,buffers,curdir,help,tabpages

" Enable mouse movements
set mouse=nicr

if has("nvim")
  set inccommand=split
  set shell=/usr/local/bin/zsh
  tnoremap <Esc> <C-\><C-n>
endif

" Tmux-specific settings for colors and pasting
set t_Co=256
set t_ut=
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


" ------------------------------------------------------------------------------
" === MAPPINGS =================================================================

" Clear the current search
nnoremap <leader><space> :noh<cr>

" Make Vim handle long lines correctly
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

" Enable quicker creation and navigation of tabs
nnoremap <leader>] :tabn<CR>
nnoremap <leader>[ :tabp<CR>
nnoremap <leader><CR> :tabnew<CR>
nnoremap <leader>{ :tabm -1<CR>
nnoremap <leader>} :tabm +1<CR>

" Enable 'line bubbling' (requires vim-unimpaired)
nmap <C-k> [e
nmap <C-j> ]e
vmap <C-k> [egv
vmap <C-j> ]egv
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi

" Re-highlight lines in visual mode after indent
vnoremap < <gv
vnoremap > >gv

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

" Highlight all of the word under the cursor
nnoremap * :call Preserve('call feedkeys("*N", "n")')<CR>

" Re-indent the whole file
nnoremap <leader>i :call Preserve('normal gg=G')<CR>

" Clear trailing whitespace in the whole file
nnoremap <silent> <leader>ww :%s/\s\+$//<CR>:let @/=''<CR><C-o>

" Splits the window vertically or horizontally and switches to the new one
nnoremap <leader>s <C-w>v<C-w>l
nnoremap <leader>h <C-w>s<C-w>j

" Search by visual selection
vnoremap * y/<C-r>"<CR>N

" Two-column scrollbinding
nnoremap <silent> <leader>vs :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>


" ------------------------------------------------------------------------------
" === MORE COMPLEX FEATURES ====================================================

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

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

function! ToggleAutoFormatting()
    if !exists('#AutoFormattingPreSave#BufWritePre')
        augroup AutoFormattingPreSave
            autocmd!
            autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.vue,*.css,*.less,*.scss,*.graphql Prettier
            autocmd BufWritePre *.cpp,*.hpp,*.c,*.h Neoformat
            autocmd BufWritePost *.elm ElmFormat
            autocmd BufWritePre *.ex,*.exs MixFormat
        augroup END
        echo 'Auto-formatting on'
    else
        augroup AutoFormattingPreSave
            autocmd!
        augroup END
        echo 'Auto-formatting off'
    endif
endfunction

nnoremap <F3> :call ToggleAutoFormatting()<CR>
silent call ToggleAutoFormatting()

" Configure syntax highlighting
"Credit joshdick
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
  set termguicolors
endif
set t_8b=[48;2;%lu;%lu;%lum
set t_8f=[38;2;%lu;%lu;%lum
syntax enable
" colorscheme Tomorrow-Night-Bright
let g:one_allow_italics = 1 " I love italic for comments
set background=dark
colorscheme one
highlight link jsComment Comment
highlight link vimComment Comment
highlight link elmLineComment Comment
highlight Comment cterm=italic

" Change gutter line numbers to be lighter
highlight LineNr      ctermbg=235
highlight LineNr      ctermfg=241
