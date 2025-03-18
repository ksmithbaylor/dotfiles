-- See the available model choices by running
-- `:lua print(vim.inspect(require("codecompanion.adapters.copilot").schema.model.choices()))`
-- after executing at least one request to CodeCompanion
local preferred_model = "claude-3.7-sonnet"

vim.keymap.set({'n', 'v'}, '<C-l>i', '<Cmd>CodeCompanion<CR>', { noremap = true, silent = true })
vim.keymap.set({'n', 'v'}, '<C-l>c', '<Cmd>CodeCompanionChat<CR>', { noremap = true, silent = true })

require("codecompanion").setup({
  display = {
    diff = {
      provider = "mini_diff",
      close_chat_at = 1000,
    },
  },
  adapters = {
    -- opts = {
    --   allow_insecure = true,
    --   proxy = "http://localhost:12345",
    -- },
    copilot = function()
      return require("codecompanion.adapters").extend("copilot", {
        schema = {
          model = {
            default = preferred_model
          },
        },
      })
    end,
  },
  strategies = {
    chat = {
      adapter = "copilot",
      keymaps = {
        send = {
          modes = { n = "<C-a>", i = "<C-a>" },
        },
        close = {
          modes = { n = "<C-q>", i = "<C-q>" },
        },
      },
    },
    inline = {
      adapter = "copilot",
      keymaps = {
        accept_change = {
          modes = { n = "<C-a>" },
          description = "Accept the suggested change",
        },
        reject_change = {
          modes = { n = "<C-q>" },
          description = "Reject the suggested change",
        },
      },
    }
  }
})
