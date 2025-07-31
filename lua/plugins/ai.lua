return {
  {
    "github/copilot.vim",
    config = function()
      -- Enable Copilot by default
      vim.g.copilot_enabled = 1

      -- Enable Copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ["*"] = false,
        lua = true,
        python = true,
        javascript = true,
        typescript = true,
        go = true,
        rust = true,
        c = true,
        cpp = true,
        sh = true,
      }

      -- Keymaps for Copilot
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true })
      vim.api.nvim_set_keymap("i", "<C-]>", "copilot#Next()", { expr = true, silent = true, noremap = true })
      vim.api.nvim_set_keymap("i", "<C-[>", "copilot#Previous()", { expr = true, silent = true, noremap = true })
      vim.api.nvim_set_keymap("i", "<C-\\>", "copilot#Dismiss()", { expr = true, silent = true, noremap = true })

      -- Don't enable Copilot in commit messages or prompt buffers
      vim.cmd([[
        autocmd FileType gitcommit,NeogitCommitMessage Copilot disable
        autocmd FileType TelescopePrompt Copilot disable
      ]])
    end,
  },
}
