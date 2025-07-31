return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-lua/plenary.nvim" },
      { "render-markdown.nvim" },
      {
        "echasnovski/mini.diff",
        config = function()
          require("mini.diff").setup({
            source = require("mini.diff").gen_source.none(),
          })
        end,
      },
      {
        "saghen/blink.cmp",
        lazy = false,
        version = "*",
        opts = {
          keymap = {
            preset = "enter",
            ["<S-Tab>"] = { "select_prev", "fallback" },
            ["<Tab>"] = { "select_next", "fallback" },
          },
          cmdline = { sources = { "cmdline" } },
          sources = {
            default = { "lsp", "path", "buffer", "codecompanion" },
          },
        },
      },
    },
    opts = {
      display = {
        diff = {
          enabled = true,
          close_chat_at = 240,
          layout = "vertical",
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "default",
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          model = "claude-sonnet-4-20250514",
          keymaps = {
            send = { modes = { n = "<C-s>", i = "<C-s>" }, opts = {} },
            close = { modes = { n = "<C-c>", i = "<C-c>" }, opts = {} },
          },
          slash_commands = {
            file = {
              callback = "strategies.chat.slash_commands.file",
              description = "Select a file using Telescope",
              opts = {
                provider = "snacks",
                contains_code = true,
              },
            },
          },
          icons = {
            buffer_pin = " ",
            buffer_watch = "👀 ",
          },
          debug_window = {
            width = vim.o.columns - 5,
            height = vim.o.lines - 2,
          },
          window = {
            layout = "vertical",
            border = "single",
            height = 0.8,
            width = 0.45,
            relative = "editor",
            full_height = true,
            sticky = false,
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              numberwidth = 1,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
          token_count = function(tokens, _)
            return " (" .. tokens .. " tokens)"
          end,
        },
        inline = {
          adapter = "copilot",
          model = "claude-sonnet-4-20250514",
        },
      },
      log_level = "DEBUG",
    },
  },
}
