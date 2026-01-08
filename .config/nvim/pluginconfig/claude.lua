-- Claude Code Keymaps:
--   Option+c: Toggle Claude Code window (continues most recent session)
--   Option+r: Open conversation picker to resume a past session
--   Option+n: Start a new Claude Code session
--   Option+f: Toggle layout between float and vertical split (when closed)
--   Option+e: Exit terminal mode (return to normal mode)

-- New session keymap (auto-pairs <M-n> disabled in auto-pairs.lua)
vim.keymap.set({'n', 'i'}, '<M-n>', '<cmd>ClaudeCode<CR>', { desc = 'New Claude Code session' })

-- Exit terminal mode with Option+e
vim.keymap.set('t', '<M-e>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation from terminal mode (matches normal <C-w> behavior)
vim.keymap.set('t', '<C-w>h', '<C-\\><C-n><C-w>h', { desc = 'Navigate to left window' })
vim.keymap.set('t', '<C-w>j', '<C-\\><C-n><C-w>j', { desc = 'Navigate to window below' })
vim.keymap.set('t', '<C-w>k', '<C-\\><C-n><C-w>k', { desc = 'Navigate to window above' })
vim.keymap.set('t', '<C-w>l', '<C-\\><C-n><C-w>l', { desc = 'Navigate to right window' })

-- Track current layout mode
local claude_layout = "float"

-- Setup function that can be called with different layouts
local function setup_claude(layout)
  claude_layout = layout
  require("claude-code").setup({
    window = {
      split_ratio = 0.5,
      position = layout,
      enter_insert = true,
      hide_numbers = true,
      hide_signcolumn = true,
      float = {
        width = "95%",
        height = "95%",
        row = "center",
        col = "center",
        relative = "editor",
        border = "double",
      },
    },
    refresh = {
      enable = true,
      updatetime = 100,
      timer_interval = 1000,
      show_notifications = true,
    },
    git = { use_git_root = true },
    shell = {
      separator = '&&',
      pushd_cmd = 'pushd',
      popd_cmd = 'popd',
    },
    command = "claude",
    command_variants = {
      continue = "--continue",
      resume = "--resume",
      verbose = "--verbose",
    },
    keymaps = {
      toggle = {
        normal = "<M-c>",
        insert = "<M-c>",
        terminal = "<M-c>",
        variants = {
          continue = "<M-c>",
          resume = "<M-r>",
        },
      },
      window_navigation = false,  -- Using custom <C-w> mappings instead
      scrolling = false,
    }
  })
end

-- Toggle layout (only when closed)
local function toggle_claude_layout()
  local claude_code = require("claude-code")
  if claude_code.is_open and claude_code.is_open() then
    return
  end

  local new_layout = claude_layout == "float" and "vertical" or "float"
  if new_layout == "vertical" then
    vim.opt.splitright = true
  end
  setup_claude(new_layout)
  vim.cmd("echo 'Claude Code layout: " .. new_layout .. "'")
end

vim.keymap.set({'n', 'i'}, '<M-f>', toggle_claude_layout, { desc = 'Toggle Claude Code layout' })

-- Initial setup
setup_claude("float")
