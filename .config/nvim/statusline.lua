-- Hide the default status indicator below the statusline
vim.cmd [[
  set noshowmode
]]

require('lualine').setup {
  options = {
    theme = 'night-owl'
  }
}
