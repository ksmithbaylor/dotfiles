local function on_attach_nvim_tree(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set("n", "<C-t>", api.tree.close, opts("Close Tree"))
  vim.keymap.set("n", "t", api.node.open.tab, opts("Open in new tab"))
end

require("nvim-tree").setup({
  on_attach = on_attach_nvim_tree,
  sort = {
    sorter = "case_sensitive"
  },
  view = {
    float = {
      enable = true,
      open_win_config = {
        relative = "editor",
        border = "rounded",
        width = 30,
        height = 40,
        row = 1,
        col = 1
      }
    }
  },
  filters = {
    git_ignored = false,
    dotfiles = false,
    git_clean = false,
    no_buffer = false,
    custom = {},
    exclude = {},
  }
})
