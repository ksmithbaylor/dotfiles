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
