function! neoformat#formatters#javascript#enabled() abort
    return ['prettierLocal', 'jsbeautify', 'prettier', 'prettydiff', 'clangformat', 'esformatter', 'prettiereslint', 'eslint_d']
endfunction

function! neoformat#formatters#javascript#jsbeautify() abort
    return {
            \ 'exe': 'js-beautify',
            \ 'args': ['--indent-size ' .shiftwidth()],
            \ 'stdin': 1,
            \ }
endfunction

function! neoformat#formatters#javascript#clangformat() abort
    return {
            \ 'exe': 'clang-format',
            \ 'stdin': 1
            \ }
endfunction

function! neoformat#formatters#javascript#prettydiff() abort
    return {
        \ 'exe': 'prettydiff',
        \ 'args': ['mode:"beautify"',
                 \ 'lang:"javascript"',
                 \ 'readmethod:"filescreen"',
                 \ 'endquietly:"quiet"',
                 \ 'source:"%:p"'],
        \ 'no_append': 1
        \ }
endfunction

function! neoformat#formatters#javascript#esformatter() abort
    return {
        \ 'exe': 'esformatter',
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#javascript#prettier() abort
    return {
        \ 'exe': 'prettier',
        \ 'args': ['--stdin', '--single-quote'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#javascript#prettierLocal() abort
    return {
        \ 'exe': './node_modules/.bin/prettier',
        \ 'args': ['--stdin', '--single-quote'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#javascript#prettiereslint() abort
    return {
        \ 'exe': 'prettier-eslint',
        \ 'args': ['--stdin'],
        \ 'stdin': 1,
        \ }
endfunction
function! neoformat#formatters#javascript#eslint_d() abort
    return {
        \ 'exe': 'eslint_d',
        \ 'args': ['--stdin','--fix-to-stdout'],
        \ 'stdin': 1,
        \ }
endfunction
