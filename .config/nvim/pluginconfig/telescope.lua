require('telescope').setup({
  defaults = {
    preview = {
      treesitter = false,
    },
  },
  pickers = {
    find_files = {
      find_command = {'rg', '--files', '--hidden', '--follow', '--glob', '!.git/*'},
    }
  }
})
require('telescope').load_extension('fzf')
