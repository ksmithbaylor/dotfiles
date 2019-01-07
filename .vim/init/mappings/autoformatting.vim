" Put all commands that format on save here
function! ToggleAutoFormatting()
    if !exists('#AutoFormattingPreSave#BufWritePre')
        augroup AutoFormattingPreSave
            autocmd!
            autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.vue,*.css,*.less,*.scss,*.graphql Prettier
            autocmd BufWritePre *.cpp,*.hpp,*.c,*.h Neoformat
            autocmd BufWritePost *.elm ElmFormat
            autocmd BufWritePre *.ex,*.exs MixFormat
            autocmd BufWritePre *.py Yapf
            autocmd BufWritePre *.rs call Preserve('%!rustfmt')
        augroup END
        echo 'Auto-formatting on'
    else
        augroup AutoFormattingPreSave
            autocmd!
        augroup END
        echo 'Auto-formatting off'
    endif
endfunction

" Set up a mapping to toggle all auto-formatting commands
nnoremap <F3> :call ToggleAutoFormatting()<CR>

" Go ahead and turn it on by default
silent call ToggleAutoFormatting()
